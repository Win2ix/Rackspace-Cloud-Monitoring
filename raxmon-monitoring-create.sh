#!/bin/bash

# raxmon-monitoring-create 
# Copyright 2013 Sujith Jose <sjose@win2ix.ca> http://www.win2ix.ca
# version = '0.1';

#begin GPL
#    This file is part of raxmon-monitoring-create.
#
#    raxmon-monitoring-create is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    raxmon-monitoring-create is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with raxmon-monitoring-create.  If not, see <http://www.gnu.org/licenses/>.
#end GPL

# Script to enable monitoring for services in RackSpace

# Checking to see if the raxmon utility is installed....

installcheck=`which raxmon-entities-list`

if [ $? -ne 0 ];then
	echo "Raxmon not installed.  Please install it before running this tool. Exiting...";
	exit 1
fi

# Creating an Entity

raxmon-entities-list | grep label
echo "Is the server you wish to be monitored in the list? (y/n)"
read text
if [ `echo $text | tr [:upper:] [:lower:]` != "y" ];then
	echo "Enter the name of the server to be monitored"
	read label
	echo "Enter the Ip address of the server to be monitored"
	read ipaddress
	raxmon-entities-create --label=$label --ip-address="$label=$ipaddress" > /tmp/$label-entity
	entityid=`cat /tmp/$label-entity | awk '{print $4}'`
	echo "The entity id is $entityid"
else
	echo "Input the Id of the server which is shown"
	read entityid
	echo "The entity id is $entityid"
fi

# Creating/listing a notification list

raxmon-entities-list | grep $entityid | awk '{print $3}' | sed -e 's/label=//' > /tmp/label
labelid=`cat /tmp/label`
raxmon-notification-plans-list --details | grep id | awk '{print $2}' | sed s/\'//g | sed -e 's/.\{1\}$//' | sed -e "1d" > /tmp/notificationplanid1
	for n in `cat /tmp/notificationplanid1`
        do
        raxmon-notification-plans-list --marker=$n --details |  awk '/ok_state/{++t}t==1' | awk '/ok_state/,/warning_state/' | awk -vRS="]" -vFS="[" '{print $2}' | sed s/\'//g | sed 's/.*\[//;s/\].*//;' | tr "," "\n" | tr -d ' ' | sort | uniq | awk 'NF' > /tmp/notificationplanid2
        	for q in `cat /tmp/notificationplanid2`
               	 	do
                	raxmon-notifications-list --marker=$q --details | awk '/address/{++t}t==1' | awk '/details/,/driver/' | grep details |awk '{print $3}'| sed -e 's/.\{2\}$//' >> /tmp/emailaddress2
                	done
        	cat /tmp/emailaddress2 | tr "\n" "," | sed -e 's/.\{1\}$//' > /tmp/emailaddress3
        	echo "The notificationplan-id $n contains the following emailaddress `cat /tmp/emailaddress3`"
        	cat /dev/null > /tmp/emailaddress2
        	cat /dev/null > /tmp/notificationplanid2
	done
cat /dev/null > /tmp/notificationplanid1
echo "Does the email address that you want to send the alerts already configured in the correct notification plan (y/n)"
read text1
if [ `echo $text1 | tr [:upper:] [:lower:]` != "y" ];then
	{
	echo "How many email address do you want to configure"
	read number
	i=1
		while [ $i -le $number ]
		do
		echo "Enter the emailaddress"
		read emailaddress
		raxmon-notifications-create --label="notify-email" --type=email --details=address=$emailaddress >> /tmp/notifications
		i=$(( $i + 1 ))
		done
	cat /tmp/notifications | awk '{print $4}' > /tmp/notificationsid
	cat /dev/null > /tmp/notifications
	notificationids=`cat /tmp/notificationsid | tr -s '\r\n' ',' | sed -e 's/,$/\n/'`
	raxmon-notification-plans-create --label=NotifcationPlan-$$ --critical-state=$notificationids --warning-state=$notificationids --ok-state=$notificationids > /tmp/notifcationplanid
	notificationplanid=`cat /tmp/notifcationplanid | awk '{print $4}'`
	}
else
	{
	echo "The email adddress exisists in the correct notification plan "
	echo "Select the notification plan id which you would like to use from the above"
	read notificationplanid
	}
fi
echo "What type of check do you want to configure enter 1 for HTTP, 2 for PING and 3 for IMAP"
read C 
case "$C" in
	"1")
		echo "Creating a new http check for this server"
		echo "Enter the complete URL of the server to be monitored"
		read url
		echo "Enter the string you want to search in the above URL"
		read string1
		echo $string1 > /tmp/string1
		string=`cat /tmp/string1`
		raxmon-checks-create --entity-id=$entityid --type=remote.http --label=$labelid --monitoring-zones=mzlon,mzdfw,mzord  --details=url=$url,body="$string",method=GET --timeout=110 --period=120 --target-alias=$labelid > /tmp/checkid
		checkid=`cat /tmp/checkid | awk '{print $4}'`
		echo "Creating an alert to check for given string $string in the body of the content" 
		raxmon-alarms-create --entity-id=$entityid --check-id=$checkid --criteria="if (metric['body_match'] == '${string}') {return OK, 'HTTP response contains the correct content ${string}'} return CRITICAL, 'HTTP response did not contain the correct content ${string}'" --notification-plan-id=$notificationplanid --metadata=consistency-level=Quorum
		echo "Creating an alert to chek for the status code of the website"
		raxmon-alarms-create --entity-id=$entityid --check-id=$checkid --criteria="if (metric[\"code\"] regex \"^[23]..$\") { return OK } return WARNING" --notification-plan-id=$notificationplanid --metadata=consistency-level=Quorum
		echo "Creating an alert to check for the time taken to reach the website threshold is 10000ms"
		raxmon-alarms-create --entity-id=$entityid --check-id=$checkid --criteria="if (metric[\"duration\"] < 10000) { return OK } return WARNING" --notification-plan-id=$notificationplanid --metadata=consistency-level=Quorum
    ;;
	"2")
		echo "Creating a new ping check for this server"
		raxmon-checks-create --entity-id=$entityid --type=remote.ping --label=$labelid --monitoring-zones=mzlon,mzdfw,mzord --period=120 --target-alias=$labelid > /tmp/checkid
		checkid=`cat /tmp/checkid | awk '{print $4}'`
		echo "Creating an alarm which returns WARNING if the packet loss is greater than 5% and CRITICAL if it's greater than 20%" 
		raxmon-alarms-create --entity-id=$entityid --check-id=$checkid --criteria="if (metric['available'] < 80) {return CRITICAL, 'Packet loss is greater than 20%'} if (metric['available'] < 95) {return WARNING, 'Packet loss is greater than 5%'} return OK, 'Packet loss is normal'" --notification-plan-id=$notificationplanid --metadata=consistency-level=Quorum
    ;;
	"3")
		echo "Creating an new IMAP check for this server"
		echo "Creating an SMTP check"
		raxmon-checks-create --entity-id=$entityid --type=remote.smtp --label=$labelid --monitoring-zones=mzlon,mzdfw,mzord --period=120 --target-alias=$labelid >  /tmp/checkid
		checkid=`cat /tmp/checkid | awk '{print $4}'`
		echo "Creating an Alarm for SMTP check"
		raxmon-alarms-create --entity-id=$entityid --check-id=$checkid --criteria="if (metric['ehlo_response_banner'] == '${labelid}') {return OK, 'SMTP is OK'} return CRITICAL, 'SMTP is not OK'" --notification-plan-id=$notificationplanid --metadata=consistency-level=Quorum
		echo "Creating a check for IMAP"
		raxmon-checks-create --entity-id=$entityid --type=remote.imap-banner --label=$labelid --monitoring-zones=mzlon,mzdfw,mzord --period=120 --target-alias=$labelid >  /tmp/checkid
		checkid=`cat /tmp/checkid | awk '{print $4}'`
		echo "Creating an alert to check for IMAP"
		raxmon-alarms-create --entity-id=$entityid --check-id=$checkid --criteria="if (metric['banner_match'] != '') {return OK, 'IMAP is OK'} return CRITICAL, 'IMAP is not OK'" --notification-plan-id=$notificationplanid --metadata=consistency-level=Quorum
    ;;
	*)
		echo "Sorry this is not a recognized option ...exiting"
		exit
    ;;
esac
echo "Everything is complete and your alerts have been setup"
exit

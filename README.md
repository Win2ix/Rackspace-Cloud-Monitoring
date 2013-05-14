RackSpace Cloud Monitoring Create script prepared by Win2ix

This script will help us in   

1) Monitoring of multiple number of servers.
2) Adding Multiple email address.
3) Creating checks for HTTP check , Ping or Imap .

Prerequisites

1) Should have rackspace account ( username and api key).You will be able to get the API key by logging into the rackspace portal https://mycloud.rackspace.com/ ( Using your username and  passowrd. )    
2) A unix/linux machine (desktop/server) with access to the internet.
   
Installation of RaxmonCLI a Command line Interface (CLI) tool

Raxmon requires Python 2.5,2.6 or 2.7. This CLI tool is available in github as open source :  https://github.com/racker/rackspace-monitoring-cli
Install the rackspace-monitoring-cli using the pip tool.

Configuring the RaxmonCLI

Under your home directory from where you would like to run the raxmon tool create a .raxrc file. Enter the following in the file

[credentials]
username=<<YOUR USERNAME>> 
api_key=<<YOUR API KEY>>
[api]
url=https://monitoring.api.rackspacecloud.com/v1.0
[auth_api]
url=https://identity.api.rackspacecloud.com/v2.0
[ssl]
verify=true 

For the complete installation steps you will find the document in http://www.rackspace.com/knowledge_center/article/getting-started-with-remote-monitoring

Once the RaxmonCLI have been configured test the same by using raxmon-entities-list.

Copy over the script raxmon-monitoring-create.sh to the same home directory and give the script executable privileges.
 
Running the Script

1) Once you run the script , it will display the list of servers which is presently being monitored. If the server for which you would like to configure the new check is already then use the id for the same or else create a new server to be monitored.
2) Now it will list out the list of email address for which you would like to configure the alerts. If all the email address exist then use them , if not create a new plan with all the email address.
3) Then it will ask the type of check you want to configure you can select 1 for HTTP, 2 for PING and 3 for IMAP.
4) Answer all the set of questions and your script would be created.
5) By default this script makes use of 3 different monitoring zones (mzlon,mzdfw,mzord) however you will be easily able to change this. 

Note: This script would be helpful when creating multiple checks for multiple servers.
To make modification to the checks or to add 1-2 servers or checks you can always login to the GUI : https://ui-labs.cloudmonitoring.rackspace.com/

Please contact Win2ix Systems if you have any issues or for any modifications.      

**RackSpace Cloud Monitoring Create script prepared by Win2ix**

Sujith Jose <sjose@win2ix.ca>
Win2ix Systems Inc. http://www.win2ix.ca


This script will help us to:

  * Monitoring multiple number of servers.
  * Adding Multiple email address.
  * Creating checks for HTTP check, Ping or Imap.

**Prerequisites**

1. Should have rackspace account ( username and api key).
 
    You will be able to get the API key by logging into the rackspace portal <https://mycloud.rackspace.com> (using your username and  password) from a Unix/linux machine (desktop/server) with access to the internet.
   
2. Installation of RaxmonCLI a Command line Interface (CLI) tool

    Raxmon requires Python 2.5,2.6 or 2.7. This CLI tool is available in github as open source:  <https://github.com/racker/rackspace-monitoring-cli>

3. Install the rackspace-monitoring-cli using the pip tool.

**Configuring the RaxmonCLI**

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
	
For the complete installation steps, please refer to <http://www.rackspace.com/knowledge_center/article/getting-started-with-remote-monitoring>

Once the RaxmonCLI have been configured, make sure it is working by running `raxmon-entities-list`.

Copy over the script raxmon-monitoring-create.sh to the same home directory and give the script executable privileges.
 
**Running the Script**

Once you run the script, it will display the list of servers which is presently being monitored.  If you wish to add a check for a new server, either create a new server or use an existing, un-monitored server and use that server's id to configure the new check.

Now it will list out the list of email address for which you would like to configure the alerts. If all the email addresses exist then use them.  If not, create a new plan with all the email addresses.

The script will then ask for the type of check you want to configure.  You can select: 

  * `1` for HTTP
  * `2` for PING
  * `3` for IMAP

Answer this set of questions and your script will be created.

**Notes**

  1. By default, this script makes use of 3 different monitoring zones

	  * mzlon
	  * mzdfw
	  * mzord 
	
	However, you can change this easily. (ed.: how?) 


  2. This script is helpful for creating multiple checks for multiple servers.  To make modification to the checks, to add more servers, or to add more checks, you can always login to the GUI: <https://ui-labs.cloudmonitoring.rackspace.com>

**Contact**

Please contact Win2ix Systems (<http://www.win2ix.ca>) if you have any issues or for any modifications.

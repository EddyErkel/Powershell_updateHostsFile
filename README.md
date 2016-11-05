# Poweshell_updateHostsFile
PowerShell script for @StevenBlack 's hosts project

.CREATION
Created by : Eddy Erkel
Version    : 1.5
Date       : 5 November 2016   

.SYNOPSIS
Update your hosts file by using different sources from the internet.

.DESCRIPTION
This PowerShell script will combine local host files with online host files into one, unique host file for safe internet browsing.
Online hosts file sources are provided by Steven Black at https://github.com/StevenBlack/hosts.

RUN THIS SCRIPT WITH ADMINISTRATOR PRIVELAGES.
The script needs to be run with administrator privelages, therefor open PowerShell by rightclicking the PowerShell icon and select 'Run as administrator'.
	
.PARAMETER Gambling
Block gambling domains. 

.PARAMETER Porn
Block porn domains.

.PARAMETER Social
Block social domains.

.PARAMETER Backup
Create a backup of the current active hosts file. 
Provide the number of backup files to keep. Use 0 to keep all files.

.PARAMETER IP
Replace IP-addresses. Default IP-address is 0.0.0.0.

.PARAMETER Replace
Replace current active hosts file and and flush the DNS cache.

.PARAMETER UseHostsDir
Use the hosts directory for downloading and processing. By default the script directory is used.

.PARAMETER ReportDomains
Display added, white-listed and black-listed hosts.

.INPUT-FILE myhosts
This script will look for the file "myhosts.txt" (unless otherwise specified below) and when found it will add all entries found to the end of the hosts file.
The myhost file format is the same as you would add to the hosts file.
Myhosts file format: 
10.0.0.1 www.domain-name1.com
10.0.0.2 www.domain-name2.com

.INPUT-FILE whitelist
This script will look for the file "whitelist.txt" (unless otherwise specified below) and when found it will search through the hosts file and
whitelist all domains found in the whitelist file by adding a hash (#) sign at the start of the line.
Whitelist file format: 
domain-name3.com
www.domain-name4.com

* domain-name3.com -> all domains ending with domain-name1.com will be whitelisted e.g. www.domain-name1.com, home.domain-name1.com, etc.
* www.domain-name4.com -> will whitelist domains ending with www.domain-name2.com (most likely only www.domain-name2.com).

.INPUT-FILE blacklist
This script will look for the file "blacklist.txt" (unless otherwise specified below) and when found it will add all entries found to the end of the hosts file.
The blacklist file format is the same as you would add to the hosts file.
Blacklist file format: 
www.domain-name5.com
www.domain-name6.com

.EXAMPLE
.\updateHostsFile.ps1 -Gambling -Social -Porn -Replace -Backup 6 -IP 1.2.3.4 -UseHostsDir
.\updateHostsFile.ps1 -Gambling -Social -Porn -IP 127.0.0.1 -Backup 0 -Replace
.\updateHostsFile.ps1 -Gambling -Social -Porn -Backup 3 -Replace
.\updateHostsFile.ps1 -Replace

To bypass the PowerShell Execution Policy type:
powershell.exe -executionpolicy bypass -file .\updateHostsFile.ps1 -Gambling -Replace

To create a scheduled task use:
Program/script: powershell.exe
Add arguments : -executionpolicy bypass -file <Path-to-script>\updateHostsFile.ps1 
Start in	  : Leave blank / empty


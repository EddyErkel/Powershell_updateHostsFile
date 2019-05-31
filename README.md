# Powershell_updateHostsFile
PowerShell script for @StevenBlack 's hosts project https://github.com/StevenBlack/hosts.

Below tekst is a copy from the comments in the 'updateHostsFile.ps1' PowerShell script:<BR>
<BR>
.CREATION<BR>
Created by : Eddy Erkel<BR>
Version    : 1.51<BR>
Date       : 27 October 2018<BR>
<BR>
.DISCLAMER<BR>
This script is provided "as is", without warranty of any kind.<BR>
Use it at your own risk. I assume no liability for damages,<BR>
direct or consequential, that may result from the use of this script.<BR>
<BR>
Grateful for my work and in a generous mood?<BR>
BTC: 18JNWyGhfAmhkWs7jzuuHn54jEZRPj81Jx<BR>
ETH: 0x067e8b995f7dbaf32081bc32927f6fac29b32055<BR>
LTC: LLqwyRiKiuvxkx76grFmbxEeoChLnxvaKH<BR>
<BR>
.SYNOPSIS<BR>
Update your hosts file by using different sources from the internet.<BR>
<BR>
.DESCRIPTION<BR>
This PowerShell script will combine local host files with online host files into one, unique host file for safe internet browsing.<BR>
Online hosts file sources are provided by Steven Black at https://github.com/StevenBlack/hosts.<BR>
<BR>
RUN THIS SCRIPT WITH ADMINISTRATOR PRIVELAGES.<BR>
The script needs to be run with administrator privelages, therefor open PowerShell by rightclicking the PowerShell icon and select 'Run as administrator'.<BR>
<BR>
.PARAMETER Gambling<BR>
Block gambling domains.<BR>
<BR>
.PARAMETER Porn<BR>
Block porn domains.<BR>
<BR>
.PARAMETER Social<BR>
Block social domains.<BR>
<BR>
.PARAMETER Backup<BR>
Create a backup of the current active hosts file.<BR> 
Provide the number of backup files to keep. Use 0 to keep all files.<BR>
<BR>
.PARAMETER IP<BR>
Replace IP-addresses. Default IP-address is 0.0.0.0.<BR>
<BR>
.PARAMETER Replace<BR>
Replace current active hosts file and and flush the DNS cache.<BR>
<BR>
.PARAMETER UseHostsDir<BR>
Use the hosts directory for downloading and processing. By default the script directory is used.<BR>
<BR>
.PARAMETER ReportDomains<BR>
Display added, white-listed and black-listed hosts.<BR>
<BR>
.INPUT-FILE myhosts<BR>
This script will look for the file "myhosts.txt" (unless otherwise specified below) and when found it will add all entries found to the end of the hosts file.<BR>
The myhost file format is the same as you would add to the hosts file.<BR>
Myhosts file format:<BR>
10.0.0.1 www.domain-name1.com<BR>
10.0.0.2 www.domain-name2.com<BR>
<BR>
.INPUT-FILE whitelist<BR>
This script will look for the file "whitelist.txt" (unless otherwise specified below) and when found it will search through the hosts file and whitelist all domains found in the whitelist file by adding a hash (#) sign at the start of the line.<BR>
Whitelist file format:<BR> 
domain-name3.com<BR>
www.domain-name4.com<BR>
<BR>
~ domain-name3.com -> all domains ending with domain-name1.com will be whitelisted e.g. www.domain-name1.com, home.domain-name1.com, etc.<BR>
~ www.domain-name4.com -> will whitelist domains ending with www.domain-name2.com (most likely only www.domain-name2.com).<BR>
<BR>
.INPUT-FILE blacklist<BR>
This script will look for the file "blacklist.txt" (unless otherwise specified below) and when found it will add all entries found to the end of the hosts file.<BR>
The blacklist file format is the same as you would add to the hosts file.<BR>
Blacklist file format:<BR> 
www.domain-name5.com<BR>
www.domain-name6.com<BR>
<BR>
.EXAMPLE<BR>
.\updateHostsFile.ps1 -Gambling -Social -Porn -Replace -Backup 6 -IP 1.2.3.4 -UseHostsDir<BR>
.\updateHostsFile.ps1 -Gambling -Social -Porn -IP 127.0.0.1 -Backup 0 -Replace<BR>
.\updateHostsFile.ps1 -Gambling -Social -Porn -Backup 3 -Replace<BR>
.\updateHostsFile.ps1 -Replace<BR>
<BR>
To bypass the PowerShell Execution Policy type:<BR>
powershell.exe -executionpolicy bypass -file .\updateHostsFile.ps1 -Gambling -Replace<BR>
<BR>
To create a scheduled task use:<BR>
Program/script: powershell.exe<BR>
Add arguments : -executionpolicy bypass -file <Path-to-script>\updateHostsFile.ps1<BR>
Start in	  : Leave blank / empty<BR>
<BR>

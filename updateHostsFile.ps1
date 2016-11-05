<#
.CREATION
Created by : Eddy Erkel
Version    : 1.4
Date       : 26 August 2016   

.SYNOPSIS
Update your hosts file by using different sources from the internet.

.DESCRIPTION
RUN THIS SCRIPT WITH ADMINISTRATOR PRIVELAGES.
This PowerShell script will combine local host files with online host files into one, unique host file for safe internet browsing.
Online hosts file sources are provided by Steven Black at https://github.com/StevenBlack/hosts.
	
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
.\UpdateHostsFile.ps1 -Gambling -Social -Porn -Replace -Backup 6 -IP 1.2.3.4 -UseHostsDir
.\UpdateHostsFile.ps1 -Gambling -Social -Porn -IP 127.0.0.1 -Backup 0 -Replace
.\UpdateHostsFile.ps1 -Gambling -Social -Porn -Backup 3 -Replace
.\UpdateHostsFile.ps1 -Replace

To bypass the PowerShell Execution Policy type:
powershell.exe -executionpolicy bypass -file .\UpdateHostsFile.ps1 -Gambling -Replace

To create a scheduled task use:
Program/script: powershell.exe
Add arguments : -executionpolicy bypass -file <Path-to-script>\UpdateHostsFile.ps1 
Start in	  : Leave blank / empty
#>

Param (
	[Parameter(Mandatory=$false)]
	[switch]$Gambling,
	[Parameter(Mandatory=$false)]
	[switch]$Porn,
	[Parameter(Mandatory=$false)]
	[switch]$Social,
	[Parameter(Mandatory=$false)]
	[int]$Backup,
	[Parameter(Mandatory=$false)]	
	[string]$IP,
	[Parameter(Mandatory=$false)]
	[switch]$Replace,
	[Parameter(Mandatory=$false)]
	[switch]$UseHostsDir,
	[Parameter(Mandatory=$false)]
	[switch]$ReportDomains
)

# Read start time
$startTime = Get-Date
$timeStamp = (Get-Date -format yyyyMMdd-HHmmss)

# Set defaults IP address
$defaultIP = "0.0.0.0"

# Set My Hosts file
$myHosts = "myhosts.txt"

# Set Whitelist file
$whiteList = "whitelist.txt"

# Set Blacklist file
$blackList = "blacklist.txt"

# Read SystemRoot environment variable
$systemRoot = $Env:SystemRoot

# Set hosts file directory
$hostsDir = "$systemRoot\System32\drivers\etc"

# Get script path
$scriptDir = $PSScriptRoot
If (!($scriptPath))
	{
	# Get script path via Powershell v2 command
	$scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}

Write-Host `n

# Check hosts file last modify date
$hostFileDate = (Get-Item $hostsDir\hosts).LastWriteTime
$daysSinceUpdate=(New-TimeSpan -Start $hostFileDate -End $startTime).Days
Write-Host "Your systems current active hosts file was last updated on $hostFileDate ($daysSinceUpdate days ago)."
Write-Host `n

# Set replacement IP address
If (!($IP))
	{	
	$IP = $defaultIP
}
Write-Host "Using `"$IP`" as replace/blacklist IP-address."

# Set process directory
If ($UseHostsDir)
	{
	Write-Host "Using $hostsDir\ for downloading and processing."
	$processDir = $hostsDir
}
Else 
	{
	Write-Host "Using $scriptDir\ for downloading and processing."
	$processDir = $scriptDir
}

Write-Host `n

# Hosts extensions selection
If ($Gambling -eq $False -AND $Porn -eq $False -AND $Social -eq $False)
	{
	# Unified hosts = (Adware + Malware)
	Write-Host "Selected Unified hosts (Adware + Malware)."
	$hostsUrl = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
	$newHosts = "hosts.unified"
}

# Unified hosts + Gambling
If ($Gambling -eq $True -AND $Porn -eq $False -AND $Social -eq $False)
	{
	Write-Host "Selected Unified hosts (Adware + Malware) + Gambling."
	$hostsUrl = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling/hosts"
	$newHosts = "hosts.gambling"
}

# Unified hosts + Porn
If ($Gambling -eq $False -AND $Porn -eq $True -AND $Social -eq $False)
	{
	Write-Host "Selected Unified hosts (Adware + Malware) + Porn"
	$hostsUrl = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"
	$newHosts = "hosts.porn"
}

# Unified hosts + Social
If ($Gambling -eq $False -AND $Porn -eq $False -AND $Social -eq $True)
	{
	Write-Host "Selected Unified hosts (Adware + Malware) + Social"
	$hostsUrl = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social/hosts"
	$newHosts = "hosts.social"
}

# Unified hosts + gambling + porn
If ($Gambling -eq $True -AND $Porn -eq $True -AND $Social -eq $False)
	{
	Write-Host "Selected Unified hosts (Adware + Malware) + Gambling + Porn."
	$hostsUrl = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts"
	$newHosts = "hosts.gambling-porn"
}

# Unified hosts + gambling + social
If ($Gambling -eq $True -AND $Porn -eq $False -AND $Social -eq $True)
	{
	Write-Host "Selected Unified hosts (Adware + Malware) + Gambling + Social."
	$hostsUrl = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-social/hosts"
	$newHosts = "hosts.gambling-social"
}

# Unified hosts + porn + social
If ($Gambling -eq $False -AND $Porn -eq $True -AND $Social -eq $True)
	{
	Write-Host "Selected Unified hosts (Adware + Malware) + Porn + Social."
	$hostsUrl = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-social/hosts"
	$newHosts = "hosts.porn-social"
}

# Unified hosts + gambling + porn + social
If ($Gambling -eq $True -AND $Porn -eq $True -AND $Social -eq $True)
	{
	Write-Host "Selected Unified hosts (Adware + Malware) + Gambling + Porn + Social."
	$hostsUrl = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-social/hosts"
	$newHosts = "hosts.gambling-porn-social"
}

# Download hosts file
Write-Host "Downloading $newHosts to $processDir\."
Invoke-WebRequest -Uri $hostsUrl -OutFile "$processDir\$newHosts"
If (!(Test-Path "$processDir\$newHosts"))
	{
	Write-Host "Failed to download $newHosts." -ForeGroundColor Red
	Exit
} 

Write-Host `n

# Replace IP addresses
(Get-Content "$processDir\$newHosts") | `
ForEach-Object { $_ -replace "127.0.0.1", "$IP" } | `
ForEach-Object { $_ -replace "0.0.0.0", "$IP" } | `
ForEach-Object { $_ -replace "$IP local", "127.0.0.1 local" } | Set-Content "$processDir\$newHosts"

# Add myhosts file contents if file exists
If (Test-Path "$processDir\$myHosts")
	{
	Write-Host "File `"$processDir\$myHosts`" exists."
	Write-Host "Adding custom domains found in input-file `"$myHosts`"."
	If ($ReportDomains) {
		Write-Host "Custom domains:"
		Get-Content "$processDir\$myHosts" | Where-Object {$_ -notmatch "^#"}
	}
	Add-Content -Path "$processDir\$newHosts" -Value ""
	Add-Content -Path "$processDir\$newHosts" -Value "# Domains added by updateHostsFile.ps1 using input-file $myHosts."	
	Add-Content -Path "$processDir\$newHosts" -Value (Get-Content "$processDir\$myHosts" | Where-Object {$_ -notmatch "^#"} )	
}
Else
	{
	Write-Host "File `"$processDir\$myHosts`" not found."
	Write-Host "No custom domains added."
}

Write-Host `n

# Add blacklist file contents if file exists
If (Test-Path "$processDir\$blackList")
	{
	Write-Host "File `"$processDir\$blackList`" exists."
	Write-Host "Adding black-listed domains found in input-file `"$blackList`"."
	Add-Content -Path "$processDir\$newHosts" -Value ""
	Add-Content -Path "$processDir\$newHosts" -Value "# Domains added by updateHostsFile.ps1 using input-file $blackList."
	If ($ReportDomains) {
		Write-Host "Black-listed domains:"
		Get-Content "$processDir\$blackList" | Where-Object {$_ -notmatch "^#"}
	}	
	#Add-Content -Path "$processDir\$newHosts" -Value (Get-Content "$processDir\$blackList" | Where-Object {$_ -notmatch "^#"} )
	(Get-Content "$processDir\$blackList" | Where-Object {$_ -notmatch "^#"}) | `
	ForEach-Object { Add-Content -Path "$processDir\$newHosts" -Value "$IP $_" }
	}
Else
	{
	Write-Host "File `"$processDir\$blackList`" not found."
	Write-Host "No additional domains black-listed."
}

Write-Host `n
	
# Whitelist domains
If (Test-Path "$processDir\$whiteList")
	{
	Write-Host "File `"$processDir\$whiteList`" exists."
	Write-Host "White-listing domains found in input-file `"$whiteList`" (this may take a while)."
	If ($ReportDomains) {
			Write-Host "White-listed domains:"		
	}
	ForEach ($domain in (Get-Content "$processDir\$whiteList"| Where-Object {$_ -notmatch "^#"}))
		{
		$domain = $domain.Trim()
		If ($ReportDomains) {
			Write-Host "$domain"
		}
		ForEach ($hostname in (Get-Content "$processDir\$newHosts" | Where-Object {$_ -notmatch "^#"}) | Select-String -Pattern "$domain")
		{
			(Get-Content "$processDir\$newHosts") | ForEach-Object { $_ -replace "$hostname" , "# $hostname" } | Set-Content "$processDir\$newHosts"
		}
	}
}
Else
	{
	Write-Host "File `"$processDir\$whiteList`" not found."
	Write-Host "No domains white-listed."
}

Write-Host `n

# Verify hosts file exists
If (Test-Path "$hostsDir\hosts") 
	{
	# Create backup copy of the current hosts file
	If ( ($Backup) -or ($Backup -eq 0) )
		{
		Write-Host "Creating backup copy of hosts to hosts.backup.$timeStamp."
		Copy-Item "$hostsDir\hosts" "$hostsDir\hosts.backup.$timeStamp"

		# Cleanup hosts file backups		
		If ($Backup -gt 0) {
			Write-Host "Cleanup backup hosts files. Latest $Backup backup files are preserved."
			Get-ChildItem $hostsDir hosts.backup* | Sort-Object CreationTime -Descending | Select -Skip $Backup | Remove-Item -Force
		}
	Write-Host `n
	}
}
Else
	{
	Write-Host "Hosts file $hostsDir\hosts does not exist. A backup copy will not be created!" -ForeGroundColor Red
	Write-Host `n
}

# Compare new hosts file to current active hosts file
Write-Host "Comparing new hosts file to current active hosts file (this may take a while)."
If (Compare-Object $(Get-Content $hostsDir\hosts) $(Get-Content $processDir\$newHosts)) 

	{
	Write-Host "Updates found."
	Write-Host `n
	
	# Replace hosts file with newly created hosts file
	If ($Replace)
		{
		If (Test-Path "$processDir\$newHosts")
			{
			# Replace hosts file
			If (Test-Path "$hostsDir\hosts")
				{
				Write-Host "Replace current active hosts file by $newHosts."
			}
			Else
				{
				Write-Host "Copy $newHosts to hosts."
			}
			Write-Host "Copy $processDir\$newHosts to $hostsDir\hosts"
			Copy-Item -Force "$processDir\$newHosts" "$hostsDir\hosts"
			
			Write-Host `n
			
			# Clear DNS Cache
			Write-Host "Flushing the DNS cache to utilize new hosts file."
			Clear-DnsClientCache
			Write-Host "DNS Cache has been flushed."
		}
		Else
			{ 
			Write-Host "Hosts file $processDir\$newHosts does not exist!"
		}
	}
	Else 
		{
		Write-Host "New hosts file with updates $processDir\$newHosts has been created."
		Write-Host `n
		Write-Host "The current active hosts file was not replaced and activated!" -Foregroundcolor Red
		Write-Host "To replace and activate new hosts file add `"-Replace`" option."
	}
	
	
}
Else
	{
	Write-Host "No updates found."
}

Write-Host `n

$endTime = Get-Date
$runTime=(New-TimeSpan -Start $startTime -End $endTime).ToString()

Write-Output "This script was executed in $(($endTime).Subtract($startTime).Minutes) minutes and $(($endTime).Subtract($startTime).Seconds) seconds."
Write-Host `n





















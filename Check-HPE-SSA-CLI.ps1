#Powershell Marvell RAID VD-Check for N-able RMM
#Author: Andreas Walker a.walker@glaronia.ch
#Licence: GNU General Public License v3.0
#Version: 1.0.4 / 12.08.2021

Param (
[int]$vdid
)

$cli = "C:\Program Files (x86)\Marvell\storage\interface\mvsetup.exe"

#Check if MarvellCLI is installed.
if (!(Test-Path $cli))
    {
    Write-Host 'ERROR - Missing MarvellCLI! Please Download from https://support.hpe.com/hpsc/swd/public/detail?swItemId=MTX_17d87af242a144cbb3a954352c&swEnvO'
    exit 1001
    }

#Get output from MarvellCLI and remove unwanted lines.
$vars = & "$cli" "info -o vd".split() | select -skip 3 | select -SkipLast 2

#Dirty solution to filter VD-ID. May requires ajustment if output of MarvellCLI has different length.
$StartLine = $vdid * 13
$Result = $vars | select -skip $StartLine | select -First 12

#Filter Get status of VD.
$Status = $Result | Where-Object {$_ -match "status:" } | Where-Object {$_ -notmatch "BGA status:" }
$Status = $Status -replace "^status:\s{1,}",""

#Generating messages for SolarWinds RMM
#Comment out $Result for less verbose output.
if ($Status -ne 'functional')
    {
    Write-Host 'ERROR - Virtual Disk' $vdid 'has status' $Status
    $Result
    exit 1001
    }
    else 
        {
        Write-Host 'OK - Virtual Disk' $vdid 'has status'$Status
        $Result
        exit 0
        }

#Catch unexpected end of script
Write-Host 'ERROR - Script came to an unexpected end!'
exit 1001

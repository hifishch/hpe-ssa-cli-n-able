#Powershell HPE SSA CLI for N-able RMM
#Author: Andreas Walker andreas.walker@walkerit.ch
#Licence: GNU General Public License v3.0
#Version: 1.0.1 / 12.08.2021

#Define paremeter
Param (
[int]$slot = 1,
[int]$ld = 1,
[bool]$ssd = $false
)

$el = 0
$clipath = 'C:\Program Files\Smart Storage Administrator\ssacli\bin\'

#Check if HPE SSA CLI is installed.
if (!(Test-Path "$clipath/ssacli.exe"))
    {
    Write-Host 'ERROR - Missing HPE SSA CLI! Please Download from https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_1d00dad72f544c5db131a7a5e4&swEnvOid=2000151'
    exit 1001
    }

#Go to CLI Path
cd $clipath
$Ctrl = (.\ssacli.exe ctrl slot=$slot show) | Select -skip 1
$CtrlName = $Ctrl | Select -first 1
$CtrlStatus = $Ctrl | Where-Object {$_ -match "Controller Status:" } 
$CtrlStatus = $CtrlStatus -replace "   Controller Status: ",""

if ($CtrlStatus -ne 'OK')
    {
    Write-Host "ERROR - Controller $CtrlName returned status code $CtrlStatus"
    $el = +1
    }
    else
        {
        Write-Host "OK - Controller $CtrlName returned status code $CtrlStatus"
        }

$ldstatusraw = (.\ssacli.exe ctrl slot=$slot ld $ld show status) | Select -Skip 1 | Select -First 1
$ldstatusraw = $ldstatusraw.Split(":")
$ldstatus = $ldstatusraw | Select -Last 1 | % {$_.replace(" ","")}
$ldname = $ldstatusraw | Select -First 1 | % {$_.replace("   ","")}

if ($ldstatus -ne 'OK')
    {
    Write-Host "ERROR - $ldname returned status code $ldstatus"
    $el = +1
    }
    else
        {
        Write-Host "OK - $ldname returned status code $ldstatus"
        }

if ($ssd)
    {
    $ssdstatus = $Ctrl = (.\ssacli.exe ctrl slot=$slot show ssdinfo) | Select -skip 2
    [int]$errorssd = $ssdstatus | Where-Object {$_ -match "Total Solid State Drives with Wearout Status:"} | % {$_.replace("   ","")} | % {$_.Split(":")} | Select -last 1
    [int]$totalssd = $ssdstatus | Where-Object {$_ -match "Total Solid State Drives:"} | % {$_.replace("   ","")} | % {$_.Split(":")} | Select -last 1
    $ssdlist = $ssdstatus | Where-Object {$_ -match "physicaldrive"}
    if ($totalssd -eq 0)
        {
        Write-Host "WARNING - No SSD found"
        }
        else
        {
        if ($errorssd -ne 0)
            {
            Write-Host "ERROR - $errorssd of $totalssd SSDs reported wearout status!"
            $ssdlist
            $el = +1 
            }
            else
            {
            Write-Host "OK - All $totalssd SSDs reported status OK!"
            $ssdlist
            }
        }

    }

#Generate Exit-Codes

if ($el -ne 0)
    {
    exit 1001
    }
    else
        {
        exit 0
        }

#Catch unexpected end of script
Write-Host 'ERROR - Script came to an unexpected end!'
exit 1001

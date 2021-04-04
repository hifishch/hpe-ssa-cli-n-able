# HPE SSA CLI LD- and SSD- Status for SolarWinds N-able™ RMM
Requires installed HPE SSA CLI: https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_1d00dad72f544c5db131a7a5e4&swEnvOid=2000151

Supports Monitoring of HPE Smart Array Controllers without iLO. (Eg. some HPE MicroServers)

## Usage
### Parameters
* -slot (default 1) defines the slot of the Smart Array Controller
* -ld (default 1) defines the LD (Logical Drive) witch should be tested.
* -ssd (default $false) if set to $true the SSD-Status wil be tested to.

### Best Practices:
* Create a script-task for every ld you need to test.
* Set the maximum execution time arround 2 Minutes (120 seconds)
* Set the Parameter -ssd $true on Flash-RAIDs

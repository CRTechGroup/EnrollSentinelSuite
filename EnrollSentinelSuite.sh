#!/bin/bash
## Enroll Sentinel Suite
## Written by Mike Muir for CRTG
## 11/25/15

## This script will download and install the various clients for Sentinel Monitoring (Watchman Monitoring),
## Sentinel Maintenance (Gruntwork) and Bomgar.

#Check for script being run as root:
if [[ $USER != "root" ]]; then 
		echo "This script must be run as root!" 
		exit 1
	fi 

#Pre-work: Ask the name of the group to be installed to.
echo Specify the Sentinel Group to be assigned to:
read sentinelGroupID

###Install CR Administrator account
# Part 1: Download cradmin installer from AWS instance to /tmp.
/usr/bin/curl http://web.crtg.io/base/crtg_items/create_cradmin_kala-1.1.pkg > /tmp/create_cradmin_kala-1.1.pkg
# Part 2: Install then remove package
/usr/sbin/installer -target / -pkg /tmp/create_cradmin_kala-1.1.pkg
/bin/rm /tmp/create_cradmin_kala-1.1.pkg

##Install Watchman Monitoring and assign to ClientGroup
#Part 3: Install Watchman Monitoring
/usr/bin/defaults write /Library/MonitoringClient/ClientSettings ClientGroup -string $sentinelGroupID && \
/usr/bin/curl -L1 https://crtechgroup.monitoringclient.com/downloads/MonitoringClient.pkg > /tmp/MonitoringClient.pkg && \
/usr/sbin/installer -target / -pkg /tmp/MonitoringClient.pkg && \
/bin/rm /tmp/MonitoringClient.pkg

#wait 5 seconds
sleep 5s

##Install Gruntwork
# Part 1: Download GW installer from AWS instance to /tmp.
/usr/bin/curl http://web.crtg.io/base/gruntwork/CRTG_Sentinel_Maintenance.pkg > /tmp/CRTG_Sentinel_Maintenance.pkg
# Part 2: Install then remove package
/usr/sbin/installer -target / -pkg /tmp/CRTG_Sentinel_Maintenance.pkg
/bin/rm /tmp/CRTG_Sentinel_Maintenance.pkg
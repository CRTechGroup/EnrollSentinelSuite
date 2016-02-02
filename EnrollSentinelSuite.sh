#!/bin/bash
## Enroll Sentinel Suite
## Written by Mike Muir for CRTG
## 11/25/15

## This script will download and install the various clients for Sentinel Monitoring (Watchman Monitoring),
## Sentinel Maintenance (Gruntwork) and Bomgar.

#########################
#DEFINE SCRIPT VARIABLES HERE:
sentinelGroupID="defineGroupIDHere"
bomgarURL="defineBomgarURLHere" 
#Example: "http://web.crtg.io/base/bomgarinstallers/TestDeploy/bomgar-scc-w0idc30efz6iiwfhfeii1gj8y8g1fzw11i685zhc40jc90.dmg.zip"

#########################


#Check for script being run as root:
if [[ $USER != "root" ]]; then 
		echo "This script must be run as root!" 
		exit 1
	fi 

###Install CR Administrator account
# Part 1: Download cradmin installer from AWS instance to /tmp.
/usr/bin/curl http://web.crtg.io/base/crtg_items/create_cradmin_kala-1.1.pkg > /tmp/create_cradmin_kala-1.1.pkg
# Part 2: Install then remove package
/usr/sbin/installer -target / -pkg /tmp/create_cradmin_kala-1.1.pkg
/bin/rm /tmp/create_cradmin_kala-1.1.pkg

###Enable ARD and SSH for CRADMIN user
#Enable ARD for Specific Users
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -specifiedUsers
#Enable ARD Agent for CRADMIN
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users cradmin -privs -all -restart -agent -menu
#Enable SSH
systemsetup -setremotelogin on
#Create SSH Group
dseditgroup -o create -q com.apple.access_ssh
#Add CRADMIN to SSH Group
dseditgroup -o edit -a cradmin -t user com.apple.access_ssh

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
/usr/bin/curl http://deploy.crtg.io/gruntwork/CRTG_Sentinel_Maintenance.pkg > /tmp/CRTG_Sentinel_Maintenance.pkg
# Part 2: Install then remove package
/usr/sbin/installer -target / -pkg /tmp/CRTG_Sentinel_Maintenance.pkg
/bin/rm /tmp/CRTG_Sentinel_Maintenance.pkg

##Deploy Bomgar

##Initially used by generating a bomgar jump client, uploading the compressed installer
##to AWS.
#First download compressed Jump Client from CRTG AWS Instance:
/usr/bin/curl $bomgarURL > /tmp/bomgar.zip
#Next, uncompress downloaded jump client:
unzip -d /tmp /tmp/bomgar.zip
rm -rf /tmp/__MACOSX
rm /tmp/bomgar.zip

#Next, mount the downloaded and uncompressed .dmg:
hdiutil attach -mountpoint /Volumes/foobar /tmp/bomgar-scc-*
 
 #...and run the bomgar installer
'/Volumes/foobar/Double-Click To Start Support Session.app/Contents/MacOS/sdcust'

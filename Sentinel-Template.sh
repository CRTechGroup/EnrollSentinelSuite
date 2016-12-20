#!/bin/bash
## Enroll Sentinel Suite- Customer Template
## Written by Mike Muir for CRTG
## 12/20/16

## This script will download and install the various clients for Sentinel Monitoring,
## Sentinel Maintenance, SafetyNet and Bomgar.

## This is a blank script, and will not correctly function without editing the SCRIPT VARIABLES, as well as adding/removing the various pieces dependent on customer requirements.
## IMPORTANT: Pay particular attention to Enabling ARD/SSH.  Line 46 needs to be edited for the cradmin and customer admin shortname.

#########################
#DEFINE SCRIPT VARIABLES HERE:
sentinelGroupID="ACE"
bomgarURL="http://deploy.crtg.io/bomgarinstallers/ACE/bomgar-scc-w0idc30xfz5d68hwj68hd5h5wfh51w167gfh1f6c40jc90.dmg.zip" 
#Example: "http://deploy.crtg.io/base/bomgarinstallers/TestDeploy/bomgar-scc-w0idc30efz6iiwfhfeii1gj8y8g1fzw11i685zhc40jc90.dmg.zip"
safetynetURL="https://safetynet.crtechgroup.net:4285/client/installers/Code42CrashPlan_5.3.1_1452927600531_7_Mac.dmg"
#Example: "https://safetynet.crtechgroup.net:4285/client/installers/Code42CrashPlan_5.3.1_1452927600531_7_Mac.dmg"
customeradminURL="https://EnterS3URLHere"
#Example: "http://deploy.crtg.io/customerdata/TestDeploy/xadminv1.pkg"

#########################


###Install CR Administrator account
echo "Creating CR Administrator account..."
# Part 1: Download cradmin installer from AWS instance to /tmp.
/usr/bin/curl http://deploy.crtg.io/crtg_items/create_cradmin_kala-1.1.pkg > /tmp/create_cradmin_kala-1.1.pkg
# Part 2: Install then remove package
/usr/sbin/installer -target / -pkg /tmp/create_cradmin_kala-1.1.pkg
/bin/rm /tmp/create_cradmin_kala-1.1.pkg

###Install Customer Administrator account
echo "Creating Customer Administrator account..."
# Part 1: Download customer installer from AWS instance to /tmp.
/usr/bin/curl $customeradminURL > /tmp/customeradmin.pkg
# Part 2: Install then remove package
/usr/sbin/installer -target / -pkg /tmp/customeradmin.pkg
/bin/rm /tmp/customeradmin.pkg

###Enable ARD and SSH for admins
echo "Adjusting Apple Remote Management settings..."
#Enable ARD for Specific Users
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -specifiedUsers
#Enable ARD Agent for CRADMIN
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users cradmin,customeradmin -privs -all -restart -agent -menu
#Enable SSH
systemsetup -setremotelogin on
#Create SSH Group
dseditgroup -o create -q com.apple.access_ssh
#Add CRADMIN to SSH Group
dseditgroup -o edit -a cradmin -t user com.apple.access_ssh

##Install Watchman Monitoring and assign to ClientGroup
echo "Installing Sentinel Monitoring..."
#Part 3: Install Watchman Monitoring
/usr/bin/defaults write /Library/MonitoringClient/ClientSettings ClientGroup -string "$sentinelGroupID" && \
/usr/bin/curl -L1 https://crtechgroup.monitoringclient.com/downloads/MonitoringClient.pkg > /tmp/MonitoringClient.pkg && \
/usr/sbin/installer -target / -pkg /tmp/MonitoringClient.pkg && \
/bin/rm /tmp/MonitoringClient.pkg



#wait 5 seconds
sleep 5s



##Install Gruntwork
echo "Installing Sentinel Maintenance..."
# Part 1: Download GW installer from AWS instance to /tmp.
/usr/bin/curl http://deploy.crtg.io/gruntwork/CRTG_Sentinel_Maintenance.pkg > /tmp/CRTG_Sentinel_Maintenance.pkg
# Part 2: Install then remove package
/usr/sbin/installer -target / -pkg /tmp/CRTG_Sentinel_Maintenance.pkg
/bin/rm /tmp/CRTG_Sentinel_Maintenance.pkg




##Deploy SafetyNet
echo "Installing SafetyNet backup software..."
##Requires hands on w/ CrashPlan login after the fact.
/usr/bin/curl $safetynetURL > /tmp/Code42CrashPlan_Mac.dmg
###Part 2: Mount, install, and unmount installer.
hdiutil attach /tmp/Code42CrashPlan_Mac.dmg
/usr/sbin/installer -target / -pkg /Volumes/Code42CrashPlan/Install\ Code42\ CrashPlan.pkg
hdiutil detach /Volumes/Code42CrashPlan

###Part 3: Remove custom installer.
/bin/rm /tmp/Code42CrashPlan_Mac.dmg





##Deploy Bomgar
echo "Deploying Bomgar remote access software..."
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


echo "Installation completed.  Please open /Applications/CrashPlan/ to authenticate and start the initial backup."

#!/bin/bash


#
# Copyright (c) 2026 DigiCert Inc. All rights reserved.
#
# THIS SOFTWARE CONTAINS CONFIDENTIAL INFORMATION AND TRADE SECRETS OF
# DIGICERT INC.  USE, DISCLOSURE OR REPRODUCTION IS PROHIBITED
# WITHOUT THE PRIOR EXPRESS WRITTEN PERMISSION OF DIGICERT
# INC.
#
# The Licensed Software and Documentation are deemed to be commercial
# computer software as defined in FAR 12.212 and subject to restricted
# rights as defined in FAR Section 52.227-19 "Commercial Computer
# Software - Restricted Rights" and DFARS 227.7202, "Rights in
# Commercial Computer Software or Commercial Computer Software
# Documentation", as applicable, and any successor regulations.  Any
# use, modification, reproduction release, performance, display or
# disclosure of the Licensed Software and Documentation by the
# U.S. Government shall be solely in accordance with the terms of this
# Agreement.
#

os=$(hostnamectl | grep -i "operating system")

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



echo "tlm_agent CLI. Copyright 2026, DigiCert Inc "
echo "Uninstalling the TLM agent service "
self="${0#./}"
base="${self%/*}"
current=$(pwd)

echo ""


if [ "$base" = "$self" ] ; then
# invoked from install dir as "./start.sh"
INSTALL_DIR=`cd "$current" ; echo $(pwd) ;`
elif [[ $base == \/* ]] ; then
# invoked with absolute path as "/a/b/c/../c/start.sh"
INSTALL_DIR=`cd "$base" ; echo $(pwd) ;`
else  
#invoke from another dir but relative path as from logs dir "../start.sh"
INSTALL_DIR=`cd $current/$base ; echo $(pwd) ;`
fi ;

export AGENT_DIRECTORY=$INSTALL_DIR
#exceute the pgm from install so that relative path access works fine. eg. activemq data dir access
cd "$AGENT_DIRECTORY"


UP=$(pgrep adm_agent | wc -l);
if [ "$UP" -ne 0 ];
then
    "$AGENT_DIRECTORY/bin/adm_agent"  --service stop
	sleep 2
fi
installed=$(service digicert-adm-agent status | wc -l);
if [ "$installed" -ne 0 ];
then
    "$AGENT_DIRECTORY/bin/adm_agent" --service uninstall
	. ./scripts/selinux-patch_uninstall.sh
    sleep 2    
else
	echo "Service is not present"
fi

issystemd=$(ps --no-headers -o comm 1)
if [ "$issystemd" = 'systemd' ]; then
	if test -f "/etc/sudoers.d/digicertagentpermission" ; then
	   echo "removing /etc/sudoers.d/digicertagentpermission ...."
	   rm -rf /etc/sudoers.d/digicertagentpermission
	   systemctl daemon-reload
	fi
	if test -f "/etc/systemd/system/digicert-adm-agent.service.d/digicertagentservice.conf" ; then       
	   echo "removing /etc/systemd/system/digicert-adm-agent.service.d ...."
	   rm -rf /etc/systemd/system/digicert-adm-agent.service.d
	   systemctl daemon-reload
	fi
	
	# Clean up recovery service if present
	echo "Cleaning up recovery service if it exists..."
	RECOVERY_SERVICE_NAME="digicert-adm-agent-recovery"
	systemctl stop "$RECOVERY_SERVICE_NAME" 2>/dev/null || true
	systemctl disable "$RECOVERY_SERVICE_NAME" 2>/dev/null || true
	rm -f "/etc/systemd/system/$RECOVERY_SERVICE_NAME.service"
	systemctl daemon-reload
fi

shopt -s extglob
rm -rf !("data"|"log")
shopt -u extglob

echo "Uninstalling agent completed"
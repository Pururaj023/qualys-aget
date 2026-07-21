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

if hash sestatus 2>/dev/null; then
	echo $(date +'%r') ": applying SELINUX policies for agent which takes around 1 minute..."
	semodule -i scripts/selinux/adm-agent-init.pp -i scripts/selinux/adm-agent-httpd.pp -i scripts/selinux/adm-agent-httpdv2.pp -i scripts/selinux/adm-agent-loadpolicy.pp -i scripts/selinux/adm-agent-restorecon.pp -i scripts/selinux/adm-agent-exe.pp -i scripts/selinux/adm-agent-ldconfig.pp 
	
		
	VERSIONID=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
	echo "RHEL version $VERSIONID"
	# Compare the version with 9.1
	if [[ $(echo "$VERSIONID <= 9.1" | bc) -eq 1 ]]; then
    	echo "RHEL version is less than or equal to 9.1"
     
	else
    	echo "RHEL version is greater than 9.1"
		semodule -i scripts/selinux/adm-agent-lsmd.pp
		semodule -i scripts/selinux/adm-agent-nmdispatcher.pp
	fi



	# check selinux status: 0 = enabled, 1 = disabled
	selinuxenabled
	if [ $? -ne 0 ]
	then
		sestat=1
	else
		sestat=0
	fi

	# check if centos version is < 8
	centos=$(cat /etc/centos-release 2> /dev/null | head -c 22 |  tail -c 1)
	[ -z "$centos" ] && centos=0

	if [ $sestat -eq 1 ] && [ $centos -lt 8 ]
	then
	   :
	else
	   setsebool -P use_virtualbox 1 2> /dev/null
	   setsebool -P nis_enabled=on  domain_can_mmap_files=on
	fi
	
	restorecon -R -v -i $INSTALLDIR
	echo $(date +'%r') ": Applied SELinux policies successfully"
fi




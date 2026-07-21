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
	echo $(date +'%r') ":Uninstalling SELinux policies of agent which will take around 1 minute...."
	semodule -r adm-agent-init -r adm-agent-httpd -r adm-agent-httpdv2 -r adm-agent-loadpolicy -r adm-agent-restorecon -r adm-agent-exe -r adm-agent-ldconfig -r adm-agent-lsmd -r adm-agent-nmdispatcher
		
	VERSIONID=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
	echo "RHEL version "$VERSIONID

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
	   setsebool -P use_virtualbox 0 2> /dev/null
	   setsebool -P nis_enabled=off  domain_can_mmap_files=off
	fi	
	
	echo $(date +'%r') ":Uninstalling SELinux policies of agent completed"
	
	
fi



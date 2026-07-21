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

otpusage()
{
cat << EOF

To activate the agent, enter the details in the following format: ./start-tlm-agent.sh --otp otpvalue --proxy proxyvalue

For example: ./start-tlm-agent.sh --otp SGGEYNIUOI --proxy http://192.168.80.1:3128

Required: --otp
Optional: --proxy

EOF
exit
}

os=$(hostnamectl | grep -i "operating system")

if [ "$EUID" -ne 0 ]
  then echo "Please run as root."
  exit
fi

user=$(id -un)
usergroup=$(getent group $(id -un) | cut -d':' -f1)
echo 
echo "tlm_agent CLI. Copyright 2026, DigiCert Inc "
echo 
echo "Starting the TLM agent ... "
echo

INSTALL_ARG=" "
provisionbyotp=0
invalidinput=0
if [ "$#" -ne 0 ]; then
	provisionbyotp=1
	while [ "$1" != "" ]; do
		case $1 in
			--otp )
				shift
				optval=$1
			;;
			--proxy )
				shift
				proxyval=$1     
			;;
			* ) 
		esac
		shift
	done

	if [ -z "$optval" ]; then 
		invalidinput=1
	else
		INSTALL_ARG=$INSTALL_ARG" --otp=$optval"
	fi
	
	if [ -n "$proxyval" ]; then
		INSTALL_ARG=$INSTALL_ARG" --proxy=$proxyval"
	fi
	
	if [ "$invalidinput" -eq 1 ]; then
		otpusage
	fi;	
fi

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


activated=false

CERTFILE=$AGENT_DIRECTORY/certs/client_auth.pem
if test -f "$CERTFILE"; then
    activated=true
fi
installed=$(service digicert-adm-agent status | wc -l);
if [ $activated = false ] && [ "$installed" -ne 0 ] ; then
	echo "Another agent service already exist";
    echo "If you are provisioning a new agent, Uninstall the existing agent and try again"
	exit
fi

running=$(pgrep adm_agent | wc -l);
if [ $activated = true ]
then
	if [ "$installed" -eq 0 ];
	then
    	"$AGENT_DIRECTORY/bin/adm_agent" --service install
    fi
    if [ "$running" -ne 1 ];
	then
		"$AGENT_DIRECTORY/bin/adm_agent"  --service start
		sleep 2
		UP=$(pgrep adm_agent | wc -l);	
		if [ "$UP" -eq 1 ];	
		then	
			echo "Service control: start complete."	
		else	
			echo "Service control: start failed."	
		fi
    else
    	service digicert-adm-agent status
    	echo 
    	echo "Service is already running";
    	exit
	fi
else
	if [ "$running" -ne 0 ];
	then
		service digicert-adm-agent status
		echo 
    	echo "Service is already running";
    	echo "If you are provisioning a new agent, stop the above service and try again"
    	exit 
    fi

	echo "Agent is not activated"
	echo ""

	if [ $provisionbyotp -eq 1 ]; then
		echo "OTP based provision"
		"$AGENT_DIRECTORY/bin/adm_agent" $INSTALL_ARG
		
		chown "$user":"$usergroup" "$AGENT_DIRECTORY" -R
		chmod -R 700 "$AGENT_DIRECTORY"
		if test -f "$CERTFILE"; then
			if [ "$installed" -eq 0 ];
			then				
				"$AGENT_DIRECTORY/bin/adm_agent" --service install
				. ./scripts/selinux-patch_install.sh				
			fi
			sleep 2
			"$AGENT_DIRECTORY/bin/adm_agent" --service start
			sleep 2	
			UP=$(pgrep adm_agent | wc -l);	
			if [ "$UP" -eq 1 ];	
			then	
				echo "Service control: start complete"
				echo "Agent installation & launch completed"
			else	
				echo "Service control: start failed"	
				echo "Agent installation completed, but fail to launch"
			fi
		else
			echo "Agent activation failed"
		fi
		exit
	fi;

	array=()
	IFS=$'\n'


	divisionId=()
	divisionName=()
	count=3
	i=0
	echo "Enter the 6-digit activation code to authenticate your identity and activate the agent" 
	# while loop
	while [ $i -lt $count ]; do
    	let i++

		read -p 'Activation code: ' optval
		while [ -z "$optval" ]; do
			read -p 'Activation code: ' optval
		done		
		echo ""
		
		. ./scripts/proxy-details.sh
			
			
			case "$proxyValues" in 
			"2" )
				if [ -z "$proxyUsername" ]
				then
					proxy="http://$proxyIp:$proxyPort"
				else
					proxy="http://$proxyUsername:$proxyPassword@$proxyIp:$proxyPort"
				fi
				;;
			"1" )				
				proxy="$sensorIp:$sensorPort"
				;;
			"0" )				
				;;
			
			esac

		
		echo ""
		
			
		read -p 'Agent alias: ' alias
			echo ""
			
			if [ -z "$alias" ]
			then
				if [ -z "$proxy" ]
				then
					"$AGENT_DIRECTORY/bin/adm_agent" --otp "$optval"
				else
					"$AGENT_DIRECTORY/bin/adm_agent" --otp "$optval" --proxy "$proxy"
				fi
			else
				if [ -z "$proxy" ]
				then
					"$AGENT_DIRECTORY/bin/adm_agent" --otp "$optval" --alias "$alias"
				else
					"$AGENT_DIRECTORY/bin/adm_agent" --otp "$optval" --alias "$alias" --proxy "$proxy"
				fi
			fi
		
		chown "$user":"$usergroup" "$AGENT_DIRECTORY" -R
		chmod -R 700 "$AGENT_DIRECTORY"
		if test -f "$CERTFILE"; then
			if [ "$installed" -eq 0 ];
			then				
				"$AGENT_DIRECTORY/bin/adm_agent" --service install
				. ./scripts/selinux-patch_install.sh				
			fi
			sleep 2
			"$AGENT_DIRECTORY/bin/adm_agent" --service start
			sleep 2	
			UP=$(pgrep adm_agent | wc -l);	
			if [ "$UP" -eq 1 ];	
			then	
				echo "Service control: start complete"
				echo "Agent installation & launch completed"
			else	
				echo "Service control: start failed"	
				echo "Agent installation completed, but fail to launch"
			fi
		else
			echo "Agent activation failed"
		fi		
		exit
	done
fi	

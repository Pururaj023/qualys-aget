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

echo "How does the certificate host connect to the cloud?"
echo "0: Direct, no proxy"
echo "1: DigiCert sensor as proxy"
echo "2: My own proxy server"
echo ""
read -p 'Select communication method: _' proxyValues
	while : [ -z "$proxyValues" ] && [ "$proxyValues" != "1" ] && [ "$proxyValues" != "2" ] && [ "$proxyValues" != "0" ]; do
				echo "How does the certificate host connect to the cloud?"
				echo "0: Direct, no proxy"
				echo "1: DigiCert sensor as proxy"
				echo "2: My own proxy server"
				echo ""
				read -p 'Select communication method: _' proxyValues
	done
	
if [ "$proxyValues" == "2" ];
	then
			read -p 'username for proxy: ' proxyUsername
			
			read -sp 'password for proxy: ' proxyPassword
			
			echo ""						
			read -p 'Proxy Ip or hostname: ' proxyIp
			 while [ -z "$proxyIp" ] ||  (! [[ $proxyIp =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] && ! [[ $proxyIp =~ ^(([a-zA-Z](-?[a-zA-Z0-9])*)\.)+[a-zA-Z]{2,}$ ]]); do
				echo "invalid ip or hostname"
				read -p 'Proxy Ip: ' proxyIp
			done
			
			read -p 'Proxy Port: ' proxyPort
			while [ -z "$proxyPort" ] ||  ! [[ $proxyPort =~ ^[0-9]+$ ]]; do
                                echo "port should be a number"
				read -p 'Proxy Port: ' proxyPort
			done
fi
			
if [ "$proxyValues" == "1" ];
	then
		read -p 'Sensor Ip: ' sensorIp
			 while [ -z "$sensorIp" ] ||  (! [[ $sensorIp =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] && ! [[ $sensorIp =~ ^(([a-zA-Z](-?[a-zA-Z0-9])*)\.)+[a-zA-Z]{2,}$ ]]); do
				echo "Invalid ip"
				read -p 'Sensor Ip: ' sensorIp
			done
			
			read -p 'Sensor Port: ' sensorPort
			while [ -z "$sensorPort" ] ||  ! [[ $sensorPort =~ ^[0-9]+$ ]]; do
				echo "port should be a number"
				read -p 'Sensor Port: ' sensorPort
			done
fi
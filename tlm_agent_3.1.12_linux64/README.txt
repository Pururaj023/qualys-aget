Copyright (c) 2026 DigiCert Inc. All rights reserved. DigiCert, the DigiCert Logo, DigiCert TLM Agent are trademarks or registered trademarks of DigiCert Inc or its affiliates in the U.S. and other countries. Other names may be trademarks of their respective owners.

The Licensed Software and Documentation are deemed to be commercial computer software as defined in FAR 12.212 and subject to restricted rights as defined in FAR Section 52.227-19 "Commercial Computer Software - Restricted Rights" and DFARS 227.7202, et seq. "Commercial Computer Software and Commercial Computer Software Documentation", as applicable, and any successor regulations.  Any use, modification, reproduction release, performance, display or disclosure of the Licensed Software and Documentation by the U.S. Government shall be solely in accordance with the terms of this Agreement.

Before you begin
==================
	• You must have admin, root, or sudo user privileges on the certificate host.
	• You must have DC One authentication OTP and the Admin or Manager role.
	• The division you want to assign the agent to must already be registered in your Trust Lifecycle Manager account.
	• Certificate host must be able to communicate with the DC One cloud directly or through a proxy server. A DigiCert Sensor can act as a proxy.


Install and activate the DigiCert Trust Lifecycle Manager Agent
===================

	• Microsoft Windows—Unpack and run the DigiCert Trust Lifecycle Manager Agent executable on the certificate host.
	• Linux—Unpack the files and run start-tlm-agent.sh on the certificate host.

For details on installing and activating an agent, refer to the Automation user guide:
https://docs.digicert.com/en/digicert-one/trust-lifecycle-manager/certificate-lifecycle-automation/deploy-and-manage-agents/install-and-activate-agents.html


Troubleshooting
==================
Find agent activity and error logs in:

<install_dir>/log/agent.log


Automate certificate lifecycle activities
==================
After you install and activate the agent, go to Trust Lifecycle Manager to:

Configure the agent with the host's IP addresses and applications
https://docs.digicert.com/en/digicert-one/trust-lifecycle-manager/certificate-lifecycle-automation/deploy-and-manage-agents/configure-agents.html

Schedule an automation event
https://docs.digicert.com/en/digicert-one/trust-lifecycle-manager/certificate-lifecycle-automation/schedule-certificate-lifecycle-automation-events.html


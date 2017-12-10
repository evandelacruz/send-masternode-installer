# send-masternode-installer

This installer will take all of the confusion out of setting up a SocialSend masternode.
Just run the installer using one of the three methods described below, and the installer will gather all of the information it needs from you before handling the download, configuration, and installation of the SocialSend wallet setup as a masternode.

## Disclaimers
If you copy this software please keep the original author information in the headers

THIS IS BETA SOFTWARE
WARNING: Use at your own risk!
ABSOLUTELY NO WARRANTY of any kind, expressed or implied. 
Software can delete your data or damage your computer!
BE CAREFUL

## Has been tested on the following systems:
- Fresh install of Ubuntu 14.04

## Install a SocialSend masternode 

### Install a SocialSend masternode on your Linux box using a single command:
    bash -c "$(wget -O - https://goo.gl/BrjeQk)"

### Or, if you don't want to use the goo.gl shortened url, you can use the full url:
    bash -c "$(wget -O - https://raw.githubusercontent.com/nodedaddy/send-masternode-installer/master/install-send-masternode)"

### Or, if you prefer to download the installer manually, use these steps:
    wget https://raw.githubusercontent.com/nodedaddy/send-masternode-installer/master/install-send-masternode
    chmod +x install-send-masternode
    ./install-send-masternode

After the installer is completed, the SocialSend masternode will be installed a service named send.instance (where "instance" is a name you provide)

## Control the masternode with these commands
    sudo service send.instance start
    sudo service send.instance stop
    sudo service send.instance restart
    sudo service send.instance status
    sudo service send.instance walletinfo
    sudo service send.instance chaininfo
    sudo service send.instance networkinfo

## Installer output example
When you run the installer, you will see something like this:

	Running the installer...


	SocialSend 1.0.0.5 Master Node Installer 0.0.1
	This will install the SocialSend wallet and configure it to run as a masternode.

	Be sure this is the setup you want before you continue:
	- Masternode running on this Linux computer (Needs to be online to keep the masternode active)
	- Send wallet running on a seperate Windows computer (Does not need to stay online after activating the masternode. This is where your rewards will be sent.)

	Press any key if you are sure this is the setup you want...
	(You can exit this installer at any time by pressing ctrl+c)

	What is the name of this masternode (no spaces or special characters) [default: mn1]?
	<Your answer here>

	Masternode name will be "mn1"

	Before you continue, you need to do a few things on your Windows wallet.
	Follow these steps:
	1) Open the SocialSend wallet on your Windows computer

	2) In the wallet interface, go to "Tools > Debug console"

	3) In the debug console, run the following command and remember the wallet id it shows you:
	   getnewaddress "mn1"

	4) In the debug console, run the following command and remember the transaction id and numeric index it shows you:
	   sendfrom "ACCOUNT_YOU_HAVE_UNLOCKED_COINS_AVAILABLE" "ADDRESS_YOU_GOT_ON_PREVIOUS_LINE"

	5) In the debug console, run the following command and remember the private key it shows you:
	   createmasternodekey

	6) Close the debug console

	Once you have completed those steps, you can press any key to continue...

	What is the masternode private key from step 5 above?
	xxx

	ALERT: The next two questions are for advanced users only.
	If you are not sure, press [enter] to accept the default value.

	What port do you want to use for the rpc server (note: this is NOT the same as the masternode port) [default: 50051]?

	RPC server will listen on port 50051

	Looking for network interfaces...
	lo:
	eth0:

	Which network interface do you want to use [default: eth0]?

	Will use interface eth0
	Found local ip address: 192.168.1.123
	Getting public ip address...
	Using local ip address: 192.168.1.123
	Using public ip address: xxx

	ALERT: The network interface is behind a router and/or you are using network address translation
	This is not an error.
	But it will require an extra step to setup your masternode using this interface.
	On your router, you will need to forward all traffic from external (xxx) port 50050 to internal (192.168.1.123) port 50050.
	This is done differently on every router, but usually involves going to http://192.168.1.1 in your web browser and editing the section called "port forwarding" (sometimes found under "advanced" or "gaming").

	Press any key to continue


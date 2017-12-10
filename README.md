# send-masternode-installer
If you copy this software please keep the original author information in the headers

THIS IS BETA SOFTWARE
WARNING: Use at your own risk!
I make no guarantees, implied or explicit, about the quality or safety of this software!
Software can delete your data or damage your computer!
BE CAREFUL

Has been tested on the following systems:
- Fresh install of Ubuntu 14.04


Install a SocialSend masternode on your Linux box using a single command:
- bash -c "$(wget -O - https://goo.gl/BrjeQk)"

Or, if you don't want to use the goo.gl shortened url, you can use the full url:
- bash -c "$(wget -O - https://raw.githubusercontent.com/nodedaddy/send-masternode-installer/master/install-send-masternode)"

Or, if you prefer to download the installer manually, use these steps:
- wget https://raw.githubusercontent.com/nodedaddy/send-masternode-installer/master/install-send-masternode
- chmod +x install-send-masternode
- ./install-send-masternode

After the installer is completed, the SocialSend masternode will be installed a service named send.instance (where "instance" is a name you provide)

You can control the masternode with these commands
- sudo service send.instance start
- sudo service send.instance stop
- sudo service send.instance restart
- sudo service send.instance status
- sudo service send.instance walletinfo
- sudo service send.instance chaininfo
- sudo service send.instance networkinfo

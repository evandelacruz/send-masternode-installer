#! /bin/sh
### BEGIN INIT INFO
# Provides:          send.nodenameplaceholder
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: SEND masternode service
# Description:       SocialSend masternode service
#
### END INIT INFO

# Author: Evan de la Cruz
# Author: adaylateandadollarshort
# for nodedaddy

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="SEND masternode (instance: nodenameplaceholder) service"
NODENAME=nodenameplaceholder
NAME=send.$NODENAME
DAEMON=/usr/sbin/sendd
CLIENT=/usr/sbin/send-cli
DAEMON_ARGS="-datadir=/etc/send/$NODENAME"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
CONFFOLDER=/etc/send/$NODENAME
SENDCONF=$CONFFOLDER/send.conf
WALLETFILE=$CONFFOLDER/wallet.dat

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{	
	#check if this is the first time running, which means the wallet will be fresh and unencrypted
	echo "wallet is $WALLETFILE"
	if [ -f $WALLETFILE ]; then
		firstrun=0
	else
		firstrun=1
	fi	
	
	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started
	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
			|| return 1
	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- \
			$DAEMON_ARGS \
			|| return 2
			
	# Add code here, if necessary, that waits for the process to be ready
	# to handle requests from services started subsequently which depend
	# on this one.  As a last resort, sleep for some time.	
	echo -n "waiting a while to verify the wallet and load the index before continuing..."		
	getbalancetest=$($CLIENT -conf="$SENDCONF" getbalance 2>&1)
	waitstatus1="connect to server"
	waitstatus2="Verifying"
	waitstatus3="Loading"
	waitstatus4="Verifying"
	waitstatus5="Loading"
	while test "${getbalancetest#*$waitstatus1}" != "$getbalancetest"
	do
		echo -n "."
		sleep 1
		getbalancetest=$($CLIENT -conf="$SENDCONF" getbalance 2>&1)
	done
	while test "${getbalancetest#*$waitstatus2}" != "$getbalancetest"
	do
		echo -n "-"
		sleep 1
		getbalancetest=$($CLIENT -conf="$SENDCONF" getbalance 2>&1)
	done
	while test "${getbalancetest#*$waitstatus3}" != "$getbalancetest"
	do
		echo -n "+"
		sleep 1
		getbalancetest=$($CLIENT -conf="$SENDCONF" getbalance 2>&1)
	done
	while test "${getbalancetest#*$waitstatus4}" != "$getbalancetest"
	do
		echo -n "o"
		sleep 1
		getbalancetest=$($CLIENT -conf="$SENDCONF" getbalance 2>&1)
	done
	while test "${getbalancetest#*$waitstatus5}" != "$getbalancetest"
	do
		echo -n "o"
		sleep 1
		getbalancetest=$($CLIENT -conf="$SENDCONF" getbalance 2>&1)
	done
	sleep 1
	echo "done"
	echo
	
	if [ $firstrun = 1 ]; then
		$CLIENT -conf="$SENDCONF" backupwallet "$CONFFOLDER/newwallet-noencryption.dat.bak"
		sleep 1
		goodstatus="encrypted"
		echo "Please enter a new passphrase for the masternode wallet..."
		read encryptpassphrase
		encryptresult=$($CLIENT -conf="$SENDCONF" encryptwallet "$encryptpassphrase")
		if test "${encryptresult#*$goodstatus}" != "$encryptresult"; then
		    echo " "
			echo "Wallet has been encrypted. Restarting daemon...";
			sleep 10
			deadstatus="response"
			isdeadtest=$($CLIENT -conf="$SENDCONF" getbalance 2>&1)
			while test "${isdeadtest#*$deadstatus}" != "$isdeadtest"
			do
				echo -n "."
				sleep 1
				isdeadtest=$($CLIENT -conf="$SENDCONF" getbalance 2>&1)
			done
			do_start			
		else
			echo "There was an error encrypting the wallet";
		fi
    else
		#wallet needs tobe unlocked for masternode
		echo " "
		echo "Please enter your wallet passphrase to start the masternode..."
		read encryptpassphrase
		
		$CLIENT -conf="$SENDCONF" walletpassphrase "$encryptpassphrase" 999999999
		
		echo "adding default nodes..."
		$CLIENT -conf="$SENDCONF" addnode 69.64.67.58:50050 add 2>&1
		$CLIENT -conf="$SENDCONF" addnode 142.44.246.3:50050 add 2>&1
		$CLIENT -conf="$SENDCONF" addnode 45.76.116.122:50050 add 2>&1
		$CLIENT -conf="$SENDCONF" addnode 69.64.67.226:50050 add 2>&1	
	fi
}

#
# Function that stops the daemon/service
#
do_stop()
{
        # Return
        #   0 if daemon has been stopped
        #   1 if daemon was already stopped
        #   2 if daemon could not be stopped
        #   other if a failure occurred
        start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --exec $DAEMON
        RETVAL="$?"
        [ "$RETVAL" = 2 ] && return 2
        # Wait for children to finish too if this is a daemon that forks
        # and if the daemon is only ever run from this initscript.
        # If the above conditions are not satisfied then add some other code
        # that waits for the process to drop all resources that could be
        # needed by services started subsequently.  A last resort is to
        # sleep for some time.
        start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
        [ "$?" = 2 ] && return 2
        # Many daemons don't delete their pidfiles when they exit.
        rm -f $PIDFILE
        return "$RETVAL"
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
        #
        # If the daemon can reload its configuration without
        # restarting (for example, when it is sent a SIGHUP),
        # then implement that here.
        #
        start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --exec $DAEMON
        return 0
}

#
# Function to check the wallet
#
do_checkwallet() {
	$CLIENT -conf="$SENDCONF" getwalletinfo
}

#
# Function to check the wallet
#
do_showaddresses() {
	$CLIENT -conf="$SENDCONF" listaddressgroupings
}

#
# Function to check the masternode
#
do_checkmasternode() {
	$CLIENT -conf="$SENDCONF" getinfo
	$CLIENT -conf="$SENDCONF" getwalletinfo
}

do_checknetwork() {
	$CLIENT -conf="$SENDCONF" getnetworkinfo
	$CLIENT -conf="$SENDCONF" getpeerinfo
	$CLIENT -conf="$SENDCONF" getnettotals
}

do_checkblockchain() {
	echo "Current synced block is "
	$CLIENT -conf="$SENDCONF" getblockcount
	$CLIENT -conf="$SENDCONF" getblockchaininfo
}

do_backupwallet() {
	$CLIENT -conf="$SENDCONF" backupwallet $2
}

do_newaddress() {
	$CLIENT -conf="$SENDCONF" getnewaddress $2
}

case "$1" in
  start)
        [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
        do_start
        case "$?" in
                0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
                2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  stop)
        [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
        do_stop
        case "$?" in
                0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
                2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  walletinfo)
		do_checkwallet
		do_showaddresses
		exit 0
		;;
  networkinfo)
		do_checknetwork
		exit 0
		;;
  chaininfo)
		do_checkblockchain
		exit 0
		;;
  addressinfo)
		do_showaddresses
		exit 0
		;;
  backupwallet)
		do_backupwallet
		exit 0
		;;
  newaddress)
		do_newaddress
		exit 0
		;;
  status)
		if status_of_proc "$DAEMON" "$NAME";
		then
		   do_checkmasternode
		   exit 0
		else
		    exit $?
		fi
        ;;
  #reload|force-reload)
        #
        # If do_reload() is not implemented then leave this commented out
        # and leave 'force-reload' as an alias for 'restart'.
        #
        #log_daemon_msg "Reloading $DESC" "$NAME"
        #do_reload
        #log_end_msg $?
        #;;
  restart|force-reload)
        #
        # If the "reload" option is implemented then remove the
        # 'force-reload' alias
        #
        log_daemon_msg "Restarting $DESC" "$NAME"
        do_stop
        case "$?" in
          0|1)
                do_start
                case "$?" in
                        0) log_end_msg 0 ;;
                        1) log_end_msg 1 ;; # Old process is still running
                        *) log_end_msg 1 ;; # Failed to start
                esac
                ;;
          *)
                # Failed to stop
                log_end_msg 1
                ;;
        esac
        ;;
  *)
		#if they didnt pass any command then output some help
        echo "Usage: send.$NAME {start|stop|status|walletinfo|networkinfo|chaininfo|addressinfo|backupwallet|newaddress|restart|force-reload} [arguments]" >&2
        echo " " >&2
        echo "Examples:" >&2
        echo " " >&2
		echo "Start the masternode:"
        echo "sudo service send.$NAME start" >&2
        echo " " >&2
		echo "Stop the masternode:"
        echo "sudo service send.$NAME stop" >&2
        echo " " >&2
		echo "Get masternode status and info:"
        echo "sudo service send.$NAME status" >&2
        echo " " >&2
		echo "Get information about the wallet:"
        echo "sudo service send.$NAME walletinfo" >&2
        echo " " >&2
		echo "List wallet ids:"
        echo "sudo service send.$NAME addressinfo" >&2
        echo " " >&2
		echo "Get information about the blockchain:"
        echo "sudo service send.$NAME chaininfo" >&2
        echo " " >&2
		echo "Get information about the network:"
        echo "sudo service send.$NAME networkinfo" >&2
        echo " " >&2
		echo "Get a new wallet address:"
        echo "sudo service send.$NAME newaddress" >&2
        echo " " >&2
		echo "Back up the wallet file:"
        echo "sudo service send.$NAME backupwallet ~/mywalletbackup.dat" >&2
        echo " " >&2
        exit 3
        ;;
esac
exit 0

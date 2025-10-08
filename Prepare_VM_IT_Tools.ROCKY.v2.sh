#!/bin/bash
set -x
#
#======================================================================
#
#  Version: 1.0 : Prepare_VM_IT_Tools.ROCKY.sh
#
#======================================================================
#
#  Purpose: Sets up host VM built via arcadian for various IT Tools/cso requirements.
#
#======================================================================
#  Signature:
#       Prepare_VM_IT_Tools.ROCKY.v2.sh
#
#======================================================================
#
#  Warning: modify the script, only if you know what you are doing!!!
#
#======================================================================
#
#  Usage:
#       run ./Prepare_VM_IT_Tools.ROCKY.sh as root via cone time cron.
#
#______________________________________________________________________
#  Return:
#       none
#______________________________________________________________________
#  Description:
#  :
#               Prepare_VM_IT_Tools.ROCKY.sh scripts does the following features.
#
#______________________________________________________________________
#  Caveats: script is as an add on to arcadian.
#  Contact arcadian sme - nanda hullahalli (sh3237)
#  Chanks to support from various operation team members for their help.
#______________________________________________________________________
#  History:
#  Author:   Srinandan(nanda) Hullahalli(sh3237)       01/09/2024
#  Author:   Asma Eid (ae866f)                         01/09/2024
#======================================================================
#
#
#  1. Setup_Wget_Proxy
#  2. Setup_Yum_Proxy
#  3. Setup_NTP_Client
#  4. Configure_postfix
#  5. Installing_ATTsudo
#  6. Installing_Radius
#  7. Installing_ATTnologin
#  8. Installing_allmid
#  9. Installing_UAM
#  10. Configuring_UAM
#  11. Installing_Eksh
#  12. Installing_ATTsjp
#  13. Installing_Clearview
#  14. Configuring_Sensage
#  15. Installing_SACT
#  16. Installing_XPW
#  17. Installing_SentinelOne
#  18. Installing_NagiosAgent
#  19. Installing_CloudPassageAgent
#  20. Installing_BPA
#  21. Installing_Flexera
#  22. Installing_RGspeedtest
#  23. Installing_Certificates
#  24. Installing_NodeExporter
#  25. Install_obudpst
#  26. Fix_eksh
#  27. Cleaning_Crontab
#
#

array="$@"

if [ $# -lt 2 ]
then
  clear
  echo -e "\n-----------------------------------
  Usage:
  $0 TENANT_NAME <index of setups separated by space>"
  echo "-----------------------------------
  Examples:
  -- To execute the selected setups pass the respective index number
  $0 ATMU|DMZ|MOBILITY|CONNECXUS 2 7 4"
  echo "
  -- To execute all the setups
  $0 ATMU|DMZ|MOBILITY|CONNECXUS all"
  echo -e "-----------------------------------
  Setups and indexes :
  1. Setup_Wget_Proxy
  2. Setup_Yum_Proxy
  3. Setup_NTP_Client
  4. Configure_postfix
  5. Installing_ATTsudo
  6. Installing_Radius
  7. Installing_ATTnologin
  8. Installing_allmid
  9. Installing_UAM
  10. Configuring_UAM
  11. Installing_Eksh
  12. Installing_ATTsjp
  13. Installing_Clearview
  14. Configuring_Sensage
  15. Installing_SACT
  16. Installing_XPW
  17. Installing_SentinelOne
  18. Installing_NagiosAgent
  19. Installing_CloudPassageAgent
  20. Installing_BPA
  21. Installing_Flexera
  22. Installing_RGspeedtest
  23. Installing_Certificates
  24. Installing_NodeExporter
  25. Install_obudpst
  26. Fix_eksh
  27. Cleaning_Crontab
  "
 exit 1
fi

#LOCAL ENVIRONMENT VARIABLES
HOSTNAME=`hostname`

TENANT=$1;    export TENANT
echo "tenant"
echo $1

if [ $TENANT == "ATMU" ]
then

        HTTP_PROXY_HOST="aic-proxy.it.att.com"
        HTTP_PROXY_PORT="3128"
        SMTP_RELAY="smtp.aic.att.net"
        NTP_SERVER1="199.37.146.88"
        NTP_SERVER2="199.37.146.89"
        NTP_SERVER3="199.37.145.130"
        COLLECTHOST1="loghost01.ipcoe.att.com"
        COLLECTHOST2="loghost02.ipcoe.att.com"
        COLLECTHOST3=iracavccfen01.infra.aic.att.net
        COLLECTHOST4=dsvtxvCsens01-eth2.infra.aic.att.net
        COLLECTHOST5=iracavccfen01.infra.aic.att.net
        QCLIENT1="dsvtxvCqdss01-eth1-0.infra.aic.att.net"
        QCLIENT2="iracavcqdss01-eth2.infra.aic.att.net"
        QCLIENT3=iracavcqdss01-eth2.infra.aic.att.net
        QCLIENT4=dsvtxvCqdss01-eth1-0.infra.aic.att.net
        QCLIENT5=iracavcqdss01-eth2.infra.aic.att.net
        SENSAGE_HOST1="loghost01.ipcoe.att.com"
        ARCADIAN_REPO_IP="32.131.248.139"

fi

if [ $TENANT == "DMZ" ]
then

        HTTP_PROXY_HOST="sub.proxy.att.com"
        HTTP_PROXY_PORT="8080"
        SMTP_RELAY="smtp.it.att.com"
        NTP_SERVER1="199.37.146.88"
        NTP_SERVER2="199.37.146.89"
        NTP_SERVER3="199.37.145.130"
        COLLECTHOST1="iracavccfen01.infra.aic.att.net"
        COLLECTHOST2="dsvtxvCsens01-eth2.infra.aic.att.net"
        QCLIENT1="dsvtxvCqdss01-eth1-0.infra.aic.att.net"
        QCLIENT2="iracavcqdss01-eth2.infra.aic.att.net"
        SENSAGE_HOST1="loghost01.ipcoe.att.com"
        ARCADIAN_REPO_IP="32.131.248.139"
fi

if [ $TENANT == "MOBILITY" ]
then

       HTTP_PROXY_HOST="aic-proxy.it.att.com"
        HTTP_PROXY_PORT="3128"
        SMTP_RELAY="smtp.aic.att.net"
        NTP_SERVER1="199.37.146.88"
        NTP_SERVER2="199.37.146.89"
        NTP_SERVER3="199.37.145.130"
        COLLECTHOST1="loghost01.ipcoe.att.com"
        COLLECTHOST2="loghost02.ipcoe.att.com"
        COLLECTHOST3=iracavccfen01.infra.aic.att.net
        COLLECTHOST4=dsvtxvCsens01-eth2.infra.aic.att.net
        COLLECTHOST5=iracavccfen01.infra.aic.att.net
        QCLIENT1="dsvtxvCqdss01-eth1-0.infra.aic.att.net"
        QCLIENT2="iracavcqdss01-eth2.infra.aic.att.net"
        QCLIENT3=iracavcqdss01-eth2.infra.aic.att.net
        QCLIENT4=dsvtxvCqdss01-eth1-0.infra.aic.att.net
        QCLIENT5=iracavcqdss01-eth2.infra.aic.att.net
        SENSAGE_HOST1="loghost01.ipcoe.att.com"
        ARCADIAN_REPO_IP="32.131.248.139"

fi

if [ $TENANT == "CONNEXUS" ]
then

        HTTP_PROXY_HOST="sub.proxy.att.com"
        HTTP_PROXY_PORT="8080"
        SMTP_RELAY="smtp.it.att.com"
        NTP_SERVER1="199.37.146.88"
        NTP_SERVER2="199.37.146.89"
        NTP_SERVER3="199.37.145.130"
        COLLECTHOST1="iracavccfen01.infra.aic.att.net"
        COLLECTHOST2="dsvtxvCsens01-eth2.infra.aic.att.net"
        QCLIENT1="dsvtxvCqdss01-eth1-0.infra.aic.att.net"
        QCLIENT2="iracavcqdss01-eth2.infra.aic.att.net"
        SENSAGE_HOST1="loghost01.ipcoe.att.com"
        ARCADIAN_REPO_IP="32.131.248.139"

fi

function Setup_Wget_Proxy ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started the wget update for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Setting wget proxy..."
	echo "https_proxy = http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/" >>/etc/wgetrc
	echo "http_proxy = http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/" >>/etc/wgetrc
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed the wget update for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Setup_Yum_Proxy ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started the yum proxy for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Setting yum proxy..."
	echo "proxy=http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/" >>/etc/yum.conf
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed the yum proxy for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}
function Setup_NTP_Client ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Setting up the NTP_Client for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Setting ntp client..."
	echo "pool $NTP_SERVER1 iburst" >>/etc/chrony.conf
	echo "pool $NTP_SERVER2 iburst" >>/etc/chrony.conf
	echo "pool $NTP_SERVER3 iburst" >>/etc/chrony.conf
	echo "Restarting Chrony NTP client..."
	/bin/systemctl restart chronyd
	sleep 10
	echo "Check NTP client binding..."
	chronyc sources
	echo "http_proxy = http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/" >>/etc/wgetrc
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting up the NTP_Client for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Configure_postfix ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started configuring postfix for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	#
	echo "Making needed changes to postfix mailsetup..."
	echo "remove sendmail package if installed from disto"
	http_proxy=http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT; export http_proxy
	https_proxy=http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT; export https_proxy
	yum -y remove sendmail
	echo "install postfix"
	yum -y install postfix
	/usr/sbin/postconf -ev relayhost=[$SMTP_RELAY] myhostname=$(hostname).$(/bin/dnsdomainname) inet_interfaces=all smtpd_banner='$myhostname ESMTP AT&T $mail_name ($mail_version)' mynetworks_style=host
	echo "restart postfix service"
	systemctl restart postfix
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed configuring postfix for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_ATTsudo ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing ATTsudo for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	echo "Downloading install_sudo.sh"
	cd /tmp/ &&  wget http://mirrors.it.att.com/pub/custom/SD/nasCDs/install/REDHAT/SI/install_sudo.sh
	cd /tmp/; chmod +x install_sudo.sh
	echo "install sudo"
       	./install_sudo.sh
	echo "Creating a symbolic link to nologin..."
	ln -s /usr/localcw/bin/nologin /bin/nologin

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing ATTsudo for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_Radius ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing Radius for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Downloading ATTRadius"
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasInstall/radius/pam_radius_auth-1.3.17-8.el8.x86_64.rpm 
        echo "Installing ATTRadius"
        rpm -ivh pam_radius_auth-1.3.17-8.el8.x86_64.rpm

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Radius for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	echo "Registering the System via email"

	HOST=$(hostname -f)
	IP=$(host ${HOST} | grep "has address" | head -1 | awk '{print $4}')
	ADDR1="acdtools@cldv0018.sldc.sbc.com"
	ADDR2="acdtools@tldv0021.dadc.sbc.com"
	MAILLOG="/tmp/maillog"
	IP=$(host ${HOST} | grep "has address" | head -1 | awk '{print $4}')
	echo "ADD_NAS:${HOST}:IP:${IP}" | mail -v -s "Pam Radius Automated Registration ${HOST}" ${ADDR1} ${ADDR2}
}

function Installing_ATTnologin ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing attnologin for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Downloading attnologin"
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasInstall/nologin/ATTnologin-5.0.2-3.el8.x86_64.rpm 
        echo "Installing attnologin"
        rpm -ivh ATTnologin-5.0.2-3.el8.x86_64.rpm
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing attnologin for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_allmid ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing allmid for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Downloading allmid.tar.Z"
        cd /tmp/ && wget http://mirrors.it.att.com/pub/custom/SD/nasUtil/allmid.tar.gz
        #
        echo "Extracting allmid.tar.Z..."
        cd /usr/localcw/bin && tar zxvf /tmp/allmid.tar.gz
        #
        echo "Setting up needed crontab for allmid script..."
        (crontab -l 2>/dev/null; echo "# IEDs update") | crontab -
        (crontab -l 2>/dev/null; echo "15 02 * * 2,4 /usr/localcw/bin/allmid.sh > /dev/null 2>&1") | crontab -

	/usr/localcw/bin/allmid.sh -A ss7352 -B ps1742
	
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing allmid for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_UAM ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing UAM for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	touch /etc/ftpusers
        echo "Downloading the file uam_extranet.tar.Z"
        cd /tmp/ && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/uam/uam_extranet.tar.Z
        #
        echo "Uncompress the file /tmp/uam_extranet.tar.Z..."
        cd / && uncompress /tmp/uam_extranet.tar.Z
        #
        echo "Extract the file uam_extranet.tar..."
        tar xvf /tmp/uam_extranet.tar
        #
        echo "Install the UAM by running the script /usr/localcw/uam/install_uam.sh..."
        /usr/localcw/uam/install_uam.sh -l
	echo "COLLECTHOST=$COLLECTHOST1" >> /usr/localcw/opt/security/etc/sectools.conf
	echo "COLLECTHOST=$COLLECTHOST2" >> /usr/localcw/opt/security/etc/sectools.conf
	echo "QCLIENT=$QCLIENT1" >> /usr/localcw/opt/security/etc/sectools.conf
	echo "QCLIENT=$QCLIENT2" >> /usr/localcw/opt/security/etc/sectools.conf
        #
        echo "Setting up needed crontab for uam script..."
        (crontab -l 2>/dev/null; echo "# uam") | crontab -
        (crontab -l 2>/dev/null; echo "0 13 * * * /usr/localcw/uam/uam_auto.pl > /dev/null 2>&1") | crontab -
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing UAM for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Configuring_UAM ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started configuring UAM for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        #
        echo "Creating UAM directory /etc/SBC..."
        mkdir /etc/SBC
        #
        echo "Creating the needed config variable for /etc/SBC/UAM.conf..."
        echo "_HOST:`hostname -f|tr '[:upper:]' '[:lower:]'`" > /etc/SBC/UAM.conf
        cat /etc/SBC/UAM.conf

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed configuring UAM for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_Eksh ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing Eksh for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Downloading atteksh"
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCDs/install/REDHAT/SI/eksh_setup.sh
	chmod +x eksh_setup.sh
        echo "Installing atteksh"
        ./eksh_setup.sh
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Eksh for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}


function Installing_ATTsjp ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing ATTsjp for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Downloading attsjp"
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasInstall/SJP/ATTJumpPoint-1.1.2-1.noarch.rpm 
        echo "Installing attsjp"
        rpm -ivh ATTJumpPoint-1.1.2-1.noarch.rpm
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing ATTsjp for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_Clearview ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing Installing_Clearview for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Downloading Clearview"
	cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/Clearview/ATTclvw-1.7-1.rhel9.x86_64.rpm
        echo "Installing Clearview"
	yum -y install ATTclvw-1.7-1.rhel9.x86_64.rpm
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Installing_Clearview for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Configuring_Sensage ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started configuring sensage for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        #
	cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCDs/install/REDHAT/SI/test/configure_sensage
	chmod +x configure_sensage
	./configure_sensage -v -c $SENSAGE_HOST1

	#
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed configuring sensage for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_SACT ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing SACT for Host:$HOSTNAME at: `date`"
        echo "# Referance: https://sact.it.att.com/client"
        echo "#_________________________________________________________________________"

        echo "Create a directory /usr/localcw/opt/sact..."
        #
	mkdir -p /usr/localcw/opt/sact
	echo "Change to the newly created SACT directory.."
	cd /usr/localcw/opt/sact

        echo "Downloading the file SACT current release..."
	wget https://sact.it.att.com/dist/sact-client-20231101.tar.gz
	#
        echo "Extracting the current release SACT package..."
	tar xzf sact-client-20231101.tar.gz
	#
	echo "Create a root cronjob to execute the SACT Client daily at a random time of day."
	./add2cron.ksh -l
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing SACT for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_XPW ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing xpw for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Downloading the latest version of XPW"
        cd /tmp/ && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/XPW/xpw_add_id_current.ksh  
        chmod +x xpw_add_id_current.ksh
        echo "Initiating XPW install"
        ./xpw_add_id_current.ksh
        echo "Updating /etc/pam.d/common-password file"
	/usr/bin/sed -i 's/^.*minlen.*$/minlen = 10/' /etc/security/pwquality.conf
	/usr/bin/sed -i 's/^.*dcredit.*$/dcredit = 0/' /etc/security/pwquality.conf
	/usr/bin/sed -i 's/^.*ucredit.*$/ucredit = 0/' /etc/security/pwquality.conf
	/usr/bin/sed -i 's/^.*lcredit.*$/lcredit = 0/' /etc/security/pwquality.conf
	/usr/bin/sed -i 's/^.*ocredit.*$/ocredit = 0/' /etc/security/pwquality.conf
	/usr/bin/sed -i 's/^.*minclass.*$/minclass = 2/' /etc/security/pwquality.conf
	grep " remember=4" /etc/pam.d/system-auth > /dev/null
	if [[ $? != 0 ]]
	then
	/usr/bin/perl -p -i -e 's/(^password\s*sufficient.*)/$1 remember=4/' /etc/pam.d/system-auth
	fi

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing xpw for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_SentinelOne ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing Sentinel_One for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Downloading Sentinel_One"
	cd /tmp
	wget -O Current_S1_Release http://mirrors.it.att.com/pub/custom/SD/nasCommon/S1/Current_S1_Release
	tar zxvf ./Current_S1_Release
	echo "Install Sentinel_One"
	cd ./SentinelOne*; ./S1-install.ksh -p
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Sentinel_One for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_NagiosAgent ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing NagiosAgent for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Downloading Nagios"
        mkdir /tmp/NO_NAS_NAGIOS_INSTALL && cd /tmp/NO_NAS_NAGIOS_INSTALL
        wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/nagios/linux_install.tar.Z
        echo "Extracting Nagios..."
        tar zxvf linux_install.tar.Z
        echo "Installing Nagios"
        ./NagiosAgentInstall.sh
        cd / && rm -r /tmp/NO_NAS_NAGIOS_INSTALL/
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing NagiosAgent for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}


function Installing_BPA ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing BPA for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Downloading BPA"
	cd /var/tmp && wget -O /var/tmp/tsco_install.tgz http://mirrors.it.att.com/files/TCSO/tsco_install.tgz
	echo "Extracting BPA..."
	tar zxvf tsco_install.tgz
	cd prod_ito
	echo "Installing BPA"
	./install_bpa.sh -d $PWD
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task:Completed installing BPA for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_CloudPassageAgent ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing CloudPassageAgent for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Downloading CloudPassageAgent file"
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCDs/install/REDHAT/SI/cws_install.sh  
	chmod +x cws_install.sh
	echo "Installing CloudPassageAgent file"
	./cws_install.sh
	echo "Starting Cloud Passage Agent..."
	/etc/init.d/cphalod start
	echo "Checking Cloud Passage Agent..."
	systemctl status cphalod
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing CloudPassageAgent for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_Flexera ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing Flexera for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Downloading Flexera file"
	wget -O - http://mirrors.it.att.com/pub/custom/SD/nasCommon/Flexera/install_Linux_Flexera.sh | /bin/bash
	echo "Installing Flexera file"
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Flexera for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_RGspeedtest ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing RGspeedtest for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
	
        echo "Downloading RGspeedtest file"
	cd /tmp && wget --no-proxy  http://downloads.dcu.att.net/Arcadian/multi_svc/add-ons/vmsetup/downloads/ATT_RGspeedtest-1.1-11.x86_64.rpm
	echo "Installing RGspeedtest"
	rpm -i /tmp/ATT_RGspeedtest-1.1-11.x86_64.rpm
	cd /tmp && wget --no-proxy http://downloads.dcu.att.net/Arcadian/multi_svc/add-ons/vmsetup/downloads/speedtest.cfg
	cp /tmp/speedtest.cfg /opt/ATT_RGspeedtest-1.1/speedtest/conf/att/speedtest

	echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing RGspeedtest for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function Installing_Certificates ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing Installing_Certificates for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
	
	echo "changing permission on Certs"
	# Add the user
#	/usr/sbin/useradd -rs /bin/false node_exporter

	# Make /etc/pki/CA/certs for node_exporter
#	/bin/chown node_exporter:node_exporter /etc/pki/CA/certs/

	# Set the ownership of the binary
#	/bin/chown speedtest:speedtest /usr/local/bin/node_exporter

	# set permissions of the directory to read only for node-exporter
	mkdir -p /etc/pki/CA/certs
#	/bin/chmod 700 /etc/pki/CA/certs
#	/bin/chmod 400 /etc/pki/CA/certs/*
#	/bin/chown node_exporter /etc/pki/CA/certs/*

#	chmod 744 /etc/pki/CA/certs
	#
        echo "Downloading enrollCert.tar.gz file..."
	cd /var/tmp 
	pwd
	unset https_proxy
	unset http_proxy
	wget --no-proxy http://downloads.dcu.att.net/Arcadian/multi_svc/add-ons/vmsetup/downloads/enrollCert.tar.gz
#	wget http://downloads.dcu.att.net/Arcadian/multi_svc/add-ons/vmsetup/downloads/enroll_cert.py
	/bin/gunzip enrollCert.tar.gz
	tar xvf enrollCert.tar
	echo "Extracting tar ball..."
#	/usr/bin/gunzip -c enrollCert.tar.gz|/bin/tar xvf -
	if [ -d /var/tmp/enroll_cert ]
	then
		echo "The directory /var/tmp/enroll_cert exists..."
		cd /var/tmp/enroll_cert 
		pwd
		echo "Installing Certificates..."
		/usr/bin/python3 enroll_cert.py
		sleep 30
		ls -l /etc/pki/CA/certs
	fi
	echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed Installing_Certificates for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function Installing_NodeExporter ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing Installing_NodeExporter for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
	
	#
	yum -y install httpd-tools.x86_64
        echo "Downloading node_exporter-1.7.0.linux-amd64.tar.gz file..."
	cd /var/tmp && wget --no-proxy http://downloads.dcu.att.net/Arcadian/multi_svc/add-ons/vmsetup/downloads/node_exporter-1.7.0.linux-amd64.tar.gz
        echo "Downloading dcu-installNE.sh file..."
	cd /var/tmp && wget --no-proxy http://downloads.dcu.att.net/Arcadian/multi_svc/add-ons/vmsetup/downloads/dcu-installNE.sh
	chmod 755 /var/tmp/dcu-installNE.sh
#	chown node_exporter:root /etc/pki/CA/certs/*
	echo "Installing node_exporter-1.7.0..."
	/var/tmp/dcu-installNE.sh

	echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed Installing_NodeExporter for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function Install_obudpst ()
{	
	echo "#_______________________________________________________________________"
	echo "#"
	echo "# Task: Started installing obudpst for Host:$HOSTNAME at: `date`"
	echo "#"
	echo "#______________________________________________________________"

        cd /tmp && wget --no-proxy http://downloads.dcu.att.net/Arcadian/multi_svc/add-ons/vmsetup/downloads/obudpst-8.0.0-1.noarch.rpm
        echo "Installing obudpst"
        rpm -ivh obudpst-8.0.0-1.noarch.rpm
	sleep 5
	rpm -q obudpst
	echo "#______________________________________________________________"
	echo "#"
	echo "# Task: Completed installing obudpst for Host:$HOSTNAME at: `date`"
	echo "#"
	echo "#_______________________________________________________________"
}

function Fix_eksh ()
{	
	echo "#_______________________________________________________________________"
	echo "#"
	echo "# Task: Started function Fix_eksh for Host:$HOSTNAME at: `date`"
	echo "#"
	echo "#______________________________________________________________"

        echo "Change shell on m16499"
	chsh -s /usr/localcw/bin/eksh m16499

        echo "Change shell on m95031"
	chsh -s /usr/localcw/bin/eksh m95031

	echo "#______________________________________________________________"
	echo "#"
	echo "# Task: Completed function Fix_eksh for Host:$HOSTNAME at: `date`"
	echo "#"
	echo "#_______________________________________________________________"
}
function Cleaning_Crontab ()
{	
	echo "#_______________________________________________________________________"
	echo "#"
	echo "# Task: Started cleaning up crontab for Host:$HOSTNAME at: `date`"
	echo "#"
	echo "#______________________________________________________________"

	/bin/sed -i  '/^@reboot/d' /var/spool/cron/root

	echo "#______________________________________________________________"
	echo "#"
	echo "# Task: Completed cleaning up crontab for Host:$HOSTNAME at: `date`"
	echo "#"
	echo "#_______________________________________________________________"
}


if [[ " ${array[*]} " =~ [[:space:]]1[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Setup_Wget_Proxy"
Setup_Wget_Proxy

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Setup_Wget_Proxy function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]2[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Setup_Yum_Proxy"
Setup_Yum_Proxy

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Setup_Yum_Proxy function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]3[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Setup_NTP_Client"
Setup_NTP_Client

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Setup_NTP_Client function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]4[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Configure_postfix"
Configure_postfix

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Configure_postfix function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]5[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_ATTsudo"
Installing_ATTsudo

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_ATTsudo function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]6[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_Radius"
Installing_Radius

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_Radius function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]7[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_Radius"
Installing_ATTnologin

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_ATTnologin function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]8[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_allmid"
Installing_allmid

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_allmid function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]9[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_UAM"
Installing_UAM

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_UAM function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]10[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Configuring_UAM"
Configuring_UAM

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Configuring_UAM function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]11[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_Eksh"
Installing_Eksh

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_Eksh function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]12[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_ATTsjp"
#Installing_ATTsjp

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_ATTsjp function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]13[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_Clearview"
#Installing_Clearview

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_Clearview function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]14[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Configuring_Sensage"
Configuring_Sensage

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Configuring_Sensage function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]15[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_SACT"
Installing_SACT

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_SACT function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]16[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_XPW"
Installing_XPW

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_XPW function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]17[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function "
Installing_SentinelOne

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_SentinelOne function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]18[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function NagiosAgent"
Installing_NagiosAgent

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing NagiosAgent function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]19[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function CloudPassageAgent"
#Installing_CloudPassageAgent

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as CloudPassageAgent function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]20[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function BPA"
Installing_BPA 

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as CloudPassageAgent function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]21[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Flexera"
Installing_Flexera

status=$( echo $? )
if [[ $status != 0 ]] ; then    
        echo "Aborting script as Installing_Flexera function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]22[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function RGspeedtest"
Installing_RGspeedtest

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as RGspeedtest function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]23[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_Certificates"
Installing_Certificates

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_Certificates function failed"
	exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]24[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_NodeExporter"
Installing_NodeExporter

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_NodeExporter function failed"
	exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]25[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Install_obudpst"
Install_obudpst

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installation of obudpst function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]26[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function fix_eksh"
Fix_eksh

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installation of obudpst function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]27[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Cleaning_Crontab"
echo "Executing function Cleaning_Crontab"
Cleaning_Crontab

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Cleaning crontab function failed"
        exit 0
fi
fi
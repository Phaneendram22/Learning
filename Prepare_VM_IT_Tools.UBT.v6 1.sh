#!/bin/bash
#set -x
#
#======================================================================
#
#  Version: 6.0 : Prepare_VM_IT_Tools.ATMU_UBT.sh
#
#======================================================================
#
#  Purpose: Sets up host VM built via arcadian for various IT Tools/cso requirements.
#
#======================================================================
#  Signature:
#       Prepare_VM_IT_Tools.ATMU_UB.v1.sh
#
#======================================================================
#
#  Warning: modify the script, only if you know what you are doing!!!
#
#======================================================================
#
#  Usage:
#       run ./Prepare_VM_IT_Tools.ATMU_UBT.sh as root via cone time cron.
#
#______________________________________________________________________
#  Return:
#       none
#______________________________________________________________________
#  Description:
#  :
#               Prepare_VM_IT_Tools.ATMU_UBT.sh scripts does the following features.
#
#______________________________________________________________________
#  Caveats: script is as an add on to arcadian.
#  Contact Arcadian SME - Nanda Hullahalli (sh3237)
#  Thanks to support from various operation team members for their help.
#______________________________________________________________________
#  History:
#  Author:   Srinandan(nanda) Hullahalli(sh3237)       01/09/2024
#  Author:   Asma Eid (ae866f)                         01/09/2024
#======================================================================
#v6  08/08/2024
# 
# 
# 1.  Setup_apt_conf
# 2.  Setup_Wget_Proxy
# 3.  Setup_NTP_Client
# 4.  Configure_postfix
# 5.  Installing_ATTsudo
# 6.  Installing_Radius
# 7.  Installing_ATTnologin
# 8.  Installing_ATTlogins
# 9.  Installing_allmid
# 10. Installing_UAM
# 11. Configuring_UAM
# 12. Installing_Brkglass
# 13. Installing_Eksh
# 14. Installing_ATTsjp
# 15. Installing_Clearview
# 16. Configuring_Sensage
# 17. Installing_SACT
# 18. Installing_XPW
# 19. Installing_BPA
# 20. CloudPassageAgent
# 21. Add_MechIDs
# 22. Cleaning_Crontab

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
   1.  Setup_apt_conf
   2.  Setup_Wget_Proxy
   3.  Setup_NTP_Client
   4.  Configure_postfix
   5.  Installing_ATTsudo
   6.  Installing_Radius
   7.  Installing_ATTnologin
   8.  Installing_ATTlogins
   9.  Installing_allmid
   10. Installing_UAM
   11. Configuring_UAM
   12. Installing_Brkglass
   13. Installing_Eksh
   14. Installing_ATTsjp
   15. Installing_Clearview
   16. Configuring_Sensage
   17. Installing_SACT
   18. Installing_XPW
   19. Installing_BPA
   20. CloudPassageAgent
   21. Add_MechIDs
   22. Cleaning_Crontab
"
  exit 1
fi



#LOCAL ENVIRONMENT VARIABLES
HOSTNAME=`hostname`

TENANT=$1;    export TENANT

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
function Setup_apt_conf ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started the configure apt.conf for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Setting apt.conf"
        echo "Acquire::http::Proxy \"http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT\";" > /etc/apt/apt.conf
        echo "Update for release change..."
        apt-get --allow-releaseinfo-change update
        apt-get --allow-releaseinfo-change update
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed the configure apt.conf for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

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

function Setup_NTP_Client ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Setting up the NTP_Client for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Setting ntp client..."
         /bin/cat > /etc/chrony/chrony.conf << EOF
server $NTP_SERVER1
server $NTP_SERVER2
server $NTP_SERVER3

driftfile /var/lib/chrony/drift
# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync
EOF
        echo "Restarting Chrony NTP client..."
        /bin/systemctl restart chronyd
        sleep 10
        echo "Check NTP client binding..."
        chronyc sources
        chronyc tracking

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
        echo "postfix   postfix/main_mailer_type        select  Internet Site" | debconf-set-selections
        echo "postfix   postfix/mailname        string  $(hostname).$(/bin/dnsdomainname)" | debconf-set-selections
        apt-get -y install bsd-mailx postfix mailutils
        postconf -ev relayhost=[$SMTP_RELAY] myhostname=$(hostname).$(/bin/dnsdomainname) inet_interfaces=all smtpd_banner='$myhostname ESMTP AT&T $mail_name ($mail_version)' mynetworks_style=host smtpd_use_tls=no
        service postfix restart
        grep relayhost /etc/postfix/main.cf

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

#       cd /tmp/; wget  http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/install_sudo.sh
        echo "Downloading install_sudo.sh..."
        cd /tmp/ &&  --no-proxy wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/install_sudo.sh
        echo "Installing sudo..."
        cd /tmp/; chmod +x install_sudo.sh; ./install_sudo.sh
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

        echo "Downloading ATTRadius..."
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attradius_4.0_amd64.deb
        echo "Installing ATTRadius..."
        dpkg -i attradius_4.0_amd64.deb

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
        echo "# Task: Started installing ATTnologin for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Downloading ATTnologin..."
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attnologin_5.0.2.0_amd64.deb
        echo "Installing ATTnologin..."
        dpkg -i attnologin_5.0.2.0_amd64.deb
        ln -s /usr/localcw/bin/nologin /bin/nologin
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing ATTnologin for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_ATTlogins ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing ATTlogins for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Downloading ATTlogins..."
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attlogins_2.0.1.0_amd64.deb
        echo "Installing ATTlogins..."
        dpkg -i attlogins_2.0.1.0_amd64.deb
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing ATTlogins for Host:$HOSTNAME at: `date`"
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

        echo "Downloading allmid.tar.Z..."
        cd /tmp/ && wget http://mirrors.it.att.com/pub/custom/SD/nasUtil/allmid.tar.gz
        #
        echo "Extracting allmid.tar.Z..."
        cd /usr/localcw/bin && tar zxvf /tmp/allmid.tar.gz
        #
        echo "Setting up needed crontab for allmid script..."
        (crontab -l 2>/dev/null; echo "# IEDs update") | crontab -
        (crontab -l 2>/dev/null; echo "15 02 * * 2,4 /usr/localcw/bin/allmid.sh > /dev/null 2>&1") | crontab -

#        /usr/localcw/bin/allmid.sh -A ss7352 -B ps1742

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

        echo "Downloading the file uam..."
        cd /tmp/ && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/uam/uam_extranet.tar.Z
        #
        echo "Uncompress the file uam_extranet.tar.Z..."
        cd /tmp && uncompress /tmp/uam_extranet.tar.Z
        #
        echo "Extract the file uam_extranet.tar..."
        tar xvf /tmp/uam_extranet.tar
        #
        echo "Install the UAM by running the script /usr/localcw/uam/install_uam.sh..."
        echo "Create an empty file /etc/ftpusers..."
        touch /etc/ftpusers
        /usr/localcw/uam/install_uam.sh -l
        echo "COLLECTHOST=$COLLECTHOST1" >> /usr/localcw/opt/security/etc/sectools.conf
        echo "COLLECTHOST=$COLLECTHOST2" >> /usr/localcw/opt/security/etc/sectools.conf
        echo "QCLIENT=$QCLIENT1" >> /usr/localcw/opt/security/etc/sectools.conf
        echo "QCLIENT=$QCLIENT2" >> /usr/localcw/opt/security/etc/sectools.conf

        #
        echo "Setting up needed crontab for uam script..."
        (crontab -l 2>/dev/null; echo "# uam") | crontab -
        (crontab -l 2>/dev/null; echo "0 13 * * * /usr/localcw/uam/uam_auto.pl > /dev/null 2>&1") | crontab -

        #
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
        echo "Downloading atteksh..."
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/atteksh_2.0_amd64.deb
	echo " Installing Eksh..."
        chmod +x eksh_setup.sh; dpkg -i atteksh_2.0_amd64.deb
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Eksh for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_Brkglass ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing Brkglass for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Downloading attbrkgls..."
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attbrkgls_1.0_all.deb
        echo "Installing attbrkgls..."
        dpkg -i attbrkgls_1.0_all.deb
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Brkglass for Host:$HOSTNAME at: `date`"
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
        echo "Downloading attsjp..."
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attsjp_1.0-1_amd64.deb
        echo "Installing attsjp..."
        dpkg -i attsjp_1.0-1_amd64.deb
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
        echo "# Task: Started installing Clearview for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        echo "Downloading Clearview..."
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attclvw_1.0_amd64.deb
        echo "Installing attclvw..."
        dpkg -i attclvw_1.0_amd64.deb
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Clearview for Host:$HOSTNAME at: `date`"
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
        echo "Creating an empty file for sensage..."
        touch /etc/rsyslog.d/40-sensage.conf
        #
        echo "Updating /etc/rsyslog.d/40-sensage.conf file..."
        echo "auth.info,authpriv.*  /var/log/secure" >> /etc/rsyslog.d/40-sensage.conf
        echo "auth.info,authpriv.*  @$SENSAGE_HOST1" >> /etc/rsyslog.d/40-sensage.conf
#        wget --no-proxy -O /etc/logrotate.d/rsyslog http://$ARCADIAN_REPO_IP/Arcadian/common/rsyslog

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
        echo "#"
        echo "#_________________________________________________________________________"

        echo "Downloading the file SACT current release..."
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCommon/security/Current_Release
        #
        echo "Creating a directory /usr/localcw/opt/sact..."
        mkdir -p /usr/localcw/opt/sact
        cd /usr/localcw/opt/sact
        #
        echo "Extracting the current release SACT package..."
        tar xvf /tmp/Current_Release
        /usr/localcw/opt/sact/add2cron.ksh -l

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

        echo "Downloading the latest version of XPW..."
        cd /tmp/ && wget -r -nd --no-parent -A 'xpw_add_id_v*.ksh' http://mirrors.it.att.com/pub/custom/SD/nasCommon/XPW/
        chmod +x xpw_add_id_*.ksh
        echo "Installing XPW..."
        ./xpw_add_id_*.ksh
        echo "Updating /etc/pam.d/common-password file..."
        /usr/bin/perl -p -i -e 's/(^password.*requisite.*pam_cracklib.so.*)/password requisite  pam_cracklib.so retry=3 minlen=10 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
        grep " remember=4" /etc/pam.d/common-password > /dev/null
          if [[ $? != 0 ]]
          then
             /usr/bin/perl -p -i -e 's/(^password.*pam_unix.so.*)/$1 remember=4/' /etc/pam.d/common-password
          fi

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing xpw for Host:$HOSTNAME at: `date`"
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

        echo "Downloading install_bpa.sh file..."
        cd /var/tmp/ && wget http://mirrors.it.att.com/files/TCSO/tsco_install.tgz
        tar zxvf tsco_install.tgz; cd prod_ito
        chmod +x install_bpa.sh
        echo "Installing BPA..."
        ./install_bpa.sh -d $PWD
	wget -O /etc/init.d/bgssd http://mirrors.it.att.com/files/TCSO/bgssd_rc
	systemctl daemon-reload; systemctl enable bgssd; systemctl start bgssd

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing BPA for Host:$HOSTNAME at: `date`"
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

        echo "Downloading CloudPassageAgent file..."
        cd /tmp && wget http://mirrors.it.att.com/pub/custom/SD/nasCDs/install/REDHAT/SI/cws_install.sh
	ech "Installing CloudPassageAgent..."
        chmod +x cws_install.sh && ./cws_install.sh

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing CloudPassageAgent for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Add_MechIDs ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started adding mechids on Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
#        useradd -c m56541 -d /home/m56541 -g rgstmechid -m -s /usr/localcw/bin/eksh m56541
        chsh -s /usr/localcw/bin/eksh m56541
        mkdir /home/m56541
        chmod 750 /home/m56541
        mkdir /home/m56541/.ssh
        chmod 750 /home/m56541/.ssh
#        chown ss7352:rgstmechid /home/m56541
#        chown ss7352:rgstmechid /home/m56541/.ssh
        cd /home/m56541/.ssh && wget --no-proxy  http://downloads.dcu.att.net/Arcadian/multi_svc/add-ons/vmsetup/downloads/authorized_keys
        chown m56541 /home/m56541/.ssh/authorized_keys
        chmod 750 /home/m56541/.ssh/authorized_keys
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed adding mechids for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}


function Cleaning_Crontab ()
{
        echo "#_______________________________________________________________________"
        echo "#"
        echo "# Task: Started cleaning up crontab for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#______________________________________________________________"

        /bin/sed -i  '/^@reboot/d' /var/spool/cron/crontabs/root

        echo "#______________________________________________________________"
        echo "#"
        echo "# Task: Completed cleaning up crontab for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_______________________________________________________________"
}


if [[ " ${array[*]} " =~ [[:space:]]1[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Setup_apt_app.conf"
Setup_apt_conf
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Setup_Wget_Proxy function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]2[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Setup_Wget_Proxy"
Setup_Wget_Proxy
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Setup_Wget_Proxy function failed"
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
echo "Executing function Installing_ATTnologins"
Installing_ATTnologin
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_ATTnologin function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]8[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_ATTlogins"
Installing_ATTlogins
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_ATTlogins function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]9[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_allmid"
Installing_allmid
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_allmid function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]10[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_UAM"
Installing_UAM
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_UAM function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]11[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Configuring_UAM"
Configuring_UAM
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Configuring_UAM function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]12[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_Brkglass"
Installing_Brkglass
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_Brkglass function failed"
        exit 0
fi
fi

if [[ " ${array[*]} " =~ [[:space:]]13[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_Eksh"
Installing_Eksh
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_Eksh function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]14[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_ATTsjp"
Installing_ATTsjp
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_ATTsjp function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]14[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_Clearview"
Installing_Clearview
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_Clearview function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]16[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Configuring_Sensage"
Configuring_Sensage
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Configuring_Sensage function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]17[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_SACT"
Installing_SACT
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_SACT function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]18[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_XPW"
Installing_XPW
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_XPW function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]19[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Installing_BPA"
Installing_BPA
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as Installing_BPA function failed"
        exit 0
fi
fi


if [[ " ${array[*]} " =~ [[:space:]]20[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function CloudPassageAgent"
Installing_CloudPassageAgent
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as CloudPassageAgent function failed"
        exit 0
fi
fi


#if [[ " ${array[*]} " =~ [[:space:]]21[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
#echo "Executing function Add_MechIDs"
#Add_MechIDs
#
#status=$( echo $? )
#if [[ $status != 0 ]] ; then
#        echo "Aborting script as Add_MechIDs function failed"
#        exit 0
#fi
#fi

if [[ " ${array[*]} " =~ [[:space:]]22[[:space:]] ]] || [[ " ${array[*]} " =~ [[:space:]]all[[:space:]] ]] ; then
echo "Executing function Cleaing_Crontab"
Cleaning_Crontab

status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Aborting script as CloudPassageAgent function failed"
        exit 0
fi
fi


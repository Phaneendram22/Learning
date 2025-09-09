#!/bin/bash
#set -x
#
#======================================================================
#
#  Version: 3.0 : Prepare_Host_Lab_UB22_All_Tenants_v3.sh
#
#======================================================================
#
#  Purpose: Sets up host built via Arcadian for various IT/CSO requirements.
#
#======================================================================

#  SIGNATURE:
#       Prepare_Host_Lab_UB22_All_Tenants_v3.sh
#
#======================================================================
#
#  WARNING: Modify the script, only if you know what you are doing!!!
#
#======================================================================
#
#  Usage:
#       Run ./Prepare_Host_Lab_UB22_All_Tenants_v3.sh TENANT_NAME  as root.
#
#______________________________________________________________________
#  RETURN:
#       None
#______________________________________________________________________
#  DESCRIPTION:
#  :
#               Prepare_Host_Lab_UB22_All_Tenants_v3.sh scripts does the following features.
#
#               1.  Sets up necessary environment variables
#______________________________________________________________________
#  CAVEATS: Script is as an add on to Arcadian. 
#  Contact Arcadian SME - Nanda Hullahalli (sh3237)
#  Thanks to Support from various operation team members for their help.
#______________________________________________________________________
#  HISTORY:
#  Author:   Srinandan(Nanda) Hullahalli(sh3237)       01/15/2021
#  Author:   Shailaja Bethi (sb272f)       01/16/2021
#  Author:   SrinivasaRagavan K (sk437s)       01/16/2021
#  Author:   Phaneendra Mallisetti (pm7512) 6/5/2025(Last updated)
#======================================================================
#v5 includes enabling SRIOV for eno1 and eno2
#v6 Fixed the issue where the SRIOV was not getting activated after simple reboot
#Added Error handling & Gateway check
#Changed SMTP_RELAY to mailhost.att.com
#Added label GPT to the GuestOS and Guest Data functions
#Updated the script on on 6/9/2025
#This is only for Dell-740 servers
#Changed sequence of function Fix_Lab_Specific_Setup  as this is nullyfying the key in authorized_keys
#Added functionality to create a toor binary
#Modified Additional_FS_GuestData to validate number of disks(16) as well as if VD already existed
#Added a function that hardens OS applicable to all flavors
#Added a function that can change iDRAC hostname if its not set to format HOSTNAME-mgmt
#There are 3 Tenants that are part of both SRIOV and GUESTDATA. Created another Array multi_function_tenant


if [ $# -lt 1 ]
then
  echo ""
  echo "Usage: $0 TENANT_NAME "
  echo "Example: $0 URLB"
  echo ""
  exit 1
fi

TENANT=$1;    export TENANT

##########################################Defining Tenant Groups############################################

common_tenants=("ascend"  "multi_svc" "CNRO" "common" "DCU_TOOLING"  "DMZ"  "ipsecmon"  "NBNC" "rgst" "vFW" "viavi" "vigmon" "ZEN" "NASA" "nasa"  )
ovs_tenants=("vrr" "LRSI")
sriov_vf_tenants=("SANE" "sane2"  "URLB" "TROUVE" "iGEMS")
add_guest_data_tenants=(  "opanga" "central_admin" "network_tools" "CENTRAL-ADMIN" )
multi_function_tenant=("IPCP" "DOH" "VVIG")

#LOCAL ENVIRONMENT VARIABLES
HOSTNAME=`hostname`

# Lab proxy
HTTP_PROXY1_IP="one.proxy.att.com"
HTTP_PROXY1_PORT="8888"

#
ARCADIAN_REPO_INTLAB_IP="135.21.13.101"

#DNS Lab
DNS_SERVER_IP_1="135.21.13.15"
DNS_SERVER_IP_2="135.25.120.104"
DNS_SERVER_IP_3="199.37.146.85"
DNS_SERVER_IP_4="199.37.145.128"

#NTP Lab
NTP1="135.25.154.100"
NTP2="135.37.9.16"
NTP3="199.37.146.95"

#Lab
QCLIENT_IP="130.8.172.108"
COLLECTHOST="loghost01.aldc.att.com"

# Lab
SMTP_RELAY="mailhost.att.com"



# TSCO Agent

TSCO_AGENT_TAR="TSCO_Agent_ver23.1.01_latest_Linux_x86_64.tar"

sleep 60
wget --no-proxy -O /etc/systemd/resolved.conf http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/common/resolved.conf
systemctl restart systemd-resolved.service

function Setup_Environment ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started the Environment setup for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        # Setup Path properly
        PATH=$PATH:/sbin:/usr/bin:/usr/sbin:/usr/localcw/sbin:/usr/localcw/bin
        export PATH

        sleep 5
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed the Environment setup for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        sleep 5

}


function Run_Repo_Update ()

{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started the repo update for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	#change APT proxy and sources
	echo "Setting apt sources"
	echo "deb http://ubuntumirror.it.att.com/ubuntu jammy main" > /etc/apt/sources.list
	echo "deb http://ubuntumirror.it.att.com/ubuntu jammy-updates main" >> /etc/apt/sources.list
	echo "deb http://ubuntumirror.it.att.com/ubuntu/jammy ato_tools main" >> /etc/apt/sources.list
	echo "deb http://ubuntumirror.it.att.com/ubuntu jammy-security main" >> /etc/apt/sources.list
	apt-get --allow-releaseinfo-change update
	apt-get --allow-releaseinfo-change update
	apt update
	apt update

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed the repo update for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Install_Racadm ()

{

	wget --no-proxy -O /tmp/libargtable2-0_13-1_amd64.deb http://$ARCADIAN_REPO_INTLAB_IP/ubuntu/ittools/libargtable2-0_13-1_amd64.deb
	wget --no-proxy -O /tmp/srvadmin-hapi_9.4.0_amd64.deb http://$ARCADIAN_REPO_INTLAB_IP/ubuntu/ittools/srvadmin-hapi_9.4.0_amd64.deb
	wget --no-proxy -O /tmp/srvadmin-idracadm7_9.4.0_all.deb http://$ARCADIAN_REPO_INTLAB_IP/ubuntu/ittools/srvadmin-idracadm7_9.4.0_all.deb
	wget --no-proxy -O /tmp/srvadmin-idracadm8_9.4.0_amd64.deb http://$ARCADIAN_REPO_INTLAB_IP/ubuntu/ittools/srvadmin-idracadm8_9.4.0_amd64.deb
	wget --no-proxy -O /tmp/libssl-dev_1.1.1-1ubuntu2.1~18.04.5_amd64.deb http://$ARCADIAN_REPO_INTLAB_IP/ubuntu/ittools/libssl-dev_1.1.1-1ubuntu2.1~18.04.5_amd64.deb
	/usr/bin/dpkg -i  /tmp/libargtable2-0_13-1_amd64.deb
	/usr/bin/dpkg -i  /tmp/srvadmin-hapi_9.4.0_amd64.deb
	/usr/bin/dpkg -i  /tmp/srvadmin-idracadm7_9.4.0_all.deb
	/usr/bin/dpkg -i  /tmp/srvadmin-idracadm8_9.4.0_amd64.deb


}


function Setup_Wget_Proxy ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started the wget --no-proxy proxy update for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	echo "Setting proxy"
	echo "http_proxy = http://$HTTP_PROXY1_IP:$HTTP_PROXY1_PORT" > /etc/wget --no-proxyrc
	echo "use_proxy = on" >> /etc/wget --no-proxyrc

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed the wget --no-proxy proxy update for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Setup_OVS ()

{
        wget --no-proxy -O /var/tmp/setup_ovs.sh http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/vrr/add-ons/setup_ovs.sh
        wget --no-proxy -O /etc/network/if-pre-up.d/config-br http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/vrr/add-ons/config-br
        /sbin/modprobe bridge
        chmod 755 /var/tmp/setup_ovs.sh
        chmod 755 /etc/network/if-pre-up.d/config-br
        sleep 20
        /var/tmp/setup_ovs.sh
}


function Configure_Mailname ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started configuring mailname for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	echo "changing mailname to FQDN"
	echo ${HOSTNAME}.$DNS_FQDN > /etc/mailname

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed configuring mailname for Host:$HOSTNAME at: `date`"
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

	echo "postfix   postfix/main_mailer_type        select  Internet Site" | debconf-set-selections
	echo "postfix   postfix/mailname        string  $(hostname).$(/bin/dnsdomainname)" | debconf-set-selections
	postconf -ev relayhost=[$SMTP_RELAY] myhostname=`hostname -f` inet_interfaces=all smtpd_banner='$myhostname ESMTP AT&T $mail_name ($mail_version)' mynetworks_style=host smtpd_use_tls=no
	service postfix restart
	grep relayhost /etc/postfix/main.cf

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed configuring postfix for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}


function Clear_root_emails ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started clearing root emails for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        echo 'd *'|mail -N

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed clearing root emails for Host:$HOSTNAME at: `date`"
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

	cd /tmp/; wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasUtil/allmid.tar.gz
        echo "Extracting allmid.tar.Z..."
        mkdir -p /usr/localcw/bin
	cd /usr/localcw/bin; tar zxvf /tmp/allmid.tar.gz
	(crontab -l 2>/dev/null; echo "# IEDs update") | crontab -
	(crontab -l 2>/dev/null; echo "15 02 * * 2,4 /usr/localcw/bin/allmid.sh > /dev/null 2>&1") | crontab -

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing allmid for Host:$HOSTNAME at: `date`"
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

	cd /tmp/; wget --no-proxy 	http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/install_sudo.sh
	cd /tmp/; chmod +x install_sudo.sh; ./install_sudo.sh
	ln -s /usr/localcw/bin/nologin /bin/nologin

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing ATTsudo for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_AutoSRM ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing AutoSRM for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	wget --no-proxy -O /tmp/extranet-srm.tar 	http://mirrors.it.att.com/pub/custom/SD/nasCommon/AutoSRM/extranet-srm.tar
	cd /
	tar xvf /tmp/extranet-srm.tar
	/usr/localcw/AutoSRM/auto_srm.ksh
	(crontab -l 2>/dev/null; echo "## AutoSRM") | crontab -
	(crontab -l 2>/dev/null; echo "45 02 * * 3   /usr/localcw/AutoSRM/auto_srm.ksh >/dev/null 2>&1") | crontab -

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing AutoSRM for Host:$HOSTNAME at: `date`"
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

	touch /etc/rsyslog.d/40-sensage.conf
	echo "auth.info,authpriv.*  /var/log/secure" >> /etc/rsyslog.d/40-sensage.conf
	echo "auth.info,authpriv.*  @loghost01.aldc.att.com" >> /etc/rsyslog.d/40-sensage.conf
	echo "/var/log/secure" >> /etc/logrotate.d/rsyslog
	cat /etc/rsyslog.d/40-sensage.conf
	echo
	cat /etc/logrotate.d/rsyslog

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed configuring sensage for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Setting_Audit_Files ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting audit files for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	echo "/dev/udp/loghost01.infra.aic.att.net/514 0" > /etc/ksh_audit
	touch /var/log/cron.log
	chmod 660 /var/log/cron.log
	mkdir -p /usr/localcw/opt/security/etc/
	touch /usr/localcw/opt/security/etc/sectools.conf
	echo "QCLIENT=$QCLIENT_IP" >> /usr/localcw/opt/security/etc/sectools.conf
	echo "COLLECTHOST=$COLLECTHOST" >> /usr/localcw/opt/security/etc/sectools.conf
	cat /etc/ksh_audit
	echo
	cat /usr/localcw/opt/security/etc/sectools.conf

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting audit files for Host:$HOSTNAME at: `date`"
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

	mkdir /etc/SBC
	echo "_HOST:`hostname -f|tr '[:upper:]' '[:lower:]'`" > /etc/SBC/UAM.conf
	cat /etc/SBC/UAM.conf

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed configuring UAM for Host:$HOSTNAME at: `date`"
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
	
	cd /tmp/; wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/uam/uam_extranet.tar.Z
	cd / ; uncompress /tmp/uam_extranet.tar.Z
	tar xvf /tmp/uam_extranet.tar
	/usr/localcw/uam/install_uam.sh -l
	touch /etc/ftpusers
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing UAM for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}



function Creating_Users_for_SACT ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started creating users for SACT for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	echo 'm61587:x:37990:3775:Sponsor ms3232,SHELL=/bin/ksh:/home/m61587:/bin/nologin' >> /etc/passwd
	echo 'm61587:!:18114:0:99999:7:::' >> /etc/shadow
	echo "telnet : ALL : severity auth.info : ALLOW" >> /etc/hosts.allow

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed creating users for SACT for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Cron_Entry_for_SACT ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started fixing cron entry for SACT for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	crontab -l > /tmp/cron.base
	HNAME=`(hostname -f)`
	/bin/sed -i "s/_collect.ksh/_collect.ksh -f $HNAME/g" /tmp/cron.base
	crontab /tmp/cron.base
	echo "crontab check"
	crontab -l

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed fixing cron entry for SACT  for Host:$HOSTNAME at: `date`"
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

	cd /tmp/
	wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/security/Current_Release
	mkdir -p /usr/localcw/opt/sact
	cd /usr/localcw/opt/sact
	tar xvf /tmp/Current_Release
	mkdir -p /etc/bgs/PERL
	chmod 1755 /etc/bgs/PERL
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

#	wget --no-proxy -O /tmp/xpw_add_id_current.ksh -r -nd --no-parent -A 'xpw_add_id_v*.ksh' http://mirrors.it.att.com/pub/custom/SD/nasCommon/XPW/
	cd /tmp/
	wget --no-proxy -r -nd --no-parent -A 'xpw_add_id_v*.ksh' http://mirrors.it.att.com/pub/custom/SD/nasCommon/XPW/
       	chmod +x xpw_add_id_*.ksh
       	./xpw_add_id_*.ksh
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

function Configuring_NTP ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started configuring NTP for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
		
	/usr/bin/timedatectl set-ntp no
	systemctl stop ntp.service
	echo "driftfile /var/lib/ntp/ntp.drift" > /etc/ntp.conf
	echo "leapfile /usr/share/zoneinfo/leap-seconds.list" >> /etc/ntp.conf
	echo "statistics loopstats peerstats clockstats" >> /etc/ntp.conf
	echo "filegen loopstats file loopstats type day enable" >> /etc/ntp.conf
	echo "filegen peerstats file peerstats type day enable" >> /etc/ntp.conf
	echo "filegen clockstats file clockstats type day enable" >> /etc/ntp.conf
	echo "restrict -4 default kod notrap nomodify nopeer noquery limited" >> /etc/ntp.conf
	echo "restrict -6 default kod notrap nomodify nopeer noquery limited" >> /etc/ntp.conf
	echo "restrict 127.0.0.1" >> /etc/ntp.conf
	echo "restrict ::1" >> /etc/ntp.conf
	echo "restrict source notrap nomodify noquery" >> /etc/ntp.conf
	echo "server $NTP1" >> /etc/ntp.conf
	echo "server $NTP2" >> /etc/ntp.conf
	echo "server $NTP3" >> /etc/ntp.conf
	systemctl restart ntp.service
	# As requested by Adam
	/usr/bin/timedatectl set-ntp no
	sleep 30
	echo "Restarting NTP..."
	systemctl restart ntp.service

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed configuring NTP for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function File_Permissions ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting file permissions for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	chown root -R /usr/local/bin
	chown root /usr/bin/chfn
	chmod 4700 /usr/bin/chfn
	chown root /usr/bin/chsh
	chmod 4700 /usr/bin/chsh
	chmod  600 /etc/shadow
	chmod 700 /root/.profile
	chmod 0644 /etc/profile

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting file permissions for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Server_Profile ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting server profile for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	echo  "TMOUT=900;export TMOUT" >> /etc/profile
	echo  "TMOUT=900;export TMOUT" >> /etc/bash.bashrc
	echo  "TMOUT=900;export TMOUT" >/etc/profile.d/tmout.sh

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting server profile for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Setting_Password_Expiry ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting password expiry dates for few accounts on  Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	/usr/sbin/usermod -L --expiredate 1 bin
	/usr/sbin/usermod -L --expiredate 1 daemon
	/usr/sbin/usermod -L --expiredate 1 lp
	/usr/sbin/usermod -L --expiredate 1 news
	/usr/sbin/usermod -L --expiredate 1 nobody
	/usr/sbin/usermod -L --expiredate 1 sshd
	/usr/sbin/usermod -L --expiredate 1 sync
	/usr/sbin/usermod -L --expiredate 1 syslog
	/usr/sbin/usermod -L --expiredate 1 uucp
	/usr/sbin/usermod -L --expiredate 1 systemd-network
	/usr/sbin/usermod -L --expiredate 1 systemd-resolve

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting password expiry dates for few accounts on Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Setting_False_Shell ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting false shell for few accounts on  Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	/usr/sbin/usermod -s /bin/false sshd
	/usr/sbin/usermod -s /bin/false lp
	/usr/sbin/usermod -s /bin/false bin
	/usr/sbin/usermod -s /bin/false daemon
	/usr/sbin/usermod -s /bin/false news
	/usr/sbin/usermod -s /bin/false nobody
	/usr/sbin/usermod -s /bin/false sync
	/usr/sbin/usermod -s /bin/false uucp

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting false shell for few accounts on Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Restrictive_Permissions ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting up restrictive permission for SACT and login.defs on Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
		
	chmod 1755 /etc/bgs/PERL
	wget -O /etc/login.defs http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/$TENANT/add-ons/login.defs

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting up restrictive permission for SACT and login.defs on Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Setting_Securetty_File ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting up securetty file for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
		
	echo "console" > /etc/securetty
	echo "tty1" >> /etc/securetty
	echo "tty2" >> /etc/securetty
	echo "tty3" >> /etc/securetty
	echo "tty4" >> /etc/securetty
	echo "tty5" >> /etc/securetty
	echo "tty6" >> /etc/securetty
	echo "tty7" >> /etc/securetty
	echo "tty8" >> /etc/securetty
	echo "tty9" >> /etc/securetty
	echo "tty10" >> /etc/securetty
	echo "tty11" >> /etc/securetty
	echo "ttyS0" >> /etc/securetty
	echo "ttyS1" >> /etc/securetty
	echo "vc/1" >> /etc/securetty
	echo "vc/2" >> /etc/securetty
	echo "vc/3" >> /etc/securetty
	echo "vc/4" >> /etc/securetty
	echo "vc/5" >> /etc/securetty
	echo "vc/6" >> /etc/securetty
	echo "vc/7" >> /etc/securetty
	echo "vc/8" >> /etc/securetty
	echo "vc/9" >> /etc/securetty
	echo "vc/10" >> /etc/securetty
	echo "vc/11" >> /etc/securetty

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting up securetty file for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Setting_Crontab_Entry ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting up crontab one time run for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	/usr/sbin/postconf -e disable_vrfy_command=yes
	/usr/sbin/postconf -e smtpd_helo_required=yes
	sleep 30

	echo "Running crontab one time - allmid.sh..."
	/usr/localcw/bin/allmid.sh > /var/log/allmid.log 2>&1
	echo "Running crontab one time - auto_srm.ksh..."
	/usr/localcw/AutoSRM/auto_srm.ksh >/var/log/auto_srm.log 2>&1
	echo "Running crontab one time - auto.pl..."
	/usr/localcw/uam/uam_auto.pl >/var/log/uam_auto.log 2>&1
	echo "Running crontab one time - updateLocalSupportTools.ksh..."
	chmod 755 /usr/localcw/bin/updateLocalSupportTools.ksh
	/usr/localcw/bin/updateLocalSupportTools.ksh >/tmp/cron-	updateLocalSupportTools.log 2>&1

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting up crontab one time run for for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_Nagios ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing nagios for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	cd /tmp/
	wget --no-proxy --no-proxy http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/common/nagios.tar
	systemctl stop nagios-nrpe-server.service
	rm -rf /usr/lib/nagios
	tar xvf nagios.tar -C /
	touch /var/lib/nagios/ethstat.state
	chown nagios /var/lib/nagios/ethstat.state
	chmod 640 /var/lib/nagios/ethstat.state
	systemctl start nagios-nrpe-server.service
	chown nagios /var/lib/nagios/ethstat.state

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing nagios for Host:$HOSTNAME at: `date`"
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

	mkdir /opt/tools
	cd /tmp/
	wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/perform/TRUESIGHT/prod_ito/install_bpa.sh
	wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/perform/TRUESIGHT/prod_ito/ATT_m95031_SilentInstall.txt
	wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/perform/TRUESIGHT/prod_ito/$TSCO_AGENT_TAR
	chmod +x /tmp/install_bpa.sh
	/tmp/install_bpa.sh

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing BPA for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Removing_init_bgssd ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started removing init bgssd file for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	rm /etc/init.d/bgssd
	echo "Enabling BPA daemon..."
	systemctl enable bgssd
	sleep 5
	echo "restart BPA daemon..."
	systemctl restart bgssd
	systemctl status bgssd

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed removing init bgssd file for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}




function Crontab_Cleanup ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started cleaning up crontab for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
				
	/bin/sed -i  '/^@reboot/d' /var/spool/cron/crontabs/root

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed cleaning up crontab for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Disable_FW
{
	/usr/sbin/ufw disable
}

function Fix_Lab_Specific_Setup

{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started fixing  interface file for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	/bin/grep ^m92488 /etc/passwd

	if [ $? -ne 0 ]
	then
	echo "Adding user m92488 to the Host:$HOSTNAME..."
	/usr/sbin/useradd -c "Arcadian MechID" -d /home/m92488 -m -u 341331 -g 499200  -s /bin/bash m92488
	fi

	echo "Adding user m92488 to the group libvirt..."
	usermod -a -G libvirt m92488

	/bin/grep ^arct4 /etc/group

	if [ $? -ne 0 ]
	then
	echo "Adding group arct4 to the group..."
	groupadd -g 499200 arct4
	fi

	if [ ! -f /usr/localcw/opt/sudo/sudoers.d/uamgrouparct4_sudoers ]
	then
	echo "Creating the UAM arct4 group..."
        echo "%arct4  ALL=(root) ALL">/usr/localcw/opt/sudo/sudoers.d/uamgrouparct4_sudoers
	fi

	if [ -d /home/m92488 ]
	then
	echo "Chown of home to m92488:arct4..."
	chown m92488:arct4 /home/m92488
	mkdir /home/m92488/.ssh
	wget --no-proxy -O /home/m92488/.ssh/authorized_keys http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/$TENANT/add-ons/authorized_keys

		if [ -f /home/m92488/.ssh/authorized_keys ]
			then
			echo "Chmod of home to 600..."
			chmod 600 /home/m92488/.ssh/authorized_keys
			chown m92488:arct4 /home/m92488/.ssh/authorized_keys
		fi
	fi

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed cleaning file system for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Setup_MechID ()
{
	wget --no-proxy -O /tmp/mechid.sh http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/common/mechid.sh
	chmod +x /tmp/mechid.sh
	/bin/sh /tmp/mechid.sh
}


function Setup_BootDisk_Order ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting up Bootdisk Order for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	/bin/racadm set BIOS.BiosBootSettings.bootseq HardDisk.List.1-1
	sleep 20
	/bin/racadm jobqueue create BIOS.Setup.1-1
	/bin/racadm set iDRAC.ServerBoot.FirstBootDevice HDD
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Ended setting up Bootdisk Order for Host:$HOSTNAME at: `date`"
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

	cd /tmp; wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attradius_4.0_amd64.deb
	dpkg -i attradius_4.0_amd64.deb

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Radius for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Register_Radius ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started registeration Radius for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
	HOST=$(hostname -f)
	IP=$(host ${HOST} | grep "has address" | head -1 | awk '{print $4}')
	ADDR1="acdtools@cldv0018.sldc.sbc.com"
	ADDR2="acdtools@tldv0021.dadc.sbc.com"
	MAILLOG="/tmp/maillog"
	IP=$(host ${HOST} | grep "has address" | head -1 | awk '{print $4}')
  	echo "ADD_NAS:${HOST}:IP:${IP}" | mail -v -s "Pam Radius Automated Registration ${HOST}" ${ADDR1} ${ADDR2}

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed registering Radius for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Installing_ATTnologin ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing attnologin for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
	cd /tmp; wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attnologin_5.0.2.0_amd64.deb
	dpkg -i attnologin_5.0.2.0_amd64.deb
	ln -s /usr/localcw/bin/nologin /bin/nologin
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing attnologin for Host:$HOSTNAME at: `date`"
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
	cd /tmp; wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attlogins_2.0.1.0_amd64.deb
	dpkg -i attlogins_2.0.1.0_amd64.deb
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing ATTlogins for Host:$HOSTNAME at: `date`"
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
	cd /tmp; wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attbrkgls_1.0_all.deb
	dpkg -i attbrkgls_1.0_all.deb
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Brkglass for Host:$HOSTNAME at: `date`"
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
	cd /tmp; wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/atteksh_2.0_amd64.deb
	dpkg -i atteksh_2.0_amd64.deb
        echo "Creating toor binary"
        echo "/usr/bin/sudo -H /usr/localcw/bin/eksh -l -o vi" > /usr/local/bin/toor
        echo "Setting permissions on toor file..."
        chmod 755 /usr/local/bin/toor 
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Eksh for Host:$HOSTNAME at: `date`"
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
	cd /tmp; wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/attclvw_1.0_amd64.deb
	dpkg -i attclvw_1.0_amd64.deb
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Clearview for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}




function Update_Patch ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started updating patches to latest on Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        cd /tmp; wget --no-proxy http://mirrors.it.att.com/pub/custom/SD/nasCommon/ubuntu/patch_ubuntu.sh
        chmod 755 /tmp/patch_ubuntu.sh
        /tmp/patch_ubuntu.sh
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing Update_Patch for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Disable_IPMI ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started disabling IPMI for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

        /bin/racadm set iDRAC.IPMILan.Enable 0
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed disabling IPMI for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}


function Setup_Additional_FS_GUESTOS ()
{

    
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting up additional file system for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        
        # Check if any virtual disk is using disks in slot 6
        racadm_output=$(racadm storage get vdisks)
        if echo "$racadm_output" | grep -w "Disk.Virtual.1:RAID.Slot.6-1"; then
        echo "A virtual disk using disks in slot 6 already exists. No action taken."
        else
       # Create the virtual disk
       echo "Creating Raid 1 with disks 2 & 3 for VM disks"
       /bin/racadm storage createvd:RAID.Slot.6-1 -rl r1 -wp wb -rp ra -name DATA2 -pdkey:Disk.Bay.2:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.3:Enclosure.Internal.0-1:RAID.Slot.6-1
       echo "Creating job for Raid 1 creation for VM disks"
       /bin/racadm jobqueue create RAID.Slot.6-1 --realtime
       sleep 60
   fi
##################### Variables #############################
    DISK="/dev/sdb"  
    PART_NUM="1"     
    PART_LABEL="primary" 
    FS_TYPE="ext4"   
    MOUNT_POINT="/var/lib/libvirt/images" 
    DEVICE_PATH="/dev/sdb1"
    FSTAB_ENTRY="$DEVICE_PATH $MOUNT_POINT ext4 defaults 0 2"
    


# Check if the partition already exists
    if sudo parted -s "$DISK" print | grep -q "^ $PART_NUM"; then
    echo "Partition $DEVICE_PATH already exists."
    else
    # Create the partition if it doesn't exist
    echo "Creating a new GPT partition table on $DISK"
    parted --script $DISK mklabel gpt
    echo "Creating partition $DEVICE_PATH..."
    sudo parted -s "$DISK" mkpart "$PART_LABEL" 0% 100%

    # Format the partition with the ext4 filesystem
    echo "Formatting partition $DEVICE_PATH as $FS_TYPE..."
    sudo mkfs.$FS_TYPE "${DISK}${PART_NUM}"
    fi

        # Check if the fstab entry already exists
        if ! grep -q "$FSTAB_ENTRY" /etc/fstab; then
            # Add the entry to /etc/fstab
            echo "$FSTAB_ENTRY" >> /etc/fstab
            echo "Entry added to /etc/fstab."
        else
            echo "Entry already exists in /etc/fstab. No action taken."
        fi

        if ! mountpoint -q "$MOUNT_POINT"; then
        echo "Mounting $DEVICE_PATH to $MOUNT_POINT..."
        sudo mkdir -p "$MOUNT_POINT"
        sudo mount "$DEVICE_PATH" "$MOUNT_POINT"
    else
        echo "$MOUNT_POINT is already mounted."
    fi

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting up additional file system for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}


function Setup_Additional_FS_GuestData() {
    echo "#_________________________________________________________________________"
    echo "#"
    echo "# Task: Started creating additional RAID for the Host: $HOSTNAME at: $(date)"
    echo "# This takes about 5 minutes to complete, please wait..."
    echo "#_________________________________________________________________________"

    NUMBER_OF_DISKS=$(/bin/racadm storage get pdisks | grep -c Disk)

    if [[ $NUMBER_OF_DISKS -ne 16 ]]; then
        echo "Failure: The host does not have the needed 16 drives..."
        return 0
    fi

    racadm_output=$(/bin/racadm storage get vdisks)

    if echo "$racadm_output" | grep -wq "Disk.Virtual.2:RAID.Slot.6-1"; then
        echo "A virtual disk using disks in slot 6 already exists (Disk.Virtual.2). Proceeding to check partition and filesystem setup."
    else
        echo "Creating RAID-6 for VM DATA, please wait..."
        /bin/racadm storage createvd:RAID.Slot.6-1 -rl r6 -wp wb -rp ra \
            -name DATA \
            -pdkey:Disk.Bay.4:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.5:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.6:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.7:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.8:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.9:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.10:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.11:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.12:Enclosure.Internal.0-1:RAID.Slot.6-1,Disk.Bay.13:Enclosure.Internal.0-1:RAID.Slot.6-1
        sleep 60

        /bin/racadm jobqueue create RAID.Slot.6-1 --realtime
        sleep 300
        if [[ $? -ne 0 ]]; then
            echo "Raid Creation Failed, exiting."
            return 1
        fi

        echo "Assigning hotspares..."
        for BAY in 14 15; do
            /bin/racadm storage hotspare:Disk.Bay.${BAY}:Enclosure.Internal.0-1:RAID.Slot.6-1 -assign yes -type ghs
            sleep 120
        done

        /bin/racadm jobqueue create RAID.Slot.6-1 --realtime
        sleep 300
        if [[ $? -ne 0 ]]; then
            echo "Hot spare assignment failed, exiting."
            return 1
        fi
        sleep 300
    fi

    echo "Setting up filesystem..."
    DISK="/dev/sdc"
    PART_NUM="1"
    PART_LABEL="primary"
    FS_TYPE="ext4"
    MOUNT_POINT="/guestdata"
    DEVICE_PATH="${DISK}${PART_NUM}"
    FSTAB_ENTRY="$DEVICE_PATH $MOUNT_POINT $FS_TYPE defaults 0 2"

    if sudo parted -s "$DISK" print | grep -q "^ $PART_NUM"; then
        echo "Partition $DEVICE_PATH already exists."
    else
        echo "Creating partition $DEVICE_PATH..."
        sudo parted --script "$DISK" mklabel gpt
        sudo parted -s "$DISK" mkpart "$PART_LABEL" 0% 100%
        sleep 5
        echo "Formatting partition $DEVICE_PATH as $FS_TYPE..."
        sudo mkfs.$FS_TYPE "$DEVICE_PATH"
    fi

    if ! grep -q "$DEVICE_PATH" /etc/fstab; then
        echo "$FSTAB_ENTRY" >> /etc/fstab
        echo "Entry added to /etc/fstab."
    else
        echo "Entry already exists in /etc/fstab. No action taken."
    fi

    if ! mountpoint -q "$MOUNT_POINT"; then
        echo "Mounting $DEVICE_PATH to $MOUNT_POINT..."
        sudo mkdir -p "$MOUNT_POINT"
        sudo mount "$DEVICE_PATH" "$MOUNT_POINT"
    else
        echo "$MOUNT_POINT is already mounted."
    fi

    echo "#_________________________________________________________________________"
    echo "#"
    echo "# Task: Completed setting up additional GuestData filesystem for Host: $HOSTNAME at: $(date)"
    echo "#"
    echo "#_________________________________________________________________________"
}

function Enable_SRIOV_NIC ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting up SRIOV NICs for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        #
        # Enabling SRIOV on eno1,2,enp94s0f0/1,enp216s0f0/1
	echo "# Task: Started setting up SRIOV on eno1 for Host:$HOSTNAME at: `date`"
        /bin/racadm set nic.DeviceLevelConfig.1.VirtualizationMode SRIOV
        echo "# Task: Started setting up SRIOV on eno2 for Host:$HOSTNAME at: `date`"
        /bin/racadm set nic.DeviceLevelConfig.2.VirtualizationMode SRIOV
        echo "# Task: Started setting up SRIOV on enp94s0f0 for Host:$HOSTNAME at: `date`"
        /bin/racadm set nic.DeviceLevelConfig.5.VirtualizationMode SRIOV
        echo "# Task: Started setting up SRIOV on enp94s0f1 for Host:$HOSTNAME at: `date`"
        /bin/racadm set nic.DeviceLevelConfig.6.VirtualizationMode SRIOV
        echo "# Task: Started setting up SRIOV on enp216s0f0 for Host:$HOSTNAME at: `date`"
        /bin/racadm set nic.DeviceLevelConfig.7.VirtualizationMode SRIOV
        echo "# Task: Started setting up SRIOV on enp216s0f1 for Host:$HOSTNAME at: `date`"
        /bin/racadm set nic.DeviceLevelConfig.8.VirtualizationMode SRIOV

        echo "# Task: Started create jobqueue on eno1 for Host:$HOSTNAME at: `date`"
        /bin/racadm jobqueue create NIC.Integrated.1-1-1
        echo "# Task: Started create jobqueue on eno2 for Host:$HOSTNAME at: `date`"
        /bin/racadm jobqueue create NIC.Integrated.1-2-1

        echo "# Task: Started create jobqueue on enp94s0f0 for Host:$HOSTNAME at: `date`"
        /bin/racadm jobqueue create NIC.Slot.3-1-1
        echo "# Task: Started create jobqueue on enp94s0f1 for Host:$HOSTNAME at: `date`"
        /bin/racadm jobqueue create NIC.Slot.3-2-1
        echo "# Task: Started create jobqueue on enp216s0f0 for Host:$HOSTNAME at: `date`"
        /bin/racadm jobqueue create NIC.Slot.8-1-1
        echo "# Task: Started create jobqueue on enp216s0f1 for Host:$HOSTNAME at: `date`"
        /bin/racadm jobqueue create NIC.Slot.8-2-1
        sleep 90

        #
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting up SRIOV NICs for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        #
}

function Ssh_Vulnerability_Fix ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started Ssh_Vulnerability_Fix for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
	/bin/sed -i '$ a\Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com\nMACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512\nKexalgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256' /etc/ssh/sshd_config
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed Ssh_Vulnerability_Fix for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Disable_SNMP_Agent ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started Disabling SNMP Agent on Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
	/bin/racadm set iDRAC.SNMP.AgentEnable Disabled
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed Disabling SNMP Agent on Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

}

function Setup_VFs ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting up SRIOV VFs for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
        #
        wget --no-proxy -O /usr/local/bin/vf_setup.sh http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/$TENANT/add-ons/vf_setup_UB22.sh
        chmod +x /usr/local/bin/vf_setup.sh
        #
        wget --no-proxy -O /etc/systemd/system/vf_setup.service  http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/$TENANT/add-ons/vf_setup_UB22.service
        /bin/systemctl enable vf_setup.service
        #
        wget --no-proxy -O /usr/local/bin/listvfs_by_pf.sh http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/common/listvfs_by_pf.sh
        chmod +x /usr/local/bin/listvfs_by_pf.sh
        #
        wget --no-proxy -O /usr/local/bin/listvfs.sh http://$ARCADIAN_REPO_INTLAB_IP/Arcadian/common/listvfs.sh
        chmod +x /usr/local/bin/listvfs.sh
	sleep 60
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting up SRIOV VFs for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function Disable_PXE_NIC3 ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started disabling PXE on eno3 for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	echo "Setting boot proto on eno3 to NONE"
	/bin/racadm set NIC.NICConfig.3.LegacyBootProto NONE

	echo "Creating job for NIC boot proto change to NONE"
	racadm jobqueue create NIC.Integrated.1-3-1
	
	sleep 10

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed disabling PXE on eno3 for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function Setup_iDRAC_PluginType ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting iDRAC Plugin Type for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	VIRTUAL_CONSOLE=`/bin/racadm get iDRAC.VirtualConsole.PluginType|sed -n 2p`
	echo "Checking for PluginType=HTML5"
	if [ "$VIRTUAL_CONSOLE" != "PluginType=2" ]
	then
        echo "Setting VirtualConsole.PluginType to HTML5"
        /bin/racadm set iDRAC.VirtualConsole.PluginType 2
        REBOOT_FLAG="TRUE"
        sleep 3
	fi

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting iDRAC Plugin Type for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function Install_Ntop ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing ntop for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	apt-get update && apt install -y ntopng

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing ntop for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function Setup_iDRAC_DomainName ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started setting up iDRAC DomainName for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	echo "Checking the host domainname"
	DCU_DOMAINNAME=`hostname -d`
        echo "Setting domainname in iDRAC"
        /bin/racadm set iDRAC.NIC.DNSDomainName $DCU_DOMAINNAME
        sleep 5

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed setting up iDRAC DomainName for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function VF_Fix ()
{


        echo ""
        echo "Additional changes to resolve two issues of iGEMS server"
        echo " #1 - Fixes the VM starting too early before VFs are created"
        echo " #2 - Increases the default SRIOV VFs"
        echo ""

        mkdir -p /etc/systemd/system/libvirtd.service.d/
        echo "##########################################################">/etc/systemd/system/libvirtd.service.d/00-setup-vfs.conf
        echo "[Unit]">>/etc/systemd/system/libvirtd.service.d/00-setup-vfs.conf
        echo "After=network.target vf_setup.service">>/etc/systemd/system/libvirtd.service.d/00-setup-vfs.conf
        echo "##########################################################">>/etc/systemd/system/libvirtd.service.d/00-setup-vfs.conf



}

function Disable_CloudInit ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started Disable_CloudInit for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	###Disable cloud init
	touch /etc/cloud/cloud-init.disabled
      	###Remove cloud-init and remove relevant files
	apt-get purge -y cloud-init
	rm -rf /etc/cloud/ && sudo rm -rf /var/lib/cloud/
        sleep 5

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed Disable_CloudInit for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function installing_perccli ()
{
echo "Downloading the perlcli utility to /var/tmp"
wget -P /var/tmp http://135.21.13.101/Arcadian/common/PERCCLI_7.2313.0_A14_Linux.tar.gz
echo "Extracting the file"
tar xzvf /var/tmp/PERCCLI_7.2313.0_A14_Linux.tar.gz
echo "Installing the package"
dpkg -i /var/tmp/PERCCLI_7.2313.0_A14_Linux/perccli_007.2313.0000.0000_all.deb
echo "enable Firmware Device Order"
/opt/MegaRAID/perccli/perccli64 /c0 set deviceorderbyfirmware=on
echo "Installation Completed"
}

function Install_lldpd ()
{
        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Started installing lldpd for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"

	apt-get update && apt install -y lldpd
        #Enable lldpd process
	systemctl enable lldpd

        echo "#_________________________________________________________________________"
        echo "#"
        echo "# Task: Completed installing lldpd for Host:$HOSTNAME at: `date`"
        echo "#"
        echo "#_________________________________________________________________________"
}

function All_OS_Flavors_Hardening() 

{
    echo " Modifying default users"

    # 1. Remove/set users
    /usr/sbin/userdel games 2>/dev/null
    /usr/bin/chage -E 1 sync
    /usr/bin/chage -E 1 shutdown
    /usr/bin/chage -E 1 halt
    /usr/bin/chage -E 1 news

    echo "Setting permissions on /etc/skel files for SACT"

    # 2. Set permissions on /etc/skel files for SACT
    /bin/chmod 600 /etc/skel/.bash_profile
    /bin/chmod 600 /etc/skel/.bash_logout
    /bin/chmod 600 /etc/skel/.bashrc
    [ -f /etc/skel/.gtkrc ] && /bin/chmod 600 /etc/skel/.gtkrc
    [ -f /etc/skel/.zshrc ] && /bin/chmod 600 /etc/skel/.zshrc

    echo "Removing umask settings in /etc/bashrc"

    # 3. Remove the umask settings in /etc/bashrc
    /bin/cp /etc/bashrc /var/tmp/bashrc
    /bin/sed 's|umask|/bin/true|g' /etc/bashrc > /tmp/bashrc.new
    /bin/cp /tmp/bashrc.new /etc/bashrc

    echo "Creating /etc/profile.d/umask.sh"

    # 4. Setup umask.sh
    /bin/cat > /etc/profile.d/umask.sh << 'EOF'
# Set umask
if [ `/usr/bin/id -u` -gt 99 ]; then
   umask 027
else
   umask 022
fi
EOF
    /bin/chmod 644 /etc/profile.d/umask.sh

    echo "Creating /etc/profile.d/tmout.sh"

    # 5. Set TMOUT variable for all shells
    /bin/cat > /etc/profile.d/tmout.sh << 'EOF'
# Shell inactivity timeout: 15 minutes
TMOUT=900
export TMOUT
readonly TMOUT
EOF
    /bin/chmod 644 /etc/profile.d/tmout.sh

    echo "[INFO] Setting up mesg script..."

    # 6. Set up mesg
    {
        echo 'if [ `echo $- | grep i` ]; then'
        echo '        mesg n'
        echo 'fi'
    } > /etc/profile.d/mesg.sh

    {
        echo 'if ($?prompt) then'
        echo '        mesg n'
        echo 'endif'
    } > /etc/profile.d/mesg.csh

    chmod 644 /etc/profile.d/mesg.sh
    chmod 644 /etc/profile.d/mesg.csh
    mesg n

    echo "All OS Flavors Hardening defaults applied."
}

function set_idrac_dnsracname () 

{
    HOSTNAME=$(hostname)
    EXPECTED_HOSTNAME="${HOSTNAME}-mgmt"

    # iDRAC DNSRacName
    CURRENT_HOSTNAME=$(racadm get iDRAC.NIC.DNSRacName 2>/dev/null | grep '^iDRAC.NIC.DNSRacName' | awk -F= '{print $2}' | xargs)

    # Compare current and expected hostname
    if [ "$CURRENT_HOSTNAME" == "$EXPECTED_HOSTNAME" ]; then
        echo "iDRAC DNSRacName is already set to '$CURRENT_HOSTNAME'. No change needed."
    else
        echo "iDRAC DNSRacName is '$CURRENT_HOSTNAME'. Updating to '$EXPECTED_HOSTNAME'..."
        racadm set iDRAC.NIC.DNSRacName "$EXPECTED_HOSTNAME"
        if [ $? -eq 0 ]; then
            echo "iDRAC DNSRacName updated to '$EXPECTED_HOSTNAME'."
        else
            echo "Failed to set iDRAC DNSRacName."
        fi
    fi
}


# Main Program

#Check if gw is reachable before executing the below functions
#If gateway is not reachable, abort the script
GW_IP=$(/sbin/ip route | awk '/default/ { print $3 }')
echo "Gateway of the host is" $GW_IP

echo "pinging the gateway"
ping -c1 -W1 -q $GW_IP &>/dev/null
status=$( echo $? )

if [[ $status != 0 ]] ; then
     echo "Gateway is not reachable. Aborting the script"
     exit 0
fi

############################################FUNCTION EXECUTION############################################################

execute_common_functions() {

echo "Executing function Setup_Environment"
Setup_Environment

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setup_Environment function failed"
	exit 0
fi

echo "Executing function Run_Repo_Update"
Run_Repo_Update

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Run_Repo_Update function failed"
	exit 0
fi

echo "Executing function Install_Racadm"
Install_Racadm

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Install_Racadm function failed"
	exit 0
fi

echo "Executing function Setup_Wget_Proxy"
Setup_Wget_Proxy

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setup_Wget_Proxy function failed"
	exit 0
fi

echo "Executing function Configure_Mailname"
Configure_Mailname

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Configure_Mailname function failed"
	exit 0
fi

echo "Executing function Configure_postfix"
Configure_postfix

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Configure_postfix function failed"
	exit 0
fi

echo "Executing function Clear_root_emails"
Clear_root_emails

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Clear_root_emails function failed"
	exit 0
fi

echo "Executing function Installing_allmid"
Installing_allmid

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_allmid function failed"
	exit 0
fi

echo "Executing function Installing_ATTsudo"
Installing_ATTsudo

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_ATTsudo function failed"
	exit 0
fi

echo "Executing function Installing_AutoSRM"
Installing_AutoSRM

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_AutoSRM function failed"
	exit 0
fi

echo "Executing function Configuring_Sensage"
Configuring_Sensage

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Configuring_Sensage function failed"
	exit 0
fi

echo "Executing function Setting_Audit_Files"
Setting_Audit_Files

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setting_Audit_Files function failed"
	exit 0
fi

echo "Executing function Configuring_UAM"
Configuring_UAM

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Configuring_UAM function failed"
	exit 0
fi

echo "Executing function Installing_UAM"
Installing_UAM

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_UAM function failed"
	exit 0
fi



echo "Executing function Creating_Users_for_SACT"
Creating_Users_for_SACT

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Creating_Users_for_SACT function failed"
	exit 0
fi

echo "Executing function Installing_SACT"
Installing_SACT

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_SACT function failed"
	exit 0
fi

echo "Executing function Cron_Entry_for_SACT"
Cron_Entry_for_SACT

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Cron_Entry_for_SACT function failed"
	exit 0
fi

echo "Executing function Installing_XPW"
Installing_XPW

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_XPW function failed"
	exit 0
fi

echo "Executing function Configuring_NTP"
Configuring_NTP

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Configuring_NTP function failed"
	exit 0
fi

echo "Executing function File_Permissions"
File_Permissions

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as File_Permissions function failed"
	exit 0
fi

echo "Executing function Server_Profile"
Server_Profile

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Server_Profile function failed"
	exit 0
fi

echo "Executing function Setting_Password_Expiry"
Setting_Password_Expiry

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setting_Password_Expiry function failed"
	exit 0
fi

echo "Executing function Setting_False_Shell"
Setting_False_Shell

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setting_False_Shell function failed"
	exit 0
fi

echo "Executing function Setting_Securetty_File"
Setting_Securetty_File

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setting_Securetty_File function failed"
	exit 0
fi

echo "Executing function Restrictive_Permissions"
Restrictive_Permissions

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Restrictive_Permissions function failed"
	exit 0
fi

echo "Executing function Setting_Crontab_Entry"
Setting_Crontab_Entry

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setting_Crontab_Entry function failed"
	exit 0
fi

echo "Executing function Installing_Nagios"
Installing_Nagios

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_Nagios function failed"
	exit 0
fi

echo "Executing function Installing_BPA"
Installing_BPA

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_BPA function failed"
	exit 0
fi

echo "Executing function Removing_init_bgssd"
Removing_init_bgssd

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Removing_init_bgssd function failed"
	exit 0
fi



echo "Executing function Crontab_Cleanup"
Crontab_Cleanup

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Crontab_Cleanup function failed"
	exit 0
fi

echo "Executing function Disable_FW"
Disable_FW

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Disable_FW function failed"
	exit 0
fi

echo "Executing function Fix_Lab_Specific_Setup"
Fix_Lab_Specific_Setup

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Fix_Lab_Specific_Setup function failed"
	exit 0
fi


echo "Executing function Setup_MechID"
Setup_MechID

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setup_MechID function failed"
	exit 0
fi

echo "Executing function Installing_Radius"
Installing_Radius

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_Radius function failed"
	exit 0
fi

echo "Executing function Register_Radius"
Register_Radius

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Register_Radius function failed"
	exit 0
fi

echo "Executing function Installing_ATTnologin"
Installing_ATTnologin

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_ATTnologin function failed"
	exit 0
fi

echo "Executing function Installing_ATTlogins"
Installing_ATTlogins

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_ATTlogins function failed"
	exit 0
fi

echo "Executing function Installing_Brkglass"
Installing_Brkglass

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_Brkglass function failed"
	exit 0
fi

echo "Executing function Installing_Eksh"
Installing_Eksh

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_Eksh function failed"
	exit 0
fi



echo "Executing function Installing_Clearview"
Installing_Clearview

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Installing_Clearview function failed"
	exit 0
fi


echo "Executing function Ssh_Vulnerability_Fix"
Ssh_Vulnerability_Fix

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Ssh_Vulnerability_Fix function failed"
	exit 0
fi

echo "Executing function Disable_SNMP_Agent"
Disable_SNMP_Agent

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Disable_SNMP_Agent function failed"
	exit 0
fi

echo "Executing function Setup_Additional_FS_GUESTOS"
Setup_Additional_FS_GUESTOS

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setup_Additional_FS_GUESTOS function failed"
	exit 0
fi



echo "Executing function Update_Patch"
Update_Patch

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Update_Patch function failed"
	exit 0
fi

echo "Executing function Disable_IPMI"
Disable_IPMI

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Disable_IPMI function failed"
	exit 0
fi

echo "Executing function Setup_BootDisk_Order"
Setup_BootDisk_Order

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setup_BootDisk_Order function failed"
	exit 0
fi

echo "Executing function Disable_PXE_NIC3"
Disable_PXE_NIC3

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Disable_PXE_NIC3 function failed"
	exit 0
fi

echo "Executing function Setup_iDRAC_PluginType"
Setup_iDRAC_PluginType

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setup_iDRAC_PluginType function failed"
	exit 0
fi

echo "Executing function Install_Ntop"
Install_Ntop
status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Install_Ntop function failed"
	exit 0
fi

echo "Executing function Setup_iDRAC_DomainName"
Setup_iDRAC_DomainName
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Setup_iDRAC_DomainName function failed"
        exit 0
fi


echo "Executing function Disable_CloudInit function"
Disable_CloudInit
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Disable_CloudInit function failed"
        exit 0
fi

echo "Executing function installing_perccli"
Disable_CloudInit
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "installing_perccli function failed"
        exit 0
fi


echo "Executing function All_OS_Flavors_Hardening"
All_OS_Flavors_Hardening
status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as All_OS_Flavors_Hardening function failed"
	exit 0
fi

echo "Executing function set_idrac_dnsracname"
set_idrac_dnsracname
status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as set_idrac_dnsracname function failed"
	exit 0
fi

echo "Executing function Install_lldpd"
Install_lldpd
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "lldpd installation function failed"
        exit 0
fi

}

if [[ " ${common_tenants[@]} " =~ " $TENANT " ]]; then
  execute_common_functions

elif [[ " ${ovs_tenants[@]} " =~ " $TENANT " ]]; then
execute_common_functions
echo "Executing function Setup_OVS"
Setup_OVS
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Setup_OVS function failed"
        exit 0
fi


elif [[ " ${sriov_vf_tenants[@]} " =~ " $TENANT " ]]; then
execute_common_functions
echo "Executing function Enable_SRIOV_NIC function"
Enable_SRIOV_NIC
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Enable_SRIOV_NIC function failed"
        exit 0
fi

echo "Executing function Setup_VFs function"
Setup_VFs
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Setup_VFs function failed"
        exit 0
fi

echo "Executing function VF_Fix function"
VF_Fix
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "VF_Fix function failed"
       exit 0
fi


elif [[ " ${add_guest_data_tenants[@]} " =~ " $TENANT " ]]; then
execute_common_functions

echo "Executing function Setup_Additional_FS_GuestData"
Setup_Additional_FS_GuestData

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setup_Additional_FS_GuestData function failed"
	exit 0
fi

elif [[ " ${multi_function_tenant[@]} " =~ " $TENANT " ]]; then
execute_common_functions

echo "Executing function Setup_Additional_FS_GuestData"
Setup_Additional_FS_GuestData

status=$( echo $? )
if [[ $status != 0 ]] ; then
	echo "Aborting script as Setup_Additional_FS_GuestData function failed"
	exit 0
fi

echo "Executing function Enable_SRIOV_NIC function"
Enable_SRIOV_NIC
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Enable_SRIOV_NIC function failed"
        exit 0
fi

echo "Executing function Setup_VFs function"
Setup_VFs
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "Setup_VFs function failed"
        exit 0
fi

echo "Executing function VF_Fix function"
VF_Fix
status=$( echo $? )
if [[ $status != 0 ]] ; then
        echo "VF_Fix function failed"
       exit 0
fi


else
  echo "Unknown tenant: $TENANT"
  exit 1
fi

echo "All required functions for $TENANT executed successfully."

echo "Rebooting the server $HOSTNAME..."
wall "Rebooting the server. Please login back after 5-7 minutes"
sleep 10

/sbin/reboot
echo "Done"


#!/usr/bin/env bash
#系统配置及yum服务配置
#--------------------------------------------------------------------------------
# Install softeare -- Install oracle 11g database software
#
# History: 2018/01/14 zhuwei First release
#--------------------------------------------------------------------------------

# set a safe path before doing anything else
PATH=/sbin:/usr/sbin:/bin:/usr/bin; export PATH

# This script must be executed as root
RUID=`/usr/bin/id|awk -F\( '{print $1}'|awk -F\= '{print $2}'`

if [ ${RUID} != "0" ] ; then
    echo "This script must be executed as root"
    exit 1
fi

# Display an error and exit
errorExit() {
    echo "$@" >&2
    exit 1
}

# Display the normal print
displayheader() {
    echo -e "\033[32m**********************************************************\033[0m"
    echo -e "\033[32m*\033[0m"$@""
    echo -e "\033[32m**********************************************************\033[0m"
    echo ""
}

prepareSystem(){
# Set SElinux to disabled mode regardless of its initial value
  sed -i -e 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
  setenforce 0
# stop iptables
  /etc/init.d/iptables stop > /dev/null 2>&1
# *** Chkconfig section
# Turn off unwanted services
  chkconfig --level 0123456 iptables off
  chkconfig --level 0123456 ip6tables off
}

#Configure the kernel params
Configure1(){
    cat >> /etc/sysctl.conf <<EOF
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF
    if [ $? != 0 ]; then
        errorExit 'Unable to configure sysctl settings for database'
    fi

 return 0
}

Configure_signle(){
    cat >> /etc/security/limits.conf <<EOF
oracle   soft  nproc   2047
oracle   hard  nproc   16384
oracle   soft  nofile  1024
oracle   hard  nofile  65536
EOF
   if [ $? != 0 ]; then
        errorExit 'Unable to configure settings for database'
   fi

   return 0
}

Configure_rac(){
    cat >> /etc/security/limits.conf <<EOF
oracle   soft  nproc   2047
oracle   hard  nproc   16384
oracle   soft  nofile  1024
oracle   hard  nofile  65536
grid   soft  nproc   2047
grid   hard  nproc   16384
grid   soft  nofile  1024
grid   hard  nofile  65536
EOF
   if [ $? != 0 ]; then
        errorExit 'Unable to configure settings for database'
   fi

   return 0
}

Configure3(){
    cat >> /etc/pam.d/login <<EOF
session    required     pam_limits.so
EOF
   if [ $? != 0 ]; then
        errorExit 'Unable to configure settings for database'
   fi

   return 0
}

if [ $1 == "rac" ] || [ $1 == "RAC" ] ; then
  prepareSystem Configure1 && Configure_rac && Configure3 || errorExit ""
  if [ -f /etc/ntp.conf ]; then
    mv /etc/ntp.conf /etc/ntp.conf.bak
   /etc/init.d/ntpd stop > /dev/null 2>&1
    chkconfig --level 0123456 ntpd off
  fi
elif [ $1 == "signle" ] || [ $1 == "SIGNLE" ] ; then
  prepareSystem Configure1 && Configure_signle && Configure3 || errorExit ""
fi


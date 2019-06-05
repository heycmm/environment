#!/usr/bin/env bash
#RPM包安装及配置（install_rpm.sh）
#-----------------------------------------------------------------------------------------------
# Install softeare -- Install oracle 11g database software
#
# History: 2018/01/14 zhuwei First release
#-----------------------------------------------------------------------------------------------

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
    echo -e "\033[32m********************************************************************\033[0m"
    echo -e "\033[32m*\033[0m"$@""
    echo -e "\033[32m********************************************************************\033[0m"
    echo ""
}

# Detect and install oracle rpm package you need

if [ -e "/etc/oracle-release" ] ; then
    VERSION1=`sed -n '1p' /etc/issue|awk 'BEGIN{OFS=""} {print $1,$2,$7}'`
    VERSION2=`sed -n '1p' /etc/issue|awk 'BEGIN{OFS=""} {print $1,$2,$7}'|awk -F. '{print $1}'`
elif [ -e "/etc/redhat-release" ] ; then
    VERSION1=`sed -n '1p' /etc/issue|awk 'BEGIN{OFS=""} {print $1,$2,$7}'`
    VERSION2=`sed -n '1p' /etc/issue|awk 'BEGIN{OFS=""} {print $1,$2,$7}'|awk -F. '{print $1}'`
elif [ -e "/etc/SuSE-release" ] ; then
    VERSION1=`sed  '/^$/d' /etc/issue|awk 'BEGIN{OFS=""} {print $3,$7,$8}'`
    VERSION2=`sed  '/^$/d' /etc/issue|awk 'BEGIN{OFS=""} {print $3,$7}'`
elif [ -e "/etc/centos-release" ] ; then
    VERSION1=`sed -n '1p' /etc/issue|awk 'BEGIN{OFS=""} {print $1,$2,$7}'`
    VERSION2=`sed -n '1p' /etc/issue|awk 'BEGIN{OFS=""} {print $1,$2,$7}'|awk -F. '{print $1}'`
fi


#VALUE=`/usr/bin/getconf LONG_BIT`
OSDIGIT=`/bin/uname -m`
YUM=`which yum`
P_YUM="/etc/yum.repos.d/"

#-----------------------------------------------------------------------------------------------
# Download yum client configure file
if [ -d $P_YUM ] ; then
   mv $P_YUM /etc/yum.repos.d.bak
   mkdir -p $P_YUM
fi
/usr/bin/wget -N -q -P $P_YUM $1/rhelrepo/$VERSION2.repo \
|| errorExit 'Failed to download the yum client files,Please manually configure!'
/bin/sed -i 's/RedHat/'$VERSION1\_$OSDIGIT'/g' $P_YUM$VERSION2.repo \
|| errorExit 'Replace the files is not successful,Please manually configure!'
if [ -f $P_YUM$VERSION2.repo ]; then
    displayheader "Successfully configured yum client, please continue"
fi

#-----------------------------------------------------------------------------------------------
# RedHat 5 and RedHat 6 install oracle software required RPM package
#-----------------------------------------------------------------------------------------------
#Red Hat Enterprise Linux 5:The following packages (or later versions) must be installed:
Red5=(binutils-2* compat-libstdc++-33* elfutils-libelf-0.* elfutils-libelf-devel-0.* \
elfutils-libelf-devel-static-0.* gcc-4.* gcc-c++-4*  glibc-2.* glibc-common-2.* glibc-devel-2.* \
glibc-headers-2* kernel-headers-2.* libaio-0.* libaio-devel-0.* libgcc-4.* libgomp-4.* \
libstdc++-4.* libstdc++-devel-* make-* numactl-devel-* sysstat-* pdksh-* ksh-* \
unixODBC-* unixODBC-devel-*)

#Red Hat Enterprise Linux 6:The following packages (or later versions) must be installed:
Red6=(binutils-2* compat-libstdc++-33* elfutils-libelf-0.* elfutils-libelf-devel-0.* \
gcc-4.* gcc-c++-4* glibc-2.* glibc-common-2.* glibc-devel-2.* glibc-headers-2* \
kernel-headers-2.* libaio-0.* libaio-devel-0.* libgcc-4.* libgomp-4.* libstdc++-4.* \
libstdc++-devel-* make-* numactl-devel-* sysstat-* ksh-* unixODBC-* unixODBC-devel-*)

#Red Hat Enterprise Linux 7:The following packages (or later versions) must be installed:
Red7=(binutils-2* compat-libstdc++-33* elfutils-libelf-0.* elfutils-libelf-devel-0.* \
gcc-4.* gcc-c++-4* glibc-2.* glibc-common-2.* glibc-devel-2.* glibc-headers-2* \
kernel-headers-2.* libaio-0.* libaio-devel-0.* libgcc-4.* libgomp-4.* libstdc++-4.* \
libstdc++-devel-* make-* numactl-devel-* sysstat-* ksh-* unixODBC-* unixODBC-devel-*)

#SUSE 11 packages: The following packages (or later versions) must be installed:
Suse11=(binutils-2.* gcc-4.* gcc-c++-4.* glibc-2.9* glibc-devel-2.9* ksh-* libstdc++33-* \
libstdc++43-* libstdc++43-devel-* libaio-* libaio-devel-* libgcc43-* libstdc++-devel-* \
make-* sysstat-*)

rlen5=${#Red5[@]}
rlen6=${#Red6[@]}
rlen7=${#Red7[@]}
slen11=${#Suse11[@]}

COUNT=0

#-----------------------------------------------------------------------------------------------
# Test your system has been installed the RPM package
displayheader "You have installed the required RPM package is as follows:"
if [ $VERSION2 == "RedHat5" or  $VERSION2 == "Centos5" or  $VERSION2 == "Oracle5" ] ; then
for((i=0;i<rlen5;i++));
do
        CHAR=${Red5[$i]}
        rpm -qa | grep "^$CHAR"
        if [ $? != 0 ] ; then
                UNINSTALL[$COUNT]=${Red5[$i]}
                COUNT=$(($COUNT+1))
        fi
done
fi

if [ $VERSION2 == "RedHat6" or $VERSION2 == "Centos6" or $VERSION2 == "Oracle6" ] ; then
for((i=0;i<len6;i++));
do
        CHAR=${Red6[$i]}
        rpm -qa | grep "^$CHAR"
        if [ $? != 0 ] ; then
                UNINSTALL[$COUNT]=${Red6[$i]}
                COUNT=$(($COUNT+1))
        fi
done
fi

if [ $VERSION2 == "RedHat7" or $VERSION2 == "Centos7" or $VERSION2 == "Oracle7" ] ; then
for((i=0;i<len7;i++));
do
        CHAR=${Red7[$i]}
        rpm -qa | grep "^$CHAR"
        if [ $? != 0 ] ; then
                UNINSTALL[$COUNT]=${Red7[$i]}
                COUNT=$(($COUNT+1))
        fi
done
fi

if [ $VERSION2 == "SUSE11" ] ; then
for((i=0;i<slen11;i++));
do
        CHAR=${Suse11[$i]}
        rpm -qa | grep "^$CHAR"
        if [ $? != 0 ] ; then
                UNINSTALL[$COUNT]=${Suse11[$i]}
                COUNT=$(($COUNT+1))
        fi
done
fi

printf '\n'

#-----------------------------------------------------------------------------------------------
# Will not install the RPM packages for installation
if [ $COUNT -gt "0" ];then
     displayheader "Do you have "$COUNT" rpm package not installed,not installed patch is:"
     len=${#UNINSTALL[@]}
     for((j=0;j<len;j++));
     do
         echo "${UNINSTALL[$j]}"
     done
     printf '\n'
     #read -p  "Are you sure to install the patch[yes or y]:" SELECT
     #printf '\n'
     if [ $SELECT == "yes" -o $SELECT == "y" ]; then
         for((l=0;l<len;l++));
         do
             VAR=${UNINSTALL[$l]}
    #         if [ $VAR == "pdksh-5.2.14-36.el5.x86_64.rpm" ]; then
    #            rpm -qa ksh-*
    #            if [ $? == 0 ]; then
    #              yum -q -y remove ksh-* >/dev/null 2 > &1
    #            fi
    #         fi
             yum -q -y install $VAR  >/dev/null 2 > &1
         done
     fi
else
    displayheader "Required RPM packages have been installed"
fi
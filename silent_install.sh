#!/usr/bin/env bash
# 安装介质下载并执行静默安装
#-----------------------------------------------------------------------------------------------
# Install softeare -- Install oracle 11g database software
#
# History: 2018/01/14 zhuwei First release
#-----------------------------------------------------------------------------------------------
#暂时未调整好如下的脚本
# set a safe path before doing anything else
PATH=/sbin:/usr/sbin:/bin:/usr/bin; export PATH

# This script must be executed as root
RUID=`/usr/bin/id|awk -F\( '{print $1}'|awk -F\= '{print $2}'`

if [ ${RUID} != "0" ] ; then
    echo "This script must be executed as root"
    exit 1
fi

WEBSITE=$1
HOSTNAME=`hostname`
PATH1="/u/database/response"
ORACLE_BASE=`grep -w "ORACLE_BASE=" /home/oracle/.bash_profile |awk -F"=" '{print $2}'`
GRID_BASE=`grep -w "ORACLE_BASE=" /home/grid/.bash_profile |awk -F"=" '{print $2}'`
GRID_HOME=`grep -w "ORACLE_HOME=" /home/grid/.bash_profile |awk -F"=" '{print $2}'`

#-----------------------------------------------------------------------------------------------
#Configure the oracle silent installation files
#暂时未调整好如下的脚本
silent_oracle(){
 ORACLE_BASE="\/u\/app\/oracle"
 ORACLE_HOME=${ORACLE_BASE}"\/product\/11\.2\.0\/db_1"
 A1="ORACLE_HOSTNAME\="
 A2="INVENTORY_LOCATION\="
 A3="ORACLE_HOME\="
 A4="ORACLE_BASE\="
 B1=${A1}${HOSTNAME}
 B2=${A2}${ORACLE_BASE}"\/oraInventory"
 B3=${A3}${ORACLE_HOME}
 B4=${A4}${ORACLE_BASE}
 mv -f $PATH1/db_install.rsp $PATH1/db_install.rsp.bak
 wget -N -q -P  $PATH1 $WEBSITE/oracle11g/db_install.rsp
 sed -i -e "s/${A1}/${B1}/g" -e "s/${A2}/${B2}/g" -e "s/${A3}/${B3}/g" \
 -e "s/${A4}/${B4}/g" $PATH1/db_install.rsp || errorExit "The configuration file failed!"
}
#暂时未调整好如下的脚本
silent_grid(){
 ORACLE_BASE="\/u\/app\/oracle"
 ORACLE_HOME=${ORACLE_BASE}"\/product\/11\.2\.0\/db_1"
 A1="ORACLE_HOSTNAME\="
 A2="INVENTORY_LOCATION\="
 A3="ORACLE_HOME\="
 A4="ORACLE_BASE\="
 B1=${A1}${HOSTNAME}
 B2=${A2}${ORACLE_BASE}"\/oraInventory"
 B3=${A3}${ORACLE_HOME}
 B4=${A4}${ORACLE_BASE}
 mv -f $PATH1/db_install.rsp $PATH1/db_install.rsp.bak
 wget -N -q -P  $PATH1 $WEBSITE/oracle11g/db_install.rsp
 sed -i -e "s/${A1}/${B1}/g" -e "s/${A2}/${B2}/g" -e "s/${A3}/${B3}/g" \
 -e "s/${A4}/${B4}/g" $PATH1/db_install.rsp || errorExit "The configuration file failed!"
}

#download oracle software
download(){

    wget -N -q -P $ORACLE_BASE  $WEBSITE/$2/p*_[1-3]of7.zip

    unzip -q -d $ORACLE_BASE $ORACLE_BASE/p*_1of7.zip
    unzip -q -d $ORACLE_BASE $ORACLE_BASE/p*_2of7.zip
 unzip -q -d $ORACLE_BASE $ORACLE_BASE/p*_3of7.zip

    rm -rf /u/p*_[1-3]of7.zip

    chown -R oracle:oinstall $ORACLE_BASE/database
}
#暂时未调整好如下的脚本
if [ $1 == "rac" ] || [ $1 == "RAC" ] ; then
  chmod a+x ${PATH1}/db_install.rsp
  chown oracle:oinstall ${PATH1}/db_install.rsp
  su - oracle -c "/u/database/./runInstaller -silent -force -responseFile \
  ${PATH1}/db_install.rsp -ignoreSysPrereqs" >>/dev/null
elif [ $1 == "signle" ] || [ $1 == "SIGNLE" ] ; then
  chmod a+x ${PATH1}/db_install.rsp
  chown oracle:oinstall ${PATH1}/db_install.rsp
  su - oracle -c "/u/database/./runInstaller -silent -force -responseFile \
  ${PATH1}/db_install.rsp -ignoreSysPrereqs" >>/dev/null
fi
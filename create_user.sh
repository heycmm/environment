#!/usr/bin/env bash
#软件安装用户建立及用户环境配置
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

upassword=$2

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
#-----------------------------------------------------------------------------------------------
CheckPath(){
    if [ ! -n "$path" ]; then
       printf "\n\tYou input is invalid!\n"
       GetPath $1
    fi
    if [ ! -d "$path" ]; then
    mkdir -p $path
    pathsize=`df "$path"|sed '1d' |awk '{print $4}'`
       if [ $pathsize -lt 31457820 ] ; then
       printf "The path -ge 30gb will be created! \n"
    rm -rf $path
          GetPath $1
       else
          return 0
       fi
    else
    #path=`echo "$path"|awk -F "/" '{print $NF}'`
 pathsize=`df "$path"|sed '1d' |awk '{print $4}'`
       if [ $pathsize -lt 31457820 ] ; then
          GetPath $1
       else
          return 0
       fi
 fi
}

AuzPath(){
    if [ $i == "oracle_base" ] ; then
   chown -R oracle:oinstall $path
   chmod -R 775 `dirname $path`
 elif [ $i == "grid_base" ] ; then
   chown -R grid:oinstall $path
   chmod -R 775 `dirname $path`
 elif [ $i == "grid_home" ] ; then
   chown -R root:oinstall `dirname $path`
   chmod -R 775 `dirname $path`
 fi
}

GetPath(){
  paths=(oracle_base grid_base grid_home)
  printf '\nplease input the path of '${paths[0]}':'
  read install_path
  path=$install_path
  if CheckPath $path
  then
    i=${paths[0]}
    AuzPath $i $path
  fi
  obase=`grep -w "ORACLE_BASE=" /home/oracle/.bash_profile |awk -F"=" '{print $2}'`
  sed -i "s#${obase}#$path#" /home/oracle/.bash_profile
  if [ $1 == "rac" ] || [ $1 == "RAC" ] ; then
    printf '\nplease input the path of '${paths[1]}':'
    read install_path
    path=$install_path
    if CheckPath $path
    then
    i=${paths[1]}
       AuzPath $i $path
    fi
 gbase=`grep -w "ORACLE_BASE=" /home/grid/.bash_profile |awk -F"=" '{print $2}'`
 sed -i "s#${gbase}#$path#" /home/grid/.bash_profile
 printf '\nplease input the path of '${paths[2]}':'
    read install_path
    path=$install_path
    if CheckPath $path
    then
   i=${paths[2]}
      AuzPath $i $path
    fi
 ghome=`grep -w "ORACLE_HOME=" /home/grid/.bash_profile |awk -F"=" '{print $2}'`
 sed -i "#${ghome}#$path#" /home/grid/.bash_profile
  fi
}

#-----------------------------------------------------------------------------------------------
#Configure the oracle user's environment
profile(){
    cat > /home/${user[j]}/.bash_profile <<EOF
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
 . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH
export TMP=/tmp
export TMPDIR=\$TMP
export ORACLE_SID=test
export ORACLE_BASE=/u/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0/db_1
export TNS_ADMIN=\$ORACLE_HOME/network/admin
export ORACLE_TERM=xterm
export PATH=/usr/sbin:\$PATH
export PATH=\$ORACLE_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib:\$ORACLE_HOME/jdbc/lib
export CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
export NLS_LANG="AMERICAN_AMERICA.ZHT16BIG5"
export NLS_DATE_FORMAT='yyyy/mm/dd hh24:mi:ss'
umask 022
if [ $USER = "oracle" ]; then
  if [ $SHELL = "/bin/ksh" ]; then
    ulimit -p 16384
    ulimit -n 65536
  else
    ulimit -u 16384 -n 65536
  fi
fi
EOF
    if [ $? != 0 ]; then
       errorExit 'bash_profile this file does not exist'
 fi

 return 0
}
#-----------------------------------------------------------------------------------------------
#In the table below for the list of users and user groups
#
#   User Name          User ID
#   ---------          -------
#   oracle             601
#   grid               602
#
#   Group Name         Group ID
#   ---------          -------
#   oinstall           601
#   dba                602
#   asmadmin           603
#   asmdba             604
#   oper               605
#   asmoper            606
#Add Users and Groups
adduser_rac(){
  group=(oinstall dba asmadmin asmdba oper asmoper)
  user=(oracle grid)
  groups=`echo ${group[@]:1:4}|tr " " ","`
  for((i=0;i<${#group[@]};i++));
  do
    groupexit=`grep -w ${group[i]} /etc/group | awk -F: '{print $1}'`
 if [ -z ${groupexit} ]; then
   groupadd -g `expr 600 + $i + 1` ${group[i]} || errorExit ""
 else
   groupmod -g `expr 600 + $i + 1` ${group[i]} || errorExit ""
 fi
  done
  for((j=0;j<${#user[@]};j++));
  do
    userexit=`grep -w ${user[j]} /etc/shadow | awk -F: '{print $1}'`
 if [ -z ${userexit} ]; then
   useradd -d /home/${user[j]} -u `expr 600 + $j + 1` -g ${group[0]} \
   -G ${groups} ${user[j]} && echo ${user[j]}:${upassword}|chpasswd \
   && profile ${user[j]} || errorExit ""
 else
   usermod -u `expr 600 + $j + 1` ${user[j]} && echo ${user[j]}:${upassword}|chpasswd \
   && profile ${user[j]} || errorExit ""
 fi
  done
}

adduser_sigle(){
  group=(oinstall dba)
  for((i=0;i<${#group[@]};i++));
  do
    groupexit=`grep -w ${group[i]} /etc/group | awk -F: '{print $1}'`
 if [ -z ${groupexit} ]; then
   groupadd -g `expr 600 + $i + 1` ${group[i]} || errorExit ""
 else
   groupmod -g `expr 600 + $i + 1` ${group[i]} || errorExit ""
 fi
  done
  userexit=`grep -w oracle /etc/shadow | awk -F: '{print $1}'`
  if [ -z ${userexit} ]; then
 useradd -d /home/oracle -u `expr 600 + $j + 1` -g oinstall \
 -G oracle && echo oracle:${upassword}|chpasswd && profile ${user[j]} || errorExit ""
  else
 usermod -u `expr 600 + $j + 1` oracle && echo oracle:${upassword}|chpasswd \
 && profile ${user[j]} || errorExit ""
  fi
}
#-----------------------------------------------------------------------------------------------
if [ $1 == "rac" ] || [ $1 == "RAC" ] ; then
  adduser_rac $upassword && GetPath $1 || errorExit ""
elif [ $1 == "signle" ] || [ $1 == "SIGNLE" ] ; then
  adduser_sigle $upassword && GetPath $1 || errorExit ""
fi
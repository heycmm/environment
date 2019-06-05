#!/usr/bin/sh
#静默安装oracle软件shell主体
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

# Display a usage message and exit
usage() {
    cat >&2 <<EOF
Usage:
    ./install_oracle_main.sh  [options]

options:
    --client: version[11.2.0.3|11.2.0.4]
    --db: type[rac|signle] version[11.2.0.3|11.2.0.4]

examples:
    ./install_oracle_main.sh client
 ./install_oracle_main.sh db rac 11.2.0.1
 ./install_oracle_main.sh db signle 11.2.0.1
 
EOF
    exit 1
}

# Retrieve name of the platform 
PLATFORM=`uname`
PWD=`pwd`
WEBSITE="http://172.16.1.20/zwdir"
NUM_OF_NODES=3
NODE1="node1"
NODE2="node2"
NODE3="node3"
PASSWD="Rootpasswd"

if [ ${PLATFORM} = "HP-UX" ] ; then
    echo "This script does not support HP-UX platform for the time being"
elif [ ${PLATFORM} = "SunOS" ] ; then
    echo "This script does not support SunOS platform for the time being"
elif [ ${PLATFORM} = "AIX" ] ; then
    echo "This script does not support AIX platform for the time being"
elif [ ${PLATFORM} = "Linux" ] ; then
    TYPE1=$1
    TYPE2=$2
    VERSION=$3
    case ${TYPE1} in
    db|DB)
        case ${TYPE2} in
        rac|RAC)
            case ${VERSION} in
                11.2.0.3|11.2.0.4|12.1.0.2)
     sh ${PWD}/install_rpm.sh
                    sh ${PWD}/install_configure.sh ${TYPE2}
              sh ${PWD}/create_user.sh ${TYPE2} ${PASSWD}
     #以下两个脚本暂未完全调整好
           sh ${PWD}/ssh_setup.sh ${NUM_OF_NODES} ${NODE1} ${NODE2} ${PASSWD} 
     sh ${PWD}/silent_install.sh ${TYPE2} ${VERSION}
     ;;
          *)
     usage
           ;;
             esac
   ;;
        signle|SIGNLE)
      case ${VERSION} in
                11.2.0.3|11.2.0.4|12.1.0.2)
        sh ${PWD}/install_rpm.sh
                    sh ${PWD}/install_configure.sh ${TYPE2}
     #以下两个脚本暂未完全调整好
              sh ${PWD}/create_user.sh ${TYPE2} ${PASSWD}
     sh ${PWD}/silent_install.sh ${TYPE2} ${VERSION}
     ;;
          *)
     usage
           ;;
             esac
   ;;
        *)
   usage
   ;;
     esac
  ;;
    client|CLIENT) #暂未将安装客户端的脚本考虑进来
     sh ${PWD}/install_rpm.sh
        sh ${PWD}/install_configure.sh
  sh ${PWD}/create_user.sh
  sh ${PWD}/silent_install.sh ${TYPE2} ${VERSION}
  ;;
    *)
  usage
        ;;
    esac
fi

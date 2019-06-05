#!/usr/bin/env bash
#Purpose:Create and config oracle install.
#Usage:Log on as the superuser('root')
#其中#1.create groups and users部分根据实际情况修改具体环境变量值即可。
groupadd dba -g 111
groupadd oinstall -g 110
useradd oracle -u 110 -g 110 -G 111
echo "oracle" | passwd --stdin oracle
echo "export TMP=/tmp">> /home/oracle/.bash_profile
echo 'export TMPDIR=$TMP'>>/home/oracle/.bash_profile
echo "export ORACLE_HOSTNAME=localhost.localdomain">> /home/oracle/.bash_profile
echo "export ORACLE_SID=orcl">> /home/oracle/.bash_profile
echo "export ORACLE_BASE=/u01/app/oracle">> /home/oracle/.bash_profile
echo 'export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1'>> /home/oracle/.bash_profile
echo 'export PATH=/usr/sbin:$PATH'>> /home/oracle/.bash_profile
echo 'export PATH=$ORACLE_HOME/bin:$PATH'>> /home/oracle/.bash_profile
echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib'>> /home/oracle/.bash_profile
echo 'export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib'>> /home/oracle/.bash_profile
echo "export LANG=en_US" >> /home/oracle/.bash_profile
echo "export NLS_LANG=american_america.AL32UTF8" >> /home/oracle/.bash_profile
echo "export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'" >> /home/oracle/.bash_profile
mkdir -p /u01
mkdir -p /u01/app
mkdir -p /u01/app/oracle
chown -R oracle:oinstall /u01
chown -R oracle:oinstall /u01/app
chown -R oracle:oinstall /u01/app/oracle
cp /etc/security/limits.conf /etc/security/limits.conf.bak
echo "oracle soft nproc 2047" >>/etc/security/limits.conf
echo "oracle hard nproc 16384" >>/etc/security/limits.conf
echo "oracle soft nofile 1024" >>/etc/security/limits.conf
echo "oracle hard nofile 65536" >>/etc/security/limits.conf
cp /etc/pam.d/login /etc/pam.d/login.bak
echo "session required /lib/security/pam_limits.so" >>/etc/pam.d/login
echo "session required pam_limits.so" >>/etc/pam.d/login
cp /etc/profile /etc/profile.bak
echo 'if [ $USER = "oracle" ]; then' >>  /etc/profile
echo 'if [ $SHELL = "/bin/ksh" ]; then' >> /etc/profile
echo 'ulimit -p 16384' >> /etc/profile
echo 'ulimit -n 65536' >> /etc/profile
echo 'else' >> /etc/profile
echo 'ulimit -u 16384 -n 65536' >> /etc/profile
echo 'fi' >> /etc/profile
echo 'fi' >> /etc/profile
cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo "fs.aio-max-nr = 1048576" >> /etc/sysctl.conf
echo "fs.file-max = 6815744" >> /etc/sysctl.conf
echo "kernel.shmall = 2097152" >> /etc/sysctl.conf
echo "kernel.shmmax = 4294967295" >> /etc/sysctl.conf
echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
echo "kernel.sem = 250 32000 100 128" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 9000 65500" >> /etc/sysctl.conf
echo "net.core.rmem_default = 262144" >> /etc/sysctl.conf
echo "net.core.rmem_max = 4194304" >> /etc/sysctl.conf
echo "net.core.wmem_default = 262144" >> /etc/sysctl.conf
echo "net.core.wmem_max = 1048586" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 262144 262144 262144" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4194304 4194304 4194304" >> /etc/sysctl.conf
sysctl -p
#!/usr/bin/env bash
#RAC安装的SSH等效配置
#--------------------------------------------------------------------------------------
#这里本来是想着调用oracle安装包里面的sshUserSetup.sh进行SSH配置的，发现存在问题
#echo $USER | tr " " "\n"| while read LINE
#do
# EXPECT <<EOF
# spawn sh ./sshUserSetup.sh -user $LINE -hosts $NODES -verify -advanced
#        expect {
#        "yes/no" { send "yes\r";exp_continue }
#  "yes' or 'no" { send "yes\r";exp_continue }
#        "password:"{send "$PASSWORD\r";exp_continue }
#              }
# EXPECT eof
#EOF
#done
#---------------------------------------------------------------------------------------

NUM_OF_NODES=$1
NODE1=$2
NODE2=$3
NODE3=$4
LINE="root oracle grid"
EXPECT=/usr/bin/expect
PASSWD=$5
#USER_PROMPT="*$ "
USER_PROMPT="*# "

#以下脚本还未进行大批量的测试，有兴趣的童鞋欢迎一起研究
echo $LINE | tr " " "\n"| while read USER
do
if [ "x${NODE1}" == "x" -o "x${USER}" == "x" -o "x${PASSWD}" == "x" ]; then

echo ""

echo "Please set the NODE INFO, USER and PASSWD"

echo "then $0 to start..."

exit 1

fi

declare -i l_i=1

while [ $l_i -le $NUM_OF_NODES ]

do

eval l_current_node=\$NODE$l_i

$EXPECT <<EOF

spawn ssh $USER@$l_current_node

expect "*(yes/no)?*" {

send -- "yes\r"

expect "*?assword:*"

send -- "$PASSWD\r"

} "*?assword:*" {send -- "$PASSWD\r"}

expect "$USER_PROMPT"

send -- "ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -P '' \r"

expect "*Overwrite (yes/no)? " {

send -- "yes\r"

} "$USER_PROMPT" {send -- "\r"}

expect "$USER_PROMPT"

send -- "cat ~/.ssh/id_rsa.pub | ssh $USER@$NODE1 'cat - >> ~/.ssh/authorized_keys' \r"

expect "*(yes/no)?*" {

send -- "yes\r"

expect "*?assword:*"

send -- "$PASSWD\r"

} "*?assword:*" {send -- "$PASSWD\r"}

expect "$USER_PROMPT"

send -- "exit\r"

EOF

((l_i++))

done

declare -i l_n=1

while [ $l_n -le $NUM_OF_NODES ]

do

eval l_current_node=\$NODE$l_n

$EXPECT <<EOF

spawn ssh $USER@$NODE1

expect "*?assword:*" {

send -- "$PASSWD\r"

expect "$USER_PROMPT"

} "$USER_PROMPT" {send -- "scp ~/.ssh/authorized_keys $l_current_node:~/.ssh/ \r"}

expect "*?assword:*"

send -- "$PASSWD\r"

expect "$USER_PROMPT"

send -- "exit\r"

EOF

((l_n++))

done
done
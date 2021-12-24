#! /bin/bash
# 执行文件报错：-bash: ./initEnv.sh: /bin/bash^M: bad interpreter: No such file or directory
# 原因：Windows 和 Linux 系统换行符不一致导致的问题；
# 解决方法1：vi 或 vim 命令下，输入 set fileformat=unix 解决换行问题；
# 解决方法2：sed -i "s/\r//" init.sh
echo -e "========== 在 opt 和 var 创建 initEnv 文件夹 =========="
sleep 1
mkdir -p /opt/initEnv
mkdir -p /var/initEnv
mkdir -p /usr/local/scripts

echo -e "========== 禁用防火墙 =========="
sleep 1
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld

echo -e "========== 修改 selinux =========="
sleep 1
sed -i "/^SELINUX=/c SELINUX=disabled" /etc/selinux/config

echo -e "========== 安装 wget =========="
sleep 1
yum install wget -y

echo -e "========== 修改 yum 源 =========="
sleep 1
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache

echo -e "========== 安装 man =========="
yum install man -y

echo -e "========== 安装 man-pages =========="
yum install man-pages -y

echo -e "========== 安装 ntp =========="
yum install ntp -y

echo -e "========== 安装 vim =========="
yum install vim -y

echo -e "========== 安装 lrzsz =========="
yum install lrzsz -y

echo -e "========== 安装 zip =========="
yum install zip -y

echo -e "========== 安装 unzip =========="
yum install unzip -y

echo -e "========== 安装 net-tools =========="
yum install net-tools -y

echo -e "========== 安装 telnet =========="
yum install telnet -y

echo -e "========== 安装 perl =========="
yum install perl -y

echo -e "========== 同步系统时间 =========="
yum info ntp && ntpdate cn.ntp.org.cn

echo -e "========== DNS 域名配置 =========="
sleep 1
echo "192.168.20.100 CentOS-7.6-64" >> /etc/hosts
echo "192.168.20.101 clone01" >> /etc/hosts
echo "192.168.20.102 clone02" >> /etc/hosts
echo "192.168.20.103 clone03" >> /etc/hosts

echo -e "========== 安装 JDK =========="
sleep 1
rpm -ivh jdk-8u231-linux-x64.rpm
echo "export JAVA_HOME=/usr/java/jdk1.8.0_231-amd64" >> /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
source /etc/profile

echo -e "========== 安装 Tomcat =========="
sleep 1
tar -zxf apache-tomcat-8.5.47.tar.gz
mv apache-tomcat-8.5.47 /opt/initEnv/

echo -e "========== 安装 Mysql =========="
sleep 1
rpm -e --nodeps `rpm -qa | grep mariadb`
tar -xvf mysql-5.7.28-1.e17.x86_64.rpm-bundle.tar
rpm -ivh mysql-community-common-5.7.28-1.e17.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.28-1.e17.x86_64.rpm
rpm -ivh mysql-community-client-5.7.28-1.e17.x86_64.rpm
rpm -ivh mysql-community-server-5.7.28-1.e17.x86_64.rpm

systemctl start mysqld
systemctl enable mysqld

tempPasswd=`grep "A temporary password" /var/log/mysqld.log | awk '{ print $NF }'`

mysql -uroot -p $tempPasswd --connect-expired-password << EOF
set global validate_password_policy=low;
set global validate_password_length=6;
alter user root@localhost identified by '123456';

use mysql;
update user set host='%' where user='root';
commit;
quit
EOF

systemctl restart mysqld

echo -e "========== 设置开机启动项 =========="
sleep 1
touch /usr/local/scripts/auto_ntpdate.sh
echo "#! /bin/bash" >> /usr/local/scripts/auto_ntpdate.sh
echo "yum info ntp && ntpdate cn.ntp.org.cn" >> /usr/local/scripts/auto_ntpdate.sh
chmod u+x /usr/local/scripts/auto_ntpdate.sh
echo "/usr/local/scripts/auto_ntpdate.sh" >> /etc/rc.local
chmod u+x /etc/rc.local

echo -e "========== 设置定时任务自动更新时间 =========="
sleep 1

echo -e "========== 删除文件 =========="
sleep 1
rm -rf apache-tomcat-8.5.47.tar.gz
rm -rf jdk-8u231-linux-x64.rpm
rm -rf mysql*
rm -rf *.sh

echo -e "========== 关闭系统，拍摄快照 =========="
sleep 1
shutdown -h now
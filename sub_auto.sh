#!/bin/bash
#配置 yum源
sed -i /gpg/s/1/0/ /etc/yum.conf &> /dev/null
yum-config-manager --add http://192.168.4.254/rhel7 &> /dev/null
yum clean all &>/dev/null && yum makecache &>/dev/null && yum repolist  &>/dev/null
#安装subversion
rpm -qa | grep subversion &> /dev/null
if [ $? -eq 0 ];then
rm -rf /var/svn
yum -y reinstall subversion
else
yum -y install subversion
fi
#创建目录
mkdir /var/svn
#创建库
svnadmin create /var/svn/project
#导入库文件
cd /usr/lib/systemd/system
svn import . file:///var/svn/project/ -m "import date"
#修改配置文件1 svnserve.conf 配置文件的全局设置
sed -i -e '/anon-/s/^# //' -e '/anon-/s/read/none/' -e '/auth-/s/^# //' -e '/password-/s/^# //' -e '/authz-/s/^# //' /var/svn/project/conf/svnserve.conf
#修改配置文件2 passwd 增加用户名和密码 注意格式
sed -i -e '$a tom = 123456 \nharry = 123456' /var/svn/project/conf/passwd
#修改配置文件3 authz 修改库里面的目录进行权限设置
sed -i -e '$a [/] \ntom =rw \nharry = r \n*=r' /var/svn/project/conf/authz
#启动服务
svnserve -d -r /var/svn/project/
ss -nultp | grep svnserve &> /dev/null

#还原1 revert 单文件本地修改从服务器上下载回来

#还原2 update 本地操作后未上传服务器并从服务器下载

#还原3  merge -r4:1 本地修改后上传到服务器然后按版本号恢复

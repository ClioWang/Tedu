#!/bin/bash
ips=('201.1.1.100' '201.1.2.5' '201.1.2.100' '201.1.2.200')
for ip in ${ips[*]}
do
    scp '/root/桌面/lnmp_soft.tar.gz' $ip:~
done
for i in `seq 0 3`
do
ip=${ips[i]}
ssh -tt $ip <<EOF
a=`ifconfig eth0 | awk '/inet /{print $2}'`
b=`ifconfig eth1 | awk '/inet /{print $2}'`
c=''
if [ ! -z $b ] ;then c=${b%.*}.254  else  c=${a%.*}.254 fi
yum-config-manager --add-repo=http://$c
sed -i '/^$/d' /etc/yum.repos.d/192.168.4.254*
echo gpgcheck=0 >> /etc/yum.repos.d/192.168.4.254*
ar -xf lnmp_soft.tar.gz
cd lnmp_soft/
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2
useradd -s /sbin/nologin nginx > /dev/null
./configure \
--user=nginx  \
--group=nginx \
--with-http_ssl_module \
--with-stream \
--with-http_stub_status_module > /dev/null
make && make install > /dev/null
rm -rf /sbin/nginx
ln -s /usr/local/nginx/sbin/nginx /sbin/
systemctl stop httpd
systemctl disable httpd
cd  ~/lnmp_soft/
yum -y install php php-fpm-5.4.16-42.el7.x86_64.rpm mariadb-server memcached
systemctl start mariadb memcached
systemctl enable mariadb memcached php-fpm
nginx || nginx -s reload
exit
EOF
done
exit
#services

#!/bin/bash

yum install -y \
  redhat-lsb-core \
  wget \
  rpmdevtools \
  rpm-build \
  createrepo \
  yum-utils \
  gcc

# get and extract nginx rpm source package
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.18.0-1.el7.ngx.src.rpm
rpm -i nginx-1.18.0-1.el7.ngx.src.rpm

# install nginx dependencies
yum-builddep /root/rpmbuild/SPECS/nginx.spec -y
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz --directory /usr/lib

# add openssl to nginx configuration options
sed -i 's|--with-debug|--with-openssl=/usr/lib/openssl-1.1.1g|' /root/rpmbuild/SPECS/nginx.spec

# build new nginx package with updated spec
rpmbuild --bb /root/rpmbuild/SPECS/nginx.spec

# install and configure nginx from newrly created rpm package
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-1.el7.ngx.x86_64.rpm
sed -i '/index  index.html index.htm;/a autoindex on;' /etc/nginx/conf.d/default.conf
systemctl enable --now nginx

# create rpm repo
mkdir /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-1.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
createrepo /usr/share/nginx/html/repo/

# add rpm repo to available list
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF


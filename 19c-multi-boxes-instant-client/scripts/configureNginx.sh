#bin/bash

vServiceManagerUser=$1
vPassword=$2
vPort=$3

export JAVA_HOME=${OGG_HOME}/jdk
echo ${JAVA_HOME}
echo ${OGG_HOME}

cd ${OGG_HOME}/lib/utl/reverseproxy
./ReverseProxySettings -u $vServiceManagerUser -P $vPassword -o ogg.conf https://localhost:$vPort
sudo cp ogg.conf /etc/nginx/conf.d/nginx.conf
sudo sh /etc/ssl/certs/make-dummy-cert /etc/nginx/ogg.pem
sudo nginx
sudo nginx -t
sudo nginx -s reload

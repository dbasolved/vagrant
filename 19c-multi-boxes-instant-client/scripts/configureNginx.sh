#bin/bash

vServiceManagerUser=oggadmin
vPassword=WElcome12345##
vPort=16000

export JAVA_HOME=${OGG_HOME}/jdk
echo ${JAVA_HOME}
echo ${OGG_HOME}

cd ${OGG_HOME}/lib/utl/reverseproxy
./ReverseProxySettings -u $vServiceManagerUser -p $vPassword -o ogg.conf https://localhost:$vPort
sudo cp ogg.conf /etc/nginx/conf.d/nginx.conf
sudo sh /etc/ssl/certs/make-dummy-cert /etc/nginx/ogg.pem
sudo nginx
sudo nginx -t
sudo nginx -s reload

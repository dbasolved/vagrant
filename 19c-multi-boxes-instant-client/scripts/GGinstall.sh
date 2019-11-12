#!/bin/bash

echo "--------------------------------------------------"
echo 'INSTALLER: Started up'
echo "--------------------------------------------------"

#fix locale
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

echo "--------------------------------------------------"
echo 'INSTALLER: Locale Fixed'
echo "--------------------------------------------------"

#install prereqs and openssl
yum -y reinstall glibc-common
yum -y install oracle-database-preinstall-19c openssl

echo "--------------------------------------------------"
echo 'INSTALLER: Oracle database preinstall and openssl installed'
echo "--------------------------------------------------"
#adding server desktop and vncserver
yum -y install xterm
yum -y install tightvnc-server
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
sed -i -e "s|<USER>|oracle|g" /etc/systemd/system/vncserver@:1.service
yum -y install nginx

echo "--------------------------------------------------"
echo 'INSTALLER: GUI desktop and VNC Server installed'
echo "--------------------------------------------------"

#create directories
mkdir -pv $ORACLE_BASE && \
mkdir -pv $ORACLE_HOME && \
mkdir -pv $ORACLE_HOME_18C && \
mkdir -pv $ORACLE_HOME_19C && \
mkdir -pv $ORACLE_HOME_18C_LIB && \
mkdir -pv $ORACLE_HOME_19C_LIB && \
mkdir -pv $ORA_INVENTORY && \
mkdir -pv $TNS_ADMIN && \
mkdir -pv $OGG_HOME && \
mkdir -pv $DEPLOYMENT_BASE && \

#set permissions (abit of overkill)
chown oracle:oinstall -R $ORACLE_BASE
chown oracle:oinstall -R $ORACLE_HOME
chown oracle:oinstall -R $ORACLE_HOME_18C
chown oracle:oinstall -R $ORACLE_HOME_19C
chown oracle:oinstall -R $ORACLE_HOME_18C_LIB
chown oracle:oinstall -R $ORACLE_HOME_19C_LIB
chown oracle:oinstall -R $ORA_INVENTORY
chown oracle:oinstall -R $TNS_ADMIN
chown oracle:oinstall -R $OGG_HOME
chown oracle:oinstall -R $DEPLOYMENT_BASE

echo "--------------------------------------------------"
echo 'INSTALLER: Required Oracle directories created'
echo "--------------------------------------------------"

env | sort

#set environment variables in .bashrc
echo "export ORACLE_BASE=$ORACLE_BASE" >> /home/oracle/.bashrc && \
echo "export ORACLE_HOME=$ORACLE_HOME" >> /home/oracle/.bashrc && \
echo "export TNS_ADMIN=$TNS_ADMIN" >> /home/oracle/.bashrc && \
echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib" >> /home/oracle/.bashrc && \
echo "export OGG_HOME=$OGG_HOME" >> /home/oracle/.bashrc && \
echo "export DEPLOYMENT_BASE=$DEPLOYMENT_BASE" >> /home/oracle/.bashrc && \
echo "export JAVA_HOME=$JAVA_HOME" >> /home/oracle/.bashrc && \
echo "export PATH=\$PATH:\$ORACLE_HOME/bin:\$LD_LIBRARY_PATH:\$OGG_HOME/bin" >> /home/oracle/.bashrc

echo "--------------------------------------------------"
echo "INSTALLER: Setting Environment Variables for Oracle completed"
echo "--------------------------------------------------"

#unzip software and configure database
unzip -q -o -j /Test_Software/${CLIENT_SHIPHOME_18C} -d ${ORACLE_HOME_18C_LIB}

echo "--------------------------------------------------"
echo "INSTALLER: Oracle Database Client 18c installed   "
echo "--------------------------------------------------"

#unzip software and configure database
unzip -q -o -j /Test_Software/${CLIENT_SHIPHOME_19C} -d ${ORACLE_HOME_19C_LIB}

echo "--------------------------------------------------"
echo "INSTALLER: Oracle Database Client 19c installed   "
echo "--------------------------------------------------"

#configure GoldenGate
unzip -q -o /Test_Software/${OGG_SHIPHOME} -d /vagrant/oggma
rm -f ${OGG_SHIPHOME}
chmod -R 777 /vagrant/oggma 
cp /vagrant/ora-response/oggcore.rsp.tmpl /vagrant/ora-response/oggcore.rsp
sed -i -e "s|###DB_VERSION###|$DB_VERSION|g" /vagrant/ora-response/oggcore.rsp
sed -i -e "s|###OGG_HOME###|$OGG_HOME|g" /vagrant/ora-response/oggcore.rsp
echo
cat /vagrant/ora-response/oggcore.rsp
echo
su -l oracle -c "yes | /vagrant/oggma/fbo_ggs_Linux_x64_services_shiphome/Disk1/runInstaller -silent -showProgress -ignorePrereq -responseFile /vagrant/ora-response/oggcore.rsp"
rm -f /vagrant/ora-response/oggcore.rsp
rm -rf /vagrant/oggma

echo "--------------------------------------------------"
echo " INSTALLER: Oracle GoldenGate 19c Installed                  "
echo "--------------------------------------------------"

rm -rf /var/cache/yum

echo "--------------------------------------------------"
echo 'INSTALLER: Done'
echo "--------------------------------------------------"

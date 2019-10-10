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
yum -y install oracle-rdbms-server-12cR1-preinstall openssl

echo "--------------------------------------------------"
echo 'INSTALLER: Oracle database preinstall and openssl installed'
echo "--------------------------------------------------"
#adding server desktop and vncserver
yum -y groupinstall 'Server with GUI'
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
mkdir -pv $ORACLE_HOME_12C && \
mkdir -pv $ORACLE_HOME_19C && \
mkdir -pv $ORA_INVENTORY && \
mkdir -pv $TNS_ADMIN && \
mkdir -pv $OGG_HOME && \
mkdir -pv $DEPLOYMENT_BASE && \

#set permissions (abit of overkill)
chown oracle:oinstall -R $ORACLE_BASE
chown oracle:oinstall -R $ORACLE_HOME
chown oracle:oinstall -R $ORACLE_HOME_12C
chown oracle:oinstall -R $ORACLE_HOME_19C
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
unzip -q -o /Test_Software/${CLIENT_SHIPHOME_12C} -d /vagrant/ora12c_client
chmod -R 777 /vagrant/ora12c_client
cp /vagrant/ora-response/client_install_12c.rsp.tmpl /vagrant/ora-response/client_install_12c.rsp
sed -i -e "s|###ORA_INVENTORY###|${ORA_INVENTORY}|g" /vagrant/ora-response/client_install_12c.rsp && \
sed -i -e "s|###ORACLE_HOME###|${ORACLE_HOME_18C}|g" /vagrant/ora-response/client_install_12c.rsp && \
sed -i -e "s|###ORACLE_BASE###|${ORACLE_BASE}|g" /vagrant/ora-response/client_install_12c.rsp

su -l oracle -c "yes | /vagrant/ora12c_client/client/runInstaller -silent -ignoreSysPrereqs -ignorePrereq -showProgress -waitForCompletion -responseFile /vagrant/ora-response/client_install_12c.rsp"
$ORA_INVENTORY/orainstRoot.sh
$ORACLE_HOME/root.sh
rm -f /vagrant/ora-response/client_install_12c.rsp

echo "--------------------------------------------------"
echo "INSTALLER: Oracle Database Client 12c installed   "
echo "--------------------------------------------------"

#unzip software and configure database
unzip -q -o /Test_Software/${CLIENT_SHIPHOME_19C} -d /vagrant/ora19c_client
chmod -R 777 /vagrant/ora19c_client
cp /vagrant/ora-response/client_install_19c.rsp.tmpl /vagrant/ora-response/client_install_19c.rsp
sed -i -e "s|###ORA_INVENTORY###|${ORA_INVENTORY}|g" /vagrant/ora-response/client_install_19c.rsp && \
sed -i -e "s|###ORACLE_HOME###|${ORACLE_HOME_19C}|g" /vagrant/ora-response/client_install_19c.rsp && \
sed -i -e "s|###ORACLE_BASE###|${ORACLE_BASE}|g" /vagrant/ora-response/client_install_19c.rsp

su -l oracle -c "yes | /vagrant/ora19c_client/client/runInstaller -silent -ignoreSysPrereqs -ignorePrereq -showProgress -waitForCompletion -responseFile /vagrant/ora-response/client_install_19c.rsp"
$ORA_INVENTORY/orainstRoot.sh
$ORACLE_HOME/root.sh
rm -f /vagrant/ora-response/client_install_19c.rsp

echo "--------------------------------------------------"
echo "INSTALLER: Oracle Database Client 19c installed   "
echo "--------------------------------------------------"

#configure GoldenGate
unzip -q -o /Test_Software/${OGG_SHIPHOME} -d /vagrant/oggma
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

#remove yum cache
rm -rf /var/cache/yum

echo "--------------------------------------------------"
echo 'INSTALLER: Done'
echo "--------------------------------------------------"

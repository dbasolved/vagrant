#!/bin/bash

echo "--------------------------------------------------"
echo 'INSTALLER: Started up'
echo "--------------------------------------------------"

#get up to date
#yum upgrade -y

#echo "--------------------------------------------------"
#echo 'INSTALLER: System updated'
#echo "--------------------------------------------------"

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
yum -y groupinstall 'Server with GUI'
yum -y install tightvnc-server
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
sed -i -e "s|<USER>|oracle|g" /etc/systemd/system/vncserver@:1.service
yum -y install nginx

echo "--------------------------------------------------"
echo 'INSTALLER: GUI desktop and VNC Server installed'
echo "--------------------------------------------------"

su -l oracle -c "unsetenv http_proxy"
su -l oracle -c "unsetenv https_proxy"
su -l oracle -c "unsetenv HTTP_PROXY"
su -l oracle -c "unsetenv HTTPS_PROXY"

#create directories
mkdir -pv $ORACLE_BASE && \
mkdir -pv $ORACLE_HOME && \
mkdir -pv $ORA_INVENTORY && \
mkdir -pv $OGG_HOME && \
mkdir -pv $DEPLOYMENT_BASE && \

#set permissions (abit of overkill)
chown oracle:oinstall -R $ORACLE_BASE
chown oracle:oinstall -R $ORACLE_HOME
chown oracle:oinstall -R $ORA_INVENTORY
chown oracle:oinstall -R $OGG_HOME
chown oracle:oinstall -R $DEPLOYMENT_BASE

echo "--------------------------------------------------"
echo 'INSTALLER: Required Oracle directories created'
echo "--------------------------------------------------"

env | sort

#set environment variables in .bashrc
echo "export ORACLE_BASE=$ORACLE_BASE" >> /home/oracle/.bashrc && \
echo "export ORACLE_HOME=$ORACLE_HOME" >> /home/oracle/.bashrc && \
echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib" >> /home/oracle/.bashrc && \
echo "export ORACLE_SID=$ORACLE_SID" >> /home/oracle/.bashrc && \
echo "export OGG_HOME=$OGG_HOME" >> /home/oracle/.bashrc && \
echo "export DEPLOYMENT_BASE=$DEPLOYMENT_BASE" >> /home/oracle/.bashrc && \
echo "export PATH=\$PATH:\$ORACLE_HOME/bin:\$LD_LIBRARY_PATH:\$OGG_HOME/bin" >> /home/oracle/.bashrc

echo "--------------------------------------------------"
echo "INSTALLER: Setting Environment Variables for Oracle completed"
echo "--------------------------------------------------"
#unzip software and configure database
unzip -q -o /vagrant/${DB_SHIPHOME} -d $ORACLE_HOME/
cp /vagrant/ora-response/dbinstall.rsp.tmpl /vagrant/ora-response/db_install.rsp
sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" /vagrant/ora-response/db_install.rsp && \
sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" /vagrant/ora-response/db_install.rsp && \
sed -i -e "s|###ORA_INVENTORY###|$ORA_INVENTORY|g" /vagrant/ora-response/db_install.rsp
chown -R oracle:oinstall $ORACLE_HOME

su -l oracle -c "yes | $ORACLE_HOME/runInstaller -silent  -ignorePrereqFailure -waitforcompletion -responseFile /vagrant/ora-response/db_install.rsp"
$ORA_INVENTORY/orainstRoot.sh
$ORACLE_HOME/root.sh
rm -f /vagrant/ora-response/db_install.rsp

echo "--------------------------------------------------"
echo "INSTALLER: Oracle Database Software installed     "
echo "--------------------------------------------------"

#configure software
cp /vagrant/ora-response/netca.rsp.tmpl /vagrant/ora-response/netca.rsp
su -l oracle -c "yes | $ORACLE_HOME/bin/netca -silent -responseFile /vagrant/ora-response/netca.rsp"
su -l oracle -c "lsnrctl start"
rm -f /vagrant/ora-response/netca.rsp

echo "--------------------------------------------------"
echo " INSTALLER: Listener Installed                    "
echo "--------------------------------------------------"

cp /vagrant/ora-response/dbca.rsp.tmpl /vagrant/ora-response/dbca.rsp
sed -i -e "s|###ORACLE_SID###|$ORACLE_SID|g" /vagrant/ora-response/dbca.rsp && \
sed -i -e "s|###PDB_NAME###|$PDB_NAME|g" /vagrant/ora-response/dbca.rsp && \
sed -i -e "s|###ORACLE_PWD###|$ORACLE_PWD|g" /vagrant/ora-response/dbca.rsp 
echo
cat /vagrant/ora-reponse/dbca.rsp
echo
su -l oracle -c "yes | $ORACLE_HOME/bin/dbca -silent -createDatabase -responseFile /vagrant/ora-response/dbca.rsp"
#rm -f /vagrant/ora-response/dbca.rsp

echo "--------------------------------------------------"
echo " INSTALLER: Database Created                      "
echo "--------------------------------------------------"

#configure GoldenGate
unzip -q -o /vagrant/${OGG_SHIPHOME} -d /vagrant/oggma
chmod -R 777 /vagrant/oggma 
cp /vagrant/ora-response/oggcore.rsp.tmpl /vagrant/ora-response/oggcore.rsp
sed -i -e "s|###DB_VERSION###|$DB_VERSION|g" /vagrant/ora-response/oggcore.rsp
sed -i -e "s|###OGG_HOME###|$OGG_HOME|g" /vagrant/ora-response/oggcore.rsp
echo
cat /vagrant/ora-response/oggcore.rsp
echo
su -l oracle -c "yes | /vagrant/oggma/fbo_ggs_Linux_x64_services_shiphome/Disk1/runInstaller -silent -showProgress -ignorePrereq -responseFile /vagrant/ora-response/oggcore.rsp"
#rm -f /vagrant/ora-response/oggcore.rsp
rm -rf /vagrant/oggma

echo "--------------------------------------------------"
echo " INSTALLER: GoldenGate Installed                  "
echo "--------------------------------------------------"

#create 1st deployment and ServiceManager
#BUG 28495568:First deployment runs successfully, but when asked to run registerServiceManager.sh
#BUG 28495568:script does not exit and box has to be CTL+C out. Additionally, the registerServiceManager.sh
#BUG 28495568:script times out when running from another terminal window.
#BUG 28495568:Workaround:
#BUG 28495568:Do not run the silent install from the install.sh script.  Run it manaully from a terminal
#BUG 28495568:session or from the GUI oggca.sh

#BUG 28495568
#su -l oracle -c "yes | /opt/app/oracle/product/19.1.0/oggcore_1/bin/oggca.sh -silent -responseFile /vagrant/ora-response/oggca_alpha.rsp"

#$DEPLOYMENT_BASE/ServiceManager/bin/registerServiceManager.sh

#create additional deployment
#su -l oracle -c "yes | /opt/app/oracle/product/12.3.0.1.4/oggcore_1/bin/oggca.sh -silent #-responseFile /vagrant/ora-response/oggca_charlie.rsp"

#BUG 28495619 (Duplicat: known issue):For some reason, ServiceManager URL works (http://localhost:16000), but login page does not appear.

#echo "-----------------------------------------------------"
#echo " Deployments Created                                 "
#echo "-----------------------------------------------------"

#remove yum cache
rm -rf /var/cache/yum

echo "--------------------------------------------------"
echo 'INSTALLER: Done'
echo "--------------------------------------------------"

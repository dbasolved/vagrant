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

echo "--------------------------------------------------"
echo 'INSTALLER: GUI desktop and VNC Server installed'
echo "--------------------------------------------------"

#create directories
mkdir -pv $ORACLE_BASE && \
mkdir -pv $ORACLE_HOME && \
mkdir -pv $ORA_INVENTORY && \

#set permissions (abit of overkill)
chown oracle:oinstall -R $ORACLE_BASE
chown oracle:oinstall -R $ORACLE_HOME
chown oracle:oinstall -R $ORA_INVENTORY

echo "--------------------------------------------------"
echo 'INSTALLER: Required Oracle directories created'
echo "--------------------------------------------------"

#set environment variables in .bashrc
echo "export ORACLE_BASE=$ORACLE_BASE" >> /home/oracle/.bashrc && \
echo "export ORACLE_HOME=$ORACLE_HOME" >> /home/oracle/.bashrc && \
echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib" >> /home/oracle/.bashrc && \
echo "export ORACLE_SID=$ORACLE_SID" >> /home/oracle/.bashrc && \
echo "export PATH=\$PATH:\$ORACLE_HOME/bin:\$LD_LIBRARY_PATH:\$OGG_HOME/bin" >> /home/oracle/.bashrc

echo "--------------------------------------------------"
echo "INSTALLER: Setting Environment Variables for Oracle completed"
echo "--------------------------------------------------"
#unzip software and configure database
unzip -o /Test_Software/${DB_SHIPHOME} -d ${ORACLE_HOME}
cp /vagrant/ora-response/dbinstall.rsp.tmpl /vagrant/ora-response/db_install.rsp
sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" /vagrant/ora-response/db_install.rsp && \
sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" /vagrant/ora-response/db_install.rsp && \
sed -i -e "s|###ORA_INVENTORY###|$ORA_INVENTORY|g" /vagrant/ora-response/db_install.rsp
chown -R oracle:oinstall ${ORACLE_HOME}

su -l oracle -c "yes | ${ORACLE_HOME}/runInstaller -silent  -ignorePrereqFailure -waitforcompletion -responseFile /vagrant/ora-response/db_install.rsp"
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

su -l oracle -c "yes | $ORACLE_HOME/bin/dbca -silent -createDatabase -responseFile /vagrant/ora-response/dbca.rsp"
rm -f /vagrant/ora-response/dbca.rsp

echo "--------------------------------------------------"
echo " INSTALLER: Database Created                      "
echo "--------------------------------------------------"

#remove yum cache
rm -rf /var/cache/yum
rm -rf /vagrant/db19c

echo "--------------------------------------------------"
echo 'INSTALLER: Done'
echo "--------------------------------------------------"

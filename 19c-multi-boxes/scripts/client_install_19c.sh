#!/bin/bash

echo
echo 'INSTALLER: Client Install Started'
echo

#set environment variables in .bashrc
echo "export ORACLE_BASE=${ORACLE_BASE}" >> /home/oracle/.bashrc && \
echo "export ORACLE_HOME=${ORACLE_HOME}" >> /home/oracle/.bashrc && \



#unzip database client software and install configure database
cp ${SOFTWARE_HOME}/ora-response/client_install_19c.rsp.tmpl ${SOFTWARE_HOME}/ora-response/client_install_19c.rsp
sed -i -e "s|###ORA_INVENTORY###|${ORA_INVENTORY}|g" ${SOFTWARE_HOME}/ora-response/client_install_19c.rsp && \
sed -i -e "s|###ORACLE_HOME###|${ORACLE_HOME}|g" ${SOFTWARE_HOME}/ora-response/client_install_19c.rsp && \
sed -i -e "s|###ORACLE_BASE###|${ORACLE_BASE}|g" ${SOFTWARE_HOME}/ora-response/client_install_19c.rsp
export OC_BIN=${SOFTWARE_HOME}/${OC19C_UNZIP_HOME}/client
${OC_BIN}/runInstaller -silent -ignoreSysPrereqs -ignorePrereq -showProgress -waitForCompletion -responseFile ${SOFTWARE_HOME}/ora-response/client_install_19c.rsp
sleep 60
rm -f ${SOFTWARE_HOME}/ora-response/client_install_19c.rsp

echo
echo 'INSTALLER: Done'
echo

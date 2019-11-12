#/bin/bash

export DEPLOYMENT_HOME=/opt/app/oracle/gg_deployments/ServiceManager
export OGG_ETC_HOME=/opt/app/oracle/gg_deployments/ServiceManager/etc
export OGG_VAR_HOME=/opt/app/oracle/gg_deployments/ServiceManager/var

echo "Starting ServiceManager"

$DEPLOYMENT_HOME/bin/stopSM.sh

echo "Done"

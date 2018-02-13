#!/bin/bash

function __oah_remove {

# OAH_PROVISIONING_DIR="${OAH_DIR}/data/env/${OAH_CURRENT_CANDIDATE}/provisioning"
# ansible-playbook -i ${OAH_PROVISIONING_DIR}/inventory ${OAH_PROVISIONING_DIR}/ove-remove.yml

CURRENT_ENV=`find $OAH_DIR/data/env -mindepth 1 -maxdepth 1  -exec basename {} \;`
if [[ -n "$CURRENT_ENV" ]]
then
if [[ "$CURRENT_ENV" = "oah-vm" ]]
then
 echo "Current env is already the default oah-vm ,Nothing to remove . Skipping..."
else
 #TODO Check why roles are installed first.
 ansible-galaxy install -r $OAH_DIR/data/env/$CURRENT_ENV/provisioning/oah-requirements.yml -p $OAH_DIR/data/roles
 ansible-playbook $OAH_DIR/data/env/$CURRENT_ENV/provisioning/oah-remove.yml -K
 rm -rf $OAH_DIR/data/env/$CURRENT_ENV
fi
fi

}

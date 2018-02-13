#!/bin/bash
function __oah_install_env()
{
  env_repo_name=$OPTION2
  if [ "$env_repo_name" == "" ]; then
    echo Environment name is empty. Please specify which environment to install
    exit 1
  fi

  CURRENT_ENV=`find $OAH_DIR/data/env -mindepth 1 -maxdepth 1  -exec basename {} \;`
  if [ "$CURRENT_ENV" == "oah-vm" ]; then
    rm -rf $OAH_DIR/data/env/$CURRENT_ENV
  fi
  echo "installing the env"
  git_url=$OAH_HOST_REPO/$OAH_REPO_NAMESPACE/$env_repo_name.git
  env_base=$OAH_DIR/data/.envs/$env_repo_name
  git clone $git_url $env_base
  ansible-galaxy install -r $env_base/provisioning/oah-requirements.yml -p $OAH_DIR/data/roles
  ansible-playbook $env_base/provisioning/oah-install.yml -K
 # oah_ansible_log=`tail -1 /tmp/log1  | cut -d = -f 7`
  if [ $oah_ansible_log -eq 0 ];  then
    current_env=$OAH_DIR/data/env/$env_repo_name
    mkdir -p $current_env
    cp -r  $env_base/host           $current_env
    cp -r  $env_base/oah-config.yml $current_env
    cp -r  $env_base/provisioning   $current_env
    cp -r  $env_base/testing        $current_env
  fi
}

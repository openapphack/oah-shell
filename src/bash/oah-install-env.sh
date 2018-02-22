#!/bin/bash
function __oah_install_env()
{
  #TODO pass meaningful arg name istead of $OPTION2
  env_repo_name=$OPTION2
  echo "In Install Env using =>  $OAH_GITHUB_URL/$env_repo_name.git"

  if [ "$env_repo_name" == "" ]; then
    echo Environment name is empty. Please specify which environment to install
    exit 1
  fi

  CURRENT_ENV=`find $OAH_DIR/data/env -mindepth 1 -maxdepth 1  -exec basename {} \;`
  if [ "$CURRENT_ENV" == "oah-vm" ]; then
    rm -rf $OAH_DIR/data/env/$CURRENT_ENV
  fi

  echo "Installing the env => $env_repo_name"
  echo "Cloning $git_url =>  $env_base"
  git_url=$OAH_GITHUB_URL/$env_repo_name.git
  env_base=$OAH_DIR/data/.envs/$env_repo_name
  git clone $git_url $env_base

  # TODO should this be after current environment has been swapped?
  echo "Installing Ansible roles in $env_base/provisioning/oah-requirements.yml "
  ansible-galaxy install -r $env_base/provisioning/oah-requirements.yml -p $OAH_DIR/data/roles
  echo "Running Ansible playbook $env_base/provisioning/oah-install.yml "
  ansible-playbook $env_base/provisioning/oah-install.yml -K


  #oah_ansible_log=`tail -1 /tmp/log1  | cut -d = -f 7`
  echo "checking $oah_ansible_log  "
  if [ $oah_ansible_log -eq 0 ];  then

    current_env=$OAH_DIR/data/env/$env_repo_name
    echo "Creating New Current Env => $current_env"
    mkdir -p $current_env
    echo "Copying $env_base/host   => $current_env"
    cp -r $env_base/host           $current_env
    echo "Copying $env_base/provisioning   => $current_env"
    cp -r $env_base/provisioning   $current_env
    echo "Copying $env_base/tests   => $current_env"
    cp -r $env_base/tests          $current_env
    echo "Copying $env_base/oah-config.yml  => $current_env"
    cp $env_base/oah-config.yml    $current_env
    echo "Making default config  => $current_env/default.oah-config.yml"
    cp $env_base/oah-config.yml    $current_env/default.oah-config.yml
    echo "Done copying env from $env_base =>  $current_env"
  fi
}

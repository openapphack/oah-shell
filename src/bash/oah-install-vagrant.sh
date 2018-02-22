#!/bin/bash
function __oah_install_vagrant() {

  #TODO check $OPTION2 Value
  env_repo_name=$OPTION2

  echo "In Vagrant Install using env repo =>  $OAH_GITHUB_URL/$env_repo_name.git"

  echo " Parameters passed are => $@"
  # echo "Executing env!!"
  # env
  #
  # echo "Executing export -p"
  # export -p

  if [ "$env_repo_name" == "" ]; then
    echo Environment name is empty. Please specify which environment to install
    return 1
  fi
  env_base=$OAH_DIR/data/.envs/$env_repo_name
  current_env=$OAH_DIR/data/env/$env_repo_name

  # cleanup and clone
  echo "Cloning $git_url =>  $env_base"

  rm -rf $env_base
  git_url=$OAH_GITHUB_URL/$env_repo_name.git
  git clone $git_url $env_base

  # cleanup and update
  echo "Removing $OAH_DIR/data/env/*"

  rm -rf $OAH_DIR/data/env/*
  echo "Creating New Current Env => $current_env"
  mkdir $current_env
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

  # launch vm
  pushd $current_env/host/vagrant
  box_name=$(awk -F':' '/vagrant_box:/ { gsub(/^\s+|\s+$/, "", $2); print $2  }' ../../oah-config.yml)
  echo "Checking for vagrant box with name $box_name"

  vagrant box list | grep $box_name > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    box_url=$(awk -F':' '/vagrant_box_url:/ { gsub(/^\s+|\s+$/, "", $2); print $2  }' ../../oah-config.yml)
  echo "Checking for vagrant box_url with name $box_url"
    if [ "$box_url" == "" ]; then
      echo 'Vagrant box url not configured. Contact environment author.'
      return 1
    else
      curl --head -sf $box_url > /dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo 'Invalid or unreachable box url. Contact environment author.'
        return 1
      else
        echo "About to add vagrant box with box_url => $box_url"
        vagrant box add $box_url
        # this might fail too...lets worry about that later
      fi
    fi
  fi
  vagrant up
  popd
}

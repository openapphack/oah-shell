#!/bin/bash
function __oah_install_docker()
{
  #TODO check $OPTION2
  echo "In Install Docker for repo =>  $OPTION2"
  env_repo_name=$OPTION2
  if [ "$env_repo_name" == "" ]; then
    echo Environment name is empty. Please specify which environment to install
    exit 1
  fi
  echo "To be added "
}

__oah_start ()
{
  #TODO check $ARG3 and $ARG2

  oah_env_repo=$ARG3
  oah_operation_mode=$ARG2
  env_base_url=http://github.com/$OAH_NAMESPACE
  if [ "$oah_operation_mode" = "-s" ]
    then
    echo "About to start playbook in :  $env_base_url/$oah_env_repo.git"
    git clone $env_base_url/$oah_env_repo.git
    ansible-galaxy install -r $oah_env_repo/provisioning/requirements.yml
    ansible-playbook $oah_env_repo/provisioning/playbook.yml -K
  fi
}

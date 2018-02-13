#!/bin/bash

# TODO Review and refactor the code below
# function __oah_list {
# 	CANDIDATE="$1"
# 	__oah_check_candidate_present "${CANDIDATE}" || return 1
# 	__oah_build_version_csv "${CANDIDATE}"
# 	__oah_determine_current_version "${CANDIDATE}"
#
# 	if [[ "${OAH_AVAILABLE}" == "false" ]]; then
# 		__oah_offline_list
# 	else
# 		FRAGMENT=$(curl -s "${OAH_SERVICE}/candidates")
# 		echo "${FRAGMENT}"
# 		unset FRAGMENT
# 	fi
# }

function  __oah_list {
  echo "Select a OAH environment from this list :"
  OAH_CANDIDATES_CSV=$(curl -s "${OAH_ENVS_INFO_SERVICE}" | grep -v ^# )
  OAH_CANDIDATES=(${OAH_CANDIDATES_CSV})
  #IFS="$OLD_IFS"
  for (( i=0; i <= ${#OAH_CANDIDATES}; i++ )); do
    # Eliminate empty entries due to incompatibility
    if [[ -n ${OAH_CANDIDATES[${i}]} ]]; then
      CANDIDATE_NAME="${OAH_CANDIDATES[${i}]}"
      cut_field=$(echo  "$CANDIDATE_NAME" |grep -o ,| wc -l)
      if [ "${cut_field}" -eq 0 ];
      then
        Env_name=$(echo "$CANDIDATE_NAME")
        Version_name="master"
      else
        cut_field_1=$[cut_field + 1]
        Env_name=$(echo  "$CANDIDATE_NAME" |cut -f1 -d',')
        Version_name_old=$(echo  "$CANDIDATE_NAME" |cut -f2-$cut_field_1 -d',')
        # Version_name=$(echo "$Version_name_old*")
        version_cut_field=$(echo  "$Version_name_old" |grep -o ,| wc -l)
        #echo "version_cut_field=(echo  Version_name_old |grep -o ,| wc -l) is $version_cut_field"
        if [[ "${version_cut_field}" -eq 0 ]];
        then
          Version_name=$(echo "*$Version_name_old")
        else
          cut_field_2=$[version_cut_field + 1]
          Version_name_1=$(echo  "$Version_name_old" |cut -f1-$version_cut_field -d',')
          #echo "Version_name_1=(echo  Version_name_old |cut -f1-version_cut_field -d',') is $Version_name_1"
          Version_name_2=$(echo  "$Version_name_old" |cut -f$cut_field_2 -d',')
          #echo "Version_name_2=(echo  Version_name_old |cut -fcut_field_2 -d',') is $Version_name_2"
          Version_name=$(echo $Version_name_1,*$Version_name_2 )
        fi
      fi
      current_env=$(oah show current)
      Version_new=$(echo "$current_env" | grep -w "$Env_name")
      if [[ -n "${Version_new}" ]];
      then
        Env_name=$(echo ">$Version_new")
      fi
      echo "$Env_name [$Version_name]"
      unset CANDIDATE_NAME
    fi
  done
}

# TODO Review and refactor this code below
# function __oah_build_version_csv {
# 	CANDIDATE="$1"
# 	CSV=""
# 	for version in $(find "${OAH_DIR}/data/.envs/${CANDIDATE}" -maxdepth 1 -mindepth 1 -exec basename '{}' \; | sort); do
# 		if [[ "${version}" != 'current' ]]; then
# 			CSV="${version},${CSV}"
# 		fi
# 	done
# 	CSV=${CSV%?}
# }
#
# function __oah_offline_list {
# 	echo "------------------------------------------------------------"
# 	echo "Offline Mode: only showing installed ${CANDIDATE} versions"
# 	echo "------------------------------------------------------------"
# 	echo "                                                            "
#
# 	oah_versions=($(echo ${CSV//,/ }))
# 	for (( i=0 ; i <= ${#oah_versions} ; i++ )); do
# 		if [[ -n "${oah_versions[${i}]}" ]]; then
# 			if [[ "${oah_versions[${i}]}" == "${CURRENT}" ]]; then
# 				echo -e " > ${oah_versions[${i}]}"
# 			else
# 				echo -e " * ${oah_versions[${i}]}"
# 			fi
# 		fi
# 	done
#
# 	if [[ -z "${oah_versions[@]}" ]]; then
# 		echo "   None installed!"
# 	fi
#
# 	echo "------------------------------------------------------------"
# 	echo "* - installed                                               "
# 	echo "> - currently in use                                        "
# 	echo "------------------------------------------------------------"
#
# 	unset CSV oah_versions
# }
#

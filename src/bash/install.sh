#!/bin/bash

OAH_NAMESPACE=${OAH_NAMESPACE:=openapphack}
OAH_ROOT=${OAH_ROOT:="$HOME"}
OAH_DIR="$OAH_ROOT/.oah"
OAH_HOST_SERVER=${OAH_HOST_SERVER:=https://raw.githubusercontent.com}

# Global variables
OAH_INSTALLER_SERVICE="${OAH_HOST_SERVER}/${OAH_NAMESPACE}/oah-installer/master"
OAH_GITHUB_URL=http://github.com/$OAH_NAMESPACE

#OAH meta data service for validated OAH environments

OAH_ENVS_INFO_SERVICE="${OAH_INSTALLER_SERVICE}/envsinfo/candidates.txt"
OAH_BROADCAST_SERVICE="${OAH_INSTALLER_SERVICE}/broadcast/"
OAH_VERSION_SERVICE="$OAH_INSTALLER_SERVICE/VERSION"
OAH_VERSION=$(curl -s $OAH_VERSION_SERVICE)
OAH_VERSION=${OAH_VERSION:=0.0.1-a1}

# Local variables
oah_bin_folder="${OAH_DIR}/bin"
oah_src_folder="${OAH_DIR}/src"
oah_tmp_folder="${OAH_DIR}/tmp"
oah_stage_folder="${oah_tmp_folder}/stage"
oah_zip_file="${oah_tmp_folder}/res-${OAH_VERSION}.zip"
oah_etc_folder="${OAH_DIR}/data/etc"
oah_var_folder="${OAH_DIR}/data/var"
oah_current_env_folder="${OAH_DIR}/data/env/"
oah_dotenvs_folder="${OAH_DIR}/data/.envs/"
oah_config_file="${oah_etc_folder}/config"
oah_bash_profile="${HOME}/.bash_profile"
oah_profile="${HOME}/.profile"
oah_bashrc="${HOME}/.bashrc"
oah_platform=$(uname)



# OS specific support (must be 'true' or 'false').
cygwin=false;
darwin=false;
solaris=false;
freebsd=false;
case "$(uname)" in
    CYGWIN*)
        cygwin=true
        ;;
    Darwin*)
        darwin=true
        ;;
    SunOS*)
        solaris=true
        ;;
    FreeBSD*)
        freebsd=true
esac

echo '                                                                     '
echo 'Thanks for using     OpenAppHack(OAH SHELL)                          '
echo '                                                                     '
echo '                                                                     '
echo '                                       Will now attempt installing...'
echo '                                                                     '


function check_command() {
  cmd="$1"
  echo "Looking for $cmd..."
  if [ -z $(which $cmd) ]; then
      cat <<EOF
Not found.
================================================================================
Please install $cmd on your system using your favourite package manager.

Restart after installing $cmd.
================================================================================
EOF
      exit 0
  fi
}


function downloadScripts() {
  echo "Download script archive..."

  archive_downloaded=n
  for ref in $OAH_VERSION master; do
    #https://github.com/openapphack/oah-shell/archive/0.0.1-1.zip
    oah_version_url="$OAH_GITHUB_URL/oah-shell/archive/$ref.zip"
    oah_zip_file=$OAH_DIR/tmp/oah-$ref.zip
    echo "Fetching $oah_version_url"
    if curl -s -f --head $oah_version_url > /dev/null 2>&1; then
      curl -s -o $oah_zip_file -L "$oah_version_url"
      archive_downloaded=y
      echo "Got $oah_zip_file"
      break;
    fi
  done

  if [ $archive_downloaded == "n" ]; then
    echo 'Failed to download script archive. Please check your network connectivity'
    exit 1
  fi

  echo "Extract script archive..."
  oah_stage_folder=$OAH_DIR/tmp/stage
  if [[ "${cygwin}" == 'true' ]]; then
    echo "Cygwin detected - normalizing paths for unzip..."
    oah_zip_file=$(cygpath -w "${oah_zip_file}")
    oah_stage_folder=$(cygpath -w "${oah_stage_folder}")
  fi
  unzip -qo "${oah_zip_file}" -d "${oah_stage_folder}"
  zip_base_dir=$(unzip -l $oah_zip_file | grep '/$' | head -n 1 | awk '{ gsub("/", "", $4); print $4 }')
  echo "Staging Folder => $oah_stage_folder"
  echo "Zip Base Dir => $zip_base_dir"
  echo "Install scripts..."
  mv $oah_stage_folder/$zip_base_dir/src/bash/oah-init.sh $OAH_DIR/bin
  mv $oah_stage_folder/$zip_base_dir/src/bash/oah-* $OAH_DIR/src
  rm -fr $oah_stage_folder/$zip_base_dir >/dev/null 2>&1
}

# Sanity checks

echo "Looking for a previous installation of OAH..."
if [ -d "${OAH_DIR}" ]; then
	echo "OAH found."
	echo ""
	echo "======================================================================================================"
	echo " You already have OAH installed."
	echo " OAH was found at:"
	echo ""
	echo "    ${OAH_DIR}"
	echo ""
	echo " Please consider running the following if you need to upgrade."
	echo ""
	echo "    $ oah selfupdate"
	echo ""
	echo "======================================================================================================"
	echo ""
	exit 0
fi

#TODO check for vagrant only if OAH_HOST_MODE is host
# valid OAH_HOST_MODE are host,remote,client and standalone.
# vagant is required to host and remote mode.

#OAH_HOST_MODE=${OAH_HOST_MODE:=standalone}

#if [[ $OAH_HOST_MODE in host remote ]] then
#    check_command vagrant
#fi

#for cmd in unzip curl sed awk git vagrant; do
for cmd in unzip curl sed awk git ; do
  check_command $cmd
done

# echo "Looking for git..."
# if [ -z $(which git) ]; then
# 	echo "Not found."
# 	echo "======================================================================================================"
# 	echo " Please install git on your system using your favourite package manager."
# 	echo ""
# 	echo " Restart after installing git."
# 	echo "======================================================================================================"
# 	echo ""
# 	exit 0
# fi
#
# echo "Looking for vagrant..."
# if [ -z $(which vagrant) ]; then
# 	echo "Not found."
# 	echo ""
# 	echo "======================================================================================================"
# 	echo " Please install vagrant on your system ."
# 	echo ""
# 	echo " OAH uses vagrant extensively."
# 	echo ""
# 	echo " Restart after installing vagrant."
# 	echo "======================================================================================================"
# 	echo ""
# 	exit 0
# fi
#
# echo "Looking for unzip..."
# if [ -z $(which unzip) ]; then
# 	echo "Not found."
# 	echo "======================================================================================================"
# 	echo " Please install unzip on your system using your favourite package manager."
# 	echo ""
# 	echo " Restart after installing unzip."
# 	echo "======================================================================================================"
# 	echo ""
# 	exit 0
# fi
#
# echo "Looking for curl..."
# if [ -z $(which curl) ]; then
# 	echo "Not found."
# 	echo ""
# 	echo "======================================================================================================"
# 	echo " Please install curl on your system using your favourite package manager."
# 	echo ""
# 	echo " OAH uses curl for crucial interactions with it's backend server."
# 	echo ""
# 	echo " Restart after installing curl."
# 	echo "======================================================================================================"
# 	echo ""
# 	exit 0
# fi
#
# echo "Looking for sed..."
# if [ -z $(which sed) ]; then
# 	echo "Not found."
# 	echo ""
# 	echo "======================================================================================================"
# 	echo " Please install sed on your system using your favourite package manager."
# 	echo ""
# 	echo " OAH uses sed extensively."
# 	echo ""
# 	echo " Restart after installing sed."
# 	echo "======================================================================================================"
# 	echo ""
# 	exit 0
# fi




echo "Installing oah scripts..."


# Create directory structure

# echo "Create distribution directories..."
# mkdir -p "${oah_bin_folder}"
# mkdir -p "${oah_src_folder}"
# mkdir -p "${oah_tmp_folder}"
# mkdir -p "${oah_stage_folder}"
# mkdir -p "${oah_ext_folder}"
# mkdir -p "${oah_etc_folder}"
# mkdir -p "${oah_var_folder}"
# mkdir -p "${oah_current_env_folder}"
# mkdir -p "${oah_dotenvs_folder}"


# Create directory structure
echo "Create distribution directories..."
for dir in bin src ext var tmp tmp/stage data data/etc data/env data/.envs; do
  mkdir -p $OAH_DIR/$dir
done

echo "Create candidate directories..."

# OAH_CANDIDATES_CSV=$(curl -s "${OAH_ENVS_INFO_SERVICE}")
# echo "$OAH_CANDIDATES_CSV" > "${OAH_DIR}/data/var/candidates"
#
# echo "$OAH_VERSION" > "${OAH_DIR}/data/var/version"
#
# # convert csv to array
# OLD_IFS="$IFS"
# IFS=","
# OAH_CANDIDATES=(${OAH_CANDIDATES_CSV})
# IFS="$OLD_IFS"
#
# for (( i=0; i <= ${#OAH_CANDIDATES}; i++ )); do
# 	# Eliminate empty entries due to incompatibility
# 	if [[ -n ${OAH_CANDIDATES[${i}]} ]]; then
# 		CANDIDATE_NAME="${OAH_CANDIDATES[${i}]}"
# 		mkdir -p "${OAH_DIR}/data/.envs/${CANDIDATE_NAME}"
# 		echo "Created for ${CANDIDATE_NAME}: ${OAH_DIR}/data/.envs/${CANDIDATE_NAME}"
# 		unset CANDIDATE_NAME
# 	fi
# done

OAH_CANDIDATES_CSV=$(curl -s "${OAH_ENVS_INFO_SERVICE}")
echo "$OAH_CANDIDATES_CSV" > "${OAH_DIR}/var/candidates"

echo "$OAH_VERSION" > "${OAH_DIR}/var/version"

# convert csv to array
#OLD_IFS="$IFS"
#IFS=","
OAH_CANDIDATES=(${OAH_CANDIDATES_CSV})
#IFS="$OLD_IFS"

#for (( i=0; i <= ${#OVE_CANDIDATES}; i++ )); do
  # Eliminate empty entries due to incompatibility
# if [[ -n ${OVE_CANDIDATES[${i}]} ]]; then
#   CANDIDATE_NAME="${OVE_CANDIDATES[${i}]}"
#   mkdir -p "${OVE_DIR}/data/.envs/${CANDIDATE_NAME}"
#   echo "Created for ${CANDIDATE_NAME}: ${OVE_DIR}/data/.envs/${CANDIDATE_NAME}"
#   unset CANDIDATE_NAME
# fi
#done

echo "Prime the config file..."
cat <<EOF > $OAH_DIR/data/etc/config
oah_auto_answer=false
oah_auto_selfupdate=false
oah_insecure_ssl=false
EOF

# echo "Prime the config file..."
# touch "${oah_config_file}"
# echo "oah_auto_answer=false" >> "${oah_config_file}"
# echo "oah_auto_selfupdate=false" >> "${oah_config_file}"
# echo "oah_insecure_ssl=false" >> "${oah_config_file}"

echo "Download script archive..."
#https://github.com/openapphack/oah/raw/gh-pages/
# curl -s "${OAH_INSTALLER_SERVICE}/res/oah-cli-scripts.zip" > "${oah_zip_file}"

# TODO if release not found set OAH_SRC and install from source


if [  "$OAH_SRC" != "" ]; then
  echo "Installing from source"
  cp $OAH_SRC/src/bash/oah-* $OAH_DIR/src
  mv $OAH_DIR/src/oah-init.sh $OAH_DIR/bin
else
  downloadScripts
fi

cat <<EOF > $HOME/.ansible.cfg
# Set the roles path and inventory path
[defaults]
roles_path=$OAH_DIR/data/roles
inventory=$OAH_DIR/data/inventory
log_path=$OAH_DIR/tmp/ansiblelog
EOF
cat <<EOF > $OAH_DIR/data/inventory
[all]
127.0.0.1              ansible_connection=local
EOF

if [ "$OAH_PROFILE_UPDATE" == "n" ]; then
  echo Skipping profile update
else
  echo "Attempt update of bash profiles..."
  oah_bash_profile="${HOME}/.bash_profile"
  oah_profile="${HOME}/.profile"
  oah_bashrc="${HOME}/.bashrc"
  oah_platform=$(uname)

oah_init_snippet=$( cat << EOF
#THIS MUST BE AT THE END OF THE FILE FOR OAH TO WORK!!!
export OAH_DIR="$HOME/.oah"

[[ -s "${OAH_DIR}/bin/oah-init.sh" ]] && source "${OAH_DIR}/bin/oah-init.sh"
EOF
)

if [ ! -f "${oah_bash_profile}" -a ! -f "${oah_profile}" ]; then
  echo "#!/bin/bash" > "${oah_bash_profile}"
  echo "${oah_init_snippet}" >> "${oah_bash_profile}"
  echo "Created and initialised ${oah_bash_profile}"
else
  if [ -f "${oah_bash_profile}" ]; then
    if [[ -z `grep 'oah-init.sh' "${oah_bash_profile}"` ]]; then
      echo -e "\n${oah_init_snippet}" >> "${oah_bash_profile}"
      echo "Updated existing ${oah_bash_profile}"
    fi
  fi

  if [ -f "${oah_profile}" ]; then
    if [[ -z `grep 'oah-init.sh' "${oah_profile}"` ]]; then
      echo -e "\n${oah_init_snippet}" >> "${oah_profile}"
      echo "Updated existing ${oah_profile}"
    fi
  fi
fi

if [ ! -f "${oah_bashrc}" ]; then
  cat <<EOF > "${oah_bashrc}"
#!/bin/bash
${oah_init_snippet}
EOF
  echo "Created and initialised ${oah_bashrc}"
else
  if [[ -z `grep 'oah-init.sh' "${oah_bashrc}"` ]]; then
    echo -e "\n${oah_init_snippet}" >> "${oah_bashrc}"
    echo "Updated existing ${oah_bashrc}"
  fi
fi
fi


# echo "Extract script archive..."
# if [[ "${cygwin}" == 'true' ]]; then
# 	echo "Cygwin detected - normalizing paths for unzip..."
# 	oah_zip_file=$(cygpath -w "${oah_zip_file}")
# 	oah_stage_folder=$(cygpath -w "${oah_stage_folder}")
# fi
# unzip -qo "${oah_zip_file}" -d "${oah_stage_folder}"
#
# echo "Install scripts..."
# mv "${oah_stage_folder}/oah-init.sh" "${oah_bin_folder}"
# mv "${oah_stage_folder}"/oah-* "${oah_src_folder}"
#
# echo "Attempt update of bash profiles..."
# if [ ! -f "${oah_bash_profile}" -a ! -f "${oah_profile}" ]; then
# 	echo "#!/bin/bash" > "${oah_bash_profile}"
# 	echo "${oah_init_snippet}" >> "${oah_bash_profile}"
# 	echo "Created and initialised ${oah_bash_profile}"
# else
# 	if [ -f "${oah_bash_profile}" ]; then
# 		if [[ -z `grep 'oah-init.sh' "${oah_bash_profile}"` ]]; then
# 			echo -e "\n${oah_init_snippet}" >> "${oah_bash_profile}"
# 			echo "Updated existing ${oah_bash_profile}"
# 		fi
# 	fi
#
# 	if [ -f "${oah_profile}" ]; then
# 		if [[ -z `grep 'oah-init.sh' "${oah_profile}"` ]]; then
# 			echo -e "\n${oah_init_snippet}" >> "${oah_profile}"
# 			echo "Updated existing ${oah_profile}"
# 		fi
# 	fi
# fi
#
# if [ ! -f "${oah_bashrc}" ]; then
# 	echo "#!/bin/bash" > "${oah_bashrc}"
# 	echo "${oah_init_snippet}" >> "${oah_bashrc}"
# 	echo "Created and initialised ${oah_bashrc}"
# else
# 	if [[ -z `grep 'oah-init.sh' "${oah_bashrc}"` ]]; then
# 		echo -e "\n${oah_init_snippet}" >> "${oah_bashrc}"
# 		echo "Updated existing ${oah_bashrc}"
# 	fi
# fi


# echo -e "\n\n\nAll done!\n\n"
#
# echo "Please open a new terminal, or run the following in the existing one:"
# echo ""
# echo "    source \"${OAH_DIR}/bin/oah-init.sh\""
# echo ""
# echo "Then issue the following command:"
# echo ""
# echo "    oah help"
# echo ""
# echo "Enjoy!!!"

cat <<EOF

All done!

Please open a new terminal, or run the following in the existing one:

    source "${OAH_DIR}/bin/oah-init.sh"

Then issue the following command:

    oah help

Enjoy!!
EOF

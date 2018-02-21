#!/bin/bash

export OAH_NAMESPACE=${OAH_NAMESPACE:=openapphack}
export OAH_ROOT=${OAH_ROOT:="$HOME"}
export OAH_DIR="$OAH_ROOT/.oah"
export OAH_HOST_SERVER=${OAH_HOST_SERVER:=https://raw.githubusercontent.com}

function oah_export {
  oah_gobal_var=$1
  oah_gobal_val=$2
  if [ -z $export_var ]; then
    export $oah_gobal_var=$oah_gobal_val
  fi
}


# Global variables
oah_export OAH_INSTALLER_SERVICE "${OAH_HOST_SERVER}/${OAH_NAMESPACE}/oah-installer/master"
oah_export OAH_GITHUB_URL http://github.com/$OAH_NAMESPACE

#OAH meta data service for validated OAH environments

oah_export OAH_ENVS_INFO_SERVICE "${OAH_INSTALLER_SERVICE}/envsinfo/candidates.txt"
oah_export OAH_BROADCAST_SERVICE "${OAH_INSTALLER_SERVICE}/broadcast/"
oah_export OAH_VERSION_SERVICE "$OAH_INSTALLER_SERVICE/VERSION"
oah_export OAH_VERSION $(cat $OAH_DIR/var/version)
oah_export OAH_PLATFORM $(uname)

if [[ -n "$OAH_DEBUG_MODE" ]]; then
   echo "Debug_mode set to => $OAH_DEBUG_MODE "
   export | grep OAH
fi

# force zsh to behave well
if [[ -n "$ZSH_VERSION" ]]; then
	setopt shwordsplit
fi

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

# For Cygwin, ensure paths are in UNIX format before anything is touched.
if ${cygwin} ; then
    [ -n "${JAVACMD}" ] && JAVACMD=$(cygpath --unix "${JAVACMD}")
    [ -n "${JAVA_HOME}" ] && JAVA_HOME=$(cygpath --unix "${JAVA_HOME}")
    [ -n "${CP}" ] && CP=$(cygpath --path --unix "${CP}")
fi


OFFLINE_BROADCAST=$( cat << EOF
==== BROADCAST =============================================

OFFLINE MODE ENABLED! Some functionality is now disabled.

============================================================
EOF
)

ONLINE_BROADCAST=$( cat << EOF
==== BROADCAST =============================================

ONLINE MODE RE-ENABLED! All functionality now restored.

============================================================
EOF
)

OFFLINE_MESSAGE="This command is not available in offline mode."

# fabricate list of candidates
echo " Looking for candidates from => ${OAH_DIR}/var/candidates"

if [[ -f "${OAH_DIR}/var/candidates" ]]; then
	OAH_CANDIDATES_CSV=$(cat "${OAH_DIR}/var/candidates")
else
  echo " Fetching candidates from => ${OAH_ENVS_INFO_SERVICE} "
	OAH_CANDIDATES_CSV=$(curl -s "${OAH_ENVS_INFO_SERVICE}")
	echo "$OAH_CANDIDATES_CSV" > "${OAH_DIR}/var/candidates"
fi



# Set the candidate array
OLD_IFS="$IFS"
IFS=","
OAH_CANDIDATES=(${OAH_CANDIDATES_CSV})
IFS="$OLD_IFS"

# Source oah module scripts.
for f in $(find "${OAH_DIR}/src" -type f -name 'oah-*' -exec basename {} \;); do
    source "${OAH_DIR}/src/${f}"
done

# Source extension files prefixed with 'oah-' and found in the ext/ folder
# Use this if extensions are written with the functional approach and want
# to use functions in the main oah script.
for f in $(find "${OAH_DIR}/ext" -type f -name 'oah-*' -exec basename {} \;); do
    source "${OAH_DIR}/ext/${f}"
done
unset f

# Attempt to set JAVA_HOME if it's not already set.
# if [ -z "${JAVA_HOME}" ] ; then
#     if ${darwin} ; then
#         [ -z "${JAVA_HOME}" -a -f "/usr/libexec/java_home" ] && export JAVA_HOME=$(/usr/libexec/java_home)
#         [ -z "${JAVA_HOME}" -a -d "/Library/Java/Home" ] && export JAVA_HOME="/Library/Java/Home"
#         [ -z "${JAVA_HOME}" -a -d "/System/Library/Frameworks/JavaVM.framework/Home" ] && export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
#     else
#         javaExecutable="$(which javac 2> /dev/null)"
#         [[ -z "${javaExecutable}" ]] && echo "OAH: JAVA_HOME not set and cannot find javac to deduce location, please set JAVA_HOME." && return
#
#         readLink="$(which readlink 2> /dev/null)"
#         [[ -z "${readLink}" ]] && echo "OAH: JAVA_HOME not set and readlink not available, please set JAVA_HOME." && return
#
#         javaExecutable="$(readlink -f "${javaExecutable}")"
#         javaHome="$(dirname "${javaExecutable}")"
#         javaHome=$(expr "${javaHome}" : '\(.*\)/bin')
#         JAVA_HOME="${javaHome}"
#         [[ -z "${JAVA_HOME}" ]] && echo "OAH: could not find java, please set JAVA_HOME" && return
#         export JAVA_HOME
#     fi
# fi

# Load the oah config if it exists.
if [ -f "${OAH_DIR}/etc/config" ]; then
	source "${OAH_DIR}/etc/config"
fi

# Create upgrade delay token if it doesn't exist
echo "Checking upgrade delay flag :${OAH_DIR}/var/delay_upgrade "
if [[ ! -f "${OAH_DIR}/var/delay_upgrade" ]]; then
	touch "${OAH_DIR}/var/delay_upgrade"
fi

# determine if up to date
OAH_VERSION_TOKEN="${OAH_DIR}/var/version"
echo "Checking Remote version token :${OAH_DIR}/var/version "
if [[ -f "$OAH_VERSION_TOKEN" && -z "$(find "$OAH_VERSION_TOKEN" -mmin +$((60*24)))" ]]; then
    OAH_REMOTE_VERSION=$(cat "$OAH_VERSION_TOKEN")
else
    echo "Checking Remote version URL :${OAH_INSTALLER_SERVICE}/oah/version "
    OAH_REMOTE_VERSION=$(curl -s "${OAH_INSTALLER_SERVICE}/oah/version" --connect-timeout 1 --max-time 1)
    oah_force_offline_on_proxy "$OAH_REMOTE_VERSION"
    if [[ -z "$OAH_REMOTE_VERSION" || "$OAH_FORCE_OFFLINE" == 'true' ]]; then
        OAH_REMOTE_VERSION="$OAH_VERSION"
    else
        echo ${OAH_REMOTE_VERSION} > "$OAH_VERSION_TOKEN"
    fi
fi

# initialise once only
if [[ "${OAH_INIT}" != "true" ]]; then
    # # Build _HOME environment variables and prefix them all to PATH
    #
    # # The candidates are assigned to an array for zsh compliance, a list of words is not iterable
    # # Arrays are the only way, but unfortunately zsh arrays are not backward compatible with bash
    # # In bash arrays are zero index based, in zsh they are 1 based(!)
    # for (( i=0; i <= ${#OAH_CANDIDATES}; i++ )); do
    #     # Eliminate empty entries due to incompatibility
    #     if [[ -n ${OAH_CANDIDATES[${i}]} ]]; then
    #         CANDIDATE_NAME="${OAH_CANDIDATES[${i}]}"
    #         CANDIDATE_HOME_VAR="$(echo ${CANDIDATE_NAME} | tr '[:lower:]' '[:upper:]')_HOME"
    #         CANDIDATE_DIR="${OAH_DIR}/.vms/${CANDIDATE_NAME}/current"
    #         export $(echo ${CANDIDATE_HOME_VAR})="$CANDIDATE_DIR"
    #         PATH="${CANDIDATE_DIR}/bin:${PATH}"
    #         unset CANDIDATE_HOME_VAR
    #         unset CANDIDATE_NAME
    #         unset CANDIDATE_DIR
    #     fi
    # done
    # unset i
    # export PATH

    export OAH_INIT="true"
fi

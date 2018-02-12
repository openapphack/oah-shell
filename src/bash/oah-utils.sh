#!/bin/bash

function __oah_echo_debug {
	if [[ "$oah_debug_mode" == 'true' ]]; then
		echo "$1"
	fi
}

function __oah_secure_curl {
	if [[ "${oah_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location "$1"
	else
		curl --silent --location "$1"
	fi
}

function __oah_secure_curl_download {
	local curl_params="--progress-bar --location"
	if [[ "${oah_insecure_ssl}" == 'true' ]]; then
		curl_params="$curl_params --insecure"
	fi

	local cookie_file="${OAH_DIR}/var/cookie"

	if [[ -f "$cookie_file" ]]; then
		local cookie=$(cat "$cookie_file")
		curl_params="$curl_params --cookie $cookie"
	fi

	curl ${curl_params} "$1"
}

function __oah_secure_curl_with_timeouts {
	if [[ "${oah_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location --connect-timeout ${oah_curl_connect_timeout} --max-time ${oah_curl_max_time} "$1"
	else
		curl --silent --location --connect-timeout ${oah_curl_connect_timeout} --max-time ${oah_curl_max_time} "$1"
	fi
}

function __oah_page {
	if [[ -n "$PAGER" ]]; then
		"$@" | $PAGER
	elif command -v less >& /dev/null; then
		"$@" | less
	else
		"$@"
	fi
}

function __oah_echo {
	if [[ "$oah_colour_enable" == 'false' ]]; then
		echo -e "$2"
	else
		echo -e "\033[1;$1$2\033[0m"
	fi
}

function __oah_echo_red {
	__oah_echo "31m" "$1"
}

function __oah_echo_no_colour {
	echo "$1"
}

function __oah_echo_yellow {
	__oah_echo "33m" "$1"
}

function __oah_echo_green {
	__oah_echo "32m" "$1"
}

function __oah_echo_cyan {
	__oah_echo "36m" "$1"
}

function __oah_echo_confirm {
	if [[ "$oah_colour_enable" == 'false' ]]; then
		echo -n "$1"
	else
		echo -e -n "\033[1;33m$1\033[0m"
	fi
}

#!/bin/bash


function __oah_offline {
	if [[ "$1" == "enable" ]]; then
		OAH_FORCE_OFFLINE="true"
		echo "Forced offline mode enabled."
	fi
	if [[ "$1" == "disable" ]]; then
		OAH_FORCE_OFFLINE="false"
		OAH_ONLINE="true"
		echo "Online mode re-enabled!"
	fi
}

function oah_determine_offline {
    local input="$1"
	if [[ -z "$input" ]]; then
		OAH_ONLINE="false"
		OAH_AVAILABLE="false"
	else
		OAH_ONLINE="true"
	fi
}

function oah_force_offline_on_proxy {
	local response="$1"
	local detect_html="$(echo "$response" | tr '[:upper:]' '[:lower:]' | grep 'html')"
	if [[ -n "$detect_html" ]]; then
		echo "OAH can't reach the internet so going offline. Re-enable online with:"
		echo ""
		echo "  $ app offline disable"
		echo ""
		OAH_FORCE_OFFLINE="true"
    else
        OAH_FORCE_OFFLINE="false"
	fi
}

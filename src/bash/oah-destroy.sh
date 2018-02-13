#!/bin/bash

function __oah_destroy {
	environment="$1"

	# Check if the ENV is ove status


	if [ -n "$environment" ]
	then
	  vagrant destroy $environment
	else
	  echo "Unable to destroy the environment"
	  echo "Please check the status  with oah status and  provide vagrant id  "
	  echo "Format is "oah destroy 'id'""
	fi
}

#!/bin/bash

function __oah_halt {
	vagrant halt
	if [ $? -eq 1 ]
	then
	echo "###########################################################################################################"
	echo "#                                                                                                         #"
	echo "#Run "oah status" and  switch to the vagrant directory of the oah env  you want to halt and run oah halt###"
	echo "#                                                                                                         #"
	echo "###########################################################################################################"
	fi
}

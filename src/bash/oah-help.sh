#!/bin/bash



function __oah_help {
	cat <<EOF
Install with ove:
Usage:  oah install [option(-v,-d,-s)] {imagename}
 Options
 -v vagrant // will be used for testing and creation of cluster

-s standalone machine / will make use of localhost as inventory

  Example : To Install Drupal8  on a Windows host with vagrant and Virtualbox:
 oah install -v oah-drupal8-vm


List the VMs available:
oah list

 Show the status of the  environmant through vagrant:
oah status

Show the  environments installed on the vm:
oah show

Show the  current environment installed on the vm:
oah show  current

Reset- Resets the environment back:
oah reset - run from the guest

Remove- Remove all the installed environment and make it as a base machine:
oah remove - run from guest

Destroy the guest:
oah destroy [machine id]}

Provision the vm - Run this if the ove install options fails in between:
oah provision

Halt a guest:
oah halt

EOF
}

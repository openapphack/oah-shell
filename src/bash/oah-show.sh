#!/bin/bash
# List the installed roles on the client, envs {vm/cluster} on the host
# Use * to show the current installed env , ~ for missing remote env, color code green/Red ,
function __oah_show {
  echo "The installed environments are:"
  find $OAH_DIR/data/.envs -mindepth 1 -maxdepth 1  -exec basename {} \;
}

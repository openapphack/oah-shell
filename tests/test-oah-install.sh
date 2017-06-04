oah_quick_test=true
oah_test_tmp_dir=../tmp

dummy_candidates_snippet=$( cat << EOF
oah-vm,0.0.1-a1,
oah-dev-vm,0.0.1-a1,
oah-drupal8-vm,0.0.1-a1,
oah-drupal7-vm,0.0.1-a1,
oah-java8-vm,0.0.1-a1,
oah-nodejs4.3-vm,0.0.1-a1,
oah-health-vm,0.0.1-a1,
oah-store-vm,0.0.1-a1,
oah-ram-vm,0.0.1-a1,
oah-hackathon-vm,0.0.1-a1,
EOF
)

dummy_broadcast_snippet=$( cat << EOF
"Welcome to OAH Broadcast"
EOF
)

dummy_latest_snippet=$( cat << EOF
"We are working on alpha 0.0.1-a1"
EOF
)



function generate_metadata {
  mkdir -p envsinfo

  touch "envsinfo/candidates.txt"
  	echo "${dummy_candidates_snippet}" >> "envsinfo/candidates.txt"

  mkdir -p broadcast

  touch "broadcast/broadcast.txt"
    echo "${dummy_broadcast_snippet}" >> "broadcast/broadcast.txt"

  touch "broadcast/latest.txt"
    echo "${dummy_latest_snippet}" >> "broadcast/latest.txt"

}

function fetch_metadata {

  "git clone "
}
# mkdir tmp directory
mkdir -p $oah_test_tmp_dir
# cd tmp directory
cd $oah_test_tmp_dir

if [ $oah_quick_test = true ] ; then
 generate_metadata
else
 fetch_metadata
fi

# start python server
#process_id
echo "python -m SimpleHttpServer 8088 "


# test local candidate file

echo "curl http://localhost:8088/envsinfo/candidate.txt | grep ove-vm"

# set env variable
# OAH_ROOT =./tmp/
# OAH_INSTALLER_SERVICE=http:/localhost:8088

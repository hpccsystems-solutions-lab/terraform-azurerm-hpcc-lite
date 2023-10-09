#!/bin/bash
#========================================================================
function assert_fail () {
    echo ">>>>>>>>>>>>>>>>>>> EXECUTING: $*"
    if "$@"; then
        echo;echo ">>>>>>>>>>>>>>>>>>> Successful: $*";echo
    else
        echo;echo ">>>>>>>>>>>>>>>>>>> FAILED: $*. EXITING!";echo
	rm -vr data
        exit 1
    fi
}
#========================================================================

cd $1;
name=$(basename `pwd`)
if [ "$name" == "hpcc" ];then
  if [ -e "../lite.auto.tfvars" ];then
    cp -v ../lite.auto.tfvars .
  else
    echo "ERROR: The file 'lite.auto.tfvars' file must exist in the root directory and it does not. So, we exit with an error."
    exit 1
  fi
fi
plan=`/home/azureuser/mkplan ${name}_deployment.plan`
if [ -d "data" ] && [ -f "data/config.json" ]; then echo "Complete! $name is already deployed";exit 0; fi
echo "=============== Deploy $name. Executing 'terraform init' ===============";
assert_fail terraform init 
echo "=============== Deploy $name. Executing 'terraform plan -out=$plan' ===============";
assert_fail terraform plan -out=$plan
echo "=============== Deploy $name. Executing 'terraform apply $plan'  ===============";
assert_fail terraform apply $plan

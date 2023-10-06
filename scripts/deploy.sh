#!/bin/bash
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
echo "=============== Deploying $name. Executing 'terraform init' ===============";
terraform init 
echo "=============== Deploying $name. Executing 'terraform plan -out=$plan' ===============";
terraform plan -out=$plan
echo "=============== Deploying $name. Executing 'terraform apply $plan'  ===============";
terraform apply $plan

#!/bin/bash
if [ "$1" == "vnet" ];then
  scripts/destroy.sh hpcc && scripts/destroy.sh aks
elif [ "$1" == "aks" ];then
  scripts/destroy.sh hpcc
fi
cd $1;
name=$(basename `pwd`)
plan=`/home/azureuser/mkplan ${name}_destroy.plan`
if [ ! -d "data" ] || [ ! -f "data/config.json" ]; then echo "$name is already destroyed";exit 0; fi

echo "=============== Destroying $name. Executing 'terraform destroy' ===============";
terraform destroy -auto-approve
rm -vr data
cd ..
r=`terraform state list|egrep "_$name"`
terraform state rm $r

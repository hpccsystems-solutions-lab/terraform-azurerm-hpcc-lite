# For Developers: Tutorial of HPCC Easy Deploy Terraform 

This tutorial explains the terraform code that deploys HPCC Systems on an azure Kubernetes service (aks). The terraform code was designed to enable one to deploy HPCC Systems easily.
The terraform code can be found on Github. Here is a link to it ([https://github.com/hpccsystems-solutions-lab/terraform-azurerm-hpcc-lite])

From the root directory of the repository one can deploy all components of the HPCC cluster. Also, one can deploy individual components of the system from these subdirectories: `vnet`, `storage`, `aks`, and `hpcc`. If you want to deploy the individual components manually, here is the order you should do the deployment: 1st `vnet`, 2nd `storage` (if you want persistent storage), 3rd `aks`, and finally `hpcc`.

The following sections will explain the terraform code in root directory and all subdirectories.

## Root Directory
Here is the root directory's contents (<font color="blue">**blue**</font> names are subdirectories) and a description of each entry:


|Entry Name|Description|
|:-----|:----------|
| `lite-variables.tf` | Contains all input variables |
| `lite.auto.tfvars.example` |Is an example .auto.tfvars file |
| `main.tf` | Contains most of the terraform code that deploys all components of system |
| `providers.tf` | Contains one provider, azurerm |
| <font color="blue">`scripts`</font> | Directory containing scripts used in deployment |
| <font color="blue">`aks`</font> | Directory containing terraform code to deploy `aks` |
| <font color="blue">`hpcc`</font> | Directory containing terraform code to deploy `hpcc` |
| <font color="blue">`storage`</font> | Directory containing terraform code to deploy external or persistent `storage` |
| <font color="blue">`vnet`</font> | Directory containing terraform code to deploy virtual network used by `aks` |


The following table shows all the variables in the file, `lite-variables.tf`, and their types. Plus, the table gives a description of each variable. Also, when one deploys from the root directory the `deploy` script puts these variables (or some of them) in the subdirectory where the deployment takes place.

|Variable|Type|Description|
|:-----|:---|:----------|
| `admin_username` | string | Username of the administrator of this HPCC Systems cluster. Example entry: "jdoe" |
| `aks_admin_email` | string | Email address of the administrator of this HPCC Systems cluster. Example entry: "jane.doe@hpccsystems.com" |
| `aks_admin_ip_cidr_map` | map of string | Map of name => CIDR IP addresses that can administrate this AKS. Format is '{"name"="cidr" [, "name"="cidr"]*}'. The 'name' portion must be unique. To add no CIDR addresses, use '{}'. The corporate network and your current IP address will be added automatically, and these addresses will have access to the HPCC cluster as a user. |
| `aks_admin_name` | string | Name of the administrator of this HPCC Systems cluster. Example entry: "Jane Doe" |
| `aks_azure_region` | string | The Azure region abbreviation in which to create these resources. Must be one of ["eastus", "eastus2", "centralus"]. Example entry: "eastus" |
| `aks_dns_zone_name` | string | Name of an existing dns zone. Example entry: "hpcczone.us-hpccsystems-dev.azure.lnrsg.io" |
| `aks_dns_zone_resource_group_name` | string | Name of the resource group of the above dns zone. Example entry: "app-dns-prod-eastus2" |
| `aks_enable_roxie` | boolean | Enable ROXIE? This will also expose port 8002 on the cluster. Example entry: false |
| `aks_max_node_count` | number | The maximum number of VM nodes to allocate for the HPCC Systems node pool. Must be 2 or more. |
| `aks_roxie_node_size ` | string | The VM size for each roxie node in the HPCC Systems. Example format `aks_roxie_node-size`="xlarge".|
| `aks_serv_node_size ` | string | The VM size for each serv node in the HPCC Systems. Example format `aks_serv_node-size`="2xlarge".|
| `aks_spray_node_size ` | string | The VM size for each spray node in the HPCC Systems. Example format `aks_spray_node-size`="2xlarge".|
| `aks_thor_node_size ` | string | The VM size for each thor node in the HPCC Systems. Example format `aks_thor_node-size`="2xlarge".|
| `authn_htpasswd_filename` | string | If you would like to use htpasswd to authenticate users to the cluster, enter the filename of the htpasswd file.  This file should be uploaded to the Azure 'dllsshare' file share in order for the HPCC processes to find it. A corollary is that persistent storage is enabled. An empty string indicates that htpasswd is not to be used for authentication. Example entry: "htpasswd.txt" |
| `enable_code_security` | boolean | Enable code security? If true, only signed ECL code will be allowed to create embedded language functions, use PIPE(), etc. Example entry: false |
| `enable_premium_storage` | boolean | If true, premium ($$$) storage will be used for the following storage shares: Dali. OPTIONAL, defaults to false. |
| `enable_thor` | boolean | If you want a thor cluster then 'enable_thor' must be set to true Otherwise it is set to false |
| `external_storage_desired` | boolean | If you want external storage instead of ephemeral storage then set this variable to true otherwise set it to false. |
| `extra_tags` | map of string | Map of name => value tags that can will be associated with the cluster. Format is '{"name"="value" [, "name"="value"]*}'. The 'name' portion must be unique. To add no tags, use '{}'. |
| `hpcc_user_ip_cidr_list` | list of string | List of explicit CIDR addresses that can access this HPCC Systems cluster. To allow public access, specify "0.0.0.0/0". To add no CIDR addresses, use '[]'. |
| `hpcc_version` | string | The version of HPCC Systems to install. Only versions in nn.nn.nn format are supported. |
| `my_azure_id` | string | Your azure account object id. Find this on azure portal, by going to 'users' then search for your name and click on it. The account object id is called 'Object ID'. There is a link next to it that lets you copy it. |
| `storage_data_gb` | number | The amount of storage reserved for data in gigabytes. Must be 1 or more. If a storage account is defined (see below) then this value is ignored. |
| `storage_lz_gb` | number | The amount of storage reserved for the landing zone in gigabytes. Must be 1 or more. If a storage account is defined (see below) then this value is ignored. |
| `thor_max_jobs` | number | The maximum number of simultaneous Thor jobs allowed. Must be 1 or more. |
| `thor_num_workers` | number | The number of Thor workers to allocate. Must be 1 or more. |


The following table gives the name of each of the 5 `null_resource` in `main.tf` and gives a short description of what each does.

|null_resource name|description|
|:-----------------|:----------|
| `deploy_vnet` | deploys aks' virtual network |
| `deploy_aks` | deploys aks |
| `deploy_storage` | deploys persistent storage |
| `external_storage` | waits for deployment of presistent storage |
| `deploy_hpcc` | deploys hpcc |

The subfolders, except for `scripts`, create components needed by the full system.

## scripts subdirectory

|scripts subdirectory entry name|description|
|:--------------------------------|:----------|
| `deploy` | Used by each of the `deploy` `null_resource`s in main.tf. This script deploys any of the components, i.e. aks, hpcc, storage, or vnet |
| `destroy` | Destroys a single component, i.e. aks, hpcc, storage, or vnet. This script destorys 1) the component whose name is given on the command line after `deploy`, e.g. `destroy vnet`, and 2) any components that depends on it, e.g. before `vnet` is destroyed both `hpcc` and `aks` would be destroyed. |
| `external_storage` | Waits for presistent storage to be created (or if ephemeral storage is used this scripts exits) NOTE: HPCC is not deployed until `external_storage` exits successfully. |
| `extract-aks-variables` | the `deploy` script uses this script to copy from root directory the `lite-variables.tf` file contents used to deploy aks. |
| `get_rg_from_file` | Outputs the resource group name in the `config.json` file given on the command line |
| `mkplan` | Makes a unique name for the file that will contain the `terraform plan` of a component being deployed. |
| <font color="blue">`needed-auto-tfvars-files`</font> | Directory containing .auto.tfvars files needed by the `aks` and `storage` components. |

## aks subdirectory

The following table tells what files and subdirectories and in the `aks` subdirectory. The deployment of an `aks`happens in this directory. If one deploys from the root directory, the `deploy` script goes to this directory to deploy an `aks`. Also, if you deploy `aks` manually you do it from this directory.

|aks subdirectory entry name|description|
|:------------------------------|:----------|
| `aks.auto.tfvars` | This file is copied to the `aks` subdirectory when the `deploy` script is executed to deploy `aks`. This file contains `rbac_bindings` is one of this file's variables which contains the variable, `my_azure_id` which is the object id of the user's azure account. This variable is given its value by the script `deploy`.|
| `aks.tf` | This file contains most of the terraform code needed to deploy `aks`. The main module in this file is the `aks` module. |
| `automation.tf` | This file contains the terraform code for scheduling the stopping and/or starting of the Kubernetes cluster. |
| <font color="blue">`data`<\font> | This directory and its contents, `config.json`, are created after the `aks` cluster is successfully deployed. |
| `data.tf` | This file contains `data` statements that gets resources needed that already exist. |
| `lite-locals.tf` | This file contains local variables that need variables given in lite.auto.tfvars. In Godson Fortil's repository, which this terraform code was forked, all the variables in this file were input variables defined in `variables.tf`. |
| `lite-variables.tf` | This file contains the definition of all variables in `lite.auto.tfvars`. This is a subset of the root directory's lite-variables.tf use by `aks`. This file was copied to the `aks` directory by the `deploy` script. |
| `lite.auto.tfvars` | This file contains all the variables (and their values) whose name beings with `aks_`. These variables and their values are copied from the lite.auto.tfvars file in the root directory. The copy is done by the script, `deploy`. |
| `locals.tf` | This file contains local variables that were originally in Godson Fortil's repository. |
| `main.tf` | This file contains resources and modules needed for the deployment. They are: `resource "random_integer" "int`, `resource "random_string" "string`, `module "subscription`, `module "naming`, `module "metadata`, `module "resource_groups`, `resource "null_resource" "az`. |
| `misc.auto.tfvars` | This file is copied to the `aks` subdirectory when the `deploy` script is executed to deploy `aks`. |
| `outputs.tf` | This file contains `output` statement which outputs the following: `advisor_recommendations`,`aks_login`,`cluster_name`,`hpcc_log_analytics_enabled`,`cluster_resource_group_name`. |
| `providers.tf` | This file contains the following providers: `azurerm`,`azuread`,`kubernetes`,`kubernetes`,`kubectl`,`kubectl`,`helm`,`helm`,`shell`. |
| `variables.tf` | This file contains the variables described in the next table. |
| `versions.tf` | This file gives the version needed of each provider. |

## hpcc subdirectory

The following table tells what files and subdirectories and in the hpcc subdirectory. The deployment of an hpcc cluster happens in this directory. If one deploys from the root directory, the `deploy` script goes to this directory to deploy an hpcc cluster. Also, if you deploy an hpcc cluster manually you do it from this directory.

|hpcc subdirectory entry name|description|
|:--------------------------------|:----------|
| `data.tf` | Contains `data` statements providing information about existing resources. |
| `hpcc.tf` | Contains the `hpcc` module which does most of the work of deploying an hpcc cluster. |
| `lite-locals.tf` | Contains variables that use lite-variables.tf variables. The contents was in .auto.tfvars of Godson's terraform-azurerm-hpcc, branch HPCC-27615 (which this terraform code is a fork). |
| `lite-variables.tf` | Contains all variables used for easy deployment. This file is copied in the hpcc directory by the `deploy` script. |
| `lite.auto.tfvars` | Contains alls the variables used for easy deployment with values of the user. This file is copied in the hpcc directory by the `deploy` script. |
| `locals.tf` | Contains local variables used in the deployment of the hpcc cluster. Variables in this file also use some of the easy deploy variables in lite-variables.tf. |
| `main.tf` | Contains modules and resources needed for the deployment of the hpcc cluster. |
| `outputs.tf` | Contains output statements that show the user important information, like the eclwatch url and the resource group used by most of the resources. |
| `providers.tf` | Contains providers needed for the hpcc cluster deployment. Also, some of these providers (`kubernetes` and `kubectl`) get credentials for the Kubernetes cluster for authenication. |
| `versions.tf` | Contains the versions needed for all providers. |
| <font color="blue">`data`</font> | This directory contains the file `config.json` which is created when the hpcc cluster successfully deploys. |

## storage subdirectory

The following table tells what files and subdirectories and in the `storage` subdirectory. The deployment of an `storage` happens in this directory. If one deploys from the root directory, the `deploy` script goes to this directory to deploy `storage`. Also, if you deploy `storage` manually you do it from this directory.

|storage subdirectory entry name|description|
|:--------------------------------|:----------|
| `data.tf` | Contains `data` statements providing information about existing resources. |
| `lite-variables.tf` | This file contains the definition of all variables in `lite.auto.tfvars`. This is a subset of the root directory's lite-variables.tf use by `storage`. This file was copied to the `aks` directory by the `deploy` script. |
| `locals.tf` | Contains local variables used in the deployment of the `storage`. Variables in this file also use some of the easy deploy variables in lite-variables.tf. |
| `main.tf` | Contains only the `storage` module |
| `outputs.tf` | Contains only the resource `local_file` which outputs to a file config.json. This is done only when on a successful deployment of `storage`. |
| `providers.tf` | Contains only 2 providers: azurerm and azuread |
| `storage.auto.tfvars` | Contains variables that describe the storage accounts that are created. This file is copied to the `storage` directory by the `deploy` script. |
| `variables.tf` | Contains variables needed for `storage` deployment. |
| `versions.tf` | dummy description text |
| <font color="blue">`data`</font> | This directory contains the file `config.json` which is created when the external storage successfully deploys. |

## vnet subdirectory


The following table tells what files and subdirectories are in the `vnet` subdirectory. The deployment of an `vnet` happens in this directory. If one deploys from the root directory, the `deploy` script goes to this directory to deploy `vnet`. Also, if you deploy `vnet` manually you do it from this directory.

|vnet subdirectory entry name|description|
|:--------------------------------|:----------|
| `data.tf` | Contains `data` statements providing information about existing resources. |
| `lite-variables.tf` | Contains all variables used for easy deployment. This file is copied in the hpcc directory by the `deploy` script. |
| `lite.auto.tfvars` | Contains all the variables used for easy deployment with values of the user. This file is copied in the `vnet` directory by the `deploy` script. |
| `locals.tf` | Contains local variables used in the deployment of `vnet`. Variables in this file also use some of the easy deploy variables in lite-variables.tf. |
| `main.tf` | Contains modules and resources needed for the deployment of `vnet` |
| `outputs.tf` | Contains several output statements that output important information to the deployer. Also, this file contains an output state that outputs a file, config.json. This file is only output if there is a successful deployment of `vnet`. |
| `providers.tf` |  Contains 2 providers: `random` and `azurerm`. |
| `variables.tf` | Contains only one variable, `disable_naming_conventions`. |
| `versions.tf` | Contains the required versions of `terraform`, `azurerm` and `random`. |
| `vnet.tf` | Contains the module `virtual_network` which deploys the virtual network used by `aks`, `hpcc`, and `storage`. |
| <font color="blue">`data`</font> | This directory contains the file `config.json` which is created when the `vnet` is successfully deploys. |

​     

# For Developers: Tutorial of HPCC Easy Deploy Terraform 

This tutorial explains the terraform that deploys HPCC Systems on an azure kubernetes service (aks). The terraform was designed to enable one to deploy HPCC Systems easily.
The terraform can be found on github. Here is a link to it ([https://github.com/hpccsystems-solutions-lab/terraform-azurerm-hpcc-lite/tree/HPCC-27615-easy-deploy])

From the root directory of the repository one can deploy all components of the HPCC cluster. Also, one can deploy individual components of the system within these subdirectories: `vnet`, `storage`, `aks`, and `hpcc`. If you want to deploy the individual components manually, here is the order you should do the deployment: 1st `vnet`, 2nd `storage` (if you want persistent storage), 3rd `aks`, and finally `hpcc`.

The following sections will explain the terraform in root directory and all subdirectories.

## Root Directory
Here is the root directory's contents (<font color="blue">blue</font> names are subdirectories) and a description of each entry:


|Entry Name|Description|
|:-----|:----------|
| `lite-variables.tf` | Contains all input variables |
| `lite.auto.tfvars.example` |Is an example .auto.tfvars file |
| `main.tf` | Contains most of the terraform that deploys all components of system |
| `providers.tf` | Contains one provider, azurerm |
| <font color="blue">`scripts`</font> | Directory containing scripts used in deployment |
| <font color="blue">`aks`</font> | Directory containing terraform to deploy `aks` |
| <font color="blue">`hpcc`</font> | Directory containing terraform to deploy `hpcc` |
| <font color="blue">`storage`</font> | Directory containing terraform to deploy external or persistent `storage` |
| <font color="blue">`vnet`</font> | Directory containing terraform to deploy virtual network used by `aks` |

The subfolders, except for `scripts`, create components needed by the full system.

The following table shows all the variables in the file, `lite-variables.tf`, and their types. Plus, the table gives a description of each variable.

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
| `aks_node_size` | string | The VM size for each node in the HPCC Systems node pool. Recommend "Standard_B4ms" or better. See https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general for more information. |
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

## scripts subdirectory

|scripts subdirectory entry name|description|
|:--------------------------------|:----------|
| `deploy` | Deploys any of the components, i.e. aks, hpcc, storage, or vnet |
| `destroy` | Deploys a single component, i.e. aks, hpcc, storage, or vnet. This script destorys 1) the component whose name is given on the command line after `deploy`, e.g. `destroy vnet`, and 2) any components that depends of the component given on the command line after `destroy`, e.g. before `vnet` is destroyed both `hpcc` and `aks` would be destroyed. |
| `external_storage` | Waits for presistent storage to be created (or if ephemeral storage is used this scripts exits) NOTE: HPCC is not deployed until `external_storage` exits successfully. |
| `extract-aks-variables` | the `deploy` script uses this script to copy from root directory the `lite-variables.tf` file contents used to deploy a component. |
| `get_rg_from_file` | Outputs the resource group name in the `config.json` file given on the command line |
| `mkplan` | Make a unique name for the file that will contain the terraform plan of a component being deployed. |
| <font color="blue">`needed-auto-tfvars-files`</font> | Directory containing .auto.tfvars files needed by the `aks` and `storage` components. |

## aks subdirectory

|aks subdirectory entry name|description|
|:------------------------------|:----------|
| `aks.auto.tfvars` | This file is copied to the `aks` subdirectory when the `deploy` script is executed to deploy `aks`. This file contains `rbac_bindings` and one if its parameters comes from the variable, `my_azure_id` which is the object id of the user's azure account. |
| `aks.tf` | This file contains must of the terraform needed to deploy `aks`. |
| `automation.tf` | This file contains the terraform for scheduling the stopping or starting of the kubernetes cluster. |
| <font color="blue">`data`<\font> | This directory and its contents, `config.json`, are created after the `aks` cluster is successfully deployed. |
| `data.tf` | This file contains `data` statements that gets resources needed that already exist. |
| `lite-locals.tf` | This file contains local variables that need variables given in lite.auto.tfvars. In Godson Fortil's repository, which this terraform was forked, all the variables in this file were input variables defined in `variables.tf`. |
| `lite-variables.tf` | This file contains the definition of all variables in `lite.auto.tfvars`. This file was copied to the `aks` directory by the `deploy` script. |
| `lite.auto.tfvars` | This file contains all the variables (and their values) whose name beings with `aks_`. These variables and their values are copied from the lite.auto.tfvars file in the root directory. The copy is done by the script, `deploy`. |
| `locals.tf` | This file contains local variables that were originally in Godson Fortil's repository. |
| `main.tf` | This file contains resources and modules needed for the deployment. They are: `resource "random_integer" "int`, `resource "random_string" "string`, `module "subscription`, `module "naming`, `module "metadata`, `module "resource_groups`, `resource "null_resource" "az`. |
| `misc.auto.tfvars` | This file is copied to the `aks` subdirectory when the `deploy` script is executed to deploy `aks`. |
| `outputs.tf` | This file contains `output` statement which outputs the following: `advisor_recommendations`,`aks_login`,`cluster_name`,`hpcc_log_analytics_enabled`,`cluster_resource_group_name`. |
| `providers.tf` | This file contains the following providers: `azurerm`,`azuread`,`kubernetes`,`kubernetes`,`kubectl`,`kubectl`,`helm`,`helm`,`shell`. |
| `variables.tf` | This file contains the variables described in the next table. |
| `versions.tf` | This file gives the version needed of each provider. |


## hpcc subdirectory

## storage subdirectory

## vnet subdirectory


Now you'll notice it has choice called no or resource and I've given names to each one of these floyd v-net for example deploy AKs deploy hpcc noticed that inside of these resources some of them have depends clauses the reason for the depends Clause is as an example aKs will not start until or venet completes and the depend on and your notice also that I have for hpcc those that depends on there and it won't start until the AKs is up and running

There's a photo called Scripps and in it are several Scripts that ploy is used by the main to to deploy the various components of of the terraform boy is a bash script that will deploy if you 

specify as an argument hpcc it will it will it will it


And then it doesn't in it a plan reply and it does that for each one of these the AKs hpcc is exactly the same

Each one of these directories will have a file in it that ends with example these all of these are actually Auto efr's filed and what you'll do with those is you will copy it into a file called well that will end with auto.tfvars you will change things to make it your own so as an example maybe I should do that
As an example of the first variable in this light.auto.tfvar's file is aksdns Zone name in the example file it doesn't have a DSN Zone name there but you have to put one there so it would be a DS Zone that you have created or somebody has created for you

In the v-net folder you will find several.tf files refine an example file which is a template file you will have to make a auto.tfvar's file using it you also see that there may be a directory called Data and what happens there is once the v-net is up and running a file called config.json is placed in that older data

If you look at the providers file is really only two providers is one called random then there's one called Azure RM random you will find will basically create the strings are random numbers for you and as your RM is play the base for any Azure functions a terraform as your functions 

Question
To the question is it's like a library each one of these is like libraries are these providers the same thing as like a library or like an import of some sort



The variables files as you would expect contain input variables to to the the module in this case v-net module along with those when it defines the variable find those variables and give it a type type can be an integer string they can be an object if you look in this case here owner is actually an object which


Thelocals.tf file is very similar to the variables file in that it defines variables also the big difference is if it defines a variable here it can use variables that were in the variables.tf file to divide it for example this very first one the variables called name but it uses disabled naming conventions which is a variable when you reference these when you when you reference a variable that comes in the comes in the variable.tf file append to it variable. or pre-pin to it variable. variable. if it's a local variable you will say local. and then the name of the variable

Let's look at the data file in the data file there are three data items I'm not quite sure what to say about these the only the only one I really know about is this one right here and what happens there is it actually goes out to uRL that URL will actually return the host name of whatever machine is executing the it's the host public IP that returns of the machine that has executing the terraform


Question
Okay go ahead let's try it the data HTTP host IP section of code that retrieves the the hosts IP address this save the IP address somewhere for it to be used does it save it in the URL variable
The answer to your question is yes it saves the public IP in the variable called UR to continue with that if you want if you want to get a hold of that stay as a data.hp http. host_ip.url for you to get a hold of it

All right let's look at maine.tf
You'll notice in maine.tf there are several modules one called subscription one called names one called metadata there's also one called Resource Group that's it



Outputs.tf the outputs.tf file will contain output statements and each of the output statements will basically when this module finishes it will it will output these outputs to either the person who ran the terraform or could be the module that that executed the terraform at the module that executed this particular module in this case vnet

Versions.tf
The versions.tf file will give you versions that you need in order to execute the terraform if you'll notice in this file here they have a version statement the version statement for example the very first one it says the version is less than or equal to 2.99.0 if you if you if you were to use a version of as your RM that was larger than that that it would say it was three it wouldn't work it would give you an error the same thing with the others we've got adam and we also have

The AKs module it will contain again some templates ending with the word example and of course again these will be converted into auto.tfvar's file by copying them and then making them owned by making them your own by changing the what the what the variables values are
Notice also that this folder has a data directory just like the vnet had saying this data directory is used in the same way as in vnet in other words when the AKs is completely when the AKs is completely deployed it will place a eurasian.jsonfile in the data directory
For both the v-neck aKs there is useful information inside of the config jason for example for the v-net config file both AKs and hpcc terraforms use animation in the config Dot jason file for vnet

I think so

In the AKs folder we have the terraform that that deploys the AKs as your resources 

Inside of main.tf you're fine that there's some resources and modules in in here you'll see for most of these these subdirectories are they will always have a have a module called subscription there are always having a module called metadata naming horse group these are all but they may have others in this case here we have a null resource called call AZ


The most important in this AKs directory is the aks.tf file and as you can guess aks.tf does the deployment of a kubernetes cluster

And now in the hpcc you find the terraform that deploys an hpcc cluster as all the others this has very similar file names at least as there's a there's one example file so a
Your notice that there are several template files ending with the word example in so in this folder in this directory but most of them are currently not being used because they have a zero zero size so there's nothing in there


Let's look at the main.tf file what you're going to see is very very similar to the mains in the other directory is the v-net directory the AKs directory you have subscription naming metadata now the no resources different to have also where is resources Resource Group should be in here new

The most important file in this directory is the hpcc.tf file as you can guess this deploys pCC cluster
     


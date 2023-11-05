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
     

## Appendix A Resources Create by HPCC Deployment

| Resources Created by HPCC Deployment                         |
| :----------------------------------------------------------- |
| `local_file.config.json`                                      |
| `random_integer.random`                                      |
| `module.hpcc.azurerm_storage_account.azurefiles_admin_services[0]` |
| `module.hpcc.azurerm_storage_account.blob_nfs_admin_services[0]` |
| `module.hpcc.azurerm_storage_container.blob_nfs_admin_services["debug"]` |
| `module.hpcc.azurerm_storage_container.blob_nfs_admin_services["dll"]` |
| `module.hpcc.azurerm_storage_container.blob_nfs_admin_services["mydropzone"]` |
| `module.hpcc.azurerm_storage_container.blob_nfs_admin_services["sasha"]` |
| `module.hpcc.azurerm_storage_share.azurefiles_admin_services["dali"]` |
| `module.hpcc.helm_release.hpcc`                              |
| `module.hpcc.kubernetes_persistent_volume.azurefiles["dali"]` |
| `module.hpcc.kubernetes_persistent_volume.blob_nfs["data-1"]` |
| `module.hpcc.kubernetes_persistent_volume.blob_nfs["data-2"]` |
| `module.hpcc.kubernetes_persistent_volume.blob_nfs["debug"]` |
| `module.hpcc.kubernetes_persistent_volume.blob_nfs["dll"]`   |
| `module.hpcc.kubernetes_persistent_volume.blob_nfs["mydropzone"]` |
| `module.hpcc.kubernetes_persistent_volume.blob_nfs["sasha"]` |
| `module.hpcc.kubernetes_persistent_volume.spill["spill"]`    |
| `module.hpcc.kubernetes_persistent_volume_claim.azurefiles["dali"]` |
| `module.hpcc.kubernetes_persistent_volume_claim.blob_nfs["data-1"]` |
| `module.hpcc.kubernetes_persistent_volume_claim.blob_nfs["data-2"]` |
| `module.hpcc.kubernetes_persistent_volume_claim.blob_nfs["debug"]` |
| `module.hpcc.kubernetes_persistent_volume_claim.blob_nfs["dll"]` |
| `module.hpcc.kubernetes_persistent_volume_claim.blob_nfs["mydropzone"]` |
| `module.hpcc.kubernetes_persistent_volume_claim.blob_nfs["sasha"]` |
| `module.hpcc.kubernetes_persistent_volume_claim.spill["spill"]` |
| `module.hpcc.kubernetes_secret.azurefiles_admin_services[0]` |
| `module.hpcc.kubernetes_storage_class.premium_zrs_file_share_storage_class[0]` |
| `module.hpcc.random_string.random`                           |
| `module.hpcc.random_uuid.volume_handle`                      |
| `module.hpcc.module.certificates.kubectl_manifest.default_issuer` |
| `module.hpcc.module.certificates.kubectl_manifest.local_certificate` |
| `module.hpcc.module.certificates.kubectl_manifest.remote_certificate` |
| `module.hpcc.module.certificates.kubectl_manifest.signing_certificate` |
| `module.hpcc.module.data_storage[0].azurerm_storage_account.default["1"]` |
| `module.hpcc.module.data_storage[0].azurerm_storage_account.default["2"]` |
| `module.hpcc.module.data_storage[0].azurerm_storage_container.hpcc_data["1"]` |
| `module.hpcc.module.data_storage[0].azurerm_storage_container.hpcc_data["2"]` |

## Appendix B Resources Created by aks Deployment

|Resources Created by aks Deployment|
|:------------------------------------------------------------------------------------------------|
| `data.azuread_group.subscription_owner` |
| `data.azurerm_advisor_recommendations.advisor` |
| `data.azurerm_client_config.current` |
| `data.azurerm_subscription.current` |
| `data.http.host_ip` |
| `local_file.output` |
| `null_resource.az[0]` |
| `random_integer.int` |
| `random_string.name` |
| `random_string.string` |
| `module.aks.data.azurerm_subscription.current` |
| `module.aks.kubernetes_config_map.terraform_modules` |
| `module.aks.kubernetes_config_map_v1_data.terraform_modules` |
| `module.aks.terraform_data.creation_metadata` |
| `module.aks.terraform_data.immutable_inputs` |
| `module.aks.time_static.timestamp` |
| `module.aks.module.cluster.data.azurerm_client_config.current` |
| `module.aks.module.cluster.data.azurerm_kubernetes_cluster.default` |
| `module.aks.module.cluster.data.azurerm_kubernetes_service_versions.default` |
| `module.aks.module.cluster.data.azurerm_monitor_diagnostic_categories.default` |
| `module.aks.module.cluster.data.azurerm_public_ip.outbound[0]` |
| `module.aks.module.cluster.azurerm_kubernetes_cluster.default` |
| `module.aks.module.cluster.azurerm_role_assignment.network_contributor_network` |
| `module.aks.module.cluster.azurerm_role_assignment.network_contributor_route_table[0]` |
| `module.aks.module.cluster.azurerm_user_assigned_identity.default` |
| `module.aks.module.cluster.terraform_data.maintenance_control_plane_start_date` |
| `module.aks.module.cluster.terraform_data.maintenance_nodes_start_date` |
| `module.aks.module.cluster.time_sleep.modify` |
| `module.aks.module.cluster_version_tag.shell_script.default` |
| `module.aks.module.core_config.kubernetes_labels.system_namespace["default"]` |
| `module.aks.module.core_config.kubernetes_labels.system_namespace["kube-system"]` |
| `module.aks.module.core_config.kubernetes_namespace.default["cert-manager"]` |
| `module.aks.module.core_config.kubernetes_namespace.default["dns"]` |
| `module.aks.module.core_config.kubernetes_namespace.default["ingress-core-internal"]` |
| `module.aks.module.core_config.kubernetes_namespace.default["logging"]` |
| `module.aks.module.core_config.kubernetes_namespace.default["monitoring"]` |
| `module.aks.module.core_config.module.aad_pod_identity.azurerm_role_assignment.k8s_managed_identity_operator_cluster` |
| `module.aks.module.core_config.module.aad_pod_identity.azurerm_role_assignment.k8s_managed_identity_operator_node` |
| `module.aks.module.core_config.module.aad_pod_identity.azurerm_role_assignment.k8s_virtual_machine_contributor_node` |
| `module.aks.module.core_config.module.aad_pod_identity.helm_release.aad_pod_identity` |
| `module.aks.module.core_config.module.aad_pod_identity.time_sleep.finalizer_wait` |
| `module.aks.module.core_config.module.cert_manager.helm_release.default` |
| `module.aks.module.core_config.module.cert_manager.kubectl_manifest.issuers["letsencrypt"]` |
| `module.aks.module.core_config.module.cert_manager.kubectl_manifest.issuers["letsencrypt_staging"]` |
| `module.aks.module.core_config.module.cert_manager.kubectl_manifest.issuers["zerossl"]` |
| `module.aks.module.core_config.module.cert_manager.kubectl_manifest.resource_files["configmap-dashboard-cert-manager.yaml"]` |
| `module.aks.module.core_config.module.cert_manager.kubectl_manifest.resource_files["poddistributionbudget-cert-manager-webhook.yaml"]` |
| `module.aks.module.core_config.module.cert_manager.kubectl_manifest.resource_files["prometheusrule-certmanager.yaml"]` |
| `module.aks.module.core_config.module.cert_manager.kubernetes_secret.zerossl_eabsecret` |
| `module.aks.module.core_config.module.cert_manager.module.identity.azurerm_federated_identity_credential.default["system:serviceaccount:cert-manager:cert-manager"]` |
| `module.aks.module.core_config.module.cert_manager.module.identity.azurerm_role_assignment.default[0]` |
| `module.aks.module.core_config.module.cert_manager.module.identity.azurerm_user_assigned_identity.default` |
| `module.aks.module.core_config.module.coredns.kubectl_manifest.resource_files["prometheusrule-coredns.yaml"]` |
| `module.aks.module.core_config.module.coredns.kubectl_manifest.resource_objects["coredns_custom"]` |
| `module.aks.module.core_config.module.crds.module.crds["aad-pod-identity"].kubectl_manifest.crds["azureassignedidentities.aadpodidentity.k8s.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["aad-pod-identity"].kubectl_manifest.crds["azureidentities.aadpodidentity.k8s.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["aad-pod-identity"].kubectl_manifest.crds["azureidentitybindings.aadpodidentity.k8s.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["aad-pod-identity"].kubectl_manifest.crds["azurepodidentityexceptions.aadpodidentity.k8s.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["cert-manager"].kubectl_manifest.crds["certificaterequests.cert-manager.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["cert-manager"].kubectl_manifest.crds["certificates.cert-manager.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["cert-manager"].kubectl_manifest.crds["challenges.acme.cert-manager.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["cert-manager"].kubectl_manifest.crds["clusterissuers.cert-manager.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["cert-manager"].kubectl_manifest.crds["issuers.cert-manager.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["cert-manager"].kubectl_manifest.crds["orders.acme.cert-manager.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["external-dns"].kubectl_manifest.crds["dnsendpoints.externaldns.k8s.io.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["alertmanagerconfigs.monitoring.coreos.com.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["alertmanagers.monitoring.coreos.com.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["podmonitors.monitoring.coreos.com.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["probes.monitoring.coreos.com.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["prometheusagents.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["prometheuses.monitoring.coreos.com.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["prometheusrules.monitoring.coreos.com.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["scrapeconfigs.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["servicemonitors.monitoring.coreos.com.yaml"]` |
| `module.aks.module.core_config.module.crds.module.crds["kube-prometheus-stack"].kubectl_manifest.crds["thanosrulers.monitoring.coreos.com.yaml"]` |
| `module.aks.module.core_config.module.external_dns.helm_release.public[0]` |
| `module.aks.module.core_config.module.external_dns.kubectl_manifest.resource_files["configmap-dashboard-external-dns.yaml"]` |
| `module.aks.module.core_config.module.external_dns.kubernetes_secret.public_config[0]` |
| `module.aks.module.core_config.module.external_dns.module.identity_public[0].azurerm_federated_identity_credential.default["system:serviceaccount:dns:external-dns-public"]` |
| `module.aks.module.core_config.module.external_dns.module.identity_public[0].azurerm_role_assignment.default[0]` |
| `module.aks.module.core_config.module.external_dns.module.identity_public[0].azurerm_role_assignment.default[1]` |
| `module.aks.module.core_config.module.external_dns.module.identity_public[0].azurerm_user_assigned_identity.default` |
| `module.aks.module.core_config.module.ingress_internal_core.helm_release.default` |
| `module.aks.module.core_config.module.ingress_internal_core.kubectl_manifest.certificate` |
| `module.aks.module.core_config.module.ingress_internal_core.kubectl_manifest.resource_files["configmap-dashboard-ingress-nginx-core-internal.yaml"]` |
| `module.aks.module.core_config.module.ingress_internal_core.kubectl_manifest.resource_files["prometheusrule-ingress-nginx-core-internal.yaml"]` |
| `module.aks.module.core_config.module.ingress_internal_core.time_sleep.lb_detach` |
| `module.aks.module.core_config.module.pre_upgrade.module.v1_0_0.shell_script.default` |
| `module.aks.module.core_config.module.pre_upgrade.module.v1_0_0-rc_1.shell_script.default` |
| `module.aks.module.core_config.module.storage.kubernetes_storage_class.default["azure-disk-premium-ssd-delete"]` |
| `module.aks.module.core_config.module.storage.kubernetes_storage_class.default["azure-disk-premium-ssd-ephemeral"]` |
| `module.aks.module.core_config.module.storage.kubernetes_storage_class.default["azure-disk-premium-ssd-retain"]` |
| `module.aks.module.core_config.module.storage.kubernetes_storage_class.default["azure-disk-premium-ssd-v2-delete"]` |
| `module.aks.module.core_config.module.storage.kubernetes_storage_class.default["azure-disk-premium-ssd-v2-ephemeral"]` |
| `module.aks.module.core_config.module.storage.kubernetes_storage_class.default["azure-disk-premium-ssd-v2-retain"]` |
| `module.aks.module.core_config.module.storage.kubernetes_storage_class.default["azure-disk-standard-ssd-delete"]` |
| `module.aks.module.core_config.module.storage.kubernetes_storage_class.default["azure-disk-standard-ssd-ephemeral"]` |
| `module.aks.module.core_config.module.storage.kubernetes_storage_class.default["azure-disk-standard-ssd-retain"]` |
| `module.aks.module.node_groups.module.bootstrap_node_group_hack.shell_script.default` |
| `module.aks.module.node_groups.module.system_node_groups["system1"].azurerm_kubernetes_cluster_node_pool.default` |
| `module.aks.module.node_groups.module.user_node_groups["servpool1"].azurerm_kubernetes_cluster_node_pool.default` |
| `module.aks.module.node_groups.module.user_node_groups["spraypool1"].azurerm_kubernetes_cluster_node_pool.default` |
| `module.aks.module.node_groups.module.user_node_groups["thorpool1"].azurerm_kubernetes_cluster_node_pool.default` |
| `module.aks.module.rbac.azurerm_role_assignment.cluster_user["35cbdc79-7ef5-4d2c-9b59-61ec21d76aa9"]` |
| `module.aks.module.rbac.kubernetes_cluster_role.aggregate_to_view[0]` |
| `module.aks.module.rbac.kubernetes_cluster_role_binding.cluster_admin[0]` |
| `module.metadata.data.azurerm_subscription.current` |
| `module.resource_groups["azure_kubernetes_service"].azurerm_resource_group.rg` |
| `module.resource_groups["azure_kubernetes_service"].random_integer.suffix[0]` |
| `module.subscription.data.azurerm_subscription.selected` |

## Appendix C Resources Created by Deployment of vnet



| Resources Created by Deployment of vnet                      |
| :----------------------------------------------------------- |
| `data.azurerm_advisor_recommendations.advisor`               |
| `data.azurerm_subscription.current`                          |
| `data.http.host_ip`                                          |
| `local_file.output`                                          |
| `module.metadata.data.azurerm_subscription.current`          |
| `module.resource_groups["virtual_network"].azurerm_resource_group.rg` |
| `module.resource_groups["virtual_network"].random_integer.suffix[0]` |
| `module.subscription.data.azurerm_subscription.selected`     |
| `module.virtual_network.azurerm_route.aks_route["hpcc-internet"]` |
| `module.virtual_network.azurerm_route.aks_route["hpcc-local-vnet-10-1-0-0-21"]` |
| `module.virtual_network.azurerm_route_table.aks_route_table["hpcc"]` |
| `module.virtual_network.azurerm_subnet_route_table_association.aks["aks-hpcc-private"]` |
| `module.virtual_network.azurerm_subnet_route_table_association.aks["aks-hpcc-public"]` |
| `module.virtual_network.azurerm_virtual_network.vnet`        |
| `module.virtual_network.module.aks_subnet["aks-hpcc-private"].azurerm_subnet.subnet` |
| `module.virtual_network.module.aks_subnet["aks-hpcc-public"].azurerm_subnet.subnet` |

## Appendix D. Resources Created by Deployment of storage

|Resources Created by Depolyment of storage|
|:------------------------------------------------------------------------------------|
| `local_file.config.json` |
| `module.storage.azurerm_storage_account.azurefiles["adminsvc1"]` |
| `module.storage.azurerm_storage_account.blobnfs["adminsvc2"]` |
| `module.storage.azurerm_storage_account.blobnfs["data1"]` |
| `module.storage.azurerm_storage_account.blobnfs["data2"]` |
| `module.storage.azurerm_storage_container.blobnfs["1"]` |
| `module.storage.azurerm_storage_container.blobnfs["2"]` |
| `module.storage.azurerm_storage_container.blobnfs["3"]` |
| `module.storage.azurerm_storage_container.blobnfs["4"]` |
| `module.storage.azurerm_storage_container.blobnfs["5"]` |
| `module.storage.azurerm_storage_container.blobnfs["6"]` |
| `module.storage.azurerm_storage_share.azurefiles["0"]` |
| `module.storage.null_resource.remove0000_from_azurefile["adminsvc1"]` |
| `module.storage.null_resource.remove0000_from_blobfs["adminsvc2"]` |
| `module.storage.null_resource.remove0000_from_blobfs["data1"]` |
| `module.storage.null_resource.remove0000_from_blobfs["data2"]` |
| `module.storage.random_string.random` |
| `module.storage.module.resource_groups["storage_accounts"].azurerm_resource_group.rg` |
| `module.storage.module.resource_groups["storage_accounts"].random_integer.suffix[0]` |

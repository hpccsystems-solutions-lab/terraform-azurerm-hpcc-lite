# Deploy HPCC Systems on Azure under Kubernetes

NOTE: A tutorial of this terraform for the developer, or others who are interested, can be found [here](documentation/hpcc-tf-for-developers.md).

This is a slightly-opinionated Terraform module for deploying an HPCC Systems cluster on Azure's kubernetes service (aks).  The goal is to provide a simple method for deploying a cluster from scratch, with only the most important options to consider.

The HPCC Systems cluster created by this module uses ephemeral storage (meaning, the storage will be deleted when the cluster is deleted). But, you can also have Persistent Storage.  See the section titled [Persistent Storage](#persistent-storage), below.

This repo is a fork of the excellent work performed by Godson Fortil.  The original can be found at [https://github.com/gfortil/terraform-azurerm-hpcc/tree/HPCC-27615].

## Requirements

* <font color="red">**Terraform**</font> This is a Terraform module, so you need to have Terraform installed on your system.  Instructions for downloading and installing Terraform can be found at [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html).  Do make sure you install a 64-bit version of Terraform, as that is needed to accommodate some of the large random numbers used for IDs in the Terraform modules.

* <font color="red">**helm**</font> Helm is used to deploy the HPCC Systems processes under Kubernetes.  Instructions for downloading and installing Helm are at [https://helm.sh/docs/intro/install](https://helm.sh/docs/intro/install/).

* <font color="red">**kubectl**</font> The Kubernetes client (kubectl) is also required so you can inspect and manage the Azure Kubernetes cluster.  Instructions for download and installing that can be found at [https://kubernetes.io/releases/download/](https://kubernetes.io/releases/download/).  Make sure you have version 1.22.0 or later.

* <font color="red">**Azure CLI**</font> To work with Azure, you will need to install the Azure Command Line tools.  Instructions can be found at [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).  Even if you think you won't be working with Azure, this module does leverage the command line tools to manipulate network security groups within kubernetes clusters.  TL;DR: Make sure you have the command line tools installed.

* This module will create an AKS cluster in your current **default** Azure subscription.  You can view your current subscriptions, and determine which is the default, using the `az account list --output table` command.  To set a default subscription, use `az account set --subscription "My_Subscription"`.

* To successfully create everything you will need to have Azure's `Contributor` role plus access to `Microsoft.Authorization/*/Write` and `Microsoft.Authorization/*/Delete` permissions on your subscription.  You may have to create a custom role for this.  Of course, Azure's `Owner` role includes everything so if you're the subscription's owner then you're good to go.

## Installing/Using This Module

1. If necessary, login to Azure.
	* From the command line, this is usually accomplished with the `az login` command.
1. Clone this repo to your local system and change current directory.
	* `git clone -b HPCC-27615-easy-deploy  https://github.com/hpccsystems-solutions-lab/terraform-azurerm-hpcc-lite.git`
	* `cd terraform-azurerm-hpcc-lite`
1. Issue `terraform init` to initialize the Terraform modules.
1. Decide how you want to supply option values to the module during invocation.  There are three possibilities:
	1. Invoke the `terraform apply` command and enter values for each option as Terraform prompts for it, then enter `yes` at the final prompt to begin building the cluster.
	1. **Recommended:**  Create a `lite.auto.tfvars` file containing the values for each option, invoke `terraform apply`, then enter `yes` at the final prompt to begin building the cluster.  The easiest way to do that is to copy the example file and then edit the copy:
		* `cp lite.auto.tfvars.example lite.auto.tfvars`
	1. Use -var arguments on the command line when executing the terraform tool to set each of the values found in the .tfvars file.  This method is useful if you are driving the creation of the cluster from a script.
1. After the Kubernetes cluster is deployed, your local `kubectl` tool can be used to interact with it.  At some point during the deployment `kubectl` will acquire the login credentials for the cluster and it will be the current context (so any `kubectl` commands you enter will be directed to that cluster by default).

At the end of a successful deployment these items are output:
* The URL used to access ECL Watch.
* The deployment azure resource group.

## Available Options

Options have data types.  The ones used in this module are:
* string
	* Typical string enclosed by quotes
	* Example
		* `"value"`
* number
	* Integer number; do not quote
	* Example
		* `1234`
* boolean
	* true or false (not quoted)
* map of string
	* List of key/value pairs, delimited by commas
	* Both key and value should be a quoted string
	* Entire map is enclosed by braces
	* Example with two key/value pairs
		* `{"key1" = "value1", "key2" = "value2"}`
	* Empty value is `{}`
* list of string
	* List of values, delimited by commas
	* A value is a quoted string
	* Entire list is enclosed in brackets
	* Example with two values
		* `["value1", "value2"]`
	* Empty value is `[]`

The following options should be set in your `lite.auto.tfvars` file (or entered interactively, if you choose to not create a file).  Only a few of them have default values. The rest are required.  The 'Updateable' column indicates whether, for any given option, it is possible to successfully apply the update against an already-running HPCC k8s cluster.

|Option|Type|Description|
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

## Persistent Storage

To get persistent storage, i.e. storage that is not deleted when the hpcc cluster is deleted, set the variable, external_storage_desired, to true.

## Useful Things

* Useful `kubectl` commands once the cluster is deployed:
	* `kubectl get pods`
		* Shows Kubernetes pods for the current cluster.
	* `kubectl get services`
		* Show the current services running on the pods on the current cluster.
	* `kubectl config get-contexts`
		* Show the saved kubectl contexts.  A context contains login and reference information for a remote Kubernetes cluster.  A kubectl command typically relays information about the current context.
	* `kubectl config use-context <ContextName>`
		* Make \<ContextName\> context the current context for future kubectl commands.
	* `kubectl config unset contexts.<ContextName>`
		* Delete context named \<ContextName\>.
		* Note that when you delete the current context, kubectl does not select another context as the current context.  Instead, no context will be current.  You must use `kubectl config use-context <ContextName>` to make another context current.
* Note that `terraform destroy` does not delete the kubectl context.  You need to use `kubectl config unset contexts.<ContextName>` to get rid of the context from your local system.
* If a deployment fails and you want to start over, you have two options:
	* Immediately issue a `terraform destroy` command and let Terraform clean up.
	* Clean up the resources by hand:
		* Delete the Azure resource group manually, such as through the Azure Portal.
			* Note that there are two resource groups, if the deployment got far enough.  Examples:
				* `app-thhpccplatform-sandbox-eastus-68255`
				* `mc_tf-zrms-default-aks-1`
			* The first one contains the Kubernetes service that created the second one (services that support Kubernetes).  So, if you delete only the first resource group, the second resource group will be deleted automatically.
		* Delete all Terraform state files using `rm *.tfstate*`
	* Then, of course, fix whatever caused the deployment to fail.
* If you want to completely reset Terraform, issue `rm -rf .terraform* *.tfstate*` and then `terraform init`.

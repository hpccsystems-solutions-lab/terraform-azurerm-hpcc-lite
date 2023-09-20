# Azure - Storage Account for HPCC Systems
<br>

## Introduction

This module deploys storage accounts for the HPCC Systems cloud native platform.

## Providers

| Name    | Version   |
| ------- | --------- |
| azurerm | >= 3.63.0 |
| random  | >= 3.3.0  |
<br>

### The `owner` block:
This block contains information on the user who is deploying the cluster. This is used as tags and part of some resource names to identify who deployed a given resource and how to contact that user. This block is required.

| Name  | Description                  | Type   | Default | Required |
| ----- | ---------------------------- | ------ | ------- | :------: |
| name  | Name of the owner.           | string | -       |   yes    |
| email | Email address for the owner. | string | -       |   yes    |

<br>
Usage Example:
<br>

    owner = {
        name  = "Example"
        email = "example@hpccdemo.com"
    }

<br>

### The `disable_naming_conventions` block:
When set to `true`, this attribute drops the naming conventions set forth by the python module. This attribute is optional.

 | Name                       | Description                 | Type | Default | Required |
 | -------------------------- | --------------------------- | ---- | ------- | :------: |
 | disable_naming_conventions | Disable naming conventions. | bool | `false` |    no    |
<br>

### The `metadata` block:
TThe arguments in this block are used as tags and part of resources’ names. This block can be omitted when disable_naming_conventions is set to `true`.

 | Name                | Description                  | Type        | Default | Required |
 | ------------------- | ---------------------------- | ----------- | ------- | :------: |
 | project_name        | Name of the project.         | string      | ""      |   yes    |
 | product_name        | Name of the product.         | string      | hpcc    |    no    |
 | business_unit       | Name of your bussiness unit. | string      | ""      |    no    |
 | environment         | Name of the environment.     | string      | ""      |    no    |
 | market              | Name of market.              | string      | ""      |    no    |
 | product_group       | Name of product group.       | string      | ""      |    no    |
 | resource_group_type | Resource group type.         | string      | ""      |    no    |
 | sre_team            | Name of SRE team.            | string      | ""      |    no    |
 | subscription_type   | Subscription type.           | string      | ""      |    no    |
 | additional_tags     | Additional resource tags.    | map(string) | {}      |    no    |
<br>

Usage Example:
<br>

    metadata = {    
        project             = "hpccdemo"
        product_name        = "example"
        business_unit       = "commercial"
        environment         = "sandbox"
        market              = "us"
        product_group       = "contoso"
        resource_group_type = "app"
        sre_team            = "hpccplatform"
        subscription_type   = "dev"
        additional_tags     = {}
    }

<br>

### The `virtual_network` block:
This block imports metadata of a virtual network deployed outside of this project. This block is optional.

 | Name                | Description                                        | Type   | Default | Required |
 | ------------------- | -------------------------------------------------- | ------ | ------- | :------: |
 | subnet_name         | The name of the subnet.                            | string | -       |    -     |
 | vnet_name           | The name of the VNet to which to allow access.     | string | -       |    -     |
 | resource_group_name | The name of the VNet resource group.               | string | -       |    -     |
 | subscription_id     | The ID of the subscription where the VNet belongs. | string | -       |    -     |
<br>

Usage Example:
<br>

    virtual_network = [{
        subnet_name             = ""
        vnet_name               = ""
        resource_group_name     = ""
        subscription_id         = ""
    }]

<br>


## Usage

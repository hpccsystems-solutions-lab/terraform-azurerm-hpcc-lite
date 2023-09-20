# Deploy HPCC Systems Platform with Terraform

This set of Terraform examples deploys all the available features that come with the HPCC Systems OSS Terraform modules.

## Order of deployment
| Order | Name      | Required |
| ----- | --------- | :------: |
| 1     | `VNet`    |   yes    |
| 2     | `AKS`     |   yes    |
| 3     | `Storage` |    no    |
| 4     | `Logging` |    no    |
| 5     | `AKS`     |    no    |
| 6     | `HPCC`    |   yes    |

## Modules
|                Name                 | Source | Used in |
| :---------------------------------: | :----: | :-----: |
| `terraform-azurerm-virtual-network` |        | `VNet`  |
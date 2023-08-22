terraform {
  required_version = ">= 1.4.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0"
    }

    http = {
      source  = "hashicorp/http"
      version = ">=3.2.1"
    }
  }
}

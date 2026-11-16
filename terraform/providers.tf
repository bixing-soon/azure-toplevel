terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "bixingsttfstate"
  #   container_name       = "tfstate"
  #   key                  = "toplevel.tfstate"
  #   use_azuread_auth     = true
  # }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

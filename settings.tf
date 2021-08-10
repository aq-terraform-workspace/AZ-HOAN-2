# Provider configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.70"
    }
  }
}

provider "azurerm" {
  features {

  }
}

# Backend configuration
# Replace these values to your own
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "aq-tf-cloud"

    workspaces {
      name = "AZ-HOAN-2"
    }
  }
}
terraform {
  required_providers {
    ignition = {
      source = "community-terraform-providers/ignition"
      version = "2.4.0"
    }
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
  required_version = ">= 0.13"
}

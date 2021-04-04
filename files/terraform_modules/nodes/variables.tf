variable "name" {
  type = string
}

variable "ignition" {
  type    = string
  default = ""
}

variable "ignition_url" {
  type    = string
  default = ""
}

variable "resource_pool_id" {
  type = string
}

variable "folder" {
  type = string
}

variable "datastore" {
  type = string
}

#variable "network" {
#  type = string
#}

variable "adapter_type" {
  type = string
}

variable "guest_id" {
  type = string
}

variable "template" {
  type = string
}

variable "thin_provisioned" {
  type = string
}

variable "disk_size" {
  type = string
}

variable "memory" {
  type = string
}

variable "num_cpu" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "mac_address" {
  type = string
  default = ""
}

variable "bootstrap_mac" {
  type = string
  default = ""
}

variable "master_macs" {
  type = list(string)
  default = []
}

variable "worker_macs" {
  type = list(string)
  default = []
}

variable "api_network_id" {
  type    = string
}

variable "opflex_network_id" {
  type    = string
}


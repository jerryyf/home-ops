variable "nfs_server" {
  type = string
}

variable "nfs_share" {
  type = string
}

variable "base_url" {
  type = string
}

variable "namespace" {
  type = string
}

locals {
  repository      = "gitea-charts"
  chart           = "gitea"
  gitea_version   = "12.4.0"
  actions_version = "0.0.1"
  gitea_hostname  = "gitea.${var.base_url}"
  nfs_path        = "${var.nfs_share}/gitea"
}


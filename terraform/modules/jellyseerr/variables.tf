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
  jellyseerr_hostname = "jellyseerr.${var.base_url}"
}
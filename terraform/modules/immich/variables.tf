variable "nfs_server" {
  type      = string
  sensitive = true
}

variable "nfs_share" {
  type = string
}

variable "base_url" {
  type = string
}

locals {
  immich_path     = "${var.nfs_share}/immich"
  immich_hostname = "immich.${var.base_url}"
}

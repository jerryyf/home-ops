variable "nfs_server" {
  type = string
}

variable "nfs_share" {
  type = string
}

variable "base_url" {
  type = string
}

locals {
  jellyfin_path   = "${var.nfs_share}/library"
  immich_hostname = "immich.${var.base_url}"
}
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
  jellyfin_path     = "${var.nfs_share}/jellyfin"
  media_path        = "${var.nfs_share}/library"
  jellyfin_hostname = "jellyfin.${var.base_url}"
}
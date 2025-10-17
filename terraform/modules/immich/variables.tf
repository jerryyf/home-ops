variable "nfs_server" {
  type      = string
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
  image_tag       = "v2.0.1"
  chart           = "oci://ghcr.io/immich-app/immich-charts/immich"
  chart_version   = "0.10.0"
}

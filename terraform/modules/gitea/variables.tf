variable "base_url" {
  type = string
}

locals {
  repository      = "gitea-charts"
  chart           = "gitea"
  gitea_version   = "12.4.0"
  actions_version = "0.0.1"
  gitea_hostname  = "gitea.${var.base_url}"
}
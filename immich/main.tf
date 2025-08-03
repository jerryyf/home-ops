terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "immich" {
  name       = "immich"
  chart      = "oci://ghcr.io/immich-app/immich-charts/immich"
  namespace  = "immich"
  set = [
    {
      name  = "immich.persistence.library.existingClaim"
      value = "immich-pvc"
    },
    {
      name  = "redis.enabled"
      value = "true"
    },
    {
      name  = "image.tag"
      value = "v1.135.3"
    },
    {
      name  = "env.DB_HOSTNAME"
      value = "immich-postgres-rw"
    },
  ]
}

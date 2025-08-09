terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10.0"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "s3" {
    bucket  = ""
    key     = ""
    region  = ""
    encrypt = true
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace_v1" "portfolio_prod" {
  metadata {
    name = "portfolio-prod"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "helm_release" "cnpg" {
  name             = "cnpg"
  repository       = "cloudnative-pg"
  chart            = "cloudnative-pg"
  namespace        = "cnpg-system"
  version          = "0.23.2"
  atomic           = true
  create_namespace = true
}

resource "helm_release" "csi_driver_nfs" {
  name             = "csi-driver-nfs"
  repository       = "csi-driver-nfs"
  chart            = "csi-driver-nfs"
  namespace        = "kube-system"
  version          = "4.11.0"
  atomic           = true
  create_namespace = true
}

module "cert_manager" {
  source = "./modules/cert_manager"
}
module "istio" {
  source = "./modules/istio"
}

module "portfolio" {
  source                       = "./modules/portfolio"
  aws_region_lambda            = var.aws_region_lambda
  aws_access_key_id_lambda     = var.aws_access_key_id_lambda
  aws_secret_access_key_lambda = var.aws_secret_access_key_lambda
  aws_lambda_function_name     = var.aws_lambda_function_name
  bot_token                    = var.bot_token
  chat_id                      = var.chat_id
  base_url                     = var.base_url_portfolio

  depends_on = [module.cert_manager.helm_release]
}

resource "kubernetes_storage_class" "nfs_csi" {
  metadata {
    name = "nfs-csi"
  }
  storage_provisioner = "nfs.csi.k8s.io"
  parameters = {
    server = var.nfs_server
    share  = var.nfs_share
  }
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  mount_options = [
    "nfsvers=4.1"
  ]
}

module "immich" {
  source     = "./modules/immich"
  nfs_server = var.nfs_server
  nfs_share  = var.nfs_share
  base_url   = var.base_url_private
}

# module "open_webui" {
#   source = "./modules/open_webui" 
# }

module "jellyfin" {
  source     = "./modules/jellyfin"
  nfs_server = var.nfs_server
  nfs_share  = var.nfs_share
  base_url   = var.base_url_private
}
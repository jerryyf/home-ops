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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  backend "s3" {
    bucket  = ""
    key     = ""
    region  = ""
    encrypt = true
  }
}

module "bootstrap" {
  source = "./modules/bootstrap"
}

resource "kubectl_manifest" "istio_telemetry" {
  yaml_body  = <<EOF
    apiVersion: telemetry.istio.io/v1
    kind: Telemetry
    metadata:
      name: mesh-default
      namespace: istio-system
    spec:
      accessLogging:
        - providers:
            - name: envoy
    EOF
  depends_on = [module.bootstrap]
}

resource "kubernetes_storage_class_v1" "nfs_csi" {
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

  depends_on = [module.bootstrap]
}

# module "cert_manager" {
#   source = "./modules/base/cert_manager"
# }

# module "istio" {
#   source = "./modules/base/istio"

#   depends_on = [module.cert_manager.helm_release]
# }

# module "argocd" {
#   source = "./modules/base/argocd"

#   depends_on = [module.cert_manager.helm_release]
# }

# public ingress cloudflare proxy
# module "portfolio" {
#   source                       = "./modules/portfolio"
#   aws_region_lambda            = var.aws_region_lambda
#   aws_access_key_id_lambda     = var.aws_access_key_id_lambda
#   aws_secret_access_key_lambda = var.aws_secret_access_key_lambda
#   aws_lambda_function_name     = var.aws_lambda_function_name
#   bot_token                    = var.bot_token
#   chat_id                      = var.chat_id
#   base_url                     = var.base_url_portfolio
#   tag                          = "1.2.1"

#   depends_on = [module.istio.helm_release]
# }

# module "immich" {
#   source     = "./modules/immich"
#   namespace  = "immich"
#   nfs_server = var.nfs_server
#   nfs_share  = var.nfs_share
#   base_url   = var.base_url_private
#   depends_on = [module.istio.helm_release]
# }

# module "jellyfin" {
#   source     = "./modules/jellyfin"
#   namespace  = "jellyfin"
#   nfs_server = var.nfs_server
#   nfs_share  = var.nfs_share
#   base_url   = var.base_url_private
#   depends_on = [module.istio.helm_release]
# }

# module "jellyseerr" {
#   source     = "./modules/jellyseerr"
#   namespace  = "jellyseerr"
#   nfs_server = var.nfs_server
#   nfs_share  = var.nfs_share
#   base_url   = var.base_url_private
#   depends_on = [module.istio.helm_release]
# }

# module "gitea" {
#   source     = "./modules/gitea"
#   namespace  = "gitea"
#   nfs_server = var.nfs_server
#   nfs_share  = var.nfs_share
#   base_url   = var.base_url_private
#   depends_on = [module.istio.helm_release]
# }

# module "open_webui" {
#   source     = "./modules/open_webui"
#   namespace  = "open-webui"
#   base_url   = var.base_url_private
#   depends_on = [module.istio.helm_release]
# }

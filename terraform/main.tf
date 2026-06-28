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

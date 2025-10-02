terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
  }
}

resource "kubernetes_persistent_volume" "jellyfin_pv" {
  metadata {
    name = "jellyfin-pv"
  }

  spec {
    storage_class_name = "nfs-csi"
    persistent_volume_source {
      nfs {
        server = var.nfs_server
        path   = local.jellyfin_path
      }
    }
    capacity = {
      storage = "1Ti"
    }
    access_modes                     = ["ReadWriteMany"]
    mount_options                    = ["nfsvers=4.1"]
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_pvc" {
  metadata {
    name      = "jellyfin-pvc"
    namespace = "jellyfin"
  }

  spec {
    volume_name        = "jellyfin-pv"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-csi"
    resources {
      requests = {
        storage = "1Ti"
      }
    }
  }

  depends_on = [kubernetes_persistent_volume.jellyfin_pv]
}

# resource "helm_release" "jellyfin" {
#   name       = "jellyfin"
#   chart      = "jellyfin/jellyfin"
#   namespace  = "jellyfin"
#   atomic     = true
#   create_namespace = true
#   set = [
#     {
#       name  = "persistence.media.storageClass"
#       value = "nfs-csi"
#     },
#     {
#       name  = "persistence.media.existingClaim"
#       value = "jellyfin-pvc"
#     }
#   ]

#   depends_on = [ kubernetes_persistent_volume.jellyfin_pv, kubernetes_persistent_volume_claim.jellyfin_pvc ]
# }

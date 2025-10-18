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

    claim_ref {
      name      = "jellyfin-pvc"
      namespace = "jellyfin"
    }

    persistent_volume_source {
      csi {
        driver    = "nfs.csi.k8s.io"
        read_only = false
        volume_attributes = {
          "server" = var.nfs_server
          "share"  = local.jellyfin_path
        }
        volume_handle = "truenas/library"
      }
    }
    capacity = {
      storage = "2Ti"
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
        storage = "2Ti"
      }
    }
  }

  depends_on = [kubernetes_persistent_volume.jellyfin_pv]
}

resource "helm_release" "jellyfin" {
  name       = "jellyfin"
  chart      = "jellyfin/jellyfin"
  namespace  = "jellyfin"
  atomic     = true
  create_namespace = true
  set = [
    {
      name  = "persistence.media.storageClass"
      value = "nfs-csi"
    },
    {
      name  = "persistence.media.existingClaim"
      value = "jellyfin-pvc"
    }
  ]

  depends_on = [ kubernetes_persistent_volume.jellyfin_pv, kubernetes_persistent_volume_claim.jellyfin_pvc ]
}

resource "helm_release" "istio_config" {
  name      = "jellyfin-ingress"
  namespace = "istio-config"
  chart     = "${path.root}/helm/istio-config"
  atomic    = true
  set = [
    {
      name  = "hostname"
      value = local.jellyfin_hostname
    },
    {
      name  = "path"
      value = "/"
    },
    {
      name  = "dest"
      value = "jellyfin.jellyfin.svc.cluster.local"
    },
    {
      name  = "port"
      value = 8096
    }
  ]

  depends_on = [helm_release.jellyfin]
}


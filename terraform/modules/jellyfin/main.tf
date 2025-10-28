resource "kubernetes_persistent_volume" "jellyfin_media_pv" {
  metadata {
    name = "jellyfin-media-pv"
  }

  spec {
    storage_class_name = "nfs-csi"

    claim_ref {
      name      = "jellyfin-media-pvc"
      namespace = "staging"
    }

    persistent_volume_source {
      csi {
        driver    = "nfs.csi.k8s.io"
        read_only = false
        volume_attributes = {
          "server" = var.nfs_server
          "share"  = local.media_path
        }
        volume_handle = "truenas/library"
      }
    }
    capacity = {
      storage = "2Ti"
    }

    access_modes                     = ["ReadWriteMany"]
    mount_options                    = ["nfsvers=4.1"]
    persistent_volume_reclaim_policy = "Delete"
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_media_pvc" {
  metadata {
    name      = "jellyfin-media-pvc"
    namespace = "staging"
  }

  spec {
    volume_name        = "jellyfin-media-pvc"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-csi"
    resources {
      requests = {
        storage = "2Ti"
      }
    }
  }
  depends_on = [kubernetes_persistent_volume.jellyfin_media_pv]
}

resource "kubernetes_persistent_volume" "jellyfin_config_pv" {
  metadata {
    name = "jellyfin-config-pv"
  }

  spec {
    storage_class_name = "nfs-csi"

    claim_ref {
      name      = "jellyfin-config-pvc"
      namespace = "staging"
    }

    persistent_volume_source {
      csi {
        driver    = "nfs.csi.k8s.io"
        read_only = false
        volume_attributes = {
          "server" = var.nfs_server
          "share"  = local.jellyfin_path
        }
        volume_handle = "truenas/jellyfin"
      }
    }
    capacity = {
      storage = "5Gi"
    }

    access_modes                     = ["ReadWriteMany"]
    mount_options                    = ["nfsvers=4.1"]
    persistent_volume_reclaim_policy = "Delete"
  }
  depends_on = [kubernetes_persistent_volume_claim.jellyfin_media_pvc]
}

resource "kubernetes_persistent_volume_claim" "jellyfin_config_pvc" {
  metadata {
    name      = "jellyfin-config-pvc"
    namespace = "staging"
  }

  spec {
    volume_name        = "jellyfin-config-pv"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-csi"
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }

  depends_on = [kubernetes_persistent_volume.jellyfin_config_pv]
}

resource "helm_release" "jellyfin" {
  name             = "jellyfin"
  chart            = "jellyfin/jellyfin"
  namespace        = "staging"
  atomic           = true
  create_namespace = true
  set = [
    {
      name  = "persistence.config.storageClass"
      value = "nfs-csi"
    },
    {
      name  = "persistence.config.existingClaim"
      value = "jellyfin-config-pvc"
    },
    {
      name  = "persistence.media.storageClass"
      value = "nfs-csi"
    },
    {
      name  = "persistence.media.existingClaim"
      value = "jellyfin-media-pvc"
    }
  ]

  depends_on = [kubernetes_persistent_volume_claim.jellyfin_config_pvc]
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
      value = "/jellyfin"
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

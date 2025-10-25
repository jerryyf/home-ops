resource "kubernetes_persistent_volume" "gitea_pv" {
  metadata {
    name = "gitea-pv"
  }

  spec {
    storage_class_name = "nfs-csi"

    claim_ref {
      name      = "gitea-pvc"
      namespace = var.namespace
    }

    persistent_volume_source {
      csi {
        driver    = "nfs.csi.k8s.io"
        read_only = false
        volume_attributes = {
          "server" = var.nfs_server
          "share"  = local.nfs_path
        }
        volume_handle = "kubernetes/gitea"
      }
    }

    capacity = {
      storage = "256Gi"
    }

    access_modes                     = ["ReadWriteMany"]
    mount_options                    = ["nfsvers=4.1"]
    persistent_volume_reclaim_policy = "Delete"
  }
}

resource "kubernetes_persistent_volume_claim" "gitea_pvc" {
  metadata {
    name      = "gitea-pvc"
    namespace = var.namespace
  }

  spec {
    volume_name        = "gitea-pv"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-csi"
    resources {
      requests = {
        storage = "256Gi"
      }
    }
  }

  depends_on = [kubernetes_persistent_volume.gitea_pv]
}

resource "helm_release" "gitea" {
  name            = "gitea"
  repository      = local.repository
  chart           = "gitea"
  version         = local.gitea_version
  namespace       = var.namespace
  atomic          = true
  cleanup_on_fail = true

  set = [
    {
      name  = "ingress.hosts[0].host"
      value = local.gitea_hostname
    },
    {
      name  = "ingress.hosts[0].paths[0].path"
      value = "/"
    },
    {
      name  = "persistence.storageClass"
      value = "nfs-csi"
    },
    {
      name  = "persistence.create"
      value = "false"
    },
    {
      name  = "persistence.claimName"
      value = "gitea-pvc"
    },
    {
      name  = "persistence.size"
      value = "256Gi"
    },
    {
      name  = "persistence.volumeName"
      value = "gitea-pv"
    },
  ]

  depends_on = [kubernetes_persistent_volume_claim.gitea_pvc]
}

resource "helm_release" "istio_config" {
  name      = "gitea-ingress"
  namespace = "istio-config"
  chart     = "${path.root}/helm/istio-config"
  atomic    = true
  set = [
    {
      name  = "hostname"
      value = local.gitea_hostname
    },
    {
      name  = "path"
      value = "/"
    },
    {
      name  = "dest"
      value = "gitea-http.${var.namespace}.svc.cluster.local"
    },
    {
      name  = "port"
      value = 3000
    }
  ]

  depends_on = [helm_release.gitea]
}


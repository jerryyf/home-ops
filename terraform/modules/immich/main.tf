terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
}

resource "kubernetes_persistent_volume" "immich_pv" {
  metadata {
    name = "immich-pv"
  }

  spec {
    storage_class_name = "nfs-csi"

    claim_ref {
      name      = "immich-pvc"
      namespace = "immich"
    }

    persistent_volume_source {
      csi {
        driver    = "nfs.csi.k8s.io"
        read_only = false
        volume_attributes = {
          "server" = var.nfs_server
          "share"  = local.immich_path
        }
        volume_handle = "truenas/immich"
      }
    }

    capacity = {
      storage = "512Gi"
    }

    access_modes                     = ["ReadWriteMany"]
    mount_options                    = ["nfsvers=4.1"]
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "immich_pvc" {
  metadata {
    name      = "immich-pvc"
    namespace = "immich"
  }

  spec {
    volume_name        = "immich-pv"
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-csi"
    resources {
      requests = {
        storage = "512Gi"
      }
    }
  }

  depends_on = [kubernetes_persistent_volume.immich_pv]
}

resource "kubernetes_manifest" "immich_postgres" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Cluster"
    "metadata" = {
      "name"      = "immich-postgres"
      "namespace" = "immich"
    }
    "spec" = {
      "instances" = 1
      "imageName" = "ghcr.io/tensorchord/cloudnative-vectorchord:16.9-0.4.3"
      "storage" = {
        "size"         = "4Gi"
        "storageClass" = "local-path"
      }
      "postgresql" = {
        "shared_preload_libraries" = [
          "vchord.so",
        ]
      }
      "bootstrap" = {
        "initdb" = {
          "postInitSQL" = [
            "CREATE EXTENSION IF NOT EXISTS \"vchord\" CASCADE;",
            "CREATE EXTENSION IF NOT EXISTS \"earthdistance\" CASCADE;"
          ]
        }
      }
    }
  }
}

resource "helm_release" "immich" {
  name      = "immich"
  chart     = local.chart
  version   = local.chart_version
  namespace = "immich"
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
      value = local.image_tag
    },
    {
      name  = "env.DB_HOSTNAME.valueFrom.secretKeyRef.name"
      value = "immich-postgres-app"
    },
    {
      name  = "env.DB_HOSTNAME.valueFrom.secretKeyRef.key"
      value = "host"
    },

    {
      name  = "env.DB_USERNAME.valueFrom.secretKeyRef.name"
      value = "immich-postgres-app"
    },
    {
      name  = "env.DB_USERNAME.valueFrom.secretKeyRef.key"
      value = "user"
    },

    {
      name  = "env.DB_PASSWORD.valueFrom.secretKeyRef.name"
      value = "immich-postgres-app"
    },
    {
      name  = "env.DB_PASSWORD.valueFrom.secretKeyRef.key"
      value = "password"
    },

    {
      name  = "env.DB_DATABASE_NAME.valueFrom.secretKeyRef.name"
      value = "immich-postgres-app"
    },
    {
      name  = "env.DB_DATABASE_NAME.valueFrom.secretKeyRef.key"
      value = "dbname"
    },
    {
      name  = "valkey.enabled"
      value = true
    },
  ]

  depends_on = [kubernetes_manifest.immich_postgres]
}

resource "helm_release" "istio_config" {
  name      = "immich-ingress"
  namespace = "immich"
  chart     = "${path.root}/helm/istio-config"
  atomic    = true
  set = [
    {
      name  = "hostname"
      value = local.immich_hostname
    },
    {
      name  = "path"
      value = "/"
    },
    {
      name  = "dest"
      value = "immich-server.immich.svc.cluster.local"
    },
    {
      name  = "port"
      value = 2283
    }
  ]

  depends_on = [helm_release.immich]
}
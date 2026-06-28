terraform {
  required_version = ">= 0.12"

  required_providers {
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
}

# resource "kubernetes_namespace_v1" "immich" {
#   metadata {
#     name = var.namespace
#   }
# }

# resource "kubernetes_persistent_volume_v1" "immich_pv" {
#   metadata {
#     name = "immich-pv"
#   }

#   spec {
#     storage_class_name = "nfs-csi"

#     claim_ref {
#       name      = "immich-pvc"
#       namespace = var.namespace
#     }

#     persistent_volume_source {
#       csi {
#         driver    = "nfs.csi.k8s.io"
#         read_only = false
#         volume_attributes = {
#           "server" = var.nfs_server
#           "share"  = local.immich_path
#         }
#         volume_handle = "truenas/immich"
#       }
#     }

#     capacity = {
#       storage = "512Gi"
#     }

#     access_modes                     = ["ReadWriteMany"]
#     mount_options                    = ["nfsvers=4.1"]
#     persistent_volume_reclaim_policy = "Delete"
#   }
#   depends_on = [kubernetes_namespace_v1.immich]
# }

# resource "kubernetes_persistent_volume_claim_v1" "immich_pvc" {
#   metadata {
#     name      = "immich-pvc"
#     namespace = var.namespace
#   }

#   spec {
#     volume_name        = "immich-pv"
#     access_modes       = ["ReadWriteMany"]
#     storage_class_name = "nfs-csi"
#     resources {
#       requests = {
#         storage = "512Gi"
#       }
#     }
#   }

#   depends_on = [kubernetes_persistent_volume_v1.immich_pv]
# }

# resource "kubectl_manifest" "immich_cluster" {
#   yaml_body  = <<EOF
#     apiVersion: postgresql.cnpg.io/v1
#     kind: Cluster
#     metadata:
#       name: immich-database
#       namespace: immich
#     spec:
#       instances: 1
#       storage:
#         size: 1Gi
#       imageName: tensorchord/cloudnative-vectorchord:16.9-0.3.0
#       postgresql:
#         shared_preload_libraries:
#           - "vchord.so"
#         # This extension is loaded via the Database CRD at cloudnative-pg-database.yaml
#         extensions:
#           - name: vchord
#             image:
#               reference: ghcr.io/tensorchord/vchord-scratch:pg18-v1.1.1
#             dynamic_library_path:
#               - /usr/lib/postgresql/18/lib
#             extension_control_path:
#               - /usr/share/postgresql/18/
#     EOF
#   depends_on = [kubernetes_namespace_v1.immich]
# }

# resource "kubectl_manifest" "immich_database" {
#   yaml_body  = <<EOF
#     apiVersion: postgresql.cnpg.io/v1
#     kind: Database
#     metadata:
#       name: immich-database
#       namespace: immich
#     spec:
#       # "app"/"app" is auto-generated via cnpg in each cluster, adjust to your user/database
#       name: app
#       owner: app
#       cluster:
#         name: immich-database
#       extensions:
#         - name: vector
#           ensure: present
#         - name: vchord
#           ensure: present
#         - name: earthdistance
#           ensure: present
#         - name: cube
#           ensure: present
#     EOF
#   depends_on = [kubernetes_namespace_v1.immich]
# }

# resource "helm_release" "immich" {
#   name      = "immich"
#   chart     = local.chart
#   version   = local.chart_version
#   namespace = var.namespace
#   set = [
#     {
#       name  = "immich.persistence.library.existingClaim"
#       value = "immich-pvc"
#     },
#     {
#       name  = "controllers.main.containers.main.image.tag"
#       value = local.image_tag
#     },
#     {
#       name  = "controllers.main.containers.main.env.DB_HOSTNAME.valueFrom.secretKeyRef.name"
#       value = "immich-postgres-app"
#     },
#     {
#       name  = "controllers.main.containers.main.env.DB_HOSTNAME.valueFrom.secretKeyRef.key"
#       value = "host"
#     },

#     {
#       name  = "controllers.main.containers.main.env.DB_USERNAME.valueFrom.secretKeyRef.name"
#       value = "immich-postgres-app"
#     },
#     {
#       name  = "controllers.main.containers.main.env.DB_USERNAME.valueFrom.secretKeyRef.key"
#       value = "user"
#     },

#     {
#       name  = "controllers.main.containers.main.env.DB_PASSWORD.valueFrom.secretKeyRef.name"
#       value = "immich-postgres-app"
#     },
#     {
#       name  = "controllers.main.containers.main.env.DB_PASSWORD.valueFrom.secretKeyRef.key"
#       value = "password"
#     },

#     {
#       name  = "controllers.main.containers.main.env.DB_DATABASE_NAME.valueFrom.secretKeyRef.name"
#       value = "immich-postgres-app"
#     },
#     {
#       name  = "controllers.main.containers.main.env.DB_DATABASE_NAME.valueFrom.secretKeyRef.key"
#       value = "dbname"
#     },
#     {
#       name  = "valkey.enabled"
#       value = true
#     },
#     {
#       name  = "controllers.main.containers.main.resources.limits.cpu"
#       value = "200m"
#     },
#     {
#       name  = "controllers.main.containers.main.resources.limits.memory"
#       value = "2Gi"
#     },
#     {
#       name  = "controllers.main.containers.main.resources.requests.cpu"
#       value = "100m"
#     },
#     {
#       name  = "controllers.main.containers.main.resources.requests.memory"
#       value = "500Mi"
#     }
#   ]

#   depends_on = [kubectl_manifest.immich_postgres]
# }

# resource "helm_release" "istio_config" {
#   name      = "immich-ingress"
#   namespace = "istio-config"
#   chart     = "${path.root}/../helm/istio-config"
#   atomic    = true
#   set = [
#     {
#       name  = "hostname"
#       value = local.immich_hostname
#     },
#     {
#       name  = "path"
#       value = "/"
#     },
#     {
#       name  = "dest"
#       value = "immich-server.${var.namespace}.svc.cluster.local"
#     },
#     {
#       name  = "port"
#       value = 2283
#     }
#   ]

#   depends_on = [helm_release.immich]
# }

# resource "kubernetes_horizontal_pod_autoscaler_v2" "immich_hpa" {
#   metadata {
#     name      = "immich-hpa"
#     namespace = var.namespace
#   }
#   spec {
#     max_replicas = 3
#     min_replicas = 1
#     metric {
#       resource {
#         name = "cpu"
#         target {
#           average_utilization = 80
#           type                = "Utilization"
#         }
#       }
#       type = "Resource"
#     }
#     metric {
#       resource {
#         name = "memory"
#         target {
#           average_utilization = 80
#           type                = "Utilization"
#         }
#       }
#       type = "Resource"
#     }
#     scale_target_ref {
#       api_version = "apps/v1"
#       kind        = "Deployment"
#       name        = "immich-server"
#     }
#   }
#   depends_on = [helm_release.immich]
# }
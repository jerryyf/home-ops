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
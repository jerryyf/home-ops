resource "kubernetes_secret_v1" "webhook_aws_env" {
  metadata {
    name      = "webhook-aws-env"
    namespace = var.env
  }
  data = {
    "AWS_REGION"               = var.aws_region_lambda
    "AWS_ACCESS_KEY_ID"        = var.aws_access_key_id_lambda
    "AWS_SECRET_ACCESS_KEY"    = var.aws_secret_access_key_lambda
    "AWS_LAMBDA_FUNCTION_NAME" = var.aws_lambda_function_name
  }
}

resource "kubernetes_secret_v1" "webhook_telegram_env" {
  metadata {
    name      = "webhook-telegram-env"
    namespace = var.env
  }
  data = {
    "BOT_TOKEN" = var.bot_token
    "CHAT_ID"   = var.chat_id
  }
  depends_on = [kubernetes_secret_v1.webhook_aws_env]
}

resource "kubernetes_deployment_v1" "portfolio" {
  metadata {
    name      = "portfolio"
    namespace = var.env
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "portfolio"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "portfolio"
        }
      }
      spec {
        container {
          name              = "portfolio"
          image             = "ghcr.io/jerryyf/portfolio:1.1.3"
          image_pull_policy = "Always"
          port {
            container_port = "3000"
          }
          resources {
            limits = {
              "cpu"    = "200m"
              "memory" = "512Mi"
            }
            requests = {
              "cpu"    = "100m"
              "memory" = "256Mi"
            }
          }
          env {
            name = "CHAT_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.webhook_telegram_env.metadata[0].name
                key  = "CHAT_ID"
              }
            }
          }
          env {
            name = "BOT_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.webhook_telegram_env.metadata[0].name
                key  = "BOT_TOKEN"
              }
            }
          }
          env {
            name = "AWS_REGION"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.webhook_aws_env.metadata[0].name
                key  = "AWS_REGION"
              }
            }
          }
          env {
            name = "AWS_ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.webhook_aws_env.metadata[0].name
                key  = "AWS_ACCESS_KEY_ID"
              }
            }
          }
          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.webhook_aws_env.metadata[0].name
                key  = "AWS_SECRET_ACCESS_KEY"
              }
            }
          }
          env {
            name = "AWS_LAMBDA_FUNCTION_NAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.webhook_aws_env.metadata[0].name
                key  = "AWS_LAMBDA_FUNCTION_NAME"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_secret_v1.webhook_aws_env, kubernetes_secret_v1.webhook_telegram_env]
}

resource "kubernetes_service" "portfolio" {
  metadata {
    name      = "portfolio"
    namespace = var.env
  }
  spec {
    selector = {
      "app" = "portfolio"
    }
    port {
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
  depends_on = [kubernetes_deployment_v1.portfolio]
}

resource "helm_release" "istio_config" {
  name      = "portfolio-ingress"
  namespace = "istio-config"
  chart     = "${path.root}/helm/istio-config"
  atomic    = true
  set = [
    {
      name  = "certificate.create"
      value = true
    },
    {
      name  = "certificate.issuer"
      value = "cloudflare"
    },
    {
      name  = "hostname"
      value = var.base_url
    },
    {
      name  = "path"
      value = "/"
    },
    {
      name  = "dest"
      value = "portfolio.${var.env}.svc.cluster.local"
    },
    {
      name  = "port"
      value = 3000
    }
  ]
  depends_on = [kubernetes_service.portfolio]
}


terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
}

resource "kubernetes_namespace_v1" "gitea" {
  metadata {
    name   = "gitea"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "helm_release" "gitea" {
  name       = "gitea"
  repository = local.repository
  chart      = "gitea"
  version    = local.gitea_version
  namespace  = kubernetes_namespace_v1.gitea.metadata[0].name
  atomic     = true
  cleanup_on_fail = true

  depends_on = [ kubernetes_namespace_v1.gitea ]
}

resource "helm_release" "istio_config" {
  name      = "gitea-ingress"
  namespace = "istio-ingress"
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
      value = "gitea-http.gitea.svc.cluster.local"
    },
    {
      name  = "port"
      value = 3000
    }
  ]

  depends_on = [helm_release.gitea]
}


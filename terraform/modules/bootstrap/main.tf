resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "helm_release" "argocd" {
  max_history      = 5
  name             = "argocd"
  chart            = "argo-cd"
  repository       = local.argocd_repo
  namespace        = kubernetes_namespace_v1.argocd.metadata[0].name
  version          = local.argocd_version
  create_namespace = true
  set = [
    {
      name  = "params.server.insecure"
      value = "true"
    },
    {
      name  = "global.domain"
      value = "argocd.home.arpa"
    }
  ]
}
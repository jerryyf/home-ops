resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
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
}
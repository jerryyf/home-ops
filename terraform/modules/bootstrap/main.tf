resource "kubernetes_namespace_v1" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace_v1" "istio_config" {
  metadata {
    name = "istio-config"
  }
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = local.istio_repo
  chart            = "base"
  namespace        = kubernetes_namespace_v1.istio_system.metadata[0].name
  version          = local.istio_version
  atomic           = true
  create_namespace = true
  set = [{
    name  = "defaultRevision"
    value = "default"
  }]
}

resource "helm_release" "istiod" {
  name             = "istiod"
  repository       = local.istio_repo
  chart            = "istiod"
  namespace        = kubernetes_namespace_v1.istio_system.metadata[0].name
  version          = local.istio_version
  atomic           = true
  create_namespace = true
  set = [{
    name  = "global.platform"
    value = local.platform
  }]
  depends_on = [helm_release.istio_base]
}

resource "kubernetes_namespace_v1" "istio_ingress" {
  metadata {
    name = "istio-ingress"
  }
}

resource "helm_release" "istio_ingress" {
  name             = "istio-ingress"
  repository       = local.istio_repo
  chart            = "gateway"
  namespace        = kubernetes_namespace_v1.istio_ingress.metadata[0].name
  version          = local.istio_version
  atomic           = true
  create_namespace = true
  set = [{
    name  = "global.platform"
    value = local.platform
  }]
  depends_on = [helm_release.istio_base]
}

resource "kubernetes_namespace_v1" "cnpg_system" {
  metadata {
    name = "cnpg-system"
  }
}

resource "helm_release" "cnpg" {
  name             = "cnpg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  namespace        = kubernetes_namespace_v1.cnpg_system.metadata[0].name
  version          = "0.28.3"
  atomic           = true
  create_namespace = true
}

resource "helm_release" "csi_driver_nfs" {
  name             = "csi-driver-nfs"
  repository       = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart            = "csi-driver-nfs"
  namespace        = "kube-system"
  version          = "4.11.0"
  atomic           = true
  create_namespace = true
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "oci://quay.io/jetstack/charts/cert-manager"
  namespace        = kubernetes_namespace_v1.cert_manager.metadata[0].name
  version          = "v1.19.0"
  atomic           = true
  create_namespace = true
  set = [
    {
      name  = "crds.enabled"
      value = true
    }
  ]
}

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
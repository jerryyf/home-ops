resource "kubernetes_namespace_v1" "istio_config" {
  metadata {
    name = "istio-config"
  }
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = local.repo
  chart            = "base"
  namespace        = "istio-system"
  version          = local.version
  atomic           = true
  create_namespace = true
  set = [{
    name  = "defaultRevision"
    value = "default"
  }]
}

resource "helm_release" "istiod" {
  name             = "istiod"
  repository       = local.repo
  chart            = "istiod"
  namespace        = "istio-system"
  version          = local.version
  atomic           = true
  create_namespace = true

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name             = "istio-ingress"
  repository       = local.repo
  chart            = "gateway"
  namespace        = "istio-ingress"
  version          = local.version
  atomic           = true
  create_namespace = true

  depends_on = [helm_release.istiod]
}

resource "kubernetes_manifest" "istio_telemetry" {
  manifest = {
    "apiVersion" = "telemetry.istio.io/v1"
    "kind"       = "Telemetry"
    "metadata" = {
      "name"      = "mesh-default"
      "namespace" = "istio-system"
    }
    "spec" = {
      "accessLogging" = [
        {
          "providers" = [
            {
              "name" = "envoy"
            },
          ]
        },
      ]
    }
  }
  depends_on = [helm_release.istio_base]
}
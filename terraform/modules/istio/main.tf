terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
  }
}

resource "kubernetes_namespace_v1" "istio_config" {
  metadata {
    name = "istio-config"
  }
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "istio"
  chart            = "base"
  namespace        = "istio-system"
  version          = "1.27.0"
  atomic           = true
  create_namespace = true
  set = [{
    name  = "defaultRevision"
    value = "default"
  }]
}

resource "helm_release" "istiod" {
  name             = "istiod"
  repository       = "istio"
  chart            = "istiod"
  namespace        = "istio-system"
  version          = "1.27.0"
  atomic           = true
  create_namespace = true
  set = [{
    name  = "global.platform"
    value = "k3s"
  }]
  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name             = "istio-ingress"
  repository       = "istio"
  chart            = "gateway"
  namespace        = "istio-ingress"
  version          = "1.27.0"
  atomic           = true
  create_namespace = true
  set = [{
    name  = "global.platform"
    value = "k3s"
  }]
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
  depends_on = [helm_release.istio_ingress]
}
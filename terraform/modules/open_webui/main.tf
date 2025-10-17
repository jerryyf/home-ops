terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
}

resource "kubernetes_namespace_v1" "open_webui" {
  metadata {
    name = "open-webui"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "helm_release" "open_webui" {
  name            = "open-webui"
  repository      = "https://helm.openwebui.com/"
  chart           = "open-webui"
  namespace       = "open-webui"
  version         = "8.8.0"
  atomic          = true
  cleanup_on_fail = true
  set = [
    {
      name  = "resources.requests.cpu"
      value = "200m"
    },
    {
      name  = "resources.requests.memory"
      value = "1Gi"
    },
    {
      name  = "resources.limits.cpu"
      value = "500m"
    },
    {
      name  = "resources.limits.memory"
      value = "2Gi"
    },
    {
      name  = "ollama.enabled"
      value = false
    },
    {
      name  = "pipelines.enabled"
      value = false
    },
  ]
}
resource "helm_release" "open_webui" {
  name            = "open-webui"
  repository      = "https://helm.openwebui.com/"
  chart           = "open-webui"
  namespace       = "staging"
  version         = "8.12.2"
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
    {
      name  = "pipelines.enabled"
      value = false
    },
    {
      name  = "persistence.storageClass"
      value = "nfs-csi"
    },
  ]
}

resource "helm_release" "istio_config" {
  name      = "open-webui-ingress"
  namespace = "istio-config"
  chart     = "${path.root}/../helm/istio-config"
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
      value = "staging.${var.base_url}"
    },
    {
      name  = "path"
      value = "/chat"
    },
    {
      name  = "dest"
      value = "open-webui.staging.svc.cluster.local"
    },
    {
      name  = "port"
      value = 80
    }
  ]

  depends_on = [helm_release.open_webui]
}

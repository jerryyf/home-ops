resource "helm_release" "jellyfin" {
  name             = "jellyfin"
  chart            = "jellyfin/jellyfin"
  namespace        = var.namespace
  atomic           = true
  create_namespace = true
  set = [
    {
      name  = "persistence.config.storageClass"
      value = "nfs-csi"
    },
    {
      name  = "persistence.media.storageClass"
      value = "nfs-csi"
    }
  ]
}

resource "helm_release" "istio_config" {
  name      = "jellyfin-ingress"
  namespace = "istio-config"
  chart     = "${path.root}/../helm/istio-config"
  atomic    = true
  set = [
    {
      name  = "hostname"
      value = local.jellyfin_hostname
    },
    {
      name  = "path"
      value = "/jellyfin"
    },
    {
      name  = "dest"
      value = "jellyfin.${var.namespace}.svc.cluster.local"
    },
    {
      name  = "port"
      value = 8096
    }
  ]

  depends_on = [helm_release.jellyfin]
}

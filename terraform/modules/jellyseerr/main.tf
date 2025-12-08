resource "helm_release" "jellyseerr" {
  name      = "jellyseerr"
  chart     = "oci://ghcr.io/fallenbagel/jellyseerr/jellyseerr-chart"
  namespace = var.namespace
  atomic    = true
}

resource "helm_release" "istio_config" {
  name      = "jellyseerr-ingress"
  namespace = "istio-config"
  chart     = "${path.root}/../helm/istio-config"
  atomic    = true
  set = [
    {
      name  = "hostname"
      value = local.jellyseerr_hostname
    },
    {
      name  = "path"
      value = "/"
    },
    {
      name  = "dest"
      value = "jellyseerr-jellyseerr-chart.${var.namespace}.svc.cluster.local"
    },
    {
      name  = "port"
      value = 80
    }
  ]

  depends_on = [helm_release.jellyseerr]
}

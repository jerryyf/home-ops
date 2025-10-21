resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "oci://quay.io/jetstack/charts/cert-manager"
  namespace        = "cert-manager"
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

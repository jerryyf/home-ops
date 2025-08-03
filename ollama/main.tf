terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "ollama_dev" {
  name       = "ollama"
  repository = "https://helm.otwld.com"
  chart      = "ollama"
  namespace  = "dev"
  cleanup_on_fail = true
}

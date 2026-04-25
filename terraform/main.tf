terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_namespace" "devops_tp" {
  metadata {
    name = var.namespace
    labels = {
      managed-by = "terraform"
      project    = "devops-tp"
    }
  }
}

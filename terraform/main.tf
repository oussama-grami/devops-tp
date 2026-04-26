terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path    = "/var/jenkins_home/.kube/config"
  config_context = "kind-devops-tp"
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

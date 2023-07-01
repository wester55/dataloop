provider "helm" {
  kubernetes {
    config_path = "${var.home}/.kube/${var.environment}-${var.customer}-kubeconfig"
  }
}

provider "helm" {
  kubernetes {
    config_path = "${var.home}/.kube/config"
  }
}

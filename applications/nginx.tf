# Install NGINX Ingress Controller using Helm provider
resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"

  create_namespace = true
  namespace        = "services"
}

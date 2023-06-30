# Install NGINX Ingress Controller using Helm provider
resource "helm_release" "nginx" {
  depends_on = [google_container_cluster.primary, null_resource.cluster-admin-binding]
  name       = "nginx"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"

  create_namespace = true
  namespace        = "services"
}

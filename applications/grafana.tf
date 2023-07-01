# Install Grafana using Helm provider
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"

  create_namespace = true
  namespace        = "monitoring"

  values = [
    <<EOF
    persistence:
      enabled: true
      size: 10Gi
    service:
      type: LoadBalancer
    EOF
  ]
}

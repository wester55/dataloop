# Install Prometheus using Helm provider
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  create_namespace = true
  namespace        = "monitoring"

#  values = [
#    <<EOF
#    serverFiles:
#      prometheus.yml:
#        scrape_configs:
#          - job_name: 'scraping'
#            static_configs:
#              - targets: ['my-target']
#    EOF
#  ]
}

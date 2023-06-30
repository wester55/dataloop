# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.gcp_details.project}-gke"
  location = var.gcp_details.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.gcp_details.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_details.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.gcp_details.project
    }

    # preemptible  = true
    machine_type = "n2-standard-2"
    tags         = ["gke-node", "${var.gcp_details.project}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

resource "null_resource" "sa_activate" {
  depends_on = [google_container_cluster.primary, google_container_node_pool.primary_nodes]
  provisioner "local-exec" {
    command = "gcloud auth activate-service-account ${var.gcp_details.service_account}@${var.gcp_details.project}.iam.gserviceaccount.com --key-file=${var.home}/.ssh/gcp-${var.customer}-${var.environment}-credentials.json"
  }
}

resource "null_resource" "kubectl_configure" {
  depends_on = [null_resource.sa_activate]
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.gcp_details.project}-gke --region ${var.gcp_details.region} --project ${var.gcp_details.project}"
  }
}

resource "null_resource" "cluster-admin-binding" {
  depends_on = [null_resource.kubectl_configure]
  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)"
  }
}

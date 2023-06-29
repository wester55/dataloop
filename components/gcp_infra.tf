variable "customer" {
  description = "customer modified"
}

variable "environment" {
  description = "environment modified"
}

variable "home" {
  description = "current user home"
}


provider "google" {
  project     = var.gcp_details.project
  region      = var.gcp_details.region
  credentials = "${var.home}/.ssh/gcp-${var.customer}-${var.environment}-credentials.json"
}

variable "gcp_details" {
  type = map(string)
  description = "gcp details"
}

variable "gke_details" {
  type = map(string)
  description = "gke details"
  default = {
    gke_num_nodes = 2
  }
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.gcp_details.project}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.gcp_details.project}-subnet"
  region        = var.gcp_details.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.gke_details.subnet
}



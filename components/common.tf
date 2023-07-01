terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.47.0"
    }

  }

  required_version = ">= 1.3"
}

variable "customer" {
  description = "customer modified"
}

variable "environment" {
  description = "environment modified"
}

variable "home" {
  description = "current user home"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "your-project-id"  # CHANGE THIS!
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "demo-cluster"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "demo-gke-vpc"
}

variable "subnet_cidr" {
  description = "CIDR for the subnet"
  type        = string
  default     = "10.0.0.0/14"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

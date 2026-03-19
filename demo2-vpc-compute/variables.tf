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

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "demo-vpc"
}

variable "subnet_cidr" {
  description = "CIDR for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "demo-instance"
}

variable "machine_type" {
  description = "Machine type (e2-micro is free tier)"
  type        = string
  default     = "e2-micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

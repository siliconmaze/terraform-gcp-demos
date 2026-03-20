variable "project_name" { type = string }
variable "environment" { type = string }
variable "project_id" { type = string }
variable "region" { type = string; default = "us-central1" }
variable "network_cidr" { type = string; default = "10.0.0.0/16" }
variable "subnet_cidrs" { type = map(string); default = {} }
variable "routing_mode" { type = string; default = "REGIONAL" }
variable "enable_private_google_access" { type = bool; default = true }
variable "enable_cloud_dns" { type = bool; default = true }
variable "dns_zone_name" { type = string; default = "" }
variable "enable_flow_logs" { type = bool; default = false }
variable "labels" { type = map(string); default = {} }

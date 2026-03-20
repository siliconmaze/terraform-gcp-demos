variable "project_id" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }

variable "cluster_name" { type = string }
variable "location" { type = string }
variable "zone" { type = string }

variable "network_name" { type = string }
variable "subnet_name" { type = string }
variable "ip_range_pods" { type = string; default = "pods" }
variable "ip_range_services" { type = string; default = "services" }

variable "num_nodes" { type = number; default = 2 }
variable "machine_type" { type = string; default = "e2-medium" }
variable "disk_size_gb" { type = number; default = 100 }

variable "enable_private_nodes" { type = bool; default = true }
variable "enable_private_endpoint" { type = bool; default = false }
variable "master_cidr" { type = string; default = "172.16.0.0/28" }

variable "allowed_master_cidrs" { type = list(string); default = [] }

variable "enable_autoscaling" { type = bool; default = true }
variable "min_nodes" { type = number; default = 1 }
variable "max_nodes" { type = number; default = 5 }

variable "maintenance_window" { type = map(string); default = {} }

variable "enable_shielded_nodes" { type = bool; default = true }
variable "enable_network_policy" { type = bool; default = false }
variable "enable_vpa" { type = bool; default = false }

variable "create_secondary_node_pool" { type = bool; default = false }
variable "secondary_node_count" { type = number; default = 0 }
variable "secondary_machine_type" { type = string; default = "n2-standard-4" }
variable "secondary_disk_size" { type = number; default = 100 }
variable "secondary_min_nodes" { type = number; default = 0 }
variable "secondary_max_nodes" { type = number; default = 3 }

variable "labels" { type = map(string); default = {} }

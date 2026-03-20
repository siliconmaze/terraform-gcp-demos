variable "project_id" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }

variable "instance_name" { type = string }

variable "database_version" { type = string; default = "POSTGRES_15" }
variable "region" { type = string; default = "us-central1" }
variable "tier" { type = string; default = "db-f1-micro" }
variable "disk_size" { type = number; default = 20 }
variable "availability_type" { type = string; default = "ZONAL" }

variable "network_name" { type = string }

variable "enable_public_ip" { type = bool; default = false }

variable "backup_enabled" { type = bool; default = true }
variable "backup_start_time" { type = string; default = "03:00" }

variable "maintenance_window" {
  type = object({ day = number, hour = number })
  default = { day = 7, hour = 3 }
}

variable "database_flags" { type = list(map(string)); default = [] }

variable "database_name" { type = string; default = "appdb" }
variable "database_charset" { type = string; default = "" }
variable "database_collation" { type = string; default = "" }

variable "create_user" { type = bool; default = true }
variable "username" { type = string; default = "dbadmin" }
variable "password" { type = string; default = ""; sensitive = true }

variable "create_ssl_cert" { type = bool; default = false }

variable "deletion_protection" { type = bool; default = false }
variable "labels" { type = map(string); default = {} }

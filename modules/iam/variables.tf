variable "project_id" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }

variable "enable_workload_identity" { type = bool; default = false }
variable "k8s_service_account_name" { type = string; default = "default" }
variable "iam_roles" { type = list(string); default = [] }

variable "labels" { type = map(string); default = {} }

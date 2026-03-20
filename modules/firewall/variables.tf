variable "project_id" { type = string }
variable "network_name" { type = string }
variable "environment" { type = string }
variable "allowed_ssh_cidrs" { type = list(string); default = [] }
variable "allow_internal" { type = bool; default = true }
variable "labels" { type = map(string); default = {} }

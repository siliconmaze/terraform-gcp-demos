variable "project_id" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "region" { type = string; default = "us-central1" }

variable "name" { type = string }
variable "network_name" { type = string }
variable "subnet_name" { type = string }
variable "instance_group" { type = string; default = "" }

variable "backend_port" { type = number; default = 80 }
variable "health_check_port" { type = number; default = 80 }
variable "health_check_path" { type = string; default = "/" }
variable "health_check_response" { type = string; default = "" }
variable "health_check_interval" { type = number; default = 15 }
variable "health_check_timeout" { type = number; default = 5 }
variable "health_check_healthy_threshold" { type = number; default = 2 }
variable "health_check_unhealthy_threshold" { type = number; default = 2 }

variable "labels" { type = map(string); default = {} }

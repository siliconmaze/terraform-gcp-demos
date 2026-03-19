variable "bucket_name" {
  description = "Name of the GCS bucket (must be globally unique)"
  type        = string
  default     = "demo-bucket-terraform"
}

variable "location" {
  description = "GCP location for the bucket"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Storage class (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = "STANDARD"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "owner_email" {
  description = "Email of the bucket owner"
  type        = string
  default     = ""  # Set this to your email!
}

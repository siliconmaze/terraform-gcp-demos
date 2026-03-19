# ==============================================================================
# Demo 1: Cloud Storage Bucket
# Objective: Create a GCS bucket for file storage
# ==============================================================================

resource "google_storage_bucket" "this" {
  name          = var.bucket_name
  location      = var.location
  storage_class = var.storage_class
  
  uniform_bucket_level_access = true
  
  labels = {
    environment = var.environment
    demo        = "demo1-gcs"
    managedby   = "terraform"
  }
}

resource "google_storage_bucket_iam_member" "admin" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectAdmin"
  member = "user:${var.owner_email}"
}

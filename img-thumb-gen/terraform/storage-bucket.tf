# Create bucket that will host the source code
resource "google_storage_bucket" "source_bucket" {
  name = "${var.GOOGLE_CLOUD_SOURCE_BUCKET_NAME}"
  location = var.GOOGLE_CLOUD_BUCKET_REGION

  force_destroy = true 
  uniform_bucket_level_access = true
}

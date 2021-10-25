resource "google_storage_bucket" "site-bucket-public" {
    name = var.MODULE_SITE_BUCKET_PUBLIC_NAME
    location = var.GOOGLE_CLOUD_BUCKET_REGION
}

resource "google_storage_bucket" "site-bucket-secure" {
    name = var.MODULE_SITE_BUCKET_SECURE_NAME
    location = var.GOOGLE_CLOUD_BUCKET_REGION
}
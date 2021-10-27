resource "google_storage_bucket" "site_bucket_public" {
    name = var.MODULE_SITE_BUCKET_PUBLIC_NAME
    location = var.GOOGLE_CLOUD_BUCKET_REGION
}

resource "google_storage_bucket" "site_bucket_private" {
    name = var.MODULE_SITE_BUCKET_PRIVATE_NAME
    location = var.GOOGLE_CLOUD_BUCKET_REGION
}
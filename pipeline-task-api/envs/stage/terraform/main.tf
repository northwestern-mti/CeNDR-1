module "lifesciences" {
  source = "./lifesciences"
}

module "cloud_run" {
  source = "./cloud-run"
  app_project = var.app_project
  gcp_region = var.gcp_region
  gcp_auth_file = var.gcp_auth_file
  environment = var.environment
}

module "pub_sub" {
  source = "./pubsub"
  app_project = var.app_project
  push_endpoint = module.cloud_run.pipeline-api-url
}

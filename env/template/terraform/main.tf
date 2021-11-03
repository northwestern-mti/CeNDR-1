module "api_pipeline_task" {
  source = "../../../api/pipeline-task/terraform"
  GOOGLE_CLOUD_PROJECT_ID = var.GOOGLE_CLOUD_PROJECT_ID
  GOOGLE_CLOUD_REGION = var.GOOGLE_CLOUD_REGION
  
  MODULE_API_PIPELINE_TASK_CONTAINER_NAME = var.MODULE_API_PIPELINE_TASK_CONTAINER_NAME
  MODULE_API_PIPELINE_TASK_CONTAINER_VERSION = var.MODULE_API_PIPELINE_TASK_CONTAINER_VERSION
  MODULE_API_PIPELINE_TASK_REPORT_BUCKET_NAME = var.MODULE_API_PIPELINE_TASK_REPORT_BUCKET_NAME
  MODULE_API_PIPELINE_TASK_WORK_BUCKET_NAME = var.MODULE_API_PIPELINE_TASK_WORK_BUCKET_NAME
  MODULE_API_PIPELINE_TASK_SERVICE_ACCOUNT_NAME = var.MODULE_API_PIPELINE_TASK_SERVICE_ACCOUNT_NAME

  ENVIRONMENT = var.ENVIRONMENT

  depends_on = [
    google_project_service.iam,
    google_project_service.run,
    google_project_service.cloudbuild,
    google_project_service.lifesciences, 
    google_project_service.container_registry
  ]
}

module "site" {
  source = "../../../site/terraform"
  GOOGLE_CLOUD_PROJECT_ID = var.GOOGLE_CLOUD_PROJECT_ID
  GOOGLE_CLOUD_PROJECT_NUMBER = var.GOOGLE_CLOUD_PROJECT_NUMBER
  GOOGLE_CLOUD_APP_LOCATION = var.GOOGLE_CLOUD_APP_LOCATION
  GOOGLE_CLOUD_BUCKET_REGION = upper(var.GOOGLE_CLOUD_REGION)
  
  DB_INSTANCE_CONNECTION_NAME = module.db.db_connection_name
  
  MODULE_SITE_BUCKET_PUBLIC_NAME = var.MODULE_SITE_BUCKET_PUBLIC_NAME
  MODULE_SITE_BUCKET_PRIVATE_NAME = var.MODULE_SITE_BUCKET_PRIVATE_NAME
  MODULE_SITE_CONTAINER_NAME = var.MODULE_SITE_CONTAINER_NAME
  MODULE_SITE_CONTAINER_VERSION = var.MODULE_SITE_CONTAINER_VERSION
  
  # secret.tfvars
  ANDERSEN_LAB_STRAIN_SHEET = "${var.ANDERSEN_LAB_STRAIN_SHEET}"
  CENDR_PUBLICATIONS_SHEET = var.CENDR_PUBLICATIONS_SHEET
  RECAPTCHA_PUBLIC_KEY = var.RECAPTCHA_PUBLIC_KEY
  RECAPTCHA_PRIVATE_KEY = var.RECAPTCHA_PRIVATE_KEY
  ELEVATION_API_KEY = var.ELEVATION_API_KEY  

  ENVIRONMENT = var.ENVIRONMENT

  depends_on = [
    google_project_service.iam,
    google_project_service.container_registry,
    google_project_service.app_engine_flex,
    google_project_service.sql_admin,
    google_project_service.secret_manager
  ]
}


module "img_thumb_gen" {
  source = "../../../img-thumb-gen/terraform"
  GOOGLE_CLOUD_PROJECT_ID = var.GOOGLE_CLOUD_PROJECT_ID
  GOOGLE_CLOUD_PROJECT_NUMBER = var.GOOGLE_CLOUD_PROJECT_NUMBER
  GOOGLE_CLOUD_REGION = var.GOOGLE_CLOUD_REGION
  GOOGLE_CLOUD_BUCKET_REGION = upper(var.GOOGLE_CLOUD_REGION)
  GOOGLE_CLOUD_SOURCE_BUCKET_NAME = var.GOOGLE_CLOUD_SOURCE_BUCKET_NAME

  MODULE_IMG_THUMB_GEN_SOURCE_BUCKET_NAME = module.site.site_bucket_public
  MODULE_IMG_THUMB_GEN_SOURCE_PATH = var.MODULE_IMG_THUMB_GEN_SOURCE_PATH

  depends_on = [
    google_project_service.cloud_function,
    google_project_service.cloudbuild
  ]
}

module "db" {
  source = "../../../db/terraform"
  GOOGLE_CLOUD_PROJECT_ID = var.GOOGLE_CLOUD_PROJECT_ID
  GOOGLE_CLOUD_REGION = var.GOOGLE_CLOUD_REGION
  MODULE_DB_POSTGRES_INSTANCE_NAME = var.MODULE_DB_POSTGRES_INSTANCE_NAME
  MODULE_DB_POSTGRES_DB_NAME = var.MODULE_DB_POSTGRES_DB_NAME
  MODULE_DB_POSTGRES_DB_USER = var.MODULE_DB_POSTGRES_DB_USER
  MODULE_DB_POSTGRES_DB_STAGE_NAME = var.MODULE_DB_POSTGRES_DB_STAGE_NAME
  MODULE_DB_POSTGRES_DB_PASSWORD = var.MODULE_DB_POSTGRES_DB_PASSWORD
  
  depends_on = [
    google_project_service.sql_admin
  ]
}
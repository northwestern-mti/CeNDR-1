variable "GOOGLE_CLOUD_PROJECT_NAME" { }
variable "GOOGLE_CLOUD_REGION" { }
variable MODULE_API_PIPELINE_TASK_REPORT_BUCKET_NAME { }
variable MODULE_API_PIPELINE_TASK_WORK_BUCKET_NAME { }
variable "ENVIRONMENT" { }

variable MODULE_API_PIPELINE_TASK_SERVICE_ACCOUNT_NAME {
  description = "Name of the service account which will execute Nemascan Lifesciences Pipelines"
}

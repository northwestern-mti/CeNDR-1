variable "gcp_project" {
  description = "The Google Cloud project name that resources will be deployed under"
  default     = "andersen-lab-stage"
}

variable "gcp_region" {
  description = "Region where the project will be deployed"
  default     = "us-central1"
}

variable gcp_report_bucket_name {
  description = "Name of the bucket where users' pipeline output reports are published"
  default     = "user-reports"
}

variable gcp_work_bucket_name {
  description = "Name of the bucket that nextflow will use to store work in-progress"
  default     = "pipeline-work"
}

variable nscalc_service_account_name {
  description = "Name of the service account which will execute Nemascan Lifesciences Pipelines"
  default     = "nscalc-pipeline"
}

variable "environment" {
  description = "Production or Development environment"
  default     = "development"
}

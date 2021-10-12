variable "app_project" {
  description = "The Google Cloud project name that resources will be deployed under"
  default     = "andersen-lab-302418"
}

variable "app_project_id" {
  description = "The Google Cloud project ID that resources will be deployed under"
  default     = "1095519981833"
}

variable "gcp_region" {
  description = "Region where the project will be deployed"
  default     = "us-central1"
}

variable "gcp_auth_file" {
  description = "Name of the JSON File containing the terraform service account private key"
  default     = "terraform-service-account.json"
}

variable nscalc_service_account_name {
  description = "Name of the service account which will execute Nemascan Lifesciences Pipelines"
  default = "nscalc-pipeline"
}

variable "environment" {
  description = "Production or Development environment"
  default     = "development"
}

variable "app_project" {
  description = "The Google Cloud project name that resources will be deployed under"
  default     = "andersen-lab-302418"
}

variable "push_endpoint" {
  description = "The URL of the deployed CloudRun service"
}
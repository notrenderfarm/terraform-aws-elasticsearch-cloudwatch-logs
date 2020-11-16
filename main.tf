provider "aws" {
  region = var.region
}

provider "google" {
  project = var.gcp_options.project_id
}

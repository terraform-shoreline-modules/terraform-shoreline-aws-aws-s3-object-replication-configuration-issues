terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "issues_with_amazon_s3_object_replication_configuration" {
  source    = "./modules/issues_with_amazon_s3_object_replication_configuration"

  providers = {
    shoreline = shoreline
  }
}
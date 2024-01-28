##################################################################
# Terraform block to specify Terraform settings and configurations
##################################################################

terraform {

  # Define the providers required for this Terraform configuration
  required_providers {

  # AWS provider configuration
    aws = {
      source  = "hashicorp/aws" # Specifies the source for the AWS provider
      version = "~> 5.34.0" # Sets the version constraint for the AWS provider
    }

  # Random provider configuration
    random = {
      source  = "hashicorp/random" # Specifies the source for the Random provider
      version = "~> 3.6.0" # Sets the version constraint for the Random provider
    }

  # Archive provider configuration
    archive = {
      source  = "hashicorp/archive" # Specifies the source for the Archive provider
      version = "~> 2.4.2" # Sets the version constraint for the Archive provider
    }
  }

# Specifies the required Terraform version for this configuration
  required_version = "~> 1.4" # Sets a version constraint for Terraform itself
}


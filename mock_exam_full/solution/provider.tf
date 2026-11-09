provider "aws" {
  region = "ap-southeast-1"

  # Mock settings for offline testing
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "mock"
  secret_key                  = "mock"
}

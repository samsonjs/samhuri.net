provider "aws" {
  region = "${var.aws_region}"
}

# Required for CloudFront certificates.
provider "aws" {
  alias = "us_east_1"
  region = "us-east-1"
}

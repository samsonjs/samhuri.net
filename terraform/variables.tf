variable "env" {
  default = "test"
  description = "Environment name"
}

variable "aws_region" {
  default = "us-west-2"
  description = "The region for all resources."
}

/*
variable "route53_zone" {
  default = "samhuri.net."
  description = "The Route53 zone for DNS records."
}

variable "cdn_certificate" {
  default = "*.samhuri.net"
  description = "Name of the certificate for CloudFront."
}
*/

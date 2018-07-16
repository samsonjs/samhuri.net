resource "aws_cloudfront_distribution" "blog" {
  enabled = true
  is_ipv6_enabled = true

  origin {
    /*domain_name = "${aws_s3_bucket.blog_public.bucket_domain_name}"*/
    origin_id = "S3-${aws_s3_bucket.blog_public.bucket}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  viewer_certificate {
    /*acm_certificate_arn = "${data.aws_acm_certificate.blog.arn}"*/
    cloudfront_default_certificate = true
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  logging_config {
    include_cookies = false
    bucket = "${aws_s3_bucket.logs.bucket_domain_name}"
    prefix = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.blog_public.bucket}"
    compress = false

    forwarded_values {
      query_string = false
      headers = [
        "Origin",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
      ]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    App = "samhuri.net"
    ManagedBy = "terraform"
  }
}

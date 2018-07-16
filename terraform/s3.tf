resource "aws_s3_bucket" "logs" {
  bucket = "samhuri.net-logs-${var.aws_region}"
  acl = "log-delivery-write"

  tags {
    App = "samhuri.net"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket" "blog_private" {
  bucket = "samhuri.net-${var.aws_region}-private"
  acl = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.logs.id}"
    target_prefix = "samhuri.net-${var.aws_region}-private/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    App = "samhuri.net"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_notification" "blog_notification" {
  bucket = "${aws_s3_bucket.blog_private.id}"

  lambda_function {
    lambda_arn = "${aws_lambda_function.blog_render.arn}"
    events = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket" "blog_public" {
  bucket = "samhuri.net-${var.aws_region}-public"
  acl = "public-read"

  logging {
    target_bucket = "${aws_s3_bucket.logs.id}"
    target_prefix = "samhuri.net-${var.aws_region}-public/"
  }

  tags {
    App = "samhuri.net"
    ManagedBy = "terraform"
  }
}

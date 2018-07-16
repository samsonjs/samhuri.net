resource "aws_iam_role" "lambda" {
  name = "samhuri.net-${var.aws_region}-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "blog_render" {
  function_name = "samhuri.net-blog-render"
  description = "[samhuri.net] render blog"
  filename = "lambda-blog-render.zip"
  source_code_hash = "${base64sha256(file("lambda-blog-render.zip"))}"
  role = "${aws_iam_role.lambda.arn}"
  handler = "???"
  runtime = "go1.x"

  tags {
    App = "samhuri.net"
    ManagedBy = "terraform"
  }
}

resource "aws_lambda_permission" "allow_s3_notifications" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.blog_render.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.blog_private.arn}"
}

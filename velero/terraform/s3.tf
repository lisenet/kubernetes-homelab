# Set up a bucket for the Velero backups to write to.

resource "aws_s3_bucket" "velero" {
  bucket = "${var.local_prefix}-velero-backups"
  acl    = "private"

  versioning {
    enabled    = false
    mfa_delete = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = "${var.local_prefix}-velero-backups"
    Project = var.local_prefix
  }
}

resource "aws_s3_bucket_public_access_block" "velero" {
  bucket                  = aws_s3_bucket.velero.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.velero]
}

resource "aws_s3_bucket_policy" "velero_bucket_policy" {
  bucket = aws_s3_bucket.velero.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Require SSL",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.velero.arn}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY

  depends_on = [aws_s3_bucket.velero]
}

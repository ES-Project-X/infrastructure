resource "aws_s3_bucket" "project_x" {
  bucket = "project-x-storage"
}

resource "aws_s3_bucket_ownership_controls" "project_x" {
  bucket = aws_s3_bucket.project_x.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "project_x" {
  bucket = aws_s3_bucket.project_x.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "project_x" {
  depends_on = [
    aws_s3_bucket_ownership_controls.project_x,
    aws_s3_bucket_public_access_block.project_x,
  ]

  bucket = aws_s3_bucket.project_x.id
  acl    = "public-read"
}
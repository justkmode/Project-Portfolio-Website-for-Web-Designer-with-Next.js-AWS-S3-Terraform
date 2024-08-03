provider "aws" {
  region = "eu-north-1"
}

# Import existing S3 Bucket
resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {
  bucket = "nextjs-portfolio-bucket-ss-justyna"
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "nextjs_bucket_ownership_controls" {
  bucket = "nextjs-portfolio-bucket-ss-justyna"

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {
  block_public_acls       = false
  block_public_policy     = false
  bucket                  = "nextjs-portfolio-bucket-ss-justyna"
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
  bucket = aws_s3_bucket_acl.nextjs_bucket_acl.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${aws_s3_bucket_acl.nextjs_bucket_acl.bucket}/*"
      }
    ]
  })
}

# Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for Next.JS portfolio site"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "nextjs_distribution" {
  origin {
    domain_name = "${aws_s3_bucket_acl.nextjs_bucket_acl.bucket}.s3.amazonaws.com"
    origin_id   = "s3-nextjs-portfolio-bucket"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Next.js portfolio site"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-nextjs-portfolio-bucket"

    forwarded_values {
      query_string = false
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

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

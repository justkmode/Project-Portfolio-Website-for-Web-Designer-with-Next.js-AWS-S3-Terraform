terraform {
  backend "s3" {
    bucket         = "nextjs-portfolio-bucket-ss-justyna"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "nextjs-portfolio-locks-justyna"
  }
}

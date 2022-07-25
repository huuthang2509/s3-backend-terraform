output "config" {
  value = {
    bucket = aws_s3_bucket.s3_bucket.bucket
    
  }
}
resource "aws_athena_database" "dbTwitter" {
  name   = "dbjmsj01"
  bucket = "${aws_s3_bucket.bucket.bucket}"
}
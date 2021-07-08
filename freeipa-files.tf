# zip zk files
data "archive_file" "freeipa-s3-codebuild-archive" {
  type = "zip"
  source {
    content = templatefile("freeipa-files/freeipa-dockerfile.tmpl", {
    })
    filename = "Dockerfile"
  }
  source {
    content  = file("freeipa-files/buildspec.yml")
    filename = "buildspec.yml"
  }
  output_path = "freeipa-files/freeipa.zip"
}

# to s3
resource "aws_s3_bucket_object" "freeipa-s3-codebuild-object" {
  bucket         = aws_s3_bucket.freeipa-bucket.id
  key            = "freeipa-files/freeipa.zip"
  content_base64 = filebase64(data.archive_file.freeipa-s3-codebuild-archive.output_path)
}

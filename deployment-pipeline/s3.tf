#
# bucket to store artifacts
#

resource aws_s3_bucket artifacts {
  bucket        = "${local.project_name}-artifacts"
  acl           = "private"
  force_destroy = true
}
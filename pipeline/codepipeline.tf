# resource aws_codepipeline codepipeline {
#   name     = var.project_name
#   role_arn = aws_iam_role.codepipeline_role.arn

#   artifact_store {
#     location = aws_s3_bucket.artifacts.bucket
#     type     = "S3"
#   }

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "ThirdParty"
#       provider         = "GitHub"
#       version          = "1"
#       output_artifacts = ["source"]

#       configuration = {
#         OAuthToken = var.github_token
#         Owner      = var.github_owner
#         Repo       = var.github_repository_name
#         Branch     = "master"
#       }
#     }
#   }

#   stage {
#     name = "Test"

#     action {
#       name     = "Test"
#       category = "Test"
#       owner    = "AWS"
#       provider = "CodeBuild"
#       version  = "1"

#       configuration = {
#         ProjectName = aws_codebuild_project.codebuild.name
#       }

#       input_artifacts = ["source"]
#     }
#   }
# }

# #
# # codepipeline assume role policy
# #

# # trust relationships
# data aws_iam_policy_document codepipeline_assume_role_policy {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["codepipeline.amazonaws.com"]
#     }
#   }
# }

# resource aws_iam_role codepipeline_role {
#   name               = "${var.project_name}-codepipeline-role"
#   assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
# }

# #
# # codepipeline policy
# #

# # inline policy data
# data aws_iam_policy_document codepipeline_policy {
#   statement {
#     actions = [
#       "s3:GetObject",
#       "s3:GetObjectVersion",
#       "s3:GetBucketVersioning",
#       "s3:PutObject"
#     ]

#     resources = [
#       aws_s3_bucket.artifacts.arn,
#       "${aws_s3_bucket.artifacts.arn}/*"
#     ]
#   }

#   statement {
#     actions = [
#       "codebuild:BatchGetBuilds",
#       "codebuild:StartBuild"
#     ]
#     resources = ["*"]
#   }
# }

# resource aws_iam_role_policy codepipeline_policy {
#   name   = "${var.project_name}-codepipeline-policy"
#   policy = data.aws_iam_policy_document.codepipeline_policy.json
#   role   = aws_iam_role.codepipeline_role.name
# }



# # resource aws_codestarnotifications_notification_rule codepipeline_notification_rule {
# #   name        = "${var.project_name}-notification-rule"
# #   resource    = aws_codepipeline.codepipeline.arn
# #   detail_type = "FULL"

# #   # https://docs.aws.amazon.com/codestar-notifications/latest/userguide/concepts.html#concepts-api
# #   event_type_ids = [
# #     "codepipeline-pipeline-pipeline-execution-started",
# #     "codepipeline-pipeline-pipeline-execution-failed",
# #     "codepipeline-pipeline-pipeline-execution-succeeded"
# #   ]

# #   target {
# #     address = var.sns_topic_arn
# #   }
# # }
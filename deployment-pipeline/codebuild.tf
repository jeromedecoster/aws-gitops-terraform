resource aws_codebuild_project codebuild {
  name          = "${local.project_name}-codebuild"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 120

  source {
    type                = "GITHUB"
    location            = "https://github.com/${var.github_owner}/${var.github_repository_name}.git"
    git_clone_depth     = 1
    report_build_status = true
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    # https://github.com/aws/aws-codebuild-docker-images/blob/master/al2/x86_64/standard/3.0/Dockerfile
    image = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type  = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${local.project_name}-log-group"
      stream_name = local.project_name
    }
  }
}

resource aws_codebuild_webhook webhook {
  project_name = aws_codebuild_project.codebuild.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "master"
    }
  }

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED,PULL_REQUEST_REOPENED"
    }

    filter {
      type    = "BASE_REF"
      pattern = "master"
    }
  }
}

resource aws_codebuild_source_credential source_credential {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}

#
# codebuild assume role policy
#

# trust relationships
data aws_iam_policy_document codebuild_assume_role_policy {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource aws_iam_role codebuild_role {
  name               = "${local.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
}

#
# attach admin policy
#

resource aws_iam_role_policy_attachment admin_attachment {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
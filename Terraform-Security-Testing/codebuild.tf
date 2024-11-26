# Create an IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "terraform-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# IAM role policy for CodeBuild
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "terraform-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = [aws_codebuild_project.codebuild_project.arn]
        principals = {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:*"
        ]
      }
    ]
  })
}

# S3 bucket for storing artifacts
resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

#trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "terraform-codebuild-artifact-bucket-${random_string.random.result}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifact_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.artifact_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.codepipeline_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "artifact_bucket_versioning" {
  bucket = aws_s3_bucket.artifact_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "artifact_buckett_pab" {
  bucket = aws_s3_bucket.artifact_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CodeBuild project
resource "aws_codebuild_project" "codebuild_project" {
  name          = "terraform-codebuild-project"
  description   = "CodeBuild Project"
  build_timeout = "60"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifact_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                      = "aws/codebuild/standard:5.0"
    type                       = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode            = true
    environment_variable {
      name = "terraform_path"
      value = var.terraform_script_path
    }
  }

  source {
    type            = "NO_SOURCE"
    buildspec       = file("./buildspec.yml")
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "terraform-codebuild-project"
      stream_name = "terraform-codebuild-project"
    }
  }

  cache {
    type  = "NO_CACHE"
  }
}
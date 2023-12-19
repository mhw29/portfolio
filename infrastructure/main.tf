resource "aws_ecr_repository" "portfolio" {
    name = "portfolio"
}

resource "aws_codebuild_project" "portfolio_project" {
    name          = "portfolio"
    description   = "Build images for portfolio project"
    build_timeout = 60

    source {
        type            = "GITHUB"
        location        = "https://github.com/mhw29/portfolio"
        git_clone_depth = 1
        buildspec       = "infrastructure/buildspec.yml"
    }

    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image        = "aws/codebuild/standard:4.0"
        type         = "LINUX_CONTAINER"
        
        environment_variable {
            name  = "AWS_ACCOUNT_ID"
            value = var.account_id
        }
        
        environment_variable {
            name  = "IMAGE_TAG"
            value = var.image_tag
        }

        environment_variable {
            name  = "IMAGE_REPO_NAME"
            value = var.image_repo
        }

        environment_variable {
            name  = "AWS_DEFAULT_REGION"
            value = var.region
        }
    }

    artifacts {
        type = "NO_ARTIFACTS"
    }

    service_role = aws_iam_role.portfolio_project_role.arn
}

resource "aws_iam_role" "portfolio_project_role" {
    name = "portfolio_project_role"

    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "codebuild.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_policy" "ecr_push_policy" {
    name        = "ecr-push-policy"
    description = "ECR push policy"

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:GetRepositoryPolicy",
                    "ecr:DescribeRepositories",
                    "ecr:ListImages",
                    "ecr:DescribeImages",
                    "ecr:BatchGetImage",
                    "ecr:InitiateLayerUpload",
                    "ecr:UploadLayerPart",
                    "ecr:CompleteLayerUpload",
                    "ecr:PutImage"
                ],
                "Resource": "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ecr_push_attachment" {
    role       = aws_iam_role.portfolio_project_role.name
    policy_arn = aws_iam_policy.ecr_push_policy.arn
}

resource "aws_iam_role_policy_attachment" "portfolio_project_cloudwatch_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccessV2"
  role       = aws_iam_role.portfolio_project_role.name
}

resource "aws_iam_role_policy_attachment" "portfolio_project_secrets_manager_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.portfolio_project_role.name
}
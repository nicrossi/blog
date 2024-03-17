# Create S3 bucket for our domain
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = var.s3_bucket_name
  acl    = "private"

  # Allow deletion of non-empty bucket
  force_destroy            = true

  # S3 bucket-level Public Access Block configuration (by default now aws has made this default as true for s3 bucket-level block public access)
  # block_public_acls       = true
  # block_public_policy     = true
  # ignore_public_acls      = true
  # restrict_public_buckets = true

  # S3 Bucket Ownership Controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  attach_policy = true
  policy        = data.aws_iam_policy_document.oac_bucket_policy.json

  versioning = {
    enabled = true
  }
}

# Create Route53 Public Hosted zone
module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    (var.s3_bucket_name) = {
      comment = "${var.s3_bucket_name} (${var.environment})"
      tags = {
        Environment = var.environment
      }
    }
  }
  tags = {
    ManagedBy = "Terraform"
  }
}

# Provision, Manage and Deploy SSL/TLS Certificates for the domain
module "acm" {
  source             = "terraform-aws-modules/acm/aws"
  version            = "~> 3.0"

  domain_name = var.s3_bucket_name
  zone_id     = module.zones.route53_zone_zone_id[var.s3_bucket_name]

  create_certificate = true
  validate_certificate = true
  wait_for_validation  = true
  validation_method    = "DNS"

  validation_allow_overwrite_records = true
  create_route53_records             = true

  tags = {
    Environment = var.environment
    Name = var.s3_bucket_name
    ManagedBy = "Terraform"
  }
}

# Create a WAFv2 Web ACL with a Rate-based rule
resource "aws_wafv2_web_acl" "wafv2" {
  name        = "CloudfrontRateBasedACL"
  description = "Cloudfront rate based web ACL"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }
  # Define the main rule for rate-based blocking
  rule {
    name     = "IPRateLimit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 10000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "IPRateLimit"
      sampled_requests_enabled   = false
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "CloudfrontRateBasedACL"
    sampled_requests_enabled   = false
  }

  tags = {
    ManagedBy = "Terraform"
  }

}

# Cloudfront distribution
module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases             = [var.s3_bucket_name]

  comment = "Cloudfront distribution for ${var.s3_bucket_name}"
  enabled = true

  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = true
  wait_for_deployment = false

  create_origin_access_identity = true

  web_acl_id = aws_wafv2_web_acl.wafv2.arn

  origin_access_identities = {
    s3_bucket_one = "Allows CloudFront to reach S3 bucket"
  }

  origin = {
    s3_one = {
      origin_id        = "s3_one"
      domain_name      = "${var.s3_bucket_name}.s3.amazonaws.com"
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    path_pattern           = "/*"
    target_origin_id       = "s3_one"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

# Origin Access Control (OAC) bucket policy
data "aws_iam_policy_document" "oac_bucket_policy" {
  statement {
    sid       = "AllowCloudFrontServicePrincipalReadOnly"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront.cloudfront_distribution_arn]
    }
  }
}

## Create an alias record that routes DNS traffic to Cloudfront distribution
resource "aws_route53_record" "record" {
  zone_id = module.zones.route53_zone_zone_id[var.s3_bucket_name]
  name    = ""
  type    = "A"
  alias {
    name = module.cloudfront.cloudfront_distribution_domain_name
    zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
  depends_on = [module.zones]
}

# Create a json file for CodePipeline's policy
data "aws_iam_policy_document" "codepipeline_assume_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create a json file for CodeBuild's policy
data "aws_iam_policy_document" "codebuild_assume_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

# Create a GitHub connection
resource "aws_codestarconnections_connection" "GitHub" {
  name          = "GitHub-connection"
  provider_type = "GitHub"
  tags = {
    ManagedBy = "Terraform"
  }
}

# Create a role for CodeBuild
resource "aws_iam_role" "codebuild_assume_role" {
  name = "${var.s3_bucket_name}-codebuild-role"

  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_policy.json
}

# Create a role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.s3_bucket_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_policy.json
}

# Create CodeBuild project
resource "aws_codebuild_project" "build_project" {
  name          = "${var.aws_codebuild_project_name}-website-build"
  description   = "CodeBuild project for ${var.s3_bucket_name}"
  service_role  = aws_iam_role.codebuild_assume_role.arn
  build_timeout = "300"
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

# Create CodePipeline
resource "aws_codepipeline" "codepipeline" {

  name     = "${var.s3_bucket_name}-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {

    location = module.s3_bucket.s3_bucket_id
    type     = "S3"
  }
  # Source stage
  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeStarSourceConnection"
      version  = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.GitHub.arn
        FullRepositoryId = var.codepipeline_full_repository_id
        BranchName       = "main"
      }
    }
  }

  # Build stage
  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["OutputArtifact"]
      version = "1"


      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  # Deploy stage
  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "S3"
      input_artifacts = ["OutputArtifact"]
      version = "1"

      configuration = {
        BucketName = var.s3_bucket_name
        Extract    = "true"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

# Create a json file for CodePipeline's policy needed to use GitHub and CodeBuild
data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]

    resources = [
      "${module.s3_bucket.s3_bucket_arn}",
      "${module.s3_bucket.s3_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = ["codestar-connections:UseConnection"]

    resources = [aws_codestarconnections_connection.GitHub.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = ["*"]
  }

}

# CodePipeline policy needed to use GitHub and CodeBuild
resource "aws_iam_role_policy" "attach_codepipeline_policy" {
  name = "${var.s3_bucket_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = data.aws_iam_policy_document.codepipeline_policy.json
}
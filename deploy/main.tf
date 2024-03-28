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
  object_ownership         = "BucketOwnerEnforced"

  versioning = {
    enabled = false
  }
}

# Create Route53 Public Hosted zone
module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    (var.domain_name) = {
      comment = "${var.domain_name} (${var.environment})"
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
  version            = "~> 4.0"

  domain_name = var.domain_name
  zone_id     = module.zones.route53_zone_zone_id[var.domain_name]
  subject_alternative_names = ["www.${var.domain_name}"]

  create_certificate   = true
  validate_certificate = true
  wait_for_validation  = true
  validation_method    = "DNS"

  validation_allow_overwrite_records = true
  create_route53_records             = true

  tags = {
    Environment = var.environment
    Name = var.domain_name
    ManagedBy = "Terraform"
  }
}

# Create a WAFv2 Web ACL with a Rate-based rule
#resource "aws_wafv2_web_acl" "wafv2" {
#  name        = "CloudfrontRateBasedACL"
#  description = "Cloudfront rate based web ACL"
#  scope       = "CLOUDFRONT"
#
#  default_action {
#    allow {}
#  }
#  # Define the main rule for rate-based blocking
#  rule {
#    name     = "IPRateLimit"
#    priority = 1
#
#    action {
#      block {}
#    }
#
#    statement {
#      rate_based_statement {
#        limit              = 10000
#        aggregate_key_type = "IP"
#      }
#    }
#
#    visibility_config {
#      cloudwatch_metrics_enabled = false
#      metric_name                = "IPRateLimit"
#      sampled_requests_enabled   = false
#    }
#  }
#
#
#  visibility_config {
#    cloudwatch_metrics_enabled = false
#    metric_name                = "CloudfrontRateBasedACL"
#    sampled_requests_enabled   = false
#  }
#
#  tags = {
#    ManagedBy = "Terraform"
#  }
#}

# Cloudfront distribution
module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = ["www.${var.domain_name}", var.domain_name]

  comment = "Cloudfront distribution for ${var.domain_name}"
  enabled = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = true
  wait_for_deployment = false
  default_root_object = "index.html"

  #web_acl_id = aws_wafv2_web_acl.wafv2.arn

  create_origin_access_control = true
  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3 ${var.domain_name}"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    s3_oac = {
      domain_name           = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3_oac"
      depends_on            = [module.s3_bucket]
    }
  }

  default_cache_behavior = {
    path_pattern           = "/*"
    target_origin_id       = "s3_oac"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    # Using Cache/ResponseHeaders/OriginRequest policies is not allowed
    # together with `compress` and `query_string` settings
    compress        = true
    query_string    = true

    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.index_url_appender.arn
      }
    }
  }

  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [module.s3_bucket]
}

# Cloudfront function IndexUrlAppender
resource "aws_cloudfront_function" "index_url_appender" {
  name        = "IndexUrlAppender"
  comment     = "Add index.html to request URLs that don’t include a file name"
  runtime     = "cloudfront-js-2.0"
  publish     = true
  code = file("${path.module}/functions/IndexUrlAppender.js")
}

# Origin Access Control (OAC) bucket policy
data "aws_iam_policy_document" "oac_bucket_policy" {
  statement {
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

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.oac_bucket_policy.json
}

# Create an Origin Access Control (OAC) resource in our cloudfront module
resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "CloudFront S3 ${var.s3_bucket_name} OAC"
  description                       = "Cloud Front S3 ${var.s3_bucket_name} OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
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

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = [
      "${module.s3_bucket.s3_bucket_arn}",
      "${module.s3_bucket.s3_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:*"
    ]

    resources = [aws_codebuild_project.build_project.id]
  }

  statement {
    sid = "CloudWatchLogsFullAccess"
    effect = "Allow"
    actions = [
      "logs:*",
      "cloudwatch:GenerateQuery"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudfront:ListDistributions",
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation"
    ]

    resources = ["*"]
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
    # standard 7.0 supports nodejs 20
    image        = "aws/codebuild/standard:7.0"
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

  statement {
    sid = "CloudWatchLogsFullAccess"
    effect = "Allow"

    actions = [
      "logs:*",
      "cloudwatch:GenerateQuery"
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

# Create CodeBuild policy
resource "aws_iam_role_policy" "attach_codebuild_policy" {
  name = "${var.s3_bucket_name}-codebuild-policy"
  role = aws_iam_role.codebuild_assume_role.id

  policy = data.aws_iam_policy_document.codebuild_policy.json
}
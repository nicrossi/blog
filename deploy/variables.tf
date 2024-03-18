variable "environment" {}
variable "region_primary" {}

variable "s3_bucket_name" {
  default = ""
}

variable "aws_codebuild_project_name" {
  default = ""
}

variable "codepipeline_full_repository_id" {
  default = ""
}

variable "hosted_zone_id" {
  default = ""
}

variable "domain_name" {
  default = ""
}
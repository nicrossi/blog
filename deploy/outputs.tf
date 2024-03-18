output "s3_bucket_region" {
  description = "The AWS region this bucket resides in."
  value       = module.s3_bucket.s3_bucket_region
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value = module.s3_bucket.s3_bucket_bucket_regional_domain_name
}

output "acm_certificate_status" {
  description = "Status of the certificate."
  value       = module.acm.acm_certificate_status
}

output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

output "The_CodeStar_Connection_status" {
  description = "The CodeStar Connection status."
  value       = aws_codestarconnections_connection.GitHub.connection_status
}

output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_distribution_arn" {
  description = "The ARN for the distribution."
  value       = module.cloudfront.cloudfront_distribution_arn
}

output "cloudfront_distribution_status" {
  description = "The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system."
  value       = module.cloudfront.cloudfront_distribution_status
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = module.cloudfront.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_last_modified_time" {
  description = "The date and time the distribution was last modified."
  value       = module.cloudfront.cloudfront_distribution_last_modified_time
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to."
  value       = module.cloudfront.cloudfront_distribution_hosted_zone_id
}

output "cloudfront_oac_id" {
  description = "The identifier for the OAI."
  value       = module.cloudfront.cloudfront_origin_access_controls_ids
}
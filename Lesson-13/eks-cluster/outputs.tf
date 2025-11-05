output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "CA data for cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}


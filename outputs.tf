# outputs.tf
output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.networking.nat_gateway_ip
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "gitlab_instance_ip" {
  description = "Private IP of the GitLab instance"
  value       = module.gitlab.instance_private_ip
}

# modules/gitlab/outputs.tf
output "instance_id" {
  description = "ID of the GitLab EC2 instance"
  value       = aws_instance.gitlab.id
}

output "instance_private_ip" {
  description = "Private IP of the GitLab instance"
  value       = aws_instance.gitlab.private_ip
}

output "ebs_volume_id" {
  description = "ID of the GitLab data EBS volume"
  value       = aws_ebs_volume.gitlab_data.id
}


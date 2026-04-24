# 16-outputs.tf

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "configure_kubectl" {
  description = "Command to configure kubectl for EKS cluster access"
  value       = "aws eks update-kubeconfig --region ${local.region} --name ${aws_eks_cluster.eks.name}"
}

output "get_alb_dns" {
  description = "Command to get ALB DNS name for Ingress access"
  value       = "kubectl get ingress -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'"
}

# ----- RDS -----

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.postgres.port
}

# ----- ECR -----

output "ecr_repository_uri" {
  description = "ECR repository URI for pushing Docker images"
  value       = aws_ecr_repository.app.repository_url
}


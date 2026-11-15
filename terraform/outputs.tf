output "k3s_public_ip" {
  description = "K3s server public IP"
  value       = aws_instance.k3s.public_ip
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://98.81.102.19:30080"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://98.81.102.19:30800"
}

output "ssh_k3s" {
  description = "SSH command to connect to K3s"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@98.81.102.19"
}

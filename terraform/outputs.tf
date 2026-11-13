output "jenkins_public_ip" {
  description = "Jenkins server public IP"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "Jenkins UI URL"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "k3s_public_ip" {
  description = "K3s server public IP"
  value       = aws_instance.k3s.public_ip
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${aws_instance.k3s.public_ip}:30080"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${aws_instance.k3s.public_ip}:30800"
}

output "ssh_jenkins" {
  description = "SSH command to connect to Jenkins"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.jenkins.public_ip}"
}

output "ssh_k3s" {
  description = "SSH command to connect to K3s"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.k3s.public_ip}"
}

output "node1_public_ip" {
  description = "Node 1 public IP - browse the live app here"
  value       = aws_instance.node1.public_ip
}

output "node1_private_ip" {
  description = "Node 1 private IP - use this in the Jenkinsfile SSH deploy step, not the public IP"
  value       = aws_instance.node1.private_ip
}

output "node2_public_ip" {
  description = "Node 2 public IP - Jenkins (:8080) and SonarQube (:9000)"
  value       = aws_instance.node2.public_ip
}

output "node2_private_ip" {
  value = aws_instance.node2.private_ip
}

output "node3_public_ip" {
  description = "Node 3 public IP - monitoring node"
  value       = aws_instance.node3.public_ip
}

output "node3_private_ip" {
  value = aws_instance.node3.private_ip
}

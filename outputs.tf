output "vault-instance-public-dns" {
  value = aws_instance.vault.public_dns
}
output "ssh-connect-string" {
  value = "${var.sshUserName}@${aws_instance.vault.public_dns}"
}
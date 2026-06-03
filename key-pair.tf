resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "ssh_key" {
  name = "ec2-ssh-private-key"
}

resource "aws_secretsmanager_secret_version" "ssh_key_value" {
  secret_id     = aws_secretsmanager_secret.ssh_key.id
  secret_string = tls_private_key.ssh_key.private_key_pem
}
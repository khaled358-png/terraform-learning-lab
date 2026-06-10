resource "aws_instance" "web_server" {
  #ami           = "ami-091138d0f0d41ff90"
  ami = var.ami
  instance_type = var.instance_type

  subnet_id = aws_subnet.public_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.ssh_security.id
  ]

  key_name = aws_key_pair.my_key.key_name

  tags = {
    Name = "jump_box"
  }
}

resource "aws_instance" "private_server" {
  #ami           = "ami-048700f1f7f2e1a70"
  ami = var.ami
  instance_type = var.instance_type

  subnet_id = aws_subnet.private_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.internal_security.id
  ]

  key_name = aws_key_pair.my_key.key_name

  tags = {
    Name = "APP"
  }
}
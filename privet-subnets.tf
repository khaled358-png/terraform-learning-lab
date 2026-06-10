resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "private-subnet-2"
  }
}

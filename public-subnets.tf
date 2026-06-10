resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}
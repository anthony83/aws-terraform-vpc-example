# VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "TerraVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "VPC-Terraform"
  }
}

# Subnets : public
resource "aws_subnet" "public" {
  count = length(var.subnets_cidr)
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = element(var.subnets_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}

# Subnets : private
resource "aws_subnet" "private" {
  count = length(var.subnets_cidr_private)
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = element(var.subnets_cidr_private,count.index)
  availability_zone = element(var.azs,count.index)
  #map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}

# Route table: attach Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}


# Route table: attach Internet Gateway
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nata.id}"
  }
  tags = {
    Name = "privateRouteTableA"
  }
}

# Route table: attach Internet Gateway
resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natb.id}"
  }
  tags = {
    Name = "privateRouteTableB"
  }
}

# Route table association with private subnets
resource "aws_route_table_association" "b" {
  count = length(var.subnets_cidr_private)
  subnet_id      = element(aws_subnet.private.*.id, 0)
  route_table_id = aws_route_table.private_rt.id
}

# Route table association with private subnets
resource "aws_route_table_association" "c" {
  count = length(var.subnets_cidr_private)
  subnet_id      = element(aws_subnet.private.*.id, 1)
  route_table_id = aws_route_table.private_rt_b.id
}

/* Elastic IP for NAT AZA Private */
resource "aws_eip" "nat_eip_aza" {
  vpc        = true
  depends_on = [aws_internet_gateway.terra_igw]
}

/* Elastic IP for NAT AZB Private */
resource "aws_eip" "nat_eip_azb" {
  vpc        = true
  depends_on = [aws_internet_gateway.terra_igw]
}

/* NAT for AZA Private Subnet*/
resource "aws_nat_gateway" "nata" {
  allocation_id = "${aws_eip.nat_eip_aza.id}"
  subnet_id     = "${element(aws_subnet.private.*.id, 0)}"
  depends_on    = [aws_internet_gateway.terra_igw]
  tags = {
    Name        = "nat"
    #Environment = "${var.environment}"
  }
}

/* NAT for AZB Private Subnet*/
resource "aws_nat_gateway" "natb" {
  allocation_id = "${aws_eip.nat_eip_azb.id}"
  subnet_id     = "${element(aws_subnet.private.*.id, 1)}"
  depends_on    = [aws_internet_gateway.terra_igw]
  tags = {
    Name        = "nat"
    #Environment = "${var.environment}"
  }
}

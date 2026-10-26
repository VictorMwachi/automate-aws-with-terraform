terraform {
  required_providers{
    aws = {
        source = "hashicorp/aws"
        version = "~>6.0"
    }
  }
}
provider "aws" {
    region = "us-east-1"
    #access_key = ""
    #secret_key = ""
}
#data "aws_vpc" "existing" {
#  id = "vpc-00e49367fcdb6e890"
#}
#resource "aws_instance" "terraform_webserver"{
#    ami = "ami-0567589d25e06853e"
#    instance_type = "t3.micro"
#    subnet_id = "subnet-083834adf90ac5173"
#}

# 1. Create vpc
resource "aws_vpc" "web_server_vpc"{
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "web-server-vpc"
  }
}
# 2. Create Internet Gateway
resource "aws_internet_gateway" "web_server_igw"{
  vpc_id = aws_vpc.web_server_vpc.id
  tags = {
    Name = "web-server-igw"
  }
}
# 3. Create Custom Route Table
resource "aws_route_table" "private_web_server_rt"{
  vpc_id = aws_vpc.web_server_vpc.id
  tags = {
    Name = "private-web-server-rt"
  }
}
resource "aws_route_table" "public_web_server_rt"{
  vpc_id = aws_vpc.web_server_vpc.id
  tags = {
    Name = "public-web-server-rt"
  }
}
# Create route to internet gateway
resource "aws_route" "public_web_server_route" {
  route_table_id = aws_route_table.public_web_server_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.web_server_igw.id
}

# 4. Create subnets
resource "aws_subnet" "public_subnet_01" {
  vpc_id = aws_vpc.web_server_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet-01"
  }
}
resource "aws_subnet" "public_subnet_02" {
  vpc_id = aws_vpc.web_server_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public-subnet-02"
  }
}
resource "aws_subnet" "private_subnet_01" {
  vpc_id = aws_vpc.web_server_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-01"
  }
}
resource "aws_subnet" "private_subnet_02" {
  vpc_id = aws_vpc.web_server_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-02"
  }
}
# 5. Associate subnets with route table
resource "aws_route_table_association" "public_subnet_01_association" {
  subnet_id = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public_web_server_rt.id 
}
resource "aws_route_table_association" "public_subnet_02_association" {
  subnet_id = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public_web_server_rt.id
}
resource "aws_route_table_association" "private_subnet_01_association" {
  subnet_id = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private_web_server_rt.id
}
resource "aws_route_table_association" "private_subnet_02_association" {
  subnet_id = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.private_web_server_rt.id
}

# 6. Create Security Group to allow HTTP and SSH access ports 22, 80, 443
resource "aws_security_group" "web_server_sg" {
  vpc_id = aws_vpc.web_server_vpc.id
  name = "web-server-sg"
  description = "Security group for web server"
  tags = {
    Name = "web-server-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.web_server_sg.id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_server_sg.id
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  }
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.web_server_sg.id
  from_port = 443
  to_port = 443
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
}

# 7. Create  a network interface with an ip in the subnet that was created in step 4
resource "aws_eip" "web_server_eip" {
  tags = {
    Name = "web-server-eip"
  }
}
resource "aws_nat_gateway" "web_server_nat" {
  allocation_id = aws_eip.web_server_eip.id
  subnet_id = aws_subnet.public_subnet_01.id
  tags = {
    Name = "web-server-nat"
  }
  depends_on = [aws_internet_gateway.web_server_igw]
}

resource "aws_route" "private_web_server_route" {
  route_table_id = aws_route_table.private_web_server_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.web_server_nat.id
}
# 8. Assign an elastic ip to the network interface created in step 7
# 9. Create ubuntu server and install/ enable apache web server
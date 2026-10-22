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
resource "aws_vpc" "my_first_vpc"{
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-first-vpc"
  }
}

resource "aws_subnet" "public_subnet_01" {
  vpc_id = aws_vpc.my_first_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet_02" {
  vpc_id = aws_vpc.my_first_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}
resource "aws_subnet" "private_subnet_01" {
  vpc_id = aws_vpc.my_first_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
}
resource "aws_subnet" "private_subnet_02" {
  vpc_id = aws_vpc.my_first_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1d"
}
# 1. Create vpc
# 2. Create Internet Gateway
# 3. Create Custom Route Table
# 4. Create subnets
# 5. Associate subnets with route table
# 6. Create Security Group to allow HTTP and SSH access ports 22, 80, 443
# 7. Create  a network interface with an ip in the subnet that was creted in step 4
# 8. Assign an elastic ip to the network interface created in step 7
# 9. Create ubuntu server and install/ enable apache web server
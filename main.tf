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
    access_key = ""
    secret_key = ""
}
data "aws_vpc" "existing" {
  id = "vpc-00e49367fcdb6e890"
}
resource "aws_instance" "terraform_webserver"{
    ami = "ami-0567589d25e06853e"
    instance_type = "t3.micro"
    subnet_id = "subnet-083834adf90ac5173"
}
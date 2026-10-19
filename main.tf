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
}
resource "aws_instance" "terraform_webserver"{
    ami = "ami-0567589d25e06853e"
    instance_type = "t3.micro"
}
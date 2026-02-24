provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-072028e29f8a73b88"
  instance_type = "t3.micro"

  tags = {
    Name = "learn-terraform"
  }
}
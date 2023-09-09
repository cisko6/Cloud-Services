provider "aws" {
  region = "us-east-1"
  access_key = "AKIAZGPH7PNHHHCHZITL"
  secret_key = "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"
}

resource "aws_instance" "my-first-server" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu"
  }
}

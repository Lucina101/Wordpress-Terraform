terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "vpc"
  }
}


# Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}



# Allow only 3306 in the private subnet
resource "aws_security_group" "db_connection" {
  name        = "db_connection"
  description = "db_connection"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "DATABASE"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["172.16.2.0/24"]
  }

  egress {
    description = "DATABASE"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["172.16.2.0/24"]
  }

  tags = {
    Name = "db_connection"
  }
}






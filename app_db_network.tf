# Public subnet
resource "aws_subnet" "app_db_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.second_private_subnet
  availability_zone = var.availability_zone

  tags = {
    Name = "app_db_subnet"
  }
}

# ENI for public subnset
resource "aws_network_interface" "app_side_nic" {
  subnet_id       = aws_subnet.app_db_subnet.id
  private_ips     = ["172.16.2.42"]
  security_groups = [aws_security_group.db_connection.id] #might modify later, for now allowed all

  tags = {
    Name : "app_side_nic"
  }
}


# ENI for public subnset
resource "aws_network_interface" "db_side_nic" {
  subnet_id       = aws_subnet.app_db_subnet.id
  private_ips     = ["172.16.2.21"]
  security_groups = [aws_security_group.db_connection.id] #might modify later, for now allowed all

  tags = {
    Name : "app_side_nic"
  }
}


resource "aws_eip" "nat_gateway_eip" {
  vpc = true
}

resource "aws_subnet" "nat_public_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block        = var.fourth_public_subnet
    availability_zone = var.availability_zone

    tags = {
        Name = "nat_public_subnet"
    }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id = aws_subnet.nat_public_subnet.id
  tags = {
    Name = "Nat gateway"
  }
  depends_on = [aws_eip.nat_gateway_eip, aws_subnet.nat_public_subnet]
}



resource "aws_subnet" "db_private_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block        = var.third_private_subnet
    availability_zone = var.availability_zone

    tags = {
        Name = "db_private_subnet"
    }
}

# ENI for public subnet
resource "aws_network_interface" "db_server_nic" {
  subnet_id       = aws_subnet.db_private_subnet.id
  private_ips     = ["172.16.3.42"]
  security_groups = [aws_security_group.allow_web.id]

  tags = {
    Name : "prod-network-interface"
  }
}

# Routing table for private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
    #change this to nat gateway later
  }
}

# Routing table association
resource "aws_route_table_association" "public_routing_to_igw" {
  subnet_id      = aws_subnet.nat_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


# Routing table association
resource "aws_route_table_association" "private_routing_asc" {
  subnet_id      = aws_subnet.db_private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

data "template_file" "database_data" {
  template = file("./db_script.tpl")
  vars = {
      database_name = var.database_name
      database_user = var.database_user
      database_pass = var.database_pass
      remote_address = "172.16.2.42"
      host_address = "172.16.2.21"
  }
}

resource "aws_instance" "database_server" {
  ami           = var.ami
  instance_type = "t2.micro"
  availability_zone = var.availability_zone
  user_data = data.template_file.database_data.rendered

  network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.db_server_nic.id
  }

    network_interface {
        device_index = 1
        network_interface_id = aws_network_interface.db_side_nic.id
    }

  tags = {
    Name = "database_server"
  }
  depends_on = [aws_network_interface.db_server_nic, aws_nat_gateway.nat_gateway]
}


/// this is for money saving
/*
resource "aws_eip" "eip_2" {
    vpc = true
    network_interface = aws_network_interface.db_server_nic.id
    associate_with_private_ip = "172.16.3.42"

    depends_on = [aws_instance.database_server]
}

output "IP2" {
    value = aws_eip.eip_2.public_ip
}*/
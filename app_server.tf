
# ENI for public subnset
resource "aws_network_interface" "app_server_nic" {
  subnet_id       = aws_subnet.server_public_subnet.id
  private_ips     = ["172.16.1.42"]
  security_groups = [aws_security_group.allow_web.id]

  tags = {
    Name : "prod-network-interface"
  }
}

# Create IGW for internet connection 
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

# Routing table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

# Public subnet
resource "aws_subnet" "server_public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.first_public_subnet
  availability_zone = var.availability_zone

  tags = {
    Name = "server_public_subnet"
  }
}


# Routing table association
resource "aws_route_table_association" "public_routing_asc" {
  subnet_id      = aws_subnet.server_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "eip" {
    vpc = true
    network_interface = aws_network_interface.app_server_nic.id
    associate_with_private_ip = "172.16.1.42"
}

data "template_file" "server_data" {
  template = file("./app_script.tpl")
    vars = {
      database_name = var.database_name
      database_user = var.database_user
      database_pass = var.database_pass
      database_host = "172.16.2.21"
      admin_user = var.admin_user
      admin_pass = var.admin_pass

      site_url = aws_eip.eip.public_ip
      
      ACCESS_KEY = aws_iam_access_key.s3_user_key.id
      SECRET_KEY = aws_iam_access_key.s3_user_key.secret

      bucket_name = var.bucket_name
  }
}

resource "aws_instance" "app_server" {
    ami                    = var.ami
    instance_type          = "t2.micro"
    availability_zone      = var.availability_zone
    user_data              = data.template_file.server_data.rendered
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.app_server_nic.id
    }

    network_interface {
        device_index = 1
        network_interface_id = aws_network_interface.app_side_nic.id
    }

    tags = {
        Name = "app_server" /** Ec2 instance name*/
    }
}

output "IP" {
    value = aws_eip.eip.public_ip
}

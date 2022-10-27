data "aws_availability_zones" "available" {
  state = "available"
}
### REDE
resource "aws_subnet" "public_subnet" {
  vpc_id = var.VCP_ID
  cidr_block = var.publicsCIDRblock
  availability_zone = var.availabilityZone
  tags = {
    name = "Wordpress"
  }
}
resource "aws_subnet" "private_subnet" {
  count = var.subnet_count.private
  vpc_id = var.VCP_ID
  cidr_block = var.privatesCIDRblock[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    name = "Wordpress"
  }
}
resource "aws_db_subnet_group" "subnetgroup_banco" {
    name = "subnetgroup_banco"
    subnet_ids = [ for subnet in aws_subnet.private_subnet :subnet.id ]
    tags = {
    name = "Wordpress"
  }
}

resource "aws_route_table_association" "public_ra" {
  route_table_id = var.RTC_PUB
  subnet_id = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = var.VCP_ID
}
  resource "aws_route_table_association" "private_ra" {
    count = var.subnet_count.private
    route_table_id = aws_route_table.private_rt.id
    subnet_id = aws_subnet.private_subnet[count.index].id
}

resource "aws_security_group" "web_security_group" {
  name        = "wordpress_SG"
  description = "Allow SSH and HTTP"
  vpc_id      = var.VCP_ID
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
    description = "EFS mount target"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
  name = "Wordpress"
  }
}

resource "aws_key_pair" "generated_key" {
  key_name   = "wordpress_kp"
  public_key = file("wordpress_kp.pub")
  tags = {
  name = "Wordpress"
  }
}

resource "aws_security_group" "db_security_group" {
  name = "db_wordpress_SG"
  vpc_id      = var.VCP_ID
  ingress {
    from_port = "3306"
    to_port = "3306"
    protocol = "tcp"
    security_groups = []
  }
  tags = {
  name = "Wordpress"
  }
}
 
resource "aws_instance" "wordpress_ec2" {
  ami                    = var.image
  security_groups = [aws_security_group.web_security_group.id]
  instance_type          = var.host
  subnet_id = aws_subnet.public_subnet.id
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sh /tmp/script.sh",
    ]
  }
  tags = {
  name = "Wordpress"
  }
}

resource "aws_eip" "webip" {
    instance = aws_instance.wordpress_ec2.id
    vpc = true
    tags = {
    name = "Wordpress"
  }
}

resource "aws_efs_file_system" "efs" {}

resource "aws_efs_mount_target" "mount" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_instance.wordpress_ec2.subnet_id
  security_groups = [aws_security_group.web_security_group.id]
}

resource "aws_efs_access_point" "access-point" {
  file_system_id = aws_efs_file_system.efs.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = var.path
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0777"
    }
  }
  tags = {
  name = "Wordpress"
  }
}
### BANCO

resource "aws_db_instance" "DB_PRESS" {
    allocated_storage = var.storage
    engine = var.engine
    engine_version = var.engineversion
    instance_class = var.db_instance
    name = var.dbname
    username = var.userdb
    password = var.passdb
    db_subnet_group_name = aws_db_subnet_group.subnetgroup_banco.id
    vpc_security_group_ids = [aws_security_group.db_security_group.id]
    skip_final_snapshot = true
    tags = {
    name = "Wordpress"
  }
}

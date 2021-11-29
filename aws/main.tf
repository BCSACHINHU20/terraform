 Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}




# Creating Public Subnet for Wordpress
resource "aws_subnet" "hu19-bcsachin-public-subnet" {
  vpc_id     = "vpc-0fc248fc45ee4cfab"
  cidr_block = "10.1.128.0/22"
  map_public_ip_on_launch = true

  tags = {
        Name= "hu19-bcsachin-public-subnet"
  }
}

# Creating Private Subnet for database
resource "aws_subnet" "hu19-bcsachin-private-subnet" {
  vpc_id     = "vpc-0fc248fc45ee4cfab"
  cidr_block = "10.1.132.0/22"
  
  tags = {
        Name= "hu19-bcsachin-private-subnet"
  }
}
# Creating Database Subnet group for RDS under our VPC
resource "aws_db_subnet_group" "hu19-bcsachin-db_subnet" {
  name       = "hu19-bcsachin-db"
  subnet_ids = [aws_subnet.hu19-bcsachin-private-subnet.id, aws_subnet.hu19-bcsachin-public-subnet.id ]

  tags = {
    Name = "bcsachin-subnet-group"
  }
}


# Creating a new security group for public subnet 
resource "aws_security_group" "hu19-bcsachin-nsg" {
  name        = "hu19-bcsachin-nsg"
  description = "Allow SSH and HTTP"
  vpc_id      = "vpc-0fc248fc45ee4cfab"                

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["157.45.123.241/32"]
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
    ipv6_cidr_blocks=["::/0"]
  }
}

# Creating a new security group for private subnet 
resource "aws_security_group" "hu19-bcsachin-nsg-private" {
  name        = "hu19-bcsachin-nsg-private"
  description = "MYSQL"
  vpc_id      = "vpc-0fc248fc45ee4cfab"                  

  ingress {
    description = "MYSQL Port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance with Wordpress installation
resource "aws_instance" "bcsachiWordPress" {
  ami           = "ami-0108d6a82a783b352"
  instance_type = "t3.micro"
  key_name = "SACHIN2"
  subnet_id = aws_subnet.hu19-bcsachin-public-subnet.id
  vpc_security_group_ids = [aws_security_group.hu19-bcsachin-nsg.id]
  tags = {
     Name = "hu19-bcsachin-wordpress"
  } 

 user_data = file("script.sh")

}

# Launching RDS db instance
resource "aws_db_instance" "hu19-bcsachin-db" {
  allocated_storage    = 20
  identifier = "hu19-bcsachin-db"
  storage_type = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "hu19bcsachindb"
  username             = "bcsachin"
  password             = "bcsachin123456"
  parameter_group_name = "default.mysql5.7"

}
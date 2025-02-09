terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "20250208~terraformpractice-vpc"
  }
}

resource "aws_subnet" "main-subnet1" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "20250208~terraformpractice-publicsubnet"
  }
}

resource "aws_subnet" "main-subnet2" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1d"
  map_public_ip_on_launch = true

  tags = {
    Name = "20250208~terraformpractice-publicsubnet"
  }
}

resource "aws_subnet" "main-subnet3" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "20250208~terraformpractice-privatesubnet"
  }
}

resource "aws_subnet" "main-subnet4" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-1d"
  map_public_ip_on_launch = false

  tags = {
    Name = "20250208~terraformpractice-privatesubnet"
  }
}

resource "aws_internet_gateway" "main-igw"{
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "20250208~terraformpractice-igw"
  }
}

resource "aws_db_parameter_group" "main-rds-parametergroup" {
  family      = "mysql5.7"
  name        = "20250209-terraformpractice-rds-parametergroup"
  description = "20250209-terraformpractice-rds-parametergroup"
}

resource "aws_db_option_group" "main-rds-optiongroup" {
  engine_name          = "mysql"
  major_engine_version = "5.7"
  name                = "20250209-terraformpractice-rds-optiongroup"
}

resource "aws_db_subnet_group" "main-rds-subnetgroup" {
  name        = "20250209-terraformpractice-rds-subnetgroup"
  description = "20250209-terraformpractice-rds-subnetgroup"
  subnet_ids  = [aws_subnet.main-subnet3.id, aws_subnet.main-subnet4.id]
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main-vpc.id


  ingress {
    from_port       = 3306  
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["10.0.1.0/24", "10.0.2.0/24"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "20250209-terraformpractice-rds-sg"
  }
}

resource "aws_db_instance" "main-rds" {
  engine               = "mysql"
  engine_version       = "5.7"
  identifier          = "20250209-terraformpractice-rds"
  instance_class      = "db.t2.micro"
  username            = "adminisrator"
  password            = "ymhseuph-1"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  storage_encrypted    = false
  
  db_name = "20250209-terraformpractice-rds"
  
  publicly_accessible    = false
  skip_final_snapshot   = true
  
  db_subnet_group_name   = aws_db_subnet_group.main-rds-subnetgroup.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  option_group_name      = aws_db_option_group.main-rds-optiongroup.name
  parameter_group_name   = aws_db_parameter_group.main-rds-parametergroup.name
  
  tags = {
    Name = "20250209-terraformpractice-rds"
  }
}

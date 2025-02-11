#--------------------------------------------------
# provider
#--------------------------------------------------

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

#--------------------------------------------------
# vpc
#--------------------------------------------------

resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "20250208~terraformpractice-vpc"
  }
}

#--------------------------------------------------
# subnet
#--------------------------------------------------

resource "aws_subnet" "main-subnet1" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "20250208~terraformpractice-publicsubnet"
  }
}

resource "aws_subnet" "main-subnet2" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1d"
  map_public_ip_on_launch = true

  tags = {
    Name = "20250208~terraformpractice-publicsubnet"
  }
}

resource "aws_subnet" "main-subnet3" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "20250208~terraformpractice-privatesubnet"
  }
}

resource "aws_subnet" "main-subnet4" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-northeast-1d"
  map_public_ip_on_launch = false

  tags = {
    Name = "20250208~terraformpractice-privatesubnet"
  }
}

#--------------------------------------------------
# internet gateway
#--------------------------------------------------

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "20250208~terraformpractice-igw"
  }
}

#--------------------------------------------------
# RDS
#--------------------------------------------------

# RDS Parameter Group
resource "aws_db_parameter_group" "main-rds-parametergroup" {
  family      = "mysql5.7"
  name        = "20250209-terraformpractice-rds-parametergroup"
  description = "20250209-terraformpractice-rds-parametergroup"
}

# RDS Option Group
resource "aws_db_option_group" "main-rds-optiongroup" {
  engine_name          = "mysql"
  major_engine_version = "5.7"
  name                 = "20250209-terraformpractice-rds-optiongroup"
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main-rds-subnetgroup" {
  name        = "20250209-terraformpractice-rds-subnetgroup"
  description = "20250209-terraformpractice-rds-subnetgroup"
  subnet_ids  = [aws_subnet.main-subnet3.id, aws_subnet.main-subnet4.id]
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main-vpc.id


  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
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

# RDS Instance
resource "aws_db_instance" "main-rds" {
  engine         = "mysql"
  engine_version = "5.7"
  identifier     = "20250209-terraformpractice-rds"
  instance_class = "db.t2.micro"
  username       = "adminisrator"
  password       = "ymhseuph-1"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = false

  db_name = "20250209-terraformpractice-rds"

  publicly_accessible = false
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.main-rds-subnetgroup.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  option_group_name      = aws_db_option_group.main-rds-optiongroup.name
  parameter_group_name   = aws_db_parameter_group.main-rds-parametergroup.name

  tags = {
    Name = "20250209-terraformpractice-rds"
  }
}

#--------------------------------------------------
# Apprication Server
#--------------------------------------------------

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Security group for App Server"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "20250209-terraformpractice-app-sg"
  }
}

#EC2
resource "aws_instance" "main_app_ec2" {
  ami           = "ami-0a6fd4c92fc6ed7d5"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main-subnet1.id

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "20250209-terraformpractice-appserver"
  }
}

#--------------------------------------------------
# Route Tables
#--------------------------------------------------

# パブリックルートテーブル
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "20250209-terraformpractice-public-rt"
  }
}

# パブリックサブネットの関連付け
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.main-subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.main-subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

# プライベートルートテーブル（デフォルトルートのみ）
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "20250209-terraformpractice-private-rt"
  }   
}

# プライベートサブネットの関連付け
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.main-subnet3.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.main-subnet4.id
  route_table_id = aws_route_table.private_rt.id
}




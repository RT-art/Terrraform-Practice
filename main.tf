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



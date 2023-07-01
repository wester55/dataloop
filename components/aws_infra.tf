variable "aws_details" {
  type = map(string)
  description = "aws details"
}

variable "vpc_details" {
  type = map(string)
  description = "vpc details"
}

provider "aws" {
  region = var.aws_details.region
  profile = "${var.environment}-${var.customer}"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_details.cidr
  tags = {
    Name = "${var.environment}-${var.customer}-vpc"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment}-${var.customer}-igw"
  }
}

# Create a subnets
resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_details.subnet_1
  availability_zone       = var.vpc_details.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-${var.customer}-subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_details.subnet_2
  availability_zone       = var.vpc_details.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-${var.customer}-subnet-2"
  }
}

resource "aws_subnet" "subnet_3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_details.subnet_3
  availability_zone       = var.vpc_details.availability_zone_3
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-${var.customer}-subnet-3"
  }
}

# Create a route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment}-${var.customer}-route-table"
  }
}

# Create a route
resource "aws_route" "route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate the subnets with the route table
resource "aws_route_table_association" "subnet_association_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet_association_2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet_association_3" {
  subnet_id      = aws_subnet.subnet_3.id
  route_table_id = aws_route_table.route_table.id
}


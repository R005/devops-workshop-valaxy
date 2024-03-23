provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "dop2" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name = "nv"
  vpc_security_group_ids = [aws_security_group.dop2sg.id]
  subnet_id = aws_subnet.dop2-public-subnet-01.id
  for_each = toset(["jenkins-master", "build-slave", "ansible"])

  tags = {
    Name = "${each.key}"
  }
}

resource "aws_security_group" "dop2sg" {
    name = "dop2sg"
    description = "SSH and Jenkins Access"
    vpc_id = aws_vpc.dop2vpc.id

    ingress {
        description = "SSH Access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "Jenkins Port"
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "ssh-jenkins-ports"
    }
}

resource "aws_vpc" "dop2vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "dop2vpc"
  }
}

resource "aws_subnet" "dop2-public-subnet-01" {
  vpc_id = aws_vpc.dop2vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"

  tags = {
    Name = "dop2-public-subnet-01"
  }
}

resource "aws_subnet" "dop2-public-subnet-02" {
  vpc_id = aws_vpc.dop2vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"

  tags = {
    Name = "dop2-public-subnet-02"
  }
}

resource "aws_internet_gateway" "dop2-igw" {
  vpc_id = aws_vpc.dop2vpc.id

  tags = {
    Name = "dop2-igw"
  }
}

resource "aws_route_table" "dop2-public-rt" {
  vpc_id = aws_vpc.dop2vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dop2-igw.id
  }
}

resource "aws_route_table_association" "dop2-rta-public-subnet-01" {
  subnet_id = aws_subnet.dop2-public-subnet-01.id
  route_table_id = aws_route_table.dop2-public-rt.id
}

resource "aws_route_table_association" "dop2-rta-public-subnet-02" {
  subnet_id = aws_subnet.dop2-public-subnet-02.id
  route_table_id = aws_route_table.dop2-public-rt.id
}
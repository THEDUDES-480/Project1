
provider "aws" {
  profile = "default"
  region     = "us-west-2"
}

//network.tf
resource "aws_vpc" "project_1_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags          = {
    Name        = "Project_1_VPC_CIT480"
  }
}


//gateways.tf
resource "aws_internet_gateway" "project_1_gw" {
  vpc_id = "${aws_vpc.project_1_vpc.id}"
  tags          = {
    Name        = "Project_1_IG_CIT480"
  }
}

//public route tbl
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.project_1_vpc.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.project_1_gw.id}"
  }
tags          = {
    Name        = "Project_1_Public_Route"
  }
}

//private route tbl
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.project_1_vpc.id}"
tags          = {
    Name        = "Project_1_Private_Route"
  }
}

//pub1
resource "aws_subnet" "pub_1" {
  cidr_block = "10.0.0.0/21"
  vpc_id = "${aws_vpc.project_1_vpc.id}"
  availability_zone = "us-west-2a"
  
  tags          = {
    Name        = "Project_1_Pub_1"
  }
}

resource "aws_route_table_association" "pub_1" {
  subnet_id      = "${aws_subnet.pub_1.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

//pub2
resource "aws_subnet" "pub_2" {
  cidr_block = "10.0.32.0/21"
  vpc_id = "${aws_vpc.project_1_vpc.id}"
  availability_zone = "us-west-2b"
  
  tags          = {
    Name        = "Project_1_Pub_2"
  }
}

resource "aws_route_table_association" "pub_2" {
  subnet_id      = "${aws_subnet.pub_2.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

//pub3
resource "aws_subnet" "pub_3" {
  cidr_block = "10.0.64.0/21"
  vpc_id = "${aws_vpc.project_1_vpc.id}"
  availability_zone = "us-west-2c"
  
  tags          = {
    Name        = "Project_1_Pub_3"
  }
}

resource "aws_route_table_association" "pub_3" {
  subnet_id      = "${aws_subnet.pub_3.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

//priv1
resource "aws_subnet" "priv_1" {
  cidr_block = "10.0.192.0/19"
  vpc_id = "${aws_vpc.project_1_vpc.id}"
  availability_zone = "us-west-2a"
  
  tags          = {
    Name        = "Project_1_Priv_1"
  }
}

resource "aws_route_table_association" "priv_1" {
  subnet_id      = "${aws_subnet.priv_1.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

//priv2
resource "aws_subnet" "priv_2" {
  cidr_block = "10.0.160.0/19"
  vpc_id = "${aws_vpc.project_1_vpc.id}"
  availability_zone = "us-west-2b"
  
  tags          = {
    Name        = "Project_1_Priv_2"
  }
}

resource "aws_route_table_association" "priv_2" {
  subnet_id      = "${aws_subnet.priv_2.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

//priv3
resource "aws_subnet" "priv_3" {
  cidr_block = "10.0.148.0/19"
  vpc_id = "${aws_vpc.project_1_vpc.id}"
  availability_zone = "us-west-2c"
  
  tags          = {
    Name        = "Project_1_Priv_3"
  }
}

resource "aws_route_table_association" "priv_3" {
  subnet_id      = "${aws_subnet.priv_3.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}


//bastion security group and rule
resource "aws_security_group" "bastion" {
name = "CIT480_Project_1_Bastion_SG"
vpc_id = "${aws_vpc.project_1_vpc.id}"
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

//security_group.tf ssh and base
resource "aws_security_group" "default" {
name = "CIT480_Project_1_SG"
vpc_id = "${aws_vpc.project_1_vpc.id}"
ingress {
    security_groups = [
      "${aws_security_group.bastion.id}"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

//add http rule
resource "aws_security_group_rule" "http" {
  type  =  "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  
  cidr_blocks = [
      "0.0.0.0/0"
	  ]
	  
  ipv6_cidr_blocks = [
	  "::/0"
	  ]
  
  security_group_id  =  "${aws_security_group.default.id}"
}

//add https rule
resource "aws_security_group_rule" "https" {
  type  =  "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  
  cidr_blocks = [
      "0.0.0.0/0"
	  ]
	  
  ipv6_cidr_blocks = [
	  "::/0"
	  ]
  
  security_group_id  =  "${aws_security_group.default.id}"
}


//ec2 instance
resource "aws_instance" "test-ec2-instance" {
  ami = "ami-06d51e91cea0dac8d"
  instance_type = "t2.micro"
  key_name = "vs"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.default.id}"]
tags = {
    Name = "Web Server ec2"
  }
subnet_id = "${aws_subnet.pub_1.id}"
  private_ip = "10.0.1.62"
}


//NAT/Bastion instance
resource "aws_instance" "nat" {
  ami = "ami-06d51e91cea0dac8d"
  subnet_id = "${aws_subnet.pub_1.id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.bastion.id}"]
  tags = {
   Name = "VPC NAT"
   }
   
  key_name = "vs"
  
}

resource "aws_eip" "nat_assocition" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}


resource "aws_eip_association" "nat_to_elastic" {
  instance_id   = "${aws_instance.nat.id}"
  allocation_id = "eipalloc-0e4159134a559faa1"
}



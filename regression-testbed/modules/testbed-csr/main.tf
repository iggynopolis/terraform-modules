# Terraform configuration file to set up an AWS vpc for Cisco Cloud services router

data "aws_region" "current" {
	count = var.vpc_count != 0 ? 1 : 0
}

resource "aws_vpc" "vpc" {
	count				= var.vpc_count
	cidr_block	= var.vpc_cidr[count.index]
	tags	= {
		Name			= "${var.resource_name_label}_csr_vpc${count.index}_${data.aws_region.current[0].name}"
	}
}

resource "aws_subnet" "public_subnet1" {
	count							= var.vpc_count
	vpc_id						= aws_vpc.vpc[count.index].id
	cidr_block				= var.pub_subnet1_cidr[count.index]
	availability_zone = var.pub_subnet1_az[count.index]
	tags	= {
		Name			= "${var.resource_name_label}_csr_vpc${count.index}_public1_${var.pub_subnet1_az[count.index]}"
	}
}

resource "aws_subnet" "public_subnet2" {
	count							= var.vpc_count
	vpc_id						= aws_vpc.vpc[count.index].id
	cidr_block				=	var.pub_subnet2_cidr[count.index]
	availability_zone = var.pub_subnet2_az[count.index]
	tags	= {
		Name			=	"${var.resource_name_label}_csr_vpc${count.index}_public2_${var.pub_subnet2_az[count.index]}"
	}
}

resource "aws_subnet" "private_subnet" {
	count							= var.vpc_count
	vpc_id						= aws_vpc.vpc[count.index].id
	cidr_block				= var.pri_subnet_cidr[count.index]
	availability_zone = var.pri_subnet_az[count.index]
	tags	= {
		Name			= "${var.resource_name_label}_csr_vpc${count.index}_private_${var.pri_subnet_az[count.index]}"
	}
}

resource "aws_internet_gateway" "igw" {
	count				= var.vpc_count
	vpc_id			= aws_vpc.vpc[count.index].id
	tags	= {
		Name			= "${var.resource_name_label}_csr_vpc${count.index}_igw_${data.aws_region.current[0].name}"
	}
}

resource "aws_route_table" "public_rtb" {
	count				= var.vpc_count
	vpc_id			= aws_vpc.vpc[count.index].id
	route {
		cidr_block	= "0.0.0.0/0"
		gateway_id	= aws_internet_gateway.igw[count.index].id
	}
	tags	= {
		Name			= "${var.resource_name_label}_csr_vpc${count.index}_public-rtb_${data.aws_region.current[0].name}"
	}
}

resource "aws_route_table" "private_rtb" {
	count				= var.vpc_count
	vpc_id			=	aws_vpc.vpc[count.index].id
	tags	= {
		Name			= "${var.resource_name_label}_csr_vpc${count.index}_private-rtb_${data.aws_region.current[0].name}"
	}
}

resource "aws_route_table_association" "public_rtb_associate1" {
	count						=	var.vpc_count
	subnet_id				= aws_subnet.public_subnet1[count.index].id
	route_table_id	= aws_route_table.public_rtb[count.index].id
}

resource "aws_route_table_association" "public_rtb_associate2" {
	count						=	var.vpc_count
	subnet_id				= aws_subnet.public_subnet2[count.index].id
	route_table_id	= aws_route_table.public_rtb[count.index].id
}
resource "aws_route_table_association" "private_rtb_associate" {
	count						=	var.vpc_count
	subnet_id				= aws_subnet.private_subnet[count.index].id
	route_table_id  = aws_route_table.private_rtb[count.index].id
}

resource "random_id" "key_id" {
	count 			= var.vpc_count != 0 ? 1 : 0
	byte_length = 4
}

# Key pair is used for all ubuntu instances
resource "aws_key_pair" "key_pair" {
	count 					= var.vpc_count != 0 ? 1 : 0
	key_name				= "testbed_csr_key-${random_id.key_id[0].dec}"
	public_key			= var.public_key
}

resource "aws_instance" "csr_instance1" {
	# Ubuntu
	count												= var.vpc_count
	ami													= local.ami
	instance_type								= "t2.medium"
	disable_api_termination			= var.termination_protection
	associate_public_ip_address = true
	subnet_id										= aws_subnet.public_subnet1[count.index].id
	private_ip									= cidrhost(aws_subnet.public_subnet1[count.index].cidr_block, var.pub_hostnum)
	vpc_security_group_ids			= [aws_security_group.sg[count.index].id]
	key_name										= aws_key_pair.key_pair[0].key_name
	tags	= {
		Name				= "${var.resource_name_label}_csr-instance1_${count.index}_${aws_subnet.public_subnet1[count.index].availability_zone}"
	}
}

resource "aws_instance" "csr_instance2" {
	# Ubuntu
  count                       = var.vpc_count
  ami                         = local.ami
  instance_type               = "t2.medium"
	disable_api_termination     = var.termination_protection
  subnet_id                   = aws_subnet.public_subnet2[count.index].id
	private_ip									= cidrhost(aws_subnet.public_subnet2[count.index].cidr_block, var.pub_hostnum)
	vpc_security_group_ids			= [aws_security_group.sg[count.index].id]
	key_name										= aws_key_pair.key_pair[0].key_name
  tags  = {
    Name        = "${var.resource_name_label}_csr-instance2_${count.index}_${aws_subnet.private_subnet[count.index].availability_zone}"
  }
}

resource "aws_security_group" "sg" {
	count				= var.vpc_count
	name				= "allow_all"
	description	= "Allow all ingress and egress."
	vpc_id			= aws_vpc.vpc[count.index].id

	ingress {
	# Allow all
	from_port		= 0
	to_port			= 0
	protocol		= "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}

	tags	= {
		Name			= "${var.resource_name_label}_csr_security-group${count.index}_${data.aws_region.current[0].name}"
	}

	egress {
	# Allow all
	from_port 	= 0
	to_port 		= 0
	protocol 		= "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_eip" "eip1" {
	count			= var.vpc_count
	instance	= aws_instance.csr_instance1[count.index].id
	vpc				= true
	tags	= {
		Name		= "${var.resource_name_label}_csr-instance1-eip${count.index}_${data.aws_region.current[0].name}"
	}
}

resource "aws_eip" "eip2" {
	count			= var.vpc_count
	instance	= aws_instance.csr_instance2[count.index].id
	vpc				= true
	tags	= {
		Name		= "${var.resource_name_label}_csr-instance2-eip${count.index}_${data.aws_region.current[0].name}"
	}
}

locals {
  owner_id = "e201de70-32a9-47fe-8746-09fa08dd334f"
  ami = local.region_image[data.aws_region.current[0].name]
  region_image = {
    us-east-1 = "ami-09799742baecfa095"
    us-east-2 = "ami-0ad09c80dcc216526"
    us-west-1 = "ami-0e4c462c3a1a95ac5"
    us-west-2 = "ami-00aad1010d5f43358"
  }
}

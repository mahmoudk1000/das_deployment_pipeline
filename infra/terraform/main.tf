 # terraform {
 #     backend "s3" {
 #         bucket  = "terraform_state_bucket"
 #         key     = "terraform.tfstate"
 #         region  =  "eu-central-1"
 #     }
 # }

provider "aws" {
    region = "eu-central-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable availability_zone {
    description = "Default avaiablity zone"
    type        = string
    default     = "eu-central-1"
}
variable env_type {
    description = "Default enviroment"
    type = string
    default = "dev"
}
variable ssh_key {
    description = "Default path of ssh key"
    type = string
    default = "~/.ssh/id_rsa"
}
variable public_ip_list {
    description = "List of allowed IPs to ssh"
    type = list(string)
    default = [ "197.48.13.99" ]
}

resource "aws_vpc" "app_vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    
    tags = {
        Name: "${var.env_type}_vpc"
    }
}

resource "aws_subnet" "dev_subnet_1" {
    vpc_id              = aws_vpc.app_vpc.id
    cidr_block          = var.subnet_cidr_block
    availability_zone  = var.availability_zone
    tags = {
        Name: "${var.env_type}_subnet"
    }
}

resource "aws_internet_gateway" "main_gw" {
    vpc_id = aws_vpc.app_vpc.id

    tags = {
        Name: "${var.env_type}-igw"
    }
}

resource "aws_default_route_table" "default-rt" {
    default_route_table_id = aws_vpc.app_vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_gw.id
    }

    tags = {
        Name: "${var.env_type}-default-rt"
    }
}

resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.app_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.public_ip_list
    }

    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_type}-default-sg"
    }
}

resource "aws_key_pair" "ssh_key" {
    key_name    = "app_server_key"
    public_key  = file(var.ssh_key)
}

data "aws_ami" "latest_amazon_linux" {
    most_recent = true

    filter {
        name   = "name"
        values = [ "amzn2-ami-hvm-*" ]
    }

    filter {
        name   = "virtualization-type"
        values = [ "hvm" ]
    }

    owners = [ "amazon" ]
}

resource "aws_instance" "app_server" {
    ami                         = data.aws_ami.latest_amazon_linux.id
    instance_type               = "t2.micro"

    key_name                    = "app_server_key"
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.dev_subnet_1.id
    vpc_security_group_ids      = [ aws_default_security_group.default-sg.id ]

    user_data = <<EOF
                    #!/usr/bin/env bash
                    echo "Horray! :)"
                EOF

    tags = {
        Name: "${var.env_type}_server"
    }
}

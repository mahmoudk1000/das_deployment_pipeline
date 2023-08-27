provider "kubernetes" {
    host = data.aws_eks_cluster.app_cluster.endpoint
    token = data.aws_eks_cluster_auth.app_cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.app_cluster.certificate_authority[0].data)
}

variable private_subnets_cidr_blocks {
    description = "List of private subnet cidr blocks"
    type = list(string)
}
variable public_subnets_cidr_blocks {
    description = "List of public subnet cidr blocks"
    type = list(string)
}


data "aws_availability_zones" "azs" {
    state = "available"
}
data "aws_eks_cluster_auth" "app_cluster" {
    name = module.eks.cluster_id
}
data "aws_eks_cluster" "app_cluster" {
    name = module.eks.cluster_id
}


module "eks_vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.1.1"

    name = "main_vpc"
    cidr = var.vpc_cidr_block
    private_subnets = var.private_subnets_cidr_blocks
    public_subnets = var.public_subnets_cidr_blocks
    azs = data.aws_availability_zones.azs.names

    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true

    tags = {
        "kubernetes.io/cluster/app-eks-cluster" = "shared"
    }

    public_subnet_tags = {
        "kubernetes.io/cluster/elb" = "shared"
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/cluster/app-eks-cluster" = "shared"
        "kubernetes.io/role/internal-elb" = 1
    }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "19.3.1"

    cluster_name = "app-cluster"
    cluster_version = "1.21"

    vpc_id = module.eks_vpc.vpc_id
    subnet_ids = module.eks_vpc.private_subnets

    tags = {
        app = "app"
        enviroment = var.env_type
    }
}

resource "aws_eks_node_group" "app_node-group" {
    cluster_name    = module.eks.cluster_name
    node_group_name = "my-node-group"

    scaling_config {
        desired_size = 2
        max_size     = 3
        min_size     = 1
    }

    launch_template {
        name = aws_launch_template.node_launch.name
        version = "$Latest"
    }

    remote_access {
        ec2_ssh_key = "my-ssh-key"
    }

    subnet_ids      = module.eks_vpc.private_subnets.subnet_ids
    node_role_arn   = aws_iam_role.eks_node_group_role.arn
}

resource "aws_launch_template" "node_launch" {
    name_prefix             = "eks-node-launch-template"
    instance_type           = "t2.micro"
    image_id                = data.aws_ami.latest_amazon_linux.id

    instance_market_options {
        market_type = "spot"
    }
}

resource "aws_iam_role" "eks_node_group_role" {
    name = "eks-node-group-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole",
                Effect = "Allow",
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

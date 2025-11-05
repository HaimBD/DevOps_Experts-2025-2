# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch all subnets in the default VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Fetch details for each subnet and filter for supported zones
locals {
  # Fetch details of each subnet individually
  subnet_details = [
    for subnet_id in data.aws_subnets.default_vpc_subnets.ids : data.aws_subnet.subnet_details[subnet_id]
  ]

  # Filter for supported availability zones
  supported_subnet_ids = [
    for subnet in local.subnet_details : subnet.id
    if contains(["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"], subnet.availability_zone)
  ]
}

# Define each subnet as a separate data source to fetch details
data "aws_subnet" "subnet_details" {
  for_each = toset(data.aws_subnets.default_vpc_subnets.ids)
  id       = each.key
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "hbd-ai-cluster"
  cluster_version = "1.31"
  vpc_id          = data.aws_vpc.default.id
  subnet_ids      = local.supported_subnet_ids
  control_plane_subnet_ids = local.supported_subnet_ids

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large"]
  }

  eks_managed_node_groups = {
    example = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

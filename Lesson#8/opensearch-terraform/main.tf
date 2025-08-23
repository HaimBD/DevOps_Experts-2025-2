terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  region      = "us-east-1"   # change if you like
  domain_name = "demo-os"     # 3-28 lowercase letters, digits, hyphens
  tags = {
    Project   = "opensearch-demo"
    ManagedBy = "terraform"
  }
}

provider "aws" {
  region = local.region
}

data "aws_caller_identity" "me" {}
data "aws_partition" "part" {}

# Public access policy: allow ES HTTP calls from any IP (keeps FGAC for auth)
data "aws_iam_policy_document" "access" {
  statement {
    sid     = "AllowAllIPsForESHttp"
    effect  = "Allow"
    actions = ["es:ESHttp*"]
    resources = [
      "arn:${data.aws_partition.part.partition}:es:${local.region}:${data.aws_caller_identity.me.account_id}:domain/${local.domain_name}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["0.0.0.0/0"]
    }
  }
}

# --- OpenSearch Domain ---
resource "aws_opensearch_domain" "this" {
  domain_name    = local.domain_name
  engine_version = "OpenSearch_2.13"     # adjust if you prefer a different 2.x

  cluster_config {
    instance_type          = "t3.small.search"
    instance_count         = 1
    zone_awareness_enabled = false
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = 10
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  # Fine-grained security with internal user DB -> use Basic Auth over HTTPS
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  # Public endpoint (open by IP), auth is enforced by FGAC credentials above
  access_policies = data.aws_iam_policy_document.access.json

  tags = local.tags
}

variable "master_user_name" {
  type        = string
  default     = "admin"
  description = "Master (Dashboards/REST) username"
}

variable "master_user_password" {
  type        = string
  sensitive   = true
  default     = "Admin123!ChangeMe"
  description = "Change me. Must meet OS password complexity."
}

# --- Helpful outputs ---
output "opensearch_endpoint" {
  value = aws_opensearch_domain.this.endpoint
}

output "dashboards_url" {
  value = aws_opensearch_domain.this.dashboard_endpoint
}

output "domain_arn" {
  value = aws_opensearch_domain.this.arn
}

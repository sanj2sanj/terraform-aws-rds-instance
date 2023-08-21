provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  rds_id        = var.rds_id
  db_name       = var.db_name
  region        = var.db_region
  backup_region = var.db_backups_region

  tags = {
    Name       = local.rds_id
    Repository = "https://github.com/sanj2sanj/terraform-aws-rds-instance"
  }
}

################################################################################
# RDS Module
################################################################################

module "db" {
  source     = "terraform-aws-modules/rds/aws"
  identifier = local.rds_id
  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                = "postgres"
  engine_version        = "15"
  family                = "postgres15" # DB parameter group
  major_engine_version  = "15"         # DB option group
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 20
  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name                         = local.db_name
  username                        = var.db_username
  password                        = var.db_password
  port                            = 5432
  multi_az                        = true
  db_subnet_group_name            = var.aws_db_subnet_group
  vpc_security_group_ids          = [module.security_group.security_group_id]
  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true
  backup_retention_period         = 1

  skip_final_snapshot = true
  deletion_protection = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "${local.rds_id}-mon-role-name"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "${local.rds_id} mon role"
  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}

################################################################################
# RDS Automated Backups Replication Module
################################################################################

provider "aws" {
  alias  = "backup_region"
  region = local.backup_region
}

module "kms" {
  source      = "terraform-aws-modules/kms/aws"
  version     = "~> 1.0"
  description = "KMS key for cross region automated backups replication"
  # Aliases
  aliases                 = [local.rds_id]
  aliases_use_name_prefix = true
  key_owners              = [data.aws_caller_identity.current.arn]
  tags                    = local.tags
  providers = {
    aws = aws.backup_region
  }
}
module "db_automated_backups_replication" {
  source                 = "terraform-aws-modules/rds/aws//modules/db_instance_automated_backups_replication"
  version                = "6.1.1"
  source_db_instance_arn = module.db.db_instance_arn
  kms_key_arn            = module.kms.key_arn
  providers = {
    aws = aws.backup_region
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.rds_id
  description = "${local.rds_id} security group"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "${local.rds_id} access from within VPC"
      cidr_blocks = var.security_group_cidr
    },
  ]

  tags = local.tags
}

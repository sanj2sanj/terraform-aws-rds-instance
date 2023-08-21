
variable "rds_id" {
  type        = string
  description = "rds_id for db instance"
  default     = "sht-logdb"
}

variable "db_name" {
  type        = string
  description = "rds_id for db instance"
  default     = "logdb"
}

variable "db_region" {
  type        = string
  description = "region for db instance"
  default     = "eu-north-1"
}

variable "db_backups_region" {
  type        = string
  description = "region for db backups"
  default     = "eu-west-1"
}

variable "db_password" {
  type        = string
  description = "Root password for db instance"
  default     = "m-23A!4aoDZ"
}

variable "db_username" {
  type        = string
  description = "Root password for db instance"
  default     = "shtlogging"
}

variable "vpc_id" {
  type        = string
  description = "VPC id to allow access to"
}

variable "security_group_cidr" {
  type        = string
  description = "Cidr to allow access to"

}

variable "aws_db_subnet_group" {
  type        = string
  description = "Subnet group for db"
}

variable "skip_final_snapshot" {
  type  = bool
  default = false
}

variable "deletion_protection" {
  type  = bool
  default = true
}

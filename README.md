# Complete RDS example for PostgreSQL with existing VPC
This code has been heavily adapted using the code [here](https://github.com/terraform-aws-modules/terraform-aws-rds/blob/master/examples/complete-postgres/README.md|). 

I already had an exisiting VPC network setup and wanted to plug it into this terraform. Apart from that it follows the same conventions as described [here](https://github.com/terraform-aws-modules/terraform-aws-rds/blob/master/examples/complete-postgres/README.md)

# Example use
``` go
module "logging-db" {
  source              = "github.com/sanj2sanj/terraform-aws-rds-instance"
  security_group_cidr = aws_vpc.shuttle.cidr_block
  vpc_id              = aws_vpc.shuttle.id
  aws_db_subnet_group = aws_db_subnet_group.managed.name
}
```
# How long does it take to create a new db?
Terraform apply took around 15mins.

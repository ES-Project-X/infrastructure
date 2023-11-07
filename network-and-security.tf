module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "project-x-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["eu-west-1a"]
  public_subnets = ["10.0.0.0/24"]
  # private_subnets = ["10.0.1.0/24"]

  # enable_nat_gateway     = true
  # single_nat_gateway     = false
  # one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true
}

resource "aws_security_group" "project_x_http" {
  name        = "project-x-http"
  description = "Enable HTTP access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

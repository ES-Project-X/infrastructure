resource "aws_db_subnet_group" "project_x" {
  name       = "project-x-db-subnet-group"
  subnet_ids = module.vpc.private_subnets # module.vpc.public_subnets
}

resource "aws_db_instance" "project_x" {
  identifier = "project-x-db"
  db_name    = "projectx"

  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  storage_type      = "gp2"
  allocated_storage = 10

  username = "username"
  password = "password"

  availability_zone      = module.vpc.azs[0]
  # vpc_security_group_ids = [aws_security_group.project_x_postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.project_x.name

  # publicly_accessible = true
}

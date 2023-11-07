resource "aws_instance" "project_x_web_ui" {
  ami           = "ami-0e309a5f3a6dd97ea"
  instance_type = "t2.nano"

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.project_x_http.id]

  tags = {
    Name = "Web UI"
  }
  user_data = file("web-server.sh")
}

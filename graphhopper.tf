/* ECS Task Definition */

resource "aws_ecs_task_definition" "graphhopper" {
  family                   = "project-x-task-graphhopper"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 2048
  cpu                      = 1024

  container_definitions = jsonencode(
    [
      {
        name  = "project-x-graphhopper"
        image = "${aws_ecr_repository.project_x_graphhopper.repository_url}"
        portMappings = [
          {
            containerPort = 80
            hostPort      = 80
          }
        ],
        memory = 2048
        cpu    = 1024
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "graphhopper"
            awslogs-region        = "eu-west-1"
            awslogs-create-group  = "true"
            awslogs-stream-prefix = "graphhopper"
          }
        }
      }
    ]
  )
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}

/* ECS Service */

resource "aws_ecs_service" "graphhopper" {
  name            = "project-x-service-graphhopper"
  cluster         = aws_ecs_cluster.project_x.id
  task_definition = aws_ecs_task_definition.graphhopper.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [module.vpc.private_subnets[0]] # [module.vpc.public_subnets[0]]
    assign_public_ip = true
    security_groups  = [aws_security_group.project_x_http.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.graphhopper.arn
    container_name   = "project-x-graphhopper"
    container_port   = 80
  }
}

/* ALB */

resource "aws_alb" "graphhopper" {
  name               = "graphhopper-alb"
  load_balancer_type = "application"
  internal           = true
  subnets            = module.vpc.private_subnets             # module.vpc.public_subnets
  security_groups    = [aws_security_group.project_x_http.id] # , aws_security_group.project_x_https.id]
}

/* ALB Target Group */

resource "aws_lb_target_group" "graphhopper" {
  name        = "graphhopper-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }
}

/* ALB Listeners */

resource "aws_lb_listener" "graphhopper_http" {
  load_balancer_arn = aws_alb.graphhopper.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.graphhopper.arn
  }
}

# resource "aws_lb_listener" "graphhopper_https" {
#   load_balancer_arn = aws_alb.graphhopper.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = var.cert_arn
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.graphhopper.arn
#   }
# }

output "graphhopper_url" { value = aws_alb.graphhopper.dns_name }

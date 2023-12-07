/* ECS Task Definition */

resource "aws_ecs_task_definition" "rest_api" {
  family                   = "project-x-task-rest-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256

  container_definitions = jsonencode(
    [
      {
        name  = "project-x-rest-api"
        image = "${aws_ecr_repository.project_x_rest_api.repository_url}"
        portMappings = [
          {
            containerPort = 80
            hostPort      = 80
          }
        ],
        memory = 512
        cpu    = 256
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "rest-api"
            awslogs-region        = "eu-west-1"
            awslogs-create-group  = "true"
            awslogs-stream-prefix = "rest-api"
          }
        }
      }
    ]
  )
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}

/* ECS Service */

resource "aws_ecs_service" "rest_api" {
  name            = "project-x-service-rest-api"
  cluster         = aws_ecs_cluster.project_x.id
  task_definition = aws_ecs_task_definition.rest_api.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [module.vpc.private_subnets[0]] 
    assign_public_ip = true
    security_groups  = [aws_security_group.project_x_http.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rest_api.arn
    container_name   = "project-x-rest-api"
    container_port   = 80
  }
}

/* ALB */

resource "aws_alb" "rest_api" {
  name               = "rest-api-alb"
  load_balancer_type = "application"
  internal           = true
  subnets            = module.vpc.private_subnets             
  security_groups    = [aws_security_group.project_x_http.id] 
}

/* ALB Target Group */

resource "aws_lb_target_group" "rest_api" {
  name        = "rest-api-tg"
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

resource "aws_lb_listener" "rest_api_http" {
  load_balancer_arn = aws_alb.rest_api.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rest_api.arn
  }
}

output "rest_api_url" { value = aws_alb.rest_api.dns_name }


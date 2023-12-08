/* ECS Task Definition */

resource "aws_ecs_task_definition" "web_ui" {
  family                   = "project-x-task-web-ui"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256

  container_definitions = jsonencode(
    [
      {
        name  = "project-x-web-ui"
        image = "${aws_ecr_repository.project_x_web_ui.repository_url}"
        portMappings = [
          {
            containerPort = 3000
            hostPort      = 3000
          }
        ],
        memory = 512
        cpu    = 256
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "web-ui"
            awslogs-region        = "eu-west-1"
            awslogs-create-group  = "true"
            awslogs-stream-prefix = "web-ui"
          }
        }
      }
    ]
  )
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}

/* ECS Service */

resource "aws_ecs_service" "web_ui" {
  name            = "project-x-service-web-ui"
  cluster         = aws_ecs_cluster.project_x.id
  task_definition = aws_ecs_task_definition.web_ui.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [module.vpc.private_subnets[0]]
    assign_public_ip = true
    security_groups  = [aws_security_group.project_x_web_ui.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_ui.arn
    container_name   = "project-x-web-ui"
    container_port   = 3000
  }
}

/* ALB */

resource "aws_alb" "web_ui" {
  name               = "web-ui-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.project_x_https.id]
}

/* ALB Target Group */

resource "aws_lb_target_group" "web_ui" {
  name        = "web-ui-tg"
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

resource "aws_lb_listener" "web_ui_https" {
  load_balancer_arn = aws_alb.web_ui.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_ui.arn
  }
}

output "web_ui_url" { value = aws_alb.web_ui.dns_name }

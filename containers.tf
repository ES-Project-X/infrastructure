resource "aws_ecr_repository" "project_x" {
  name                 = "project-x-container-repository"
  image_tag_mutability = "MUTABLE"
}
output "ecr_repository_id" {
  value = aws_ecr_repository.project_x.registry_id
}

resource "aws_ecs_cluster" "project_x" {
  name = "project-x-cluster"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_ecs_task_definition" "project_x" {
  family                   = "project-x-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256

  container_definitions = jsonencode(
    [
      {
        name  = "project-x-container"
        image = "${aws_ecr_repository.project_x.repository_url}"
        portMappings = [
          {
            containerPort = 5000
            hostPort      = 5000
          }
        ],
        memory = 512
        cpu    = 256
      }
    ]
  )
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "project_x" {
  name            = "project-x-service"
  cluster         = aws_ecs_cluster.project_x.id
  task_definition = aws_ecs_task_definition.project_x.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [module.vpc.public_subnets[0]]
    assign_public_ip = true
    security_groups  = [aws_security_group.project_x_any.id]
  }
}

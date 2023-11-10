/* Docker Image ECS Repositories */

resource "aws_ecr_repository" "project_x_web_ui" {
  name                 = "project-x-web-ui"
  image_tag_mutability = "MUTABLE"
}
resource "aws_ecr_repository" "project_x_rest_api" {
  name                 = "project-x-rest-api"
  image_tag_mutability = "MUTABLE"
}
resource "aws_ecr_repository" "project_x_graphhopper" {
  name                 = "project-x-graphhopper"
  image_tag_mutability = "MUTABLE"
}
resource "aws_ecr_repository" "project_x_cyclosm" {
  name                 = "project-x-cyclosm"
  image_tag_mutability = "MUTABLE"
}

output "project_x_web_ui_repository_id" { value = aws_ecr_repository.project_x_web_ui.registry_id }
output "project_x_rest_api_repository_id" { value = aws_ecr_repository.project_x_rest_api.registry_id }
output "project_x_graphhopper_repository_id" { value = aws_ecr_repository.project_x_graphhopper.registry_id }
output "project_x_cyclosm_repository_id" { value = aws_ecr_repository.project_x_cyclosm.registry_id }

/* ECS Cluster */

resource "aws_ecs_cluster" "project_x" {
  name = "project-x-cluster"
}

/* ECS Task Execution Role */

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

/* ECS Task Definition */

resource "aws_ecs_task_definition" "project_x" {
  family                   = "project-x-task"
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
            containerPort = 8989
            hostPort      = 8989
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

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

output "project_x_web_ui_repository_id" { value = aws_ecr_repository.project_x_web_ui.registry_id }
output "project_x_rest_api_repository_id" { value = aws_ecr_repository.project_x_rest_api.registry_id }
output "project_x_graphhopper_repository_id" { value = aws_ecr_repository.project_x_graphhopper.registry_id }

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

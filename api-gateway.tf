resource "aws_apigatewayv2_api" "project_x" {
  name          = "project-x-api-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "project_x" {
  api_id      = aws_apigatewayv2_api.project_x.id
  name        = "$default"
  auto_deploy = true
}

/* Allow HTTPS from our domain */

resource "aws_apigatewayv2_domain_name" "project_x" {
  domain_name = var.api_gw_domain

  domain_name_configuration {
    certificate_arn = var.cert_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

// Need to create CNAME of var.api_gw_domain to this value
output "api_gw_domain_name" { value = aws_apigatewayv2_domain_name.project_x.domain_name_configuration[0].target_domain_name }

/* Map our domain to the API Gateway */

resource "aws_apigatewayv2_api_mapping" "project_x" {
  api_id      = aws_apigatewayv2_api.project_x.id
  domain_name = aws_apigatewayv2_domain_name.project_x.domain_name
  stage       = aws_apigatewayv2_stage.project_x.name
}

/* REST API */

// resource "aws_apigatewayv2_vpc_link" "rest_api" {
//   name               = "project-x-rest-api"
//   security_group_ids = [aws_security_group.project_x_http.id]
//   subnet_ids         = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
// }

resource "aws_apigatewayv2_route" "rest_api" {
  api_id    = aws_apigatewayv2_api.project_x.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.rest_api.id}"
}

resource "aws_apigatewayv2_integration" "rest_api" {
  api_id             = aws_apigatewayv2_api.project_x.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = "http://${aws_alb.rest_api.dns_name}/{proxy}"
  connection_type    = "INTERNET"
}

/* Graphhopper */

resource "aws_apigatewayv2_route" "graphhopper" {
  api_id    = aws_apigatewayv2_api.project_x.id
  route_key = "ANY /router/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.graphhopper.id}"
}

resource "aws_apigatewayv2_integration" "graphhopper" {
  api_id             = aws_apigatewayv2_api.project_x.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = "http://${aws_alb.graphhopper.dns_name}/{proxy}"
  connection_type    = "INTERNET"
}

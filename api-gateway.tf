resource "aws_apigatewayv2_api" "project_x" {
  name          = "project-x-api-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "project_x" {
  api_id      = aws_apigatewayv2_api.project_x.id
  name        = "$default"
  auto_deploy = true
}

/* Link API Gateway to VPC */

resource "aws_apigatewayv2_vpc_link" "project_x" {
  name               = "project-x-vpc-link"
  security_group_ids = [aws_security_group.project_x_http.id]
  subnet_ids         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
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

resource "aws_apigatewayv2_route" "rest_api" {
  api_id    = aws_apigatewayv2_api.project_x.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.rest_api.id}"

}

resource "aws_apigatewayv2_integration" "rest_api" {
  api_id           = aws_apigatewayv2_api.project_x.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.rest_api_http.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.project_x.id

  request_parameters = {
    "overwrite:path" = "/$request.path.proxy"
  }
}

/* Graphhopper */

resource "aws_apigatewayv2_route" "graphhopper" {
  api_id    = aws_apigatewayv2_api.project_x.id
  route_key = "ANY /router/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.graphhopper.id}"
}

resource "aws_apigatewayv2_integration" "graphhopper" {
  api_id           = aws_apigatewayv2_api.project_x.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.graphhopper_http.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.project_x.id

  request_parameters = {
    "overwrite:path" = "/$request.path.proxy"
  }
}

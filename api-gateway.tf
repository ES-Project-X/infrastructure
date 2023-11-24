# resource "aws_apigatewayv2_api" "project_x" {
#   name          = "project-x-api-gw"
#   protocol_type = "HTTP"
# }
# 
# output "project_x_api_gw_id" { value = aws_apigatewayv2_api.project_x.id }
# output "project_x_api_gw_endpoint" { value = aws_apigatewayv2_api.project_x.api_endpoint }
# 
# resource "aws_apigatewayv2_stage" "project_x" {
#   api_id      = aws_apigatewayv2_api.project_x.id
#   name        = "$default"
#   auto_deploy = true
# }
# 
# /* Web UI */
# 
# resource "aws_apigatewayv2_route" "web_ui" {
#   api_id    = aws_apigatewayv2_api.project_x.id
#   route_key = "GET /web-ui"
#   target    = "integrations/${aws_apigatewayv2_integration.web_ui.id}"
# }
# 
# resource "aws_apigatewayv2_integration" "web_ui" {
#   api_id             = aws_apigatewayv2_api.project_x.id
#   integration_type   = "HTTP_PROXY"
#   integration_method = "GET"
#   integration_uri    = "http://${aws_alb.web_ui.dns_name}/"
#   connection_type    = "INTERNET"
# }
# 
# /* REST API */
# 
# resource "aws_apigatewayv2_route" "rest_api" {
#   api_id    = aws_apigatewayv2_api.project_x.id
#   route_key = "GET /rest-api"
#   target    = "integrations/${aws_apigatewayv2_integration.rest_api.id}"
# }
# 
# resource "aws_apigatewayv2_integration" "rest_api" {
#   api_id             = aws_apigatewayv2_api.project_x.id
#   integration_type   = "HTTP_PROXY"
#   integration_method = "GET"
#   integration_uri    = "http://${aws_alb.rest_api.dns_name}/"
#   connection_type    = "INTERNET"
# }
# 
# /* Graphhopper */
# 
# resource "aws_apigatewayv2_route" "graphhopper" {
#   api_id    = aws_apigatewayv2_api.project_x.id
#   route_key = "GET /graphhopper"
#   target    = "integrations/${aws_apigatewayv2_integration.graphhopper.id}"
# }
# 
# resource "aws_apigatewayv2_integration" "graphhopper" {
#   api_id             = aws_apigatewayv2_api.project_x.id
#   integration_type   = "HTTP_PROXY"
#   integration_method = "GET"
#   integration_uri    = "http://${aws_alb.graphhopper.dns_name}/"
#   connection_type    = "INTERNET"
# }
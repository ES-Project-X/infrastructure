resource "aws_cloudwatch_log_group" "web_ui" { name = "web-ui" }
resource "aws_cloudwatch_log_group" "rest_api" { name = "rest-api" }
resource "aws_cloudwatch_log_group" "graphhopper" { name = "graphhopper" }
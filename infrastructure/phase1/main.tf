variable "apex_function_ping" {}
variable "apex_function_health_check" {}

#
# Lambda functions
#
resource "aws_lambda_alias" "ping" {
  name             = "ping"
  function_name    = "${var.apex_function_ping}"
  function_version = "$LATEST"
}

resource "aws_lambda_alias" "health_check" {
  name             = "health_check"
  function_name    = "${var.apex_function_health_check}"
  function_version = "$LATEST"
}

#
# API Gateway configurations
#
resource "aws_api_gateway_rest_api" "Pingpong" {
  name        = "PingpongAPI"
  description = "Pingpong services"
}

resource "aws_api_gateway_resource" "Ping" {
  rest_api_id = "${aws_api_gateway_rest_api.Pingpong.id}"
  parent_id   = "${aws_api_gateway_rest_api.Pingpong.root_resource_id}"
  path_part   = "ping"
}

resource "aws_api_gateway_method" "PingPost" {
  rest_api_id   = "${aws_api_gateway_rest_api.Pingpong.id}"
  resource_id   = "${aws_api_gateway_resource.Ping.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "PingPost" {
  rest_api_id = "${aws_api_gateway_rest_api.Pingpong.id}"
  resource_id = "${aws_api_gateway_resource.Ping.id}"
  http_method = "${aws_api_gateway_method.PingPost.http_method}"

  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = "arn:aws:apigateway:ap-northeast-2:lambda:path/2015-03-31/functions/${aws_lambda_alias.ping.arn}/invocations"
  integration_http_method = "POST"
}

#
# CloudWatch Events
#
resource "aws_cloudwatch_event_rule" "HealthCheck" {
  name                = "pingpong-healthcheck"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "HealthCheck" {
  target_id = "health_check"
  rule      = "${aws_cloudwatch_event_rule.HealthCheck.name}"
  arn       = "${aws_lambda_alias.health_check.arn}"
}

resource "aws_lambda_permission" "CloudwatchPermission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_alias.health_check.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.HealthCheck.arn}"
}

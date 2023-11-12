locals {
  redendered_template = templatefile("api/example1/api-spec.yaml", {
    function1_arn = module.example1.function1_arn.arn
    function2_arn = module.example1.function2_arn.arn
    region        = "us-east-1"
  })
}
# API Gateway resource
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "MyAPI"
  description = "API Gateway"
  body        = local.redendered_template
}
output "name" {
  value = local.redendered_template

}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  //  depends_on  = [aws_api_gateway_rest_api.my_api]


  # Using a timestamp to ensure a new deployment on each 'terraform apply'
  triggers = {
    redeployment = sha256(jsonencode("${aws_api_gateway_rest_api.my_api.body}"))
  }


  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name    = "dev"
}

resource "aws_lambda_permission" "apigw1" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.example1.function1_arn.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw2" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.example1.function2_arn.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*"
}

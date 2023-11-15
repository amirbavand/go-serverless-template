locals {

  submodules = {
    example1 = module.example1
    // Add more submodules as needed

  }
  all_functions = flatten([
    for submodule_name, submodule in local.submodules : [
      for function_name, function_arn in submodule.function_arns : {
        submodule_name = submodule_name
        function_name  = function_name
        function_arn   = function_arn
      }
    ]
  ])
  all_function_arns = merge([
    for submodule_name, submodule in local.submodules : {
      for function_name, function_arn in submodule.function_arns : function_name => function_arn
    }
  ]...)
  rendered_template = templatefile("api/example1/api-spec.yaml", {
    functions = local.all_function_arns
    region    = "us-east-1"
  })

}
# API Gateway resource
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "MyAPI"
  description = "API Gateway"
  body        = local.rendered_template
}
output "name" {
  value = local.rendered_template

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


resource "aws_lambda_permission" "apigw_permission" {
  for_each = { for idx, val in local.all_functions : "${val.submodule_name}_${val.function_name}" => val }

  statement_id  = "AllowAPIGatewayInvoke_${each.value.function_name}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "CognitoAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  provider_arns = [aws_cognito_user_pool.my_pool.arn]
}

resource "aws_iam_role" "admin_role" {
  name = "admin_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "cognito-idp.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "admin_policy" {
  name = "admin_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "execute-api:Invoke",
          "execute-api:ManageConnections"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*/*"
          // This pattern allows access to all methods on all resources
        ]
      },
    ],
  })
}
resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.admin_role.name
  policy_arn = aws_iam_policy.admin_policy.arn
}

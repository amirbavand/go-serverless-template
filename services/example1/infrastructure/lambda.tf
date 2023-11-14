locals {
  functions = {
    "function1" = {
      description = "My first hello world function"
      handler     = "function1"
    },
    "function2" = {
      description = "My second hello world function"
      handler     = "function2"
    }
  }

  binary_path = "bin"
}

// Build the binary for the lambda functions in a specified path
resource "null_resource" "function_binary" {
  for_each = local.functions

  triggers = {
    always_run = timestamp()
    # source_files = sha256(file("${path.module}/../functions/${each.key}/${each.key}.go"))
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/../functions/${each.key} && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ../../../../bin/${each.key} ."
  }
}

// Zip the binary, as AWS Lambda can use only zip files
data "archive_file" "function_archive" {
  for_each = local.functions

  type        = "zip"
  source_file = "${local.binary_path}/${each.key}"
  output_path = "bin/${each.key}.zip"
  depends_on  = [null_resource.function_binary]
}

// Create the lambda functions from zip files
resource "aws_lambda_function" "function" {
  for_each = local.functions

  function_name = each.key
  description   = each.value.description
  role          = aws_iam_role.lambda.arn
  handler       = each.value.handler
  memory_size   = 128
  runtime       = "go1.x"

  filename         = "bin/${each.key}.zip"
  source_code_hash = data.archive_file.function_archive[each.key].output_base64sha256
}

// Create log groups in CloudWatch to gather logs of our lambda functions
resource "aws_cloudwatch_log_group" "log_group" {
  for_each = local.functions

  name              = "/aws/lambda/${aws_lambda_function.function[each.key].function_name}"
  retention_in_days = 7
}

// Output the ARNs of the Lambda functions
output "function_arns" {
  value = { for k, v in aws_lambda_function.function : k => v.arn }
}

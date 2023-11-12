locals {
  funcations_name = ["function1", "function2"]
  services_name   = "example1"
  function1_name  = "function1"
  function2_name  = "function2"
  binary_path     = "bin"
  archive1_path   = "bin/${local.function1_name}.zip"
  binary2_path    = "bin/${local.function2_name}"
  archive2_path   = "bin/${local.function2_name}.zip"

}
// build the binary for the lambda function in a specified path
resource "null_resource" "function1_binary" {
  triggers = {
    always_run = timestamp()

    #  source_files = sha256(file("${path.module}/../functions/${local.function1_name}/${local.function1_name}.go"))
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/../functions/${local.function1_name} && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ../../../../bin/${local.function1_name} ."
  }
}

// zip the binary, as we can use only zip files to AWS lambda
data "archive_file" "function1_archive" {
  depends_on = [null_resource.function1_binary]

  type        = "zip"
  source_file = "${local.binary_path}/${local.function1_name}"
  output_path = local.archive1_path
}

// create the lambda function from zip file
resource "aws_lambda_function" "function1" {
  function_name = "function1"
  description   = "My first hello world function"
  role          = aws_iam_role.lambda.arn
  handler       = local.function1_name
  memory_size   = 128

  filename         = local.archive1_path
  source_code_hash = data.archive_file.function1_archive.output_base64sha256

  runtime = "go1.x"
}

// create log group in cloudwatch to gather logs of our lambda function
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.function1.function_name}"
  retention_in_days = 7
}

# Output the ARN of the Lambda function
output "function1_arn" {
  value = aws_lambda_function.function1
}




// build the binary for the lambda function2 in a specified path
resource "null_resource" "function2_binary" {
  triggers = {
    always_run = timestamp()

    # source_files = sha256(file("${path.module}/../functions/${local.function2_name}/${local.function2_name}.go"))
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/../functions/${local.function2_name} && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ../../../../bin/${local.function2_name} ."
  }
}


// zip the binary, as we can use only zip files to AWS lambda
data "archive_file" "function2_archive" {
  depends_on = [null_resource.function2_binary]

  type        = "zip"
  source_file = "${local.binary_path}/${local.function2_name}"
  output_path = local.archive2_path
}


// create the lambda function from zip file
resource "aws_lambda_function" "function2" {
  function_name = "function2"
  description   = "My first hello world function"
  role          = aws_iam_role.lambda.arn
  handler       = local.function2_name
  memory_size   = 128

  filename         = local.archive2_path
  source_code_hash = data.archive_file.function2_archive.output_base64sha256

  runtime = "go1.x"
}

// create log group in cloudwatch to gather logs of our lambda function
resource "aws_cloudwatch_log_group" "log_group2" {
  name              = "/aws/lambda/${aws_lambda_function.function2.function_name}"
  retention_in_days = 7
}

# Output the ARN of the Lambda function
output "function2_arn" {
  value = aws_lambda_function.function2
}

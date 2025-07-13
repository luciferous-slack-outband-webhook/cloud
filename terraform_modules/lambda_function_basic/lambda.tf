resource "aws_lambda_function" "function" {
  function_name                  = replace("${var.system_name}-${var.identifier}", "_", "-")
  role                           = var.role_arn
  runtime                        = var.runtime
  architectures                  = ["arm64"]
  handler                        = var.handler
  memory_size                    = var.memory_size
  timeout                        = var.timeout
  s3_bucket                      = var.s3_bucket_deploy_package
  s3_key                         = var.s3_key_deploy_package
  source_code_hash               = var.source_code_hash
  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = true

  layers = concat(var.layers, [
    # aws-lambda-powertools[all]==3.15.1
    "arn:aws:lambda:ap-northeast-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python313-arm64:18"
  ])

  environment {
    variables = var.environment_variables
  }
}

resource "aws_lambda_alias" "function" {
  function_name    = aws_lambda_function.function.function_name
  function_version = aws_lambda_function.function.version
  name             = var.alias
}

locals {
  iam = {
    effect = {
      allow = "Allow"
    }
  }
}

# ================================================================
# Assume Role Policy Document
# ================================================================

data "aws_iam_policy_document" "assume_role_policy_event_bridge" {
  policy_id = "assume_role_policy_event_bridge"
  statement {
    sid     = "AssumeRolePolicyEventBridge"
    effect  = local.iam.effect.allow
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_lambda" {
  policy_id = "assume_role_policy_lambda"
  statement {
    sid     = "AssumeRolePolicyLambda"
    effect  = local.iam.effect.allow
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

# ================================================================
# Policy EventBridge Put Events
# ================================================================

data "aws_iam_policy_document" "policy_event_bridge_put_events" {
  policy_id = "policy_event_bridge_put_events"
  statement {
    sid       = "AllowEventBridgePutEvents"
    effect    = local.iam.effect.allow
    actions   = ["events:PutEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "event_bridge_put_events" {
  policy = data.aws_iam_policy_document.policy_event_bridge_put_events.json
}

# ================================================================
# Policy EventBridge Invoke API Destination
# ================================================================

data "aws_iam_policy_document" "policy_event_bridge_invoke_api_destination" {
  policy_id = "policy_event_bridge_invoke_api_destination"
  statement {
    sid       = "PolicyEventBridgeInvokeApiDestination"
    effect    = local.iam.effect.allow
    actions   = ["events:InvokeApiDestination"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "event_bridge_invoke_api_destination" {
  policy = data.aws_iam_policy_document.policy_event_bridge_invoke_api_destination.json
}

# ================================================================
# Policy DynamoDB Query for Lambda Function URLs
# ================================================================

data "aws_iam_policy_document" "policy_dynamodb_query_lambda_function_urls" {
  policy_id = "policy_dynamodb_query_lambda_function_urls"
  statement {
    sid    = "AllowDynamoDbQuery"
    effect = local.iam.effect.allow
    actions = [
      "dynamodb:Query"
    ]
    resources = [
      aws_dynamodb_table.slack_outband_webhook_mapping.arn,
      "${aws_dynamodb_table.slack_outband_webhook_mapping.arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "dynamodb_query_lambda_function_urls" {
  policy = data.aws_iam_policy_document.policy_dynamodb_query_lambda_function_urls.json
}

# ================================================================
# Policy SSM GetParameters for Lambda Function URLs
# ================================================================

data "aws_iam_policy_document" "policy_ssm_get_parameters_lambda_function_urls" {
  policy_id = "policy_ssm_get_parameters_lambda_function_urls"
  statement {
    sid    = "AllowSsmGetParameters"
    effect = local.iam.effect.allow
    actions = [
      "ssm:GetParameters"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ssm_get_parameters_lambda_function_urls" {
  policy = data.aws_iam_policy_document.policy_ssm_get_parameters_lambda_function_urls.json
}

# ================================================================
# Policy KMS Decrypt for Lambda Function URLs
# ================================================================

data "aws_iam_policy_document" "policy_kms_decrypt_lambda_function_urls" {
  policy_id = "policy_kms_decrypt_lambda_function_urls"
  statement {
    sid    = "AllowKmsDecrypt"
    effect = local.iam.effect.allow
    actions = [
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kms_decrypt_lambda_function_urls" {
  policy = data.aws_iam_policy_document.policy_kms_decrypt_lambda_function_urls.json
}

# ================================================================
# Role Lambda Error Processor
# ================================================================

resource "aws_iam_role" "lambda_error_processor" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_error_processor" {
  for_each = {
    a = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    b = aws_iam_policy.event_bridge_put_events.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.lambda_error_processor.name
}

# ================================================================
# Role Lambda Function URLs
# ================================================================

resource "aws_iam_role" "lambda_function_urls" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_function_urls" {
  for_each = {
    a = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    b = aws_iam_policy.dynamodb_query_lambda_function_urls.arn
    c = aws_iam_policy.ssm_get_parameters_lambda_function_urls.arn
    d = aws_iam_policy.kms_decrypt_lambda_function_urls.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.lambda_function_urls.name
}

# ================================================================
# Role EventBridge Invoke API Destination
# ================================================================

resource "aws_iam_role" "event_bridge_invoke_api_destination" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_event_bridge.json
}

resource "aws_iam_role_policy_attachment" "event_bridge_invoke_api_destination" {
  for_each = {
    a = aws_iam_policy.event_bridge_invoke_api_destination.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.event_bridge_invoke_api_destination.name
}

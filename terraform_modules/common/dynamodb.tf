# ================================================================
# DynamoDB Table
# ================================================================

resource "aws_dynamodb_table" "slack_outband_webhook_mapping" {
  name         = "${var.system_name}-slack-outband-webhook-mapping"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pairId"

  attribute {
    name = "pairId"
    type = "S"
  }

  attribute {
    name = "slackIdentifier"
    type = "S"
  }

  global_secondary_index {
    name            = "slackIdentifier-index"
    hash_key        = "slackIdentifier"
    projection_type = "ALL"
  }

}
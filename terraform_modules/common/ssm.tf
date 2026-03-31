locals {
  ssm = {
    prefix = {
      outputs = "/SlackOutbandWebhook/Cloud/Outputs"
    }
  }
}

# ================================================================
# Outputs
# ================================================================

resource "aws_ssm_parameter" "url_subscription_to_outband" {
  name  = "${local.ssm.prefix.outputs}/UrlSubscriptionToOutband"
  type  = "String"
  value = aws_lambda_function_url.subscription_to_outband.function_url
}

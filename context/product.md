# Slack Outband Webhook

## 背景/目的

- Slackチャンネルに投稿されたメッセージを他のシステムに連携したい
- Slack AppのEvent Subscriptionを使って実現したい
- 投稿されたチャンネルもしくは投稿したユーザーごとに別のURLへのPOSTでWebhookを飛ばしたい

## 制約条件

- Slack AppのEvent Subscriptionは指定したURLにPOSTで飛んでくる
  - AWSのAPI Gatewayで受け取りAWS Lambdaで処理する

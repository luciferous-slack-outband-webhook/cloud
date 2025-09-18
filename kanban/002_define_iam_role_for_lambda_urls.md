# 002_define_iam_role_for_lambda_urls.md

## 概要

- バックエンドに使用するLambdaが用いるIAM Roleを書いてください
- 必要な権限
  - LambdaのBasic Execution Role
  - 作成したDynamoDB TableへのQuery権限
    - GSIに対するQueryで使用する
  - SSM Parametersにおける `get-parameters`の権限
  - KMSにおける `decrypt`権限
    - リソースは `*`で良い

---

## 作業ログ

### 2025-07-25 19:58:11

Lambda Function URLs用のIAM Roleを`terraform_modules/common/iam.tf`に定義しました。

**作成したリソース**：
- **IAM Role**: `aws_iam_role.lambda_function_urls`
  - Lambda Assume Role Policyを設定
- **IAM Policies**:
  - `aws_iam_policy.dynamodb_query_lambda_function_urls` - DynamoDB Query権限
  - `aws_iam_policy.ssm_get_parameters_lambda_function_urls` - SSM Parameters取得権限
  - `aws_iam_policy.kms_decrypt_lambda_function_urls` - KMS復号権限
- **Policy Attachments**: 上記ポリシー + AWSLambdaBasicExecutionRole

**権限内容**：
1. Lambda Basic Execution Role（ログ出力用）
2. DynamoDBテーブル`${var.system_name}-slack-outband-webhook-mapping`とGSI`slackIdentifier-index`へのQuery権限
3. SSM ParametersのGetParameters権限（リソース: *）
4. KMS Decrypt権限（リソース: *、SSM Parameter復号用）

作業完了です。

### 2025-07-25 20:01:04

**修正作業**: Policy定義位置の調整

Policyの定義位置を他のPolicyセクションと統一するため、以下の修正を実施しました：

**修正内容**：
- Lambda Function URLs用のPolicy群（DynamoDB Query、SSM GetParameters、KMS Decrypt）を既存のEventBridge Policy群の後に移動
- Role定義セクションの前に配置するよう構造を調整

**修正後のファイル構造**：
1. Assume Role Policy Document
2. Policy EventBridge Put Events  
3. Policy EventBridge Invoke API Destination
4. **Policy DynamoDB Query for Lambda Function URLs** ← 移動
5. **Policy SSM GetParameters for Lambda Function URLs** ← 移動  
6. **Policy KMS Decrypt for Lambda Function URLs** ← 移動
7. Role Lambda Error Processor
8. Role Lambda Function URLs
9. Role EventBridge Invoke API Destination

これでファイル構造が統一され、保守性が向上しました。
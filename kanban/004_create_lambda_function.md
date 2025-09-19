# 004_create_lambda_function.md

## 概要
- subscription_to_outband.pyをハンドラーとするLambda FunctionをTerraformで定義してください
- `002_define_iam_role_for_lambda_urls.md`で作成したIAM Roleを使用してください
- Lambda Functionの定義には `lambda_function`モジュールを使用してください

## 2025-09-19 作業完了

### 実施内容
1. 既存のTerraformコード構造を調査し、commonモジュールの構成を把握
2. 002で作成されたIAM Role (`aws_iam_role.lambda_function_urls`) の詳細を確認
   - DynamoDB Query、SSM GetParameters、KMS Decryptの権限が付与済み
3. `src/handlers/subscription_to_outband/subscription_to_outband.py` の存在を確認
4. `lambda_function`モジュールの使用方法を確認
   - `lambda_function_basic`のラッパーでエラー通知機能付き
   - `subscription_destination_lambda_arn`パラメーターが必要
5. `terraform_modules/common/lambda.tf`に以下のリソースを追加
   ```hcl
   module "lambda_subscription_to_outband" {
     source = "../lambda_function"

     identifier = "subscription_to_outband"
     handler    = "handlers/subscription_to_outband/subscription_to_outband.handler"
     role_arn   = aws_iam_role.lambda_function_urls.arn

     subscription_destination_lambda_arn = module.lambda_error_processor.function_arn

     s3_bucket_deploy_package = aws_s3_object.lambda_deploy_package.bucket
     s3_key_deploy_package    = aws_s3_object.lambda_deploy_package.key
     source_code_hash         = data.archive_file.lambda_deploy_package.output_base64sha256
     system_name              = var.system_name
     runtime                  = local.lambda.runtime
     region                   = var.region
   }
   ```

### 結果
- subscription_to_outband.pyをハンドラーとするLambda Functionの定義が完了
- 002で作成したIAM Roleの適用が完了
- エラー通知機能付きのlambda_functionモジュールの使用が完了

# プロジェクト概要

このプロジェクトはSlack Appを使って、Slackチェンネルへの投稿内容を指定したURLへのWebhookに投げるための仕組みです。

## 基本原則

- チャットおよびMarkdownファイルでは日本語を使用してください
- `CLAUDE.md` および `context/*.md` について編集する場合は次のようにしてください
  - 明示的に指示があるときは編集してください
  - 明示的な指示がない場合は、何故編集が必要なのかの理由を先に提示してください

## Context

### `context/product.md`

- プロダクトの背景、目的、制約条件

### `context/architecture.md`

- 技術スタック
- 使用するライブラリ
- ライブラリの情報を取得するのに使用するMCPサーバー

### `context/python_modules.md`

- 自作のPythonモジュール
- 明示的な指示がない限り、Claude Codeが対象Pythonコードを編集することを禁じます

### `context/terraform_modules.md`

- 自作のTerraform Modules
- commonモジュール以外は、明示的な指示がない限り、Claude Codeが対象のコードを編集することを禁じます

### `context/specification.md`

- プロダクトの詳細な設計、満たすべき仕様

### `context/operation.md`

- 作業方法のルール
- これに従って作業してほしい

### `kanban/*.md`

- Claude Codeへの作業指示書
- このMarkdownファイルを明示的に指定してClaude Codeに作業させる
- このファイルに作業履歴を追記する


---
trigger: always_on
description: 開発セッション開始時に実行するルール確認フロー
---

# Session Rules Initialization

このワークフローは、開発セッションの開始時や、AIエージェントがコンテキストを見失った際に実行し、重要な運用ルールを再確認するためのものです。

## 1. Artifact Directory Selection Rule
AIエージェントはファイル操作（特に `task.md` や `implementation_plan.md` 等のアーティファクト作成・更新）を行う際、以下のルールを厳守しなければなりません。

- **ルール**: System Prompt（システム指示）に含まれる `<active_task_reminder>` や `<artifact_reminder>` セクションに記載されたパスを**唯一の正解**として扱うこと。
- **禁止事項**: 過去の会話履歴（Context History）に含まれる古いパスを使用してはならない。
- **理由**: Antigravityシステムはセッションごとに固有のディレクトリへのアクセスのみを許可しており、古いパスへの書き込みはブロックされるため。

## 2. Confirmation
- 現在の System Prompt から正しい `Brain Directory` パスを特定し、メモしてください。

## 実行可能なコマンド

以下のコマンドは実行を許可します。

- flutter analyze
-- ただし、libフォルダ以下とpackagesフォルダ以下のみに限定

- flutter test
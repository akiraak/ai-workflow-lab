---
url: https://zenn.dev/ischca/articles/cc-guide-plan-mode
fetched_at: 2026-04-06T06:00:00+09:00
---

# いきなりコードを書かせない。Claude Code「Planモード」のすすめ

## Plan mode とは

Plan mode は Claude Code の実行モードの一つで、読み取り専用の操作に制限してコードベースの分析と計画立案に専念させるモード。

## Plan mode で使えるツール

Plan mode では以下が可能：
- ファイルの閲覧・検索
- Web 検索
- 調査活動

以下は禁止：
- ファイル編集
- コマンド実行
- コード変更

## Anthropic の推奨4ステップアプローチ

1. ファイル、画像、URL の分析をコーディングなしで要求
2. Claude にアプローチ戦略の策定を依頼（Extended Thinking を利用するために "think" を使う）
3. ソリューションの実装を要求
4. コミットとプルリクエストの作成を要求

> "Steps 1-2 matter—without them, Claude tends to jump directly into coding."

計画フェーズを省略すると下流で問題が発生：
- 根本的な誤解による完全な書き直し
- 見落とされた影響範囲の後日修正
- 蓄積される手戻り

## 使い方

### セッション中の切り替え
**Shift+Tab** でモードを切り替え。最初の押下で Auto-Accept モード、次の押下で Plan mode。

### セッション開始時に Plan mode で起動
```
claude --permission-mode plan
```

### ヘッドレスモードで使用
```
claude --permission-mode plan -p "認証を分析して改善提案を出してください"
```

## 実践的なワークフロー

### 複雑なリファクタリング戦略
Plan mode で開始：
```
> Create a detailed migration strategy for moving authentication to OAuth2
```

Claude が現在の実装を分析し、包括的な計画を策定。後方互換性やデータベース移行について具体的なフォローアップ質問で確認。満足したら Plan mode を無効にして実装に進む。

### すべての実装タスクに計画を適用
軽微な修正でも計画から始める：
```
> I need this feature added. Create a plan first—don't implement yet.
```

計画をレビューし、懸念に対処してから実装を承認。

## 計画チェックリスト

以下について明確にする：
- **ゴール**: 成功とはどのようなものか
- **コンテキスト**: なぜ重要で、どのような制約があるか
- **受け入れ基準**: 完了をどう測定するか
- **境界**: 起きてはならないこと
- **想定外の対応**: 予期せぬ発見にどう対処するか

この段階での曖昧さは、実装時のズレとして再浮上する。

---
url: https://zenn.dev/hokuto_tech/articles/86d1edb33da61a
fetched_at: 2026-04-05
---

# Claude Code を初めて使う人向けの実践ガイド

## プロンプトのコツ
- 悪い例: 「このコードを改善して」
- 良い例: 「このコードのパフォーマンスを改善して。特に配列処理で、現在O(n²)をO(n)にしたい」

## 思考モードの活用
- `think` - 基本的な思考
- `think hard` - より深い思考
- `ultrathink` - 最大限の思考時間
- 1-2回実行してうまくいかない場合は ultrathink をつけると解決することが多い

## 音声入力の活用
- 音声では背景・理由・期待結果を自然に含めて話す傾向がある
- 結果としてClaude Codeはより正確な解決策を提示できる
- Superwhisperなどで日本語音声を英語翻訳し両方をClaude Codeに渡すアプローチ

## 4つの基本原則
1. Plan modeで計画立案
2. 即座のフィードバック
3. 段階的なアプローチ（こまめにgit add）
4. MCP連携による拡張

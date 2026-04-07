---
url: https://dev.to/cheetah100/pitfalls-of-claude-code-1nb6
fetched_at: 2026-04-06T12:00:00Z
---

# Pitfalls of Claude Code

By Peter Harrison

## Jumping Into Code
AI は要件を探索せずにすぐコード変更を始める。「議論なしで嬉々としてコード変更に取り掛かる」。

## Silent Decision Making
Claude がアーキテクチャ決定を目に見えない形で行う。著者は機能リグレッションのデバッグ中、AI が不正確な API ドキュメントに合わせてクライアント URL を変更していたことを発見。

## One Shot Mentality and Sycophancy
「一発で解決するよう訓練されている」「従順な解決策を提供するよう叩き込まれている」。批判的評価より回答提供を優先。

## Not Asking for Help
障害に遭遇すると「様々な検索を行ってスラッシングを始める」。明確化を求めず、無駄にトークンを消費。

## Recommended Disciplines
- TDD: テストは「部分的な嘘発見器」
- Revert and Discuss: 変更を元に戻し、選択肢を探索してから実装を許可
- Discussion Before Implementation: コーディング前に分析と比較を要求
- Hard Gates on Live Systems: エージェントはコミットできない。すべての変更に明示的な人間のレビューが必要

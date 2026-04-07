---
url: https://dev.to/docat0209/5-patterns-that-make-claude-code-actually-follow-your-rules-44dh
fetched_at: 2026-04-06T12:00:00Z
---

# 5 Patterns That Make Claude Code Actually Follow Your Rules

## Root Cause
LLM は指示を人間のように「覚えて」いない。2つの問題:
1. Primacy/recency bias: 最初と最後の指示が最も注意される
2. Cognitive load: フロンティアモデルは約150-200の離散的指示に確実に従う。Claude のシステムプロンプトが約50を消費し、ユーザールールには100-150スロットのみ

## Pattern 1: The 30-Line Rule
CLAUDE.md を200行から30行に削減。各行を「これを削除したら Claude がミスするか？」でテスト。

## Pattern 2: Positive Instructions Over Negative Ones
否定形の指示を肯定形に書き換える。「セミコロンを使うな」→「セミコロンを省略する」。
10個の否定ルールを肯定に書き換えて違反が約50%減少。

## Pattern 3: Anchor Critical Rules at Top and Bottom
Primacy/recency bias を意図的に利用。最も違反されるルールを文書の最初5行と最後5行に配置（意図的に重複）。

## Pattern 4: Use Hooks for Hard Enforcement
プロンプトレベルの指示は「提案」、Hooks は「システムレベルの強制」。
3回違反されるルールは CLAUDE.md から Hooks に移行する。

## Pattern 5: Scope Rules to Subdirectories
複数レベルに CLAUDE.md を配置。ルート CLAUDE.md をスリムに保ちながら、文脈に応じた精密な指示を提供。

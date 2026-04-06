import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'AI Workflow Lab',
  description: 'AI を普段の開発・作業ワークフローに組み込む手法の調査・検証',
  lang: 'ja',
  base: '/ai-workflow-lab/',

  srcExclude: [
    '**/research/cache/**/[0-9]*.md',
    '**/research/cache/**/_index.md',
    'README.md',
    'TODO.md',
    'DONE.md',
    'CLAUDE.md',
    'plans/**',
    'node_modules/**',
  ],

  themeConfig: {
    nav: [
      { text: 'ホーム', link: '/' },
      { text: '調査結果', link: '/experiments/claude-code-prompting/' },
      { text: 'Web調査キャッシュ', link: '/research/' },
    ],

    sidebar: {
      '/experiments/': [
        {
          text: 'Claude Code プロンプティング',
          items: [
            { text: '1-1. 対話プロンプトの特性', link: '/experiments/claude-code-prompting/01-prompt-characteristics' },
            { text: '1-2. CLAUDE.md の活用法', link: '/experiments/claude-code-prompting/02-claude-md' },
            { text: '1-3. Plan mode の活用法', link: '/experiments/claude-code-prompting/03-plan-mode' },
            { text: '1-4. slash commands・ツール連携', link: '/experiments/claude-code-prompting/04-slash-commands' },
            { text: '1-5. 最適なディレクトリ構成', link: '/experiments/claude-code-prompting/05-directory-structure' },
            { text: '1-6. .claude ディレクトリ', link: '/experiments/claude-code-prompting/06-dot-claude' },
            { text: '1-7. ファイル把握の仕組み', link: '/experiments/claude-code-prompting/07-file-discovery' },
            { text: '1-8. コンテキスト制御', link: '/experiments/claude-code-prompting/08-context-control' },
          ],
        },
        {
          text: 'Phase 2: タスク別指示パターン',
          items: [
            { text: '2-1. バグ修正', link: '/experiments/claude-code-prompting/09-task-bug-fix' },
            { text: '2-2. 新機能実装', link: '/experiments/claude-code-prompting/10-task-new-feature' },
            { text: '2-3. リファクタリング', link: '/experiments/claude-code-prompting/11-task-refactoring' },
            { text: '2-4. コードレビュー・説明', link: '/experiments/claude-code-prompting/12-task-code-review' },
          ],
        },
      ],
      '/research/': [
        {
          text: 'Web 調査キャッシュ',
          items: [
            { text: '2026-04-05', link: '/research/cache/2026-04-05T000000/' },
            { text: '2026-04-06', link: '/research/cache/2026-04-06T000000/' },
            { text: '2026-04-06 (Phase 2)', link: '/research/cache/2026-04-06T060000/' },
          ],
        },
      ],
    },

    search: {
      provider: 'local',
    },

    outline: {
      level: [2, 3],
      label: '目次',
    },

    docFooter: {
      prev: '前のページ',
      next: '次のページ',
    },
  },
})

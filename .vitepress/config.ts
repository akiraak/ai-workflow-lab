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
          ],
        },
      ],
      '/research/': [
        {
          text: 'Web 調査キャッシュ',
          items: [
            { text: '2026-04-05', link: '/research/cache/2026-04-05T000000/' },
            { text: '2026-04-06', link: '/research/cache/2026-04-06T000000/' },
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

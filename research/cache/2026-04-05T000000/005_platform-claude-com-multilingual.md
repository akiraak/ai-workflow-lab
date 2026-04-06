---
url: https://platform.claude.com/docs/en/build-with-claude/multilingual-support
fetched_at: 2026-04-05
---

# Multilingual support

Claude excels at tasks across multiple languages, maintaining strong cross-lingual performance relative to English.

## Performance data (MMLU, zero-shot chain-of-thought, relative to English 100%)

| Language | Claude Opus 4.1 | Claude Opus 4 | Claude Sonnet 4.5 | Claude Sonnet 4 | Claude Haiku 4.5 |
|----------|-----------------|---------------|-------------------|-----------------|------------------|
| English (baseline) | 100% | 100% | 100% | 100% | 100% |
| Spanish | 98.1% | 98.0% | 98.2% | 97.5% | 96.4% |
| Japanese | 96.9% | 96.2% | 96.8% | 95.6% | 93.5% |
| Chinese (Simplified) | 97.1% | 96.7% | 96.9% | 95.9% | 94.2% |
| Korean | 96.6% | 96.4% | 96.7% | 95.9% | 93.3% |

## Best practices

1. Provide clear language context: explicitly state desired input/output language
2. Use native scripts: submit text in native script rather than transliteration
3. Consider cultural context: effective communication requires cultural and regional awareness

## Language support considerations

- Claude processes input in most languages using standard Unicode characters
- Performance varies by language, with strongest in widely-spoken languages
- Even in lower-resource languages, Claude maintains meaningful capabilities

---
url: https://github.com/tldraw/make-real/blob/main/CLAUDE.md
fetched_at: 2026-04-06T12:00:00Z
---

# CLAUDE.md — tldraw/make-real

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview
Make Real is a Next.js application that transforms hand-drawn wireframes into working HTML prototypes using AI. Built on the tldraw SDK. Live at: https://makereal.tldraw.com

## Development Commands
```bash
yarn install
yarn dev       # Dev server on http://localhost:3000
yarn build     # Production build
yarn start     # Production server
yarn lint      # Lint code
```
No test suite exists. TypeScript strict mode is disabled.

## Architecture
### Core Flow
1. User draws wireframes on tldraw canvas
2. Selected shapes captured as JPEG via editor.toImage()
3. Image + prompts sent to AI provider API routes
4. Streamed HTML response parsed for DOCTYPE boundaries
5. Generated HTML rendered in PreviewShape iframe
6. Completed HTML uploaded to Vercel Postgres

### Host-Based Routing
middleware.ts rewrites based on hostname.

### Key Components
- useMakeReal Hook: Main orchestration
- PreviewShape: Custom tldraw shape rendering HTML in iframe
- Settings System: MIGRATION_VERSION, localStorage persistence

### API Routes
OpenAI, Anthropic, Google — all streaming text responses with maxDuration: 60.

## Code Patterns
### Adding a New AI Provider
1. Add to PROVIDERS array in settings.tsx
2. Create API route
3. Add case in switch block in useMakeReal.ts

### Modifying Prompts
1. Create new prompt constant in prompt.ts
2. Update references in settings.tsx
3. Increment MIGRATION_VERSION

## Technology Stack
Next.js 14 (App Router), tldraw 4.x, Vercel AI SDK, Tailwind CSS

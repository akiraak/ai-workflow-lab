---
url: https://code.claude.com/docs/en/gitlab-ci-cd
fetched_at: 2026-04-09T10:00:00+09:00
---

# Claude Code GitLab CI/CD

> Learn about integrating Claude Code into your development workflow with GitLab CI/CD

> **Info:** Claude Code for GitLab CI/CD is currently in beta. Features and functionality may evolve as we refine the experience. This integration is maintained by GitLab.

> **Note:** This integration is built on top of the Claude Code CLI and Agent SDK, enabling programmatic use of Claude in your CI/CD jobs and custom automation workflows.

## Why use Claude Code with GitLab?

* **Instant MR creation**: Describe what you need, and Claude proposes a complete MR with changes and explanation
* **Automated implementation**: Turn issues into working code with a single command or mention
* **Project-aware**: Claude follows your `CLAUDE.md` guidelines and existing code patterns
* **Simple setup**: Add one job to `.gitlab-ci.yml` and a masked CI/CD variable
* **Enterprise-ready**: Choose Claude API, AWS Bedrock, or Google Vertex AI to meet data residency and procurement needs
* **Secure by default**: Runs in your GitLab runners with your branch protection and approvals

## How it works

1. **Event-driven orchestration**: GitLab listens for your chosen triggers (e.g., a comment that mentions `@claude`). The job collects context, builds prompts, and runs Claude Code.

2. **Provider abstraction**: Use Claude API (SaaS), AWS Bedrock (IAM-based), or Google Vertex AI (GCP-native).

3. **Sandboxed execution**: Each interaction runs in a container with strict network and filesystem rules. Claude Code enforces workspace-scoped permissions. Every change flows through an MR.

## What can Claude do?

* Create and update MRs from issue descriptions or comments
* Analyze performance regressions and propose optimizations
* Implement features directly in a branch, then open an MR
* Fix bugs and regressions identified by tests or comments
* Respond to follow-up comments to iterate on requested changes

## Setup

### Quick setup

1. **Add a masked CI/CD variable**: Settings > CI/CD > Variables, add `ANTHROPIC_API_KEY` (masked, protected)

2. **Add a Claude job to `.gitlab-ci.yml`**:

```yaml
stages:
  - ai

claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  variables:
    GIT_STRATEGY: fetch
  before_script:
    - apk update
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - echo "$AI_FLOW_INPUT for $AI_FLOW_CONTEXT on $AI_FLOW_EVENT"
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Review this MR and implement the requested changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
```

### Manual setup (recommended for production)

1. **Configure provider access**: Claude API, AWS Bedrock (OIDC), or Google Vertex AI (WIF)
2. **Add project credentials**: `CI_JOB_TOKEN` or Project Access Token with `api` scope
3. **Add the Claude job** to `.gitlab-ci.yml`
4. **(Optional) Enable mention-driven triggers**: Add project webhook for "Comments (notes)"

## Configuration examples

### Basic .gitlab-ci.yml (Claude API)

```yaml
stages:
  - ai

claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  before_script:
    - apk update
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Summarize recent changes and suggest improvements'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
```

### AWS Bedrock job example (OIDC)

Prerequisites:
* Amazon Bedrock enabled with Claude model permissions
* GitLab OIDC configured in AWS
* IAM role with Bedrock permissions

```yaml
claude-bedrock:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
  before_script:
    - apk add --no-cache bash curl jq git python3 py3-pip
    - pip install --no-cache-dir awscli
    - curl -fsSL https://claude.ai/install.sh | bash
    - export AWS_WEB_IDENTITY_TOKEN_FILE="${CI_JOB_JWT_FILE:-/tmp/oidc_token}"
    - if [ -n "${CI_JOB_JWT_V2}" ]; then printf "%s" "$CI_JOB_JWT_V2" > "$AWS_WEB_IDENTITY_TOKEN_FILE"; fi
    - >
      aws sts assume-role-with-web-identity
      --role-arn "$AWS_ROLE_TO_ASSUME"
      --role-session-name "gitlab-claude-$(date +%s)"
      --web-identity-token "file://$AWS_WEB_IDENTITY_TOKEN_FILE"
      --duration-seconds 3600 > /tmp/aws_creds.json
    - export AWS_ACCESS_KEY_ID="$(jq -r .Credentials.AccessKeyId /tmp/aws_creds.json)"
    - export AWS_SECRET_ACCESS_KEY="$(jq -r .Credentials.SecretAccessKey /tmp/aws_creds.json)"
    - export AWS_SESSION_TOKEN="$(jq -r .Credentials.SessionToken /tmp/aws_creds.json)"
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Implement the requested changes and open an MR'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
  variables:
    AWS_REGION: "us-west-2"
```

### Google Vertex AI job example (Workload Identity Federation)

```yaml
claude-vertex:
  stage: ai
  image: gcr.io/google.com/cloudsdktool/google-cloud-cli:slim
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
  before_script:
    - apt-get update && apt-get install -y git && apt-get clean
    - curl -fsSL https://claude.ai/install.sh | bash
    - gcloud auth login --cred-file=<(WIF configuration JSON)
  script:
    - /bin/gitlab-mcp-server || true
    - >
      CLOUD_ML_REGION="${CLOUD_ML_REGION:-us-east5}"
      claude
      -p "${AI_FLOW_INPUT:-'Review and update code as requested'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
  variables:
    CLOUD_ML_REGION: "us-east5"
```

## Best practices

### CLAUDE.md configuration
Create a `CLAUDE.md` file at the repository root to define coding standards, review criteria, and project-specific rules.

### Security considerations
- Never commit API keys or cloud credentials
- Use CI/CD masked variables
- Use provider-specific OIDC where possible
- Limit job permissions and network egress
- Review Claude's MRs like any other contributor

### CI costs
- GitLab Runner time consumes compute minutes
- API costs vary by task complexity
- Use specific `@claude` commands, set max_turns, limit concurrency

## Security and governance

- Each job runs in an isolated container with restricted network access
- Changes flow through MRs with reviewer approval
- Branch protection and approval rules apply
- Claude Code uses workspace-scoped permissions
- Costs remain under your control (bring your own credentials)

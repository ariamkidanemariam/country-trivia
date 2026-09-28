# OpenCode API Key Setup Guide

This guide explains how to obtain an OpenCode API key and configure it for the GitHub Actions PR review workflow.

## Prerequisites

- A GitHub account with admin access to this repository
- An OpenCode account (https://opencode.ai)

## Step 1: Get Your OpenCode API Key

1. Go to https://opencode.ai and sign in (or create an account)
2. Navigate to **Settings** → **API Keys**
3. Click **Create New Key**
4. Give it a name (e.g., `github-actions-pr-review`)
5. Copy the generated key — you won't be able to see it again

## Step 2: Add the Key to GitHub Secrets

1. Go to this repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Set the name to: `OPENCODE_API_KEY`
5. Paste your OpenCode API key as the value
6. Click **Add secret**

## Step 3: Verify the Workflow

1. The workflow is defined in `.github/workflows/pr-review.yml`
2. It triggers automatically when a PR is opened, updated, or reopened
3. To test: open a new PR and the review will run automatically
4. Check the **Actions** tab to see the workflow execution

## How It Works

```
PR Opened/Updated
       │
       ▼
┌──────────────────┐
│ GitHub Actions   │
│ workflow triggers│
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Checkout code    │
│ Install OpenCode │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Get PR diff      │
│ Build review     │
│ prompt           │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ OpenCode CLI     │
│ (big-pickle)     │
│ generates review │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Post review as   │
│ PR comment       │
└──────────────────┘
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Workflow fails with "API key not found" | Verify `OPENCODE_API_KEY` secret is set in repo settings |
| Review is empty or truncated | The diff may be too large; consider splitting large PRs |
| OpenCode CLI not found | Check the install step in the workflow logs |
| Rate limits | OpenCode free tier has limits; upgrade if needed |

## Security Notes

- Never commit the API key to the repository
- The key is stored encrypted in GitHub Secrets
- Only workflows with `pull-requests: write` permission can post reviews
- The key is only exposed to the workflow runtime, not to PR authors

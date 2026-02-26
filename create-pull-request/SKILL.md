---
name: create-pull-request
description: Create or update a draft PR from git diff (title + body)
---

Execution permissions:

- You may use `git` to:
  - detect default branch
  - compute diff
- You may use `gh` CLI to:
  - detect existing PR for current branch
  - read PR body
  - create draft PR
  - update PR title and body

Use this skill when the user asks to create or update PR metadata.

Do not use shell scripts for metadata generation.
Do not use `codex exec` inside any script.
Do not implement heuristics or pre-classification in bash.

Workflow:

1. Detect default branch.
2. Run `git diff origin/<default-branch>...HEAD`.
3. Include unstaged changes only if the user explicitly asks.
4. Reason directly over raw diff content.
5. Generate:

- title: Conventional Commit style, lowercase, max 72 chars
- body: MUST always be wrapped in this exact marker block (even when creating a new PR):

  <!-- auto-pr-metadata:start -->

  ## Changes
  - ...
  <!-- auto-pr-metadata:end -->

- Inside the marker block, ONLY these sections are allowed:
  - `## Changes`
  - optional `## Notes`
- No other sections allowed (no `Summary`, no `Testing`).

6. Validate before applying:

- title must match this regex:
  `^(feat|fix|refactor|chore|docs|test|ci|perf)($begin:math:text$\[a\-z0\-9\.\_\/\-\]\+$end:math:text$)?: [a-z0-9][a-z0-9 -]{0,69}$`
- body MUST contain BOTH markers exactly once:
  - `<!-- auto-pr-metadata:start -->`
  - `<!-- auto-pr-metadata:end -->`
- body must contain:
  - `## Changes` with 3–8 bullets
  - optional `## Notes` with 0–3 bullets
- The marker block must be the ONLY auto-generated content you create/overwrite.

7. Dry-run output first:

- Print the proposed title and the full body (including markers).
- Then print exactly:
  `Type 'continue' to apply, anything else to cancel.`

8. Only if the next user message is exactly `continue`:

- Detect whether an open PR exists for the current branch (prefer PR targeting the default branch).

If PR exists:

- Update the PR title.
- Update ONLY the content inside the markers:
  - `<!-- auto-pr-metadata:start -->`
  - `<!-- auto-pr-metadata:end -->`
- Preserve all user-authored text outside the markers.
- If markers do not exist yet in the PR body, prepend the marker block at the top and keep the existing body below it unchanged.

If PR does not exist:

- Create a DRAFT PR targeting the default branch.
- The PR body MUST include the marker block on first creation (do not omit markers).

Output behavior:

- Keep output concise.
- When done, print PR URL and final title only.

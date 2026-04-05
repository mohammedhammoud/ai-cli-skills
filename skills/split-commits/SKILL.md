---
name: split-commits
description: Group current changes into multiple commitlint-compliant commits and apply on confirmation
argument-hint: "Optional: focus area or grouping preference"
---

Analyze current repository changes and split them into multiple coherent commits.

Repository policy:

- Before applying this skill, read `AGENTS.md` (or equivalent repo-local instructions) if present.
- Repository-specific commit conventions override this skill's generic defaults.
- If the repository defines additional allowed commit types, scopes, or casing rules, follow that policy.
- If commitlint config exists, treat it as authoritative for format constraints.

Workflow:

1. Inspect all current changes:
   - Run: `git status --short`
   - Run: `git diff --stat`
   - Run: `git diff --cached --stat`
   - Run detailed diffs only when summaries are insufficient.
2. Propose a commit plan that groups related changes by intent.
   - Prefer grouping by file boundaries for safe staging.
   - Avoid splitting a single file across multiple commits unless explicitly requested.
   - Keep the number of commits minimal but meaningful.
3. Generate one commit message per planned commit.
4. Validate each message against commitlint/repository rules.

Message rules (default when no stricter repo rule exists):

- Format: `<type>(optional-scope): short description`
- Allowed types: feat, fix, refactor, chore, docs, test, ci, perf
- Lowercase only
- Max 72 characters
- No trailing period
- Description must reflect outcome/intent, not low-level implementation detail

Dry-run output rules:

- Print the full proposed commit plan in order.
- For each commit, include:
  - commit number
  - commit message
  - short file list
- Then print exactly:
  `Type 'continue' to create these commits or anything else to cancel.`

Execution rules:

- Do NOT commit unless the user's next reply is exactly: continue
- On `continue`, create commits in the proposed order.
- Stage only the files/hunks that belong to each planned commit.
- Never use `git commit --no-verify` (or any commit command with `--no-verify`).
- If safe non-interactive staging is not possible for the proposed split, stop and report the blocker instead of making partial/incorrect commits.
- If user reply is anything else, exit silently.

Output behavior:

- Keep output concise.
- After successful execution, print the created commit SHAs in order.

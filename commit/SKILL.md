---
name: commit
description: Generate and optionally apply a Conventional Commit from staged changes
---

Generate a single best Conventional Commit message from staged changes.

Steps:

1. Inspect staged changes:
   - Run: `git diff --cached --stat`
   - Run: `git diff --cached` only if summary is insufficient.

2. Internally generate 3 candidate messages.
3. Select the single best message.

Commit rules:

- Format: `<type>(optional-scope): short description`
- Allowed types: feat, fix, refactor, chore, docs, test, ci, perf
- Lowercase only
- Max 72 characters
- No trailing period
- Be precise and reflect staged intent, not implementation detail
- If multiple concerns exist, prefer the dominant change

Output rules:

- Print ONLY the selected commit message (one line).
- Then print exactly:
  Type 'continue' to commit or anything else to cancel.

Execution rules:

- Do NOT commit unless the next user message is exactly: continue
- If user replies `continue`, run:
  `git commit -m "<message>"`
- Otherwise, exit silently.

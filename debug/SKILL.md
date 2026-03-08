---
name: debug
description: Debug a bug from a given entrypoint file, prove root cause, propose a minimal patch
---

Use when the user wants root-cause debugging starting from a specific file.

Repository policy:

- Before applying this skill, read `AGENTS.md` (or equivalent repo-local instructions) if present.
- Repository-specific constraints on validation, file scope, coding standards, and output override this skill's generic defaults.
- If repository policy conflicts with the generic rules below, prefer repository policy and state the conflict briefly if needed.

Required input (must be present):

1. Entrypoint file path
2. Expected behavior
3. Actual behavior
4. Reproduction steps (how to trigger)

Optional:

- Error message / stack trace / logs (if any)

If any required item is missing:

- Print exactly which item(s) are missing.
- Exit.

Rules:

- Assume the bug exists.
- No guessing: every claim must point to code evidence.
- No broad refactors, no new abstractions, no unrelated improvements.
- Do not run tests, do not commit, do not open PRs.

Workflow:

1. Read the entrypoint file.
2. Trace the execution path step-by-step.
3. If not found in entrypoint, follow the call chain one layer at a time until proven.

Output:

1. Root cause (file + line + explanation)
2. Proof (why this matches the observed behavior)
3. Minimal fix (exact patch/snippet)
4. Risk level (low|medium|high)

Then print exactly:
Type "continue" to apply this minimal patch. Anything else cancels.

Apply phase (only if next message is exactly "continue"):

- Apply ONLY the minimal fix described above.
- Modify ONLY the referenced file(s).
- Do NOT refactor anything else.
- Do NOT run tests.
- Do NOT create commits.
- Do NOT open pull requests.
- Do NOT trigger CI.
- Do NOT invoke other skills.
- Stop immediately after applying.

Then print:

- `git status --short`
- `git diff --stat`

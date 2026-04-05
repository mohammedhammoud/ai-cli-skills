---
name: debug
description: Debug a bug from an entrypoint or symptom, prove root cause, propose a minimal patch
argument-hint: "[entrypoint] [expected] [actual] [repro] [mode quick|strict]"
---

Use when the user wants root-cause debugging starting from a specific file.

Repository policy:

- Before applying this skill, read `AGENTS.md` (or equivalent repo-local instructions) if present.
- Repository-specific constraints on validation, file scope, coding standards, and output override this skill's generic defaults.
- If repository policy conflicts with the generic rules below, prefer repository policy and state the conflict briefly if needed.

Preferred input:

1. Entrypoint file path
2. Expected behavior
3. Actual behavior
4. Reproduction steps (how to trigger)

Optional:

- Error message / stack trace / logs (if any)

Minimum start condition:

- Entrypoint file path OR one concrete symptom (error/log/failing behavior).

If preferred items are missing:

- Start with available context.
- List missing items briefly as "helpful context" (not blockers).
- Continue investigation and ask for only the next most valuable missing detail when needed.

Debug modes:

- `quick` (default): prioritize fast triage, likely root cause, and smallest verifiable next step.
- `strict`: require full evidence chain before proposing a fix.
- If the user does not specify mode, use `quick`.

Rules:

- Assume the bug exists.
- No guessing: every claim must point to code evidence.
- No broad refactors, no new abstractions, no unrelated improvements.
- Do not run tests, do not commit, do not open PRs.

Workflow:

1. Start from provided entrypoint or symptom source.
2. Trace the execution path step-by-step.
3. If not found, follow the call chain one layer at a time.
4. In `quick` mode, provide the best evidence-backed hypothesis and the next verification step when proof is incomplete.
5. In `strict` mode, continue until root cause is proven end-to-end before proposing a fix.

Output:

1. Root cause or best current hypothesis (file + line + explanation)
2. Proof status:
   - proven evidence, or
   - strongest evidence so far + next verification step
3. Minimal fix (exact patch/snippet) when justified
4. Risk level (low|medium|high)

Then print exactly:
Type "continue" to apply this minimal patch. Anything else cancels.

Apply phase (only if the user's next reply is exactly "continue"):

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

---
name: review
description: Review staged or unstaged changes for bugs, risks, and minimal risk-reducing fixes
---

Usage (required):

- $review staged
- $review changes

Argument must be exactly one of:
- staged
- changes

If missing or invalid:
Print ONLY:
Usage: $review staged | $review changes
Exit.

---

Behavior:

If argument is `staged`:
- Run: `git diff --cached --stat`
- Run: `git diff --cached`

If argument is `changes`:
- Run: `git diff --stat`
- Run: `git diff`

Only inspect the diff output.
Do NOT scan the entire repository.
Do NOT run tests.
Do NOT modify files.
Do NOT commit.

---

Review goals:

Detect:

- Functional bugs
- Regressions
- Edge-case risks
- i18n violations (hardcoded UI strings)
- TypeScript looseness (`any`, unsafe casts)
- Missing tests
- Accessibility issues
- Architectural drift

Do NOT invent issues just to suggest changes.
It is valid to conclude that everything looks correct.

Only suggest changes if they:

- Reduce real risk
- Preserve behavior
- Are minimal and scoped

Do NOT propose architectural refactors.

---

Output format:

1. Blocking issues
2. Functional bugs
3. Risky patterns
4. Missing tests
5. Overall risk level: low | medium | high

If overall risk level is NOT low:

- Propose a minimal, behavior-preserving fix
- Clearly list affected files
- Explain why it reduces risk
- Then print:

Type 'continue' to apply the fix or anything else to cancel.

If overall risk level is low:

- Print: "No changes required."
- Do NOT propose refactors.
- Do NOT print the continue instruction.
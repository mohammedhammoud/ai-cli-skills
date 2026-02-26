# codex-user-skills

User-defined Codex skills, versioned in Git.

## Structure

- `<skill-name>/SKILL.md`
- `<skill-name>/scripts/...` (optional)
- `link.sh` (symlinks skills into `~/.codex/skills`)

## Install / Sync

```bash
./link.sh
```

This links all skill directories from this repo into `~/.codex/skills`.

## Notes

- Keep `~/.codex/skills/.system` untouched (managed by Codex).
- This repo should only contain user skills.

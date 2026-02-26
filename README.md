# codex-skills

User-defined Codex skills, versioned in Git.

## 1. Structure

Follow OpenAI's official guidance for skill structure and conventions:

- <https://platform.openai.com/docs/guides/skills>

Repository layout used here:

- `<skill-name>/SKILL.md`
- `<skill-name>/scripts/...` (optional)
- `link.sh` (symlinks skills into `~/.codex/skills`)

## 2. Install / Sync

```bash
cd ~/code/codex-skills
./link.sh
```

What this does:

- Creates `~/.codex/skills` if needed
- Symlinks each skill directory from this repo into `~/.codex/skills`
- Keeps `~/.codex/skills/.system` untouched

## 3. How We Work

Standard flow:

1. Make changes
2. Run `$review`
3. Fix changes if needed
4. Run `$commit`
5. Accept commit message
6. Run `$create-pull-request`
7. Continue if everything looks good

## 4. Notes

- This repo should only contain user-defined skills.
- Do not modify `~/.codex/skills/.system` manually.
- Prefer small, focused commits.
- Re-run `./link.sh` after adding a new skill folder.

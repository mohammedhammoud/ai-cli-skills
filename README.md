# ai-cli-skills

Personal Codex and GitHub Copilot skills.
Optimized for my setup. Public as reference.

More context:

- <https://mohammedhammoud.com/blog/how-i-turned-codex-cli-into-a-structured-engineering-assistant/>

## 1. Structure

Follow the official skill guidance for the CLIs this repo targets:

- <https://platform.openai.com/docs/guides/skills>
- <https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills>

Layout:

- `src/skills/<skill-name>/SKILL.md`
- `src/skills/<skill-name>/scripts/...` (optional)
- `src/instructions.md`
- `install.sh`

## 2. Install / Sync

Need:

- `git`
- Codex and/or GitHub Copilot CLI with local skills support
- `gh` CLI for workflows that create or update pull requests
- GitHub authentication configured for `gh` when using PR automation
- `rtk` recommended

```bash
git clone <your-fork-or-repo-url> ~/code/ai-cli-skills
cd ~/code/ai-cli-skills
./install.sh
```

Path is example only.

`./install.sh`:

- Offers to install `rtk` if missing
- If `rtk` exists, offers to run `rtk init` for detected tools
- If `~/.codex` exists, symlinks each skill directory from `src/skills/` into `~/.codex/skills` and symlinks `src/instructions.md` into `~/.codex/AGENTS.md`
- If `~/.copilot` exists, symlinks each skill directory from `src/skills/` into `~/.copilot/skills` and symlinks `src/instructions.md` into `~/.copilot/copilot-instructions.md`
- Removes stale symlinks in those skill directories when a skill from this repo is renamed or removed
- Skips any CLI home directory that is not present

## 3. Typical Workflow

1. `debug`
2. change code or `refactor`
3. `audit`
4. fix if needed
5. `commit`
6. accept commit message
7. `create-or-update-pr`
8. continue if good

Hands-off flow: `lazy`.

## 4. Repo Notes

- Re-run `./install.sh` after changing `src/skills/` or `src/instructions.md`.
- Prefer `rtk` when installed. Fallback to raw commands when needed.
- Some skills assume GitHub-hosted repos and detect remotes at runtime.
- Skills and shared instructions are global symlinks into supported CLI home dirs.

## 5. Skills

- `commit`: commit message from staged diff (`src/skills/commit/SKILL.md`)
- `create-or-update-pr`: create or refresh draft PR metadata (`src/skills/create-or-update-pr/SKILL.md`)
- `debug`: root-cause debug, then minimal patch (`src/skills/debug/SKILL.md`)
- `audit`: review diff for bugs and risk (`src/skills/audit/SKILL.md`)
- `lazy`: end-to-end branch, change, validate, commit, push, draft PR (`src/skills/lazy/SKILL.md`)
- `rebase`: safe local rebase only (`src/skills/rebase/SKILL.md`)
- `refactor`: safe behavior-preserving cleanup (`src/skills/refactor/SKILL.md`)
- `split-commits`: split current changes into coherent commits (`src/skills/split-commits/SKILL.md`)

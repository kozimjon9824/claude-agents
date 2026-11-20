# Claude Code agents for Flutter development

Thirteen [Claude Code subagents](https://code.claude.com/docs/en/sub-agents) that speed up day-to-day Flutter work: wiring APIs, matching Figma, reviewing, refactoring, testing (including golden and Patrol E2E tests), debugging crashes, translations, security, dependency upgrades, release notes and Jira — plus a `feature-pipeline` skill that chains them.

Each agent reads the rules of the project it runs in (`CLAUDE.md`, `.cursor/rules`), so they work in any Flutter project. Start from [`templates/CLAUDE.md`](templates/CLAUDE.md): the more of it you fill in (commands, environments, test data, code rules), the less the agents guess or ask.

Agents work against dev/staging only, never production; anything that writes data, posts to Jira or pushes code waits for your confirmation.

| Agent | What it does | Edits files? |
|---|---|---|
| `api-integrator` | Connects a backend endpoint end to end from backend source, OpenAPI or a live call: DTO, Retrofit method, repository, domain model, code generation, live check | yes |
| `figma-matcher` | Compares a Figma frame with the running screen and lists pixel differences with exact fixes | no |
| `flutter-code-reviewer` | Reviews changes against project rules: localization, state, layout, 250-line files, widgets folder, accessibility… | no |
| `flutter-refactorer` | Applies review findings without changing behaviour: splits pages into widgets, `const`, keys, tokens | yes |
| `flutter-test-writer` | Writes and runs cubit, repository, widget and golden tests | tests only |
| `flutter-bug-investigator` | Finds a bug's root cause from logs, data or a crash report (symbolicates obfuscated traces), reports the smallest fix and a reproducing test | no |
| `l10n-auditor` | Missing/unused/undefined translation keys, hard-coded strings, Cyrillic script checks | no |
| `simulator-qa-tester` | Runs user flows on the iOS Simulator and checks the screen against backend data | no |
| `patrol-test-writer` | Writes and runs Patrol E2E tests for critical flows on dev/staging, adds stable widget keys, checks for flakiness | tests + keys |
| `jira-writer` | Writes finished work to Jira in the team's existing style and moves it to Done | Jira only |
| `mobile-security-auditor` | Security review for finance/banking apps: storage, secrets, logs, TLS/pinning, screenshots, release hardening, deep links | no |
| `dependency-upgrader` | Upgrades packages in small batches, reads changelogs, migrates code, keeps analyze and tests green | yes |
| `release-notes-writer` | Internal changelog plus uz/ru/en App Store and Google Play notes within store limits | no |

## Skill

| Skill | What it does |
|---|---|
| `feature-pipeline` | Jira ticket → API → UI → tests → review → simulator QA → MR draft, with an analyze/test gate after every step; pushes and Jira updates only after you confirm |

## Install

```bash
git clone https://github.com/kozimjon9824/claude-agents.git ~/claude-agents
```

Link the folder so Claude Code loads the agents in every project (move any existing `~/.claude/agents` aside first):

```bash
ln -s ~/claude-agents/agents ~/.claude/agents
```

Link the skills the same way (move any existing `~/.claude/skills` aside first):

```bash
ln -s ~/claude-agents/skills ~/.claude/skills
```

Open a new Claude Code session — the agents load at session start.

To install for one project only, copy the files into that project's `.claude/agents/` and `.claude/skills/` instead.

## Update

```bash
git -C ~/claude-agents pull
```

## Use

Ask in plain words, e.g.:

- "review my changes with flutter-code-reviewer", then "apply it with flutter-refactorer"
- "compare Figma frame 5351:1710 with the screen using figma-matcher"
- "write tests for the orders cubit with flutter-test-writer"
- "audit translations with l10n-auditor"
- "security review my changes with mobile-security-auditor"
- "implement ABC-123 end to end" (uses the `feature-pipeline` skill)

Claude also picks an agent on its own when a task matches its description.

## Requirements

- Claude Code
- Flutter SDK on `PATH` (or resolvable from the project's `.dart_tool/package_config.json`)
- Optional tools some agents use: an iOS Simulator (`simulator-qa-tester`, `figma-matcher`, `patrol-test-writer`), Patrol CLI (`patrol-test-writer`), a Figma MCP connection (`figma-matcher`), a Jira MCP connection (`jira-writer`)

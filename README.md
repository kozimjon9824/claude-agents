# Claude Code agents for Flutter development

Nine [Claude Code subagents](https://code.claude.com/docs/en/sub-agents) that speed up day-to-day Flutter work: wiring APIs, matching Figma, reviewing, refactoring, testing, debugging, translations and Jira.

Each agent reads the rules of the project it runs in (`CLAUDE.md`, `.cursor/rules`), so they work in any Flutter project.

| Agent | What it does | Edits files? |
|---|---|---|
| `api-integrator` | Connects a backend endpoint end to end: DTO, Retrofit method, repository, domain model, code generation, live check | yes |
| `figma-matcher` | Compares a Figma frame with the running screen and lists pixel differences with exact fixes | no |
| `flutter-code-reviewer` | Reviews changes against project rules: localization, state, layout, 250-line files, widgets folder, accessibility… | no |
| `flutter-refactorer` | Applies review findings without changing behaviour: splits pages into widgets, `const`, keys, tokens | yes |
| `flutter-test-writer` | Writes and runs cubit, repository and widget tests | tests only |
| `flutter-bug-investigator` | Finds a bug's root cause from logs and data, reports the smallest fix | no |
| `l10n-auditor` | Missing/unused/undefined translation keys, hard-coded strings, Cyrillic script checks | no |
| `simulator-qa-tester` | Runs user flows on the iOS Simulator and checks the screen against backend data | no |
| `jira-writer` | Writes finished work to Jira in the team's existing style and moves it to Done | Jira only |

## Install

```bash
git clone https://github.com/kozimjon9824/claude-agents.git ~/claude-agents
```

Link the folder so Claude Code loads the agents in every project (move any existing `~/.claude/agents` aside first):

```bash
ln -s ~/claude-agents/agents ~/.claude/agents
```

Open a new Claude Code session — the agents load at session start.

To install for one project only, copy the files into that project's `.claude/agents/` instead.

## Update

```bash
git -C ~/claude-agents pull
```

## Use

Ask in plain words, e.g.:

- "review my changes with flutter-code-reviewer", then "apply it with flutter-refactorer"
- "compare Figma frame 5351:1710 with the screen using figma-matcher"
- "write tests for the milk period cubit with flutter-test-writer"
- "audit translations with l10n-auditor"

Claude also picks an agent on its own when a task matches its description.

## Requirements

- Claude Code
- Flutter SDK on `PATH` (or resolvable from the project's `.dart_tool/package_config.json`)
- Optional tools some agents use: an iOS Simulator (`simulator-qa-tester`, `figma-matcher`), a Figma MCP connection (`figma-matcher`), a Jira MCP connection (`jira-writer`)

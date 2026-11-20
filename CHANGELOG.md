# Changelog

## 2026-11-20
- Safety: `figma-matcher`, `simulator-qa-tester` and `jira-writer` can no longer edit files (`disallowedTools`). Live API calls and database access are dev/staging only and read-only by default; data-changing steps need explicit confirmation.
- `flutter-refactorer` hands bug and security fixes back to the main session instead of skipping them silently; `feature-pipeline` now owns those fixes, has a preflight step, guidance for the implementation step and at most two review rounds.
- `flutter-test-writer` marks tests that expose app bugs as `skip: 'APP BUG: …'`; the pipeline treats them as open, not green.
- `flutter-code-reviewer`: file-size and hygiene rules are defaults the project's `CLAUDE.md` can override.
- Uzbek trigger phrases in every agent description; neutral examples instead of internal project names.
- Added `templates/CLAUDE.md`.
- Earlier today: added `mobile-security-auditor`, `dependency-upgrader`, `release-notes-writer`, `patrol-test-writer` and the `feature-pipeline` skill; extended `api-integrator`, `flutter-test-writer`, `flutter-bug-investigator`; `jira-writer` drafts before posting.

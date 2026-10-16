---
name: jira-writer
description: Turns finished work (git commits, a session summary) into Jira tasks written in the team's existing style, linked to the right epic and moved to Done. Use when asked to "write the work to Jira" / "jiraga yozib chiq".
---

You write completed work into Jira so it reads like the tasks the team already has.

## How to work
1. **Learn the house style first.** Search the caller's recent issues (`reporter = currentUser() ORDER BY created DESC`) and read two or three of the same kind (mobile / backend / web):
   - language and title pattern (for example `Мобильное приложение: …`, `Backend …: …`),
   - issue type, priority, assignee,
   - which epic each area goes under (read the Epic Link field of existing tasks),
   - description structure (sections such as Goal / What was done / Verification / Commits).
   Follow what you find. If the area or epic is unclear, ask the caller instead of guessing.
2. **Collect the work.** Use what the caller gives; otherwise read `git log` in each repo involved (author, date range or branch the caller names) and the diffs where a commit message is not enough. Do not report work you cannot trace to a commit or to the caller's description.
3. **Split by topic, not by commit**: one task per user-visible feature or backend capability; backend and client work on the same feature are separate tasks in their own epics, each mentioning the other.
4. **Check for duplicates**: search for an existing task covering the same thing before creating one.
5. **Create** the tasks (Markdown descriptions), then **move them to Done** — read the available transitions and step through the workflow (e.g. Backlog → To Do → In Progress → Done) rather than assuming ids.

## Writing rules
- Concrete and verifiable: what changed for the user, endpoints and fields touched, how it was checked, commit hashes and branch.
- No invented results: say "verified on simulator" only if it was; leave out what was not done.
- Keep each description short — bullets, not essays.

## Report
List the created keys with titles and links, the epic each went to, and their final status. Mention anything you skipped or were unsure about.

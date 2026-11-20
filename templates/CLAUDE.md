# CLAUDE.md — <app name>

> Template for the agents in https://github.com/kozimjon9824/claude-agents.
> Copy to the root of your Flutter project, fill in every `<…>`, delete what doesn't apply.
> Agents read this file first; anything missing here they will ask about or guess.
> Don't put secrets here — this file is committed. Point to where secrets live instead.

## Project
- What the app is, in one line: <…>
- Packages / modules (monorepo?): <path → purpose>
- Base branch for features: <develop | main>; branch names: `feature/<KEY>-<slug>`, `fix/<KEY>-<slug>`
- Ticket key prefix: <ABC>

## Stack and architecture
- State: <Cubit (flutter_bloc) | Bloc | …>; states with <Freezed | Equatable>
- Errors: <fpdart Either<Failure, T> | Result type | …>
- Network: <Dio + Retrofit>; DI: <get_it manual | injectable>; routing: <go_router | auto_route | Navigator>
- Folders: `lib/features/<feature>/{data,domain,presentation}/`; widgets in `presentation/widgets/`
- Models: <e.g. `<Feature>Model extends <Feature>Entity`, json_serializable>; result wrapper: <…>
- Closest feature to copy when building a new one: <lib/features/…>

## Commands
- Code generation: `<dart run build_runner build --delete-conflicting-outputs>`
- Analyze: `<flutter analyze>` — known pre-existing warnings to ignore: <…>
- Unit/widget tests: `<flutter test --exclude-tags golden>`; goldens: `<flutter test --tags golden>` (generated on <macOS | Linux CI image>)
- E2E: `<patrol test -t integration_test/flows/... --flavor staging --dart-define-from-file=.env.test>`
- Run on simulator: `<flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=.env.dev>`

## Environments
| Name | Base URL | Agents may use it |
|---|---|---|
| local | <http://localhost:…> | yes |
| dev | <https://dev.…> | yes |
| staging | <https://staging.…> | yes, read-only unless asked |
| production | <https://…> | **never** |

- Dev auth / token: <script or command that prints a dev token, e.g. `scripts/dev_token.sh`> — never commit tokens.
- Dev database (if agents may read it): <how to connect>; read-only for agents.

## Test data
- Test accounts, PIN, OTP: in `<.env.test>` (untracked) — keys: `E2E_PHONE`, `E2E_PIN`, `E2E_OTP`
- Fixed staging OTP: <yes/no, where documented>
- Records safe to modify in QA: <…>

## Code rules (agents treat these as project rules)
- Max lines per UI file: <250>; big pages split into `presentation/widgets/`
- Design tokens only: <AppColors / AppSizes / AppTextStyles>; no hard-coded colors/sizes
- Bottom sheets vs dialogs, loaders (<shimmer>), keyboard dismissal: <…>
- File/class prefix: <none | abc_>; widget naming: <…>
- Tests required for new logic: <yes | encouraged>

## Localization
- Library: <easy_localization>; files: `<assets/translations/{uz,ru,en}.json>`; source of truth: <uz>
- Lookup style: `<'feature.key'.tr()>`; structure: <nested | flat dot-keys>

## Security notes
- Secure storage wrapper: <…>; pinning: <where configured>; sensitive screens: <…>
- What counts as sensitive data here: <tokens, card numbers, phone, passport, …>

## What agents may do without asking
- Create local branches, edit code on them, run the commands above, local commits: <yes>
- Push, open MRs, change Jira, write to any database, bump versions, edit CI/signing: **ask first**

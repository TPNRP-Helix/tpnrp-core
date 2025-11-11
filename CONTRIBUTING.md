## Contributing to TPNRP-Helix

Thank you for your interest in contributing! This document explains how to set up your environment, the conventions we follow, and how to propose changes.

### Prerequisites
- Node.js 20+ (recommended LTS)
- Yarn (repo uses `yarn.lock`)
- Git
- Optional for Lua development: Lua 5.4+ and your preferred Lua tooling (e.g., Lua Language Server)

### Repository structure (high level)
- `client/` — game client scripts (Lua) and UI app
  - `entities/`, `models/` — client-side Lua entities and models
  - `tpnrp-ui/` — React + Vite + TypeScript UI
- `server/` — server-side Lua services and entities
- `shared/` — shared Lua types, enums, config, and locales
- `TPNRP.sqlite` — local SQLite database (dev)

### Getting started (UI)
1. Install dependencies:
   - `cd client/tpnrp-ui`
   - `yarn install`
2. Run the UI in development mode:
   - `yarn dev`
3. Build:
   - `yarn build`
4. Lint:
   - `yarn lint`

The UI uses Vite + React 19 + TypeScript + Tailwind CSS and Radix UI primitives.

### Getting started (Lua)
- Client and server Lua scripts live under `client/` and `server/` respectively, with shared contracts in `shared/`.
- Keep shared types and enums in `shared/types/` and `shared/enums.lua` synchronized with actual usage.
- If you use a Lua formatter or linter locally, ensure it doesn’t introduce stylistic churn and adheres to the conventions below.

### Branching model
- Create feature branches off the active working branch (e.g., `feat/tpnrp-ui` or `main` if applicable):
  - `feat/<short-scope>` for new features
  - `fix/<short-scope>` for bug fixes
  - `chore/<short-scope>` for tooling, config, or maintenance
  - `refactor/<short-scope>` for non-functional changes
  - `docs/<short-scope>` for documentation-only changes

### Commit messages (Conventional Commits)
Use Conventional Commits. Examples:
- `feat(ui): add settings sidebar responsive layout`
- `fix(lua): prevent nil access in player inventory`
- `chore(ci): bump node version to 18`
- `docs: add contribution guidelines`

Format:
`<type>(optional scope): <short summary>`

Common types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `build`, `ci`.

### Code style and guidelines

General
- Keep changes focused and incremental.
- Prefer descriptive names for variables, functions, and files.
- Avoid deeply nested control flow; use early returns where possible.
- Add concise comments only when necessary to explain non-obvious intent, invariants, or caveats.

TypeScript (UI)
- Use TypeScript with explicit types for public component props and store types.
- Follow existing patterns in `client/tpnrp-ui/src/components/ui/*` for primitives and composition with `class-variance-authority` (`cva`).
- Keep UI state colocated; for shared game state, use Zustand stores under `src/stores/`.
- Tailwind:
  - Prefer utility classes and `tailwind-merge` to resolve conflicts.
  - Keep class lists readable; split into multiple lines when long.
- React:
  - Prefer function components.
  - Memoize expensive computations or heavy lists as needed.
  - Keep effects narrow in scope and dependency arrays accurate.
- Lint before pushing: `yarn lint` in `client/tpnrp-ui`.

Lua (client/server/shared)
- Place shared constants, enums, and types in `shared/` and reference them rather than redefining.
- Keep functions small and cohesive.
- Avoid global namespace pollution; prefer local scope when possible.
- Validate inputs on public-facing APIs (e.g., DAOs, services).
- Keep server-side data access logic in `server/services/*DAO.lua`; keep entities small and focused.

Locales and i18n
- For UI: add strings to `client/tpnrp-ui/src/locales/<lang>.json` and reference them via the existing i18n utility.
- For Lua: extend `shared/locales/` consistently and fallback to `en` when appropriate.

### Tests
- If adding non-trivial logic, include basic tests or usage demos where applicable. If a test framework is introduced later, migrate demos to proper tests.

### Pull requests
- Keep PRs focused and reasonably small.
- Include a clear description:
  - What changed and why
  - Screenshots or short clips for UI changes if possible
  - Any migration, config, or data changes
- Ensure:
  - Builds pass (`yarn build` for UI)
  - Lint passes (`yarn lint` for UI)
  - No obvious regressions in Lua runtime paths you touched

### Review guidelines
- Be constructive and specific. Suggest alternatives when requesting changes.
- Prefer aligning with existing patterns unless there’s a strong reason to change.
- When refactoring, favor mechanical changes with clear rationale.

### Release notes
- Use Conventional Commits to aid automated changelogs.
- Surface user-facing changes in PR descriptions.

### Security
- Do not commit secrets or sensitive data.
- Report vulnerabilities privately to the maintainers.

### License
By contributing, you agree that your contributions will be licensed under the project’s license.



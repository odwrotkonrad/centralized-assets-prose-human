# Spec Scenarios Convention

<!-- [>] 🤖🤖 -->

Behavior specs are markdown files, all in `cross-repo/prose/spec`, under
`repos/<repo-path>/spec/<vetting>/<unit>/`, `<repo-path>` the project's path
under the group. The prose system's own specs sit under
`repos/cross-repo/prose/assets/`, behavior every repo shares under
`repos/shared/`. Downstream repos carry no spec trees: edit the spec here, then
implement in the repo.

Nothing under `cross-repo/prose/spec` renders into a consumer repo. Specs are
read here. The conventions summary is the one file leaving this repo, and it
loads once onto the host through `ai-harness/configs` `base`
(`conventions/templates/convention.md`), never into a repo's `AGENTS.md`.

Two forms, two files:

- `<feature>.story.md`: user stories. The default.
- `<feature>.scenarios.md`: Gherkin scenarios. Only for behavior a BDD runner
  will drive.

## Picking A Form

Write a user story: who gains what, no Given/When/Then mechanics.

Write Gherkin scenarios only when a BDD runner will drive the behavior, the
trigger is deterministic (a CLI invocation, an API call) and the outcome is
observable. Everything else stays a story.

A scenarios file always accompanies a story file of the same stem. A story file
may stand alone.

## Layout

Both forms share a stem inside the unit dir:

```
spec/unvetted_ai/telemetry/
  collection.story.md
  collection.scenarios.md
  forwarding.story.md
```

`technical-requirements.md` keeps its name, no suffix.

## Shape: User Story

```markdown
# Feature: Session telemetry

## As an operator

Runs and watches agent sessions, never authors their code.

### Debug a session without entering it (todo)

I want telemetry forwarded to one endpoint,
so that I never shell into a session to diagnose it.

### Tell one session's telemetry from another's (todo)

I want each signal to name its session,
so that I can attribute load to the right agent.
```

- H1 `# Feature: <name>`.
- H2 `## As a <role>` / `## As an <role>`. Stated once, every story below
  inherits it. Several roles per file allowed, one H2 each.
- Under the H2, one line on the persona: what they do, what they do not. Never
  repeated in a story.
- H3: the story title, the audience's gain in one line, role not restated,
  status in parentheses at the end: `(todo)`.
- Body: `I want ...,` / `so that ...`, two lines, role not repeated.
- A prose paragraph under the H1 is fine where the feature needs framing.

## Shape: Gherkin Scenario

```
Scenario: <value this scenario brings to an audience, as a one-line description> (todo | implemented | tested)
  Given <precondition>
  When <trigger>
  Then <observable outcome>
  And <further outcomes>
```

The title names the audience's gain: what a user, operator or agent gets or is
protected from. Given/When/Then carry the mechanics.

## Vetting

`spec/` splits into three dirs, each holding `<unit>/` trees. The dir marks what
a human vetted, so what AI may touch:

- `spec/vetted/`: fully vetted. AI never touches.
- `spec/vetted_title_only/`: titles vetted. AI never touches H3 story titles or
  `Scenario:` lines, edits the rest freely. The trailing status is not part of
  the title: AI keeps it accurate.
- `spec/unvetted_ai/`: unvetted. AI free rein. All new AI specs land here.

Moving files, stories and scenarios between dirs is the vetting act: human will
only.

`technical-requirements.md` lives under a vetting dir too, prefer `vetted/`.
Unvetted requirements poison the spec tree. On add or change, AI urges the human
to vet before anything builds on it.

## Statuses

```
Statuses: todo | implemented | tested (implemented, tests in place).
```

- `todo`: specified, not implemented
- `implemented`: behavior exists, no test pins it
- `tested`: behavior exists and tests pin it

Every story and scenario closes its title with the status in parentheses. One
place to read it, one to change it.

On a scenario, `tested` means tests pin every Then clause. On a story, tests pin
the described behavior, in practice a `.scenarios.md` counterpart whose
scenarios are `tested`.

Keep it accurate: promote to `tested` only once a test pins the behavior,
demote when implementation or tests go away.

<!-- [<] 🤖🤖 -->

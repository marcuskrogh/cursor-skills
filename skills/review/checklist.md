# Review checklists

Paste the relevant section into each sub-agent brief. Axes investigate **vertically**
(deep within changed logic) and **horizontally** (across related modules and contracts).

Axes: **Spec**, **Correctness**, **Integration**, **Architecture**, **Standards**.

## Spec

### Vertical
- [ ] Each acceptance criterion / bug expected-result is implemented in the changed code
- [ ] Work-package / sub-task outcomes are actually delivered (not just TODOs/comments)
- [ ] Edge cases called out in PLAN/BUG are handled
- [ ] Wrong algorithm or behaviour relative to the written spec

### Horizontal
- [ ] Related surfaces updated: API, UI, docs, config, migrations, feature flags, metrics
- [ ] No scope creep beyond the issue (extra behaviour that should be a new Task)
- [ ] BUG fixes include regression protection called for in acceptance (test or equivalent)
- [ ] MODEL/PLAN numeric or domain constraints reflected at all touchpoints

## Correctness

### Vertical (intra-path)
- [ ] Logic errors, off-by-one, inverted conditions, wrong operators
- [ ] Null / undefined / empty / NaN / missing key handling
- [ ] Error paths: exceptions caught or propagated correctly; no swallowed errors that hide failure
- [ ] Resource lifecycle: files, connections, locks, subscriptions opened/closed; no leaks
- [ ] Concurrency / async: races, double-submit, stale reads, missing await, cancellation
- [ ] Idempotency and retries where the domain requires them
- [ ] Numeric stability, units, timezones, encoding, locale assumptions
- [ ] Validation of untrusted or external input before use

### Horizontal (tests & contracts)
- [ ] New behaviour has tests; failure paths tested, not only happy path
- [ ] Existing tests updated when contracts change
- [ ] Tooling failures (lint/type/test) from the manager run are explained or fixed as findings
- [ ] Fixtures/factories match new schema or API shapes

## Integration

### Horizontal (cross-module) — primary
- [ ] Callers and callees of changed symbols still type/behave correctly
- [ ] Public API / schema / protobuf / OpenAPI / event payload compatibility
- [ ] Authn/authz: every sensitive path checks permission server-side
- [ ] Horizontal privilege: user A cannot access user B's resources by swapping IDs
- [ ] Vertical privilege: lower roles cannot reach admin/privileged operations
- [ ] Shared mutable state, caches, and singletons remain coherent
- [ ] Config / env / secrets: no new required knobs undocumented; no secrets in code/logs
- [ ] DB migrations / backward compatibility / rollout order
- [ ] Feature flags default-safe; removal paths considered
- [ ] Observability: important failures still log/metric/trace usefully

### Vertical (at each boundary)
- [ ] Assumptions at module boundaries documented by types or checks
- [ ] Error mapping across layers (domain → HTTP/RPC) preserves meaning
- [ ] Partial failure in multi-step flows does not corrupt state

## Architecture

Deep structural analysis of the change in context of the surrounding codebase.
Findings must cite evidence (paths, layers, dependency edges) and propose a
**concrete refactoring** — not vague "consider cleaning this up."

Documented ADRs / architecture docs / dependency rules override generic advice.

**vs Integration:** runtime contracts and auth fit → Integration; structural fit and
refactorings → Architecture. **vs Standards:** local smells/naming → Standards;
module/layer/design-shape problems → Architecture.

### Vertical (intra-module structure)
- [ ] New/changed logic lives in the right layer or package (not UI→DB shortcuts, not domain depending on HTTP/framework types)
- [ ] Module cohesion: changed unit has one clear responsibility; change does not turn it into a god object/service/file
- [ ] Abstraction quality: interfaces/ports hide the right details; no leaky abstractions exposing persistence/transport internals
- [ ] Complexity growth: long methods/types/files made worse without an extract/split plan
- [ ] Speculative frameworks or premature generalization introduced without a second real use
- [ ] Composition vs inheritance / indirection: new layers earn their keep

### Horizontal (system structure) — primary for this axis
- [ ] Dependency direction respects the repo's intended architecture (domain ← application ← adapters, package rules, …)
- [ ] No new or worsened import/package cycles across modules
- [ ] Boundaries: feature/package seams remain clear; change does not smear one concern across many packages (shotgun surgery)
- [ ] Divergent change: one module is not accumulating unrelated reasons to change
- [ ] Duplication vs false sharing: extract a shared module only when concepts truly align; otherwise keep separate
- [ ] Consistency with existing patterns (how similar features are structured in this repo)
- [ ] ADR / architecture-doc compliance for touched areas
- [ ] Data ownership and module APIs: who owns the model; are cross-module calls going through the right façade?
- [ ] Extension points: change hard-codes a one-off where the codebase already has a plugin/strategy/registry pattern (or vice versa)
- [ ] Testability structure: hard-wired collaborators that block isolating the unit without a redesign

### Refactoring outcomes (use in finding bodies)
When flagging, name a concrete move, for example:
- Extract module / package / type for a cohesive responsibility
- Move type or function to the correct layer
- Invert dependency (introduce port + adapter; depend on abstraction)
- Split god module along change-axes
- Collapse needless indirection / speculative generality
- Introduce a façade to hide a message chain or unstable neighbor
- Align with an existing pattern already used for a sibling feature

Severity: improvement opportunity → `note`; clear architectural regression in this PR → `should-fix`; hard documented constraint breach → `blocker`.

## Standards (smell baseline)

Repo docs override. Smells are usually `note` (or `should-fix` if severe). Skip tooling-enforced style.

### Smell baseline (_Refactoring_, Fowler ch.3)

- **Mysterious Name** — name doesn't reveal role → rename or rethink design
- **Duplicated Code** — same logic shape in multiple hunks → extract
- **Feature Envy** — method uses another's data more than its own → move it
- **Data Clumps** — same fields travel together → introduce a type
- **Primitive Obsession** — primitive stands in for a domain concept → small type
- **Repeated Switches** — same type cascade repeated → polymorphism or shared map
- **Shotgun Surgery** — one change edits many scattered sites → gather
- **Divergent Change** — one module changed for unrelated reasons → split
- **Speculative Generality** — abstraction for unneeded future → delete/inline
- **Message Chains** — long `a.b().c().d()` → hide behind one method
- **Middle Man** — mostly delegates → remove and call target
- **Refused Bequest** — ignores most inherited behaviour → prefer composition

### Vertical / horizontal for standards
- Vertical: naming, structure, and clarity inside new functions
- Horizontal: consistency with neighbouring modules and established patterns in the repo

When a smell is really a module/layer/dependency problem, prefer an **Architecture**
finding with a structural refactoring over a Standards note.

# Review checklists

Paste the relevant section into each sub-agent brief. Axes investigate **vertically**
(deep within changed logic) and **horizontally** (across related modules and contracts).

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

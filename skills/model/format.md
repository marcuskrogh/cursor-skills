# LaTeX question format

Agent-only. **Do not present this file to the user during alignment.**

Applies the alignment [format override](../alignment/SKILL.md#format-overrides) for mathematical topics. Read with [reference.md](reference.md) for notation.

## Mandatory shape

Each alignment message contains **exactly one** display-math block and **nothing else** (unless the user explicitly asked otherwise).

$$
\begin{aligned}
\textbf{Q$n$:} \quad & \text{Short prose line.} \\
\frac{dx}{dt} &= f(x,u) \\
\text{Closing question?} &
\end{aligned}
$$

### Structure

1. Entire question — label, words, symbols, equations — inside a single `$$ ... $$` block.
2. Wrap body in `\begin{aligned} ... \end{aligned}`; use `\\` between lines.
3. Label on first line: `\textbf{Q1:} \quad & \text{...}`.
4. **Every equation on its own line** — never inline with prose.
5. Prose in short `\text{...}` chunks; avoid one long horizontal line.
6. **No markdown** outside the block. No backticks or code fences.

### Relation alignment

- Primary relations: `lhs &= rhs` — ampersand **before** the relation.
- Distribution clauses: `lhs &= rhs, & \eta &\sim \mathcal{D}(\cdot)` — align `\sim` and noise symbols in columns.
- Index clauses: `t_a &\le t_k \le t_b, & k &\in \{0,\ldots,N\}`.

### Layout

- 3–4 logical lines typical; `\\` between logical lines only.
- Each displayed relation on one line (full SDE on one line when possible).

### Definition hierarchy

When embedding a model, optimiser, or estimator:

1. **Level 0 — shell:** top-level structure with abstract slots ($f$, $\sigma$, $h$, $l$, …) — do not expand yet.
2. **Level 1 — symbols:** $x$, $u$, dimensions, index sets.
3. **Level 2+ — expand one block at a time** under italic section headers (`\textit{Drift } f(x,u)`), with sub-definitions before use.
4. Separate levels with `\\[6pt]`.
5. **One closing question** per message — not a survey.

**Anti-patterns:** flattening hierarchy; `& lhs = rhs` instead of `lhs &= rhs`; markdown or inline `$...$` outside the block.

### Closing artifact and readiness

Alignment summary: one or more aligned `$$ ... $$` blocks using the definition hierarchy.

Readiness question:

$$
\begin{aligned}
\textbf{Q$n$:} \quad & \text{Ready to finalise the model specification?}
\end{aligned}
$$

## Example questions

$$
\begin{aligned}
\textbf{Q1:} \quad & \text{ODE, SDE, DAE, or SDAE?} \\
& \text{Linear or nonlinear } f\text{?}
\end{aligned}
$$

$$
\begin{aligned}
\textbf{Q7:} \quad & \text{Linear-Gaussian state estimation:} \\
x_{k+1} &= A x_k + B u_k + w_k, & w_k &\sim \mathcal{N}(0,Q) \\
y_k^{m} &= C x_k + v_k, & v_k &\sim \mathcal{N}(0,R) \\
& \text{Kalman filter, EKF, UKF, or particle filter?}
\end{aligned}
$$

See the former `maths-grill-and-develop` skill history for extended hierarchical examples (CSTR SDE, MPC OCP).

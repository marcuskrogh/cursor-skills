# Default Notation Reference

Agent-only reference for phrasing alignment questions. **Do not present this file or its contents to the user during alignment.**

When writing questions to the user: one `$$ ... $$` block with `aligned`; align primary relations with `&=`; align distribution and iterator side clauses; for models/OCP/estimators use **top-down hierarchy** (abstract shell first, then symbols, then expand $f$, $\sigma$, $l$, etc. with sub-definitions before use).

Deviations from this baseline should be clarified via targeted questions.

## General

- Scalars: lowercase or Greek letters (e.g. $a$, $\alpha$)
- Vectors: lowercase (e.g. $x$, $u$)
- Matrices: uppercase (e.g. $A$, $Q$) — not bold, not italic
- Transpose: $A^{T}$
- Inverse: $A^{-1}$
- 2-norm (weighted): $\|x\|_{Q} = x^{T} Q x$
- 1-norm: $|x|$
- Inner product: $x^{T} y$
- Outer product: $x y^{T}$

## Calculus & Differential Equations

- Ordinary derivative: $\frac{dx}{dt}$
- Partial derivative: $\frac{\partial f}{\partial x}$
- Gradient: $\nabla f$
- Divergence: $\nabla \cdot$
- Curl: $\nabla \times$
- Integral: $\int_{a}^{b} f(x) \, dx$
- Continuous-time variables: $x(t)$, $u(t)$, $d(t)$
- Discrete-time variables: $x_{k}$, $u_{k}$, $d_{k}$
- Parameters: $p$

## ODE Models

**Continuous-time:**

$$\frac{dx(t)}{dt} = f(x(t), u(t), d(t), p)$$

$$z(t) = h(x(t), u(t), d(t), p)$$

$$y^{m}(t_{k}) = g^{m}(x(t_{k}), u(t_{k}), d(t_{k}), p)$$

**Discrete-time:**

$$x_{k+1} = f(x_{k}, u_{k}, d_{k}, p)$$

$$z_{k} = h(x_{k}, u_{k}, d_{k}, p)$$

$$y^{m}_{k} = g^{m}(x_{k}, u_{k}, d_{k}, p)$$

## SDE Models (Itô)

**Continuous-time:**

$$dx(t) = f(x(t), u(t), d(t), p) \, dt + \sigma(x(t), u(t), d(t), p) \, dw(t), \quad dw(t) \sim \mathcal{N}(0, dt \, I)$$

$$z(t) = h(x(t), u(t), d(t), p)$$

$$y^{m}(t_{k}) = g^{m}(x(t_{k}), u(t_{k}), d(t_{k}), p) + v(t_{k}), \quad v(t_{k}) \sim \mathcal{N}(0, R)$$

**Discrete-time:**

$$x_{k+1} = f(x_{k}, u_{k}, d_{k}, p) + \sigma(x_{k}, u_{k}, d_{k}, p) \, w_{k}, \quad w_{k} \sim \mathcal{N}(0, Q)$$

$$z_{k} = h(x_{k}, u_{k}, d_{k}, p)$$

$$y^{m}_{k} = g^{m}(x_{k}, u_{k}, d_{k}, p) + v_{k}, \quad v_{k} \sim \mathcal{N}(0, R)$$

## DAE Models

**Continuous-time (ODE + algebraic constraint):**

$$\frac{dx(t)}{dt} = f(x(t), y(t), u(t), d(t), p)$$

$$0 = g(x(t), y(t), u(t), d(t), p)$$

$$z(t) = h(x(t), y(t), u(t), d(t), p)$$

$$y^{m}(t_{k}) = g^{m}(x(t_{k}), y(t_{k}), u(t_{k}), d(t_{k}), p) + v(t_{k}), \quad v(t_{k}) \sim \mathcal{N}(0, R)$$

Where $y(t)$ denotes algebraic variables.

## SDAE Models (Itô)

**Continuous-time:**

$$dx(t) = f(x(t), y(t), u(t), d(t), p) \, dt + \sigma(x(t), y(t), u(t), d(t), p) \, dw(t), \quad dw(t) \sim \mathcal{N}(0, dt \, I)$$

$$0 = g(x(t), y(t), u(t), d(t), p)$$

$$z(t) = h(x(t), y(t), u(t), d(t), p)$$

$$y^{m}(t_{k}) = g^{m}(x(t_{k}), y(t_{k}), u(t_{k}), d(t_{k}), p) + v(t_{k}), \quad v(t_{k}) \sim \mathcal{N}(0, R)$$

## Linear Systems

**Continuous-time ODE:**

$$\frac{dx(t)}{dt} = A_{c} x(t) + B_{c} u(t) + E_{c} d(t)$$

**Continuous-time SDE:**

$$dx(t) = (A_{c} x(t) + B_{c} u(t) + E_{c} d(t)) \, dt + G_{c} \, dw(t), \quad dw(t) \sim \mathcal{N}(0, dt \, I)$$

**Discrete-time ODE:**

$$x_{k+1} = A x_{k} + B u_{k} + E d_{k}$$

**Discrete-time SDE:**

$$x_{k+1} = A x_{k} + B u_{k} + E d_{k} + G w_{k}, \quad w_{k} \sim \mathcal{N}(0, Q)$$

**Output (controlled):**

$$z(t) = C_{z} x(t) + D_{z} u(t)$$

**Measurement:**

$$y^{m}(t_{k}) = C x(t_{k}) + D u(t_{k}) + F d(t_{k}) + v(t_{k}), \quad v(t_{k}) \sim \mathcal{N}(0, R)$$

When using both continuous and discrete-time, continuous-time matrices carry subscript $c$ (e.g. $A_{c}$), discrete-time are unsubscripted (e.g. $A$).

## State Estimation

- True state: $x$
- State estimate: $\hat{x}$
- One-step prediction: $\hat{x}_{k+1|k}$
- Filtered estimate: $\hat{x}_{k|k}$
- Covariance (filtered): $P_{k|k}$
- Covariance (predicted): $P_{k+1|k}$
- Kalman gain: $K_{k}$
- Process noise: $w(t)$ (CT), $w_{k}$ (DT)
- Measurement noise: $v(t_{k})$ (CT), $v_{k}$ (DT)

Same conditional notation applies to outputs, measurements, and other estimated quantities (e.g. $z_{k|k}$, $y^{m}_{k|k-1}$).

## Optimization (Nocedal & Wright conventions)

- Objective: $\varphi = f(x)$
- Optimal value: $x^{*}$
- Constraints (combined): $c_{l} \leq c(\cdot) \leq c_{u}$
- Constraints (separate): $c_{l} \leq c_{\text{ineq}}(\cdot) \leq c_{u}$, $c_{\text{eq}}(\cdot) = 0$
- Lagrangian: $L(x, \lambda)$
- Equality multipliers: $\lambda$
- Inequality multipliers: $\mu$

## Optimal Control (Bolza Form)

- Lagrange term: $l(\cdot)$
- Mayer term: $\hat{l}(\cdot)$

## Model Predictive Control (MPC)

- Prediction horizon: $N_{z}$
- Control horizon: $N_{u}$
- When equal: $N = N_{z} = N_{u}$
- Quadratic weights: $Q_{z}$ (tracking), $Q_{s}$ (slack), $Q_{\Delta u}$ (input rate-of-move)
- Linear weights (vectors): $q_{u}$, $q_{\text{eco}}$, etc.
  - e.g. $q_{u}^{T} u_{k}$ for price-scaled input cost

## Discretization & Numerical Methods

- Simulation time step: $\Delta t$
- Control sample time: $T_{s}$
- Discrete time grid: $k \in \{0, 1, \ldots, N\}$
- ODE/DAE: explicit or implicit Euler with substepping
- SDE/SDAE: explicit or implicit-explicit Euler-Maruyama with substepping

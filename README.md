# Spring-Mass-Damper System Identification

A MATLAB implementation of a classical system identification pipeline for estimating the damping and stiffness parameters of a spring-mass-damper (SMD) system from noisy, sparsely sampled measurement data. Like the aircraft sysID implementation, this serves as a **baseline reference** — results are intended as a basis of comparison for other system identification methods.

The workflow uses two sequential stages: a **Least-Squares Regression** (equation-error) method for initial parameter estimates, followed by an **Output-Error** method for refinement.

---

## System

The system being identified is a 1D spring-mass-damper:

```
m*x_ddot + c*x_dot + k*x = F(t)
```

Rearranged for regression, the parameters identified are:

```
theta = [-c/m, -k/m, 1/m]
```

with true values `m = 2`, `c = 0.3`, `k = 0.2` and a sinusoidal forcing input `F(t) = sin(2*pi*t)`.

---

## Files

| File | Description |
|---|---|
| `massdamper_full.mat` | Measured data file (sparse, noisy position measurements) |
| `AYUSH_statespace_smd.m` | Supporting file defining the SMD state-space model |
| `oe.m` | SIDPAC output-error optimizer (Morelli, NASA Langley) |

---

## Pipeline

```
Sparse, Noisy Measurements
    │
    ▼
Savitzky-Golay smoothing (sgolayfilt)
    │
    ▼
Spline interpolation  —  resampled to uniform 10 Hz grid
    │
    ▼
Numerical differentiation (deriv)  —  xdot, x_ddot
    │
    ▼
Least-Squares Regression  —  lesq (unconstrained)
    │                        regressor: [xdot, x, u]
    ▼  initial parameter estimates
Output-Error Method  —  oe.m (SIDPAC)
    │                   Modified Newton-Raphson + Simplex fallback
    │                   Full simulation at each iteration
    ▼
Final Parameter Estimates
```

---

## Data & Preprocessing Notes

The input data is sparsely sampled (`sparcityLevel150`) with added random noise. Several preprocessing steps are applied before regression:

- **Smoothing**: Savitzky-Golay filter (`sgolayfilt`, order 2, window 21) applied to raw position measurements
- **Interpolation**: Smoothed data is resampled to a uniform `0.1 s` grid via spline interpolation before being passed to `oe.m`
- **Differentiation**: Velocity and acceleration are computed from the interpolated signal using `deriv`

The choice of interpolation method and resampling frequency have a measurable impact on parameter estimation accuracy.

---

## Dependencies

- MATLAB
- [SIDPAC](https://software.nasa.gov/) toolbox (`oe.m` and supporting routines: `mnr.m`, `simplex.m`, `estrr.m`, `misvd.m`, `cvec.m`, `compcost.m`, `lesq.m`)
- `deriv.m` — smoothed numerical differentiation
- the other files were for data extraction and parsing of Prof. Brunswicker's spring mass damper data

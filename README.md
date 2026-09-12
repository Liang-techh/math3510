# MATH 3510 — MATLAB Problems 1 and 2

Solutions to the two problems in the supplied assignment image. Each required
function is in its own `.m` file at the repository root.

| File | Purpose |
| --- | --- |
| `samplevar.m` | Problem 1: sample variance calculated directly from the formula. |
| `polyadd.m` | Problem 2: add descending-power coefficient vectors of unequal lengths. |
| `test_assignment.m` | Examples, comparisons with `var`, and automated checks. |
| `.github/workflows/matlab.yml` | Run the checks in MATLAB on GitHub Actions. |

## Run in MATLAB

Download or clone this repository, open MATLAB, and set **Current Folder** to
this repository's folder. In the Command Window, run:

```matlab
test_assignment
```

The test runner prints the variance comparisons and polynomial examples. A
successful run ends with:

```text
All tests passed: 543 checks.
```

This is the expected success message, not a claim that a particular workflow
run has completed. Actual MATLAB execution results are in the repository's
**Actions** tab. No additional MATLAB toolbox is required by the code.

The same tests can also be invoked in GNU Octave:

```sh
octave --no-gui --quiet --eval "test_assignment"
```

## Problem 1 — `samplevar(x)`

For a real vector with `n >= 2` observations, compute the mean first, then the
sum of squared deviations:

```matlab
xbar = sum(x) / n;
s2 = sum((x - xbar).^2) / (n - 1);
```

`.^2` squares each element separately. The denominator is `n - 1`, not `n`.
The implementation does **not** call `var`. Row and column vectors are both
accepted; numeric inputs are converted to double precision before arithmetic.

Example:

```matlab
x = [1 2 3 4 5];
samplevar(x)        % 2.5
var(x)              % 2.5
samplevar(x.')       % 2.5
```

The automated tests compare the implementation with `var` on fixed examples
and 100 reproducibly generated random vectors, including column inputs.

**Boundary convention:** the assignment formula requires at least two
observations. `samplevar([])` and `samplevar(5)` return `NaN` to mark an
undefined sample variance. The test runner prints `var(5)` separately so its
singleton convention is not silently confused with the stated formula. NaN
and infinite observations propagate through the formula; complex and
non-vector inputs are rejected.

## Problem 2 — `polyadd(p, q)`

Coefficients are stored in descending-power order. To add vectors of unequal
lengths, pad the shorter vector with zeros on the **left**, then add
corresponding coefficients.

Example:

```matlab
p = [2 3 4];         % 2*x^2 + 3*x + 4
q = [5 6];           %         5*x + 6
r = polyadd(p, q)    % [2 8 10]
```

Here `q` is aligned as `[0 5 6]`; adding `[5 6 0]` would change the polynomial.
The implementation accepts row or column vectors and always returns a row
vector of length `max(numel(p), numel(q))`. Leading zeros are retained, even
when all coefficients cancel. Use `0` to represent the zero polynomial;
empty coefficient vectors and matrices are rejected.

The tests cover both orders of unequal lengths, equal lengths, constants,
column vectors, leading zeros, complete cancellation, integer inputs, and
complex coefficients. They also check the identity
`polyval(polyadd(p,q),t) = polyval(p,t) + polyval(q,t)` for 100 random pairs.

## Documentation

- MathWorks: [Create and Evaluate Polynomials](https://www.mathworks.com/help/matlab/math/create-and-evaluate-polynomials.html).
- MathWorks: [Set up MATLAB in GitHub Actions](https://github.com/matlab-actions/setup-matlab).
- MathWorks: [Run MATLAB commands in GitHub Actions](https://github.com/matlab-actions/run-command).

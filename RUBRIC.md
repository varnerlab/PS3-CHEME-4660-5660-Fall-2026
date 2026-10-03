# PS3 grading rules

Your selected track is graded out of **4**. An accepted Advanced score of 4
also earns **one Magic Point**, once for PS3. Select your track in `TRACK.txt`.

| Score | Public checks passed | Other requirements |
|:--:|:--|:--|
| 0 | None, or the selected source file cannot load | — |
| 1 | At least one, but no more than half | — |
| 2 | More than half, but fewer than all | Unless the minor-error review supports a 3 |
| 3 | All | At least one completion requirement below is not met |
| 3 | More than half, but fewer than all | The minor-error criteria below are met after teaching-team review |
| 4 | All | All completion requirements below are met |

Checks run separately, using supplied inputs where possible so an
unfinished early function does not block every later check. Failed checks
or a loading error do not cause a Frozen Zero: a readable ZIP containing
attempted work submitted by the deadline still qualifies for revisions.
Standard has **20 checks**, with five for each function. Advanced has
**32 checks**: the same 20 plus six for model construction and six for
probability calculation. Completing only the shared Advanced work earns
at most 2. We grade the selected track.

Standard cutoffs are 1–10 checks for score 1 and 11–19 for score 2.
Advanced cutoffs are 1–16 for score 1 and 17–31 for score 2. Passing all
20 or 32 checks gives 3 or 4 after completion review. The minor-error
review below can raise a score of 2 to 3.

## A 3 for a minor coding error

When more than half the checks pass, the teaching team may award **3** for
otherwise complete work with a minor, localized coding error. Every required
function must be attempted, the failures must trace to one small implementation
mistake, and the code and answers must show understanding of the methods.
All response parts and documentation requirements must be complete.

For example, charging one extra day of fees may qualify when the written
explanation correctly describes the interval convention. Missing functions,
hard-coded answers, omitting the required Advanced model, or confusing
fixed weights with fixed share counts do not qualify. A 4 still requires
every check to pass and all completion requirements to be met.

## Requirements for a 4

- **Estimation:** Compare the full 2014–2025 window with 2025 alone. Select
  price rows before calculating growth rates; use no 2026 data in estimation.
  Preserve ticker order and use the stated time units and sample covariance convention.
- **Optimization:** Construct both minimum-variance allocations with the
  specified constraints. Include no borrowing fee or growth target in the
  objective or constraints. Do not alter weights using 2026 results.
- **Evaluation:** Hold signed share counts fixed. Calculate wealth and
  beginning-of-interval borrowing fees correctly over 126 trading days
  at 0% and 3%. Apply the benchmark to net terminal wealth and use strict inequality for success.
- **Advanced:** Construct MA-GBM with correctly scaled covariance and price
  drifts. Calculate success probabilities from joint asset-price paths,
  keeping all outcomes in the denominator and reusing price paths within each
  fitted model and standard normal draws across models.
- **Documentation:** Keep the supplied docstrings. Document each helper's
  purpose, inputs, and output, and comment non-obvious steps. Load helper
  files under `src` through `Include.jl`.
- **Written work:** Answer all three questions in the selected response
  file with the requested numbers, units, and reasoning. Include an
  estimation-window prediction and its reconsideration. Interpret supplied tables rather than
  reproducing them. Distinguish estimated risk, realized
  risk, terminal wealth, and, for Advanced, modeled success probability.
- **Finished work:** Remove completed TODOs and starter errors from the
  selected track's source and response files. Leave the other track unchanged.

We do not require the optimized portfolios to outperform the equal-weight
portfolio, the shorts to reduce realized risk, or the forecast's more likely
outcome to occur. We assess the calculations and your interpretation.

## How we check submissions

As in PS2, grading will copy the selected source and response files, custom
helpers under `src`, `Include.jl`, and `TRACK.txt` into a clean student
release. Edits to supplied data, tests, reports, support code, or the checker
will not be used. Helpers must not replace those components.

The checker gives feedback; the teaching team assigns the grade. Passing
every test means the work is pending completion review. The teaching team
may assign 3 or 4 after reading the documentation and answers.

## Initial submission and revisions

PS3 is released **October 4, 2026**. Submit a readable ZIP with attempted
work by **October 18, 2026 at 11:59 PM ET**. A missing, empty, or unreadable
submission receives a **Frozen Zero** and cannot be revised for credit or
earn a Magic Point. Incomplete attempted work and failed checks qualify
for revisions.

After a qualifying initial submission, revisions are allowed until
**December 19, 2026 at 11:59 PM ET**, with no limit on attempts. Use
**New Attempt** on the same Canvas assignment. Eligible revisions have no
late penalty. We keep your highest score, even if you change tracks. An
accepted Advanced score of 4 earned through revision also earns the
one-time Magic Point.

## Independent work

You may discuss ideas and use course materials, books, documentation, the
internet, and AI tools. Submit your own work. Do not share code or solutions.

The reference solution will be released after the initial deadline. Use it
to understand errors and debug your work, but do not copy it. Copying it
results in a locked score of 0 for PS3. These rules also apply to revisions.

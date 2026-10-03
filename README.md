# Problem Set 3 (PS3): Does More Recent Data Lead to a Better Portfolio?

Suppose you have USD 10,000 to invest in a portfolio of stocks. You are unsure how to estimate its risk and expected return.
You could use twelve years of price data or just the most recent year. A longer history contains more observations, but a shorter history emphasizes recent market conditions. You must also decide whether to allow short positions or hold only long positions. Short positions can reduce portfolio risk, but they incur borrowing costs.

These choices lead to the following question: **Does using more recent data lead to a better portfolio, and does allowing short positions help or hurt portfolio performance?**

We will investigate this question using two estimation windows: **2014–2025**
and **2025 alone**. For each window, choose minimum-variance portfolios with
and without short positions. Then hold all four portfolios over the same
126 trading days in 2026. Compare their risk before borrowing fees and
wealth after fees. The Advanced track also estimates the probability of
beating a benchmark using a model fitted to each window.

## Dates and grading

- **Release:** Sunday, October 4, 2026.
- **Due:** Sunday, October 18, 2026 at 11:59 PM ET. Upload your ZIP to Canvas.
- **Revisions:** Until December 19, 2026 at 11:59 PM ET after a qualifying
  initial submission. We keep your highest score, even if you change tracks.
- **Score:** Out of 4. An Advanced score of 4, confirmed by the teaching
  team, also earns one Magic Point.

Submit a readable ZIP with attempted work by the initial deadline, even if
checks fail. A missing, empty, or unreadable submission receives a **Frozen
Zero** and cannot be revised for credit or earn a Magic Point. See the
[grading rubric](RUBRIC.md) for the full rules.

## Choose your track

Both tracks investigate the same question. Complete only your selected
track's source file and three written responses.

| Track | Work to complete | Written responses |
|:--|:--|:--|
| **Standard** | Four functions reused for both estimation windows. Compare allocations and observed performance after fees. | [Standard questions](responses/Standard.md) |
| **Advanced** | The same four functions plus two functions for multiple-asset geometric Brownian motion (MA-GBM) and success probabilities. | [Advanced questions](responses/Advanced.md) |

Use the covariance and multiple-asset GBM material from the [L5b slides](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/d38e8d35ae35b941168992b7cc13d101bef90c7c/lectures/week-5/L5b/slides/CHEME-5660-L5b-Slides-Fall-2026.pdf) and the
minimum-variance portfolios from [L6a slides](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/d38e8d35ae35b941168992b7cc13d101bef90c7c/lectures/week-6/L6a/slides/CHEME-5660-L6a-Slides-Fall-2026.pdf). The
[mathematical companion](docs/PS3-Mathematical-Companion.pdf) presents the
formulas as lecture slides and introduces borrowing fees.
The supplied report generates comparison tables. Cite the numbers needed for your
answers. **You do not need to reproduce the tables**. The single-index model
(SIM) and rebalancing are outside this assignment.

## Set up the comparison

Use the same eight stocks in this order: Apple (AAPL), Microsoft (MSFT),
NVIDIA (NVDA), Advanced Micro Devices (AMD), Goldman Sachs (GS), Bank of
America (BAC), Ford (F), and Johnson & Johnson (JNJ).

| Input | Use |
|:--|:--|
| [2014–2025 prices](data/portfolio-2014-2025.csv), all rows | Estimate the long-history inputs from 3,017 prices and 3,016 daily changes. |
| The same file, 2025 rows only | Estimate the recent-history inputs from 250 prices and 249 daily changes. |
| [2026 prices](data/portfolio-2026.csv) | Evaluate every allocation over the same 126 trading days. |

The supplied loader selects each window
**before your estimation function calculates growth rates**. Your function
will work with either price matrix. Selecting only the 2025 prices excludes
the change from December 31, 2024 to January 2, 2025. The long window includes
that change. Reserve all 2026 prices for evaluation.

Every portfolio begins with **USD 10,000 at the December 31, 2025 prices**.
This is day 0. The first 2026 observation is day 1. Close all positions at
observation 126 on July 6, 2026. Use 252 trading days per year. The [data notes](data/README.md)
describe the aligned volume-weighted prices in USD/share.

Allow fractional shares and use short-sale proceeds to finance long
positions. Ignore dividends, taxes, commissions, bid-ask spreads, collateral
requirements, and forced liquidation. Include the borrowing fee defined
in Study 2.

## Study 1: What allocations does each history suggest?

Before reading the allocation results, record the short prediction requested
in Question 1. Then estimate the mean growth rates and covariance matrix
from each window and choose two portfolios:

- **Long-only minimum variance:** Find the allocation with the smallest
  estimated variance when every weight must be nonnegative.
- **Shorts-allowed minimum variance:** Minimize the same variance when
  weights may be negative. A negative weight means borrowing and selling
  shares that must later be bought back.

The weights must sum to one. The optimization has no growth target and
excludes borrowing costs. Use the course solver for the long-only problem.
For the shorts-allowed problem, evaluate the L6a closed-form solution
with a linear solve.

This gives **four optimized portfolios**. The report also supplies one
equal-weight reference, with one eighth of initial wealth in each stock.
Its holdings do not depend on the estimation window.

Compare the selected stocks, short exposure, and estimated risk. The report
shows individual-stock risk and each shorted stock's correlation with
the combined long holdings. High volatility alone does not make
a stock a useful hedge. Its relationship with the other holdings
also matters.

These minimum-variance allocations depend on the **covariance matrix**.
The estimated means are needed for the Advanced price model. They do not
affect the allocations because there is no growth target. Each window
estimates risk using its own covariance matrix. Study 2 compares the
allocations on the same new prices to see whether lower estimated risk
leads to lower realized risk.

## Study 2: Which estimates hold up in 2026?

Convert each allocation into signed share counts at the day-0 prices.
**Hold those share counts fixed** through day 126. The weights will change
as prices change. Use the same 2026 prices to calculate wealth and realized
risk for all four allocations and the equal-weight reference.

Risk is the standard deviation of growth rates calculated from daily prices
and expressed per year. Estimated risk uses the window's covariance and
initial weights. Realized risk uses the observed buy-and-hold wealth path.
All risk comparisons use wealth **before borrowing fees**.

First evaluate the holdings with **zero borrowing fees**. Then charge
**3% per trading year** on the value of the shares owed at the beginning
of each interval. Use the annual rate divided by 252 as the daily rate.
A 126-day investment has 126 charges, using prices from day 0 through day
125. Fees accrue without interest and are paid at liquidation. Share counts
stay fixed. The 3% rate is an illustrative assumption, not a market quote.
Portfolios without shorts owe no borrowing fees.

Compare **gross wealth** before fees with **net wealth** after fees.
The report also shows gains or losses on the short positions. A short's
profitability and its contribution to portfolio risk are different questions.
The optimized portfolios also differ in their long holdings.

Finally, compare net wealth with a benchmark that starts at USD 10,000 and
grows at **5% per trading year, compounded continuously**. Success means
finishing strictly above it. As in PS2, a positive scaled net present value
(NPV) means the discounted net proceeds exceed the initial investment.

## Study 3: What can we conclude?

Use the 2026 results to compare the two estimation windows. Which
history produced lower realized risk, and which produced greater net wealth?
Did shorts lower risk or increase net wealth? How much did borrowing
costs contribute?

Revisit your prediction using selected numbers from the report. Explain
one advantage and one limitation of using only the most recent year.
Changing the window changes both the number of observations and their
recency. This one market history cannot establish that either window will
always give the better portfolio.

The Standard track ends here. The Advanced track adds the model
probabilities below to its third written response.

## Advanced: How likely was success under each model?

Fit one MA-GBM model to each estimation window. For each model, evaluate the
two allocations chosen from that window and the equal-weight reference.
Estimate their probabilities of beating the benchmark after 126 days at
borrowing rates of 0% and 3%.

The supplied helper generates **20,000 joint stock-price paths per
model**. Within a model, reuse the same paths across portfolios and fee
rates. Across models, reuse the same standard normal draws. Transform
them using each model's fitted parameters to obtain different price paths.

Reuse your holdings and fee functions on each path. Count successes and
divide by the total number of paths. Calculate portfolio wealth from the
joint asset prices. A portfolio with short positions cannot generally be
treated as one lognormal asset. Path generation and reporting are supplied.

Compare each model's probabilities with the observed outcomes. A change in
an optimized portfolio's forecast across windows reflects changes in both
its holdings and the fitted price model. Equal-weight holdings stay the
same, although their modeled probabilities can change.

The report shows Monte Carlo standard errors. These measure simulation
precision conditional on the fitted model, not forecast accuracy. The four
allocations are evaluated on the same market episode, not four independent
repetitions.

## Code and submission

The student release uses Julia **1.12.7** and the PS2 workflow:

| Task | Functions to complete |
|:--|:--|
| Estimate inputs and choose allocations | `estimate_inputs`, `minimum_variance_weights` |
| Calculate wealth and borrowing costs | `portfolio_path`, `borrowing_costs` |
| Advanced: Construct the model and count successes | `build_magbm`, `benchmark_probability` |

The same functions serve both windows. Supplied docstrings specify
arguments and return values. The report selects the windows, calls your
functions, and produces the comparison tables. Complete
[src/Standard.jl](src/Standard.jl) or [src/Advanced.jl](src/Advanced.jl).

1. Download `PS3-CHEME-4660-5660-Fall-2026-student.zip` from the assignment
   materials and extract it. Open a terminal in the extracted folder. Use
   Julia 1.12.7 and install the recorded environment with
   `julia --project=. --startup-file=no -e 'using Pkg; Pkg.instantiate()'`.
   Keep [Project.toml](Project.toml) and [Manifest.toml](Manifest.toml) together.
2. Set `TRACK.txt` to `standard` or `advanced`. Complete the selected source
   file and its three responses. The Advanced file includes all six functions.
3. Keep supplied docstrings and document any helpers you write. Put helper
   files under `src` and load them through `Include.jl`. Leave data, support code, reports,
   and tests unchanged.
4. Run `julia --project=. --startup-file=no check_submission.jl`. The checker
   runs 20 Standard or 32 Advanced public checks, prints the report, exports
   results, and writes `MANIFEST.txt`. Unfinished calculations appear as
   `UNAVAILABLE`. The first run may take longer while Julia compiles packages.
5. ZIP the student folder as `CHEME-5660-PS3-<your netid>.zip` and upload it
   to Canvas. Submit attempted work by the deadline even if checks fail.

Read `results/Report.md` for the comparison tables. The same folder contains
`window-inputs.csv`, `allocations.csv`, `observed.csv`, `fees.csv`,
`stock-risk.csv`, `short-diagnostics.csv`, `wealth-paths.csv`, and
`probabilities.csv`. The probability file has no data rows in Standard.
Exported probabilities and weights are decimal fractions. The displayed
tables use percentages. Each run replaces these generated files.

You are graded on correct calculations and interpretation, regardless of
which portfolio performs best. Passing every public check means your work
is ready for teaching-team review, which also covers documentation and
the three written responses. See the [rubric](RUBRIC.md) for the score cutoffs.

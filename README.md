# Problem Set 3 (PS3): Does More Recent Data Lead to a Better Portfolio?

Suppose you have USD 10,000 to invest in a portfolio of stocks, and you must
estimate the portfolio's risk from past prices. You could use twelve years of
prices or only the most recent year. A longer window contains more
observations. A shorter window emphasizes recent market conditions. You must
also decide whether to allow short positions. Short positions can reduce
portfolio risk, but they incur borrowing fees.

These choices lead to the central question of PS3: **Does using more recent
data lead to a better portfolio, and does allowing short positions help or
hurt portfolio performance?**

You will answer this question with two **estimation windows**: all prices from
**2014–2025** (12 years) and **2025 prices alone** (1 year). For each window,
you will choose two global minimum-variance (GMV) portfolios: one that allows
short positions and one that does not. You will then hold all four portfolios
over the same 126 trading days in 2026 and compare their performance.

The Advanced track also fits a multiple-asset geometric Brownian motion
(MAGBM) model to each window and estimates each portfolio's probability of
beating a benchmark.

## Lecture slides, examples, and mathematical companion

PS3 uses the covariance and MAGBM material from [the L5b lecture slides](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/d38e8d35ae35b941168992b7cc13d101bef90c7c/lectures/week-5/L5b/slides/CHEME-5660-L5b-Slides-Fall-2026.pdf)
and the minimum-variance portfolios from [the L6a lecture slides](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/d38e8d35ae35b941168992b7cc13d101bef90c7c/lectures/week-6/L6a/slides/CHEME-5660-L6a-Slides-Fall-2026.pdf).
The [mathematical companion](docs/PS3-Mathematical-Companion.pdf) presents
the formulas as lecture slides and introduces borrowing fees, which are new
in PS3.

The starter functions follow two L6a course examples. They keep the
examples' variable names, array types, and package calls. Each docstring
names the example task to follow. Its **Course references** section names
the example cell and code lines to imitate, the lecture slides that explain
the calculation, and the matching slide in the mathematical companion.
Slide numbers match the slide footers.

| PS3 functions | Course example and task |
|:--|:--|
| `estimate_inputs`, `minimum_variance_weights` | [Minimum-variance portfolio example](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/1828cc6a6d56e918a6c4036d0bde2ee44b91291c/lectures/week-6/L6a/CHEME-5660-L6a-Example-Data-MinVar-Portfolio-Fall-2026.ipynb), Task 1: estimate inputs and compute the two GMV portfolios. |
| `portfolio_path` | [Portfolio simulation example](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/1828cc6a6d56e918a6c4036d0bde2ee44b91291c/lectures/week-6/L6a/CHEME-5660-L6a-Example-MAGBM-Portfolio-Fall-2026.ipynb), Task 2: convert weights to shares and calculate wealth. |
| `borrowing_costs` | PS3 extension: follow Study 2 and the hints in the function. The examples omit borrowing fees. |
| `build_magbm`, `benchmark_probability` (Advanced) | [Portfolio simulation example](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/1828cc6a6d56e918a6c4036d0bde2ee44b91291c/lectures/week-6/L6a/CHEME-5660-L6a-Example-MAGBM-Portfolio-Fall-2026.ipynb), Task 1: construct the model; Task 3: apply the trade rule. |

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

## Getting started

Use Julia `1.12.7`. All price files are supplied; you do not need to download
any market data.

1. Download the `Source code (zip)` archive from the tagged
   [PS3 GitHub release](https://github.com/varnerlab/PS3-CHEME-4660-5660-Fall-2026/releases/tag/ps3-cheme-4660-5660-2026.1)
   and extract it.
2. In VS Code, open the extracted folder containing
   [Project.toml](Project.toml), [README.md](README.md), and
   [check_submission.jl](check_submission.jl). Open a terminal there and run
   all commands from that folder.
3. Install the recorded package versions. This requires an internet connection
   and may take several minutes:

   ```text
   julia --project=. --startup-file=no -e 'using Pkg; Pkg.instantiate()'
   ```

   Keep [Project.toml](Project.toml) and [Manifest.toml](Manifest.toml) together.
4. Set [TRACK.txt](TRACK.txt) to exactly `standard` or `advanced`:

   | Track | Code to complete | Questions to answer |
   |:--|:--|:--|
   | Standard | The four functions in [src/Standard.jl](src/Standard.jl) | [responses/Standard.md](responses/Standard.md) |
   | Advanced | The same four functions plus two MAGBM functions in [src/Advanced.jl](src/Advanced.jl) | [responses/Advanced.md](responses/Advanced.md) |

   Complete only your selected track. The Advanced file contains its own
   copies of the four Standard functions. Leave the other track's source and
   response files unchanged.
5. Before you view any allocation results, write the prediction in
   Question 1a of your response file.
6. Complete the functions. Replace each `error("Complete ...")` expression
   with your calculation. Keep the supplied function names, arguments,
   return types, docstrings, setup lines, and return statements. Leave the
   input arrays unchanged; some checks verify this. Each docstring lists the
   arguments and return values, names the example cell whose Julia code to
   imitate, and lists the slides to read. The TODO hints give the steps.
   Delete each TODO comment once you finish that step.
7. Save your code and run the checker:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

   The checker runs 20 Standard or 32 Advanced public checks. It then calls
   your functions for both estimation windows and **automatically prints the
   comparison report**. You do not need a separate report command. If checks
   fail, numbers in brackets point to the messages under **Check details**.
   Unfinished calculations appear as `UNAVAILABLE`, and the report lists
   their causes under **Unavailable calculations**. Run the checker as you
   work; you do not need to finish every function first. The first run takes
   longer while Julia compiles packages.

If you write helper functions, put them in separate `.jl` files under
[src](src) and load them from [Include.jl](Include.jl) using its commented
example. Document each helper's purpose, inputs, and output. Leave the data,
support code, reports, tests, and checker unchanged.

## Portfolio and data

Use the same eight stocks in this order: Apple (AAPL), Microsoft (MSFT),
NVIDIA (NVDA), Advanced Micro Devices (AMD), Goldman Sachs (GS), Bank of
America (BAC), Ford (F), and Johnson & Johnson (JNJ).

| Price data | Use |
|:--|:--|
| [2014–2025 prices](data/portfolio-2014-2025.csv), all rows | **2014–2025 window.** Estimate each stock's mean growth rate and the covariance matrix from 3,017 price rows and 3,016 daily growth observations. |
| The same file, 2025 rows only | **2025 window.** Estimate each stock's mean growth rate and the covariance matrix from 250 price rows and 249 daily growth observations. |
| [2026 prices](data/portfolio-2026.csv) | Evaluate every portfolio over the same 126 trading days. |

Every portfolio begins with **USD 10,000 at the December 31, 2025 prices**.
This is day 0. The first 2026 observation is day 1. Close all positions at
observation 126 on July 6, 2026, the **closing day**. Use 252 trading days
per year. The [data notes](data/README.md) describe the aligned
volume-weighted average prices in USD/share.

PS3 allows fractional shares and ignores dividends, taxes, commissions,
bid-ask spreads, and collateral requirements. It includes the borrowing fee
defined in Study 2.

## Study 1: What allocations does each estimation window suggest?

Compare the GMV weights from the 2014–2025 window with those from the 2025
window. For each window, find one GMV portfolio that allows short positions
and one that prohibits them. This study shows how the estimation window and
the shorting rule change the weights and the estimated risk.

1. **Write your prediction.** Before you view any allocation results, answer
   Question 1a in your response file. Predict how using only 2025 might
   change the size of the short positions and the reliability of the risk
   estimates. Keep this prediction; you will revisit it in Question 1c.
2. **Complete `estimate_inputs`.** Calculate daily log growth rates from the
   supplied prices. Then calculate each stock's sample mean growth rate and
   the sample covariance matrix. Use sample means, not a growth regression.
   The same function must work for either estimation window.
3. **Complete `minimum_variance_weights`.** Return weights that sum to one and
   minimize the estimated portfolio variance. For the long-only case, require
   nonnegative weights and use the course solver. For the shorts-allowed
   case, allow negative weights and use the L6a closed-form solution with a
   linear solve. A negative weight is a short position: borrowed shares that
   are sold now and bought back on the closing day. Do not add a growth
   target or a borrowing fee. The long-only starter code supplies a growth
   floor equal to the smallest mean growth rate. Keep it: every fully
   invested long-only portfolio meets this floor, so it excludes no
   allocation.
4. **Answer Questions 1b and 1c.** Run the checker. It calls your functions
   for both estimation windows and reports four portfolios, each with its
   estimated growth, estimated risk, and short exposure. Estimated growth is
   the weighted average of the stocks' mean growth rates; it does not affect
   the GMV weights. Short exposure is the total initial value of the short
   positions as a percentage of initial wealth. The report also lists each
   stock's estimated risk and, for each shorted stock, its correlation with
   the portfolio's long positions. Use these values to compare the windows
   and to explain why covariance matters when choosing stocks to short.

Risk values are standard deviations of growth rates in inverse years, so
they are larger than the percentage volatilities quoted in financial news.
Some differences between portfolios may be small. A small difference is a
result to interpret, not a sign of a coding error; the report shows risk to
four decimal places so it stays visible.

The report also includes an equal-weight reference that puts one eighth of
initial wealth in each stock. You do not write a function for it.

Each window produces its own risk estimates, so a lower estimated risk does
not show which portfolio will perform better. Study 2 tests all four
portfolios on the same 2026 prices.

## Study 2: Which estimates hold up in 2026?

Compare the four portfolios and the equal-weight reference over the same
**126 trading days in 2026**. This study tests whether the lower estimated
risk from Study 1 carries over to new prices and whether borrowing fees
change the wealth comparison.

1. **Complete `portfolio_path`.** Use the initial weights, USD 10,000, and
   the day-0 prices to calculate the number of shares of each stock.
   Negative share counts are short positions. Hold these share counts fixed
   through day 126 and calculate the portfolio's wealth on every day. Return
   wealth before borrowing fees. The weights drift as prices change; do not
   rebalance.
2. **Complete `borrowing_costs`.** Calculate the total fee on the borrowed
   shares for one annual rate. The report compares two rates. At **0%** no
   fee is owed, so net wealth equals gross wealth. At **3%** the report calls
   your function. Charge each trading interval using the value
   of the shares owed at the start of that interval. Divide the annual rate
   by 252 to get the daily rate. The 126 intervals use the prices from day 0
   through day 125. Fees do not earn or pay interest and are paid on the
   closing day. Portfolios without short positions owe no fee. The 3% rate
   is an illustrative assumption.
3. **Read the report.** Rerun the checker. The report uses your functions to
   calculate gross wealth (before fees) and net wealth (after fees). It also
   reports realized risk and success against the benchmark. For each
   shorts-allowed portfolio, it splits the gain before fees into the long
   and short positions. For each shorted stock, it lists the amount shorted,
   the stock's 2026 price change, and the gain or loss on that short.
   Realized risk is the sample standard deviation of the portfolio's daily
   log growth rates, on the same inverse-year scale as estimated risk and
   calculated from wealth before fees. The benchmark starts at USD 10,000
   and grows at **5% per year, compounded continuously**. A portfolio
   succeeds when its net wealth ends strictly above the benchmark.
4. **Answer Question 2.** Compare realized risk and net wealth within each
   window and against equal weight. Then use the 0% and 3% results to
   separate the effect of fees from the effect of different holdings.

Study 3 uses these observed results to decide whether the more recent prices
led to a better portfolio in this experiment.

## Study 3: What can we conclude?

Use the results from Studies 1 and 2 to answer the central question: did
using only 2025 prices lead to a better portfolio, and did allowing short
positions help? **This study requires interpretation, not another
function.**

- **Standard:** Answer Question 3 in your response file.
- **Advanced:** First complete the model comparison below. Then answer
  Question 3 in your response file. It combines the model comparison with
  this conclusion, so you still submit three written responses.

## Advanced: How likely was success under each model?

Estimate the probability that each portfolio beats the benchmark after 126
trading days. Compare the predictions from the MAGBM model fitted to the
2014–2025 window with those from the model fitted to the 2025 window. Then
compare those predictions with the outcomes observed in Study 2.

1. **Complete `build_magbm`.** Use one window's mean growth rates and
   covariance matrix to construct its MAGBM model. Return the course
   package's model object, as in Task 1 of the portfolio simulation example.
   The report calls this function once for each estimation window.
2. **Complete `benchmark_probability`.** The report supplies a vector of net
   terminal wealth values, one per simulated path. Follow the example's trade
   rule: calculate the scaled net present value (NPV) of each path, count the
   positive values, and divide by the total number of paths. Keep zero and
   negative wealth outcomes in the denominator. Return a probability between
   zero and one.
3. **Read the simulation results.** Rerun the checker. The supplied helper
   generates **20,000 joint stock-price paths per model**. The report reuses
   your holdings and fee functions to calculate net wealth on each path.
   Each model evaluates the two portfolios chosen from its own window and the
   equal-weight reference at borrowing rates of **0% and 3%**. Within each
   model, all portfolios and fee rates use the same price paths. Both models
   use the same standard normal draws, transformed by their own fitted
   parameters. You do not write simulation code.
4. **Answer Question 3.** Compare the modeled probabilities with the observed
   outcomes, interpret the fee effect, compare the two models, and finish
   with the Study 3 conclusion. Your response file lists each required part.

The report gives a Monte Carlo standard error for each probability. A small
standard error describes simulation precision; it does not establish
forecast accuracy. The historical comparison covers one market episode
shared by all portfolios.

## Check and submit your work

1. Save your code and answers, then run the checker again:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

   The checker writes `MANIFEST.txt` and lists any answers that still
   contain TODO.
2. Create a ZIP of the entire PS3 folder named
   `CHEME-5660-PS3-<your netid>.zip`.
3. Upload the ZIP to the PS3 assignment on Canvas. Submit attempted work by
   the initial deadline even if checks fail.

Read `results/Report.md` for the comparison tables. The same folder contains
`window-inputs.csv`, `allocations.csv`, `observed.csv`, `fees.csv`,
`short-positions.csv`, `stock-risk.csv`, `short-diagnostics.csv`,
`wealth-paths.csv`, and `probabilities.csv`. The probability file has no
data rows in Standard. Exported probabilities, weights, and price changes
are decimal fractions; the displayed
tables use percentages. Each run replaces these generated files.

You are graded on correct calculations and interpretation, regardless of
which portfolio performs best. Passing every public check means your work
is ready for teaching-team review, which also covers documentation and
the three written responses. See the [rubric](RUBRIC.md) for the score
cutoffs.

# PS3 Advanced responses

**Central question:** Does using more recent data lead to a better portfolio,
and does allowing short positions help?

Complete this file instead of the Standard responses. Answer every lettered
part of each question inside that question's answer block. Keep the
`<!-- answer-N:start -->` and `<!-- answer-N:end -->` markers, and replace
each TODO with your response. One short paragraph per lettered part is
enough.

Use the report tables as evidence. Cite only the numbers that support each
comparison, with their window and portfolio labels. Do not copy whole tables
or list every value.

Report weights and exposures as percentages, wealth and fees in USD, and
risk in inverse years. Use four decimal places for risk so small differences
remain visible. Report probabilities as percentages and probability changes
in percentage points. Formulas are in the
[mathematical companion](../docs/PS3-Mathematical-Companion.pdf).

## 1. What allocations does each estimation window suggest?

**a. Predict first.** Before you view any allocation results, write two or
three sentences predicting how using 2025 alone might change the short
exposure and the reliability of the risk estimates. If you have already seen
the results, say so and state what you would have expected.

**b. Compare the windows.** For each window, name the shorted stocks. Cite
the short exposure and the estimated risks of the two GMV portfolios that
support your comparison.

**c. Explain.** Revisit your prediction. Explain why covariance, rather than
individual volatility alone, determines whether a short position can help.
Explain why allowing short positions can never increase the minimum
estimated variance when the covariance matrix is held fixed.

<!-- answer-1:start -->
TODO: Answer parts a–c.
<!-- answer-1:end -->

## 2. Which estimates hold up in 2026?

**a. Compare realized risk and net wealth.** At a 3% borrowing rate, compare
the long-only and shorts-allowed portfolios within each window. Identify
which of the four portfolios had the lowest realized risk and which had the
greatest net wealth, and compare them with the equal-weight reference.

**b. Separate fees from holdings.** For each shorts-allowed portfolio, cite
its borrowing fee and its 0% result. Decide whether the fee or the different
holdings explain most of its wealth difference from the long-only portfolio.

**c. Explain the short positions.** Explain how a short position can lose
money while still helping to reduce portfolio fluctuations.

<!-- answer-2:start -->
TODO: Answer parts a–c.
<!-- answer-2:end -->

## 3. How likely was success under each model, and what can we conclude?

**a. Compare predictions with outcomes.** For each fitted model, cite the
two GMV portfolios' success probabilities at a 3% borrowing rate and their
observed success or failure from Question 2. Within each window, does the
portfolio with the lowest estimated variance have the highest modeled
success probability? Explain why it need not.

**b. Interpret the fee effect.** For each shorts-allowed portfolio, report
the change in success probability from 0% to 3% fees, in percentage points.
Explain why this change cannot be positive when the holdings and simulated
price paths are unchanged.

**c. Compare the two models.** When you compare predictions across windows,
separate changes in the portfolio weights from changes in the fitted model.
Explain why the equal-weight portfolio can have different success
probabilities under the two models even though its holdings do not change.

**d. Answer the central question.** Use the observed results and the modeled
probabilities to state whether using only 2025 prices led to a better
portfolio and whether allowing short positions helped. Support your answer
with two numerical comparisons. Explain one advantage and one limitation of
using only 2025 prices. Changing the window changes both the number of
observations and how recent they are; explain why this experiment cannot
separate those two effects. Explain why a small Monte Carlo standard error
and this single observed 2026 episode cannot establish forecast accuracy.

<!-- answer-3:start -->
TODO: Answer parts a–d.
<!-- answer-3:end -->

An incorrect initial prediction does not reduce your score when you explain
and reconsider it using the results. No additional window, fee rate, or
simulation code is required.

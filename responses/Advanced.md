# PS3 Advanced responses

**Central question:** Does using more recent data lead to a better portfolio,
and does allowing short positions help?

Complete this file instead of the Standard responses. Use the supplied
report tables as evidence. **Do not reproduce them.** Cite
selected numbers with their window and portfolio labels. Keep these answer
markers and replace each TODO with your response. About two short paragraphs
per question should be sufficient; Question 1 also includes your prediction; Question 3 may need three paragraphs.

Report weights and exposures as percentages, wealth and fees in USD, and
risk in inverse years. Use four decimal places for risk so small differences
remain visible. Formulas are in the
[mathematical companion](../docs/PS3-Mathematical-Companion.pdf).

## 1. What allocations does each history suggest?

**Predict first.** Before viewing the allocation comparison, write two or
three sentences about how using 2025 alone might change the short exposure
and reliability of the risk estimates. Keep this prediction. If you have
already seen the results, say so and explain what you would have expected.

**Compare and explain.** For each window, identify the shorted stocks and
report total short exposure and the estimated risk of the two optimized
portfolios. Revisit your prediction. Explain why covariance, rather than
individual volatility alone, determines whether a short can help. Why can
allowing shorts never increase the minimum estimated variance when the
covariance matrix is held fixed?

<!-- answer-1:start -->
TODO: Add your prediction and interpret the allocation comparison.
<!-- answer-1:end -->

## 2. Which estimates hold up in 2026?

For each window, compare the long-only and shorts-allowed portfolios'
realized risk and net terminal wealth at a 3% borrowing rate. Cite those
values, then identify which of the four allocations had the lowest realized
risk and which had the greatest net wealth. Briefly compare these with the
supplied equal-weight reference.

For each shorts-allowed allocation, report the borrowing fee and use the
zero-fee result to judge whether the fee or the holdings explain most of
its wealth difference from the long-only allocation. Explain why a short
can lose money while still helping to reduce portfolio fluctuations.

<!-- answer-2:start -->
TODO: Interpret the common 2026 evaluation and separate holdings from fee effects.
<!-- answer-2:end -->

## 3. How likely was success under each model?

At a 3% borrowing rate, compare the success probabilities for the two
optimized portfolios under each window's MA-GBM model. Cite the probabilities
and observed success or failure. Within each window, does the lowest
estimated variance correspond to the highest modeled success probability?
Explain why it need not.

For each shorts-allowed allocation, report the change in probability from
0% to 3% fees, in percentage points. Explain why it cannot increase when
holdings and simulated asset paths are unchanged. The report supplies these
calculations; no extra simulation code is required.

Conclude whether the recent window gave a better portfolio in this
experiment. Distinguish changes in the holdings from changes in the fitted
price model: why can the equal-weight probability change even though its
holdings do not? Explain one advantage and one limitation of the recent
window, and why a small Monte Carlo standard error and this single observed
history cannot establish forecast accuracy.

<!-- answer-3:start -->
TODO: Compare model probabilities, interpret fees, and give a qualified conclusion.
<!-- answer-3:end -->

An incorrect initial prediction does not reduce your score when you explain
and reconsider it using the results. No additional window or fee sweep is
required.

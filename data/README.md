# Supplied portfolio prices

Both tracks use the same eight stocks, in this column order:
`AAPL, MSFT, NVDA, AMD, GS, BAC, F, JNJ`.

| File | Dates | Rows | Role |
|:--|:--|--:|:--|
| [portfolio-2014-2025.csv](portfolio-2014-2025.csv) | January 3, 2014–December 31, 2025 | 3,017 | Estimate parameters and choose allocations for both estimation windows. |
| [portfolio-2026.csv](portfolio-2026.csv) | January 2–September 4, 2026 | 170 | Evaluate the fixed holdings. |

Each CSV has a header, a `date` column in `YYYY-MM-DD` format, and one price
column per stock. Prices are daily volume-weighted average prices in
USD/share. Every selected stock has a complete history on the source's date
grid, positive finite prices, and the same strictly increasing dates.
No rows were filled or interpolated.

The estimation file combines 2,767 observations from the course's corrected
2014–2024 snapshot with 250 observations from its 2025 snapshot. Calculate
**3,016 consecutive growth observations**, including the change from
December 31, 2024 to January 2, 2025. Do not restart the growth calculation
at the year boundary. Use a time step of 1/252 trading year and sample
covariance divisor **3,015**.

Use the December 31, 2025 prices as the initial prices. That row is day 0
for evaluation, not an additional 2026 observation. Estimate all inputs and
select all allocations using only this file. For the recent window, first
select its 250 rows dated in 2025, then calculate 249 growth observations
with sample covariance divisor 248. This window excludes the change from
December 31, 2024 to January 2, 2025. The supplied loader selects each
window's rows and arranges them as price tables keyed by ticker. Your
`estimate_inputs` function receives the same kind of input for either window.

The first 2026 row is day 1. The 126th observation is **July 6, 2026**.
Include day 0 when forming the evaluation path, giving 127 price rows and 126 trading intervals.
The later observations are supplied as part of the fixed snapshot but
are not used to fit or select anything in this assignment.

## Source and extraction

These files copy the `volume_weighted_average_price` columns from the
course repository's Polygon.io snapshots. The source download requested
split-adjusted prices; the exercise ignores dividends. The wide CSV layout
preserves the supplied values and trading-date order.

The historical input uses the course's corrected 2014–2024 file, documented
in its `MARKET-DATA.md`. All eight stocks have aligned histories. At the
join into 2025, absolute one-interval log price changes are below 0.026.
Across the combined history, the largest absolute log price change is
about 0.266. These checks find no obvious split-scale discontinuity; they
are not an independent audit of every corporate action.

The files originate in `code/src/data` of the
[course repository](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026).
Source filenames and SHA-256 hashes are:

```text
SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2
63c54e39967c4291c3e4130ef5a73c439222c00ed7160f6c32961e08a4159ee0

SP500-Daily-OHLC-1-2-2025-to-12-31-2025.jld2
5526d1cb7eb458697723b756b98fcab2655bb8bfd6686d0e5ea0c65bf9938579

SP500-Daily-OHLC-1-2-2026-to-09-04-2026.jld2
805936bd2ea505020c8f30b860cddbe063a6430dc42189d4c81bb5b05b4e9492
```

The basket is a subset of the L6a example's firms, chosen to retain technology,
banking, automotive, and health-care stocks. It was fixed before the original
2026 evaluation and retained when the estimation window was extended to
2014–2025. The assignment compares portfolios within this supplied basket;
it does not test a rule for selecting stocks from the entire market.

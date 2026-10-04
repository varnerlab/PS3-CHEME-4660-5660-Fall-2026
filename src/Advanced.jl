# PS3 Advanced: complete the six functions below.
# The report reuses these functions for both estimation windows.
# Keep the function names, arguments, return types, and docstrings.
# Replace each error("Complete ...") expression with your calculation.
# The setup lines, return statements, and solver roundoff cleanup are supplied.
# Save your code, then run from the PS3 folder:
# julia --project=. --startup-file=no check_submission.jl
#
# The docstrings and hints refer to tasks in these two L6a course examples.
# README.md links both notebooks in its course example table.
# Minimum variance: CHEME-5660-L6a-Example-Data-MinVar-Portfolio-Fall-2026.ipynb
# Portfolio simulation: CHEME-5660-L6a-Example-MAGBM-Portfolio-Fall-2026.ipynb
#
# Each docstring ends with Course references: the example notebook cells
# that show the Julia code, the L5b and L6a lecture slides that explain the
# calculation, and the matching slide in the PS3 mathematical companion
# (docs/PS3-Mathematical-Companion.pdf). README.md links all of them.
# Some example cells wrap their calculation in a let ... end block. Copy only
# the lines you need and rename variables to match this file.

"""
    estimate_inputs(dataset::Dict{String,DataFrame}, my_list_of_tickers::Array{String,1};
        Δt::Float64 = 1.0/252.0) -> Tuple

Estimate the mean growth rates and covariance matrix for one estimation window.

### Arguments

- `dataset`: Price tables keyed by ticker. Each `DataFrame` has `timestamp`
  and `volume_weighted_average_price` (USD/share) columns. The supplied
  loader has already selected the window's rows and aligned the dates.
- `my_list_of_tickers`: Stock order for the columns of `G` and the entries
  of `ĝ` and `Σ̂_g`.
- `Δt`: Length of one interval in years. Daily data use `1/252`.

### Returns

A tuple `(G, ĝ, Σ̂_g)`:

- `G`: Growth-rate matrix (1/year). Rows are intervals and columns are stocks.
- `ĝ`: Sample-mean growth rate of each stock (1/year).
- `Σ̂_g`: Sample covariance matrix of the growth rates (1/year²).

### Method

Calculate the daily growth rates, then the sample mean and sample
covariance of each column. Use sample means, not the L4b growth
regression. Keep every interval in `dataset`.

### Course references

- Example code: `CHEME-5660-L6a-Example-Data-MinVar-Portfolio-Fall-2026.ipynb`,
  Task 1, the cell under "Estimate the portfolio inputs". Its `G`, `ĝ`,
  and `Σ̂_g` lines are the three calculations here. Skip its date checks,
  `Ĉ`, and `ρ̂`; the PS3 loader has already aligned the dates.
- Lecture slides: L5b slide 19, "The Data Matrix and the Sample
  Covariance". L6a slide 20, "Estimated Inputs", explains why PS3 uses
  sample means.
- PS3 companion: slide 5, "Study 1: Estimate the Growth Rates".
"""
function estimate_inputs(dataset::Dict{String,DataFrame},
    my_list_of_tickers::Array{String,1}; Δt::Float64 = 1.0/252.0)::Tuple

    # TODO 1: Call the course log_growth_matrix function on dataset.
    # Hint: pass dataset, my_list_of_tickers, and the keyword Δt = Δt.
    # The function reads the VWAP column and calculates consecutive log growth.
    G = error("Complete estimate_inputs: calculate G.");

    # TODO 2: Average each column of G, as in the notebook's ĝ calculation.
    # Hint: mean(..., dims=1) |> vec returns one mean per stock.
    ĝ = error("Complete estimate_inputs: calculate ĝ.");

    # TODO 3: Calculate the sample covariance of the columns of G.
    # Hint: cov(..., dims=1) uses the sample divisor (number of rows minus one).
    Σ̂_g = error("Complete estimate_inputs: calculate Σ̂_g.");

    # Return the three arrays in this order -
    return (G, ĝ, Σ̂_g);
end

"""
    minimum_variance_weights(ĝ::Array{Float64,1}, Σ̂_g::Array{Float64,2};
        allow_shorts::Bool = false) -> Array{Float64,1}

Compute the global minimum-variance (GMV) weights for one estimation window.

### Arguments

- `ĝ`: Sample-mean growth rates from `estimate_inputs` (1/year).
- `Σ̂_g`: Positive-definite sample covariance matrix from `estimate_inputs`
  (1/year²), in the same stock order as `ĝ`.
- `allow_shorts`: `true` permits negative weights (short positions); `false`
  requires every weight to be nonnegative.

### Returns

- `w`: One weight per stock, in the order of `ĝ`. The weights sum to one.

### Method

When `allow_shorts` is `true`, use the closed-form weights with a linear
solve. Otherwise, call the course solver with long-only bounds. Keep the
supplied growth floor `R = minimum(ĝ)`, as in the example: every fully
invested long-only allocation meets this floor, so it excludes no
allocation. Do not add a growth target or a borrowing fee.

### Course references

- Example code: `CHEME-5660-L6a-Example-Data-MinVar-Portfolio-Fall-2026.ipynb`,
  Task 1. Shorts allowed: the `x` and `w` lines in the cell under
  "Compute the global minimum-variance portfolio". Long only: the
  `build(...)` call under "Add long-only bounds" and the `solve` and
  `solution["argmax"]` lines in the cell after it. Skip the `σ` line and
  the `@assert` checks.
- Lecture slides: L6a slides 11–13 cover the GMV problem, its
  closed-form weights, and the meaning of a negative weight. L6a slides
  18–19 cover "The Long-Only Problem" and "The Growth Floor".
- PS3 companion: slides 6–7, "Study 1: Choose the Allocations" and
  "Study 1: Solve the Shorts-Allowed Problem".
"""
function minimum_variance_weights(ĝ::Array{Float64,1}, Σ̂_g::Array{Float64,2};
    allow_shorts::Bool = false)::Array{Float64,1}

    # Initialize -
    M = length(ĝ); # number of firms

    if allow_shorts
        # TODO 1: Solve for x, as in the example cell under
        # "Compute the global minimum-variance portfolio".
        # Hint: use the backslash operator to solve Σ̂_g*x = one_vector.
        one_vector = ones(M);
        x = error("Complete minimum_variance_weights: solve for x.");

        # TODO 2: Normalize x so the weights sum to one. Keep negative entries.
        # Hint: the notebook divides x by the scalar one_vector'*x.
        w = error("Complete minimum_variance_weights: normalize x.");
    else
        # Set up the long-only bounds, as in the notebook -
        bounds = zeros(M, 2); # column 1: lower bounds, column 2: upper bounds
        bounds[:,2] .= 1.0;

        # TODO 3: Fill in the estimated covariance and mean vector.
        # Hint: the package field Σ receives Σ̂_g; its field μ receives ĝ.
        problem = build(MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem, (
            Σ = error("Complete minimum_variance_weights: supply Σ."),
            μ = error("Complete minimum_variance_weights: supply μ."),
            bounds = bounds,
            initial = (1/M)*ones(M),
            R = minimum(ĝ)
        ));

        # TODO 4: Solve problem and extract the optimal weights.
        # Hint: solve(...) returns a dictionary; solution["argmax"] holds w.
        # Under "Add long-only bounds", the code cell after the build(...) cell
        # shows both lines.
        solution = error("Complete minimum_variance_weights: solve problem.");
        w = error("Complete minimum_variance_weights: extract w.");

        # Remove solver roundoff at zero bounds (supplied) -
        w[abs.(w) .< 1e-6] .= 0.0;
        w = w / sum(w);
    end

    return w;
end

"""
    portfolio_path(prices::Array{Float64,2}, w::Array{Float64,1}, W₀::Float64) -> Tuple

Convert initial weights to fixed share counts and value the holdings on every day.

### Arguments

- `prices`: Share prices (USD/share). Rows are trading days, with day 0 in
  row 1. Columns are stocks.
- `w`: Initial weights, in the column order of `prices`.
- `W₀`: Initial wealth (USD).

### Returns

A tuple `(shares, W)`:

- `shares`: Signed, fractional share count for each stock. A negative count
  means shares owed.
- `W`: Gross wealth (USD) for every row of `prices`, including day 0. Keep
  zero or negative values if they occur.

### Method

Hold the share counts fixed; do not rebalance. A negative weight gives a
negative share count, so the same calculation handles short positions.
Do not subtract borrowing fees here; `borrowing_costs` calculates them.

### Course references

- Example code: `CHEME-5660-L6a-Example-MAGBM-Portfolio-Fall-2026.ipynb`,
  Task 2. The `shares` line under "Convert the weights to share counts"
  and the `W_actual` line under "Calculate wealth from the fixed
  holdings". The example's `prices_2025` is the `prices` argument here.
  The example uses long-only weights, but the same two lines work when
  some weights are negative.
- Lecture slides: L5b slide 24, "Buy-and-Hold Wealth". L6a slide 13,
  "What Does a Negative Weight Mean?", explains signed share counts.
- PS3 companion: slide 10, "Study 2: Hold the Shares".
"""
function portfolio_path(prices::Array{Float64,2}, w::Array{Float64,1},
    W₀::Float64)::Tuple

    # Initialize -
    S₀ = prices[1,:]; # initial share prices (USD/share), as in the notebook

    # TODO 1: Convert each firm's initial dollar allocation to shares.
    # Hint: w*W₀ gives dollars per firm. Divide entrywise by S₀ using ./.
    shares = error("Complete portfolio_path: calculate shares.");

    # TODO 2: Value those same shares at every row of prices.
    # Hint: the example's W_actual line uses prices_2025*shares. Here the
    # matrix is named prices.
    W = error("Complete portfolio_path: calculate W.");

    return (shares, W);
end

"""
    borrowing_costs(prices::Array{Float64,2}, shares::Array{Float64,1},
        annual_rate::Float64, Δt::Float64) -> Float64

Calculate the total borrowing fee on the short positions over the holding period.

### Arguments

- `prices`: Share prices (USD/share) from day 0 through the sale day. Rows
  are trading days and columns are stocks.
- `shares`: Signed, fixed share counts from `portfolio_path`.
- `annual_rate`: Annual borrowing rate as a fraction, for example `0.03`
  for 3%. A rate of `0.0` gives no fee, so the report uses gross wealth for
  its 0% results.
- `Δt`: Length of one trading interval in years.

### Returns

- `total_fee`: Total borrowing fee (USD). It is zero when no shares are owed
  or the rate is zero.

### Method

This fee is a PS3 extension. For each interval, charge `annual_rate*Δt`
times the value of the shares owed at the start of the interval. The
final row is the sale day and starts no interval. Fees are paid at the
sale, do not compound, and do not change the share counts.

### Course references

- Example code: none; the course examples omit borrowing fees. The loops
  are supplied, and each TODO needs one number or one product.
  `prices[j,i]` is the price in row `j` (day) and column `i` (stock).
- Lecture slides: L6a slide 13, "What Does a Negative Weight Mean?",
  explains how a short position works. The lecture ignores the borrowing
  fee that PS3 adds.
- PS3 companion: slide 13, "Study 2: Accumulate Borrowing Fees".
"""
function borrowing_costs(prices::Array{Float64,2}, shares::Array{Float64,1},
    annual_rate::Float64, Δt::Float64)::Float64

    # Initialize -
    N, M = size(prices); # price rows and firms

    # TODO 1: Initialize the accumulated fee to zero dollars (0.0).
    total_fee = error("Complete borrowing_costs: initialize total_fee.");

    for i ∈ 1:M
        if shares[i] < 0.0 # only borrowed shares incur fees
            shares_owed = -shares[i]; # positive number of shares owed

            for j ∈ 1:(N-1) # interval starts; exclude the final sale row
                # TODO 2: Value the shares owed at this interval's starting price.
                # Hint: multiply prices[j,i] (USD/share) by shares_owed (shares).
                short_value = error("Complete borrowing_costs: calculate short_value.");

                # TODO 3: Add this interval's fee to total_fee.
                # Hint: annual_rate*Δt is the fee per dollar for one interval.
                total_fee += error("Complete borrowing_costs: calculate the interval fee.");
            end
        end
    end

    return total_fee;
end

"""
    build_magbm(ĝ::Array{Float64,1}, Σ̂_g::Array{Float64,2};
        Δt::Float64 = 1.0/252.0) -> MyMultipleAssetGeometricBrownianMotionEquityModel

Build the multiple-asset GBM (MAGBM) price model for one estimation window.

### Arguments

- `ĝ`: Sample-mean growth rates (1/year).
- `Σ̂_g`: Positive-definite sample covariance matrix of the growth rates
  (1/year²).
- `Δt`: Length of the interval used to estimate `ĝ` and `Σ̂_g`, in years.

### Returns

- `model`: A `MyMultipleAssetGeometricBrownianMotionEquityModel` with drift
  vector `μ` (1/year) and covariance factor `A` (1/√year). The supplied
  report passes it to the package's `sample` function to simulate prices.

### Method

Convert the growth-rate covariance to a covariance rate, factor it, and
add the half-variance correction to the mean growth rates. The supplied
code builds the model from the drift and the factor.

### Course references

- Example code: `CHEME-5660-L6a-Example-MAGBM-Portfolio-Fall-2026.ipynb`,
  Task 1. The `Ĉ` line under "Estimate mean growth rates and
  covariance", the `A` line under "Construct the price model", and the
  `μ̂` line in the cell after it. The `build(...)` call is supplied.
- Lecture slides: L5b slides 11–14 cover the MAGBM model, the covariance
  factor, and the one-step price update with its half-variance term.
  L5b slide 21, "Estimating the Covariance Rate".
- PS3 companion: slide 16, "Advanced: Construct the MAGBM Model".
"""
function build_magbm(ĝ::Array{Float64,1}, Σ̂_g::Array{Float64,2};
    Δt::Float64 = 1.0/252.0)::MyMultipleAssetGeometricBrownianMotionEquityModel

    # TODO 1: Convert growth-rate covariance to the covariance rate Ĉ.
    # Hint: multiply Σ̂_g by Δt, as in Task 1's "Estimate mean growth rates and covariance".
    Ĉ = error("Complete build_magbm: calculate Ĉ.");

    # TODO 2: Calculate the lower Cholesky factor of Ĉ and store it as a Matrix.
    # Hint: cholesky(...).L |> Matrix, as in the A line under
    # "Construct the price model".
    A = error("Complete build_magbm: calculate A.");

    # TODO 3: Add the half-variance correction to ĝ to obtain the price drift.
    # Hint: the correction is 0.5*diag(Ĉ). The package's sample function subtracts
    # it in each log-price step, so adding it here keeps the mean growth equal to ĝ.
    μ̂ = error("Complete build_magbm: calculate μ̂.");

    # Build the actual course model (supplied) -
    model = build(MyMultipleAssetGeometricBrownianMotionEquityModel, (
        μ = μ̂,
        A = A
    ));
    return model;
end

"""
    benchmark_probability(W_T::Array{Float64,1}, W₀::Float64,
        g_y::Float64, N::Int64, Δt::Float64) -> Float64

Estimate the probability that net terminal wealth beats the benchmark.

### Arguments

- `W_T`: Net terminal wealth (USD), one value per simulated path. The
  supplied report has already subtracted borrowing fees.
- `W₀`: Initial wealth (USD).
- `g_y`: Benchmark growth rate, continuously compounded (1/year).
- `N`: Number of holding intervals (126 in PS3).
- `Δt`: Length of one holding interval, in years.

### Returns

- `p̂`: Fraction of paths with positive scaled NPV, between 0 and 1. It is
  not a percentage.

### Method

In PS3 the target scaled NPV is zero. A path succeeds only when its
scaled NPV is strictly positive. Keep every path in the denominator,
including paths with zero or negative wealth.

### Course references

- Example code: `CHEME-5660-L6a-Example-MAGBM-Portfolio-Fall-2026.ipynb`,
  Task 3. The `ρ` line in the first Task 3 cell, then the `p̂` line under
  "Estimate the target probability". Use `W_T` in place of
  `simulated_wealth[end, :]`. Skip the `se` line and the summary table.
- Lecture slides: L6a slide 21, "Portfolio Wealth and Scaled NPV".
- PS3 companion: slide 18, "Advanced: Estimate the Success Probability".
"""
function benchmark_probability(W_T::Array{Float64,1}, W₀::Float64,
    g_y::Float64, N::Int64, Δt::Float64)::Float64

    # Initialize -
    T = N*Δt; # holding period (years); N counts intervals, not price rows
    ρ_target = 0.0; # a positive scaled NPV means we beat the benchmark
    n = length(W_T); # number of simulated paths

    # TODO 1: Calculate scaled NPV for each net terminal wealth value.
    # Hint: in Task 3, replace simulated_wealth[end, :] with W_T.
    # Use ./ W₀, multiply by exp(-g_y*T), then subtract 1.0 entrywise.
    ρ_T = error("Complete benchmark_probability: calculate ρ_T.");

    # TODO 2: Count outcomes strictly above ρ_target and divide by n.
    # Hint: count(ρ_T .> ρ_target) counts true entries. Equality is not success.
    p̂ = error("Complete benchmark_probability: calculate p̂.");

    return p̂;
end

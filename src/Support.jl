# Supplied data and simulation machinery. Leave this file unchanged.
const PS3_TICKERS = ["AAPL", "MSFT", "NVDA", "AMD", "GS", "BAC", "F", "JNJ"];
const PS3_DT = 1/252;
const PS3_WEALTH = 10_000.0;
const PS3_DAYS = 126;
const PS3_BENCHMARK = 0.05;
const PS3_PATHS = 20_000;
const PS3_SEED = 566003;
const PS3_WEIGHT_TOL = 1e-6; # hide only solver roundoff when labeling short exposure

"""
    load_price_file(path) -> NamedTuple

Read the supplied wide CSV into `(dates, tickers, prices)`. Check the fixed
stock order, increasing dates, and positive finite prices. No interpolation
or date filtering is performed here. Malformed input raises an error.
"""
function load_price_file(path::AbstractString)::NamedTuple
    lines = readlines(path);
    length(lines) >= 2 || error("Price file has no observations: $path");
    header = split(strip(lines[1]), ',');
    header == ["date"; PS3_TICKERS] || error("Unexpected price columns: $path");
    dates = Date[];
    prices = Matrix{Float64}(undef, length(lines)-1, length(PS3_TICKERS));
    for (row, line) in enumerate(lines[2:end])
        cells = split(strip(line), ',');
        length(cells) == length(header) || error("Invalid price row $(row+1): $path");
        push!(dates, Date(cells[1]));
        prices[row, :] = parse.(Float64, cells[2:end]);
    end
    all(diff(dates) .> Day(0)) || error("Price dates must be strictly increasing.");
    all(x -> isfinite(x) && x > 0, prices) || error("Prices must be finite and positive.");
    return (dates=dates, tickers=copy(PS3_TICKERS), prices=prices);
end

"""
    load_experiment(root) -> NamedTuple

Load the two estimation windows and the 127-row evaluation path. Select 2025
price rows before any student growth calculation. Prepend December 31, 2025
to the first 126 observations of 2026. Later observations are not used.
Return `(windows, dates, prices, tickers)`. Each window has `label`, `dates`,
and `prices`; the outer dates and prices describe the common evaluation.
"""
function load_experiment(root::AbstractString)::NamedTuple
    training = load_price_file(joinpath(root, "data", "portfolio-2014-2025.csv"));
    observed = load_price_file(joinpath(root, "data", "portfolio-2026.csv"));
    length(training.dates) == 3017 || error("Expected 3,017 training prices.");
    first(training.dates) == Date(2014,1,3) && last(training.dates) == Date(2025,12,31) ||
        error("Training dates do not match the supplied snapshot.");
    all(d -> 2014 <= year(d) <= 2025, training.dates) || error("Invalid training year.");
    all(d -> year(d) == 2026, observed.dates) || error("Evaluation contains a non-2026 date.");
    length(observed.dates) >= PS3_DAYS || error("Evaluation needs 126 trading days.");
    observed.dates[PS3_DAYS] == Date(2026,7,6) || error("Unexpected liquidation date.");
    recent = year.(training.dates) .== 2025;
    count(recent) == 250 || error("Expected 250 recent prices.");
    windows = [(label="2014-2025", dates=training.dates, prices=training.prices),
        (label="2025", dates=training.dates[recent], prices=training.prices[recent, :])];
    prices = vcat(training.prices[end:end, :], observed.prices[1:PS3_DAYS, :]);
    dates = vcat(training.dates[end], observed.dates[1:PS3_DAYS]);
    return (windows=windows, dates=dates, prices=prices, tickers=training.tickers);
end

"""
    realized_risk(wealth, dt) -> Union{Missing,Float64}

Return the sample standard deviation of annualized log growth from a gross
wealth path. Return `missing` if any wealth is nonpositive or fewer than two
intervals are available. No clipping, fees, or early liquidation are applied.
"""
function realized_risk(wealth::AbstractVector, dt::Real)
    length(wealth) >= 3 && all(x -> isfinite(x) && x > 0, wealth) || return missing;
    return std(diff(log.(wealth)) ./ dt; corrected=true);
end

"""
    simulate_paths(model, initial_prices, days, paths, dt; seed=PS3_SEED) -> Array

Generate exact multiple-asset GBM prices with dimensions time × stock × path,
including initial prices in row 1. The model supplies `drift`, `diffusion`,
and `factor`. Use the same seed for both fitted models to reuse standard
normal innovations. No global random state is changed. One bank is shared
across all allocations and fee rates within each model.

Only one model's price bank is needed at a time. At the assignment settings
its storage is about 155 MiB. Work arrays for innovations contain one path.
"""
function simulate_paths(model::NamedTuple, initial_prices::Vector{Float64},
    days::Int, paths::Int, dt::Float64; seed::Int=PS3_SEED)::Array{Float64,3}
    days > 0 && paths > 0 && dt > 0 || throw(ArgumentError("Positive simulation sizes required."));
    n = length(initial_prices);
    length(model.drift) == n && size(model.diffusion) == size(model.factor) == (n,n) ||
        throw(DimensionMismatch("Model dimensions do not match the stock prices."));
    all(isfinite, model.drift) && all(isfinite, model.factor) && all(isfinite, model.diffusion) ||
        error("Model parameters must be finite.");
    isapprox(model.factor * model.factor', model.diffusion; atol=1e-9, rtol=1e-7) ||
        error("The model factor must satisfy A*A' = diffusion.");
    all(x -> isfinite(x) && x > 0, initial_prices) || error("Initial prices must be positive.");
    rng = MersenneTwister(seed); # reset per fitted window, so innovations agree across models
    bank = Array{Float64}(undef, days+1, n, paths);
    normal = Matrix{Float64}(undef, n, days);
    increments = similar(normal);
    log_drift = (model.drift .- diag(model.diffusion)./2) .* dt;
    for path in 1:paths
        randn!(rng, normal);
        mul!(increments, model.factor, normal);
        bank[1, :, path] = initial_prices;
        for day in 1:days, stock in 1:n
            bank[day+1, stock, path] = bank[day, stock, path] *
                exp(log_drift[stock] + sqrt(dt)*increments[stock, day]);
        end
    end
    all(x -> isfinite(x) && x > 0, bank) || error("Simulated prices overflowed or underflowed.");
    return bank;
end

"""
    simulated_outcomes(bank, weights, wealth, annual_rate, dt) -> NamedTuple

Reuse the student's holdings and fee functions on every supplied price path.
Return gross and net terminal wealth vectors and the number of gross paths
that touched zero or became negative. Retain every outcome and fixed holding
through liquidation. The zero-fee comparison uses the same gross vector.
"""
function simulated_outcomes(bank::Array{Float64,3}, weights::Vector{Float64},
    wealth::Float64, annual_rate::Float64, dt::Float64)::NamedTuple
    paths = size(bank,3);
    gross, net = zeros(paths), zeros(paths);
    nonpositive = 0;
    for path in 1:paths
        prices = bank[:, :, path]; # concrete matrix matches the student function contract
        holdings = portfolio_path(prices, weights, wealth);
        gross[path] = holdings.wealth[end];
        net[path] = gross[path] - borrowing_costs(prices, holdings.shares, annual_rate, dt);
        nonpositive += any(<=(0), holdings.wealth);
    end
    all(isfinite, gross) && all(isfinite, net) || error("Simulated wealth must remain finite.");
    return (gross=gross, net=net, nonpositive=nonpositive);
end

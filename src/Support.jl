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
    course_dataset(prices, tickers; dates) -> Dict{String,DataFrame}

Arrange the supplied CSV prices as the ticker-keyed DataFrames used in L6a.
Columns are timestamp and volume_weighted_average_price. The caller selects
price rows first; this conversion does not filter dates or compute growth.
"""
function course_dataset(prices::Array{Float64,2}, tickers::Array{String,1};
    dates::Array{Date,1})::Dict{String,DataFrame}
    size(prices) == (length(dates),length(tickers)) ||
        throw(DimensionMismatch("Dates and tickers must match the price matrix."));
    dataset = Dict{String,DataFrame}();
    for (i,ticker) ∈ enumerate(tickers)
        dataset[ticker] = DataFrame(timestamp=copy(dates),
            volume_weighted_average_price=prices[:,i]);
    end
    return dataset;
end

"""
    load_experiment(root) -> NamedTuple

Load the two estimation windows and the 127-row evaluation path. Select 2025
price rows before any student growth calculation. Prepend December 31, 2025
to the first 126 observations of 2026. Later observations are not used.
Return `(windows, dates, prices, tickers)`. Each window has `label`, `dates`,
and `prices`, plus the course-format `dataset`; the outer dates and prices
describe the common evaluation.
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
    windows = [merge(window, (dataset=course_dataset(window.prices,training.tickers;
        dates=window.dates),)) for window in windows];
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
    simulate_paths(model, S₀, days, number_of_paths, Δt; seed=PS3_SEED) -> Dict

Call the course sampler exactly as in Task 1 of the L6a portfolio simulation
example. Return a dictionary: path number => matrix with time in column 1
and stock prices in columns 2:end. Row 1 is day 0.

Reset the random seed before each fitted model so both use the same standard
normal draws. All portfolios and fees reuse this dictionary within a model.
"""
function simulate_paths(model::MyMultipleAssetGeometricBrownianMotionEquityModel,
    S₀::Array{Float64,1}, days::Int64, number_of_paths::Int64,
    Δt::Float64; seed::Int64=PS3_SEED)::Dict{Int64,Array{Float64,2}}
    days > 0 && number_of_paths > 0 && Δt > 0 ||
        throw(ArgumentError("Positive simulation sizes required."));
    M = length(S₀);
    length(model.μ)==M && size(model.A)==(M,M) ||
        throw(DimensionMismatch("Model dimensions do not match the stock prices."));
    all(isfinite,model.μ) && all(isfinite,model.A) || error("Model parameters must be finite.");
    all(x -> isfinite(x) && x > 0,S₀) || error("Initial prices must be positive.");

    # Use the same model, sampler call, and output type as the course example -
    T₁ = 0.0;
    T₂ = days*Δt;
    Random.seed!(seed);
    simulation_dictionary = VLQuantitativeFinancePackage.sample(model,
        (Sₒ = S₀, T₁ = T₁, T₂ = T₂, Δt = Δt),
        number_of_paths = number_of_paths);

    for prices in values(simulation_dictionary)
        size(prices)==(days+1,M+1) || error("Unexpected simulated path dimensions.");
        all(x -> isfinite(x) && x > 0,prices[:,2:end]) ||
            error("Simulated prices overflowed or underflowed.");
    end
    return simulation_dictionary;
end

"""
    simulated_outcomes(bank, weights, wealth, annual_rate, dt) -> NamedTuple

Reuse the student's holdings and fee functions on every supplied price path.
Return gross and net terminal wealth vectors and the number of gross paths
that touched zero or became negative. Retain every outcome and fixed holding
through liquidation. The zero-fee comparison uses the same gross vector.
"""
function simulated_outcomes(bank::Dict{Int64,Array{Float64,2}}, weights::Vector{Float64},
    wealth::Float64, annual_rate::Float64, dt::Float64)::NamedTuple
    paths = length(bank);
    gross, net = zeros(paths), zeros(paths);
    nonpositive = 0;
    for path in 1:paths
        prices = bank[path][:,2:end]; # drop the time column, as in the course notebook
        shares, W = portfolio_path(prices, weights, wealth);
        gross[path] = W[end];
        net[path] = gross[path] - borrowing_costs(prices, shares, annual_rate, dt);
        nonpositive += any(<=(0), W);
    end
    all(isfinite, gross) && all(isfinite, net) || error("Simulated wealth must remain finite.");
    return (gross=gross, net=net, nonpositive=nonpositive);
end

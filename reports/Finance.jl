# Supplied comparison tables. Calculations call the selected student functions.
"""Run a report calculation, recording its label and error instead of stopping other tables."""
function report_attempt(f::Function, label::String, issues::Vector{String})
    try
        return f();
    catch caught
        push!(issues, label * ": " * sprint(showerror,caught));
        return nothing;
    end
end

"""Validate estimated array shapes and finite entries before constructing dependent tables."""
function checked_estimates(result::Tuple, rows::Int, stocks::Int)
    G, ĝ, Σ̂_g = result;
    p = (growth=G,mean=ĝ,covariance=Σ̂_g);
    size(p.growth)==(rows-1,stocks) && length(p.mean)==stocks &&
        size(p.covariance)==(stocks,stocks) || error("Estimation returned unexpected dimensions.");
    all(isfinite,p.growth) && all(isfinite,p.mean) && all(isfinite,p.covariance) ||
        error("Estimation returned nonfinite values.");
    return p;
end

"""Validate full-investment weights; do not silently repair an incorrect student allocation."""
function checked_weights(w::Vector{Float64}, n::Int, shorts::Bool)
    length(w)==n && all(isfinite,w) && isapprox(sum(w),1.0; atol=1e-7) ||
        error("Weights must be finite and sum to one.");
    shorts || minimum(w)>=-PS3_WEIGHT_TOL || error("Long-only allocation contains a short.");
    return w;
end

"""Return one fixed-holdings historical record. Fee-dependent fields stay missing until the fee function works."""
function historical_record(prices::Matrix{Float64}, weights::Vector{Float64}, issues::Vector{String})
    shares, W = portfolio_path(prices,weights,PS3_WEALTH);
    path = (shares=shares,wealth=W);
    length(path.shares)==size(prices,2) && length(path.wealth)==size(prices,1) ||
        error("Holdings returned unexpected dimensions.");
    all(isfinite,path.shares) && all(isfinite,path.wealth) || error("Holdings must be finite.");
    # Report gross wealth and realized risk even while the fee function is unfinished -
    fee = report_attempt("2026 borrowing fees",issues) do
        f = borrowing_costs(prices,path.shares,0.03,PS3_DT);
        isfinite(f) && f>=0 || error("Borrowing cost must be finite and nonnegative.");
        f;
    end
    fee = fee===nothing ? missing : fee;
    short = weights .< -PS3_WEIGHT_TOL;
    # Split the gross gain by side; the long and short gains add to gross wealth minus W₀ -
    gains = path.shares.*(prices[end,:]-prices[1,:]);
    pnl = sum(gains[short]);
    long_pnl = sum(gains[.!short]);
    # Show what each short cost: its initial value, price change, and gain before fees -
    positions = [(stock=i, amount=-path.shares[i]*prices[1,i], change=prices[end,i]/prices[1,i]-1,
        gain=gains[i]) for i in findall(short)];
    gross = path.wealth[end];
    net = gross-fee;
    target = PS3_WEALTH*exp(PS3_BENCHMARK*PS3_DAYS*PS3_DT);
    return (path=path, gross=gross, net=net, fees=fee, risk=realized_risk(path.wealth,PS3_DT),
        long_pnl=long_pnl, short_pnl=pnl, short_positions=positions,
        scaled_npv=net/target-1, success=net>target, zero_success=gross>target);
end

"""Build each table whose required student calculations are available; mark the others UNAVAILABLE."""
function finance_tables(track::AbstractString, root::AbstractString;
    paths::Int=PS3_PATHS, seed::Int=PS3_SEED)::NamedTuple
    data = load_experiment(root);
    issues = String[];
    tables = Dict(name=>NamedTuple[] for name in
        ("window-inputs","allocations","observed","fees","short-positions","stock-risk","short-diagnostics","probabilities","wealth-paths"));
    timings = NamedTuple[];
    equal = fill(1/8,8);
    eq_history = report_attempt("Equal-weight 2026 evaluation",issues) do
        historical_record(data.prices,equal,issues);
    end
    # Add one common historical reference, independent of the fitted window -
    add_history!(tables,"reference","equal_weight",eq_history,data.dates);
    for window in data.windows
        parameters = report_attempt("$(window.label) estimation",issues) do
            checked_estimates(estimate_inputs(deepcopy(window.dataset),copy(data.tickers); Δt=PS3_DT),size(window.prices,1),8);
        end
        eqrisk = parameters === nothing ? missing : sqrt(max(0.0,dot(equal,parameters.covariance*equal)));
        push!(tables["window-inputs"],(window=window.label,price_rows=size(window.prices,1),
            growth_rows=size(window.prices,1)-1,start_date=first(window.dates),end_date=last(window.dates),
            equal_weight_estimated_risk=eqrisk));
        for i in 1:8
            push!(tables["stock-risk"],(window=window.label,ticker=data.tickers[i],
                risk=parameters===nothing ? missing : sqrt(max(0.0,parameters.covariance[i,i]))));
        end
        allocations = Dict{String,Union{Nothing,Vector{Float64}}}("equal_weight"=>equal);
        for name in ("long_only","shorts_allowed")
            weights = parameters===nothing ? nothing : report_attempt("$(window.label) $name allocation",issues) do
                checked_weights(minimum_variance_weights(copy(parameters.mean),copy(parameters.covariance);allow_shorts=name=="shorts_allowed"),8,name=="shorts_allowed");
            end
            allocations[name] = weights;
            risk = weights===nothing ? missing : sqrt(max(0.0,dot(weights,parameters.covariance*weights)));
            exposure = weights===nothing ? missing : max(0.0,-sum(weights[weights .< -PS3_WEIGHT_TOL]));
            holdings = weights===nothing ? fill(missing,8) : weights;
            push!(tables["allocations"],merge((window=window.label,portfolio=name,estimated_risk=risk,
                short_exposure=exposure),NamedTuple{Tuple(Symbol.(data.tickers))}(Tuple(holdings))));
            history = weights===nothing ? nothing : report_attempt("$(window.label) $name 2026 evaluation",issues) do
                historical_record(data.prices,weights,issues);
            end
            add_history!(tables,window.label,name,history,data.dates);
            if name=="shorts_allowed"
                push!(tables["fees"],(window=window.label,portfolio=name,
                    zero_fee_wealth=history===nothing ? missing : history.gross,
                    three_percent_wealth=history===nothing ? missing : history.net,
                    borrowing_fee=history===nothing ? missing : history.fees,
                    long_pnl=history===nothing ? missing : history.long_pnl,
                    short_pnl=history===nothing ? missing : history.short_pnl,
                    zero_fee_success=history===nothing ? missing : history.zero_success,
                    three_percent_success=history===nothing ? missing : history.success));
                if history!==nothing
                    for p in history.short_positions
                        push!(tables["short-positions"],(window=window.label,ticker=data.tickers[p.stock],
                            amount_shorted=p.amount,price_change=p.change,gain_before_fees=p.gain));
                    end
                end
                if weights!==nothing
                    report_attempt("$(window.label) short diagnostics",issues) do
                        long_weights = max.(weights,0.0);
                        long_weights ./= sum(long_weights);
                        long_growth = parameters.growth*long_weights;
                        for i in findall(<(-PS3_WEIGHT_TOL),weights)
                            push!(tables["short-diagnostics"],(window=window.label,ticker=data.tickers[i],
                                weight=weights[i],stock_risk=sqrt(parameters.covariance[i,i]),
                                correlation_with_longs=cor(parameters.growth[:,i],long_growth)));
                        end
                    end
                end
            end
        end
        if track=="advanced"
            simulation_report!(tables,timings,issues,window,parameters,allocations,data.prices[1,:],paths,seed);
        end
    end
    return (tables=tables,issues=unique(issues),timings=timings);
end

"""Append one history row and its gross wealth series, or explicit unavailable cells."""
function add_history!(tables, window, name, h, dates)
    value(field) = h===nothing ? missing : getproperty(h,field);
    push!(tables["observed"],(window=window,portfolio=name,sale_date=last(dates),
        realized_risk=value(:risk),gross_wealth=value(:gross),borrowing_fee=value(:fees),
        net_wealth=value(:net),scaled_npv=value(:scaled_npv),beats_benchmark=value(:success)));
    for (i,date) in enumerate(dates)
        push!(tables["wealth-paths"],(window=window,portfolio=name,day=i-1,date=date,
            gross_wealth=h===nothing ? missing : h.path.wealth[i]));
    end
    return nothing;
end

"""Add probabilities and their Monte Carlo errors using one shared bank for the fitted window."""
function simulation_report!(tables,timings,issues,window,parameters,allocations,initial,paths,seed)
    started = time();
    model = parameters===nothing ? nothing : report_attempt("$(window.label) price model",issues) do
        build_magbm(copy(parameters.mean),copy(parameters.covariance); Δt=PS3_DT);
    end
    # Avoid generating a large bank while required student functions are still stubs -
    ready = model===nothing ? nothing : report_attempt("$(window.label) simulation prerequisites",issues) do
        probe = reshape(repeat(initial,3),8,3)' |> Matrix;
        shares, W = portfolio_path(probe,fill(1/8,8),PS3_WEALTH);
        borrowing_costs(probe,shares,0.03,PS3_DT);
        benchmark_probability([PS3_WEALTH],PS3_WEALTH,PS3_BENCHMARK,PS3_DAYS,PS3_DT);
        true;
    end
    bank = ready===nothing ? nothing : report_attempt("$(window.label) path generation",issues) do
        simulate_paths(model,initial,PS3_DAYS,paths,PS3_DT;seed=seed);
    end
    for name in ("long_only","shorts_allowed","equal_weight")
        weights = allocations[name];
        outcome = bank===nothing || weights===nothing ? nothing : report_attempt("$(window.label) $name probabilities",issues) do
            r = simulated_outcomes(bank,weights,PS3_WEALTH,0.03,PS3_DT);
            p0 = benchmark_probability(r.gross,PS3_WEALTH,PS3_BENCHMARK,PS3_DAYS,PS3_DT);
            p3 = benchmark_probability(r.net,PS3_WEALTH,PS3_BENCHMARK,PS3_DAYS,PS3_DT);
            0<=p3<=p0<=1 || error("Probabilities must lie in [0,1] and cannot increase with fees.");
            (p0=p0,p3=p3,se0=sqrt(p0*(1-p0)/paths),se3=sqrt(p3*(1-p3)/paths),
                delta=100*(p3-p0),nonpositive=r.nonpositive);
        end
        v(field) = outcome===nothing ? missing : getproperty(outcome,field);
        push!(tables["probabilities"],(window=window.label,portfolio=name,paths=paths,
            probability_zero=v(:p0),probability_three_percent=v(:p3),
            se_zero=v(:se0),se_three_percent=v(:se3),fee_change_percentage_points=v(:delta),
            nonpositive_gross_paths=v(:nonpositive)));
    end
    push!(timings,(window=window.label,seconds=time()-started,bank_bytes=bank===nothing ? 0 : Base.summarysize(bank)));
    return nothing;
end

"""Write CSV records at full Float64 precision. Missing calculations are marked UNAVAILABLE."""
function write_table_csv(path::AbstractString, rows::Vector{NamedTuple}, headers::Vector{Symbol})
    cell(x) = "\"" * replace(ismissing(x) ? "UNAVAILABLE" : string(x), '"'=>"\"\"") * "\"";
    open(path,"w") do io
        println(io,join(string.(headers),','));
        for row in rows
            println(io,join([cell(getproperty(row,key)) for key in headers],','));
        end
    end
    return nothing;
end

# Readable portfolio labels for the displayed tables; CSV files keep the identifiers -
const PORTFOLIO_LABELS = Dict("long_only"=>"long-only","shorts_allowed"=>"shorts-allowed",
    "equal_weight"=>"equal weight");

"""Format table values without rounding the calculations or exported CSV data."""
function report_cell(x, key::Symbol)::String
    ismissing(x) && return "UNAVAILABLE";
    key==:portfolio && return get(PORTFOLIO_LABELS,x,string(x));
    x isa Bool && return x ? "yes" : "no";
    x isa AbstractFloat || return string(x);
    key==:price_change && return @sprintf("%+.4f%%",100*x); # sign shows a rise or fall
    key in Symbol.(PS3_TICKERS) || key in (:weight,:short_exposure,:probability_zero,:probability_three_percent,:scaled_npv) ?
        (@sprintf("%.4f%%",100*x)) :
        key in (:se_zero,:se_three_percent) ? (@sprintf("%.4f",100*x)) :
        occursin("risk",string(key)) || key==:correlation_with_longs ? (@sprintf("%.4f",x)) :
        (@sprintf("%.2f",x));
end

"""Write one readable Markdown table from records and display labels."""
function markdown_table(io, title, rows, columns)
    println(io,"\n## ",title,"\n");
    println(io,"| ",join(last.(columns)," | ")," |");
    println(io,"| ",join(fill("---",length(columns))," | ")," |");
    for row in rows
        println(io,"| ",join([report_cell(getproperty(row,first(c)),first(c)) for c in columns]," | ")," |");
    end
    isempty(rows) && println(io,"\nNo rows available. See the calculation messages below.");
end

"""
    print_finance_report(track, root; output_directory) -> NamedTuple

Run the supplied comparison, print and save Report.md, and export nine CSV
tables. Unfinished calculations produce UNAVAILABLE rather than reference
answers. CSV probabilities are fractions; displayed probabilities are percent.
Monte Carlo errors are displayed in percentage points. Return tables and timing
records for instructor validation. Standard exports a header-only probability file.
"""
function print_finance_report(track::AbstractString,root::AbstractString;
    output_directory::AbstractString=joinpath(root,"results"))::NamedTuple
    result = finance_tables(track,root);
    t = result.tables;
    mkpath(output_directory);
    headers = Dict(
        "short-positions"=>[:window,:ticker,:amount_shorted,:price_change,:gain_before_fees],
        "short-diagnostics"=>[:window,:ticker,:weight,:stock_risk,:correlation_with_longs],
        "probabilities"=>[:window,:portfolio,:paths,:probability_zero,:probability_three_percent,
            :se_zero,:se_three_percent,:fee_change_percentage_points,:nonpositive_gross_paths]);
    for (name,rows) in t
        keys = isempty(rows) ? headers[name] : collect(propertynames(first(rows)));
        write_table_csv(joinpath(output_directory,name*".csv"),rows,keys);
    end
    io = IOBuffer();
    println(io,"# PS3 $(titlecase(track)) comparison\n");
    println(io,"Write your Question 1a prediction before you read the allocation results.\n");
    println(io,"Hold USD 10,000 from December 31, 2025 through July 6, 2026 (126 trading days).");
    println(io,"Risk is measured before fees in inverse years. Wealth is in USD. The 5% continuous benchmark is USD ",
        @sprintf("%.2f",PS3_WEALTH*exp(PS3_BENCHMARK*PS3_DAYS*PS3_DT)),".");
    markdown_table(io,"Estimation windows",t["window-inputs"],[:window=>"Window",:price_rows=>"Prices",:growth_rows=>"Changes",:equal_weight_estimated_risk=>"Equal-weight estimated risk"]);
    for window in ("2014-2025","2025")
        rows=filter(r->r.window==window,t["allocations"]);
        markdown_table(io,"Allocations: $window",rows,[:portfolio=>"Portfolio",:estimated_risk=>"Estimated risk",:short_exposure=>"Short exposure"]);
        weight_rows=[(ticker=ticker,long_only=getproperty(rows[1],Symbol(ticker)),shorts_allowed=getproperty(rows[2],Symbol(ticker))) for ticker in PS3_TICKERS];
        # Weight columns use percent labels explicitly; input CSV weights remain fractions.
        println(io,"\n| Stock | Long only (%) | Shorts allowed (%) |\n| --- | --- | --- |");
        for r in weight_rows
            println(io,"| ",r.ticker," | ",report_cell(r.long_only,:weight)," | ",report_cell(r.shorts_allowed,:weight)," |");
        end
    end
    markdown_table(io,"Observed results at 3% borrowing",t["observed"],[:window=>"Window",:portfolio=>"Portfolio",:realized_risk=>"Realized risk",:net_wealth=>"Net wealth",:beats_benchmark=>"Success"]);
    markdown_table(io,"Borrowing-fee comparison",t["fees"],[:window=>"Window",:portfolio=>"Portfolio",:zero_fee_wealth=>"Wealth at 0%",:three_percent_wealth=>"Wealth at 3%",:borrowing_fee=>"Fee",:long_pnl=>"Long gains before fees",:short_pnl=>"Short gains before fees",:zero_fee_success=>"Success at 0%",:three_percent_success=>"Success at 3%"]);
    println(io,"\nLong and short gains before fees add up to the change in gross wealth from USD 10,000.");
    markdown_table(io,"Short positions in 2026",t["short-positions"],[:window=>"Window",:ticker=>"Stock",:amount_shorted=>"Amount shorted",:price_change=>"Price change",:gain_before_fees=>"Gain before fees"]);
    println(io,"\nAmount shorted is the initial value of the shares owed. Price change runs from December 31, 2025 to July 6, 2026. A short gains when its price falls and loses when its price rises.");
    markdown_table(io,"Individual-stock risk",t["stock-risk"],[:window=>"Window",:ticker=>"Stock",:risk=>"Estimated risk"]);
    markdown_table(io,"Short-position diagnostics",t["short-diagnostics"],[:window=>"Window",:ticker=>"Stock",:weight=>"Weight",:stock_risk=>"Stock risk",:correlation_with_longs=>"Correlation with combined longs"]);
    println(io,"\nCorrelation with combined longs compares the shorted stock's growth rates with the growth rate of the portfolio's long positions. Both use the estimation window. The long positions keep their initial weights, rescaled to sum to one.");
    if track=="advanced"
        markdown_table(io,"Modeled success probabilities",t["probabilities"],[:window=>"Model window",:portfolio=>"Portfolio",:probability_zero=>"Success at 0%",:probability_three_percent=>"Success at 3%",:fee_change_percentage_points=>"Fee change (pp)"]);
        markdown_table(io,"Simulation precision",t["probabilities"],[:window=>"Model window",:portfolio=>"Portfolio",:paths=>"Paths",:se_zero=>"SE at 0% (pp)",:se_three_percent=>"SE at 3% (pp)"]);
        println(io,"\nStandard errors describe simulation precision under the fitted model, not forecast accuracy. Fee changes use unrounded probabilities. Both models reuse standard normal draws with seed $PS3_SEED. Nonpositive wealth paths stay in the denominator.");
    end
    if !isempty(result.issues)
        println(io,"\n## Unavailable calculations\n");
        for issue in result.issues
            println(io,"- ",replace(issue,'\n'=>" "));
        end
    end
    println(io,"\nUse selected results as evidence in the three response blocks. The teaching team reviews interpretation and documentation.");
    report=String(take!(io));
    write(joinpath(output_directory,"Report.md"),report);
    println(report);
    return result;
end

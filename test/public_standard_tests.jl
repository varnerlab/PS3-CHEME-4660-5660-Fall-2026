# Each closure tests one calculation with independent supplied inputs.
"""Return the twenty Standard public checks; no observed assignment answers are embedded."""
function standard_public_checks()::Vector{NamedTuple}
    # Synthetic fixtures keep early unfinished functions from blocking later checks -
    G = [1.0 2.0; 3.0 0.0; 2.0 4.0];
    dt = 0.25;
    prices = vcat(reshape([10.0,20.0],1,:), [10.0 20.0] .* exp.(cumsum(G; dims=1).*dt));
    tickers = ["AAPL","MSFT"];
    dataset = course_dataset(prices,tickers; dates=collect(Date(2020,1,1):Day(1):Date(2020,1,4)));
    C = [1.0 1.5; 1.5 4.0];
    parameters = (mean=[0.1,0.3], covariance=C);
    P = [10.0 20.0; 12.0 18.0; 9.0 30.0];
    w = [1.5,-0.5];
    return [
        (name="Estimation: one growth row per price interval", evaluate=() ->
            size(estimate_inputs(deepcopy(dataset),copy(tickers); Δt=dt)[1]) == (3,2)),
        (name="Estimation: annualized log changes", evaluate=() ->
            isapprox(estimate_inputs(deepcopy(dataset),copy(tickers); Δt=dt)[1],G; atol=1e-12)),
        (name="Estimation: column mean vector", evaluate=() ->
            isapprox(estimate_inputs(deepcopy(dataset),copy(tickers); Δt=dt)[2],[2.0,2.0]; atol=1e-12)),
        (name="Estimation: sample covariance includes cross-stock terms", evaluate=() ->
            isapprox(estimate_inputs(deepcopy(dataset),copy(tickers); Δt=dt)[3],[1.0 -1.0; -1.0 4.0]; atol=1e-12)),
        (name="Estimation: another window length and time step", evaluate=() -> begin
            p = reshape(exp.([0.0,0.1,0.3,0.6,1.0]),:,1);
            d = course_dataset(p,["AAPL"]; dates=collect(Date(2020,1,1):Day(1):Date(2020,1,5)));
            r = estimate_inputs(d,["AAPL"]; Δt=0.5);
            isapprox(r[2],[0.5]; atol=1e-12) && isapprox(r[3][1,1],1/15; atol=1e-12)
        end),
        (name="Allocation: long-only boundary optimum", evaluate=() ->
            isapprox(minimum_variance_weights(parameters.mean,parameters.covariance),[1.0,0.0]; atol=2e-5)),
        (name="Allocation: unrestricted short position", evaluate=() ->
            isapprox(minimum_variance_weights(parameters.mean,parameters.covariance; allow_shorts=true),[1.25,-0.25]; atol=1e-9)),
        (name="Allocation: diagonal covariance and full investment", evaluate=() -> begin
            r = minimum_variance_weights([-0.2,0.9,0.0],Matrix(Diagonal([1.,2.,4.])));
            isapprox(r,[4/7,2/7,1/7]; atol=2e-5) && isapprox(sum(r),1.0; atol=1e-9)
        end),
        (name="Allocation: means do not change either solution", evaluate=() -> begin
            p = (mean=[9.0,-4.0], covariance=copy(C));
            isapprox(minimum_variance_weights(p.mean,p.covariance),[1.,0.]; atol=2e-5) &&
                isapprox(minimum_variance_weights(p.mean,p.covariance;allow_shorts=true),[1.25,-0.25]; atol=1e-9)
        end),
        (name="Allocation: shorts have no finite position cap", evaluate=() -> begin
            # This positive-definite covariance has the exact optimum [11,-10].
            p = (mean=zeros(2),covariance=[100.01 110.01;110.01 121.01]);
            isapprox(minimum_variance_weights(p.mean,p.covariance;allow_shorts=true),[11.,-10.]; atol=1e-7)
        end),
        (name="Holdings: signed fractional shares", evaluate=() ->
            isapprox(portfolio_path(copy(P),copy(w),100.0)[1],[15.,-2.5]; atol=1e-12)),
        (name="Holdings: gross wealth includes day zero", evaluate=() ->
            isapprox(portfolio_path(copy(P),copy(w),100.0)[2],[100.,135.,60.]; atol=1e-12)),
        (name="Holdings: shares remain fixed as weights drift", evaluate=() ->
            isapprox(portfolio_path([10. 10.;20. 5.;10. 20.],[0.5,0.5],100.0)[2],[100.,125.,150.]; atol=1e-12)),
        (name="Holdings: retain nonpositive wealth outcomes", evaluate=() ->
            isapprox(portfolio_path([10. 10.;1. 30.;10. 10.],[2.,-1.],100.0)[2],[100.,-280.,100.]; atol=1e-12)),
        (name="Holdings: scale with investment without mutating inputs", evaluate=() -> begin
            p, weights = copy(P), copy(w);
            r = portfolio_path(p,weights,250.0);
            isapprox(r[2],[250.,337.5,150.]; atol=1e-12) && p==P && weights==w
        end),
        (name="Fees: beginning-of-interval prices exclude liquidation", evaluate=() ->
            isapprox(borrowing_costs(copy(P),[15.,-2.5],0.03,0.25),0.7125; atol=1e-12)),
        (name="Fees: zero rate", evaluate=() -> borrowing_costs(copy(P),[15.,-2.5],0.0,0.25)==0.0),
        (name="Fees: no short shares", evaluate=() -> borrowing_costs(copy(P),[5.,2.5],0.03,0.25)==0.0),
        (name="Fees: sum multiple shorts and do not compound", evaluate=() ->
            isapprox(borrowing_costs([10. 20.;20. 10.;1000. 1000.],[-2.,-3.],0.1,0.5),7.5; atol=1e-12)),
        (name="Fees: one interval and unchanged inputs", evaluate=() -> begin
            p = [10. 20.;1000. 2000.]; q=[0.,-2.];
            fee = borrowing_costs(p,q,0.03,1/252);
            isapprox(fee,40*0.03/252; atol=1e-12) && p==[10. 20.;1000. 2000.] && q==[0.,-2.]
        end),
    ];
end

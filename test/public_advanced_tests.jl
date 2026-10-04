"""Return the twenty shared checks and twelve Advanced checks using isolated inputs."""
function advanced_public_checks()::Vector{NamedTuple}
    p = (mean=[0.1,-0.2],covariance=[4.0 1.0;1.0 9.0]);
    dt = 0.25;
    extra = [
        (name="Model: covariance rate scaling", evaluate=() ->
            begin
                m = build_magbm(p.mean,p.covariance; Δt=dt);
                m isa MyMultipleAssetGeometricBrownianMotionEquityModel &&
                    isapprox(m.A*m.A',[1.0 0.25;0.25 2.25]; atol=1e-12)
            end),
        (name="Model: price drift includes the half-variance correction", evaluate=() ->
            isapprox(build_magbm(p.mean,p.covariance; Δt=dt).μ,[0.6,0.925]; atol=1e-12)),
        (name="Model: lower Cholesky factor with a positive diagonal", evaluate=() -> begin
            # The lower Cholesky factor of [1.0 0.25; 0.25 2.25] is unique.
            A=build_magbm(p.mean,p.covariance; Δt=dt).A;
            istril(A) && all(diag(A) .> 0) && isapprox(A,[1.0 0.0;0.25 sqrt(2.1875)]; atol=1e-12)
        end),
        (name="Model: another observation time step", evaluate=() -> begin
            m=build_magbm(p.mean,p.covariance; Δt=0.1);
            isapprox(m.A*m.A',[0.4 0.1;0.1 0.9]; atol=1e-12) &&
                isapprox(m.μ,[0.3,0.25]; atol=1e-12)
        end),
        (name="Model: one stock", evaluate=() -> begin
            m=build_magbm([0.2],reshape([8.0],1,1); Δt=0.125);
            isapprox(m.μ,[0.7]; atol=1e-12) && isapprox(m.A*m.A',ones(1,1); atol=1e-12)
        end),
        (name="Model: preserve negative correlations and input parameters", evaluate=() -> begin
            C=[4. -1.;-1. 9.]; r=(mean=[0.1,-0.2],covariance=C);
            m=build_magbm(r.mean,r.covariance; Δt=dt);
            isapprox(m.A*m.A',[1. -0.25;-0.25 2.25]; atol=1e-12) && r.covariance==[4. -1.;-1. 9.]
        end),
        (name="Probability: equality is not success", evaluate=() ->
            benchmark_probability([100.0],100.0,0.0,2,dt)==0.0),
        (name="Probability: count strict successes", evaluate=() ->
            benchmark_probability([99.,100.,101.,102.],100.0,0.0,2,dt)==0.5),
        (name="Probability: retain zero and negative wealth in denominator", evaluate=() ->
            benchmark_probability([-20.,0.,110.],100.0,0.0,1,dt)==1/3),
        (name="Probability: all and no successes", evaluate=() ->
            benchmark_probability([101.,102.],100.0,0.0,1,dt)==1.0 &&
            benchmark_probability([99.,100.],100.0,0.0,1,dt)==0.0),
        (name="Probability: convert holding intervals to years", evaluate=() ->
            benchmark_probability([105.,109.,110.],100.0,0.1,2,dt)==2/3),
        (name="Probability: paired fees cannot increase success", evaluate=() -> begin
            gross=[90.,101.,103.,110.]; net=gross.-[0.,2.,4.,0.];
            p0=benchmark_probability(gross,100.0,0.0,126,1/252);
            p3=benchmark_probability(net,100.0,0.0,126,1/252);
            p0==0.75 && p3==0.25 && gross==[90.,101.,103.,110.]
        end),
    ];
    return [standard_public_checks(); extra];
end

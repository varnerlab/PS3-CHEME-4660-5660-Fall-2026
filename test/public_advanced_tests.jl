"""Return the twenty shared checks and twelve Advanced checks using isolated inputs."""
function advanced_public_checks()::Vector{NamedTuple}
    p = (mean=[0.1,-0.2],covariance=[4.0 1.0;1.0 9.0]);
    dt = 0.25;
    target = 100.0*exp(0.05*2*dt);
    extra = [
        (name="Model: diffusion covariance scaling", evaluate=() ->
            isapprox(build_magbm(p,dt).diffusion,[1.0 0.25;0.25 2.25]; atol=1e-12)),
        (name="Model: price drift includes the half-variance correction", evaluate=() ->
            isapprox(build_magbm(p,dt).drift,[0.6,0.925]; atol=1e-12)),
        (name="Model: factor reconstructs diffusion covariance", evaluate=() -> begin
            A=build_magbm(p,dt).factor;
            isapprox(A*A',[1.0 0.25;0.25 2.25]; atol=1e-12)
        end),
        (name="Model: another observation time step", evaluate=() -> begin
            m=build_magbm(p,0.1);
            isapprox(m.diffusion,[0.4 0.1;0.1 0.9]; atol=1e-12) &&
                isapprox(m.drift,[0.3,0.25]; atol=1e-12)
        end),
        (name="Model: one stock", evaluate=() -> begin
            m=build_magbm((mean=[0.2],covariance=reshape([8.0],1,1)),0.125);
            isapprox(m.drift,[0.7]; atol=1e-12) && isapprox(m.factor*m.factor',ones(1,1); atol=1e-12)
        end),
        (name="Model: preserve negative correlations and input parameters", evaluate=() -> begin
            C=[4. -1.;-1. 9.]; r=(mean=[0.1,-0.2],covariance=C);
            m=build_magbm(r,dt);
            isapprox(m.factor*m.factor',[1. -0.25;-0.25 2.25]; atol=1e-12) && r.covariance==[4. -1.;-1. 9.]
        end),
        (name="Probability: equality is not success", evaluate=() ->
            benchmark_probability([target],100.0,0.05,2,dt)==0.0),
        (name="Probability: count strict successes", evaluate=() ->
            benchmark_probability([target-1,target,target+1,nextfloat(target)],100.0,0.05,2,dt)==0.5),
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

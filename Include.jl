# Load the selected track and its helpers from paths relative to this file -
const _ROOT = @__DIR__;
include(joinpath(_ROOT, "reports", "Terminal.jl"));
include(joinpath(_ROOT, "test", "Rubric.jl"));

const _USE_SOLUTION = "--solution" in ARGS; # local instructor validation only
const _OUTPUT_ROOT = _USE_SOLUTION ? joinpath(_ROOT, "instructor", "output") : _ROOT;
all(==("--solution"), ARGS) || throw(ArgumentError("The only optional argument is --solution."));
const _TRACK = String(strip(read(joinpath(_ROOT, "TRACK.txt"), String)));
_TRACK in ("standard", "advanced") || throw(ArgumentError("TRACK.txt must contain standard or advanced."));
const _SOURCE_PATH = joinpath(_ROOT, _USE_SOLUTION ? "instructor/reference" : "src", titlecase(_TRACK)*".jl");

import VLQuantitativeFinancePackage # course price-path sampler
using DataFrames # ticker-keyed price tables, as in the course notebooks
using VLQuantitativeFinancePackage: build, solve, log_growth_matrix,
    MyMultipleAssetGeometricBrownianMotionEquityModel,
    MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem # course long-only portfolio solver
using LinearAlgebra # covariance factors, matrix products, and linear solves
using Statistics # sample means, covariance, standard deviation, and correlation
using Random # repeatable stock-price simulations
using Dates # dates and estimation-window selection
using Printf # readable wealth, risk, and probability tables

include(joinpath(_ROOT, "src", "Support.jl"));
include(joinpath(_ROOT, "reports", "Finance.jl"));
include(joinpath(_ROOT, "test", "public_standard_tests.jl"));
include(joinpath(_ROOT, "test", "public_advanced_tests.jl"));
const _PUBLIC_CHECKS = _TRACK == "standard" ? standard_public_checks() : advanced_public_checks();

# Load optional student helpers before the selected source file -
# Store helper files under src/. Document each helper's purpose, inputs, and output.
# include(joinpath(_ROOT, "src", "MyHelperFunctions.jl"));
isfile(_SOURCE_PATH) || throw(ArgumentError("Selected source file is missing: $(_SOURCE_PATH)"));
include(_SOURCE_PATH);

# CHEME 5660 Problem Set 3

This is the Fall 2026 student release of PS3: *Does More Recent Data Lead to a Better Portfolio?*

Download **Source code (zip)** below, extract it, and begin with `README.md`. The release contains the starter code for both tracks, the 2014–2025 and 2026 price files for eight stocks, the mathematical companion, public tests, response files, submission checker, comparison report, and grading rubric. The reference solutions are not included.

Choose Standard or Advanced in `TRACK.txt`.
* __Standard__ estimates growth rates from two windows, 2014–2025 and 2025 alone, chooses a long-only and a shorts-allowed minimum-variance portfolio for each, and evaluates all four over 126 trading days in 2026, with and without borrowing fees.
* __Advanced__ adds a multiple-asset geometric Brownian motion (MAGBM) model for each window and estimates each portfolio's probability of beating a 5% benchmark.

Write your prediction in Question 1a before you view any allocation results.

The assignment was built and tested with **Julia 1.12.7**; follow the package setup instructions in the README. Run `check_submission.jl` to check your code and print the comparison report; it prints the submission instructions for building your ZIP.

The initial submission is due on Canvas by **11:59 PM ET on Sunday, October 18, 2026**. Eligible revisions are accepted until **December 19, 2026 at 11:59 PM ET**. An accepted Advanced score of 4 earns one Magic Point.

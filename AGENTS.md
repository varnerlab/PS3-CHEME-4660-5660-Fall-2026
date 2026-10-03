# PS3 assignment conventions

- Keep the README free of equations, LaTeX commands, and math delimiters.
  Explain the task in plain language and link to the mathematical companion.
- Organize the assignment around its central portfolio question. Each study
  should state what students compare, why it matters, and how it leads to
  the next study. Preserve the agreed Standard and Advanced scope.
- Put mathematical details in `docs/PS3-Mathematical-Companion.tex` and its
  compiled PDF, using the supplied course lecture styling. Render and inspect
  changed slides before delivery. Rebuild with `make -C docs`.
- Keep response templates aligned with the studies. Keep instructor solutions
  and numerical results out of the student release.

- Compare two estimation windows: all 2014–2025 prices and 2025 prices alone.
  Select price rows before computing growth rates. Reserve 2026 for evaluation,
  with December 31, 2025 as day 0 and one 126-trading-day holding period.
- Compare long-only and shorts-allowed GMV for each window. Supply equal weight
  as one historical reference. Use only 0% and 3% borrowing-rate scenarios.
- Keep four Standard and six Advanced student functions, reused across windows.
  Supply simulation machinery and report tables. Require one prediction and
  three interpretations per track, without table transcription.

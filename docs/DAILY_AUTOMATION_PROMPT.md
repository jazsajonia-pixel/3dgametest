# Daily Development Task Prompt — THE HUM

## Short instruction to paste into Manus Task Scheduler

Copy this block into a daily scheduled task. Choose the daily run time and timezone in the Scheduler:

```text
Continue development of the Godot 4.7.2 mobile horror game THE HUM in GitHub repository jazsajonia-pixel/3dgametest. Read and follow docs/DAILY_AUTOMATION_PROMPT.md and docs/DEVELOPMENT_ROADMAP.md in the repository. First inspect the latest progress ledger, git history, working tree, and tests so you do not repeat previous work. Implement one useful, distinct unfinished improvement from the roadmap; search and verify free, game-usable 3D assets and exact licenses before importing any. Test before and after changes; fix errors and rerun relevant tests. Update the roadmap ledger. Commit and push only when checks pass. End by reporting what changed, files, asset sources/licenses, exact tests/results, commit, blockers, and the next non-duplicate task. Do not claim a test or device/export check that was not actually run; never pay for assets or services.
```

## Full prompt for the scheduled run

> You are continuing development of the user’s Godot game. Work autonomously inside the connected GitHub repository `jazsajonia-pixel/3dgametest`. The goal is to turn **THE HUM: Archive of the Drowned** into a complete, visually distinctive, mobile-first 3D horror game. Do real repository work—not just planning or recommendations. Continue from the current code and maintain the project’s Godot 4.7.2 compatibility.

### 1. Re-establish context before editing

1. Clone the selected repository if it is not already present, then inspect the current branch, working tree, recent commits, README, project settings, tests, and relevant scripts/scenes.
2. Read `docs/DEVELOPMENT_ROADMAP.md` and this file. Read the latest entry in the roadmap’s **Progress ledger** before selecting a task.
3. Run the available baseline Godot import/editor check and gameplay smoke test before edits. Record failures that existed beforehand. Do not assume the previous run’s test result still applies to the current checkout.
4. Preserve unrelated user changes. Do not discard, overwrite, or force-push work you did not create. Never expose credentials or private config values.

### 2. Pick new work without repeating old work

Choose **one cohesive, useful improvement** from the highest-priority incomplete roadmap phase. Fix directly related bugs in the same run. Prefer a blocking bug, regression, incomplete acceptance criterion, or the `Next distinct focus` recorded in the ledger.

Before implementing, compare the candidate with the recent commit history and progress ledger. Do not redo a completed item under a different name. If the expected outcome is already present, verify it briefly and choose the next distinct unfinished item. Do not create superficial changes just to produce a commit. If no safe, meaningful task is available, report why and leave the code unchanged.

### 3. Search and handle 3D assets responsibly

When the selected work needs an external asset, search the asset’s **official source page** and confirm the exact file’s license before downloading or importing it. Relevant starting sources are recorded in the roadmap: Quaternius’ Modular Sci-Fi MEGAKIT, Poly Haven materials/models, and ambientCG materials. Recheck current pages and asset-specific terms at the time of use.

- Prefer CC0 or another clearly documented license that permits use in a game, including commercial distribution where applicable. Confirm whether attribution is required.
- Do not use a marketplace listing, search-result snippet, or the license of a neighboring asset as proof for the chosen file.
- Do not buy assets, select paid pack tiers, start trials, subscribe, or require a new paid connector. If the only suitable asset is paid or its license is unclear, leave it out and report the blocker.
- Record every imported third-party item in a repository asset/license manifest with the exact asset name, source URL, license, date obtained, required credit, and any modification. Preserve license/credit files where applicable.
- Prefer compact glTF/texture options that import correctly in Godot. Start with 1K/2K textures for mobile unless a higher resolution has a measured benefit. Do not bulk-download whole libraries or commit unnecessary cache/export files.
- Maintain one coherent, grounded horror art direction. Do not mix stylized low-poly assets into the realistic archive without checking the in-game result first. If no suitable licensed asset is found, improve the existing procedural art or build a simple original asset instead.

### 4. Implement, test, fix, and test again

Make the smallest implementation that fulfills the chosen improvement while preserving the mobile control path and existing echo-based gameplay. Add or update a regression test for bugs and important new behavior. Keep visuals readable on a phone and keep performance constraints in view.

Run the tests available in the current environment. The existing Godot commands are:

```bash
godot --headless --editor --path . --quit
godot --headless --audio-driver Dummy --path . --script res://tests/gameplay_smoke.gd
git diff --check
```

For visual or HUD work, run the screenshot harness when Xvfb is available and inspect the resulting image:

```bash
xvfb-run -a -s '-screen 0 1600x900x24' godot --audio-driver Dummy --path . --script res://tests/capture_preview.gd
```

1. If any test exposes an error, identify its cause, fix it, and rerun the failing test plus the relevant regression checks. Continue until the relevant checks pass or a real blocker prevents it.
2. Review logs for script/parser errors, invalid Godot API calls, collision problems, resource leaks caused by the change, and failing assertions. Do not treat an exit code alone as proof of a clean run.
3. If Android templates, SDKs, a physical device, network access, or a required licensed asset are unavailable, say so plainly. Do not claim an export or device test that was not performed.
4. Do not push a known-broken change. If a failure cannot be fixed safely, retain the exact error and reproduction details in the report and roadmap ledger; avoid merging or pushing the broken implementation.

### 5. Update state and deliver a complete report

After successful validation:

- Update the relevant phase/status and append one dated entry to the roadmap’s **Progress ledger**. Include what changed, exact validation, commit ID, and the next distinct task. Keep the ledger short and never erase prior entries.
- Run `git diff --check`, inspect the final diff, commit the coherent change, and push it to the selected repository’s `main` branch only if the repository is clean enough to do so and the relevant tests pass. Never force-push.
- At the end of **every** run, report a concise but complete summary containing:
  1. The improvement completed and why it matters.
  2. Files changed.
  3. 3D assets downloaded or evaluated, with source URLs, exact licenses, credits, and sizes where relevant. Say explicitly if no asset was imported.
  4. Tests run and their exact pass/fail results. Include any checks that could not be run.
  5. Commit hash and repository link if a push succeeded.
  6. Errors fixed, remaining blockers, and the next non-duplicate task.

Be factual and specific. A partially completed or blocked task must be reported as such. Never say “all tests passed” unless the logs support it.

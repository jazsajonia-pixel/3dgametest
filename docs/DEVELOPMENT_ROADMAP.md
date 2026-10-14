# THE HUM — Full Development Roadmap

## Vision

Grow **THE HUM: Archive of the Drowned** from its current playable vertical slice into a polished, mobile-first 3D horror game for Godot 4.7.2. The desired look is grounded and believable: a damp acoustic research archive with convincing concrete, corroded metal, pooled water, practical lighting, readable silhouettes, and character animation that communicates weight and intent. Horror should come from information and consequences—not from repeating loud jump scares.

The distinguishing mechanic is already in the prototype: the player deliberately emits an echolocation pulse. It reveals nearby memories and the Listener, but gives the creature the pulse’s origin to investigate. The player can move away while it follows that false lead. Preserve this identity while making the environment, enemy, story, controls, and moment-to-moment choices deeper.

The project targets **Godot 4.7.2** and mobile devices. Keep the existing GL Compatibility renderer and mobile controls unless testing demonstrates a better option. Prefer accessible, low-cost development and legally clear assets. A task may introduce one coherent increment; do not try to implement this whole roadmap in one session.

## Current baseline

The repository already contains a playable procedural corridor, first-person movement, keyboard/mouse support, a mobile virtual stick and touch-look, ECHO/LAMP/USE/RUN/CROUCH buttons, a touch-friendly restart button, the Listener, pulse-revealed fragments, recharge stations, an exit, generated ambient/pulse/heartbeat audio, and Godot smoke tests. The mobile HUD and core gameplay loop were tested in Godot 4.7.2. The scene and most of its art remain GDScript-built; **one license-verified third-party 3D asset is now imported**.

Use this as a baseline, not as a reason to recreate systems that already work. At the start of each development run, inspect the repository, recent commits, tests, and progress ledger below. Update this document as work is completed.

## Phased development

### Phase 0 — Establish a repeatable baseline

**Goal:** Every later change can be checked against a known working build.

- Run a Godot 4.7.2 editor/import check and the existing gameplay smoke test before changing code.
- Record any pre-existing errors separately from errors introduced by the current task.
- Add or improve regression tests when a bug is fixed or a gameplay system changes.
- Keep tests deterministic. Use dummy audio or headless-safe settings where appropriate, and clean up active audio before test-process shutdown.

**Done when:** A fresh checkout opens in the target engine; baseline tests have documented results; known blockers are listed rather than silently ignored.

### Phase 1 — Project structure and production workflow

**Goal:** Make the growing game maintainable without breaking the current loop.

- Gradually separate the all-in-one runtime script into clear components: player, input, creature, level/interactables, audio, and HUD. Refactor in small steps with tests after each step.
- Move adjustable values into named configuration resources or well-documented constants. Avoid creating an elaborate framework before it solves a real problem.
- Give scenes, resources, imported assets, scripts, and tests consistent names and folders. Keep generated `.godot` cache and editor-only files out of Git.
- Add a short asset/license manifest if any third-party file is imported.

**Done when:** A new contributor can identify the main scene, major gameplay systems, asset origin, and test commands from the repository without reverse-engineering everything.

### Phase 2 — Asset selection and legal intake

**Goal:** Replace selected procedural placeholders with visually stronger assets while keeping one coherent art direction and a mobile-appropriate footprint.

Research individual assets before downloading. Prefer official source pages with explicit **CC0** or another clearly commercial-game-compatible license. Record the exact asset name, source page, license, retrieval date, modifications, and any required credit. Do not infer the license from a search result, marketplace label, or another asset in the same collection. Do not download paid editions, start trials, make purchases, or bundle files whose rights are unclear.

Imported example and verified starting points for continued asset evaluation:

- **Already imported — Poly Haven Modular Industrial Pipes 01:** a 12K-triangle, 2 m industrial prop set with a 1K glTF variant and PBR maps. It is CC0; the project uses it at 75% scale in the second bay and records provenance in `assets/third_party/ASSET_SOURCES.md`. [7]
- **Quaternius Modular Sci-Fi MEGAKIT:** a 277-model modular environment pack with glTF/FBX/OBJ/Blend options and a CC0 license. Its source version includes Godot implementation details, while the page says only part of the collection is free. Use only an explicitly free download. Inspect the stylized look before using it; it may be better for selected doors, panels, or blockout pieces than for the game’s grounded concrete surfaces. [1]
- **Trial imported (2026-10-12) — Poly Haven Concrete Wall 003:** a worn, painted concrete PBR material. Four 1K JPG maps (diffuse, OpenGL normal, roughness, and ambient occlusion) are used on only the second service-bay back wall; the other two bay backs retain procedural concrete for comparison. The in-engine screenshot captures the trial under the flashlight. No physical-device performance check has been run. CC0. [2] [3]
- **ambientCG Concrete 047 A:** a concrete PBR material captured through surface photogrammetry. The asset page offers several resolutions and states that ambientCG assets are CC0. Prefer a size appropriate to the target device; the listed 4K JPG archive is substantially larger than the 1K option. [4]
- **Poly Haven Industrial & Infrastructure models:** a useful category to search for pipes, fixtures, machinery, and other environmental props. The category page is a search pool, not proof that a specific model fits. Verify each chosen model page, file format, license, scale, and mobile performance before importing. Poly Haven’s license page says its HDRIs, textures, and 3D models are CC0. [5] [6]

Modular Industrial Pipes 01 and Concrete Wall 003 are now imported. The concrete is intentionally contained to one wall pending further art-direction comparison. Other listed material and model candidates are research leads, not imports. Re-check each source and exact file before further use. If a candidate clashes with the intended visual style, search for a better match or keep the existing custom geometry. Avoid importing a whole pack when only one or two pieces are useful.

**Done when:** Each imported file has a traceable origin and license; the art direction is consistent; Godot imports the files without errors; the game still runs on the intended mobile renderer.

### Phase 3 — Believable archive environments

**Goal:** Evolve the single corridor into a distinctive, navigable place.

- Establish a small material palette: aged concrete, coated steel, rust, painted markings, glass, standing water, and emergency lighting. Keep roughness, normal, and albedo maps physically plausible rather than adding detail uniformly.
- Break up repeated geometry with structural variation, wall labels, service access, damaged fixtures, acoustic baffles, cables, debris, and waterlines. Use authored sightlines and silhouettes to guide the player.
- Create distinct spaces such as a listening laboratory, flooded service bay, records vault, and exit machinery room. Give each location a gameplay or story purpose.
- Improve wet-surface response, decals, contact shadows, light falloff, fog, and carefully controlled reflections. Keep the mood readable enough for mobile screens.
- Add collision that matches visible geometry and clear navigation around clutter.

**Done when:** The player can tell areas apart, understand where to go without constant HUD arrows, and move through the route without collision snags. New visuals improve the horror mood without obscuring the enemy, interactables, or controls.

### Phase 4 — Player, creature, and animation

**Goal:** Give movement and the Listener convincing physical presence.

- Improve first-person camera motion with a restrained walk/run gait, crouch height, stopping inertia, and surface-specific footstep feedback. Keep camera movement comfortable and provide reduced-motion settings.
- Evaluate a rigged, game-ready player/creature model or author a custom one. A suitable model should have clear joints, manageable materials, correct scale, and animation rights suitable for this game.
- Use a Skeleton3D/AnimationPlayer or another Godot-supported animation workflow where appropriate. Blend idle, approach, investigate, recoil, search, attack, and retreat states; avoid abrupt visible snaps.
- Make the Listener’s posture, head/eye tracking, limb drag, breath, and reaction to light/echo signal intent. Preserve its rule of investigating the last echo origin.
- Add appropriate low-detail meshes or LODs for mobile if the chosen model requires them.

**Done when:** Animations transition without visible pops, core states remain understandable in darkness, and the creature’s reaction supports rather than contradicts the echo mechanic. Any downloaded model/animation has a recorded license.

### Phase 5 — Expand the signature mechanics

**Goal:** Make each pulse a meaningful decision and create counterplay beyond hiding.

Build from the current system instead of replacing it. Surface-aware dry/wet footfalls now provide a first sound-based movement signal, and crouching reduces both footfall cadence and hearing distance. Possible next experiments include acoustic surfaces changing pulse reach, valves or machinery that create decoy sounds, limited-use sound dampening, a creature that infers routes from repeated pulses, and machinery that briefly masks the player’s sound. Select only mechanics that can be taught clearly and tested.

- Give the player more than one viable response when the Listener investigates an echo.
- Make acoustic differences visible and learnable without an encyclopedia.
- Ensure the flashlight remains a constrained tool, not a permanent enemy off-switch.
- Tune difficulty around fair warning, recoverability, and mobile control precision.
- Add tests for pulse placement, enemy target selection, cooldowns, resource consumption, and edge cases.

**Done when:** Players can explain why the creature moved, identify at least two useful strategies, and finish a test encounter without relying on random enemy behavior.

### Phase 6 — Level flow and environmental story

**Goal:** Turn a mechanically sound corridor into a complete short horror experience.

- Design a clear opening, escalation, midpoint reversal, climax, and ending.
- Use recovered memory fragments to reveal an understandable, emotionally specific story through short audio logs, documents, environmental clues, or interactive echoes.
- Create route choices, limited loops, and meaningful safe stations. Do not make every objective a simple corridor pickup.
- **Starter lesson implemented:** the opening uses dry concrete and the nearby right-hand puddle to teach footstep noise and crouch counterplay before the first ECHO wakes the Listener. Continue expanding the lesson into fair echo-risk/objective onboarding without forcing a scare.
- Add at least one ending or state variation that follows from player choices if scope allows.

**Done when:** A new player can start, learn the controls, understand the objective, experience escalation, and reach a deliberate ending without developer instructions.

### Phase 7 — Sound, atmosphere, and feedback

**Goal:** Make acoustic horror both effective and accessible.

- Refine the original hum, pulse, and heartbeat. Add spatialized machinery, water, creaks, distant impacts, creature locomotion, and zone-specific ambience.
- Separate UI, ambience, environment, and creature volumes. Keep loud transient events from causing harsh jumps in playback level.
- Give mobile actions immediate visual, sound, or haptic feedback where supported; never rely on vibration alone.
- Add subtitles/captions for essential spoken or directional audio and a visual cue option for players who cannot hear the signal.
- Keep effects configurable and avoid unnecessarily repetitive loops.

**Done when:** Critical threats and objectives are understandable with sound enabled and with accessibility cues enabled; volume settings persist as intended.

### Phase 8 — Mobile UX and accessibility

**Goal:** Make the game comfortable and legible on real touch screens.

- Test multiple landscape aspect ratios and safe areas. Keep controls separated, thumb-reachable, and large enough; provide adjustable scale/opacity and left-handed layout if practical.
- Add a pause menu, restart confirmation if needed, settings, sensitivity, audio sliders, quality options, and a clear exit flow.
- Add subtitle size, contrast, reduced motion, screen shake, aim/look sensitivity, and key remapping options where feasible.
- Check touch handling for simultaneous movement and look, button presses while moving, multitouch interruption, focus loss, and return from pause.
- Keep desktop keyboard/mouse support as a test path; do not let it break mobile touch.

**Done when:** A tester can complete the game on a touch device, with no hidden keyboard-only requirement, blocked button, unsafe overlap, or unreadable critical text.

### Phase 9 — Performance and device testing

**Goal:** Make visuals sustainable on target devices.

- Measure frame-time and memory on a real Android device or a documented emulator when available. Do not report a device test that was not run.
- Audit texture sizes, mesh/material counts, draw calls, shadow-casting lights, transparency, particle counts, physics bodies, and audio memory.
- Use LODs, culling, efficient material reuse, baked/static lighting where it helps, and configurable quality tiers. Preserve the dark mood at low quality.
- Test cold start, scene transition, pause/resume, touch interruption, and longer play sessions.
- Add Android export presets and validate them only when the required templates and SDK are installed. Document unavailable tooling rather than claiming a successful package.

**Done when:** Performance targets are measured and recorded on the available hardware; the game remains playable under a low-quality preset; export results and known device limitations are explicit.

### Phase 10 — Content, polish, and release readiness

**Goal:** Make the short game feel complete and deliverable.

- Add a title screen, control guide, pause/settings screen, credits/license page, ending screen, and save/checkpoint behavior if appropriate.
- Fix progression softlocks, restart bugs, audio lifetime issues, missing-resource warnings, and localization/layout problems.
- Check that third-party assets appear in the credits or license manifest when required. Retain source links even for CC0 materials as provenance.
- Capture current in-engine screenshots and short gameplay footage only after verifying the current build.
- Prepare a release checklist for project files, Android export, version number, performance notes, credits, and known issues.

**Done when:** The repository can be opened from a clean checkout, the main loop has an ending, the license record is complete, and all stated platform/export claims have been verified.

## Definition of done for each daily increment

A change is complete only when it solves one specific, non-duplicate task; fits the project’s horror and mobile direction; includes a relevant regression test when practical; has been run in Godot 4.7.2 (or its limitation is explicitly documented); and updates the progress ledger below. For visual work, capture and inspect an actual Godot-rendered preview. For failed checks, fix the cause and rerun. Do not mark an unresolved failure as passed.

## Progress ledger

Keep the latest entry at the bottom. Each scheduled run must read this history before choosing work, avoid repeating completed tasks, and append a concise result with date, completed change, validation, commit, and next distinct priority. Update phase status only when its acceptance criteria have evidence.

| Date | Change completed | Validation | Commit | Next distinct focus |
|---|---|---|---|---|
| 2026-10-10 | Added mobile virtual stick, touch-look, action/toggle buttons, restart UI, touch tests, and safe-area layout. | Godot 4.7.2 editor import; gameplay smoke test; rendered preview. | `3101175` | Asset/art-direction audit and a first license-cleared PBR/industrial asset import. |
| 2026-10-11 | Imported Poly Haven Modular Industrial Pipes 01 at 1K and integrated the CC0 assembly, collision proxy, and source manifest in the second bay. | Godot 4.7.2 editor import; mobile/gameplay smoke test with 8-mesh/PBR/collision assertions; Xvfb capture inspected; `git diff --check`. | `5819755` | Trial 1K Concrete Wall 003 on one contained wall section; compare it with the procedural concrete before broader use. |
| 2026-10-12 | Trialed Poly Haven Concrete Wall 003’s 1K diffuse, OpenGL normal, roughness, and AO maps on one bay back wall; kept two other bay backs procedural and darkened albedo after the first preview. | Baseline and post-change Godot 4.7.2 editor import; gameplay/material smoke; Xvfb 1600×900 preview captured and inspected; all four file checksums/byte counts verified; `git diff --check`. | `7442ce0` | Add deterministic Listener last-echo target/retarget tests, then fix one pursuit edge case without changing the signature mechanic. |
| 2026-10-13 | Added deterministic first-echo capture, retarget, large-delta arrival/no-overshoot, and close-range flashlight-recoil tests. Fixed recoil at an arrived lure by steering away from the player, using the camera-to-core beam direction, preventing a catch during recoil, and animating the recoil state. | Baseline and post-change Godot 4.7.2 editor import; gameplay smoke test passed with target, arrival, and recoil assertions; `git diff --check`. No asset was needed or imported. | `2ff660f` | Add surface-aware footstep sound/noise so wet-floor movement and crouching create learnable, testable acoustic trade-offs. |
| 2026-10-14 | Added original spatialized concrete/splash footsteps, puddle-zone sampling, stance/speed-dependent cadence and hearing radius, and footstep-driven Listener retargeting with a throttled alert cue. | Baseline and post-change Godot 4.7.2 editor import; gameplay smoke test covers wet/dry detection, loudness/cadence ordering, grounded timing, and heard/unheard target updates; regenerated WAV metadata checked; `git diff --check`. No third-party asset was imported. | `fe0d1d8` | Add a small onboarding encounter that demonstrates dry/wet acoustics and safe crouch counterplay without forcing a jump scare. |
| 2026-10-15 | Added a safe opening tutorial using the real start-area puddle: explains dry steps, louder standing splashes, and crouched wet-step counterplay; the Listener remains dormant until ECHO. Updated the README and captured an opening HUD screenshot. | Baseline checkout: Godot 4.7.2 editor import and gameplay smoke passed. Post-change: editor import and smoke passed, including both tutorial step orders and asleep-Listener assertions; Xvfb 1600×900 captured and inspected onboarding/archive screenshots; `git diff --check`. No third-party assets were imported. | Pending | Add a concise, optional story reveal to the first recovered memory fragment and test its mobile readability. |

## References

[1]: https://quaternius.com/packs/modularscifimegakit.html "Modular Sci-Fi MEGAKIT — Quaternius"
[2]: https://polyhaven.com/license "Poly Haven Asset License"
[3]: https://polyhaven.com/a/concrete_wall_003 "Concrete Wall 003 — Poly Haven"
[4]: https://ambientcg.com/view?id=Concrete047A "Concrete 047 A — ambientCG"
[5]: https://polyhaven.com/models/industrial-infrastructure "Industrial & Infrastructure Models — Poly Haven"
[6]: https://polyhaven.com/models "Poly Haven 3D Models"
[7]: https://polyhaven.com/a/modular_industrial_pipes_01 "Modular Industrial Pipes 01 — Poly Haven"

# THE HUM — Full Development Roadmap

## Vision

Grow **THE HUM: Archive of the Drowned** from its current playable vertical slice into a polished, mobile-first 3D horror game for Godot 4.7.2. The desired look is grounded and believable: a damp acoustic research archive with convincing concrete, corroded metal, pooled water, practical lighting, readable silhouettes, and character animation that communicates weight and intent. Horror should come from information and consequences—not from repeating loud jump scares.

The distinguishing mechanic is already in the prototype: the player deliberately emits an echolocation pulse. It reveals nearby memories and the Listener, but gives the creature the pulse’s origin to investigate. The player can move away while it follows that false lead. Preserve this identity while making the environment, enemy, story, controls, and moment-to-moment choices deeper.

The project targets **Godot 4.7.2** and mobile devices. Keep the existing GL Compatibility renderer and mobile controls unless testing demonstrates a better option. Prefer accessible, low-cost development and legally clear assets. A task may introduce one coherent increment; do not try to implement this whole roadmap in one session.

## Current baseline

The repository already contains a playable procedural corridor, first-person movement, keyboard/mouse support, a mobile virtual stick and touch-look, ECHO/LAMP/USE/RUN/CROUCH buttons, a touch-friendly restart button, the Listener, pulse-revealed fragments, recharge stations, an exit, generated ambient/pulse/heartbeat audio, and a Godot smoke-test script. The mobile HUD and core gameplay loop were tested in Godot 4.7.2. The scene and much of its art are currently built in GDScript; **no third-party 3D assets have been imported yet**.

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

Verified starting points for later asset evaluation:

- **Quaternius Modular Sci-Fi MEGAKIT:** a 277-model modular environment pack with glTF/FBX/OBJ/Blend options and a CC0 license. Its source version includes Godot implementation details, while the page says only part of the collection is free. Use only an explicitly free download. Inspect the stylized look before using it; it may be better for selected doors, panels, or blockout pieces than for the game’s grounded concrete surfaces. [1]
- **Poly Haven Concrete Wall 003:** a worn, painted concrete PBR material with diffuse, ambient-occlusion, roughness, and normal-map options. The page lists resolutions from 1K through 16K and CC0. Start at 1K or 2K for mobile; only use larger maps after measuring the quality and memory cost. [2] [3]
- **ambientCG Concrete 047 A:** a concrete PBR material captured through surface photogrammetry. The asset page offers several resolutions and states that ambientCG assets are CC0. Prefer a size appropriate to the target device; the listed 4K JPG archive is substantially larger than the 1K option. [4]
- **Poly Haven Industrial & Infrastructure models:** a useful category to search for pipes, fixtures, machinery, and other environmental props. The category page is a search pool, not proof that a specific model fits. Verify each chosen model page, file format, license, scale, and mobile performance before importing. Poly Haven’s license page says its HDRIs, textures, and 3D models are CC0. [5] [6]

These are researched candidates, **not assets already present in the project**. Re-check each source and exact file before use. If a candidate clashes with the intended visual style, search for a better match or keep the existing custom geometry. Avoid importing a whole pack when only one or two pieces are useful.

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

Build from the current system instead of replacing it. Possible experiments include water depth changing footstep noise, acoustic surfaces changing pulse reach, valves or machinery that create decoy sounds, limited-use sound dampening, a creature that infers routes from repeated pulses, and machinery that briefly masks the player’s sound. Select only mechanics that can be taught clearly and tested.

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
- Include an onboarding encounter that teaches the echo risk without punishing first-time players unfairly.
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

## References

[1]: https://quaternius.com/packs/modularscifimegakit.html "Modular Sci-Fi MEGAKIT — Quaternius"
[2]: https://polyhaven.com/license "Poly Haven Asset License"
[3]: https://polyhaven.com/a/concrete_wall_003 "Concrete Wall 003 — Poly Haven"
[4]: https://ambientcg.com/view?id=Concrete047A "Concrete 047 A — ambientCG"
[5]: https://polyhaven.com/models/industrial-infrastructure "Industrial & Infrastructure Models — Poly Haven"
[6]: https://polyhaven.com/models "Poly Haven 3D Models"

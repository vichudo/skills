---
name: frontier-threejs
description: 'Build any idea (game, product viz, generative art, world, data sculpture, landing-page hero, tool) as a frontier real-time browser 3D experience on Three.js r186+ WebGPURenderer, TSL node materials, GPU compute, and coupled systems: time-of-day, shared wind, instancing, atmosphere, GI, temporal post. Use when the user asks for anything 3D, Three.js, WebGPU, React Three Fiber, shaders, or a scene, or wants a visual idea to look as impressive as current browser tech allows.'
argument-hint: "[the idea]"
---

# frontier-threejs

Ship the idea at the **current production ceiling** of browser 3D, not at tutorial level. The bar is the recent wave of AI-built Three.js demos: hills with long crawling shadows, oceans with foam and wakes, forests that move in one shared wind, and light that changes over the course of a day.

This skill sets the level to aim for. It is not a fixed recipe. Every idea gets its own art direction, and the systems below are how you reach that level for it.

## Ground truth over memory

Three.js changes every ~2 months and model memory lags behind. **Before writing code, check the version you are actually running on** (`node_modules/three/package.json`, or `npm view three version`). Then confirm every addon import exists in `node_modules/three/examples/jsm/`. The closest official `webgpu_*` example is the canonical usage. The verified r186 inventory, with import paths, is in [TOOLBOX.md](TOOLBOX.md). Traps models commonly fall into:

- `PostProcessing` was renamed **`RenderPipeline`** in r183, so write `renderPipeline.outputNode = …`.
- `SunLight` (cascaded shadows) only works after `renderer.library.addLight( SunLightNode, SunLight )`.
- `godrays()` supports only Directional/Point lights, not `SunLight`.
- `WaterMesh` is still a normal-map water. A hero ocean needs FFT compute (see TOOLBOX).
- Import from `three/webgpu` and `three/tsl`. Never mix those with the `three` WebGL build in one scene.

## Stack

- **Three.js r186+ `WebGPURenderer`**. Its built-in WebGL2 backend is the fallback, and only that. Check which WebGPU-only features the chosen techniques depend on (VXGI, some compute paths) and degrade them when the backend is WebGL.
- **TSL only** for materials and effects: `MeshStandardNodeMaterial` / `MeshPhysicalNodeMaterial` / `MeshSSSNodeMaterial` with `colorNode`, `positionNode`, `normalNode`, `emissiveNode`. Never `ShaderMaterial`, `RawShaderMaterial`, or `onBeforeCompile`.
- **GPU compute** (`instancedArray` + `Fn().compute(n)`) for anything that would otherwise be a per-frame CPU loop: particles, flocking, cloth, instance transforms, ocean spectra, grass culling.
- **App shell:** use raw Three.js + Vite for a standalone demo or custom engine. Use React Three Fiber 9 (latest stable; 10 is alpha) + drei when the 3D sits inside a product UI, with the async WebGPU `gl` factory (see PATTERNS.md).

## Systems, not props

Build the scene as coupled systems that share state. One variable should change many things at once.

1. **Time-of-day clock.** A single `t` drives the sun direction, sun color, SkyMesh sun position and clouds, the fog color, the environment (a PMREM of the sky, regenerated throttled), exposure, and a `night` uniform that turns emissives on. Use a locked HDRI only for interiors or studio product shots.
2. **Shared wind.** One TSL function of `(worldXZ, time)`. Grass, canopies, cloth, particles, rain, flags, and water chop all sample it, so a gust visibly travels across the whole scene.
3. **Instancing first.** Anything that appears more than ~20 times is an `InstancedMesh`, a `BatchedMesh`, or GPU particles, with per-instance variation (hash of `instanceIndex` for scale, phase, tint, lean). Use one draw call per kind of thing.
4. **Lighting budget.** One key `SunLight` (or a spot/rect key light indoors), plus sky or probe ambient, plus emissives. For many small lights, use `ClusteredLighting` rather than scattering `PointLight`s. Put GI on top: `ssgi` for general cases, `vxgi` or `LightProbeGrid` for interiors.
5. **Atmosphere.** Outdoors, add height fog or scattering fog, aerial perspective, and god rays or volumetrics where light has something to cut through. Water gets FFT waves, foam, and depth color. Interiors get volumetric light shafts and dust motes.
6. **Post that sells the shot.** An MRT scene pass (output, velocity, normal), then AO/GI, TRAA (or TAAU for dynamic resolution), bloom, lens flare, and subtle grain and CA. Pick deliberately between AgX and ACES tone mapping. Exposure is part of the look.

Density recipe for nature, ground, or any "alive world": use a terrain heightfield shaded by slope, height, and moisture in TSL (not a tiling texture). Grass is 50k–150k instanced blades, bent only at the tips by the shared wind. Trees are a few hero trees plus an instanced forest with wind in the canopy. The sun should be low enough that shadows crawl. Built-in generators give a head start: `TerrainGenerator`, `ForestGenerator`, `TreeGenerator`, `CityGenerator`.

## Look direction

- **One strong mood per scene**, with a name: dawn ridge, wet night pier, maple moonlight, tropical noon, sodium-lit parking garage. Avoid a generic "3D template".
- **Camera and sun do the work.** Use traveling light, changing shadow length, a flare as the sun crosses a silhouette, and a slow dolly with parallax.
- **Variation over tiling.** Use per-instance attributes, noise, clustered density, and wear.
- **Interaction disturbs the systems.** Walking parts the grass, boats leave a wake, a click sends a wind gust, and there is a time-of-day scrub and a weather toggle.
- **Material truth.** Use physical parameters (clearcoat, sheen, transmission, iridescence, anisotropy, SSS) where the real material has them, grounded by contact shadows or AO.

## Performance guardrails

- Target 60 fps on a recent laptop. Provide quality tiers (shadow map size, GI on/off, instance counts, pixel ratio) and dynamic resolution through TAAU.
- Mobile gets ~100 draw calls or fewer. Use KTX2/Basis textures and Meshopt/Draco geometry.
- Don't simulate or draw what the camera can't see: frustum and distance LOD, compute culling for huge instance counts.
- Use `await renderer.compileAsync( scene, camera )` behind a loading state, so the first frame doesn't hitch. `dispose()` geometries, materials, and render targets.
- Debug with `renderer.inspector = new Inspector()`, not guesswork.

## Procedure

1. **Name the mood and the hero shot** in one line before writing any code.
2. **Map the idea onto the six systems.** Decide what each system means here, even for a short prompt. A system can be skipped only when it clearly makes no sense. If the idea is 2D/UI-only, add a quiet 3D layer that uses these techniques, unless the user asked for no 3D.
3. **Check APIs against the installed version** and the closest `webgpu_*` example (see TOOLBOX.md).
4. **Write complete, runnable code**: imports, renderer, TSL nodes, lights, loop, resize, dispose, loading state, quality tiers. Skeletons are in [PATTERNS.md](PATTERNS.md). If a subsystem is too large to build here (a production FFT ocean, a production grass system), use a named library or write a clearly marked stub with the same architecture: GPU, instanced, shared wind, time-of-day aware.
5. **Comment only the system contracts**: the shared wind uniform, the sun/time mapping, instance attribute layouts.

## Reject on sight

A `MeshBasicMaterial` world · one `DirectionalLight` over a gray plane · a static skybox · cloned meshes that aren't instanced · a `Mesh` per grass blade · wind computed on the CPU in JS · `ShaderMaterial` copied from old examples · `EffectComposer` on WebGPU · a scrolling normal map as an ocean · noon-flat lighting without a mood · a first frame that stalls compiling shaders.

## Output

Ship the strongest version of the user's idea that runs in a modern browser, and treat everything above as the baseline, not as extras. Finish with one line naming the mood, the systems in play, and any WebGPU-only features that are degraded on the fallback.

# Frontier toolbox — verified against three r186.1 (2026-09-24)

Each import path below was checked in the published package. The **Example** column names the official `webgpu_*` example that shows canonical usage. Read it at `https://raw.githubusercontent.com/mrdoob/three.js/r<version>/examples/<name>.html`.

On a newer release, re-verify quickly:

```sh
npm view three version
ls node_modules/three/examples/jsm/{lights,lighting,generators,objects,tsl/display,tsl/lighting}
```

Also scan `examples/files.json` → `webgpu` for new names; new names usually mean new frontier features.

## Core

| Need | Import | Example |
|---|---|---|
| Renderer (WebGPU, WebGL2 fallback) | `WebGPURenderer` from `three/webgpu` · `forceWebGL`, `reversedDepthBuffer`, `outputType: HalfFloatType` (HDR display) | `webgpu_reversed_depth_buffer`, `webgpu_hdr` |
| Node materials | `MeshStandardNodeMaterial`, `MeshPhysicalNodeMaterial`, `MeshSSSNodeMaterial`, `VolumeNodeMaterial`, `SpriteNodeMaterial`, `PointsNodeMaterial` | `webgpu_materials_sss`, `webgpu_volume_lighting` |
| Post pipeline | `RenderPipeline` (was `PostProcessing`) + `pass`, `mrt`, `output`, `velocity`, `normalView`, `diffuseColor` from `three/tsl` | `webgpu_postprocessing_ssgi` |
| GPU compute | `instancedArray`, `Fn`, `instanceIndex`, `.compute( n )`, `renderer.compute()` | `webgpu_compute_particles`, `webgpu_compute_birds`, `webgpu_compute_cloth` |
| Indirect / bundles | storage structs + draw-indirect; `RenderBundle` | `webgpu_struct_drawindirect`, `webgpu_performance_renderbundle` |
| Debug/tuning UI | `Inspector` from `three/addons/inspector/Inspector.js`; `node.toInspector( 'label' )` | most r186 examples |
| Noise in TSL | `mx_noise_float`, `mx_fractal_noise_float`, `hash` (`three/tsl`); `curlNoise`, `voronoiNoise`, `bayer16` (`three/addons/tsl/math/*`) | `webgpu_materialx_noise` |

## Light, shadow, GI

| Need | Import | Example |
|---|---|---|
| Sun with cascaded shadows | `SunLight`, `SunLightNode` from `three/addons/lights/` — **register with** `renderer.library.addLight( SunLightNode, SunLight )`. The direction comes from `position` (no target). | `webgpu_lights_sunlight` |
| Classic CSM (DirectionalLight) | `CSMShadowNode` from `three/addons/csm/CSMShadowNode.js` | `webgpu_shadowmap_csm` |
| Tiled shadows | `TileShadowNode` from `three/addons/tsl/shadows/` | `webgpu_shadowmap_array` |
| Contact / screen-space shadows | `sss` from `three/addons/tsl/display/SSSNode.js` (it is screen-space *shadows*, not subsurface) | `webgpu_postprocessing_sss`, `webgpu_shadow_contact` |
| Screen-space GI + AO | `ssgi` from `tsl/display/SSGINode.js` → `getAONode()`, `getGINode()` | `webgpu_postprocessing_ssgi` |
| Voxel cone-traced GI (WebGPU only) | `vxgi` from `three/addons/lighting/vxgi/VXGINode.js` + `builtinGIContext` on the scene pass | `webgpu_vxgi`, `webgpu_vxgi_sponza` |
| Irradiance probe volume | `LightProbeGrid` from `three/addons/lighting/LightProbeGrid.js` | `webgpu_lightprobes`, `webgpu_lightprobes_sponza` |
| Many small lights | `ClusteredLighting` from `three/addons/lighting/ClusteredLighting.js` → `renderer.lighting = …` | `webgpu_lights_clustered` |
| GTAO only | `ao` from `tsl/display/GTAONode.js` | `webgpu_postprocessing_ao` |
| Area / IES / projector | `RectAreaLight`, IES spot, projector light | `webgpu_lights_rectarealight`, `webgpu_lights_ies_spotlight`, `webgpu_lights_projector` |

## Sky, atmosphere, water

| Need | Import | Example |
|---|---|---|
| Physical sky + clouds | `SkyMesh` from `three/addons/objects/SkyMesh.js` (`sunPosition`, `turbidity`, `rayleigh`, `cloudCoverage`, `cloudDensity`, `cloudSpeed`, `showSunDisc`). Feed it to `PMREMGenerator.fromScene` → `scene.environment` | `webgpu_sky`, `webgpu_lights_sunlight` |
| Height fog | `scene.fogNode = fog( color, exponentialHeightFogFactor( … ) )` | `webgpu_fog_height` |
| Scattering fog (blurred scene through fog) | `densityFogFactor` + `gaussianBlur` composite | `webgpu_custom_fog_scattering` |
| God rays | `godrays( depth, camera, light )` + `bilateralBlur` + `depthAwareBlend` — **Directional/Point only**, full shadow setup required | `webgpu_postprocessing_godrays` |
| Volumetric light / clouds / fire | `VolumeNodeMaterial`, `texture3D`, `RaymarchingBox` (`three/addons/tsl/utils/Raymarching.js`) | `webgpu_volume_lighting(_traa)`, `webgpu_volume_cloud`, `webgpu_volume_fire` |
| Caustics | light-space caustics | `webgpu_caustics`, `webgpu_volume_caustics` |
| Stylized ocean (cheap) | `WaterMesh` (normal-map) — acceptable only for far/background water | `webgpu_ocean` |
| Heightfield water sim | compute ripple sim | `webgpu_compute_water` |
| Hero ocean | FFT spectrum in compute (Tessendorf/JONSWAP cascades → displacement + foam) written in TSL, or **Tidewater** (paid kit: cascaded FFT, wakes, buoyancy, underwater — gettidewater.com) | `webgpu_tsl_raging_sea` for the vertex-displacement idea |
| Reflections | `ssr` (+ denoise), `reflector()` for planar mirrors, blurred/rough reflection | `webgpu_postprocessing_ssr_denoise`, `webgpu_reflection_roughness` |

## World generation & content

| Need | Import | Example |
|---|---|---|
| Procedural mountains | `TerrainGenerator` from `three/addons/generators/TerrainGenerator.js` (eroded, TSL grass/rock/snow material, `sampleHeight`) | — (`webgpu_tsl_procedural_terrain` shows a hand-rolled TSL terrain lit by `SunLight`) |
| Instanced forest on terrain | `ForestGenerator` (500k trees, one draw call) | — |
| Procedural tree geometry | `TreeGenerator` + `createTreeMaterial` (branches; add foliage layer) · or `@dgreenheck/ez-tree` (npm) for full trees with leaves | `webgpu_custom_fog_scattering` |
| City | `CityGenerator`, `createBuildingMaterial`, `createRoadMaterial` | `webgpu_generator_city`, `webgpu_generator_building` |
| Grass | build it (see PATTERNS) or **Grassworks** (paid, WebGPU grass: terrain-aware placement, LOD, interaction — grassworks.techredux.co) | — |
| Gaussian splats | `GaussianSplat` from `three/addons/objects/GaussianSplat.js` + `SPLATLoader` / `SPZLoader` (WebGPURenderer only; forceWebGL OK) | `webgpu_gaussian_splat` |
| Assets | `GLTFLoader` + `KTX2Loader` + `MeshoptDecoder` (`three/addons/libs/meshopt_decoder.module.js`) / `DRACOLoader`; MaterialX via `MaterialXLoader` | `webgpu_loader_gltf_compressed`, `webgpu_loader_materialx` |
| Particle VFX recipes | TSL flames, tornado, linked particles, attractors, galaxy | `webgpu_tsl_vfx_*`, `webgpu_tsl_compute_attractors_particles`, `webgpu_tsl_galaxy` |

## Post / image pipeline (all in `three/addons/tsl/display/`)

| Effect | Factory |
|---|---|
| Temporal AA | `traa( color, depth, velocity, camera )` — also resolves GI / volumetric noise |
| Temporal upscaling (dynamic res) | `taau( … )` + `sharpen` · or `FSR1Node` |
| Bloom | `bloom( node, strength, radius, threshold )` (selective / emissive variants exist) |
| Lens flare | `lensflare( node, params )` |
| DoF / motion blur | `DepthOfFieldNode`, `MotionBlur` |
| Grade | `Lut3DNode`, `film` (grain), `ChromaticAberrationNode`; anamorphic streaks are a custom bloom (`webgpu_postprocessing_anamorphic`) |
| Transparency | `OITPassNode` (order-independent) |
| Denoise | `DenoiseNode`, `RecurrentDenoiseNode` |
| Outline / stylized | `OutlineNode`, `SobelOperatorNode`, `RetroPassNode`, `PixelationPassNode` |

## Paid / third-party kits (name them when relevant)

- **Tidewater**: FFT ocean kit for WebGPU and WebGL2.
- **Grassworks**: production WebGPU grass.
- **ez-tree** (MIT): procedural trees with foliage.

Use one of these when its polish matters more than owning the code. Otherwise write a stub with the same architecture.

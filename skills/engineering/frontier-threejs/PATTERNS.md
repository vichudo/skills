# Patterns — system skeletons (r186)

These are starting architectures, not templates to paste unchanged. Adapt them to the idea, and check each API against the installed version (see TOOLBOX.md).

## 1. Bootstrap: renderer, sun, sky environment, capability tier

```js
import * as THREE from 'three/webgpu';
import { SunLight } from 'three/addons/lights/SunLight.js';
import { SunLightNode } from 'three/addons/lights/SunLightNode.js';
import { SkyMesh } from 'three/addons/objects/SkyMesh.js';

// `tier` comes from the quality tiers in section 7
const renderer = new THREE.WebGPURenderer( { antialias: false } ); // TRAA resolves AA
renderer.library.addLight( SunLightNode, SunLight );               // required for SunLight
renderer.setPixelRatio( Math.min( devicePixelRatio, tier.pixelRatio ) );
renderer.setSize( innerWidth, innerHeight );
renderer.shadowMap.enabled = true;
renderer.toneMapping = THREE.AgXToneMapping;
document.body.append( renderer.domElement );
await renderer.init();

const webgpu = renderer.backend.isWebGPUBackend === true; // false → WebGL2 fallback: drop WebGPU-only features

const scene = new THREE.Scene();
const sun = new SunLight();              // direction = position → origin, no target
sun.castShadow = true;
sun.shadow.camera.far = 800;             // shadow distance covered by the cascades
sun.shadow.mapSize.setScalar( tier.shadowMap );
sun.shadow.normalBias = 0.05;
scene.add( sun );

const sky = new SkyMesh();
sky.scale.setScalar( 9000 );
sky.showSunDisc.value = false;
scene.add( sky );
```

## 2. Time-of-day: one clock that drives everything

```js
import { uniform } from 'three/tsl';

export const night = uniform( 0 ); // 0 day … 1 night; emissives read this

const pmrem = new THREE.PMREMGenerator( renderer );
const envScene = new THREE.Scene();
let envRT, lastEnvElevation = Infinity;

const SUN_DAY = new THREE.Color( 0xfff2e3 ), SUN_DUSK = new THREE.Color( 0xff8a3d );
const FOG_DAY = new THREE.Color( 0xd8e2ea ), FOG_DUSK = new THREE.Color( 0xd9a273 );

export function setTimeOfDay( t ) { // t in [0,1): 0.25 sunrise, 0.5 noon, 0.75 sunset
	const elevation = Math.sin( ( t - 0.25 ) * Math.PI * 2 ) * 70; // degrees
	const azimuth = t * 360;
	sun.position.setFromSphericalCoords( 1, THREE.MathUtils.degToRad( 90 - elevation ), THREE.MathUtils.degToRad( azimuth ) );

	const day = THREE.MathUtils.clamp( elevation / 30, 0, 1 );
	sun.color.lerpColors( SUN_DUSK, SUN_DAY, day );
	sun.intensity = elevation > 0 ? 2 + day * 3 : 0;
	sky.sunPosition.value.copy( sun.position );
	scene.fog?.color.lerpColors( FOG_DUSK, FOG_DAY, day );
	renderer.toneMappingExposure = THREE.MathUtils.lerp( 0.35, 0.6, day );
	night.value = 1 - THREE.MathUtils.smoothstep( elevation, -6, 4 );

	// PMREM is expensive: regenerate the sky environment only when the sun has moved noticeably
	if ( Math.abs( elevation - lastEnvElevation ) > 0.75 ) {
		lastEnvElevation = elevation;
		envRT?.dispose();
		envScene.add( sky );
		envRT = pmrem.fromScene( envScene );
		scene.add( sky );
		scene.environment = envRT.texture;
	}
}
```

Emissives: `material.emissiveNode = color( 0xffb46b ).mul( night ).mul( intensity )`. Windows, lanterns, and bioluminescence then turn on with the dusk.

## 3. Shared wind: one TSL function everyone samples

```js
import { Fn, uniform, vec2, vec3, time, sin, mx_noise_float } from 'three/tsl';

export const windDir = uniform( new THREE.Vector2( 1, 0.35 ).normalize() );
export const windStrength = uniform( 0.6 ); // gust-on-click: tween this up and back
export const windSpeed = uniform( 1.2 );

// returns an XZ displacement at a world XZ position; gusts travel downwind across the scene
export const wind = Fn( ( [ xz ] ) => {
	const scroll = xz.mul( 0.04 ).sub( windDir.mul( time.mul( windSpeed ).mul( 0.25 ) ) );
	const gust = mx_noise_float( vec3( scroll, time.mul( 0.05 ) ) ).mul( 0.5 ).add( 0.5 );
	const flutter = sin( time.mul( 7 ).add( xz.x.mul( 0.9 ) ).add( xz.y.mul( 0.6 ) ) ).mul( 0.12 );
	return windDir.mul( gust.add( flutter ).mul( windStrength ) );
} );
```

Grass, canopies, cloth, particles, and water chop all call `wind(worldXZ)`. Never write a second wind.

## 4. Instanced grass bent by the shared wind

```js
import { positionLocal, uv, instanceIndex, hash, vec3, mix, color } from 'three/tsl';

const blade = new THREE.PlaneGeometry( 0.06, 1, 1, 4 ).translate( 0, 0.5, 0 ); // uv.y 0 root → 1 tip
const mat = new THREE.MeshStandardNodeMaterial( { side: THREE.DoubleSide, roughness: 0.8 } );

const tip = uv().y.pow( 1.6 );              // only upper verts move
const rnd = hash( instanceIndex );          // per-blade variation without extra attributes
// positionNode runs after the instance matrix, so positionLocal is already mesh-space (≈ world if mesh at origin)
const bend = wind( positionLocal.xz ).mul( tip ).mul( rnd.mul( 0.6 ).add( 0.7 ) );
mat.positionNode = positionLocal.add( vec3( bend.x, bend.length().mul( tip ).negate().mul( 0.3 ), bend.y ) );
mat.colorNode = mix( color( 0x2f4a1a ), color( 0x9fb04a ), tip ).mul( rnd.mul( 0.25 ).add( 0.85 ) );

const grass = new THREE.InstancedMesh( blade, mat, tier.grassCount ); // 50k–150k
// fill instanceMatrix from terrain.sampleHeight(x,z), cluster density with noise, random yaw/scale/lean
grass.receiveShadow = true;
```

For very large fields, move placement and culling into compute (write the visible instances into an `instancedArray`, then draw indirect). Grassworks is the paid production version of this.

## 5. GPU compute particles that obey the same wind

```js
import { Fn, instancedArray, instanceIndex, vec3, hash, If, deltaTime } from 'three/tsl';

const N = 200_000;
const pos = instancedArray( N, 'vec3' ), vel = instancedArray( N, 'vec3' );

const init = Fn( () => {
	const p = pos.element( instanceIndex );
	p.assign( vec3( hash( instanceIndex ), hash( instanceIndex.add( 1 ) ), hash( instanceIndex.add( 2 ) ) ).sub( 0.5 ).mul( vec3( 200, 40, 200 ) ) );
} )().compute( N );

const update = Fn( () => {
	const p = pos.element( instanceIndex ), v = vel.element( instanceIndex );
	const w = wind( p.xz );
	v.addAssign( vec3( w.x, -0.2, w.y ).sub( v ).mul( deltaTime.mul( 2 ) ) ); // relax toward wind + gravity
	p.addAssign( v.mul( deltaTime ) );
	If( p.y.lessThan( 0 ), () => { p.y.assign( 40 ); } );                    // respawn
} )().compute( N );

const mat = new THREE.SpriteNodeMaterial( { transparent: true, depthWrite: false } );
mat.positionNode = pos.toAttribute();
const motes = new THREE.Sprite( mat );
motes.count = N;
scene.add( motes );

renderer.compute( init );
// each frame: renderer.compute( update );
```

## 6. Post: MRT → GI/AO → TRAA → bloom/flare/grain

```js
import { pass, mrt, output, velocity, normalView, diffuseColor, packNormalToRGB, unpackRGBToNormal, sample, add, vec4 } from 'three/tsl';
import { ssgi } from 'three/addons/tsl/display/SSGINode.js';
import { traa } from 'three/addons/tsl/display/TRAANode.js';
import { bloom } from 'three/addons/tsl/display/BloomNode.js';

const pipeline = new THREE.RenderPipeline( renderer ); // NOT PostProcessing (renamed r183)
const scenePass = pass( scene, camera );
scenePass.setMRT( mrt( { output, diffuseColor, normal: packNormalToRGB( normalView ), velocity } ) );
scenePass.getTexture( 'diffuseColor' ).type = THREE.UnsignedByteType; // bandwidth
scenePass.getTexture( 'normal' ).type = THREE.UnsignedByteType;

const color = scenePass.getTextureNode( 'output' );
const depth = scenePass.getTextureNode( 'depth' );
const normal = sample( ( uv ) => unpackRGBToNormal( scenePass.getTextureNode( 'normal' ).sample( uv ) ) );

let lit = color;
if ( tier.gi ) {
	const gi = ssgi( color, depth, normal, camera );
	gi.sliceCount.value = 2; gi.stepCount.value = 8;
	lit = vec4( add( color.rgb.mul( gi.getAONode() ), scenePass.getTextureNode( 'diffuseColor' ).rgb.mul( gi.getGINode().rgb ) ), color.a );
}
const resolved = traa( lit, depth, scenePass.getTextureNode( 'velocity' ), camera ); // also denoises GI
pipeline.outputNode = resolved.add( bloom( resolved, 0.25, 0.4, 0.9 ) );
// optional: lensflare(), film() grain, Lut3D grade — keep each subtle
// loop: pipeline.render() instead of renderer.render()
```

Interiors: swap `ssgi` for `vxgi` (WebGPU only; see `webgpu_vxgi`), injected via `scenePass.contextNode = builtinGIContext( ao, gi )`. Dynamic resolution: `taau` instead of `traa`.

## 7. Loading, quality tiers, lifecycle

```js
const tiers = {
	high:   { pixelRatio: 1.5, shadowMap: 2048, grassCount: 150_000, gi: true },
	medium: { pixelRatio: 1.25, shadowMap: 1024, grassCount: 70_000, gi: false },
	low:    { pixelRatio: 1,   shadowMap: 1024, grassCount: 25_000, gi: false },
};
// pick from backend + navigator.gpu adapter info + a short frame-time probe; step down on sustained >20ms frames

await renderer.compileAsync( scene, camera ); // behind a loading overlay, so the first frame doesn't hitch
renderer.setAnimationLoop( frame );
// on teardown: renderer.setAnimationLoop( null ); dispose geometries, materials, textures, render targets, pmrem, pipeline
```

## 8. React Three Fiber 9 + WebGPU

```jsx
import * as THREE from 'three/webgpu';
import { Canvas, extend } from '@react-three/fiber';
import { SunLight } from 'three/addons/lights/SunLight.js';
import { SunLightNode } from 'three/addons/lights/SunLightNode.js';

extend( THREE ); // register node materials etc. as JSX elements

<Canvas
	shadows
	gl={ async ( props ) => {
		const renderer = new THREE.WebGPURenderer( props );
		renderer.library.addLight( SunLightNode, SunLight );
		await renderer.init();
		return renderer;
	} }
>
	{ /* systems as components; post via a component that owns a RenderPipeline and renders in useFrame( …, 1 ) */ }
</Canvas>
```

Keep TSL node graphs in `useMemo`. Drive uniforms (`night`, `windStrength`) by mutating `.value` in `useFrame`, never through React state.

type Vec2 = [number, number];
type Vec3 = [number, number, number];
type Vec3or2 = [number, number, number?];

class DrawContext {
	#ctx: CanvasRenderingContext2D;
	#canvas: HTMLCanvasElement;

	constructor(canvas: HTMLCanvasElement) {
		this.#canvas = canvas;
		this.#ctx = this.#canvas.getContext("2d")!;
	}

	begin() {
		// this.#ctx.scale(40, 40);
		this.#ctx.translate(
			this.#canvas.width / 2,
			this.#canvas.height / 2);
	}

	end() {

	}

	project([px, py, pz]: Vec3or2): Vec2 {
		return [px, py];
	}

	unproject([px, py]: Vec2, z: number): Vec3 {
		return [px, py, z];
	}

	ellipse(center: Vec2, radii: Vec2) {
		this.arc(center, radii, 0, Math.PI * 2);
	}

	arc(
		center: Vec2, radii: Vec2, 
		start: number, stop: number,
	) {
		let [cx, cy] = this.project(center);
		let [rx, ry] = this.project(radii);
		this.#ctx.beginPath();
		this.#ctx.ellipse(cx, cy, rx, ry, 0, start, stop);
		this.#ctx.stroke();
	}
}

/// A shape that can be drawn.
class Shape {
	draw(ctx: DrawContext) {
		console.warn("Shape.draw called (abstract method)");
	}
}

class SphereShape extends Shape {
	center: Vec3;
	radius: number;

	constructor(center: Vec3, radius: number) {
		super();
		this.center = center;
		this.radius = radius;
	}

	draw(ctx: DrawContext) {
		let [cx, cy] = ctx.project(this.center);
		ctx.ellipse(
			[cx, cy],
			[this.radius, this.radius],
		);
		const a: Vec2 = [cx - this.radius, cy];
		const b: Vec2 = [cx + this.radius, cy];
		let pa = ctx.unproject(a, 0.0);
		let pb = ctx.unproject(b, 0.0);
		ctx.arc(
			[cx, cy],
			[this.radius, this.radius],
			Math.atan2(pa[1], pa[0]),
			Math.atan2(pb[1], pb[0]),
		)
	}
}

(() => {
	const canvas = document.getElementById("canvas") as
		HTMLCanvasElement;
	const rctx = new DrawContext(canvas);
	const sphere = new SphereShape([0, 0, 0], 50);
	rctx.begin();
	sphere.draw(rctx);
	rctx.end();
})();

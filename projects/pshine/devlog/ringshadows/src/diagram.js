"use strict";
class DrawContext {
    #ctx;
    #canvas;
    constructor(canvas) {
        this.#canvas = canvas;
        this.#ctx = this.#canvas.getContext("2d");
    }
    begin() {
        // this.#ctx.scale(40, 40);
        this.#ctx.translate(this.#canvas.width / 2, this.#canvas.height / 2);
    }
    end() {
    }
    project([px, py, pz]) {
        return [px, py];
    }
    unproject([px, py], z) {
        return [px, py, z];
    }
    ellipse(center, radii) {
        this.arc(center, radii, 0, Math.PI * 2);
    }
    arc(center, radii, start, stop) {
        let [cx, cy] = this.project(center);
        let [rx, ry] = this.project(radii);
        this.#ctx.beginPath();
        this.#ctx.ellipse(cx, cy, rx, ry, 0, start, stop);
        this.#ctx.stroke();
    }
}
/// A shape that can be drawn.
class Shape {
    draw(ctx) {
        console.warn("Shape.draw called (abstract method)");
    }
}
class SphereShape extends Shape {
    center;
    radius;
    constructor(center, radius) {
        super();
        this.center = center;
        this.radius = radius;
    }
    draw(ctx) {
        let [cx, cy] = ctx.project(this.center);
        ctx.ellipse([cx, cy], [this.radius, this.radius]);
        const a = [cx - this.radius, cy];
        const b = [cx + this.radius, cy];
        let pa = ctx.unproject(a, 0.0);
        let pb = ctx.unproject(b, 0.0);
        ctx.arc([cx, cy], [this.radius, this.radius], Math.atan2(pa[1], pa[0]), Math.atan2(pb[1], pb[0]));
    }
}
(() => {
    const canvas = document.getElementById("canvas");
    const rctx = new DrawContext(canvas);
    const sphere = new SphereShape([0, 0, 0], 50);
    rctx.begin();
    sphere.draw(rctx);
    rctx.end();
})();

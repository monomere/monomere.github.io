#import "@local/cetz:0.3.4"
#set text(size: 15pt)
#set par(justify: true)

= Disk Shadows


I needed to draw the shadow of a planet on its rings. Because of how rendering is handled,
we actually have a polar coordniates system, with the planet in the center, and the end of the ring disk at $r=1$.
// Instead of solving for straight lines in polar coordinates, we just take a specific $r in ["InnerR"/"OuterR", 1]$ and figure out what angle we should use.
// Note that for the shadow to make sense, the Sun should actually be on the other side, but this is how I originally drew this out (just add $2pi$ to fix it)


#let windows(arr, size) = {
  array.range(arr.len() - size + 1).map(i => {
    arr.slice(i, count: size)
  })
}

#context {
align(center,
  cetz.canvas({
    import cetz.draw: *
    let text-along-path(text, path, start-percentage: 0%, end-percentage: 100%) = {
      let letters = text.clusters().map(cluster => [#cluster])
      let widths = letters.map(letter => {
        let width = measure(letter).width
        if width == 0pt {
          // Measuring a single space returns a width of 0pt.
          // This is a hack to get the width of a space.
          measure([X X]).width - measure([XX]).width
        } else {
          width
        }
      })
      let total_width = widths.sum()
      let total_percentage = end-percentage - start-percentage

      let distance_covered = 0
      let anchors = ()
      let anchors = for w in widths {
        let relative_width = w / total_width
        let percentage = start-percentage + total_percentage * distance_covered
        distance_covered += relative_width

        (percentage,)
      }
      anchors.push(end-percentage)

      for ((percentage_1, percentage_2), letter) in windows(anchors, 2).zip(letters) {
        let midpoint = (percentage_1 + percentage_2) / 2

        get-ctx(ctx => {
          let (ctx, percentage_1, percentage_2) = cetz.coordinate.resolve(
            ctx,
            (name: path, anchor: percentage_1),
            (name: path, anchor: percentage_2),
          )

          let angle = cetz.vector.angle2(percentage_1, percentage_2)
          
          content(
            (name: path, anchor: midpoint),
            anchor: "south",
            angle: angle,
            letter
          )
        })
      }
    }
    set-style(
      stroke: 0.4pt,
      grid: (
        stroke: gray + 0.2pt,
        step: 0.5
      )
    )
    scale(4)
    grid((-1.5, -1.5), (1.5, 1.5))
    line((-1.5, 0), (1.5, 0))
    line((0, -1.5), (0, 1.5))

    let Rr = 1.0
    let Rr2 = 0.7
    let Rp = 0.4
    circle((0, 0), radius: Rr)
    // circle((0, 0), radius: Rr2, stroke: (
		// 	paint: rgb("#888"),
		// 	thickness: 0.5pt,
		// 	dash: "dashed",
		// ))
    let sun_pos = (1.2, 0.7)
    let α = 90deg - calc.atan2(
      sun_pos.at(1),
      sun_pos.at(0),
    )
    line((-sun_pos.at(0), -sun_pos.at(1)), sun_pos, stroke: (
			thickness: 0.5pt,
      paint: rgb("#666"),
      dash: "dashed",
    ))
    circle((0, 0), radius: Rp, stroke: (
			paint: rgb("#450456"),
			thickness: 1pt,
		), fill: red.transparentize(40%))
    circle((-sun_pos.at(0), -sun_pos.at(1)), radius: 0.05, fill: yellow)
    arc((0, 0), anchor: "origin", start: 0deg, stop: α, radius: 6mm,
      name: "alpha-center-angle")
    content((
      name: "alpha-center-angle",
      anchor: α,
    ), [$alpha$], anchor: "mid-west", padding: 0.2)
    line(
      name: "shadow-line",
      (
        -calc.sin(α)*Rp - calc.cos(α) * Rp / calc.tan(α),
        0
      ),
      (
        calc.cos(α + calc.asin(Rp/Rr)) * Rr,
        calc.sin(α + calc.asin(Rp/Rr)) * Rr,
      )
    )
    line(
      name: "shadow-line-cont",
      (
        -calc.sin(α)*Rp - calc.cos(α) * Rp / calc.tan(α),
        0
      ),
      (
        -calc.cos(α + -calc.asin(Rp/Rr)) * Rr,
        -calc.sin(α + -calc.asin(Rp/Rr)) * Rr,
      )
    )
    line(
      name: "shadow-line2",
      (
        calc.sin(α)*Rp + calc.cos(α) * Rp / calc.tan(α),
        0
      ),
      (
        calc.cos(α - calc.asin(Rp/Rr)) * Rr,
        calc.sin(α - calc.asin(Rp/Rr)) * Rr,
      )
    )
    line(
      name: "shadow-line2-cont",
      (
        calc.sin(α)*Rp + calc.cos(α) * Rp / calc.tan(α),
        0
      ),
      (
        -calc.cos(α + calc.asin(Rp/Rr)) * Rr,
        -calc.sin(α + calc.asin(Rp/Rr)) * Rr,
      )
    )
    line(
      name: "perp-line",
      (0, 0),
      (
        calc.cos(α + 90deg) * Rp,
        calc.sin(α + 90deg) * Rp,
      ),
    )
    let β = α + calc.asin(Rp/Rr)
    let β2 = α - calc.asin(Rp/Rr)
    line(
      name: "hypot-line",
      (0, 0),
      "shadow-line.end",
    )
    line(
      name: "hypot-line2-cont2",
      (0, 0),
      (
        calc.cos(α - calc.asin(Rp/Rr)) * (Rr+0.1),
        calc.sin(α - calc.asin(Rp/Rr)) * (Rr+0.1),
      )
    )
    arc((0, 0), anchor: "origin", start: 0deg, stop: β2,
      radius: 1.1, name: "beta-prime-angle")
    content((
      name: "beta-prime-angle",
      anchor: β2,
    ), [$beta'$], anchor: "mid-west", padding: 0.2)
    arc((0, 0), anchor: "origin", start: β, stop: β2,
      radius: Rr, name: "shadow-arc", stroke: (
        thickness: 2pt,
        paint: rgb("#451053")
      ))
    text-along-path("   in shadow   ", "shadow-arc")
    // content((2, 2), [#str(type(x))])
    arc((0, 0), anchor: "origin", start: 0deg, stop: β,
      radius: 2mm, name: "alpha-center-angle")
    content((
      name: "alpha-center-angle",
      anchor: β,
    ), [$beta$], anchor: "mid-west", padding: 0.2)
    arc(
      "shadow-line.start",
      name: "alpha-west-angle",
      anchor: "origin",
      start: 0deg,
      stop: α,
      radius: 2mm
    )
    content((
      name: "alpha-west-angle",
      anchor: α,
    ), [$alpha$], anchor: "mid-west", padding: 0.2)
    
    content((0, 0), [$O$], anchor: "north-east",
      padding: 0.15)
    content(
      "shadow-line.end",
      [$A$], anchor: "south-west", padding: 0.15)
    content(
      "perp-line.end",
      [$B$], anchor: "south-east", padding: 0.15)
    content(
      "shadow-line-cont.start",
      [$C$], anchor: "south", padding: 0.2)
    group({
      rotate(α)
      rect(
        "perp-line.end",
        (rel: (0.05, -0.05)),
      )
    })
    
  })
)
}

To know if the current point $(r,theta)$ is in shadow, we need to check if $theta$ is between the angles $beta$ and $beta'$ ($beta'$ is like $beta$ but on the other side).
After a bit of trigonometry, we can conclude that

#align(center, $beta,beta'=alpha ± arcsin(R_p/r)$)

Ok, looks like we're done! Here's the shader code:

```fs
bool is_in_shadow(
  float radius,   // = r
  float angle,    // = θ
  float sun_angle // = α
) {
  float d = acos(relative_planet_radius / radius);
  float l = angle - d; // = β or β'
  float r = angle + d; // = β' or β
  return l <= angle && angle <= r;
}
```

If we actually run this, it works! But let's fast-forward a couple hundred years (Saturn has a big orbit) just to be surethat it doesn't break.

_Oh..._

Looks like we forgot that $alpha$ and $theta$ are constrained to $[-pi, pi]$ (because that's what `atan2` returns, but it could just as well have been constrained to $[0, 2pi]$, the problem would still be there, just at different angles). Let's try to come up with an example that breaks our check. If $theta$ is say $-3$, and $(beta, beta')=(pi - 0.5, pi + 0.5)$, on a unit circle it would look like this:


#align(center,
  cetz.canvas({
    import cetz.draw: *
    set-style(stroke: 0.4pt,
      grid: (
        stroke: gray + 0.2pt,
        step: 0.5
      )
    )
    let r = 1.3
    scale(3)
    grid((-1.5, -1.5), (1.5, 1.5))
    content((r, 0), [$0$], anchor: "south-west", padding: .1)
    content((-r,0), [$pi$], anchor: "south-east", padding: .1)
    content((-r,0), [$-pi$], anchor: "north-east", padding: .1)
    scale(x: -1)
    rotate(90deg)
    line((-1.5, 0), (1.5, 0))
    line((0, -1.5), (0, 1.5))
    circle((0, 0), radius: r)
    let angl = (a, name, c, d) => {
      line((0, 0), (r * calc.sin(a), r * calc.cos(a)), stroke: (
        thickness: 1pt,
        paint: c,
      ))
      if a != 0.0deg {
        arc((0, 0), start: 90deg, stop: 90deg-a, radius: d, anchor: "origin", name: name)
      }
    }
    angl(-3rad, "theta", red, 0.2)
    content((name: "theta", anchor: -3rad), [$theta$], anchor: "north-west", padding: .1)
    let beta1 = calc.pi * 1rad + 0.5rad
    let beta2 = calc.pi * 1rad - 0.5rad
    angl(beta1, "beta1", blue, 0.3)
    angl(beta2, "beta2", blue, 0.4)
    arc((0,0), anchor: "origin",
      start: 90deg-beta1, stop: 90deg-beta2,
      radius: r, fill: blue.transparentize(90%), mode: "PIE",
      stroke: none)
  })
)

Notice how $theta$ looks like its inside of the blue region, but numerically, the angles don't overlap: $pi-0.5< -3 < pi+0.5$ is false. To actually check if the angle is inside, we need to add (or substract, if the signs are opposite) $2pi$ to it, to bring it in the same period as the edges. Interestingly, we don't even need to check for this situation (`if`s are costly on the GPU)! We need to compare $theta$, $theta+2pi$, and $theta-2pi$ with the $beta$s and if any of the results is true, the point is between the angles. This is how it would look in code:

```fs
// returns true if a <= b <= c.
bool is_ordered(float a, float b, float c) {
  return a <= b && b <= c;
}

bool is_in_shadow(
  float radius,   // = r
  float angle,    // = θ
  float sun_angle // = α
) {
  float d = acos(relative_planet_radius / radius);
  float l = angle - d; // = β or β'
  float r = angle + d; // = β' or β
  return
    is_ordered(l, angle - 2.0 * PI, r) ||
    is_ordered(l, angle, r) ||
    is_ordered(l, angle + 2.0 * PI, r);
}
```

Now we're actually done!

\<insert saturn image here\>

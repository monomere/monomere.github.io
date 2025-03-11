#import "@preview/cetz:0.3.4"
#set text(size: 15pt)
#set page(width: auto, height: auto, margin: 0pt)
#let windows(arr, size) = {
  array.range(arr.len() - size + 1).map(i => {
    arr.slice(i, count: size)
  })
}

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

#import "@local/cetz:0.3.4"
#set text(size: 15pt)
#set page(width: auto, height: auto, margin: 1em)
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
    intersections("circle1is", {
      circle((0,0,0), radius: 1)
      ortho(on-xz(circle((0,0,0), radius: 1)))
    })
    line("circle1is.0", "circle1is.7",
      stroke: red + 3pt)
    ortho({
      on-xz(grid((-1.5, -1.5), (1.5, 1.5)))
      // on-xz({
      //   arc
      // })
      // merge-path(
      //   {
      //     arc(anchor: "origin", (0,0,0), radius: 1,
      //       start: -90deg, stop: 180deg, mode: "OPEN")
      //     // circle((0,0,2), radius: 1)
      //   }
      // )
      // // on-xy()
      // // on-xy()
      // on-xy({
      //   for x in range(0, 10) {
      //     let a = x / 10 * calc.pi * 2
          
      //     line(
      //       (calc.cos(a), calc.sin(a),0),
      //       (calc.cos(a), calc.sin(a),2),
      //       radius: 1
      //     )
      //   }
      // })
    })
  })
)

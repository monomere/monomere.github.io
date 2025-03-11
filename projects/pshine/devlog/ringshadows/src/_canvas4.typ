#import "@preview/cetz:0.3.4"
#set text(size: 15pt)
#set page(width: auto, height: auto, margin: 0pt)
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
    circle((0, 0), radius: Rr2)
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
    line(
      name: "shadow-line",
      (
        -calc.cos(α + -calc.asin(Rp/Rr)) * Rr,
        -calc.sin(α + -calc.asin(Rp/Rr)) * Rr,
      ),
      (
        calc.cos(α + calc.asin(Rp/Rr)) * Rr,
        calc.sin(α + calc.asin(Rp/Rr)) * Rr,
      ),
      stroke: (dash: "dashed", thickness: 0.5pt, paint: rgb("#451053"))
    )
    line(
      name: "shadow-line2",
      (
        -calc.cos(α + calc.asin(Rp/Rr)) * Rr,
        -calc.sin(α + calc.asin(Rp/Rr)) * Rr,
      ),
      (
        calc.cos(α - calc.asin(Rp/Rr)) * Rr,
        calc.sin(α - calc.asin(Rp/Rr)) * Rr,
      ),
      stroke: (dash: "dashed", thickness: 0.5pt, paint: rgb("#451053"))
    )
    let βg1 = α + calc.asin(Rp/(Rr+0.05))
    let βg2 = α - calc.asin(Rp/(Rr+0.05))
    let β11 = α + calc.asin(Rp/Rr)
    let β12 = α - calc.asin(Rp/Rr)
    let β21 = α + calc.asin(Rp/Rr2)
    let β22 = α - calc.asin(Rp/Rr2)
    hide(arc((0, 0), anchor: "origin", start: βg1, stop: βg2,
      radius: Rr+0.05, name: "shadow-arc-guide", stroke: (
        thickness: 2pt,
        paint: rgb("#451053")
      )))
    merge-path(fill: rgb("#451053").transparentize(60%), close: true, {
      arc((0, 0), anchor: "origin", start: β11, stop: β12,
        radius: Rr, name: "shadow-arc", stroke: (
          thickness: 2pt,
        )
      )
      arc((0, 0), anchor: "origin", start: β22, stop: β21,
        radius: Rr2, name: "shadow-arc2", stroke: (
          thickness: 2pt,
          paint: rgb("#451053")
        )
      )
    })
    text-along-path("   in shadow   ", "shadow-arc-guide")
    line((0, 0), (Rr2*calc.cos(β21), Rr2*calc.sin(β21)))
    line((0, 0), (Rr*calc.cos(β11), Rr*calc.sin(β11)))
    // cetz.angle.angle(
    //   (0, 0),
    //   (1, 0),
    //   (Rr2*calc.cos(β21), Rr2*calc.sin(β21)),
    //   radius: 2mm
    // )
    // cetz.angle.angle(
    //   (0, 0),
    //   (1, 0),
    //   (Rr*calc.cos(β11), Rr*calc.sin(β11)),
    //   radius: 1.5mm
    // )
    
    // let measure-circle(
    //   name,
    //   base-rad,
    //   text-rad,
    //   angle,
    //   label,
    // ) = {
    //   // let Gr_p = 1.3
    //   let γ_p = angle
    //   let γ_p1 = γ_p + calc.asin(base-rad / text-rad)
    //   let γ_p2 = γ_p - calc.asin(base-rad / text-rad)
    //   // arc((0, 0), radius: Gr_p, start: γ_p1, stop: γ_p2, anchor: "origin")
    //   line(
    //     name: name + "_measure",
    //     mark: (symbol: "straight", length: 0.5mm, width: 0.4mm),
    //     (text-rad * calc.cos(γ_p1 +1deg), text-rad * calc.sin(γ_p1 +1deg)),
    //     (text-rad * calc.cos(γ_p2 -1deg), text-rad * calc.sin(γ_p2 -1deg))
    //   )
    //   line(
    //     name: name + "_measure_L",
    //     (base-rad*calc.cos(γ_p+90deg), base-rad*calc.sin(γ_p+90deg)),
    //     (text-rad*calc.cos(γ_p1), text-rad*calc.sin(γ_p1)),
    //     stroke: (paint: gray, thickness:1pt, dash: "dotted"),
    //   )
    //   line(
    //     name: name + "_measure_R",
    //     (base-rad*calc.cos(γ_p - 90deg), base-rad*calc.sin(γ_p - 90deg)),
    //     (text-rad*calc.cos(γ_p2), text-rad*calc.sin(γ_p2)),
    //     stroke: (paint: gray, thickness:1pt, dash: "dotted"),
    //   )
    //   content(
    //     (name + "_measure.start", 50%, name + "_measure.end"),
    //     angle: name + "_measure.end",
    //     anchor: "south",
    //     padding: 1mm,
    //     label
    //   )
    // }
    // measure-circle(
    //   "Rp",
    //   Rp,
    //   1.3,
    //   160deg,
    //   $R_p$
    // )
    // measure-circle(
    //   "Rr",
    //   Rr,
    //   1.6,
    //   95deg,
    //   $R_r$
    // )
    // measure-circle(
    //   "Rr",
    //   Rr2,
    //   1.26,
    //   95deg,
    //   $R_r$
    // )
  })
)
}

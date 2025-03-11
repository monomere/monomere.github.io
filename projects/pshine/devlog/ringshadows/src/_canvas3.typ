#import "@preview/cetz:0.3.4"
#set text(size: 15pt)
#set page(width: auto, height: auto, margin: 1em)
#let windows(arr, size) = {
  array.range(arr.len() - size + 1).map(i => {
    arr.slice(i, count: size)
  })
}
// Multiply 4x4 matrix with vector of size 3 or 4.
// The value of vec_4 defaults to w (1).
//
// The resulting vector is of dimension 4
/// Multiplies a 4x4 matrix with a vector of size 3 or 4. The resulting is three dimensional
/// - mat (matrix): The matrix to multiply
/// - vec (vector): The vector to multiply
/// - w (float): The default value for the fourth element of the vector if it is three dimensional.
/// -> vector
#let mul4x4-vec3w(mat, vec, w: 1) = {
  assert(vec.len() <= 4)

  let x = vec.at(0)
  let y = vec.at(1)
  let z = vec.at(2, default: 0)
  let w = vec.at(3, default: w)

  let (
    (a1,a2,a3,a4),
    (b1,b2,b3,b4),
    (c1,c2,c3,c4),
    (d1,d2,d3,d4),
  ) = mat
  return (
    a1 * x + a2 * y + a3 * z + a4 * w,
    b1 * x + b2 * y + b3 * z + b4 * w,
    c1 * x + c2 * y + c3 * z + c4 * w,
    d1 * x + d2 * y + d3 * z + d4 * w,
  )
}

#let mul4x4-vec3proj(mat, vec, w: 1) = {
  let (x,y,z,w) = mul4x4-vec3w(mat, vec, w: w)
  return (x/w, y/w, z/w)
}

#align(center,
  cetz.canvas({
    import cetz.draw: *
    // scale(3)
    let proj = (x: 10deg, y: 22deg, z: 0deg)
    let mtx = cetz.matrix.mul-mat(
      cetz.matrix.ident(4),
      cetz.matrix.ident(4),
      cetz.matrix.transform-rotate-z(proj.z),
      cetz.matrix.transform-rotate-y(proj.y),
      cetz.matrix.transform-rotate-x(proj.x),
    )
    let mtxi = cetz.matrix.inverse(mtx)
    set-style(stroke: 0.4pt,
      grid: (
        stroke: gray + 0.2pt,
        step: 0.5
      )
    )
    let r = 1.3
    intersections("circle1is", {
      circle((0,0,0), radius: 1)
      ortho(..proj, on-xz(circle((0,0,0), radius: 1)))
    })
    get-ctx((ctx) => {
      let (a, b) = ((-1, 0), (1, 0))
      let (ap, bp) = (a, b)
      let ap = cetz.matrix.mul4x4-vec3(mtxi, a)
      let bp = cetz.matrix.mul4x4-vec3(mtxi, b)
      let app = cetz.matrix.mul4x4-vec3(mtx, ap)
      let bpp = cetz.matrix.mul4x4-vec3(mtx, bp)
      line(a, b, stroke: rgb("#3498b3") + 1pt)
      line(ap, bp, stroke: blue + 1pt)
      ortho(..proj, on-xz(line(
        (ap.at(0), ap.at(1), 0),
        (bp.at(0), bp.at(1), 0),
        stroke: red + 1.5pt
      )))
    })
    ortho(..proj, {
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

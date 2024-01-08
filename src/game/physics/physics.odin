package physics

import "core:math/linalg"
import rl "vendor:raylib"

import "../../rlutil"

G  :: 6.78
RESTITUTION :: 0.5
DT :: 1.0 / 120

World :: struct {
    bodies: [dynamic]Body,
    ball: Body,
    dt_acc: f32,
}

Body :: struct {
    pos, vel: rl.Vector2,
    radius: f32,
}

init :: proc() -> (w: World) {
    reserve(&w.bodies, 2)
    append(&w.bodies, Body{pos = 0, radius = 10, vel = {1, 0}})
    append(&w.bodies, Body{pos = 26, radius = 12, vel = {3, 5}})

    w.ball = Body{ pos = -20, radius = 1 }
    return
}

deinit :: proc(w: World) { delete(w.bodies) }


update :: proc(w: ^World, dt: f32) {
    w.dt_acc += dt
    for w.dt_acc >= DT {
        w.dt_acc -= DT
        fixed_update(w)
    }
}

fixed_update :: proc(w: ^World) -> bool {
    for &body in w.bodies {
        ball_mass := body_mass(w.ball)
        ab := body.pos - w.ball.pos
        force := G * ball_mass * body_mass(body) / linalg.length2(ab)
        acceleration := force / ball_mass
        w.ball.vel += linalg.normalize(ab) * acceleration * DT
    }

    w.ball.pos += w.ball.vel * DT

    for body in w.bodies {
        if rl.CheckCollisionCircles(w.ball.pos, w.ball.radius, body.pos, body.radius) {
            ab := linalg.normalize(body.pos - w.ball.pos)
            dist_overlap := (w.ball.pos + w.ball.radius*ab) - (body.pos - body.radius*ab)

            w.ball.pos -= dist_overlap
            w.ball.vel -= -(1 + RESTITUTION) * linalg.dot(-w.ball.vel, ab) * ab
        }
    }

    if rlutil.nearly_eq(linalg.length(w.ball.vel), 0, 0.001) {
        w.ball.vel = 0
        return false
    }

    return true
}

body_mass :: proc(b: Body) -> f32 {
    return b.radius * b.radius * rl.PI
}

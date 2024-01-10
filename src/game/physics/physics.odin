package physics

import "core:math/linalg"
import rl "vendor:raylib"

import "../../rlutil"

G  :: 6.78
RESTITUTION :: 0.5
MU :: 0.3 // Friction
DT :: 1.0 / 240

World :: struct {
    bodies: [dynamic]Body,
    ball: Body,

    ball_prev_pos: rl.Vector2,

    dt_acc: f32,
}

Body :: struct {
    pos, vel: rl.Vector2,
    radius, angle: f32,
}

init :: proc() -> (w: World) {
    reserve(&w.bodies, 2)
    append(&w.bodies, Body{ pos =  -200, radius = 100, vel = {1, 0} })
    append(&w.bodies, Body{ pos = 200, radius = 150, vel = {3, 5} })

    w.ball = Body{ pos = 0, radius = 5,  }
    return
}

deinit :: proc(w: World) { delete(w.bodies) }


update :: proc(w: ^World, dt: f32) {
    w.dt_acc += dt
    for w.dt_acc >= DT {
        w.dt_acc -= DT

        w.ball_prev_pos = w.ball.pos
        fixed_update(w)

        if rlutil.nearly_eq(w.ball_prev_pos, w.ball.pos, 0.000001) {
            w.ball.vel = 0
        }
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
            ab := linalg.normalize(body.pos - w.ball.pos) // Collision normal.
            dist_overlap := (w.ball.pos + w.ball.radius*ab) - (body.pos - body.radius*ab)

            rel_vel := -w.ball.vel

            w.ball.pos -= dist_overlap
            w.ball.vel -= -(1 + RESTITUTION) * linalg.dot(rel_vel, ab) * ab
            w.ball.vel *= 0.995
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

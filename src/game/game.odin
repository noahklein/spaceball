package game

import "core:math/linalg"
import rl "vendor:raylib"

import "../rlutil"

G  :: 6.78
RESTITUTION :: 0.5
DT :: 1.0 / 120

bodies: [dynamic]Body
ball: Body
dt_acc: f32

Body :: struct {
    pos, vel: rl.Vector2,
    radius: f32,
}

init :: proc() {
    reserve(&bodies, 2)
    append(&bodies, Body{pos = 0, radius = 10, vel = {1, 0}})
    append(&bodies, Body{pos = 26, radius = 12, vel = {3, 5}})

    ball = Body{ pos = -20, radius = 1 }
}

deinit :: proc() { delete(bodies) }

update :: proc(dt: f32) {
    dt_acc += dt
    for dt_acc >= DT {
        dt_acc -= DT
        fixed_update()
    }
}

fixed_update :: proc() {
    for &body in bodies {
        ab := body.pos - ball.pos
        force := G * body_mass(ball) * body_mass(body) / linalg.length2(ab)
        acceleration := force / ball.radius
        ball.vel += linalg.normalize(ab) * acceleration * DT
    }

    ball.pos += ball.vel * DT

    for body in bodies {
        if rl.CheckCollisionCircles(ball.pos, ball.radius, body.pos, body.radius) {
            ab := linalg.normalize(body.pos - ball.pos)
            dist_overlap := (ball.pos + ball.radius*ab) - (body.pos - body.radius*ab)

            ball.pos -= dist_overlap
            ball.vel -= -(1 + RESTITUTION) * linalg.dot(-ball.vel, ab) * ab
        }
    }

    if rlutil.nearly_eq(linalg.length(ball.vel), 0, 0.001) {
        ball.vel = 0
    }
}

draw2d :: proc() {
    for body in bodies {
        rl.DrawCircleV(body.pos, body.radius, rl.SKYBLUE)
    }

    rl.DrawCircleV(ball.pos, ball.radius, rl.RED)
}

body_mass :: proc(b: Body) -> f32 {
    return b.radius * b.radius * rl.PI
}

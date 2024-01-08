package game

import "core:fmt"
import "core:math/linalg"
import rl "vendor:raylib"

import "../rlutil"

G :: 6.78

bodies: [dynamic]Body
ball: Body

Body :: struct {
    pos, vel: rl.Vector2,
    radius: f32,
}

init :: proc() {
    reserve(&bodies, 2)
    append(&bodies, Body{pos = 0, radius = 5, vel = {1, 0}})
    append(&bodies, Body{pos = 20, radius = 7, vel = {3, 5}})

    ball = Body{ pos = -7, radius = 1 }
}

deinit :: proc() { delete(bodies) }

update :: proc(dt: f32) {
    for &body in bodies {
        ab := body.pos - ball.pos
        force := G * ball.radius * body.radius / linalg.length2(ab)
        acceleration := force / ball.radius
        ball.vel += linalg.normalize(ab) * acceleration * dt
    }

    ball.pos += ball.vel * dt


    for body in bodies {
        if rl.CheckCollisionCircles(ball.pos, ball.radius, body.pos, body.radius) {
            ab := linalg.normalize(body.pos - ball.pos)
            dist_overlap := (ball.pos + ball.radius*ab) - (body.pos - body.radius*ab)

            ball.pos -= dist_overlap
            ball.vel -= -1.6 * linalg.dot(-ball.vel, ab) * ab
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
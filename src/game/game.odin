package game

import "core:math/linalg"
import rl "vendor:raylib"

import "physics"

mode :  Mode = .Physics
Mode :: enum u8 { Aim, Physics }

world: physics.World
future: physics.World

PATH_POINTS :: 256
ball_path: [PATH_POINTS]rl.Vector2
ball_prev_pos: rl.Vector2

init :: proc() {
    world = physics.init()
    future = physics.init()
}

deinit :: proc() {
    physics.deinit(world)
    physics.deinit(future)
}

update :: proc(dt: f32, cursor: rl.Vector2) {
    if mode == .Aim {
        update_aim(dt, cursor)
        return
    }
    switch mode {
        case .Aim: update_aim(dt, cursor)
        case .Physics:
            handle_input(&world)
            ball_prev_pos = world.ball.pos
            update_physics(&world, dt)

            future.ball = world.ball
            for i in 0..<PATH_POINTS {
                physics.update(&future, 25.0 / PATH_POINTS)
                ball_path[i] = future.ball.pos
            }
    }
}

update_aim :: proc(dt: f32, cursor: rl.Vector2) {
}

update_physics :: proc(world: ^physics.World, dt: f32) {
    physics.update(world, dt)
}

world_draw2d :: proc(w: physics.World) {
    for body in w.bodies {
        rl.DrawCircleV(body.pos, body.radius, rl.SKYBLUE)
    }

    for va, i in ball_path[:PATH_POINTS - 1] {
        vb := ball_path[i+1]
        rl.DrawLineV(va, vb, rl.WHITE)
    }

    rl.DrawCircleV(w.ball.pos, w.ball.radius, rl.RED)
    end := rl.Vector2{linalg.cos(w.ball.angle), linalg.sin(w.ball.angle)}
    rl.DrawLineV(w.ball.pos, w.ball.pos + w.ball.radius * end, rl.WHITE)

    {

        get_point :: proc(rads: f32) -> rl.Vector2 {
            return {linalg.cos(rads), linalg.sin(rads)}
        }

        v1 := get_point(w.ball.angle)
        v2 := get_point(w.ball.angle - 150*rl.DEG2RAD)
        v3 := get_point(w.ball.angle + 150*rl.DEG2RAD)
        p := w.ball.pos
        r := w.ball.radius
        rl.DrawTriangle(p + v1*r, p + v2*r, p + v3*r, rl.WHITE)
    }

    if mode == .Aim {
    }
}

handle_input :: proc(world: ^physics.World) {
    dir: rl.Vector2

    if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT)  do dir.x = -1
    if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do dir.x =  1
    if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP)    do dir.y =  1
    if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN)  do dir.y = -1

    SPEED :: 40
    if dir != 0 {
        dir = linalg.normalize(dir)
        world.ball.angle += linalg.TAU * dir.x * physics.DT

        forward := rl.Vector2{linalg.cos(world.ball.angle), linalg.sin(world.ball.angle)}
        world.ball.vel += SPEED * dir.y * forward * physics.DT
    }
}
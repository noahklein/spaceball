package game

import "core:math/linalg"
import rl "vendor:raylib"
import "physics"

mode :  Mode = .Physics
Mode :: enum u8 { Aim, Physics }

world: physics.World
future: physics.World

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
            update_physics(&world, dt)
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
    if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP)    do dir.y = -1
    if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN)  do dir.y =  1

    if dir != 0 {
        dir = linalg.normalize(dir)
        world.ball.angle += dir.x * physics.DT

        forward := rl.Vector2{linalg.cos(world.ball.angle), linalg.sin(world.ball.angle)}
        world.ball.vel += 10 * dir.y * forward * physics.DT
    }
}
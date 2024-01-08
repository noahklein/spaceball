package game

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
        case .Physics: update_physics(&world, dt)
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

    if mode == .Aim {
    }
}


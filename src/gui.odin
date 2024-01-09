package main

import "core:time"
import rl "vendor:raylib"

import "ngui"
import "game"
import "rlutil"

draw_gui :: proc(camera: ^rl.Camera2D) {
    ngui.update()

     if ngui.begin_panel("Game", {0, 0, 300, 0}) {
        if ngui.flex_row({0.2, 0.4, 0.2, 0.2}) {
            ngui.text("Camera")
            ngui.vec2(&camera.target, label = "Target")
            ngui.float(&camera.zoom, min = 0.5, max = 10, label = "Zoom")
            ngui.float(&camera.rotation, min = -360, max = 360, label = "Angle")
        }

        if ngui.flex_row({0.25, 0.25}) {
            ngui.float(&timescale, min = 0, max = 100, label = "Timescale")
            ngui.arrow(&game.world.ball.vel, "Velocity")
        }

        dur :: proc(prof: rlutil.Profile) -> f32 {
            return f32(time.stopwatch_duration(prof.stopwatch))
        }

        if ngui.flex_row({1}) {
            if ngui.graph_begin("Time", 256, lower = 0, upper = f32(time.Second) / 120) {
                update := rlutil.profile_get("update")
                draw   := rlutil.profile_get("draw")
                ngui.graph_line("Update", dur(update), rl.BLUE)
                ngui.graph_line("Draw", dur(draw), rl.RED)
            }
        }
    }

    rl.DrawFPS(rl.GetScreenWidth() - 80, 0)
}
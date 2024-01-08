package main

import "core:fmt"
import "core:mem"

import rl "vendor:raylib"

import "game"
import "ngui"
import "rlutil"

camera: rl.Camera2D
timescale: f32 = 1

main :: proc() {
    when ODIN_DEBUG {
        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)

        defer {
            if len(track.allocation_map) > 0 {
                fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
                for _, entry in track.allocation_map {
                    fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
                }
            }
            if len(track.bad_free_array) > 0 {
                fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
                for entry in track.bad_free_array {
                    fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
                }
            }
            mem.tracking_allocator_destroy(&track)
        }
    }
    defer free_all(context.temp_allocator)

    rl.SetTraceLogLevel(.ALL if ODIN_DEBUG else .WARNING)
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(1600, 900, "Bullets")
    defer rl.CloseWindow()

    rl.rlEnableSmoothLines()

    // Before we do anything, clear the screen to avoid transparent windows.
    rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
    rl.EndDrawing()

    camera = rl.Camera2D{ zoom = 10, offset = rlutil.screen_size() / 2 }

    ngui.init()
    defer ngui.deinit()

    rlutil.profile_init(2)
    defer rlutil.profile_deinit()

    game.init()
    defer game.deinit()

    for !rl.WindowShouldClose() {
        defer free_all(context.temp_allocator)


        if rlutil.profile_begin("Update") {
            dt := rl.GetFrameTime() * timescale
            cursor := rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)
            game.update(dt, cursor)
        }

        rlutil.profile_begin("Draw")
        rl.BeginDrawing()
        defer rl.EndDrawing()
        rl.ClearBackground(rl.BLACK)

        rl.BeginMode2D(camera)
            game.world_draw2d(game.world)
        rl.EndMode2D()

        draw_gui(&camera)
    }
}
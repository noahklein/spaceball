package ngui

import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"

FONT :: 11
TEXT_COLOR :: rl.WHITE
DARK_TEXT_COLOR :: DEFAULT_BUTTON_COLOR
PANEL_COLOR ::  rl.Color{ 200, 200, 200, 190 }

TITLE_FONT :: FONT
TITLE_HEIGHT :: FONT * 2 + 4
TITLE_COLOR :: rl.MAROON

LABEL_HEIGHT :: FONT + 2

DEFAULT_BUTTON_COLOR :: rl.DARKBLUE
HOVER_BUTTON_COLOR   :: rl.BLUE
ACTIVE_BUTTON_COLOR  :: rl.SKYBLUE

INPUT_PAD :: 2

@(require_results)
button_color :: proc(hover, active: bool, press := false) -> rl.Color {
    mod: rl.Color = {10, 10, 0, 0} if press else 0
    if active {
        return ACTIVE_BUTTON_COLOR + mod
    } else if hover {
        return HOVER_BUTTON_COLOR + mod
    }
    return DEFAULT_BUTTON_COLOR + mod
}

@(require_results)
dark_color :: proc(hover, active: bool) -> rl.Color {
    if active {
        return {80, 80, 80, 255}
    } else if hover {
        return {40, 40, 40, 255}
    }
    return rl.BLACK
}

@(require_results)
title_color :: proc(active: bool) -> rl.Color {
    return rl.RED if active else rl.MAROON
}

@(require_results)
input_color :: proc(hover, active: bool) -> rl.Color {
    color := dark_color(hover, active)
    if hover && rl.IsMouseButtonDown(.LEFT) {
        color += {20, 20, 20, 0}
    }
    return color
}

@(require_results)
slider_color :: proc(hover, active: bool, pct: f32) -> rl.Color {
    mod : rl.Color
    if hover  do mod += {20, 20, 20, 0}
    if active do mod += {20, 20, 20, 0}

    return lerp_color({ 0, 121, 190, 255 }, {0, 140, 210, 255}, pct) + mod
}

// Blinks between white and non_white.
@(require_results)
cursor_color :: proc(non_white := rl.SKYBLUE) -> rl.Color {
    now := rl.GetTime()
    t := math.cos(2 * (now - state.last_keypress_time))
    t *= t

    return lerp_color(rl.WHITE, non_white, f32(t))
}

@(require_results)
lerp_color :: proc(ac, bc: rl.Color, t: f32) -> rl.Color {
    a := linalg.array_cast(ac, f32)
    b := linalg.array_cast(bc, f32)

    v := linalg.lerp(a, b, t)
    v = linalg.clamp(v, a, b)

    return rl.Color(linalg.array_cast(v, u8))
}
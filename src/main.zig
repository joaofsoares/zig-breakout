const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
});

const Bar = struct {
    position: raylib.Vector2,
    width: f32,
    height: f32,
    color: raylib.Color,
};

const Ball = struct {
    position: raylib.Vector2,
    radius: f32,
    color: raylib.Color,
};

const Brick = struct {
    position: raylib.Vector2,
    width: f32,
    height: f32,
    color: raylib.Color,
    is_active: bool,
};

var ball_speed: raylib.Vector2 = .{ .x = 5.0, .y = 4.0 };

const WIDTH: u32 = 800;
const HEIGHT: u32 = 600;

const BRICK_COUNT = 40;
const BRICK_WIDTH = 50;
const BRICK_HEIGHT = 20;

const BRICK_POS_X = 120;
const BRICK_POS_Y = 40;

pub fn main() !void {
    raylib.InitWindow(WIDTH, HEIGHT, "breakout");

    raylib.SetTargetFPS(60);

    const bar: Bar = .{
        .position = .{ .x = WIDTH / 2 - 50, .y = HEIGHT - 100 },
        .width = 100.0,
        .height = 20.0,
        .color = raylib.GREEN,
    };

    const ball: Ball = .{
        .position = .{ .x = WIDTH / 2, .y = HEIGHT - 125 },
        .radius = 10.0,
        .color = raylib.WHITE,
    };

    const allocator = std.heap.page_allocator;
    const bricks = try create_rectangles(allocator);
    defer bricks.deinit();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();

        raylib.ClearBackground(raylib.BLACK);

        for (bricks.items) |brick| {
            const p_x: i32 = @intFromFloat(brick.position.x);
            const p_y: i32 = @intFromFloat(brick.position.y);
            const p_width: i32 = @intFromFloat(brick.width);
            const p_height: i32 = @intFromFloat(brick.height);

            if (brick.is_active) {
                raylib.DrawRectangle(p_x, p_y, p_width, p_height, brick.color);
            }
        }

        raylib.DrawCircleV(ball.position, ball.radius, ball.color);

        raylib.DrawRectangle(bar.position.x, bar.position.y, bar.width, bar.height, bar.color);

        raylib.EndDrawing();
    }

    raylib.CloseWindow();
}

fn create_rectangles(allocator: std.mem.Allocator) !std.ArrayList(Brick) {
    var rectangles = std.ArrayList(Brick).init(allocator);

    var initial_position: f32 = 0.0;

    for (0..10) |_| {
        const orange_brick: Brick = .{
            .position = .{ .x = BRICK_POS_X + initial_position, .y = BRICK_POS_Y },
            .width = BRICK_WIDTH,
            .height = BRICK_HEIGHT,
            .color = raylib.ORANGE,
            .is_active = true,
        };

        const pink_brick: Brick = .{
            .position = .{ .x = BRICK_POS_X + initial_position, .y = BRICK_POS_Y + 40 },
            .width = BRICK_WIDTH,
            .height = BRICK_HEIGHT,
            .color = raylib.PINK,
            .is_active = true,
        };

        const purple_brick: Brick = .{
            .position = .{ .x = BRICK_POS_X + initial_position, .y = BRICK_POS_Y + 80 },
            .width = BRICK_WIDTH,
            .height = BRICK_HEIGHT,
            .color = raylib.PURPLE,
            .is_active = true,
        };

        const red_brick: Brick = .{
            .position = .{ .x = BRICK_POS_X + initial_position, .y = BRICK_POS_Y + 120 },
            .width = BRICK_WIDTH,
            .height = BRICK_HEIGHT,
            .color = raylib.RED,
            .is_active = true,
        };

        try rectangles.append(orange_brick);
        try rectangles.append(pink_brick);
        try rectangles.append(purple_brick);
        try rectangles.append(red_brick);

        initial_position += 60;
    }

    return rectangles;
}

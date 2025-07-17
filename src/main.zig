const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
});

const Ball = struct {
    position: raylib.Vector2,
    radius: f32,
    color: raylib.Color,
};

const Bar = struct {
    position: raylib.Vector2,
    width: f32,
    height: f32,
    color: raylib.Color,
};

const Rectangle = struct {
    identifier: i32,
    position: raylib.Vector2,
    width: f32,
    height: f32,
    color: raylib.Color,
};

pub fn main() !void {
    const screenWidth: i32 = 800;
    const screenHeight: i32 = 450;

    raylib.InitWindow(screenWidth, screenHeight, "breakout");

    raylib.SetTargetFPS(60);

    const ball: Ball = .{
        .position = .{ .x = screenWidth / 2, .y = 330 },
        .radius = 20.0,
        .color = raylib.WHITE,
    };

    const bar: Bar = .{
        .position = .{ .x = screenWidth / 2 - 60, .y = 350 },
        .width = 120.0,
        .height = 20.0,
        .color = raylib.GREEN,
    };

    const allocator = std.heap.page_allocator;
    const rectangles = try create_rectangles(allocator);
    defer rectangles.deinit();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();

        raylib.ClearBackground(raylib.BLACK);

        for (rectangles.items) |rectangle| {
            const p_x: i32 = @intFromFloat(rectangle.position.x);
            const p_y: i32 = @intFromFloat(rectangle.position.y);
            const p_width: i32 = @intFromFloat(rectangle.width);
            const p_height: i32 = @intFromFloat(rectangle.height);
            raylib.DrawRectangle(p_x, p_y, p_width, p_height, rectangle.color);
        }

        raylib.DrawCircle(ball.position.x, ball.position.y, ball.radius, ball.color);

        raylib.DrawRectangle(bar.position.x, bar.position.y, bar.width, bar.height, bar.color);

        raylib.EndDrawing();
    }

    raylib.CloseWindow();
}

fn create_rectangles(allocator: std.mem.Allocator) !std.ArrayList(Rectangle) {
    var rectangles = std.ArrayList(Rectangle).init(allocator);

    var width_position: f32 = 100.0;
    const height_position = 50;
    const rectangle_width = 50;
    const rectangle_height = 25;

    for (0..10) |i| {
        const id: i32 = @intCast(i);

        const rectangle_orange: Rectangle = .{
            .identifier = id,
            .position = .{ .x = width_position, .y = height_position },
            .width = rectangle_width,
            .height = rectangle_height,
            .color = raylib.ORANGE,
        };

        const rectangle_pink: Rectangle = .{
            .identifier = id + 10,
            .position = .{ .x = width_position, .y = height_position + 40 },
            .width = rectangle_width,
            .height = rectangle_height,
            .color = raylib.PINK,
        };

        const rectangle_purple: Rectangle = .{
            .identifier = id + 20,
            .position = .{ .x = width_position, .y = height_position + 80 },
            .width = rectangle_width,
            .height = rectangle_height,
            .color = raylib.PURPLE,
        };

        const rectangle_red: Rectangle = .{
            .identifier = id + 30,
            .position = .{ .x = width_position, .y = height_position + 120 },
            .width = rectangle_width,
            .height = rectangle_height,
            .color = raylib.RED,
        };

        try rectangles.append(rectangle_orange);
        try rectangles.append(rectangle_pink);
        try rectangles.append(rectangle_purple);
        try rectangles.append(rectangle_red);

        width_position += 60;
    }

    return rectangles;
}

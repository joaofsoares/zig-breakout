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

pub fn main() !void {
    const WIDTH: u32 = 800;
    const HEIGHT: u32 = 600;

    var ball_speed: raylib.Vector2 = .{ .x = 5.0, .y = 4.0 };

    raylib.InitWindow(WIDTH, HEIGHT, "breakout");

    raylib.SetTargetFPS(60);

    var bar: Bar = .{
        .position = .{ .x = WIDTH / 2 - 50, .y = HEIGHT - 100 },
        .width = 100.0,
        .height = 20.0,
        .color = raylib.GREEN,
    };

    var ball: Ball = .{
        .position = .{ .x = WIDTH / 2, .y = HEIGHT - 125 },
        .radius = 10.0,
        .color = raylib.WHITE,
    };

    const allocator = std.heap.page_allocator;
    const bricks = try create_rectangles(allocator);
    defer bricks.deinit();

    const BRICK_COUNT = 40;
    var start_pressed = false;
    var win = false;
    var remaining_bricks: u32 = BRICK_COUNT;
    var collision_brick: bool = false;
    var collision_bar: bool = false;

    while (!raylib.WindowShouldClose()) {
        if (raylib.IsKeyPressed(raylib.KEY_SPACE) and !start_pressed) {
            start_pressed = true;
        }

        if (raylib.IsKeyDown(raylib.KEY_RIGHT) and bar.position.x < WIDTH - bar.width) {
            bar.position.x += 10;
        }

        if (raylib.IsKeyDown(raylib.KEY_LEFT) and bar.position.x > 0) {
            bar.position.x -= 10;
        }

        for (0..BRICK_COUNT) |i| {
            collision_brick = raylib.CheckCollisionCircleRec(ball.position, ball.radius, raylib.Rectangle{ .x = bricks.items[i].position.x, .y = bricks.items[i].position.y, .width = bricks.items[i].width, .height = bricks.items[i].height });

            if (collision_brick and bricks.items[i].is_active) {
                bricks.items[i].is_active = false;
                remaining_bricks -= 1;
                ball_speed.y *= -1.0;
                if (ball.position.x < bricks.items[i].position.x or
                    ball.position.x > bricks.items[i].position.x + bricks.items[i].width)
                {
                    ball_speed.x *= -1.0;
                }
            }
        }

        collision_bar = raylib.CheckCollisionCircleRec(ball.position, ball.radius, raylib.Rectangle{ .x = bar.position.x, .y = bar.position.y, .width = bar.width, .height = bar.height });

        if (collision_bar) {
            if (ball.position.y + ball.radius >= bar.position.y) {
                ball_speed.y *= -1.0;
            }
            if (ball.position.x < bar.position.x or ball.position.x > bar.position.x + bar.width) {
                ball_speed.x *= -1.0;
            }
        }

        if (!win and start_pressed) {
            ball.position.x += ball_speed.x;
            ball.position.y += ball_speed.y;

            if ((ball.position.x >= (WIDTH - ball.radius)) or
                (ball.position.x <= ball.radius))
            {
                ball_speed.x *= -1.0;
            }

            if ((ball.position.y >= (HEIGHT - ball.radius)) or
                (ball.position.y <= ball.radius))
            {
                ball_speed.y *= -1.0;
            }
        }

        raylib.BeginDrawing();

        raylib.ClearBackground(raylib.BLACK);

        for (bricks.items) |brick| {
            if (brick.is_active) {
                raylib.DrawRectangle(@intFromFloat(brick.position.x), @intFromFloat(brick.position.y), @intFromFloat(brick.width), @intFromFloat(brick.height), brick.color);
            }
        }

        raylib.DrawCircleV(ball.position, ball.radius, ball.color);

        raylib.DrawRectangle(@intFromFloat(bar.position.x), @intFromFloat(bar.position.y), @intFromFloat(bar.width), @intFromFloat(bar.height), bar.color);

        if (remaining_bricks == 0) {
            win = true;
            const message_size: u32 = @intCast(@divTrunc(raylib.MeasureText("You win!", 20), 2));
            const message_calc_x: c_int = @intCast(WIDTH / 2 - message_size);
            raylib.DrawText("You win!", message_calc_x, HEIGHT / 2 - 10, 20, raylib.GREEN);
        }

        raylib.EndDrawing();
    }

    raylib.CloseWindow();
}

fn create_rectangles(allocator: std.mem.Allocator) !std.ArrayList(Brick) {
    const BRICK_WIDTH = 50;
    const BRICK_HEIGHT = 20;

    const BRICK_POS_X = 120;
    const BRICK_POS_Y = 40;
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

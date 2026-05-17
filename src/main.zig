const std = @import("std");
const rl = @import("raylib");
const flecs = @import("flecs");
const ecs = @import("ecs.zig");

pub fn main(_: std.process.Init) !void {
    std.debug.print("Centipede!\n", .{});

    const width = 800;
    const height = 450;

    rl.initWindow(width, height, "centipede");
    rl.setTargetFPS(60);

    const world = flecs.init();
    defer _ = flecs.fini(world);

    flecs.COMPONENT(world, ecs.Position);
    flecs.COMPONENT(world, ecs.Velocity);
    flecs.TAG(world, ecs.Player);
    flecs.TAG(world, ecs.Bullet);

    const player_entity = flecs.new_entity(world, "Player");
    _ = flecs.set(world, player_entity, ecs.Position, .{ .x = 200, .y = 200 });
    flecs.add(world, player_entity, ecs.Player);

    var player_desc = flecs.query_desc_t{};
    player_desc.terms[0].id = flecs.id(ecs.Position);
    player_desc.terms[1].id = flecs.id(ecs.Player);
    const player_query = try flecs.query_init(world, &player_desc);
    defer flecs.query_fini(player_query);

    var bullet_desc = flecs.query_desc_t{};
    bullet_desc.terms[0].id = flecs.id(ecs.Position);
    bullet_desc.terms[1].id = flecs.id(ecs.Bullet);
    const bullet_query = try flecs.query_init(world, &bullet_desc);
    defer flecs.query_fini(bullet_query);

    var pos_vel_desc = flecs.query_desc_t{};
    pos_vel_desc.terms[0].id = flecs.id(ecs.Position);
    pos_vel_desc.terms[1].id = flecs.id(ecs.Velocity);
    const q = try flecs.query_init(world, &pos_vel_desc);
    defer flecs.query_fini(q);

    while (rl.windowShouldClose() == false) {
        rl.beginDrawing();
        rl.clearBackground(.red);
        rl.drawText("hello world!", 100, 100, 48, .white);

        var player_it = flecs.query_iter(world, player_query);
        while (flecs.query_next(&player_it)) {
            for (player_it.entities()) |ent| {
                _ = ent;
                std.debug.print("player display...\n", .{});
            }
        }

        var bullet_it = flecs.query_iter(world, bullet_query);
        while (flecs.query_next(&bullet_it)) {
            const p = flecs.field(&bullet_it, ecs.Position, 0) orelse undefined;
            for (bullet_it.entities(), 0..) |_, i| {
                std.debug.print("bullet display... {d}\n", .{i});
                const x: i32 = @intFromFloat(p[i].x);
                const y: i32 = @intFromFloat(p[i].y);
                rl.drawRectangle(x, y, 20, 20, .white);
            }
        }
        rl.endDrawing();

        if (rl.isKeyDown(.space)) {
            const bullet_entity = flecs.new_id(world);
            _ = flecs.set(world, bullet_entity, ecs.Position, .{ .x = 200, .y = 200 });
            _ = flecs.set(world, bullet_entity, ecs.Velocity, .{ .x = 0, .y = 1 });
            flecs.add(world, bullet_entity, ecs.Bullet);
        }

        var pvit = flecs.query_iter(world, q);
        while (flecs.query_next(&pvit)) {
            // flecs.field(it: *iter_t, comptime T: type, index: i8)
            const p = flecs.field(&pvit, ecs.Position, 0) orelse undefined;
            const v = flecs.field(&pvit, ecs.Velocity, 1) orelse undefined;
            for (pvit.entities(), 0..) |_, index| {
                p[index].x = p[index].x + v[index].x;
                p[index].y = p[index].y + v[index].y;
            }
        }
    }

    rl.closeWindow();
}

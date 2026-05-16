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
            for (bullet_it.entities()) |ent| {
                _ = ent;
                std.debug.print("bullet display...\n", .{});
            }
        }
        rl.endDrawing();
    }

    rl.closeWindow();
}

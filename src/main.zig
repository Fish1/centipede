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
    flecs.COMPONENT(world, ecs.DebugRender);
    flecs.TAG(world, ecs.Player);
    flecs.TAG(world, ecs.Bullet);

    const player_entity = flecs.new_entity(world, "Player");
    _ = flecs.set(world, player_entity, ecs.Position, .{ .x = 100, .y = 100 });
    _ = flecs.set(world, player_entity, ecs.Velocity, .{ .x = 0, .y = 0 });
    _ = flecs.set(world, player_entity, ecs.DebugRender, .{ .dummy = true });
    flecs.add(world, player_entity, ecs.Player);

    var player_desc = flecs.query_desc_t{};
    player_desc.terms[0].id = flecs.id(ecs.Velocity);
    player_desc.terms[1].id = flecs.id(ecs.Player);
    const player_query = try flecs.query_init(world, &player_desc);
    defer flecs.query_fini(player_query);

    var bullet_desc = flecs.query_desc_t{};
    bullet_desc.terms[0].id = flecs.id(ecs.Position);
    bullet_desc.terms[1].id = flecs.id(ecs.Bullet);
    const bullet_query = try flecs.query_init(world, &bullet_desc);
    defer flecs.query_fini(bullet_query);

    var debug_render_desc = flecs.query_desc_t{};
    debug_render_desc.terms[0].id = flecs.id(ecs.DebugRender);
    debug_render_desc.terms[1].id = flecs.id(ecs.Position);
    const debug_render_query = try flecs.query_init(world, &debug_render_desc);
    defer flecs.query_fini(debug_render_query);

    var position_velocity_desc = flecs.query_desc_t{};
    position_velocity_desc.terms[0].id = flecs.id(ecs.Position);
    position_velocity_desc.terms[1].id = flecs.id(ecs.Velocity);
    const position_velocity_query = try flecs.query_init(world, &position_velocity_desc);
    defer flecs.query_fini(position_velocity_query);

    while (rl.windowShouldClose() == false) {
        rl.beginDrawing();
        rl.clearBackground(.black);
        rl.drawText("Centipede!", 24, 24, 48, .white);

        debug_render(world, debug_render_query);

        rl.endDrawing();

        if (rl.isKeyDown(.space)) {
            shoot(world);
        }

        control_player(world, player_query);
        update_positions(world, position_velocity_query);
    }

    rl.closeWindow();
}

fn shoot(world: *flecs.world_t) void {
    const bullet_entity = flecs.new_id(world);
    _ = flecs.set(world, bullet_entity, ecs.Position, .{ .x = 200, .y = 200 });
    _ = flecs.set(world, bullet_entity, ecs.Velocity, .{ .x = 0, .y = 1 });
    _ = flecs.set(world, bullet_entity, ecs.DebugRender, .{ .dummy = true });
    flecs.add(world, bullet_entity, ecs.Bullet);
}

fn debug_render(world: *flecs.world_t, query: *flecs.query_t) void {
    var bullet_it = flecs.query_iter(world, query);
    while (flecs.query_next(&bullet_it)) {
        const position = flecs.field(&bullet_it, ecs.Position, 1) orelse undefined;
        for (bullet_it.entities(), 0..) |_, i| {
            const x: i32 = @intFromFloat(position[i].x);
            const y: i32 = @intFromFloat(position[i].y);
            rl.drawRectangle(x - 4, y - 4, 8, 8, .white);
        }
    }
}

fn control_player(world: *flecs.world_t, query: *flecs.query_t) void {
    var player_it = flecs.query_iter(world, query);
    while (flecs.query_next(&player_it)) {
        const velocity = flecs.field(&player_it, ecs.Velocity, 0) orelse undefined;
        for (player_it.entities(), 0..) |_, i| {
            velocity[i].y = 0;
            if (rl.isKeyDown(.up)) {
                velocity[i].y = velocity[i].y - 1;
            }
            if (rl.isKeyDown(.down)) {
                velocity[i].y = velocity[i].y + 1;
            }

            velocity[i].x = 0;
            if (rl.isKeyDown(.left)) {
                velocity[i].x = velocity[i].x - 1;
            }
            if (rl.isKeyDown(.right)) {
                velocity[i].x = velocity[i].x + 1;
            }
        }
    }
}

fn update_positions(world: *flecs.world_t, query: *flecs.query_t) void {
    var pvit = flecs.query_iter(world, query);
    while (flecs.query_next(&pvit)) {
        const p = flecs.field(&pvit, ecs.Position, 0) orelse undefined;
        const v = flecs.field(&pvit, ecs.Velocity, 1) orelse undefined;
        for (pvit.entities(), 0..) |_, index| {
            p[index].x = p[index].x + v[index].x;
            p[index].y = p[index].y + v[index].y;
        }
    }
}

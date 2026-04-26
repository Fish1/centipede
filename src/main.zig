const std = @import("std");
const rl = @import("raylib");

pub fn main(_: std.process.Init) !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const width = 800;
    const height = 450;

    rl.initWindow(width, height, "centipede");
    rl.setTargetFPS(30);

    while (rl.windowShouldClose() == false) {
        rl.beginDrawing();
        rl.clearBackground(.red);
        rl.drawText("hello world!", 100, 100, 12, .white);
        rl.endDrawing();
    }

    rl.closeWindow();
}

const std = @import("std");

const types = @import("types.zig");
const tga = @import("tga.zig");
const raytracer = @import("raytracer.zig");

pub fn main() !void {
    var timer: std.time.Timer = try std.time.Timer.start();
    //
    const w: u32 = 1080;
    const h: u32 = 720;
    var pixels: [w * h]types.Color = [1]types.Color{types.Color.BLACK} ** (w * h);
    try raytracer.process_image(w, h, &pixels);
    const tracing_time = timer.lap();
    //
    try tga.writeTGA(w, h, &pixels);
    const writing_time = timer.lap();
    //
    std.debug.print("Tracing Time: {} (ms)\n", .{tracing_time / std.time.ns_per_ms});
    std.debug.print("Writing Time: {} (ms)\n", .{writing_time / std.time.ns_per_ms});
}

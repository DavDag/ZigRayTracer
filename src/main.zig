const std = @import("std");

const types = @import("types.zig");
const tga = @import("tga.zig");
const raytracer = @import("raytracer.zig");
const Camera = @import("camera.zig").Camera;
const Sphere = @import("sphere.zig").Sphere;
const Scene = @import("scene.zig").Scene;

const Color = types.Color;
const Vec3 = types.Vec3;
const Material = types.Material;

fn createScene(allocator: std.mem.Allocator) !Scene {
    _ = allocator;
    const w: u32 = 1080;
    const h: u32 = 720;
    const samples: u32 = 32;
    const max_depth: u32 = 8;
    const gamma: f32 = 2.2;
    const num_threads: u32 = 24;
    const job_size: u32 = 16;
    const camera: Camera = .{
        .fovy = 45.0,
        .position = .{ .x = 0, .y = 0, .z = 1 },
        .target = .{ .x = 0, .y = 0, .z = 0 },
    };
    const materials: [2]Material = .{
        .{ .albedo = .{ .r = 0.5, .g = 0.5, .b = 0.5 }, .blurr = 1.0, .refraction_ratio = 0.0 },
        .{ .albedo = .{ .r = 0.2, .g = 1.0, .b = 1.0 }, .blurr = 0.8, .refraction_ratio = 0.0 },
    };
    const spheres: [2]Sphere = .{
        .{ .cen = .{ .x = 0, .y = -100.5, .z = 0 }, .rad = 100, .mat = &materials[0] },
        .{ .cen = .{ .x = 0, .y = 0, .z = 0 }, .rad = 0.5, .mat = &materials[1] },
    };
    return .{
        .w = w,
        .h = h,
        .samples = samples,
        .max_depth = max_depth,
        .gamma = gamma,
        .num_threads = num_threads,
        .job_size = job_size,
        .camera = camera,
        .spheres = &spheres,
        .materials = &materials,
    };
}

pub fn main() !void {
    var timer: std.time.Timer = try std.time.Timer.start();

    var scene = try createScene(std.heap.page_allocator);
    try scene.init(std.heap.page_allocator);
    defer scene.deinit();
    try raytracer.process_scene(scene);
    const tracing_time = timer.lap();

    try tga.writeTGA(std.heap.page_allocator, scene.w, scene.h, scene._out.?);
    const writing_time = timer.lap();

    std.debug.print("Tracing Time: {}ms\n", .{tracing_time / std.time.ns_per_ms});
    std.debug.print("Writing Time: {}ms\n", .{writing_time / std.time.ns_per_ms});
}

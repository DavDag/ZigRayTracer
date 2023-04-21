const std = @import("std");
const types = @import("types.zig");
const Camera = @import("camera.zig").Camera;
const Sphere = @import("sphere.zig").Sphere;
const Scene = @import("scene.zig").Scene;

const Color = types.Color;
const Vec3 = types.Vec3;
const Ray = types.Ray;
const RayHit = types.RayHit;
const Material = types.Material;

pub fn process_scene(scene: Scene) !void {
    if (scene.num_threads < 2) {
        for (0..scene.h) |y| {
            for (0..scene.w) |x| {
                const x_u32 = @intCast(u32, x);
                const y_u32 = @intCast(u32, y);
                const c: Color = process_pixel(scene, x_u32, y_u32);
                scene._out.?[y_u32 * scene.w + x_u32] = c;
            }
        }
    } else {
        var job_index: u32 = 0;
        var threads: [256]std.Thread = undefined;
        for (0..scene.num_threads) |i| {
            threads[i] = try std.Thread.spawn(.{}, process_job, .{ i, scene, &job_index });
        }
        for (0..scene.num_threads) |i| {
            threads[i].join();
        }
    }
}

fn process_job(thread_id: usize, scene: Scene, job_index: *u32) !void {
    std.debug.print("[{d: >2}]: Running\n", .{thread_id});

    const jobs_count_x: u32 = try std.math.divCeil(u32, scene.w, scene.job_size);
    const jobs_count_y: u32 = try std.math.divCeil(u32, scene.h, scene.job_size);
    const jobs_count = jobs_count_x * jobs_count_y;

    var timer = try std.time.Timer.start();
    var processing: u64 = 0;
    var processed: u64 = 0;
    while (true) {
        const index = @atomicRmw(u32, job_index, .Add, 1, .Monotonic);
        if (index >= jobs_count) break;

        const sy: u32 = @divTrunc(index, jobs_count_x) * scene.job_size;
        const sx: u32 = @rem(index, jobs_count_x) * scene.job_size;
        const ey: u32 = @min(sy + scene.job_size, scene.h);
        const ex: u32 = @min(sx + scene.job_size, scene.w);

        for (sy..ey) |y| {
            for (sx..ex) |x| {
                const x_u32 = @intCast(u32, x);
                const y_u32 = @intCast(u32, y);
                const c: Color = process_pixel(scene, x_u32, y_u32);
                scene._out.?[y_u32 * scene.w + x_u32] = c;
            }
        }
        processing += timer.lap();
        processed += 1;
    }
    const processing_ms = processing / std.time.ns_per_ms;
    const processing_avg_ms = processing_ms / processed;
    std.debug.print(
        "[{d: >2}]: {d: >3}(ms) / {d: >6}(ms) | {d: >4}#\n",
        .{ thread_id, processing_avg_ms, processing_ms, processed },
    );
}

fn process_pixel(scene: Scene, px: u32, py: u32) Color {
    const px_f32 = @intToFloat(f32, px);
    const py_f32 = @intToFloat(f32, py);
    var res: Color = Color.BLACK;
    for (0..scene.samples) |_| {
        const offx: f32 = types.Rnd_f32();
        const offy: f32 = types.Rnd_f32();
        const dx = (px_f32 + offx) / scene._w_f32;
        const dy = (py_f32 + offy) / scene._h_f32;
        const ray = scene.camera.getRayFor(dx, dy);
        const col = trace(scene, ray, scene.max_depth);
        res.add(col);
    }
    const samples_f32 = @intToFloat(f32, scene.samples);
    res.div(samples_f32);
    res.gamma(scene.gamma);
    return res;
}

fn trace(scene: Scene, ray: Ray, depth: u32) Color {
    if (depth == 0) {
        return Color.BLACK;
    }
    var payload: RayHit = .{ .tmin = 0.0001, .tmax = std.math.inf_f32 };
    if (scene.hit(ray, &payload)) {
        var sca: Ray = .{};
        var att: Color = .{};
        if (payload.mat.?.*.scatter(ray, payload, &att, &sca)) {
            const res = trace(scene, sca, depth - 1);
            att.combine(res);
            return att;
        }
        return Color.BLACK;
    } else {
        const t = (ray.dir.y + 1) / 2;
        return Color.Mix(scene.sky_color_a, scene.sky_color_b, t);
    }
}

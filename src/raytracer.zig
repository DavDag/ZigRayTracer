const std = @import("std");
const types = @import("types.zig");
const Camera = @import("camera.zig").Camera;
const Sphere = @import("sphere.zig").Sphere;

const Color = types.Color;
const Vec3 = types.Vec3;
const Ray = types.Ray;
const RayHit = types.RayHit;
const Material = types.Material;

var cam: Camera = .{
    .f = 45.0,
    .p = .{ .x = 0, .y = 0, .z = 1 },
    .t = .{ .x = 0, .y = 0, .z = 0 },
};

pub fn process_image(comptime w: u32, comptime h: u32, out_image: []Color) !void {
    const w_f32 = @intToFloat(f32, w);
    const h_f32 = @intToFloat(f32, h);
    cam.a = w_f32 / h_f32;
    cam.init();

    var y: u32 = 0;
    while (y < h) : (y += 1) {
        var x: u32 = 0;
        while (x < w) : (x += 1) {
            const x_f32 = @intToFloat(f32, x);
            const y_f32 = @intToFloat(f32, y);
            var c: Color = process_pixel(x_f32, y_f32, w_f32, h_f32);
            c.gamma(2.0);
            out_image[y * w + x] = c;
        }
    }
}

fn process_pixel(px: f32, py: f32, w: f32, h: f32) Color {
    const samples: u32 = 32;
    const max_depth: u32 = 8;
    var res: Color = Color.BLACK;
    for (0..samples) |_| {
        const offx: f32 = types.Rnd_f32();
        const offy: f32 = types.Rnd_f32();
        const dx = (px + offx) / w;
        const dy = (py + offy) / h;
        const ray = cam.getRayFor(dx, dy);
        const col = trace(ray, max_depth);
        res.add(col);
    }
    const samples_f32: f32 = @intToFloat(f32, samples);
    res.div(samples_f32);
    return res;
}

const ground_mat: Material = .{
    .a = .{ .r = 0.5, .g = 0.5, .b = 0.5 },
    .b = 1,
    .r = 0,
};
const middle_mat: Material = .{
    .a = .{ .r = 1.0, .g = 1.0, .b = 1.0 },
    .b = 1,
    .r = 0,
};
const ground_sphere: Sphere = .{
    .c = .{ .x = 0, .y = -100.5, .z = 0 },
    .r = 100,
    .m = &ground_mat,
};
const middle_sphere: Sphere = .{
    .c = .{ .x = 0, .y = 0, .z = 0 },
    .r = 0.5,
    .m = &middle_mat,
};

fn trace(ray: Ray, depth: u32) Color {
    if (depth == 0) {
        return Color.BLACK;
    }

    var payload: RayHit = .{ .tmin = 0.0001, .tmax = std.math.inf_f32 };
    _ = ground_sphere.hit(ray, &payload);
    _ = middle_sphere.hit(ray, &payload);

    if (payload.m != null) {
        var sca: Ray = .{};
        var att: Color = .{};
        if (payload.m.?.*.scatter(ray, payload, &att, &sca)) {
            const res = trace(sca, depth - 1);
            return .{ .r = att.r * res.r, .g = att.g * res.g, .b = att.b * res.b };
        }
        return Color.BLACK;
    } else {
        const sky_color_a: Color = .{ .r = 1.0, .g = 1.0, .b = 1.0 };
        const sky_color_b: Color = .{ .r = 0.5, .g = 0.7, .b = 1.0 };
        const t = (ray.d.y + 1) / 2;
        return Color.Mix(sky_color_a, sky_color_b, t);
    }
}

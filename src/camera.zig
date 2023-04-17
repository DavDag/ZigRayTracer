const std = @import("std");
const types = @import("types.zig");

const Vec3 = types.Vec3;
const Ray = types.Ray;

pub const Camera = struct {
    f: f32 = 0, // fov
    a: f32 = 0, // aspect ratio
    p: Vec3 = .{}, // camera position
    t: Vec3 = .{}, // camera target
    inc_x: Vec3 = .{},
    inc_y: Vec3 = .{},

    pub fn init(self: *Camera) void {
        self.inc_x = .{};
        self.inc_y = .{};

        const theta = std.math.degreesToRadians(f32, self.f);
        const viewh = 2 * std.math.tan(theta / 2);
        const vieww = self.a * viewh;

        var w: Vec3 = .{};
        w.add(self.p);
        w.sub(self.t);

        const u: Vec3 = Vec3.Cross(.{ .x = 0, .y = 1, .z = 0 }, w);
        const v: Vec3 = Vec3.Cross(w, u);

        self.inc_x.add(u);
        self.inc_y.add(v);

        self.inc_x.mul(vieww);
        self.inc_y.mul(viewh);
    }

    pub fn getRayFor(self: Camera, px: f32, py: f32) Ray {
        const x = px * 2 - 1;
        const y = py * 2 - 1;

        var inc_x: Vec3 = .{};
        inc_x.add(self.inc_x);
        inc_x.mul(x);

        var inc_y: Vec3 = .{};
        inc_y.add(self.inc_y);
        inc_y.mul(y);

        var ray_orig: Vec3 = .{};
        ray_orig.add(self.p);

        var ray_dir: Vec3 = .{};
        ray_dir.add(inc_x);
        ray_dir.sub(inc_y);
        ray_dir.sub(ray_orig);
        ray_dir.unit();

        const res: Ray = .{
            .o = ray_orig,
            .d = ray_dir,
        };
        return res;
    }
};

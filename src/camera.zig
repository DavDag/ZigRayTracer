const std = @import("std");
const types = @import("types.zig");
const Scene = @import("scene.zig").Scene;

const Vec3 = types.Vec3;
const Ray = types.Ray;

pub const Camera = struct {
    fovy: f32 = 0,
    position: Vec3 = .{},
    target: Vec3 = .{},
    _inc_x: Vec3 = .{},
    _inc_y: Vec3 = .{},

    pub fn init(self: *Camera, scene: Scene) void {
        const aspect: f32 = scene._w_f32 / scene._h_f32;
        self._inc_x = .{};
        self._inc_y = .{};

        const theta = std.math.degreesToRadians(f32, self.fovy);
        const viewh = 2 * std.math.tan(theta / 2);
        const vieww = aspect * viewh;

        var w: Vec3 = .{};
        w.add(self.position);
        w.sub(self.target);

        const u: Vec3 = Vec3.Cross(.{ .x = 0, .y = 1, .z = 0 }, w);
        const v: Vec3 = Vec3.Cross(w, u);

        self._inc_x.add(u);
        self._inc_y.add(v);

        self._inc_x.mul(vieww);
        self._inc_y.mul(viewh);
    }

    pub fn getRayFor(self: Camera, px: f32, py: f32) Ray {
        const x = px * 2 - 1;
        const y = py * 2 - 1;

        var inc_x: Vec3 = .{};
        inc_x.add(self._inc_x);
        inc_x.mul(x);

        var inc_y: Vec3 = .{};
        inc_y.add(self._inc_y);
        inc_y.mul(y);

        var ray_orig: Vec3 = .{};
        ray_orig.add(self.position);

        var ray_dir: Vec3 = .{};
        ray_dir.add(inc_x);
        ray_dir.sub(inc_y);
        ray_dir.sub(ray_orig);
        ray_dir.unit();

        const res: Ray = .{
            .orig = ray_orig,
            .dir = ray_dir,
        };
        return res;
    }
};

const std = @import("std");
const types = @import("types.zig");
const Camera = @import("camera.zig").Camera;
const Sphere = @import("sphere.zig").Sphere;

const Color = types.Color;
const Vec3 = types.Vec3;
const Ray = types.Ray;
const RayHit = types.RayHit;
const Material = types.Material;

pub const Scene = struct {
    w: u32 = 0,
    h: u32 = 0,
    samples: u32 = 0,
    max_depth: u32 = 0,
    gamma: f32 = 0,
    sky_color_a: Color = Color.BLACK,
    sky_color_b: Color = Color.BLACK,
    num_threads: u32 = 0,
    job_size: u32 = 0,
    camera: Camera = .{},
    spheres: ?[]const Sphere = null,
    materials: ?[]const Material = null,
    _allocator: ?std.mem.Allocator = null,
    _out: ?[]Color = null,
    _w_f32: f32 = 0,
    _h_f32: f32 = 0,

    pub fn init(self: *Scene, allocator: std.mem.Allocator) !void {
        self._w_f32 = @intToFloat(f32, self.w);
        self._h_f32 = @intToFloat(f32, self.h);
        self.camera.init(self.*);
        self._allocator = allocator;
        self._out = try allocator.alloc(Color, self.w * self.h);
        std.mem.set(Color, self._out.?, Color.BLACK);
    }

    pub fn hit(self: Scene, ray: Ray, payload: *RayHit) bool {
        var res: bool = false;
        for (self.spheres.?) |sphere| {
            const tmp: bool = sphere.hit(ray, payload);
            res = tmp or res;
        }
        return res;
    }

    pub fn deinit(self: *Scene) void {
        self._allocator.?.free(self._out.?);
    }
};

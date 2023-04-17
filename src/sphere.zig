const std = @import("std");
const types = @import("types.zig");

const Vec3 = types.Vec3;
const Ray = types.Ray;
const RayHit = types.RayHit;
const Material = types.Material;

pub const Sphere = struct {
    c: Vec3 = .{}, // sphere center
    r: f32 = 0, // sphere radius
    m: ?*const Material = null, // sphere material

    pub fn hit(self: Sphere, ray: Ray, payload: *RayHit) bool {
        var oc: Vec3 = .{};
        oc.add(ray.o);
        oc.sub(self.c);

        const a: f32 = ray.d.len2();
        const half_b: f32 = Vec3.Dot(oc, ray.d);
        const c: f32 = oc.len2() - (self.r * self.r);

        const d = half_b * half_b - a * c;
        if (d < 0) return false;

        const sqrt_d = @sqrt(d);
        const x1 = (-half_b - sqrt_d) / a;
        const x2 = (-half_b - sqrt_d) / a;

        var res = x1;
        if (res < payload.tmin or res > payload.tmax) res = x2;
        if (res < payload.tmin or res > payload.tmax) return false;

        const hit_p = ray.at(res);

        var hit_n: Vec3 = .{};
        hit_n.add(hit_p);
        hit_n.sub(self.c);
        hit_n.div(self.r);
        const front_facing = Vec3.Dot(ray.d, hit_n) < 0;
        if (!front_facing) {
            hit_n.mul(-1);
        }

        payload.m = self.m;
        payload.p = hit_p;
        payload.n = hit_n;
        payload.t = res;
        payload.tmax = res;

        return true;
    }
};

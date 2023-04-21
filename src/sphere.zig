const std = @import("std");
const types = @import("types.zig");

const Vec3 = types.Vec3;
const Ray = types.Ray;
const RayHit = types.RayHit;
const Material = types.Material;

pub const Sphere = struct {
    cen: Vec3 = .{},
    rad: f32 = 0,
    mat: ?*const Material = null,

    pub fn hit(self: Sphere, ray: Ray, payload: *RayHit) bool {
        var oc: Vec3 = .{};
        oc.add(ray.orig);
        oc.sub(self.cen);

        const a: f32 = ray.dir.len2();
        const half_b: f32 = Vec3.Dot(oc, ray.dir);
        const c: f32 = oc.len2() - (self.rad * self.rad);

        const d = half_b * half_b - a * c;
        if (d < 0) return false;

        const sqrt_d = @sqrt(d);
        const x1 = (-half_b - sqrt_d) / a;
        const x2 = (-half_b + sqrt_d) / a;

        var res = x1;
        if (res < payload.tmin or res > payload.tmax) res = x2;
        if (res < payload.tmin or res > payload.tmax) return false;

        const hit_p = ray.at(res);

        var hit_n: Vec3 = .{};
        hit_n.add(hit_p);
        hit_n.sub(self.cen);
        hit_n.div(self.rad);
        hit_n.unit();
        const front_facing = Vec3.Dot(ray.dir, hit_n) < 0;
        if (!front_facing) {
            hit_n.mul(-1);
        }

        payload.mat = self.mat;
        payload.pos = hit_p;
        payload.norm = hit_n;
        payload.tmax = res;

        return true;
    }
};

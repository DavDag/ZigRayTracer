const std = @import("std");

var rnd_gen = std.rand.DefaultPrng.init(0);
var rnd_inst = rnd_gen.random();
pub fn Rnd_f32() f32 {
    return rnd_inst.float(f32);
}

pub const Color = struct {
    r: f32 = 0,
    g: f32 = 0,
    b: f32 = 0,

    pub const WHITE: Color = .{ .r = 1.0, .g = 1.0, .b = 1.0 };
    pub const BLACK: Color = .{ .r = 0.0, .g = 0.0, .b = 0.0 };

    pub fn add(self: *Color, other: Color) void {
        self.r += other.r;
        self.g += other.g;
        self.b += other.b;
    }

    pub fn mul(self: *Color, scalar: f32) void {
        self.r *= scalar;
        self.g *= scalar;
        self.b *= scalar;
    }

    pub fn div(self: *Color, scalar: f32) void {
        const tmp: f32 = 1.0 / scalar;
        self.r *= tmp;
        self.g *= tmp;
        self.b *= tmp;
    }

    pub fn gamma(self: *Color, comptime scalar: f32) void {
        const exp: f32 = 1.0 / scalar;
        self.r = std.math.pow(f32, self.r, exp);
        self.g = std.math.pow(f32, self.g, exp);
        self.b = std.math.pow(f32, self.b, exp);
    }

    pub fn Mix(a: Color, b: Color, t: f32) Color {
        var tmp_a: Color = .{};
        tmp_a.add(a);
        tmp_a.mul(1 - t);
        var tmp_b: Color = .{};
        tmp_b.add(b);
        tmp_b.mul(t);
        var res: Color = .{};
        res.add(tmp_a);
        res.add(tmp_b);
        return res;
    }
};

pub const Vec3 = struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,

    pub fn add(self: *Vec3, other: Vec3) void {
        self.x += other.x;
        self.y += other.y;
        self.z += other.z;
    }

    pub fn sub(self: *Vec3, other: Vec3) void {
        self.x -= other.x;
        self.y -= other.y;
        self.z -= other.z;
    }

    pub fn mul(self: *Vec3, scalar: f32) void {
        self.x *= scalar;
        self.y *= scalar;
        self.z *= scalar;
    }

    pub fn div(self: *Vec3, scalar: f32) void {
        const tmp: f32 = 1.0 / scalar;
        self.x *= tmp;
        self.y *= tmp;
        self.z *= tmp;
    }

    pub fn len(self: Vec3) f32 {
        return std.math.sqrt(self.len2());
    }

    pub fn len2(self: Vec3) f32 {
        return (self.x * self.x) + (self.y * self.y) + (self.z * self.z);
    }

    pub fn unit(self: *Vec3) void {
        const w = self.len();
        self.div(w);
    }

    pub fn Dot(veca: Vec3, vecb: Vec3) f32 {
        return (veca.x * vecb.x) + (veca.y * vecb.y) + (veca.z * vecb.z);
    }

    pub fn Cross(veca: Vec3, vecb: Vec3) Vec3 {
        const res: Vec3 = .{
            .x = (veca.y * vecb.z - vecb.y * veca.z),
            .y = (veca.z * vecb.x - vecb.z * veca.x),
            .z = (veca.x * vecb.y - vecb.x * veca.y),
        };
        return res;
    }

    pub fn Reflect(vec: *Vec3, surfNorm: Vec3) Vec3 {
        var dot: f32 = Vec3.Dot(vec, surfNorm);
        var surfNormTimes2Dot = surfNorm;
        surfNormTimes2Dot.mul(dot * 2.0);
        var res: Vec3 = .{};
        res.add(vec);
        res.sub(surfNormTimes2Dot);
        return res; // vec - surfNorm * (dot(vec, surfNorm) * 2);
    }

    pub fn RndUnitSphere() Vec3 {
        var res: Vec3 = .{};
        while (true) {
            res.x = Rnd_f32() * 2 - 1;
            res.y = Rnd_f32() * 2 - 1;
            res.z = Rnd_f32() * 2 - 1;
            if (res.len2() >= 1) {
                continue;
            }
            break;
        }
        res.unit();
        return res;
    }
};

pub const Ray = struct {
    o: Vec3 = .{ .x = 0, .y = 0, .z = 0 }, // origin
    d: Vec3 = .{ .x = 0, .y = 0, .z = 0 }, // direction

    pub fn at(self: Ray, t: f32) Vec3 {
        var res: Vec3 = .{};
        res.add(self.d);
        res.mul(t);
        res.add(self.o);
        return res;
    }
};

pub const RayHit = struct {
    p: Vec3 = .{ .x = 0, .y = 0, .z = 0 }, // hit position
    n: Vec3 = .{ .x = 0, .y = 0, .z = 0 }, // hit normal
    t: f32 = 0, // hit time
    tmin: f32 = 0, // hit time range limit
    tmax: f32 = 0, // hit time range limit
    m: ?*const Material = null, // hit material
};

pub const Material = struct {
    a: Color = .{ .r = 0, .g = 0, .b = 0 }, // albedo
    b: f32 = 0, // blurr
    r: f32 = 0, // refraction ratio

    pub fn scatter(self: Material, ray: Ray, payload: RayHit, att: *Color, sca: *Ray) bool {
        _ = ray;

        var rnd_dir: Vec3 = Vec3.RndUnitSphere();
        rnd_dir.mul(self.b);

        var out_dir = .{};
        _ = out_dir;
        rnd_dir.add(payload.n);
        rnd_dir.add(rnd_dir);
        rnd_dir.unit();

        att.* = self.a;
        sca.* = .{ .o = payload.p, .d = rnd_dir };
        return true;
    }
};

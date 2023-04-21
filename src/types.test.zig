const std = @import("std");
const testing = std.testing;
const types = @import("types.zig");

const Color = types.Color;
const Vec3 = types.Vec3;

fn expectColor(c: Color, comptime r: f32, comptime g: f32, comptime b: f32) !void {
    try testing.expectEqual(r, c.r);
    try testing.expectEqual(g, c.g);
    try testing.expectEqual(b, c.b);
}

test "Color.creation" {
    const c: Color = .{};
    try testing.expect(@TypeOf(c) == Color);
    try testing.expect(@TypeOf(c.r) == f32);
    try testing.expect(@TypeOf(c.g) == f32);
    try testing.expect(@TypeOf(c.b) == f32);

    const c1: Color = .{};
    try expectColor(c1, 0, 0, 0);

    // Array initialization not supported
    // const c2: Color = .{ 0, 0, 0 };
    // try expectColor(c2, 0, 0, 0);

    const c3: Color = .{ .r = 0, .g = 0, .b = 0 };
    try expectColor(c3, 0, 0, 0);

    const cw: Color = Color.WHITE;
    try expectColor(cw, 1, 1, 1);

    const cb: Color = Color.BLACK;
    try expectColor(cb, 0, 0, 0);

    const c4: Color = .{ .r = 1.5, .g = 2.5, .b = 3.5 };
    try expectColor(c4, 1.5, 2.5, 3.5);
}

test "Color.add" {
    const c1: Color = .{ .r = 1, .g = 2, .b = 3 };
    const c2: Color = .{ .r = 1, .g = 4, .b = 9 };

    var c3: Color = .{};
    c3.add(c1);
    c3.add(c2);
    try expectColor(c3, 2, 6, 12);

    var c4: Color = .{};
    c4.add(c2);
    c4.add(c1);
    try expectColor(c4, 2, 6, 12);

    var c5: Color = .{};
    c5.add(c1);
    c5.add(c1);
    try expectColor(c5, 2, 4, 6);
}

test "Color.div" {
    const c1: Color = .{ .r = 1, .g = 2, .b = 3 };
    const c2: Color = .{ .r = 1, .g = 4, .b = 9 };

    var c3: Color = c1;
    c3.div(1);
    try expectColor(c3, 1, 2, 3);

    var c4: Color = c2;
    c4.div(2);
    try expectColor(c4, 0.5, 2.0, 4.5);

    var c5: Color = .{ .r = 1, .g = 1, .b = 1 };
    c5.div(0);
    try testing.expect(std.math.isInf(c5.r));
    try testing.expect(std.math.isInf(c5.g));
    try testing.expect(std.math.isInf(c5.b));

    var c6: Color = .{ .r = 0, .g = 0, .b = 0 };
    c6.div(0);
    try testing.expect(std.math.isNan(c6.r));
    try testing.expect(std.math.isNan(c6.g));
    try testing.expect(std.math.isNan(c6.b));
}

test "Color.mul" {
    const c1: Color = .{ .r = 1, .g = 2, .b = 3 };
    const c2: Color = .{ .r = 1, .g = 4, .b = 9 };

    var c3: Color = c1;
    c3.mul(1);
    try expectColor(c3, 1, 2, 3);

    var c4: Color = c2;
    c4.mul(0.5);
    try expectColor(c4, 0.5, 2.0, 4.5);

    var c5: Color = .{ .r = 1, .g = 1, .b = 1 };
    c5.mul(0);
    try expectColor(c5, 0, 0, 0);

    var c6: Color = .{ .r = 0, .g = 0, .b = 0 };
    c6.mul(0);
    try expectColor(c5, 0, 0, 0);
}

test "Color.gamma" {
    const c1: Color = .{ .r = 0.5, .g = 0.5, .b = 0.5 };

    var c2: Color = c1;
    c2.gamma(2);
    try expectColor(c2, std.math.sqrt1_2, std.math.sqrt1_2, std.math.sqrt1_2);

    var c3: Color = c1;
    c3.gamma(1);
    try expectColor(c3, 0.5, 0.5, 0.5);

    var c4: Color = c1;
    c4.gamma(0);
    try expectColor(c4, 0, 0, 0);
}

test "Color.combine" {
    // TODO
}

test "Color.mix" {
    // TODO
}

fn expectVec3(c: Vec3, comptime x: f32, comptime y: f32, comptime z: f32) !void {
    try testing.expectApproxEqAbs(x, c.x, 0.0001);
    try testing.expectApproxEqAbs(y, c.y, 0.0001);
    try testing.expectApproxEqAbs(z, c.z, 0.0001);
}

fn expectVec3Inf(c: Vec3) !void {
    try testing.expect(std.math.isInf(c.x));
    try testing.expect(std.math.isInf(c.y));
    try testing.expect(std.math.isInf(c.z));
}

fn expectVec3Nan(c: Vec3) !void {
    try testing.expect(std.math.isNan(c.x));
    try testing.expect(std.math.isNan(c.y));
    try testing.expect(std.math.isNan(c.z));
}

test "Vec3.creation" {
    const v: Vec3 = .{};
    try testing.expect(@TypeOf(v) == Vec3);
    try testing.expect(@TypeOf(v.x) == f32);
    try testing.expect(@TypeOf(v.y) == f32);
    try testing.expect(@TypeOf(v.z) == f32);

    const v1: Vec3 = .{};
    try expectVec3(v1, 0, 0, 0);

    // Array initialization not supported
    // const v2: Vec3 = .{ 0, 0, 0 };
    // try expectVec3(v2, 0, 0, 0);

    const v3: Vec3 = .{ .x = 0, .y = 0, .z = 0 };
    try expectVec3(v3, 0, 0, 0);

    const v4: Vec3 = .{ .x = 1.5, .y = 2.5, .z = 3.5 };
    try expectVec3(v4, 1.5, 2.5, 3.5);
}

test "Vec3.add" {
    const v1: Vec3 = .{ .x = 1, .y = 2, .z = 3 };
    const v2: Vec3 = .{ .x = 1, .y = 4, .z = 9 };

    var v3: Vec3 = .{};
    v3.add(v1);
    v3.add(v2);
    try expectVec3(v3, 2, 6, 12);

    var v4: Vec3 = .{};
    v4.add(v2);
    v4.add(v1);
    try expectVec3(v4, 2, 6, 12);

    var v5: Vec3 = .{};
    v5.add(v1);
    v5.add(v1);
    try expectVec3(v5, 2, 4, 6);
}

test "Vec3.sub" {
    const v1: Vec3 = .{ .x = 1, .y = 2, .z = 3 };
    const v2: Vec3 = .{ .x = 1, .y = 4, .z = 9 };

    var v3: Vec3 = .{};
    v3.sub(v1);
    v3.sub(v2);
    try expectVec3(v3, -2, -6, -12);

    var v4: Vec3 = .{};
    v4.sub(v2);
    v4.sub(v1);
    try expectVec3(v3, -2, -6, -12);

    var v5: Vec3 = .{};
    v5.sub(v1);
    v5.sub(v1);
    try expectVec3(v5, -2, -4, -6);
}

test "Vec3.mul" {
    const v1: Vec3 = .{ .x = 1, .y = 2, .z = 3 };
    const v2: Vec3 = .{ .x = 1, .y = 4, .z = 9 };

    var v3: Vec3 = v1;
    v3.mul(1);
    try expectVec3(v3, 1, 2, 3);

    var v4: Vec3 = v2;
    v4.mul(2);
    try expectVec3(v4, 2, 8, 18);

    var v5: Vec3 = .{ .x = 1, .y = 1, .z = 1 };
    v5.mul(0);
    try expectVec3(v5, 0, 0, 0);

    var v6: Vec3 = .{ .x = 0, .y = 0, .z = 0 };
    v6.mul(0);
    try expectVec3(v6, 0, 0, 0);
}

test "Vec3.div" {
    const v1: Vec3 = .{ .x = 1, .y = 2, .z = 3 };
    const v2: Vec3 = .{ .x = 1, .y = 4, .z = 9 };

    var v3: Vec3 = v1;
    v3.div(1);
    try expectVec3(v3, 1, 2, 3);

    var v4: Vec3 = v2;
    v4.div(2);
    try expectVec3(v4, 0.5, 2.0, 4.5);

    var v5: Vec3 = .{ .x = 1, .y = 1, .z = 1 };
    v5.div(0);
    try expectVec3Inf(v5);

    var v6: Vec3 = .{ .x = 0, .y = 0, .z = 0 };
    v6.div(0);
    try expectVec3Nan(v6);
}

test "Vec3.len" {
    const v0: Vec3 = .{};
    const v0len2: f32 = 0;
    try testing.expectEqual(v0len2, v0.len());

    const v1: Vec3 = .{ .x = 1, .y = 2, .z = 3 };
    const v1len2: f32 = 14;
    try testing.expectEqual(@sqrt(v1len2), v1.len());

    const v2: Vec3 = .{ .x = 1, .y = 4, .z = 9 };
    const v2len2: f32 = 98;
    try testing.expectEqual(@sqrt(v2len2), v2.len());
}

test "Vec3.len2" {
    const v0: Vec3 = .{};
    const v0len2: f32 = 0;
    try testing.expectEqual(v0len2, v0.len2());

    const v1: Vec3 = .{ .x = 1, .y = 2, .z = 3 };
    const v1len2: f32 = 14;
    try testing.expectEqual(v1len2, v1.len2());

    const v2: Vec3 = .{ .x = 1, .y = 4, .z = 9 };
    const v2len2: f32 = 98;
    try testing.expectEqual(v2len2, v2.len2());
}

test "Vec3.unit" {
    var v0: Vec3 = .{};
    v0.unit();
    try expectVec3Nan(v0);

    var v1: Vec3 = .{ .x = 1, .y = 0, .z = 0 };
    const v1len = @sqrt(@as(f32, 1));
    v1.unit();
    try expectVec3(v1, 1 / v1len, 0 / v1len, 0 / v1len);

    var v2: Vec3 = .{ .x = 1, .y = 4, .z = 9 };
    const v2len: f32 = @sqrt(@as(f32, 98));
    v2.unit();
    try expectVec3(v2, 1 / v2len, 4 / v2len, 9 / v2len);
}

test "Vec3.Dot" {
    const v0: Vec3 = .{};
    const v1: Vec3 = .{ .x = 1, .y = 2, .z = 3 };
    const v2: Vec3 = .{ .x = 1, .y = 4, .z = 9 };

    const d0: f32 = Vec3.Dot(.{}, .{});
    try testing.expectEqual(@as(f32, 0), d0);

    const d1: f32 = Vec3.Dot(v0, v0);
    try testing.expectEqual(@as(f32, 0), d1);

    const d2: f32 = Vec3.Dot(v0, v1);
    try testing.expectEqual(@as(f32, 0), d2);

    const d3: f32 = Vec3.Dot(v1, v2);
    try testing.expectEqual(@as(f32, 36), d3);

    const d4: f32 = Vec3.Dot(v1, v1);
    try testing.expectEqual(v1.len2(), d4);
}

test "Vec3.Cross" {
    // TODO
}

test "Vec3.Reflect" {
    // TODO
}

test "Vec3.RndUnitSphere" {
    // TODO
}

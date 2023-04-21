const std = @import("std");
const c = @cImport(@cInclude("process.h"));
const types = @import("types.zig");

const Color = types.Color;

pub fn writeTGA(allocator: std.mem.Allocator, w: u32, h: u32, pixels: []const Color) !void {
    const file = try std.fs.cwd().createFile("test.tga", .{ .read = true });
    defer file.close();

    const w_u8 = std.mem.asBytes(&w);
    const h_u8 = std.mem.asBytes(&h);

    var tgameta: [18]u8 = .{0} ** (18);
    tgameta[2] = 2;
    tgameta[12] = w_u8[0];
    tgameta[13] = w_u8[1];
    tgameta[14] = h_u8[0];
    tgameta[15] = h_u8[1];
    tgameta[16] = 24;
    tgameta[17] = 0b00100000;
    try file.writeAll(&tgameta);

    var raw_pixels: []u8 = try allocator.alloc(u8, w * h * 3);
    defer allocator.free(raw_pixels);
    std.mem.set(u8, raw_pixels, 0);

    var i: u32 = 0;
    while (i < raw_pixels.len) : (i += 3) {
        const p = pixels[i / 3];
        const r_u32 = @floatToInt(u32, p.r * 255.0);
        const g_u32 = @floatToInt(u32, p.g * 255.0);
        const b_u32 = @floatToInt(u32, p.b * 255.0);
        const r_u8 = @truncate(u8, r_u32) & 0xff;
        const g_u8 = @truncate(u8, g_u32) & 0xff;
        const b_u8 = @truncate(u8, b_u32) & 0xff;
        raw_pixels[i + 2] = r_u8;
        raw_pixels[i + 1] = g_u8;
        raw_pixels[i + 0] = b_u8;
    }
    try file.writeAll(raw_pixels);

    var cwd_buff: [1024]u8 = .{0} ** (1024);
    const cwd_dir = try std.fs.cwd().realpath(".", &cwd_buff);
    const paths = .{ cwd_dir, "test.tga" };
    const file_path = try std.fs.path.join(allocator, &paths);
    defer allocator.free(file_path);
    var buff: [1024]u8 = .{0} ** (1024);
    const cmd = try std.fmt.bufPrint(&buff, "start paintdotnet:\"{s}\"", .{file_path});
    _ = c.system(&cmd[0]);
}

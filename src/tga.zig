const std = @import("std");
const c = @cImport(@cInclude("process.h"));
const types = @import("types.zig");

pub fn writeTGA(comptime w: u32, comptime h: u32, pixels: []const types.Color) !void {
    const file = try std.fs.cwd().createFile("test.tga", .{ .read = true });
    defer file.close();

    var tgameta: [18]u8 = .{0} ** (18);
    tgameta[2] = 2;
    tgameta[12] = (w >> 0) & 0xff;
    tgameta[13] = (w >> 8) & 0xff;
    tgameta[14] = (h >> 0) & 0xff;
    tgameta[15] = (h >> 8) & 0xff;
    tgameta[16] = 24;
    tgameta[17] = 0b00100000;
    try file.writeAll(&tgameta);

    var raw_pixels: [w * h * 3]u8 = [1]u8{0} ** (w * h * 3);
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
    try file.writeAll(&raw_pixels);

    var cwd_buff: [1024]u8 = .{0} ** (1024);
    const cwd_dir = try std.fs.cwd().realpath(".", &cwd_buff);
    const paths = .{ cwd_dir, "test.tga" };
    const file_path = try std.fs.path.join(std.heap.page_allocator, &paths);
    var buff: [1024]u8 = .{0} ** (1024);
    const cmd = try std.fmt.bufPrint(&buff, "start paintdotnet:\"{s}\"", .{file_path});
    _ = c.system(&cmd[0]);
}

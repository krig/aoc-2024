const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const a = arena.allocator();

    var leftList = std.ArrayList(u32).init(a);
    defer leftList.deinit();
    var rightList = std.ArrayList(u32).init(a);
    defer rightList.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        var it2 = std.mem.tokenizeScalar(u8, line, ' ');
        try leftList.append(try std.fmt.parseInt(u32, it2.next() orelse "0", 10));
        try rightList.append(try std.fmt.parseInt(u32, it2.next() orelse "0", 10));
    }

    std.mem.sort(u32, leftList.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, rightList.items, {}, comptime std.sort.asc(u32));

    var sum: u32 = 0;
    for (leftList.items, rightList.items) |left, right| {
        if (left < right) {
            sum += @abs(right - left);
        } else {
            sum += @abs(left - right);
        }
    }
    std.debug.print("Result: {d}\n", .{sum});
}

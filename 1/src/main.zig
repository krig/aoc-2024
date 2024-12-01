const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const a = arena.allocator();

    var leftList = std.ArrayList(i32).init(a);
    var rightList = std.ArrayList(i32).init(a);
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        var it2 = std.mem.tokenizeScalar(u8, line, ' ');
        try leftList.append(try std.fmt.parseInt(i32, it2.next() orelse unreachable, 10));
        try rightList.append(try std.fmt.parseInt(i32, it2.next() orelse unreachable, 10));
    }

    std.mem.sort(i32, leftList.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, rightList.items, {}, comptime std.sort.asc(i32));

    var sum: u32 = 0;
    for (leftList.items, rightList.items) |left, right| {
        sum += @abs(left - right);
    }
    std.debug.print("Part 1: {d}\n", .{sum});

    var score: usize = 0;
    for (leftList.items) |left| {
        score += std.mem.count(i32, rightList.items, &.{left}) * @abs(left);
    }
    std.debug.print("Part 2: {d}\n", .{score});
}

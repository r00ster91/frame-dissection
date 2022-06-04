const std = @import("std");
const log = std.log;
const mem = std.mem;

pub const log_level = .debug;

pub fn main() !void {
    _ = async x();
}

noinline fn x() !void {
    var hello = [5]u8{ 'h', 'e', 'l', 'l', 'o' };
    _ = hello;
    var full_bytes = [_]u8{0xff} ** 10;
    _ = full_bytes;

    const frame: anyframe = @frame();
    const frame_address = @frameAddress();
    const frame_bytes = @ptrCast([*]const u8, frame);

    log.scoped(.start).debug("frame address: {d}", .{frame_address});

    var i: usize = 0;
    while (true) : (i += 1) {
        const possible_address = mem.readIntNative(
            usize,
            @ptrCast(*const [8]u8, frame_bytes[i .. i + 8]),
        );
        log.scoped(.frame).debug(
            "{d: >[alignment]}: byte: {[byte]d: >3}, possible address: {[possible_address]d}",
            .{
                .index = i,
                .alignment = std.fmt.count("{d}", .{@frameSize(x)}),
                .byte = frame_bytes[i],
                .possible_address = possible_address,
            },
        );

        if (i > 0 and i % 8 == 0)
            log.scoped(.frame).debug("8-byte mark crossed", .{});

        const reader = std.io.fixedBufferStream(frame_bytes[i .. i + 8]).reader();

        const next_bytes = try reader.readBytesNoEof(hello.len);
        var printable = true;
        for (next_bytes) |byte| {
            if (!std.ascii.isPrint(byte)) {
                printable = false;
                break;
            }
        }
        if (printable) {
            log.scoped(.frame).debug("next {d} chars: {s}", .{
                hello.len, next_bytes,
            });
        }

        if (possible_address == frame_address) {
            log.scoped(.frame).debug("found frame address", .{});
            break;
        }
    }
    log.scoped(.@"end  ").debug("bytes read: {d}", .{i});
    log.scoped(.@"end  ").debug("return address: {d}", .{@returnAddress()});
}

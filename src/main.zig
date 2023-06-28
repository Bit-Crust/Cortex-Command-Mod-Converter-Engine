const std = @import("std");

const expect = std.testing.expect;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

/// This .ini input file:
/// /* foo   */ /* foo2*//*foo3*/
/// DataModule
/// \t/* bar */Description      = Epic /* baz
/// bee */\tSupportedGameVersion = Pre4
///
/// Turns into this .ini output file:
/// // foo foo2 foo3
/// DataModule
/// \tDescription = Epic // bar baz
/// \tSupportedGameVersion = Pre4 // bee
///
/// That output file is internally represented with these AST nodes:
/// [
///     { "comment": "foo foo2 foo3" },
///     { "property": "DataModule", "children": [
///         { "property": "Description", "value": "Epic", "comment": "bar baz" },
///         { "property": "SupportedGameVersion", "value": "Pre4", "comment": "bee" }
///     ]}
/// [
const TokenType = enum {
    Comment,
    Tabs,
    Spaces,
    Equals,
    Word,
};

const Token = struct {
    token_type: TokenType,
    slice: []const u8,
};

fn getToken(slice: []const u8, index: *usize) Token {
    const character = slice[0];
    return switch (character) {
        ' ' => {
            index.* += 1; // TODO: Do this in a loop
            return Token{ .token_type = .Spaces, .slice = slice };
        },
        else => {
            index.* += 1; // TODO: Do this in a loop
            return Token{ .token_type = .Word, .slice = slice };
        },
    };
}

// const AST = struct {
//     property: []const u8,
//     value: []const u8,
//     comment: ?[]const u8 = null,
//     children: ?*AST = null,
// };

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "ast" {
    // TODO: Try making gpa const
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = &gpa.allocator();
    // _ = allocator;
    // defer _ = gpa.deinit();

    var path_buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.realpath("tests/ini_test_files/token_and_cst/simple/in.ini", &path_buf);

    var file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var tokens = ArrayList(Token).init(test_allocator);
    defer tokens.deinit();

    var text = try in_stream.readAllAlloc(test_allocator, std.math.maxInt(usize));
    defer test_allocator.free(text);

    // std.log.warn("'{s}'", .{text});

    var index: usize = 0;

    var token: Token = undefined;

    token = getToken(text[index..], &index);
    try expect(token.token_type == .Word);
    try std.testing.expectEqualStrings("AddEffect = MOPixel", token.slice);
    try std.testing.expectEqualStrings("ddEffect = MOPixel", text[index..]);

    token = getToken(text[index..], &index);
    try expect(token.token_type == .Word);
    try std.testing.expectEqualStrings("ddEffect = MOPixel", token.slice);
    try std.testing.expectEqualStrings("dEffect = MOPixel", text[index..]);

    // var line_number: i32 = 1;

    // var line_iter = std.mem.split(u8, text, "\n");
    // while (line_iter.next()) |line| {
    //     // Move "line" along as ptr/slice and add tokens in loop
    //     while (true) {
    //         try tokens.append(getToken(&line, line_number));
    //     }

    //     line_number += 1;

    //     // var iter = std.mem.split(u8, line, "=");
    //     // var count: usize = 0;
    //     // while (iter.next()) |token| : (count += 1) {
    //     //     std.log.warn("{d}: '{s}'", .{ count, token });
    //     // }

    //     // try std.testing.expectEqualStrings("AddEffect = MOPixel", line);
    //     // std.log.warn("{s}", .{line});
    // }

    // std.log.warn("{d}", .{line_number});
    // std.log.warn("{s} '{s}'", .{ @tagName(tokens.items[0].token_type), tokens.items[0].slice });

    // std.log.warn("{s}", .{@tagName(tokens.items[1].token_type)});
    // std.log.warn("'{s}'", .{tokens.items[1].slice});

    // const x = tokens.items[0];
    // _ = x;
    // const x = tokens.?[0];
    // std.log.warn("{s}", .{x.slice});
    // try expect(1 == 2);
    // try expect(eql(
    //     []Token,
    //     tokens.items,
    //     []Token{{.token_type = .Word, .slice = "xd",}},
    // ));
    // try expect(std.meta.eql(
    //     tokens.items[0],
    //     Token{ .token_type = .Word, .slice = "AddEffect = MOPixel" },
    // ));

    // const ast = AST{
    //     .property = "a",
    //     .value = "b",
    // };
}

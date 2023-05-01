module dlox.lox;
import dlox.cli;
import dlox.token;
import dlox.runtime_error;
import std.stdio;
import std.stdio : stderr;
import std.format : format;

static struct Lox {
    static bool hadError = false;
    static bool hadRuntimeError = false;

    private static void report(int line, string where, string message) {
        writeln("[ line ", line, " ] Error", where, ": ", message);
        hadError = true;
    }

    static void error(Token token, string message) {
        if (token.type == TokenType.eof) {
            report(token.line, " at end", message);
        } else {
            report(token.line, " at '" ~ token.lexeme ~ "'", message);
        }
    }

    static void runTimeError(RuntimeError error) {
        stderr.writeln(format("%s\n[line %s] ", error.msg, error.token.line));
        hadRuntimeError = true;
    }
}

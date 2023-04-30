module dlox.lox;
import dlox.cli;
import dlox.token;
import std.stdio;

struct Lox {
    static bool hadError = false;

    private static void report(int line, string where, string message) {
        writeln("[ line ", line, " ] Error", where, ": ", message);
        hadError = true;
    }

    static void run() {

    }

    static void error(Token token, string message) {
        if (token.type == TokenType.eof) {
            report(token.line, " at end", message);
        } else {
            report(token.line, " at '" ~ token.lexeme ~ "'", message);
        }
    }
}

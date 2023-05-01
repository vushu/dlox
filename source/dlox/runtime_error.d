module dlox.runtime_error;
import std.stdio;
import dlox.token : Token;

public class RuntimeError : Exception {
    Token token;

    this(Token token, string msg, string file = __FILE__, size_t line = __LINE__,
            Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
        this.token = token;
    }
}

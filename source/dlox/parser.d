module dlox.parser;
import dlox.token;
import dlox.expr;

class Parser {
    private Token[] _tokens;
    private int _current = 0;

    this(ref Token[] tokens) {
        _tokens = tokens;
    }

    // private Expr equality(){
    //     Expr
    // }

    private bool match(TokenType[] types...) {
        foreach (type; types) {
            // type.
        }
        return true;
    }

    private bool check(Token type) {
        if (isAtEnd)
            return false;
        return peek == type;
    }

    private Token advance() {
        if (!isAtEnd)
            _current++;
        return previous;
    }

    private bool isAtEnd() {
        return peek.type == TokenType.EOF;
    }

    private Token peek() {
        return _tokens[_current];
    }

    private Token previous() {
        return _tokens[_current - 1];
    }
}

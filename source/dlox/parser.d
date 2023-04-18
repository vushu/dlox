module dlox.parser;
import dlox.token;
import dlox.expr;

class Parser {
    private Token[] _tokens;
    private int _current = 0;

    this(ref Token[] tokens) {
        _tokens = tokens;
    }

    private Expr equality() {
        Expr expr = comparison;
        while (match(TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL)) {
            Token operator = previous;
            Expr right = comparison;
            expr = new Binary(expr, operator, right);

        }
        return expr;
    }

    private Expr comparison() {
        return Expr.init;
    }

    private Expr term() {
        while (match(TokenType.GREATER, TokenType.GREATER_EQUAL, TokenType.LESS, TokenType
                .LESS_EQUAL)) {
        }
        return Expr.init;
    }

    private bool match(TokenType[] types...) {
        foreach (type; types) {
            if (check(type)) {
                advance;
                return true;
            }
        }
        return false;
    }

    private bool check(TokenType type) {
        if (isAtEnd)
            return false;
        return peek.type == type;
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

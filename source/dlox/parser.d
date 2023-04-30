module dlox.parser;
import dlox.token;
import dlox.expr;
import dlox.lox;
import std.stdio;

class Parser {
    private Token[] _tokens;
    private int _current = 0;

    this(ref Token[] tokens) {
        _tokens = tokens;
    }

    Expr parse() {
        try {
            return expression;

        } catch (ParseError e) {
            return null;
        }
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
        Expr expr = term;
        while (match(TokenType.GREATER, TokenType.GREATER_EQUAL,
                TokenType.LESS, TokenType.LESS_EQUAL)) {
            Token operator = previous;
            Expr right = term;
            expr = new Binary(expr, operator, right);
        }
        return expr;
    }

    private Expr term() {
        auto expr = factor;
        while (match(TokenType.MINUS, TokenType.PLUS)) {
            Token operator = previous;
            Expr right = factor;
            expr = new Binary(expr, operator, right);
        }
        return expr;
    }

    private Expr factor() {
        Expr expr = unary;
        while (match(TokenType.SLASH, TokenType.STAR)) {
            Token operator = previous;
            Expr right = unary;
            expr = new Binary(expr, operator, right);
        }
        return expr;
    }

    private Expr unary() {
        if (match(TokenType.BANG, TokenType.MINUS)) {
            Token operator = previous;
            Expr right = unary;
            return new Unary(operator, right);
        }
        return primary;
    }

    private Expr primary() {
        if (match(TokenType.FALSE)) {
            return new Literal(LiteralType(false));
        } else if (match(TokenType.TRUE)) {
            return new Literal(LiteralType(true));
        } else if (match(TokenType.NIL)) {
            return new Literal(LiteralType(Nothing()));
        } else if (match(TokenType.NUMBER, TokenType.STRING)) {
            return new Literal(previous.literal);
        } else if (match(TokenType.LEFT_PAREN)) {
            Expr expr = expression;
            consume(TokenType.RIGHT_PAREN, "Expect ')' after expression.");
            return new Grouping(expr);
        }

        throw error(peek, "Expression expected.");
    }

    private Expr expression() {
        return equality;
    }

    private Token consume(TokenType type, string message) {
        if (check(type)) {
            return advance;
        }
        throw error(peek, message);
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

    private ParseError error(Token token, string message) {
        Lox.error(token, message);
        return new ParseError;
    }

    private void synchronize() {
        advance;
        while (!isAtEnd) {
            if (previous.type == TokenType.SEMICOLON) {
                return;
            }
            switch (peek.type) with (TokenType) {
            case CLASS,
                FUN, VAR, IF,
                WHILE, PRINT, RETURN:
                return;
            default:
                break;
            }
            advance;
        }
    }
}

private class ParseError : Exception {

    this(string msg = "Failed to parse.", string file = __FILE__,
        size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}

unittest {

    import dlox.scanner;
    import dlox.ast_printer;

    auto sourceCode = "40 + 2 == 4 * 10 + 2";
    auto scanner = Scanner(sourceCode);
    Token[] tokens = scanner.scanTokens;
    Parser parser = new Parser(tokens);
    Expr expression = parser.parse;
    assert(!Lox.hadError);
    auto printer = new ASTPrinter;
    expression.accept(printer);
    auto printed = printer.appender.data;
    assert(printed == q{(== (+ 40 2) (+ (* 4 10) 2))});

}

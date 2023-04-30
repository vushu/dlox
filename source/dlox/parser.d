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
        while (match(TokenType.bangEqual, TokenType.equalEqual)) {
            Token operator = previous;
            Expr right = comparison;
            expr = new Binary(expr, operator, right);

        }
        return expr;
    }

    private Expr comparison() {
        Expr expr = term;
        while (match(TokenType.greater, TokenType.greaterEqual,
                TokenType.less, TokenType.lessEqual)) {
            Token operator = previous;
            Expr right = term;
            expr = new Binary(expr, operator, right);
        }
        return expr;
    }

    private Expr term() {
        auto expr = factor;
        while (match(TokenType.minus, TokenType.plus)) {
            Token operator = previous;
            Expr right = factor;
            expr = new Binary(expr, operator, right);
        }
        return expr;
    }

    private Expr factor() {
        Expr expr = unary;
        while (match(TokenType.slash, TokenType.star)) {
            Token operator = previous;
            Expr right = unary;
            expr = new Binary(expr, operator, right);
        }
        return expr;
    }

    private Expr unary() {
        if (match(TokenType.bang, TokenType.minus)) {
            Token operator = previous;
            Expr right = unary;
            return new Unary(operator, right);
        }
        return primary;
    }

    private Expr primary() {
        if (match(TokenType.falseKeyword)) {
            return new Literal(LiteralType(false));
        } else if (match(TokenType.trueKeyword)) {
            return new Literal(LiteralType(true));
        } else if (match(TokenType.nilKeyword)) {
            return new Literal(LiteralType(Nothing()));
        } else if (match(TokenType.numberLiteral, TokenType.stringLiteral)) {
            return new Literal(previous.literal);
        } else if (match(TokenType.leftParen)) {
            Expr expr = expression;
            consume(TokenType.rightParen, "Expect ')' after expression.");
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
        return peek.type == TokenType.eof;
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
            if (previous.type == TokenType.semicolon) {
                return;
            }
            switch (peek.type) with (TokenType) {
            case classKeyword,
                funKeyword, varKeyword, ifKeyword,
                whileKeyword, printKeyword, returnKeyword:
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

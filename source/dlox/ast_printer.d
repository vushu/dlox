module dlox.ast_printer;
import dlox.expr;
import dlox.token;
import std.stdio;
import std.conv : to;
import std.array : Appender;

class ASTPrinter : Visitor!string {

    string visitLiteralExpr(Literal!string expr) {
        if (expr.value.isLiteralTypeNothing)
            return "nil";
        else
            return expr.value.to!string;
    }

    string visitBinaryExpr(Binary!string expr) {
        return parenthesize(expr.operator.lexeme, expr.left, expr.right);
    }

    string visitGroupingExpr(Grouping!string expr) {
        return parenthesize("group", expr.expression);
    }

    string visitUnaryExpr(Unary!string expr) {
        return parenthesize(expr.operator.lexeme, expr.right);
    }

    private string parenthesize(string name, Expr!string[] exprs...) {
        Appender!string appender;
        appender.put("(");
        appender.put(name);

        foreach (expr; exprs) {
            appender.put(" ");
            appender.put(expr.accept(this));
        }

        appender.put(")");
        return appender.data;
    }

}

unittest {
    ASTPrinter printer = new ASTPrinter();
    auto literal = new Literal!string(LiteralType(Nothing()));
    auto res = literal.accept(printer);
    assert(res == "nil");
}

unittest {
    ASTPrinter printer = new ASTPrinter();
    Literal!string literal = new Literal!string(LiteralType(3.14));
    auto tok = Token(TokenType.STAR, "-", LiteralType(Nothing()), 1);
    auto tok2 = Token(TokenType.STAR, "*", LiteralType(Nothing()), 1);
    auto unary = new Unary!string(tok, literal);
    auto binary = new Binary!string(new Literal!string(LiteralType("44")), tok2, unary);
    auto grouping = new Grouping!string(binary);

    auto res = grouping.accept(printer);
    immutable(string) expected = "(group (* 44 (- 3.14)))";
    assert(res == expected);
}

module dlox.ast_printer;
import dlox.expr;
import dlox.token;
import std.stdio;
import std.conv : to;
import std.array : Appender;

class ASTPrinter : Visitor {

    void visitLiteralExpr(Literal expr) {
        if (expr.value.isLiteralTypeNothing)
            appender.put("nil");
        else
            appender.put(expr.value.to!string);
    }

    void visitBinaryExpr(Binary expr) {
        parenthesize(expr.operator.lexeme, expr.left, expr.right);
    }

    void visitGroupingExpr(Grouping expr) {
        parenthesize("group", expr.expression);
    }

    void visitUnaryExpr(Unary expr) {
        parenthesize(expr.operator.lexeme, expr.right);
    }

    private void parenthesize(string name, Expr[] exprs...) {
        appender.put("(");
        appender.put(name);

        foreach (Expr expr; exprs) {
            appender.put(" ");
            expr.accept(this);
        }

        appender.put(")");
    }

    Appender!string appender;

}

unittest {
    ASTPrinter printer = new ASTPrinter();
    Literal literal = new Literal(LiteralType(Nothing()));
    literal.accept(printer);
    assert(printer.appender.data == "nil");
}

unittest {
    ASTPrinter printer = new ASTPrinter();
    Literal literal = new Literal(LiteralType(3.14));
    auto tok = Token(TokenType.STAR, "-", LiteralType(Nothing()), 1);
    auto tok2 = Token(TokenType.STAR, "*", LiteralType(Nothing()), 1);
    auto unary = new Unary(tok, literal);
    auto binary = new Binary(new Literal(LiteralType("44")), tok2, unary);
    auto grouping = new Grouping(binary);

    grouping.accept(printer);
    immutable(string) expected = "(group (* 44 (- 3.14)))";
    assert(printer.appender.data == expected);
}

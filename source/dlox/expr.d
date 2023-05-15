module dlox.expr;
import std.array;
import std.stdio;
import dlox.token;
import std.typecons : Tuple;
import std.sumtype : SumType, match;
import std.string : toLower;
import std.conv : to;
import std.format;

template makeVisit(string baseName, string typeName) {
    const char[] makeVisit =
        [
            "void visit", typeName, baseName, "(", typeName, " ",
            baseName.toLower,
            ");"
    ].join;
}

string generateConstructor(immutable(string[2])[] args...) {
    Appender!string appender;
    appender.put("this(");
    foreach (idx, arg; args) {
        appender.put(arg[0] ~ " " ~ arg[1]);
        if (idx + 1 < args.length) {
            appender.put(", ");
        }
    }
    appender.put("){");
    foreach (arg; args) {
        appender.put("this." ~ arg[1] ~ " = " ~ arg[1] ~ ";");
    }
    appender.put("}");

    foreach (arg; args) {
        appender.put(arg[0] ~ " " ~ arg[1] ~ ";");
    }

    return appender.data;
}

auto makeAccept(string baseName, string visitorType, string name) {

    const char[] acceptString =
        format("void accept(%s visitor){ visitor.visit%s%s(this);}", visitorType, name, baseName);
    return acceptString;
}

mixin template MakeExpr(string name, immutable(string[2])[] args) {
    mixin(generateConstructor(args));
    mixin(makeAccept("Expr", "ExprVisitor", name));
}

mixin template MakeStmt(string name, immutable(string[2])[] args) {
    mixin(generateConstructor(args));
    mixin(makeAccept("Stmt", "StmtVisitor", name));
}

interface Expr {
    void accept(ExprVisitor visitor);
}

interface Stmt {
    void accept(StmtVisitor visitor);
}

class Binary : Expr {
    mixin MakeExpr!("Binary", [
        ["Expr", "left"], ["Token", "operator"],
        ["Expr", "right"]
    ]);
}

class Grouping : Expr {
    mixin MakeExpr!("Grouping", [["Expr", "expression"]]);
}

class Literal : Expr {
    mixin MakeExpr!("Literal", [["LiteralType", "value"]]);
}

class Unary : Expr {
    mixin MakeExpr!("Unary", [
        ["Token", "operator"], ["Expr", "right"]
    ]);
}

class Expression : Stmt {
    mixin MakeStmt!("Expression", [
        ["Expr", "expression"]
    ]);
}
class Print : Stmt {
    mixin MakeStmt!("Print", [
        ["Expr", "expression"]
    ]);
}

interface StmtVisitor {
    mixin(makeVisit!("Stmt", "Expression"));
    mixin(makeVisit!("Stmt", "Print"));
}

interface ExprVisitor {
    mixin(makeVisit!("Expr", "Literal"));
    mixin(makeVisit!("Expr", "Binary"));
    mixin(makeVisit!("Expr", "Grouping"));
    mixin(makeVisit!("Expr", "Unary"));
}

unittest {
    Literal literal = new Literal(LiteralType(3.14));
    Token t = Token(TokenType.minus, "-", LiteralType(Nothing()), 1);
    Unary unary = new Unary(t, literal);
    assert(unary.operator.lexeme == "-");
    assert((cast(Literal) unary.right).value == LiteralType(3.14));
    writeln(Literal.stringof);
}


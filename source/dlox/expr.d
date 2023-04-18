module dlox.expr;
import std.array;
import std.stdio;
import dlox.token;
import std.typecons : Tuple;
import std.sumtype : SumType, match;
import std.string : toLower;
import std.conv : to;

template makeVisit(string baseName, string typeName) {
    const char[] makeVisit =
        [
            "void visit", typeName, baseName, "(", typeName, " ",
            baseName.toLower,
            ");"
    ].join;
}

interface Expr {
    void accept(Visitor visitor);
}

struct Argument {
    string typeName;
    string variableName;
}

string generateConstructor(immutable(Argument[]) args) {
    Appender!string appender;
    appender.put("this(");
    foreach (idx, arg; args) {
        appender.put(arg.typeName ~ " " ~ arg.variableName);
        if (idx + 1 < args.length) {
            appender.put(", ");
        }
    }
    appender.put("){");
    foreach (arg; args) {
        appender.put("this." ~ arg.variableName ~ " = " ~ arg.variableName ~ ";");
    }
    appender.put("}");

    foreach (arg; args) {
        appender.put(arg.typeName ~ " " ~ arg.variableName ~ ";");
    }

    return appender.data;
}

template makeExpr(string baseName, string name, immutable(Argument[]) args) {
    const char[] constructor = generateConstructor(args);
    const char[] makeExpr = [
        "class ", name, ": ", baseName, " {",
        constructor,
        "void accept(Visitor visitor){ return visitor.visit", name,
        baseName, "(this); }",
        "}"
    ].join;
}

mixin(makeExpr!("Expr", "Binary", [
    Argument("Expr", "left"),
    Argument("Token", "operator"),
    Argument("Expr", "right")
]));

mixin(makeExpr!("Expr", "Grouping", [
    Argument("Expr", "expression")
]));

mixin(makeExpr!("Expr", "Literal", [Argument("LiteralType", "value")]));

mixin(
    makeExpr!("Expr", "Unary", [
    Argument("Token", "operator"), Argument("Expr", "right")
]));

interface Visitor {
    mixin(makeVisit!("Expr", "Literal"));
    mixin(makeVisit!("Expr", "Binary"));
    mixin(makeVisit!("Expr", "Grouping"));
    mixin(makeVisit!("Expr", "Unary"));
}

unittest {
    Literal literal = new Literal(LiteralType(3.14));
    Token t = Token(TokenType.MINUS, "-", LiteralType(Nothing()), 1);
    Unary unary = new Unary(t, literal);
    assert(unary.operator.lexeme == "-");
    assert((cast(Literal) unary.right).value == LiteralType(3.14));
}

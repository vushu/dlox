module dlox.expr;
import std.array;
import std.stdio;
import dlox.token;
import std.typecons : Tuple;
import std.sumtype : SumType, match;
import std.string : toLower;

template makeVisit(string baseName, string typeName) {
    const char[] makeVisit =
        [
            "R visit", typeName, baseName, "(", typeName, "!R ",
            baseName.toLower,
            ");"
    ].join;
}

interface Expr(R) {
    R accept(Visitor!R visitor);
}

alias Argument = Tuple!(string, string);

string generateConstructor(immutable(Argument[]) args) {
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

template makeExpr(string baseName, string name, immutable(Argument[]) args) {
    const char[] constructor = generateConstructor(args);
    const char[] makeExpr = [
        "class ", name, "(R): ", baseName, "!R {",
        constructor,
        "R accept(Visitor!R visitor){ return visitor.visit", name,
        baseName, "(this); }",
        "}"
    ].join;
}

mixin(makeExpr!("Expr", "Binary", [
    Argument("Expr!R", "left"),
    Argument("Token", "operator"),
    Argument("Expr!R", "right")
]));

mixin(makeExpr!("Expr", "Grouping", [
    Argument("Expr!R", "expression")
]));

mixin(makeExpr!("Expr", "Literal", [Argument("LiteralType", "value")]));

mixin(
    makeExpr!("Expr", "Unary", [
    Argument("Token", "operator"), Argument("Expr!R", "right")
]));

interface Visitor(R) {
    mixin(makeVisit!("Expr", "Literal"));
    mixin(makeVisit!("Expr", "Binary"));
    mixin(makeVisit!("Expr", "Grouping"));
    mixin(makeVisit!("Expr", "Unary"));
}

unittest {
    Literal!string literal = new Literal!string(LiteralType(3.14));
    Token t = Token(TokenType.MINUS, "-", LiteralType(Nothing()), 1);
    Unary!string unary = new Unary!string(t, literal);

    // pragma(msg, mixin(GenerateVistorBody!("Expr", "Literal")));
}

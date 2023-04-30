module dlox.token;
import std.sumtype : SumType, match;
import std.conv : to;
import std.stdio;
import std.typecons : Nullable, nullable;

enum TokenType {
    // Single-character tokens.
    leftParen,
    rightParen,
    leftBrace,
    rightBrace,
    comma,
    dot,
    minus,
    plus,
    semicolon,
    slash,
    star,

    // One or two character tokens.
    bang,
    bangEqual,
    equal,
    equalEqual,
    greater,
    greaterEqual,
    less,
    lessEqual,

    // Literals.
    identifier,
    stringLiteral,
    numberLiteral,

    // Keywords.
    andKeyword,
    classKeyword,
    elseKeyword,
    falseKeyword,
    funKeyword,
    forKeyword,
    ifKeyword,
    nilKeyword,
    orKeyword,
    printKeyword,
    returnKeyword,
    superKeyword,
    thisKeyword,
    trueKeyword,
    varKeyword,
    whileKeyword,

    eof
}

enum TokenType[string] KEYWORDS = [
    "and": TokenType.andKeyword,
    "class": TokenType.classKeyword,
    "else": TokenType.elseKeyword,
    "false": TokenType.elseKeyword,
    "for": TokenType.forKeyword,
    "fun": TokenType.funKeyword,
    "if": TokenType.ifKeyword,
    "nil": TokenType.nilKeyword,
    "or": TokenType.orKeyword,
    "print": TokenType.printKeyword,
    "return": TokenType.returnKeyword,
    "super": TokenType.superKeyword,
    "this": TokenType.thisKeyword,
    "true": TokenType.trueKeyword,
    "var": TokenType.varKeyword,
    "while": TokenType.whileKeyword,
];

struct Nothing {
}

alias LiteralType = SumType!(string, int, double, bool, Nothing);

struct Token {
    TokenType type;
    string lexeme;
    LiteralType literal;
    int line;

    public string toString() {
        bool isNull = literal.match!((ref Nothing _) => true,
            _ => false);
        return "{ type: " ~ type.to!string ~ ", lexeme: " ~ lexeme ~ ", literal: " ~ (
            isNull ? "null" : (
                literal.to!string)) ~ ", line: " ~ line
            .to!string ~ " }";
    }
}

bool isLiteralTypeNothing(LiteralType literal) {

    return literal.match!((ref Nothing _) => true,
        _ => false);
}

LiteralType createStringLiteral(string value) {
    return LiteralType(value);
}

LiteralType createDoubleLiteral(string value) {
    return LiteralType(to!double(value));
}

unittest {
    TokenType type = TokenType.stringLiteral;
    auto token = Token(type, "", createStringLiteral("helloWorld"), 1);
    assert(token.toString == "{ type: stringLiteral, lexeme: , literal: helloWorld, line: 1 }");
}

unittest {
    import std.stdio;

    TokenType type = TokenType.identifier;
    auto token = Token(type, "", LiteralType(Nothing()), 1);
    assert(token.toString == "{ type: identifier, lexeme: , literal: null, line: 1 }");

}

module dlox.token;
import std.sumtype : SumType, match;
import std.conv : to;
import std.stdio;
import std.typecons : Nullable, nullable;

enum TokenType : int
{
	// Single-character tokens.
	LEFT_PAREN,
	RIGHT_PAREN,
	LEFT_BRACE,
	RIGHT_BRACE,
	COMMA,
	DOT,
	MINUS,
	PLUS,
	SEMICOLON,
	SLASH,
	STAR,

	// One or two character tokens.
	BANG,
	BANG_EQUAL,
	EQUAL,
	EQUAL_EQUAL,
	GREATER,
	GREATER_EQUAL,
	LESS,
	LESS_EQUAL,

	// Literals.
	IDENTIFIER,
	STRING,
	NUMBER,

	// Keywords.
	AND,
	CLASS,
	ELSE,
	FALSE,
	FUN,
	FOR,
	IF,
	NIL,
	OR,
	PRINT,
	RETURN,
	SUPER,
	THIS,
	TRUE,
	VAR,
	WHILE,

	EOF
}

enum TokenType[string] KEYWORDS = [
	"and": TokenType.AND,
	"class": TokenType.CLASS,
	"else": TokenType.ELSE,
	"false": TokenType.FALSE,
	"for": TokenType.FOR,
	"fun": TokenType.FUN,
	"if": TokenType.IF,
	"nil": TokenType.NIL,
	"or": TokenType.OR,
	"print": TokenType.PRINT,
	"return": TokenType.RETURN,
	"super": TokenType.SUPER,
	"this": TokenType.THIS,
	"true": TokenType.TRUE,
	"var": TokenType.VAR,
	"while": TokenType.WHILE,
];

struct Nothing
{
}

alias Literal = SumType!(string, int, double, Nothing);

struct Token
{
	TokenType type;
	string lexeme;
	Literal literal;
	int line;

	public string toString()
	{
		bool isNull = literal.match!((ref Nothing _) => true,
			_ => false);
		return "{ type: " ~ type.to!string ~ ", lexeme: " ~ lexeme ~ ", literal: " ~ (
			isNull ? "null" : (
				literal.to!string)) ~ ", line: " ~ line
			.to!string ~ " }";
	}
}

Literal createStringLiteral(string value)
{
	return Literal(value);
}

Literal createDoubleLiteral(string value)
{
	return Literal(to!double(value));
}

unittest
{
	TokenType type = TokenType.STRING;
	auto token = Token(type, "", createStringLiteral("helloWorld"), 1);
	assert(token.toString == "{ type: STRING, lexeme: , literal: helloWorld, line: 1 }");
}

unittest
{
	import std.stdio;

	TokenType type = TokenType.IDENTIFIER;
	auto token = Token(type, "", Literal(Nothing()), 1);
	assert(token.toString == "{ type: IDENTIFIER, lexeme: , literal: null, line: 1 }");

}

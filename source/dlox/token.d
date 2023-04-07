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

alias Literal = SumType!(string, int, double, typeof(null));

struct Token
{
	TokenType type;
	string lexeme;
	Literal literal;
	int line;

	public string toString()
	{
		bool isNull = literal.match!((ref typeof(null) _) => true, 
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
	auto token = Token(type, "", Literal(null), 1);
	assert(token.toString == "{ type: IDENTIFIER, lexeme: , literal: null, line: 1 }");

}

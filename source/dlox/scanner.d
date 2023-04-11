module dlox.scanner;
import dlox.lox;
import dlox.token;
import std.typecons : nullable, Nullable;
import std.experimental.logger;

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

struct Scanner
{
	string source;
	Token[] tokens;
	uint start = 0;
	uint current = 0;
	uint line = 0;

	Token[] scanTokens()
	{

		while (!isAtEnd)
		{
			start = current;
			scanToken();
		}

		tokens ~= Token(TokenType.EOF, "", Literal(null), line);
		return tokens;
	}

	private char advance()
	{
		return source[current++];
	}

	private void addToken(TokenType type)
	{
		addToken(type, Literal(null));
	}

	private void addToken(TokenType type, Literal literal)
	{
		string text = source[start .. current];
		tokens ~= Token(type, text, literal, line);
	}

	//to look at second character
	private bool match(char expected)
	{
		if (isAtEnd)
			return false;

		if (source[current] != expected)
			return false;

		current++;
		return true;
	}

	private char peek()
	{
		if (isAtEnd)
			return '\0';
		return source[current];
	}

	private char peekNext()
	{
		if (current + 1 >= source.length)
			return '\0';

		return source[current + 1];
	}

	private void scanToken()
	{
		char c = advance();

		switch (c)
		{
		case '(':
			addToken(TokenType.LEFT_PAREN);
			break;
		case ')':
			addToken(TokenType.RIGHT_PAREN);
			break;
		case '{':
			addToken(TokenType.LEFT_BRACE);
			break;
		case '}':
			addToken(TokenType.RIGHT_BRACE);
			break;
		case ',':
			addToken(TokenType.COMMA);
			break;
		case '.':
			addToken(TokenType.DOT);
			break;
		case '-':
			addToken(TokenType.MINUS);
			break;
		case '+':
			addToken(TokenType.PLUS);
			break;
		case ';':
			addToken(TokenType.SEMICOLON);
			break;
		case '*':
			addToken(TokenType.STAR);
			break;
		case '!':
			addToken(match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
			break;
		case '=':
			addToken(match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
			break;
		case '<':
			addToken(match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
			break;
		case '>':
			addToken(match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
			break;
		case '/':
			if (match('/'))
			{
				// A comment goes until the end of line.
				while (peek != '\n' && !isAtEnd)
				{
					advance;
				}
			}
			else
				addToken(TokenType.SLASH);
			break;
		case ' ':
		case '\r':
		case '\t':
			// ignoring whitespace.
			break;
		case '\n':
			line++;
			break;
		case '"':

			break;
		default:
			if (c.isDigit)
			{
				handleNumber;
			}
			else if (c.isAlphaNumberic)
			{
				handleIdentifier;
			}
			else
				Lox.error(line, "Unexpected character");
			break;
		}

	}

	private bool isAtEnd()
	{
		return current >= source.length;
	}

	private void handleIdentifier()
	{
		while (peek.isAlphaNumberic)
		{
			advance;
		}
		string text = source[start .. current];
		// see if any keywords
		auto found = text in KEYWORDS;
		auto type = TokenType.IDENTIFIER;

		if (found !is null)
		{
			type = *found;
		}
		addToken(type);
	}

	void handleNumber()
	{
		while (peek.isDigit)
		{
			advance;
		}

		if (peek == '.' && peekNext.isDigit)
		{
			advance;
		}

		addToken(TokenType.NUMBER, createDoubleLiteral(source[start .. current]));
	}

	void handleString()
	{
		while (peek != '"' && !isAtEnd)
		{
			if (peek == '\n')
			{
				line++;
			}
			advance;
		}
		if (isAtEnd)
		{
			Lox.error(line, "Unterminated string.");
			return;
		}

		advance;

		// Trim the surrounding quotes.
		string value = source[start + 1 .. current + 1];
		addToken(TokenType.STRING, createStringLiteral(value));
	}
}

private bool isDigit(char c)
{
	return c >= '0' && c <= '9';
}

private bool isAlpha(char c)
{
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
}

private bool isAlphaNumberic(char c)
{
	return c.isAlpha || c.isDigit;
}

unittest
{
	import std.stdio : writeln;

	writeln("Finding OR");

	auto scanner = Scanner("or");
	Token[] tokens = scanner.scanTokens;
	assert(tokens[0].type == TokenType.OR);
	assert(tokens[1].type == TokenType.EOF);
}

unittest
{
	import std.stdio : writeln;

	writeln("Should deduce TokenType: IDENFIFIER and TokenType: OR");

	auto scanner = Scanner("orchid or");
	Token[] tokens = scanner.scanTokens;
	assert(tokens[0].type == TokenType.IDENTIFIER);
	assert(tokens[1].type == TokenType.OR);
	assert(tokens[$ - 1].type == TokenType.EOF);
	assert(tokens.length == 3);
}

unittest
{
	import std.stdio : writeln;

	auto scanner = Scanner("!=");
	Token[] tokens = scanner.scanTokens;
	assert(tokens[0].type == TokenType.BANG_EQUAL);
	assert(tokens[1].type == TokenType.EOF);
}

unittest
{
	import std.stdio : writeln;

	auto scanner = Scanner("jumanji");
	writeln("Should be of type IDENTIFIER");
	Token[] tokens = scanner.scanTokens;
	assert(tokens[0].type == TokenType.IDENTIFIER);
	assert(tokens[1].type == TokenType.EOF);
}

unittest
{
	assert(isDigit('8'));
	assert(!isDigit('p'));
}

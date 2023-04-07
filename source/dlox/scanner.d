module dlox.scanner;
import dlox.lox;
import dlox.token;
import std.typecons : nullable, Nullable;
import std.experimental.logger;

struct Scanner
{
	string source;
	Token[] tokens;
private:
	uint start = 0;
	uint current = 0;
	uint line = 0;

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

private char advance(ref Scanner scanner)
{
	with (scanner)
	{
		return source[current++];
	}
}

private void addToken(ref Scanner scanner, TokenType type)
{
	addToken(scanner, type, createNullLiteral);
}

private void addToken(ref Scanner scanner, TokenType type, Literal literal)
{
	with (scanner)
	{
		string text = source[start .. current];
		tokens ~= Token(type, text, literal, line);
	}
}

//to look at second character
bool match(ref Scanner scanner, char expected)
{
	if (scanner.isAtEnd)
	{
		return false;
	}

	if (scanner.source[scanner.current] != expected)
	{
		return false;
	}
	scanner.current++;
	return true;
}

char peek(scope ref const(Scanner) scanner)
{
	if (scanner.isAtEnd)
	{
		return '\0';
	}
	return scanner.source[scanner.current];
}

private char peekNext(scope ref Scanner scanner)
{
	with (scanner)
	{
		if (current + 1 >= source.length)
		{
			return '\0';
		}
		return source[scanner.current + 1];
	}
}

private void scanToken(scope ref Scanner scanner)
{
	char c = advance(scanner);

	switch (c)
	{
	case '(':
		scanner.addToken(TokenType.LEFT_PAREN);
		break;
	case ')':
		scanner.addToken(TokenType.RIGHT_PAREN);
		break;
	case '{':
		scanner.addToken(TokenType.LEFT_BRACE);
		break;
	case '}':
		scanner.addToken(TokenType.RIGHT_BRACE);
		break;
	case ',':
		scanner.addToken(TokenType.COMMA);
		break;
	case '.':
		scanner.addToken(TokenType.DOT);
		break;
	case '-':
		scanner.addToken(TokenType.MINUS);
		break;
	case '+':
		scanner.addToken(TokenType.PLUS);
		break;
	case ';':
		scanner.addToken(TokenType.SEMICOLON);
		break;
	case '*':
		scanner.addToken(TokenType.STAR);
		break;
	case '!':
		scanner.addToken(scanner.match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
		break;
	case '=':
		scanner.addToken(scanner.match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
		break;
	case '<':
		scanner.addToken(scanner.match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
		break;
	case '>':
		scanner.addToken(scanner.match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
		break;
	case '/':
		if (scanner.match('/'))
		{
			Lox.error(scanner.line, "damn ");
			// A comment goes until the end of line.
			while (scanner.peek !is '\n' && !scanner.isAtEnd)
			{
				scanner.advance;
			}
		}
		else if (scanner.match('*'))
		{
			Lox.error(scanner.line, "c-style comment");

			while (scanner.peek !is '*' && scanner.peekNext !is '/' && !scanner.isAtEnd)
			{
				scanner.advance;
			}

			if (scanner.peek is '*' && scanner.peekNext is '/')
			{
				// consuming * and then / thats why we increment by 2
				scanner.current += 2;
			}
		}
		else
		{
			scanner.addToken(TokenType.SLASH);
		}
		break;
	case ' ':
	case '\r':
	case '\t':
		// ignoring whitespace.
		break;
	case '\n':
		scanner.line++;
		break;
	case '"':

		break;
	default:
		if (c.isDigit)
		{
			scanner.handleNumber;
		}
		else if (c.isAlphaNumberic)
		{
			scanner.handleIdentifier;
		}
		else
		{
			Lox.error(scanner.line, "Unexpected character");
		}
		break;
	}

}

Token[] scanTokens(scope ref Scanner scanner)
{

	while (!scanner.isAtEnd)
	{
		scanner.start = scanner.current;
		scanner.scanToken();
	}

	scanner.tokens ~= Token(TokenType.EOF, "", createNullLiteral, scanner.line);
	return scanner.tokens;
}

bool isAtEnd(scope ref const(Scanner) scanner)
{
	with (scanner)
	{
		return current >= source.length;
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

private void handleIdentifier(scope ref Scanner scanner)
{
	while (scanner.peek.isAlphaNumberic)
	{
		scanner.advance;
	}
	with (scanner)
	{
		string text = scanner.source[start .. current];
		// see if any keywords
		auto found = text in KEYWORDS;
		auto type = TokenType.IDENTIFIER;

		if (found !is null)
		{
			type = *found;
		}
		scanner.addToken(type);
	}
}

private void handleNumber(scope ref Scanner scanner)
{
	while (scanner.peek.isDigit)
	{
		scanner.advance;
	}

	if (scanner.peek == '.' && scanner.peekNext.isDigit)
	{
		scanner.advance();
	}

	with (scanner)
	{
		scanner.addToken(TokenType.NUMBER, createDoubleLiteral(source[start .. current]));
	}
}

private void handleString(scope ref Scanner scanner)
{
	while (scanner.peek != '"' && !scanner.isAtEnd)
	{
		if (scanner.peek == '\n')
		{
			scanner.line++;
		}
		scanner.advance;
	}
	if (scanner.isAtEnd)
	{
		Lox.error(scanner.line, "Unterminated string.");
		return;
	}

	scanner.advance;

	// Trim the surrounding quotes.
	with (scanner)
	{
		string value = source[start + 1 .. current + 1];
		scanner.addToken(TokenType.STRING, createStringLiteral(value));
	}
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

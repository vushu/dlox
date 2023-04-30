module dlox.scanner;
import dlox.lox;
import dlox.token;
import std.experimental.logger;

struct Scanner {

    this(string source) {
        _source = source;
    }

    Token[] scanTokens() {

        while (!isAtEnd) {
            _start = _current;
            scanToken();
        }

        _tokens ~= Token(TokenType.EOF, "", LiteralType(Nothing()), _line);
        return _tokens;
    }

private:
    string _source;
    Token[] _tokens;
    uint _start = 0;
    uint _current = 0;
    uint _line = 0;

    char advance() {
        return _source[_current++];
    }

    void addToken(TokenType type) {
        addToken(type, LiteralType(Nothing()));
    }

    void addToken(TokenType type, LiteralType literal) {
        string text = _source[_start .. _current];
        _tokens ~= Token(type, text, literal, _line);
    }

    //to look at second character
    bool match(char expected) {
        if (isAtEnd)
            return false;

        if (_source[_current] != expected)
            return false;

        _current++;
        return true;
    }

    char peek() {
        if (isAtEnd)
            return '\0';
        return _source[_current];
    }

    char peekNext() {
        if (_current + 1 >= _source.length)
            return '\0';

        return _source[_current + 1];
    }

    void scanToken() {
        char c = advance;
        switch (c) with (TokenType) {
        case '(':
            addToken(LEFT_PAREN);
            break;
        case ')':
            addToken(RIGHT_PAREN);
            break;
        case '{':
            addToken(LEFT_BRACE);
            break;
        case '}':
            addToken(RIGHT_BRACE);
            break;
        case ',':
            addToken(COMMA);
            break;
        case '.':
            addToken(DOT);
            break;
        case '-':
            addToken(MINUS);
            break;
        case '+':
            addToken(PLUS);
            break;
        case ';':
            addToken(SEMICOLON);
            break;
        case '*':
            addToken(STAR);
            break;
        case '!':
            addToken(match('=') ? BANG_EQUAL : BANG);
            break;
        case '=':
            addToken(match('=') ? EQUAL_EQUAL : EQUAL);
            break;
        case '<':
            addToken(match('=') ? LESS_EQUAL : LESS);
            break;
        case '>':
            addToken(match('=') ? GREATER_EQUAL : GREATER);
            break;
        case '/':
            if (match('/')) {
                // A comment goes until the end of line.
                while (peek != '\n' && !isAtEnd) {
                    advance;
                }
            } else
                addToken(SLASH);
            break;
        case ' ', '\r', '\t':
            // ignoring whitespace.
            break;
        case '\n':
            _line++;
            break;
        case '"':

            break;
        default:
            if (c.isDigit) {
                handleNumber;
            } else if (c.isAlphaNumberic) {
                handleIdentifier;
            } else
                Lox.error(Token(), "Unexpected character");
            break;
        }

    }

    bool isAtEnd() {
        return _current >= _source.length;
    }

    void handleIdentifier() {
        while (peek.isAlphaNumberic) {
            advance;
        }
        string text = _source[_start .. _current];
        // see if any keywords
        auto found = text in KEYWORDS;
        auto type = TokenType.IDENTIFIER;

        if (found !is null) {
            type = *found;
        }
        addToken(type);
    }

    void handleNumber() {
        while (peek.isDigit) {
            advance;
        }

        if (peek == '.' && peekNext.isDigit) {
            advance; // Consume the "."
            while (peek.isDigit) {
                advance;
            }
        }

        addToken(TokenType.NUMBER, createDoubleLiteral(_source[_start .. _current]));
    }

    void handleString() {
        while (peek != '"' && !isAtEnd) {
            if (peek == '\n') {
                _line++;
            }
            advance;
        }
        if (isAtEnd) {
            Lox.error(Token(), "Unterminated string.");
            return;
        }

        advance;

        // Trim the surrounding quotes.
        string value = _source[_start + 1 .. _current + 1];
        addToken(TokenType.STRING, createStringLiteral(value));
    }
} // End of Scanner

private bool isDigit(char c) {
    return c >= '0' && c <= '9';
}

private bool isAlpha(char c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
}

private bool isAlphaNumberic(char c) {
    return c.isAlpha || c.isDigit;
}

unittest {
    import std.stdio : writeln;
    import std.conv : to;

    writeln("Should resolve source as NUMBER");

    auto scanner = Scanner("3.14");
    Token[] tokens = scanner.scanTokens;
    assert(tokens[0].literal.to!string == "3.14");
    assert(tokens[0].type == TokenType.NUMBER);
    assert(tokens[$ - 1].type == TokenType.EOF);
}

unittest {
    import std.stdio : writeln;

    writeln("Should resolve source as OR");

    auto scanner = Scanner("or");
    Token[] tokens = scanner.scanTokens;
    assert(tokens[0].type == TokenType.OR);
    assert(tokens[1].type == TokenType.EOF);
}

unittest {
    import std.stdio : writeln;

    writeln("Should deduce TokenType: IDENFIFIER and TokenType: OR");

    auto scanner = Scanner("orchid or");
    Token[] tokens = scanner.scanTokens;
    assert(tokens[0].type == TokenType.IDENTIFIER);
    assert(tokens[1].type == TokenType.OR);
    assert(tokens[$ - 1].type == TokenType.EOF);
    assert(tokens.length == 3);
}

unittest {
    import std.stdio : writeln;

    auto scanner = Scanner("!=");
    Token[] tokens = scanner.scanTokens;
    assert(tokens[0].type == TokenType.BANG_EQUAL);
    assert(tokens[1].type == TokenType.EOF);
}

unittest {
    import std.stdio : writeln;

    auto scanner = Scanner("jumanji");
    writeln("Should be of type IDENTIFIER");
    Token[] tokens = scanner.scanTokens;
    assert(tokens[0].type == TokenType.IDENTIFIER);
    assert(tokens[1].type == TokenType.EOF);
}

unittest {
    assert(isDigit('8'));
    assert(!isDigit('p'));
}

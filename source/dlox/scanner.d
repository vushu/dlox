module dlox.scanner;
import dlox.lox;
import dlox.token;
import std.experimental.logger;

struct Scanner {

    this(string source){
        _source = source;
    }

    Token[] scanTokens() {

        while (!isAtEnd) {
            _start = _current;
            scanToken();
        }

        _tokens ~= Token(TokenType.EOF, "", Literal(Nothing()), _line);
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
        addToken(type, Literal(Nothing()));
    }

    void addToken(TokenType type, Literal literal) {
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
        switch (c) {
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
            if (match('/')) {
                // A comment goes until the end of line.
                while (peek != '\n' && !isAtEnd) {
                    advance;
                }
            } else
                addToken(TokenType.SLASH);
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
                Lox.error(_line, "Unexpected character");
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
            advance;
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
            Lox.error(_line, "Unterminated string.");
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

    writeln("Finding OR");

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

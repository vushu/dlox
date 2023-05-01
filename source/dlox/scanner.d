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

        _tokens ~= Token(TokenType.eof, "", LiteralType(Nothing()), _line);
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
            addToken(leftParen);
            break;
        case ')':
            addToken(rightParen);
            break;
        case '{':
            addToken(leftBrace);
            break;
        case '}':
            addToken(rightBrace);
            break;
        case ',':
            addToken(comma);
            break;
        case '.':
            addToken(dot);
            break;
        case '-':
            addToken(minus);
            break;
        case '+':
            addToken(plus);
            break;
        case ';':
            addToken(semicolon);
            break;
        case '*':
            addToken(star);
            break;
        case '!':
            addToken(match('=') ? bangEqual : bang);
            break;
        case '=':
            addToken(match('=') ? equalEqual : equal);
            break;
        case '<':
            addToken(match('=') ? lessEqual : less);
            break;
        case '>':
            addToken(match('=') ? greaterEqual : greater);
            break;
        case '/':
            if (match('/')) {
                // A comment goes until the end of line.
                while (peek != '\n' && !isAtEnd) {
                    advance;
                }
            } else
                addToken(slash);
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
        auto type = TokenType.identifier;

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

        addToken(TokenType.numberLiteral, createDoubleLiteral(_source[_start .. _current]));
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
        addToken(TokenType.stringLiteral, createStringLiteral(value));
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
    assert(tokens[0].type == TokenType.numberLiteral);
    assert(tokens[$ - 1].type == TokenType.eof);
}

unittest {
    import std.stdio : writeln;

    writeln("Should resolve source as OR");

    auto scanner = Scanner("or");
    Token[] tokens = scanner.scanTokens;
    assert(tokens[0].type == TokenType.orKeyword);
    assert(tokens[1].type == TokenType.eof);
}

unittest {
    import std.stdio : writeln;

    writeln("Should deduce TokenType: IDENFIFIER and TokenType: OR");

    auto scanner = Scanner("orchid or");
    Token[] tokens = scanner.scanTokens;
    assert(tokens[0].type == TokenType.identifier);
    assert(tokens[1].type == TokenType.orKeyword);
    assert(tokens[$ - 1].type == TokenType.eof);
    assert(tokens.length == 3);
}

unittest {
    import std.stdio : writeln;

    auto scanner = Scanner("!=");
    Token[] tokens = scanner.scanTokens;
    assert(tokens[0].type == TokenType.bangEqual);
    assert(tokens[1].type == TokenType.eof);
}

unittest {
    import std.stdio : writeln;

    auto scanner = Scanner("jumanji");
    writeln("Should be of type identifier");
    Token[] tokens = scanner.scanTokens;
    assert(tokens[0].type == TokenType.identifier);
    assert(tokens[1].type == TokenType.eof);
}

unittest {
    assert(isDigit('8'));
    assert(!isDigit('p'));
}

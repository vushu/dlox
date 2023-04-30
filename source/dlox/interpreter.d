module dlox.interpreter;
import std.array : Appender;
import dlox.token;
import dlox.expr;
import std.conv : to;
import std.variant : Variant, variantArray;
import std.sumtype : match;
import std.array;
import std.stdio;

class Interpreter : Visitor {

    void visitLiteralExpr(Literal expr) {
        auto res = expr.value.match!(
            (ref Nothing _) => data = null,
            (ref int v) => data = v,
            (ref double v) => data = v,
            (ref bool v) => data = v,
            (ref string v) => data = v,
        );
        writeln(res);
    }

    void visitBinaryExpr(Binary expr) {
        auto left = evaluate(expr.left);
        auto right = evaluate(expr.right);
        switch (expr.operator.type) {

        case TokenType.minus:
            data = left.get!double - right.get!double;
            break;
        case TokenType.slash:
            data = left.get!double / right.get!double;
            break;
        case TokenType.star:
            data = left.get!double * right.get!double;
            break;
        case TokenType.plus:
            if (left.type is typeid(double) && right.type is typeid(double)) {
                data = left.get!double + left.get!double;
            }
            if (left.type is typeid(string) && right.type is typeid(string)) {
                data = (left.get!string ~ right.get!string);
            }
            break;
        case TokenType.greater:
            data = left.get!double > right.get!double;
            break;
        case TokenType.greaterEqual:
            data = left.get!double >= right.get!double;
            break;
        case TokenType.bangEqual:
            data = !isEqual(left, right);
            break;
        case TokenType.equalEqual:
            data = isEqual(left, right);
            break;
        default:
            break;
        }

    }

    void visitGroupingExpr(Grouping expr) {
        data = evaluate(expr.expression);
    }

    void visitUnaryExpr(Unary expr) {
        Variant right = evaluate(expr.right);
        switch (expr.operator.type) {
        case TokenType.bang:
            data = !isTruthy(right);
            break;
        case TokenType.minus:
            checkNumberOperand(expr.operator, right);
            data = -right.get!double;
            break;
        default:
            break;
        }
    }

    private Variant evaluate(Expr expr) {
        auto evaluator = new Interpreter();
        expr.accept(evaluator);
        return evaluator.data;
    }

    Variant data;
}

private bool isTruthy(Variant variant) {
    if (variant.type is typeid(null)) {
        return false;
    }
    if (variant.type is typeid(bool)) {
        return variant.get!bool;
    }
    return true;
}

private bool isEqual(Variant a, Variant b) {

    if (a.type is typeid(null) && b.type is typeid(null)) {
        return true;
    }

    if (a.type is typeid(null)) {
        return false;
    }
    return a == b;
}

private void checkNumberOperand(Token operator, Variant operand) {
    if (operand.type is typeid(double))
        return;
    throw new RuntimeError(operator, "Operand must be a number");
}

private void checkNumberOperands(Token operator, Variant left, Variant right) {
    if (left.type is typeid(double) && right.type is typeid(double))
        return;
    throw new RuntimeError(operator, "Operands must be a numbers");
}

private class RuntimeError : Exception {
    Token token;

    this(Token token, string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
        this.token = token;
    }
}

unittest {
    Variant v = null;
    assert(!isTruthy(v));
}

unittest {
    Variant v = 42;
    assert(isTruthy(v));
}

unittest {
    Variant v = false;
    assert(!isTruthy(v));
}

unittest {
    auto t = Token(TokenType.minus, "", LiteralType(Nothing()), 1);
    checkNumberOperand(t, Variant(42.0));
}

unittest {
    import dlox.scanner;
    import dlox.parser;

    auto source_code = "(2 + 2) * -10";
    auto scanner = new Scanner(source_code);
    auto tokens = scanner.scanTokens;
    auto parser = new Parser(tokens);
    auto expr = parser.parse;
    auto interpreter = new Interpreter;
    if (expr) {
        auto result = interpreter.evaluate(expr);
        writeln(result);
        assert(result == -40);
    }
}

module dlox.interpreter;
import std.array : Appender;
import dlox.token;
import dlox.expr;
import std.conv : to;
import std.variant : Variant, variantArray;
import std.sumtype : match;

class Interpreter : Visitor {

    void visitLiteralExpr(Literal expr) {
        expr.value.match!(
            (ref Nothing _) => data = null,
            (ref int v) => data = v,
            (ref double v) => data = v,
            (ref bool v) => data = v,
            (ref string v) => data = v,
        );
    }

    void visitBinaryExpr(Binary expr) {
        auto left = evaluate(expr.left);
        auto right = evaluate(expr.right);
        switch (expr.operator.type) {

        case TokenType.MINUS:
            data = left.get!(double) - right.get!double;
            break;
        case TokenType.SLASH:
            data = left.get!(double) / right.get!double;
            break;
        case TokenType.STAR:
            data = left.get!(double) * right.get!double;
            break;
        case TokenType.PLUS:
            if (left.type is typeid(double) && right.type is typeid(double)) {
                data = left.get!double + left.get!double;
            }
            if (left.type is typeid(string) && right.type is typeid(string)) {
                data = (left.get!string ~ right.get!string);
            }
            break;
        case TokenType.GREATER:
            data = left.get!double > right.get!double;
            break;
        case TokenType.GREATER_EQUAL:
            data = left.get!double >= right.get!double;
            break;
        case TokenType.BANG_EQUAL:
            data = !isEqual(left, right);
            break;
        case TokenType.EQUAL_EQUAL:
            data = isEqual(left, right);
            break;
        default:
            break;
        }

    }

    void visitGroupingExpr(Grouping expr) {
        evaluate(expr.expression);
    }

    void visitUnaryExpr(Unary expr) {
        Variant right = evaluate(expr.right);
        switch (expr.operator.type) {
        case TokenType.BANG:
            data = !isTruthy(right);
            break;
        case TokenType.MINUS:
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

module dlox.interpreter;
import std.array : Appender;
import dlox.token;
import dlox.expr;
import dlox.lox;
import dlox.runtime_error;
import std.conv : to;
import std.variant : Variant, variantArray;
import std.sumtype : match;
import std.array;
import std.stdio;

class Interpreter : ExprVisitor, StmtVisitor {

    void interpret(Stmt[] statements) {
        try {
            foreach (statement; statements) {
                execute(statement);
            }
        } catch (RuntimeError e) {
            Lox.runTimeError(e);
        }
    }

    void visitLiteralExpr(Literal expr) {
        auto res = expr.value.match!((ref Nothing _) => data = null,
            (ref int v) => data = v, (ref double v) => data = v,
            (ref bool v) => data = v, (ref string v) => data = v,);
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
                data = left.get!double + right.get!double;
            }
            else if (left.type is typeid(string) && right.type is typeid(string)) {
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
    void visitVariableExpr(Variable expr) {
    }

    void visitExpressionStmt(Expression stmt) {
        evaluate(stmt.expression);
    }

    void visitPrintStmt(Print stmt) {
        Variant value = evaluate(stmt.expression);
        writeln(stringify(value));
    }

    void visitVarStmt(Var stmt) {
    }

    private Variant evaluate(Expr expr) {
        auto evaluator = new Interpreter();
        expr.accept(evaluator);
        return evaluator.data;
    }

    private void execute(Stmt stmt) {
        stmt.accept(this);
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

private string stringify(Variant object) {
    import std.algorithm.searching : endsWith;

    if (object.type is typeid(null))
        return "nil";
    if (object.type is typeid(double)) {
        string text = object.to!string;
        if (text.endsWith(".0")) {
            // omitting .0
            text = text[0 .. $ - 2];
        }
        return text;
    }

    return object.to!string;

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

    auto source_code = "(2 + 2) * -10;";
    auto scanner = new Scanner(source_code);
    auto tokens = scanner.scanTokens;
    auto parser = new Parser(tokens);
    auto statements = parser.parse;
    auto interpreter = new Interpreter;
    if (!statements.empty) {
        interpreter.interpret(statements);
    }
}

unittest {
    import dlox.scanner;
    import dlox.parser;

    auto source_code = "print 220 * 20;";
    auto scanner = new Scanner(source_code);
    auto tokens = scanner.scanTokens;
    auto parser = new Parser(tokens);
    auto statements = parser.parse;
    auto interpreter = new Interpreter;
    if (!statements.empty) {
        interpreter.interpret(statements);
    }
}

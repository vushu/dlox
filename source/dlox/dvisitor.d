module dlox.dvisitor;

struct Monkey {

}

struct Donkey {

}

class AstPrinter {

}

private:
template hasVisitDonkey(S) {
    enum bool hasVisitDonkey = is(typeof(() {
                S s = S.init;
                Donkey m = Donkey.init;
                s.visit(m); // need a magma property
            }));
}
template hasVisitMonkey(S) {
    enum bool hasVisitMonkey = is(typeof(() {
                S s = S.init;
                Monkey m = Monkey.init;
                s.visit(m); // need a magma property
            }));
}


void visit(T)(T t) if(is(T == Donkey)){

}

void visit(T)(T t) if(is(T == Monkey)){

}

unittest {

}
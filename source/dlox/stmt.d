module dlox.stmt;
import std.stdio;

template isVolcano(S) {
    enum bool isVolcano = hasMagma!S; // only requirement for now
}

template hasMagma(S) {
    enum bool hasMagma = is(typeof(() {
                S s = S.init;
                int d = s.magma; // need a magma property
            }));
}

struct Vulcano {
    int lava(){
        writeln("Vulcano makes lava");
        return 1;
    }
}


struct LavaMan{
    void magma(){
        writeln("lavaman throwing lava");
    }
}

void makeLava(S)(S s) if (hasMagma!S) { 
}

// void makeLava(S)(S s) if (!hasMagma!S) { 
// }
unittest {
    LavaMan lavaMan;
    Vulcano vulcano;
    makeLava(lavaMan);
    makeLava(vulcano);
}



module dlox.cli;
import std.file;
import std.experimental.logger;
import std.range;
import std.stdio;
import std.typecons : Nullable, nullable;
import std.path : buildPath;
import core.stdc.stdlib : exit;
import std.getopt;
import dlox.scanner;

bool hadError = false;

Nullable!string readSourceFile(string path)
{
    if (!exists(path))
    {
        return Nullable!string.init;
    }
    return (cast(string) read(path)).nullable;
}

void runPrompt()
{
    info("Repl-mode");
    string line;
    showArrow;
    while ((line = readln) !is null)
    {
        if (line == "q\n")
        {
            break;
        }
        showArrow;
        runRepl(line);
    }
}

void runRepl(string source)
{
    auto scanner = Scanner(source);
    auto tokens = scanner.scanTokens;
    writeln("-----------------");
    foreach (tok; tokens)
    {
        writeln(tok);
    }
    writeln("-----------------");
    showArrow;
}

void showArrow()
{
    write("➤ ");
}

void runProgram(string[] args)
{
    string file;
    string script;
    GetoptResult result = getopt(args, "file", &file, "script", &script);
    if (!script.empty)
    {
        writeln("Usage dlox [script]");
        exit(64);
    }
    else if (!file.empty)
    {
        auto source = readSourceFile(buildPath(getcwd, file));
        if (source.isNull)
        {
            warning("No such file exists: ", args[0]);
            exit(1);
        }
        if (hadError)
        {
            exit(65);
        }

    }
    else if (result.helpWanted)
    {
        writeln("Usage: \n--file [file_path] \n--script [lox script]");
    }
    else
    {
        runPrompt;
    }

}

unittest
{
    assert(!readSourceFile(buildPath(getcwd, "lox_files/hello_world.lox")).isNull);
}

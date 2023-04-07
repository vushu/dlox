module dlox.lox;
import dlox.cli;
import std.stdio;

struct Lox
{
	static bool hadError = false;
	private static void report(int line, string where, string message)
	{
		writeln("[line ", line, " ] Error", where, ": ", message);
		hadError = true;
	}

	static void error(int line, string message)
	{
		report(line, "", message);
	}
}

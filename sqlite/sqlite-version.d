module sqlite;
//this imports a file called sqlite3.d, which is a d version of the sqlite3.h file.
//You can get it from https://github.com/biozic/d2sqlite3/tree/master/source/d2sqlite3
import sqlite3;
import std.stdio;
import std.string;

void main() {
	//get the version
	const(char)* cver=sqlite3_libversion();
	auto ver=fromStringz(cver);
	writeln("sqlite3 version=" ~ ver);
}
README

This is a test of calling an SQLite3 function from D.  This was very hard to set up so I want to document it.

1. We want to use the Windows 64-bit version of D and of SQLite.  Use the -m64 flag for dmd to use 64-bit.  
Make sure to use the D2 64-bit command prompt.
2. You need 2 sqlite3 files which I got from https://github.com/biozic/d2sqlite3/tree/master/lib/win64.  These are:
sqlite3.dll and sqlite3.lib.  Also you need the sqlite3.d file from https://github.com/biozic/d2sqlite3/tree/master/source/d2sqlite3.
The official sqlite3 site only has 32 bit versions.
3. I put the sqlite3.d file in c:\dlang\import and told the compiler where it was with the -I=c:\dlang\import flag. This needs 
to be in the code with "import sqlite3;".  I changed the module name from module d2sqlite3.sqlite3 to just sqlite3.
4. I put the sqlite3.lib file in c:\dlang\lib\win64 and told the compiler where it was with the -I=c:\dlang\lib\win64 flag.
I think you could put this in the same directory as sqlite3.d.
5. You need the Microsoft Visual C runtime library.  Just download Microsoft Visual Studio from https://visualstudio.microsoft.com/downloads/.
Get the Community edition.  It is huge, like 6 GB.  You don't need to do anything else.  The important thing is that this has a file
called libcmt.lib that it will add to the path.
6. The compiled program needs to find the sqlite3.dll file.  I don't know where it should be so I put it in the same directory as the
compiled .exe file.  I think it could be put in c:\windows\system32.  However, this could be confused with a 32-bit version, so it is 
probably best to keep it in the same directory.

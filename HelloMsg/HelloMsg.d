/+
 + Copyright (c) Charles Petzold, 1998.
 + Ported to the D Programming Language by Andrej Mitrovic, 2011.
 + Modified from:  https://github.com/AndrejMitrovic/DWinProgramming/blob/master/Samples/Chap01/HelloMsg/HelloMsg.d
 +/

module HelloMsg;

import core.runtime;
import std.utf;
import std.string: toStringz;

auto toUTF16z(S)(S s)
{
    return toUTFz!(const(wchar)*)(s);
}

import win32.windef;
import win32.winuser;

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{
    int result;
    void exceptionHandler(Throwable e) { throw e; }

    try
    {
        //Runtime.initialize(&exceptionHandler);
        Runtime.initialize;
        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, iCmdShow);
        //Runtime.terminate(&exceptionHandler);
        Runtime.terminate;
    }
    catch (Throwable o)
    {
        //MessageBox(null, o.toString().toUTF16z, "Error", MB_OK | MB_ICONEXCLAMATION);
        MessageBox(null, toStringz(o.toString()), "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0;
    }

    return result;
}

int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{
    MessageBox(NULL, "Hello, Windows!", "From D", 0);
    return 0;
}
/**
Mastermind from http://www.rosettacode.org/wiki/Mastermind
Translated from Kotlin, which was in turn translated from C++
*/
import std.stdio;
import std.string;
import std.conv;

//====================================
//code to make this similar to kotlin
import std.random;
Random rand;

//This is the random number function
int nextInt(Random r,int range) {
	return uniform(0, range , rand);
}

//there are other ways to do this, but I am using the current milliseconds to init
void init_randomizer() {
	uint m=get_millis();
	rand = Random(m);
}

uint get_millis() {
	import std.datetime.systime;
	import core.time;
	SysTime now = Clock.currTime();
	Duration frac = now.fracSecs;	
	long msecs=frac.total!("msecs");
	return cast(uint)msecs;
}

int coerceIn(int num,int min,int max) {
	if (num < min) {return min;}
	else if (num > max) {return max;}
	else {return num;}
}

//take
//Returns a subsequence of this char sequence containing the first n characters from this char sequence, 
//or the entire char sequence if this char sequence is shorter.
string take(string str,int len) {
	if (str.length < len) {
		return str;
	} else {
		return str[0 .. len];
	}
}

//====================================

class Mastermind {
    int codeLen;
    int colorsCnt;
    int guessCnt;
    bool repeatClr;
    string colors;
    string combo = "";
 	//private val guesses = mutableListOf<CharArray>()
 	string[] guesses;
    //private val results = mutableListOf<CharArray>()
 	string[] results;
 
    this(int codeLen, int cl,int guessCnt, bool repeatClr) {
        string color = "ABCDEFGHIJKLMNOPQRST";
        this.codeLen = coerceIn(codeLen,4, 10);
        if (!repeatClr && cl < this.codeLen) {cl = this.codeLen;}
        this.colorsCnt = coerceIn(cl,2, 20);       
        this.guessCnt = coerceIn(guessCnt,7, 20);    
        this.repeatClr = repeatClr;
        this.colors = take(color, colorsCnt);
    }

    void play() {
        bool win = false;
        combo = getCombo();
        while (guessCnt != 0) {
            showBoard();
            if (checkInput(getInput())) {
                win = true;
                break;
            }
            guessCnt--;
        }
        writeln("\n\n--------------------------------");
        if (win) {
            writeln("Very well done!\nYou found the code: " ~ combo);
        }
        else {
            writeln("I am sorry, you couldn't make it!\nThe code was: " ~ combo);
        }
        writeln("--------------------------------");
    }
 
    void showBoard() {
    	for( int x = 0; x < guesses.length; x++ ) {
            writeln("\n--------------------------------");
            write(x + 1);
            write(": ");
            foreach(e; guesses[x]) {
            	write(to!string(e) ~ " ");
            }
            write(" :  ");
            foreach(e; results[x]) {
            	write(to!string(e) ~ " ");
            }
            int z = codeLen - results[x].length;
            if (z > 0) {
            	for( int i = 0; i < z; i++ ) { write("- ");}
            }
        }
        writeln("");
    }


	//check to make sure all letters in input are in the set of colors
	//keep looping until true
    string getInput() {
        while (true) {
            write("Enter your guess (" ~ colors ~ "): ");
            
            string input = strip(stdin.readln());
            string u = input.toUpper();
            string alpha = take(u,codeLen);
            
            int ix=0;
            foreach(c; alpha) {
            	ix = colors.indexOf(c);
            	if (ix<0) break;
			}		
            if (ix>-1) {
            	return alpha;
            }
        }
    }

    bool checkInput(string a) {
        guesses ~= a;
        int black = 0;
        int white = 0;
        bool[] gmatch = new bool[codeLen];
        bool[] cmatch = new bool[codeLen];
        for (int i=0;i<codeLen;i++) {
            if (a[i] == combo[i]) {
                gmatch[i] = true;
                cmatch[i] = true;
                black++;
            }
        }
        for (int i=0;i<codeLen;i++)  {
            if (gmatch[i]) continue;
            for (int j=0;j<codeLen;j++) {
                if (i == j || cmatch[j]) continue;
                if (a[i] == combo[j]) {
                    cmatch[j] = true;
                    white++;
                    break;
                }
            }
        }   
        char[] r;
        for (int i=0;i<black;i++) {
        	r ~= 'X';
        }
        for (int i=0;i<white;i++) {
        	r ~= 'O';
        }         
        string myResult = to!string(r);
        //writeln("[checkInput] myResult = " ~ myResult);
        results ~= myResult;
        return black == codeLen;
    }

    string getCombo() {
    	char[] c;
    	char[] clr = colors.dup;
        for (int s=0;s<codeLen; s++) {
            int z = nextInt(rand,clr.length);
            //append to c
            c ~= clr[z];
            //remove the color from the list of options
            if (!repeatClr) {
            	import std.algorithm.mutation : remove;
            	clr = clr.remove(z);
            }
        }
        return to!string(c);
    }    
}
 
void main() {
	init_randomizer();
    Mastermind m = new Mastermind(4, 8, 12, false);
    m.play();
}
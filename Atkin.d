//Sieve of Atkin, D version, modified from a Java version
//see https://en.wikipedia.org/wiki/Sieve_of_Atkin
import std.stdio;
import std.array;


bool[] SieveOfAtkin(int limit) {
	import std.math;
	auto root = sqrt(cast(float)limit);
	int SQRT_MAX = cast(int)root + 1;
	
	//create array
	bool[] barray = new bool[limit];
	
	//initialize it
	//for (int i=0;i<limit;i++) {
	//	barray ~= true;
	//}
	//writeln("length=",barray.length);
	
    for (int x = 1; x < SQRT_MAX; x++)
    {
        for (int y = 1; y < SQRT_MAX; y++)
        {
 			//group 1
            int k = (4 * x * x) + (y * y);
    		if ((k < limit) && ((k % 12 == 1) || (k % 12 == 5))) {
    			barray[k]=!barray[k];
    		}

    		//group 2
      		k = 3 * x * x + y * y;
    		if ((k < limit) && (k % 12 == 7)) {
    			barray[k]=!barray[k];
    		}

    		//group 3
			if (x > y) {
				k = 3 * x * x - y * y;
			    if ((k < limit) && (k % 12 == 11)) {
			    	barray[k]=!barray[k];
				}
			}
		}
	}

	//final clean up
	barray[2]=true;
	barray[3]=true;
	for (int n = 5; n <= SQRT_MAX; n++) {
		bool b = barray[n];
		if (b) {
			int n2 = n * n;
	    	for (int k = n2; k < limit; k += n2) {
	    		barray[k]=false;
	    	}
		}
	}
	return barray;
}


//==================
void main(string[] args) {
	//writeln(args[1]);
	int limit = parseInt(args[1]);
	writeln("limit=",limit);
	bool[] ba = SieveOfAtkin(limit);

		for (int i=2;i<limit;i++) {
			if (ba[i]) {
				write(i, " ");
			}
		}
		writeln();
}

//parseInt - return -1 if invalid
int parseInt(string s) {
	import std.conv;
 	try {
 		return to!int(s);	
 	} catch (Exception x) {
 		return -1;
 	}
}

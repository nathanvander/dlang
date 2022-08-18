import std.stdio;
import std.conv;
import std.format;
import std.array;

/**
jday is the numeric value of a date, where 0 is January 1, 1901.  This is only valid through
December 31, 2099. We exclude the years 1900 and 2100 because they are oddball years - (they are divisible
by 4 but they are not leap years).

qday is the day number in a 4 year cycle from 0..1460.

jday 1461 is January 1, 1905
*/

//from java
class IllegalArgumentException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
     }
}

/**
* IsoDate is a string in the format YYYY-MM-DD
* See https://en.wikipedia.org/wiki/ISO_8601.
* We allow dates that aren't strictly correct, like 2022-02-31 would be legal
* This is just a wrapper around the date string
*/
class IsoDate {
	string iso;

	//default constructor. Don't use, but we have to have it because
	//there are multiple constructors
	this() {
		iso = "1901-01-01";
	}
	
	this(int yyyy,int mm,int dd) {
		if (yyyy < 1901 || yyyy > 2099) {
			throw new IllegalArgumentException("invalid year: " ~ to!string(yyyy));
		} else if (mm < 1 || mm > 12) {
			throw new IllegalArgumentException("invalid month: " ~ to!string(mm));
		} else if (dd < 1 || dd > 31) {
			throw new IllegalArgumentException("invalid day: " ~ to!string(dd));
		} else {
			iso=format("%d-%02d-%02d",yyyy,mm,dd);		
		}
	}

	//create an IsoDate from a string.  It needs to be validated
	this (string s) {
		if (s.length == 0) {
			throw new IllegalArgumentException("invalid date string: '' ");
		}
		string[] sa = s.split("-");
		if (sa.length !=3 ) {
			throw new IllegalArgumentException("invalid date string: " ~ s);
		} 
		//implicit else 
		//delegate to above constructor which validates it
		this( to!int(sa[0]), to!int(sa[1]), to!int(sa[2]) );		
	}
	
	override string toString() {return iso;}

	//split an IsoDate into parts
	int[3] parts() {
		string[] sa = iso.split("-");
		if (sa.length !=3 ) {
			//this shouldn't happen
			throw new IllegalArgumentException("invalid date string: " ~ iso);
		}		
		int[3] ia;
		ia[0] = to!int(sa[0]);
		ia[1] = to!int(sa[1]);
		ia[2] = to!int(sa[2]);
		return ia;
	}
	
	/** 
	* Get the jday of an IsoDate
	* This is a number from 0..72683
	* where 0 is 1901-01-01 and 72683 is 2099-12-31
	*/
	int jday() {
		int[3] p = parts();
		int dpy = daysInPriorYears(p[0]);
		int dpm = daysInPriorMonths(p[0],p[1]);
		return dpy + dpm + p[2] - 1;
	}
	
	/**
	* 1901 => 0
	* 1902 => 365
	* y is the year
	*/
	static int daysInPriorYears(int y) {
		int cycles = ((y - 1901) / 4);	//uses integer division
		//cur will be a value from 0..3, where 3 means divisible by 4 and is a leap year
		//1901 will have a value of 0
		int cur = (y - 1901) % 4;
		if (cur==3) {
			return (cycles * 1461) + 1095;
		} else {
			return (cycles * 1461) + (cur * 365);
		}		
	}

	//this holds the days year to date through the beginning of the month
	//to use this, subtract 1 from the current month and get the value.
	//for example, Feb is the 2nd month, so give it m param 1 to get 31	
	static int daysInPriorMonths(int y,int m) {
		const int[12] MDAYS = [0,31,59,90,120,151,181,212,243,273,304,334];
		int cy = (y - 1901) % 4;
		if (cy==3 && m>2) {
			return MDAYS[m-1]+1;
		} else {
			return MDAYS[m-1];
		}
	}
	
	static string dayOfWeek(int jday) {
		//January 1, 1901 was a Tuesday, so I start with Tuesday
		const string[7] WEEKDAY = ["Tuesday","Wednesday",
			"Thursday","Friday","Saturday","Sunday","Monday"];	
		int dow = jday % 7;
		return WEEKDAY[dow];
	}
	
	static string monthName(int m) {
		const string[13] MONTH = ["","January","February","March","April","May","June",
			"July","August","September","October","November","December"];	
		return MONTH[m];
	}
	
	/**
	* Given the Jday, return the year, month and day, in that order
	* The algorithm can be improved, but I am just trying to get it to return the correct result
	*/
	static int[3] jymd(int jday) {
		int[3] ymd;
		auto q = jday / 1461;
		auto r = jday % 1461;
		auto t = r / 365;
		auto u = r % 365;
		if (r==1460) {
			//handle the oddball case of 12/31/04 
			//and every 4 years thereafter
			ymd[0] = 1901 + (q * 4) + 3;
			ymd[1] = 12;
			ymd[2] = 31;
		} else {
			ymd[0] = 1901 + (q * 4) + t;
			if (r>1153) {
				if (u<60) {
					ymd[1]=2; ymd[2]=(u-30);
				} else if (u < 91) {
					ymd[1]=3; ymd[2]=(u-59);
				} else if (u < 121) {
					ymd[1]=4; ymd[2]=(u-90);
				} else if (u < 152) {
					ymd[1]=5; ymd[2]=(u-120);
				} else if (u < 182) {
					ymd[1]=6; ymd[2]=(u-151); 
				} else if (u < 213) {
					ymd[1]=7; ymd[2]=(u-181); 
				} else if (u < 244) {
					ymd[1]=8; ymd[2]=(u-212); 
				} else if (u < 274) {
					ymd[1]=9; ymd[2]=(u-243); 
				} else if (u < 305) {
					ymd[1]=10; ymd[2]=(u-273); 
				} else if (u < 335) {
					ymd[1]=11; ymd[2]=(u-304);
				} else {
					ymd[1]=12; ymd[2]=(u-334);
				}				
			} else {
				if (u < 31) {
					ymd[1]=1; ymd[2]=(u+1);
				} else if (u < 59) {
					ymd[1]=2; ymd[2]=(u-31+1);
				} else if (u < 90) {
					ymd[1]=3; ymd[2]=(u-59+1);
				} else if (u < 120) {
					ymd[1]=4; ymd[2]=(u-90+1);
				} else if (u < 151) {
					ymd[1]=5; ymd[2]=(u-120+1);
				} else if (u < 181) {
					ymd[1]=6; ymd[2]=(u-151+1); 
				} else if (u < 212) {
					ymd[1]=7; ymd[2]=(u-181+1); 
				} else if (u < 243) {
					ymd[1]=8; ymd[2]=(u-212+1); 
				} else if (u < 273) {
					ymd[1]=9; ymd[2]=(u-243+1); 
				} else if (u < 304) {
					ymd[1]=10; ymd[2]=(u-273+1); 
				} else if (u < 334) {
					ymd[1]=11; ymd[2]=(u-304+1);
				} else {
					ymd[1]=12; ymd[2]=(u-334+1);
				}			
			}
		}
		return ymd;
	}
}	

//----------------------------------------------

void main() {
	import std.string;
	write("Enter a date in the format YYYY-MM-DD: ");
	string line = stdin.readln();
	//writeln(line);
	IsoDate d = new IsoDate(line.strip());
	writeln(d.toString());
	int j = d.jday();
	writeln(j);
	//---------------
	int[] ymd = IsoDate.jymd(j);
	string m = IsoDate.monthName(ymd[1]);
	string dow = IsoDate.dayOfWeek(j);
	
	writeln(dow ~ ", " ~ m ~ " " ~ to!string(ymd[2]) ~ ", " ~ to!string(ymd[0]) );	
}
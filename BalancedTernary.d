/*
* With balanced ternaries a from string "+-0++0+", b from native integer -436, c "+-++-":
* Write out a, b and c in decimal notation;
* Calculate a * (b - c), ; 
* write out the result in both ternary and decimal notations. 


I think this could be done much simpler.  This is mostly an exercise in converting java code
from https://rosettacode.org/wiki/Balanced_ternary

Here are some of the changes:
- convert "String" to "string"
- use "~" to concatenate strings instead of "+"
- instead of "s.charAt(i)", use s[i]
- instead of "a.length()", use "a.length"
*/

import std.stdio;
import std.string;

//substring
string substring(string s, size_t beg, size_t end)
{
    return s[beg .. end];
}

string substring(string s, size_t beg) {
	return s[beg .. $];
}

public class BTernary {
	string value;
	
	//public BTernary(String s)
	this(string s) {
			int i=0;
			//while(s.charAt(i)=='0') {
			while(s[i]=='0') {
				i++;
			}
			this.value=s.substring(i);
	}
		
	//public BTernary(int v)
	this(int v) {
			this.value="";
			this.value=convertToBT(v).idup();
	}
	
	//constructor using char array
	this(char[] ca) {
		this(ca.idup);
	}
		
	//This is static - it doesn't need to be part of the class
	//private string convertToBT(int v)
	private static char[] convertToBT(int v)
	{
		if(v<0)
			return flip(convertToBT(-v));
		if(v==0) {
			return [];
		}
		int rem=mod3(v);
		if(rem==0)
			return convertToBT(v/3) ~ '0';
		if(rem==1)
			return convertToBT(v/3) ~ "+";
		if(rem==2) {
			return convertToBT((v+1)/3) ~ "-";
		}
		return "You can't see me".dup;
	}
	
	//This is static - it doesn't need to be part of the class
	//private string flip(string s)
	private static char[] flip(char[] s)
	{
		char[] flip;
		//string flip="";
		for(int i=0;i<s.length ;i++)
		{
			if(s[i]=='+') {
				//flip+='-';
				flip ~= '-';
			}
			else if(s[i]=='-') {
				//flip+='+';
				flip ~= '+';
			}
			else {
				//flip+='0';
				flip ~= '0';
			}
		}
		return flip;
	}
		
		//This is static - it doesn't need to be part of the class
		private static int mod3(int v)
		{
			if(v>0)
				return v%3;
			v=v%3;
			return (v+3)%3;
		}
		
		public int intValue()
		{
			import std.math;
			int sum=0;
			string s=this.value;
			for(int i=0;i<s.length;i++)
			{
				char c=s[s.length-i-1];
				int dig=0;
				if(c=='+')
					dig=1;
				else if(c=='-')
					dig=-1;
				//sum+=dig*Math.pow(3, i);
				sum += dig*pow(3,i);
			}
			return sum;
		}
		
		
		public BTernary add(BTernary that)
		{
			string a=this.value;
			string b=that.value;
			
			//string longer=a.length()>b.length()?a:b;
			string longer=a.length >b.length ?a:b;
			string shorter=a.length>b.length?b:a;
			
			while(shorter.length<longer.length) {
				//shorter=0+shorter;
				shorter = "0" ~ shorter;
			}
			
			a=longer;
			b=shorter;
			
			char carry='0';
			string sum="";
			for(int i=0;i<a.length;i++)
			{
				int place=cast(int)a.length - cast(int)i - 1;
				string digisum=addDigits(a[place],b[place],carry);
				if(digisum.length!=1) {
					carry=digisum[0];
				}
				else
				{
					carry='0';
				}
				//sum=digisum.charAt(digisum.length()-1)+sum;
				sum= digisum[digisum.length-1] ~ sum;
			}
			//sum=carry+sum;
			sum = carry ~ sum;
			
			return new BTernary(sum);
		}
		
		//This is static - it doesn't need to be part of the class
		private static string addDigits(char a,char b,char carry)
		{
			string sum1=addDigits(a,b);
			string sum2=addDigits(sum1[sum1.length-1],carry);
			//System.out.println(carry+" "+sum1+" "+sum2);
			if(sum1.length==1)
				return sum2;
			if(sum2.length==1) {
				//return sum1[0]+sum2;
				char[] ca = sum1[0] ~ sum2.dup;
				return ca.idup;
			}
			//implied else
			//return sum1[0]+"";
			//there has to be a better way of doing this
			import std.conv;
			return to!string(sum1[0]);
			
		}
		
		//This is static - it doesn't need to be part of the class
		private static string addDigits(char a,char b)
		{
			//string sum="";
			char[] sum;
			if(a=='0')
				sum = [b];
			else if (b=='0')
				//sum=a+"";
				sum = [a];
			else if(a=='+')
			{
				if(b=='+')
					sum = ['+','-'];
				else
					sum= ['0'];
			}
			else
			{
				if(b=='+')
					sum= ['0'];
				else {
					sum = ['-','+'];
				}
			}
			return sum.idup;
		}
		
		public BTernary neg()
		{
			return new BTernary(flip(this.value.dup));
		}
		
		public BTernary sub(BTernary that)
		{
			return this.add(that.neg());
		}
		
		public BTernary mul(BTernary that)
		{
			BTernary one=new BTernary(1);
			BTernary zero=new BTernary(0);
			BTernary mul=new BTernary(0);
			
			int flipflag=0;
			if(that.compareTo(zero)==-1)
			{
				that=that.neg();
				flipflag=1;
			}
			for(BTernary i=new BTernary(1);i.compareTo(that)<1;i=i.add(one))
				mul=mul.add(this);
			
			if(flipflag==1)
				mul=mul.neg();
			return mul;
		}
		
		//public boolean equals(BTernary that)
		public bool equals(BTernary that)
		{
			//return this.value.equals(that.value);
			return this.value == that.value;
		}
		
		public int compareTo(BTernary that)
		{
			if(this.intValue()>that.intValue())
				return 1;
			else if(this.equals(that))
				return 0;
			 return -1;
		}
		
		public override string toString()
		{
			return value;
		}
}


//==========================

void main(string[] args)
{
 		BTernary a=new BTernary("+-0++0+");
		BTernary b=new BTernary(-436);
		BTernary c=new BTernary("+-++-");
		
		writeln("a=", a.intValue());
		writeln("b=", b.intValue());
		writeln("c=", c.intValue());
		writeln();
		
		//result=a*(b-c)
		BTernary result=a.mul(b.sub(c));
		
		writeln("result= ", result, " ", result.intValue());
}

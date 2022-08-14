// this is based on the problem at
// http://www.rosettacode.org/wiki/Dining_philosophers
import std.stdio, std.string, core.sync.mutex, core.thread, std.conv;

/**
* A Fork is an eating utensil.  In the world of dining philosophers,
* you need 2 forks to eat.  To make it more complicated, you can't pick up
* a fork unless you reserve it first.  When you are done with the fork,
* you have to first drop it, then release it. This is to prevent deadlock.
*
* To restate: the sequence is: reserve, pickup, drop, release
*/
shared class Fork {
	int id;
	Mutex mu;
	int holder;
	// state 0 = free; state 1 = reserved; state 2 = locked
	int state;
	
	//constructor
	this(int num) {
		id = num;
		mu = new shared Mutex();
		holder = -1;
		state = 0;
	}
	
	//return name as a string
	string stringName() { return "Fork# " ~ to!string(id);}
	
	bool isFree() {return state == 0;}
	
	//return true if you were able to reserve it or false if not
	bool reserve(int h) {
		synchronized { 
			if (state == 0) {
				holder = h;
				state = 1;
				return true;
			} else {
				return false;
			}
		}
	}
	
	//release the reservation
	//this doesnt have to be sychronized
	bool release(int h) {
		if ((state == 1) && (holder == h)) {
			holder = -1;
			state = 0;
			return true;				
		} else {
			return false;
		}
	}

	bool pickup(int h) {
		if ((state == 1) && (holder == h)) {
			state = 2;
			mu.lock();
			return true;				
		} else {
			return false;
		}
	}	
	
	bool drop(int h) {
		if ((state == 2) && (holder == h)) {
			state = 1;
			mu.unlock();
			return true;				
		} else {
			return false;
		}	
	}
}

//========================
// Forks
Fork[5] forks;

void initForks(int n) {
	for (int i = 0; i< n; i++) {
		forks[i]=new Fork(i);
		write("setting fork ");
		writeln(i);
	}
}

Fork getFork(int i) {
	return forks[i];
}

//=================================
enum PhiloState {
	Ready,
	Hungry,	
	Eating,
	Pondering,
	Done
}

class Philosopher : Thread {
	int id; 			//number from 0..6
	string name; 
	PhiloState state; 	//one of the states above
	int course;
	int leftfork; 
	int rightfork;
	
	//constructor
	this(int num,string nam,int left,int right) {
		super(&run);
		this.id = num;
		this.name = nam;
		this.state = PhiloState.Ready;
		course = 0;
		this.leftfork = left;
		this.rightfork = right;
		write(name ~ " sits down at the table. ");
	}
	
	string getName() {return name;}
	
	string getState() {
		switch (state) {
			case PhiloState.Ready: return "ready";
			case PhiloState.Hungry: return "hungry";
			case PhiloState.Eating: return "eating";
			case PhiloState.Pondering: return "pondering";
			case PhiloState.Done: return "done";
			default: return "default";
		}
	}
	
	void setState(PhiloState st) {
		state = st;
	}
	
	bool isDone() {
		return state == PhiloState.Done;
	}

	void wait(string s) {
		write("..." ~ name ~ s);
		Thread.sleep(50.msecs);  // sleep for 50 milliseconds
	}

	//try to eat.  if you can't, drop both forks and wait
	void dine() {
		write(name ~ " is trying to eat. ");
		Fork lf = getFork(leftfork);
		Fork rf = getFork(rightfork);
		bool waiting = true;
		while (waiting) {
			//try to reserve the forks
			if (lf.reserve(id) && rf.reserve(id)) {
				waiting = false;
				write(name ~ " picks up " ~ lf.stringName() ~ ". ");
				lf.pickup(id);
				write(name ~ " picks up " ~ rf.stringName() ~ ". ");
				rf.pickup(id);
				setState(PhiloState.Eating);
				write(name ~ " is " ~ getState() ~ ". ");			
				wait(" [chomp chomp]. ");
				write(name ~ " drops " ~ lf.stringName() ~ ". ");
				lf.drop(id);
				write(name ~ " drops " ~ rf.stringName() ~ ". ");
				rf.drop(id);
				lf.release(id);
				rf.release(id);
			} else {
				//abort, release both forks
				lf.release(id);
				rf.release(id);			
				wait(" is looking for a fork. ");
			}
		}
	}

	private : void run() {
		wait(" waits patiently for dinner to begin. ");
		for ( ; course < 4; course++ ) {
			setState(PhiloState.Hungry);
			write(name ~ " is " ~ getState() ~ ". ");
			dine();
			setState(PhiloState.Pondering);
			write(name ~ " is " ~ getState()~ ". ");
			wait(" is theorizing. ");
		}
		setState(PhiloState.Done);
		write(name ~ " is " ~ getState()~ ". ");
	}
}

//=================================
void main() {
	writeln("Welcome to Dining Philosophers");
	writeln("There are 5 philosophers and 5 forks.");
	writeln("A philosophers needs 2 forks to eat.");
	writeln("Can they cooperate by sharing forks?");

	initForks(5);
	
	auto a = new Philosopher(0,"Aristotle",0,1);
	auto k = new Philosopher(1,"Kant",1,2);
	auto m = new Philosopher(2,"Marx",2,3);	
	auto p = new Philosopher(3,"Plato",3,4);
	auto r = new Philosopher(4,"Russell",4,0);		
	a.start();
	k.start();
	m.start();
	p.start();
	r.start();
}
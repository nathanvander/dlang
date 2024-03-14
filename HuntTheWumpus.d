import std.stdio;
import std.random;

//Hunt The Wumpus
//Based on the C++ version
//at https://rosettacode.org/wiki/Hunt_the_Wumpus

// constant value 2d array to represent the dodecahedron
// room structure. rooms are numbered 0..19
//this has 3 columns and 20 rows
const static int[3][20] adjacentRooms = [
  [1, 4, 7],   [0, 2, 9],   [1, 3, 11],   [2, 4, 13],    [0, 3, 5],
  [4, 6, 14],  [5, 7, 16],   [0, 6, 8],   [7, 9, 17],   [1, 8, 10],
  [9, 11, 18], [2, 10, 12], [11, 13, 19],  [3, 12, 14],  [5, 13, 15],
  [14, 16, 19], [6, 15, 17],  [8, 16, 18], [10, 17, 19], [12, 15, 18]
];

static Random RNG; 

//-------------------------------------------------
//helper functions
//returns the first character entered
char inputChar() {
	import std.string;
 	string input = strip(stdin.readln()); 
 	if (input.length == 0) {
 		return ' ';
 	} else {
		return input[0];
	}
}

//returns a number from 0..9, or -1 if it is any other character
int inputNum() {
	char c = inputChar();
	int v = cast(int)c;
	if (v > 47 && v < 58) {
		return v - 48;
	} else {
		return -1;
	}
}

//returns number inputed, including negative number
//returns -32768 if invalid
int inputBigNumber() {
	import std.conv;
	import std.string;
 	string input = strip(stdin.readln());  
 	try {
 		return to!int(input);	
 	} catch (Exception x) {
 		return -32768;
 	}
}

//This is the random number function.
//return a number from 0 .. range-1
int get_random(int range) {
	return uniform(0, range , RNG);
}

//there are other ways to do this, but I am using the current milliseconds to init
void init_randomizer() {
	uint m=get_millis;
	RNG = Random(m);
}

uint get_millis() {
	import std.datetime.systime;
	import core.time;
	SysTime now = Clock.currTime();
	Duration frac = now.fracSecs;	
	long msecs=frac.total!("msecs");
	return cast(uint)msecs;
}

//---------------------------------------
class WumpusGame {

	// Data Members
    int numRooms;
    int currentRoom, startingPosition; // currentRoom is an integer variable that stores the room the player is currently in (between 0-20)
    int wumpusRoom, batRoom1, batRoom2, pitRoom1, pitRoom2; // Stores the room numbers of the respective
    int wumpusStart, bat1Start, bat2Start;
    bool playerAlive, wumpusAlive; // Are the player and wumpus still alive? True or false.
    int numArrows; //store arrow count

    // private functions
    //void PlacePits();
    //void PlaceBats();
    //void PlaceWumpus();
    //void PlacePlayer();
    //bool IsValidMove(int);
    //bool IsRoomAdjacent(int, int);
    //int Move(int);
    //void InspectCurrentRoom();
    //void PerformAction(int);
    //void MoveStartledWumpus(int);
    //void PlayGame();
    //void PlayAgain();
    //void PrintInstructions();

	// default constructor
	this() {
		numRooms = 20;	
		init_randomizer();
	}

	// This function prints the instructions for the game
	// to the console
	void PrintInstructions() {
    	writeln(" Welcome to 'Hunt the Wumpus'! ");
    	writeln(" The wumpus lives in a cave of 20 rooms. Each room has 3 tunnels leading to");
    	writeln(" other rooms. (Look at a dodecahedron to see how this works - if you don't know");
    	writeln(" what a dodecahedron is, ask someone). \n");
    	writeln(" Hazards: \n");
    	writeln(" Bottomless pits - two rooms have bottomless pits in them. If you go there, you ");
    	writeln(" fall into the pit (& lose!) \n");
    	writeln(" Super bats - two other rooms have super bats.  If you go there, a bat grabs you");
    	writeln(" and takes you to some other room at random. (Which may be troublesome). Once the");
    	writeln(" bat has moved you, that bat moves to another random location on the map.\n\n");

    	writeln(" Wumpus");
    	writeln(" The wumpus is not bothered by hazards (he has sucker feet and is too big for a");
    	writeln(" bat to lift).  Usually he is asleep.  Two things wake him up: you shooting an");
    	writeln(" arrow or you entering his room. If the wumpus wakes he moves (p=.75) one room or ");
    	writeln(" stays still (p=.25). After that, if he is where you are, he eats you up and you lose!\n");

    	writeln(" You \n");
    	writeln(" Each turn you may move, save or shoot an arrow using the commands move, save, & shoot.");
    	writeln(" Moving: you can move one room (thru one tunnel).");
    	writeln(" Arrows: you have 3 arrows. You lose when you run out. You aim by telling the");
    	writeln(" computer the rooms you want the arrow to go to.  If the arrow can't go that way");
    	writeln(" (if no tunnel), the arrow will not fire.");

    	writeln(" Warnings");
    	writeln(" When you are one room away from a wumpus or hazard, the computer says:");
	
    	writeln(" Wumpus: 'I smell a wumpus'");
    	writeln(" Bat: 'Bats nearby'");
    	writeln(" Pit: 'I feel a draft'");

    	writeln();
    	writeln("Press Y to return to the main menu.");
    	inputChar();
	}

	// This function will place two bats throughout the map
	// this ensures that the bats will not be place in the same
	// room as another bat or the wumpus
	void PlaceBats() {		
  		bool validRoom = false;
  		while(!validRoom) {
      		batRoom1 = get_random(20);
      		if(batRoom1 != wumpusRoom) {
          		validRoom = true;
          	}
  		}

  		validRoom = false;
  		while(!validRoom) {
      		batRoom2 = get_random(20);
      		if(batRoom2 != wumpusRoom && batRoom2 != batRoom1) {
          		validRoom = true;
          	}
  		}
  		bat1Start = batRoom1;
  		bat2Start = batRoom2;
	}

	// this function randomly places the pits
	// throughout the map excluding room 0
	void PlacePits() {
    	pitRoom1 = get_random(19) + 1;
    	pitRoom2 = get_random(19) + 1;
	}

	// this function randomly places the wumpus in a room
	// without being in room number 0
	void PlaceWumpus() {
	    int randomRoom = get_random(19) + 1;
	    wumpusRoom = randomRoom;
	    wumpusStart = wumpusRoom;
	}

	// place the player in room 0
	void PlacePlayer() {
	    startingPosition = 0;
	    currentRoom = Move(0);
	}

	// This is a  method that checks if the user inputted a valid room to move to or not.
	// The room number has to be between 0 and 20, but also must be adjacent to the current room.
	bool IsValidMove(int roomID) {
	    if (roomID < 0) return false;
	    if (roomID > numRooms) return false;
	    if (!IsRoomAdjacent(currentRoom, roomID)) return false;

	    return true;
	}

	// This method returns true if roomB is adjacent to roomA, otherwise returns false.
	// It is a helper method that loops through the adjacentRooms array to check.
	// It will be used throughout the app to check if we are next to the wumpus, bats, or pits
	// as well as check if we can make a valid move.
	//roomA and roomB are values from 0..19
	bool IsRoomAdjacent(int roomA, int roomB)
	{
		//writeln("[DEBUG: in room ", roomA, ", and checking if ",roomB, " is adjacent");
	    for (int j = 0; j < 3; j++)
	    {
	        //if (adjacentRooms[roomA][j] == roomB){
	        if (adjacentRooms[roomA][j] == roomB){
	        	//writeln("[DEBUG: yes]");
	          return true;
	        }
	    }
	    //writeln("[DEBUG: no]");
	    return false;
	}

	// This method moves the player to a new room and returns the new room. It performs no checks on its own.
	int Move(int newRoom)
	{
	    return newRoom;
	}

	// Inspects the current room.
	// This method check for Hazards such as being in the same room as the wumpus, bats, or pits
	// It also checks if you are adjacent to a hazard and handle those cases
	// Finally it will just print out the room description
	void InspectCurrentRoom() {
	    if (currentRoom == wumpusRoom)
	    {
	        writeln("The Wumpus ate you!!!");
	        writeln("LOSER!!!");
	        PlayAgain();
	    }
	    else if (currentRoom == batRoom1 || currentRoom == batRoom2)
	    {
	        int roomBatsLeft = currentRoom;
	        bool validNewBatRoom = false;
	        //this variable is misnamed, it actually means isNotBatRoom, but I won't change it
	        bool isBatRoom = false;
	        writeln("Snatched by superbats!!");
	        if(currentRoom == pitRoom1 || currentRoom == pitRoom2) {
	            writeln("Luckily, the bats saved you from the bottomless pit!!");
	        }
	        while(!isBatRoom) {
	            currentRoom = Move(get_random(20));
	            if(currentRoom != batRoom1 && currentRoom != batRoom2) {
	            	//I don't understand this logic
	                isBatRoom = true;
	            }
	        }
	        writeln("The bats moved you to room ", currentRoom);
	        InspectCurrentRoom();

	        if(roomBatsLeft == batRoom1){
	            while(!validNewBatRoom){
	                batRoom1 = get_random(19) + 1;
	                if(batRoom1 != wumpusRoom && batRoom1 != currentRoom)
	                    validNewBatRoom = true;
	            }
	        } else {
	            while(!validNewBatRoom){
	                batRoom2 = get_random(19) + 1;
	                if(batRoom2 != wumpusRoom && batRoom2 != currentRoom)
	                    validNewBatRoom = true;
	            }
	        }
	    }
	    else if(currentRoom == pitRoom1 || currentRoom == pitRoom2)
	    {
	        writeln("YYYIIIIIEEEEE.... fell in a pit!!!");
	        writeln("GAME OVER LOSER!!!");
	        PlayAgain();
	    }
	    else
	    {
	        writeln("You are in room ", currentRoom);
	        if (IsRoomAdjacent(currentRoom, wumpusRoom)){
	            writeln("You smell a horrid stench...");
	        }
	        if (IsRoomAdjacent(currentRoom, batRoom1) || IsRoomAdjacent(currentRoom, batRoom2)){
	            writeln("Bats nearby...");
	        }
	        if (IsRoomAdjacent(currentRoom, pitRoom1) || IsRoomAdjacent(currentRoom, pitRoom2)){
	            writeln("You feel a draft...");
	        }
	        writeln("Tunnels lead to rooms ");
	        for (int j = 0; j < 3; j++)
	        {
	            writeln(adjacentRooms[currentRoom][j]);
	        }
	        //debugging
	        writeln("(Psst. The wumpus is in room ",wumpusRoom,")");
	    }
	}
	
	void PerformActionMove() {
    	//case 1:
		writeln("Which room? ");
        int newRoom = inputBigNumber();
        if (newRoom < 0 || newRoom > 19) {
        	writeln("You cannot move there.");
        } else {
        	// Check if the user inputted a valid room id, then simply tell the player to move there.
            if (IsValidMove(newRoom))
            {
            	currentRoom = Move(newRoom);
                InspectCurrentRoom();
			}
            else
            {
            	writeln("You cannot move there.");
            }

		}
	}

	void PerformActionShoot() {
        //case 2:
        if (numArrows < 1) {
        	writeln("You do not have any arrows!");
        	return;
        }
		writeln("Which room? ");
       	int newRoom = inputBigNumber();
       	if (newRoom < 0 || newRoom > 19) {
       		writeln("You cannot shoot there.");
       		writeln("[DEBUG: ",newRoom," is invalid]");
        	return;
        }        	

		// Check if the user inputted a valid room id, then simply tell the player to move there.
        if (IsValidMove(newRoom)) {
        	numArrows--;
           	if (newRoom == wumpusRoom){
            	writeln("ARGH.. Splat!");
                writeln("Congratulations! You killed the Wumpus! You Win.");
                writeln("Press 'Y' to return to the main menu.");
                wumpusAlive = false;
                inputChar();
            }
            else
            {
            	writeln("Miss! But you startled the Wumpus");
                MoveStartledWumpus(wumpusRoom);
                writeln("Arrows Left: ", numArrows);
                if (wumpusRoom == currentRoom){
                	writeln("The wumpus attacked you! You've been killed.");
                    writeln("Game Over!");
                    PlayAgain();
                }
            }
		} else {
			writeln("You cannot shoot there.");
			writeln("[DEBUG: invalid room]");
		}
	}
	
	void PerformActionQuit() {
    	writeln("Quitting the current game.");
        playerAlive = false;	
	}

	// this function moves the wumpus randomly to a room that is adjacent to
	// the wumpus's current position
	void MoveStartledWumpus(int roomNum){
	    int rando = get_random(3);
	    if(rando != 3)
	        wumpusRoom = adjacentRooms[roomNum][rando];
	}

	// This restarts the map from the beginning without resetting the locations
	void PlayAgain(){
	    char reply;
	    writeln("Would you like to replay the same map? Enter Y to play again.");
	    reply = inputChar();
	    if(reply == 'y' || reply == 'Y'){
	        currentRoom = startingPosition;
	        wumpusRoom = wumpusStart;
	        batRoom1 = bat1Start;
	        batRoom2 = bat2Start;
	        writeln("Try not to die this time.");
	        InspectCurrentRoom();
	    } else {
	        playerAlive = false;
	    }
	}

	// PlayGame() method starts up the game.
	// It houses the main game loop and when PlayGame() quits the game has ended.
	void PlayGame()
	{
		int choice;
		bool validChoice = false;

		writeln("Running the game...");

  		// Initialize the game
		PlaceWumpus();
		PlaceBats();
		PlacePits();
		PlacePlayer();

		// game set up
		playerAlive = true;
		wumpusAlive = true;
		numArrows = 3;

    	//Inspects the initial room
    	InspectCurrentRoom();

    	// Main game loop.
    	while (playerAlive && wumpusAlive)
    	{
    	    writeln("Enter an action choice.");
    	    writeln("1) Move");
    	    writeln("2) Shoot");
    	    writeln("3) Quit");
    	    writeln(">>> ");

        	do
        	{
	            validChoice = true;
	            writeln("Please make a selection: ");
	           	choice = inputNum();
	            switch (choice)
	                {
	                    case 1:
	                        PerformActionMove();
	                        break;
	                    case 2:
	                        PerformActionShoot();
	                        break;
	                    case 3:
	                        PerformActionQuit();
	                        break;
	                    default:
	                        validChoice = false;
	                        writeln("Invalid choice. Please try again.");
	                        break;
	                }
	
	        } while (validChoice == false);
	    }
	}

	// this function begins the game loop
	void StartGame() {
		int choice;
  		bool validChoice;
  		bool keepPlaying;
  		wumpusStart = bat1Start = bat2Start = -1;

  		do {
      		keepPlaying = true;
      		writeln("Welcome to Hunt The Wumpus.");
      		writeln("1) Play Game");
      		writeln("2) Print Instructions");
      		writeln("3) Quit");

      		do {
          		validChoice = true;
          		writeln("Please make a selection: ");

          			choice = inputNum();
              		switch (choice)
              		{
              		    case 1:
              		        PlayGame();
              		        break;
              		    case 2:
              		        PrintInstructions();
              		        break;
              		    case 3:
              		        writeln("Quitting.");
              		        keepPlaying = false;
              		        break;
              		    default:
              		        validChoice = false;
              		        writeln("Invalid choice. Please try again.");
                      		break;
              		}
        	} while (validChoice == false);
  		} while (keepPlaying);
	}
}

//-------------------
void main() {
    // create wumpus game object
    WumpusGame game = new WumpusGame();
    // start the game
    game.StartGame();
}
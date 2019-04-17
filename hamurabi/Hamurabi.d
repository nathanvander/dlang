/**
 * The Hamurabi game in D.
 * For background see: https://en.wikipedia.org/wiki/Hamurabi_(video_game)
 * The Java source is from: https://www.cis.upenn.edu/~matuszek/cit590-2009/Examples/Hammurabi.java
 * Note that the proper spelling is Hammurabi with 2 m's, but the game has only 1 m.
 *
 */
module hamurabi;
import std.stdio;
import std.random;
import std.conv;
import std.string;

	//game variables
	Random rand;
	int year;
	int population;
	int grain;
	int acres;
	int landValue;
	int starved;
	int percentStarved;
	int plagueVictims;
	int immigrants;
	int grainHarvested;
	int harvestPerAcre;
	int amountEatenByRats;
	int grainFedToPeople;
	int acresPlanted;
	const string OGH = "O Great Hammurabi!";

	//--------------------------------
	//helper functions

	//This is the random number function
	int get_random(int range) {
		return uniform(0, range , rand);
	}

	//there are other ways to do this, but I am using the current milliseconds to init
	void init_randomizer() {
		uint m=get_millis;
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
	
    /**
     * Prints the given message (which should ask the user for some integral
     * quantity), and returns the number entered by the user. If the user's
     * response isn't an integer, the question is repeated until the user does
     * give a integer response.
     *
     * @param message
     *            The request to present to the user.
     * @return The user's numeric response.
     */
    int getNumber(string message) {
        while (true) {
            writeln(message);
            
            auto input = strip(stdin.readln());
            try {
				return to!int(input);
			} catch (std.conv.ConvException x) {
				writeln(input ~ " isn't a number!");
            }
        }
    }	

    /**
     * Tells user that the request cannot be fulfilled.
     *
     * @param message The reason the request cannot be fulfilled.
     */
    void jest(string message) {
        writeln(OGH ~ ", surely you jest!");
        writeln(message);
    }

	//--------------------------------
	//main method
	void main() {
		init_randomizer;
		printIntroductoryParagraph;
		playGame;
	}

	//starts with an homage to the basic source code
	void printIntroductoryParagraph() {
		writeln("
HAMURABI 
CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY.

Congratulations! You are the newest ruler of ancient Samaria,
elected for a ten year term of office. Your duties are to
dispense food, direct farming, and buy and sell land as
needed to support your people. Watch out for rat infestations
and the plague! Grain is the general currency, measured in
bushels.

The following will help you in your decisions:                
   * Each person needs at least 20 bushels of grain per year to survive
   * Each person can farm at most 10 acres of land
   * It takes 2 bushels of grain to farm an acre of land
   * The market price for land fluctuates yearly
     
Rule wisely and you will be showered with appreciation at the
end of your term. Rule poorly and you will be kicked out of office!
		");
	}

	//--------------------------------
	//play the game
    void playGame() {
        bool stillInOffice = true;

        initializeVariables();
        printSummary();
        while (year <= 10 && stillInOffice) {
            buyLand();
            sellLand();
            feedPeople();
            plantGrain();

            checkForPlague();
            countStarvedPeople();
            if (percentStarved >= 45) {
                stillInOffice = false;
            }
            countImmigrants();
            takeInHarvest();
            checkForRats();
            updateLandValue();
            printSummary();
            year = year + 1;
        }
        printFinalScore();
    }

    /**
     * Initialize all instance variables for start of game.
     */

    void initializeVariables() {
        year = 1;
        population = 100;
        grain = 2800;
        acres = 1000;
        landValue = 19;
        starved = 0;
        plagueVictims = 0;
        immigrants = 5;
        grainHarvested = 3000;
        harvestPerAcre = 3;
        amountEatenByRats = 200;
    }

    /**
     * Prints the year-end summary.
     */
	void printSummary() {
        writeln("___________________________________________________________________");
        writeln(OGH);
        writeln("You are in year " ~ to!string(year) ~ " of your ten year rule.");
        if (plagueVictims > 0) {
            writeln("A horrible plague killed " ~ to!string(plagueVictims) ~ " people.");
        }
        writeln("In the previous year " ~ to!string(starved) ~ " people starved to death,");
        writeln("and " ~ to!string(immigrants) ~ " people entered the kingdom.");
        writeln("The population is now " ~ to!string(population) ~ ".");
        writeln("We harvested " ~ to!string(grainHarvested) ~ " bushels at " ~ to!string(harvestPerAcre) ~ " bushels per acre.");
        if (amountEatenByRats > 0) {
            writeln("*** Rats destroyed " ~ to!string(amountEatenByRats) ~ " bushels, leaving " ~ to!string(grain) ~ " bushels in storage.");
        } else {
            writeln("We have " ~ to!string(grain) ~ " bushels of grain in storage.");
        }
        writeln("The city owns " ~ to!string(acres) ~ " acres of land.");
        writeln("Land is currently worth " ~ to!string(landValue) ~ " bushels per acre.");
        writeln();
    }

    /**
     * Allows the user to buy land.
     */
    void buyLand() {
        int acresToBuy;
        string question = "How many acres of land will you buy? ";

        acresToBuy = getNumber(question);
        int cost = landValue * acresToBuy;
        while (cost > grain) {
            jest("We have but " ~ to!string(grain) ~ " bushels of grain, not " ~ to!string(cost) ~ "!");
            acresToBuy = getNumber(question);
            cost = landValue * acresToBuy;
        }
        grain = grain - cost;
        acres = acres + acresToBuy;
        writeln(OGH ~ ", you now have " ~ to!string(acres) ~ " acres of land");
        writeln("and " ~ to!string(grain) ~ " bushels of grain.");
    }



    /**
     * Allows the user to sell land.
     */
    void sellLand() {
        string question = "How many acres of land will you sell? ";
        int acresToSell = getNumber(question);

        while (acresToSell > acres) {
            jest("We have but " ~ to!string(acres) ~ " acres!");
            acresToSell = getNumber(question);
        }
        grain = grain + landValue * acresToSell;
        acres = acres - acresToSell;
        writeln(OGH ~ ", you now have " ~ to!string(acres) ~ " acres of land");
        writeln("and " ~ to!string(grain) ~ " bushels of grain.");
    }

    /**
     * Allows the user to decide how much grain to use to feed people.
     */
    private void feedPeople() {
        string question = "How much grain will you feed to the people? ";
        grainFedToPeople = getNumber(question);

        while (grainFedToPeople > grain) {
            jest("We have but " ~ to!string(grain) ~ " bushels!");
            grainFedToPeople = getNumber(question);
        }
        grain = grain - grainFedToPeople;
        writeln(OGH ~ ", " ~ to!string(grain) ~ " bushels of grain remain.");
    }

    /**
     * Allows the user to choose how much grain to plant.
     */
    private void plantGrain() {
        string question = "How many bushels will you plant? ";
        int amountToPlant = 0;
        bool haveGoodAnswer = false;

        while (!haveGoodAnswer) {
            amountToPlant = getNumber(question);
            if (amountToPlant > grain) {
                jest("We have but " ~ to!string(grain) ~ " bushels left!");
            } else if (amountToPlant > 2 * acres) {
                jest("We have but " ~ to!string(acres) ~ " acres available for planting!");
            } else if (amountToPlant > 20 * population) {
                jest("We have but " ~ to!string(population) ~ " people to do the planting!");
            } else {
                haveGoodAnswer = true;
            }
        }
        acresPlanted = amountToPlant / 2;
        grain = grain - amountToPlant;
        writeln(OGH ~ ", we now have " ~ to!string(grain) ~ " bushels of grain in storage.");
    }

    /**
     * Checks for plague, and counts the victims.
     */
    private void checkForPlague() {
        //if (rand.nextDouble() < 0.15) {
        int chance = get_random(100);
        if (chance < 15) {
        	writeln("*** A horrible plague kills half your people! ***");
            plagueVictims = population / 2;
            population = population - plagueVictims;
        } else {
            plagueVictims = 0;
        }
    }

    /**
     * Counts how many people starved, and removes them from the population.
     */
    private void countStarvedPeople() {
        int peopleFed = grainFedToPeople / 20;
        if (peopleFed >= population) {
            starved = 0;
            percentStarved = 0;
            writeln("Your people are well fed and happy.");
        } else {
            starved = population - peopleFed;
            writeln(to!string(starved) ~ " people starved to death.");
            percentStarved = (100 * starved) / population;
            population = population - starved;
        }
    }

    /**
     * Counts how many people immigrated.
     */
    private void countImmigrants() {
        if (starved > 0) {
            immigrants = 0;
        } else {
            immigrants = (20 * acres + grain) / (100 * population) + 1;
            population += immigrants;
        }
    }

    /**
     * Determines the harvest, and collects the new grain.
     */
    private void takeInHarvest() {
        harvestPerAcre = get_random(5) + 1;
        grainHarvested = harvestPerAcre * acresPlanted;
        grain = grain + grainHarvested;
    }

    /**
     * Checks if rats get into the grain, and determines how much they eat.
     */

    private void checkForRats() {
        if (get_random(100) < 40) {
            int percentEatenByRats = 10 + get_random(21);
            writeln("*** Rats eat " ~ to!string(percentEatenByRats) ~ " percent of your grain! ***");
            amountEatenByRats = (percentEatenByRats * grain) / 100;
            grain = grain - amountEatenByRats;
        } else {
            amountEatenByRats = 0;
        }
    }

    /**
     * Randomly sets the new price of land.
     */
    private void updateLandValue() {
        landValue = 17 + get_random(7);
    }

    /**
     * Prints an evaluation at the end of a game.
     */
    private void printFinalScore() {
        if (starved >= (45 * population) / 100) {
        	writeln("O Once-Great Hammurabi");
			writeln(to!string(starved) ~ " of your people starved during the last year of your");
			writeln("incompetent reign! The few who remain have stormed the palace");
            writeln("and bodily evicted you!");
            writeln("\nYour final rating: TERRIBLE.");
            return;
        }
        int plantableAcres = acres;
        if (20 * population < plantableAcres) {
            plantableAcres = 20 * population;
        }

        if (plantableAcres < 600) {
            writeln("Congratulations, " ~ OGH);
            writeln(" You have ruled wisely but not");
            writeln("well; you have led your people through ten difficult years, but");
            writeln("your kingdom has shrunk to a mere " ~ to!string(acres));
            writeln(" acres.\n" ~ "\nYour final rating: ADEQUATE.");
        } else if (plantableAcres < 800) {
            writeln("Congratulations, \" + OGH + \" You  have ruled wisely, and");
            writeln("shown the ancient world that a stable economy is possible.");
            writeln("\nYour final rating: GOOD.");
        } else {
            writeln("Congratulations, " ~ OGH ~ " You  have ruled wisely and well, and");
            writeln("expanded your holdings while keeping your people happy.");
            writeln("Altogether, a most impressive job!");
            writeln("\nYour final rating: SUPERB.");
        }
    }

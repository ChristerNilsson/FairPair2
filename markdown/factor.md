## The FACTOR method

Where is Elo's origin?  

* XMIN = minimum elo rating of all players
* XMAX = maximum elo rating of all players
* FACTOR is supposed to be >= 1.2
* OFFSET = (XMAX - XMIN) / (FACTOR - 1) - XMIN
* The rating is translated by OFFSET
* Example:
	* XMIN = 1406
	* XMAX = 2416
	* player at 1600 meets a 1700 rated player
* FACTOR == 2:
	* OFFSET => -396
	* Interval = [1010, 2020] (FACTOR * 1010 = 2020)
	* WIN
		* 1600 gets 1700 - 396 = 1306
		* 1700 gets 1600 - 396 = 1206
	* DRAW
		* 1600 gets 0.5 * 1306 = 653
		* 1700 gets 0.5 * 1206 = 603
	* LOSS 
		* 1600 gets 0
		* 1700 gets 0
* FACTOR == 3:
	* OFFSET => -901
	* Interval => [505, 1515] (FACTOR * 505 = 1515)
	* WIN
		* 1600 gets 1700 - 901 = 799
		* 1700 gets 1600 - 901 = 699
	* DRAW
		* 1600 gets 0.5 * 799 = 399.5
		* 1700 gets 0.5 * 699 = 349.5
	* LOSS 
		* 1600 gets 0
		* 1700 gets 0
* The contradiction
	* High FACTOR makes winning easier for high ranked
	* Low  FACTOR makes winning easier for low  ranked
	* Somewhere there is a sweet spot

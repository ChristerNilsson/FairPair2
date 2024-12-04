# Teknik

* Spela in med MS Snipping Tool. Nås via tangenten Print Screen
* Använd t ex Sennheiser BlueTooth Headset
* Dela in avsnitten efter t ex skärmarna. Döp dem till A, B osv
* Sätt ihop delarna med MS ClipChamp
* Resultatet hamnar på Downloads

-------------------------------------------------------------------

Ersätt Schweizer-systemet med ett lottningssystem som gör turneringar mer jämna och spännande!

Varken den starkare eller den svagare spelaren uppskattar förutsägbara partier.

Schweizer-systemet är orättvist: en vinst mot en högrankad spelare är värd exakt lika mycket som en vinst mot en lågrankad spelare.

Principer för ett sådant system:
1. Para ihop spelare med liknande Elo Performance
2. Använd Elo Performance för att avgöra placering

Dags att damma av den gamla principen: Lika barn leka bäst!

Här kan du jämföra Schweizer-systemet och det nya systemet: (youtube-länk)

Prova det nya systemet: (github-länk)

-------------------------------------------------------------------

Replace the Swiss system with a pairing system that makes tournaments more balanced and exciting!

Neither the stronger nor the weaker player appreciates predictable games.

The Swiss system is unfair: a win against a high-rated player is worth exactly as much as a win against a low-rated player.

Principles for such a system:
a) Pair players with similar Elo Performance
b) Use ELO Performance to determine standings

Time to revive the old principle: Birds of a feather flock together!

Here you can compare the Swiss system and the new system: (youtube link)

Try the new system: (github link)

-------------------------------------------------------------------

# Intro

[A Tyresö Open 2024](https://member.schack.se/ShowTournamentServlet?id=13664&listingtype=2).  
This is the score sheet of a Swiss tournament in Sweden, named Tyresö Open 2024.  
It had eight rounds and 81 participants.  
Here you see the eight rounds,
and if you scroll down here you will see the 81 participants.
As you can see in the first round there was a huge ELO gap between the players. Number 1 with ELO 2416 met 53 with ELO 1835, that is a gap of around 600 elos.

[B ELO Chart](https://docs.google.com/spreadsheets/d/1DHRnlp8Q6RnnG-gF-fg0liyS2zZINEF5typxI497JyE/edit?gid=483813383#gid=483813383)

In this chart I'm showing the sorted ELO ratings.  
Here we have the highest rating, 2416
and here we have the lowest, 1406.

[C 1985 Nordenfur](https://docs.google.com/spreadsheets/d/1DHRnlp8Q6RnnG-gF-fg0liyS2zZINEF5typxI497JyE/edit?gid=243754366#gid=243754366)
Let's study one player, Mr Nordenfur.
He has elo 1985 and is marked in this green bar.  
The red bars indicates the players he met in the Swiss tournament,  
ranging from 1721 to 2416, a range of 695 elos.  
The dark blue bars indicates the players he would have met using ELO Pairings instead,  
ranging from 1936 up to 2035, a range of 99 elos.  
Please note, in Swiss he never met ANY of his closest players.  

[D 1828 Johansson](https://docs.google.com/spreadsheets/d/1DHRnlp8Q6RnnG-gF-fg0liyS2zZINEF5typxI497JyE/edit?gid=10301852#gid=10301852)
Here we have Mr Johansson, with en elo rating of 1828.  
This is the first round and this is the last, eight round of the Tyresö tournament.
The blue bars indicates ELO Pairings and the red bars Swiss Pairings.  
In the first round Mr Johansson met a strong player having 538 higher elo.
Please note the big swings in Swiss, like an elevator or roller coaster.
ELO Pairings starts with the closest player, in elo,  
and then the amplitude rises slowly with every round.  
Compare the red bars with the blue bars and you will see the ELO bars are much smaller.
Note the differences: 538 vs 25  

[E Swiss Matrix](https://docs.google.com/spreadsheets/d/1DHRnlp8Q6RnnG-gF-fg0liyS2zZINEF5typxI497JyE/edit?gid=1809770193#gid=1809770193)
This matrix indicates which player met each other.  
On one axis you have one player 
and on the other axis you have a another player.
A player can never meet himself, so these impossible meetings are indicated with an asterix.
It is mirrored in the main diagonal and  
contains the round numbers.  
Both axis are sorted by elo strength, with the upper left corner containing the strongest players.
On this row we will find Mr Nordenfur with elo rating 1985.
We can see that he met this weak player in round 1.
He won of course that game and then had to meet the strongest player in round 2.
He lost there and then met a weaker player in round 3.
Here we have the rounds 4, 5, 6, 7 and finally round number 8.
As you can see there was a lot of swinging,
the worst gap being around 750 elos.

[F ELO Matrix](https://docs.google.com/spreadsheets/d/1DHRnlp8Q6RnnG-gF-fg0liyS2zZINEF5typxI497JyE/edit?gid=830847657#gid=830847657)
This is the ELO Matrix.
It is the same tournament, but paired using ELO Pairings instead.  
Let me zoom so we can see the complete picture.
Here you see the main diagonal.
Most games are very close to the main diagonal.  
It looks a bit irregular here in the strong corner,
but this is paired with an excellent algorithm, Blossoms, from 1965,
and I'm sure this is the best possible pairing.

No matter the game results, the matrix will always look like this.  
One chess friend of mine, christened this *Floating Berger*.  
Every player has his personal Berger group, kind of, with himself being in the middle.  

Our friend, 1985 Nordenfur can be found in line 22:  
  8 5 4 1 * 3 2 6 7
His eight games are an example of the best match possible.
Himself being in the middle, between four stronger players and four weaker players.

Not all of the players are as lucky as Mr Nordenfur,
If we skip the unnecessary round 8, the pairing becomes smoother.
The more rounds you have, the larger the gap.
Having 80 players, seven rounds is enough.

# ELO Probability

[G What does a difference of 500 elo mean?](https://docs.google.com/spreadsheets/d/1DHRnlp8Q6RnnG-gF-fg0liyS2zZINEF5typxI497JyE/edit?gid=1487995663#gid=1487995663)

Two players, having the same elo, that is a difference of zero, will win 50% of the time.
If the difference increases to fifty, 
the expected wins will increase to 57% for the better player 
and decrease to 43% for the weaker player.

As you can see here, if the difference is 500 elos, the better player will win 19 times out of 20.  
The weaker player will win one game in twenty.  

[H Probabiltiy Formula](https://docs.google.com/spreadsheets/d/1DHRnlp8Q6RnnG-gF-fg0liyS2zZINEF5typxI497JyE/edit?gid=60645458#gid=60645458)

If you would like to calcultate the probability of who is going to win,
you can use this formula.

Here we have the rating for player B, and player A,
and here we have the probabiltity of A winning.

If the players have the same rating, 1500, this term will be zero, 
and ten to zero is one, so the result will 0.5, that is 50%.

If the difference is high, like 1400 to 2800, the weaker player will only win one game of 3163 games.

The probability is only depending on the difference, not the absolute values, as you can see here. The have both a difference of 500 elos.

This formula is related to the Normal Distribution and the Standard Deviation is 400, with a mean of zero.

# A small demo

This is a simulation of a smaller chess tournament with 14 players and four rounds  
using the brand new ELO Pairings web page.  

You can see the URL here and all the data is here, in the URL.

[I 14 players demo](https://christernilsson.github.io/ELO-Pairings/?TOUR=Senior_Stockholm&DATE=2024-05-28&PLAYERS=(1825!JOHANSSON_Lennart)(1697!BJ%C3%96RKDAHL_G%C3%B6ran)(1684!SILINS_Peteris)(1681!STOLOV_Leonid)(1644!PETTERSSON_Lars-%C3%85ke)(1598!ISRAEL_Dan)(1598!AIKIO_Onni)(1583!PERSSON_Kjell)(1561!LILJESTR%C3%96M_Tor)(1559!LEHVONEN_Jouko)(1539!ANDERSSON_Lars_Owe)(1535!%C3%85BERG_Lars-Erik)(1532!ANTONSSON_G%C3%B6rgen)(1400!STR%C3%96MB%C3%84CK_Henrik))

You have prepared all these names and elos, maybe you did that yesterday and today is the tournament.
Maybe you would like to pause some of the people that got delayed in traffic.
Use toggle or space to alter their statuses.

# [J] Pair four rounds
I will start by pairing four rounds, filling in random results.  
So, I click on Pair and here we have the pairing.
We also have two files that are downloaded, more about them later.

14 players, that means seven tables.
The two strongest are playing at the first table,
and the two weakest at the last table.

Here is a button named Random and it will fill in random results for all the players, for this round.

When zero results are missing, we can pair the next round.

I repeat this for all rounds.

Now we can check the Standings.

  P RP RP RP RP
  
# [K] Standings
Here we have the standings after four rounds.

* The winner of this simulation is SILINS with almost 6000 elos
* This column, contains the sum of all game scores weighted with the elos of the opponents.
   * This is similar to calculating with the well known Sonneborn-Berger, using elos instead of total scores.
So, you add the opponents full elo if you win and if you draw, half of the opponents elo will be added to your sum.

Now, let's talk about the colors of the games.

* Green background indicates a win
* Red a loss
* And Gray a draw

* Colors of the pieces are the same as the color of the numbers.
* In the first round, SILINS met STOLOV and won with black pieces.
* In the second round, SILINS met JOHANSSON and won as white.
* In the third round SILINS met BJÖRKDAHL and drew with black
* In the fourth round, SILINS met ÅBERG and won as white

The ID:s you see here are the starting ID:s and they stay same during the tournament.

* Thew winner, SILINS, met all the four highest ranked players 4 1 2 5 except number 3 as this is SILINS himself.   
* Also note, ANDERSSON ended up as number four, even being as low rated as 1539.
* ANDERSSON, having elo 1539, met players with ratings 1532, 1535, 1561 and 1598.
* Two players were stronger and two weaker.

# [K2] Weighted Elo Calculation

I will now show You how to calculate the ELO sum for the winner.
In the first round Mr SILINS met player 4, that is Mr STOLOV.
STOLOV has an ELO of 1681, and this is added here.

In the second round SILINS met number 1, JOHANSSON who has en elo of 1825.
This is added here.

In the third round, SILINS made a draw with number 2, BJÖRKDAHL, with ELO 1697.
You can find that here and it is multiplied with 0.5 as it was a draw.

In the fourth round, SILINS met number 5, PETTERSSON with an ELO of 1644, which is added here.

If all of this is summed up, the result will be 5998.5
As you can see it is the same value as over here.

# [L] Navigation

[make the window smaller]

* You can navigate using the keys and the mouse
* You can also use the keys Up Down PageUp PageDown Home and End
* Finally, You can also scroll with the mouse wheel and click with the mouse

# [M] Pages
* Top left you see four pages:
   * Standings
   * Tables
   * Names
   * Active

Zooming is handled using the I key for In and O key for Out

# [N] Entering Results

Normally you print score sheets, that the players fill in after the game is played.
When a score sheet is finished it is handed over to the Pairer, the person doing the pairings. The printed score sheet is not necessary, but a very good backup, in case anything goes wrong.

* This is done in the Tables page.
* Jump to the top with Home and start entering the collected results using
   * 1 for white Win
   * space for Draw
   * 0 for white Loss
* You may enter the results one or more time to double check.
* Delete erroneous results with the Delete key.

# [O] Pairing
* After entering all the results, you may pair the next round using the Pair button.
* Here we see the files downloaded.
   * Click Ctrl+J to see the downloaded files. 
* The first file contains STANDINGS, NAMES and TABLES.
* This is the file you normally print, if you would like to print.
* You don't have to print, but if you want to print, this is the file to print.
   * First you will see the STANDINGS
   * Next the alphabetically sorted NAMES listing.
      * In a large tournament, make sure these are evenly distributed in your playing room after each pairing. This will help the players finding their seats.
   * And finally the TABLES to be filled in by the players.
   * This content is roughly the same as on the screen.

* The second file contains the URL. This is your backup and quite handy if anything goes wrong.
   * Select all lines with Ctrl+A.
   * Copy them with Ctrl+C
   * Finally paste everything in the URL field of your browser.
* The rest of the files were written in the earlier rounds.

# [P] How do I continue?
Ok, Let's say you are convinced ELO Pairings is the best thing since sliced bread
and you want you try this in your own chess club.

What do You do?

A good starting point is to edit this [URL](https://github.com/ChristerNilsson/ELO-Pairings/blob/main/tournaments/14.txt) and then copy and paste it in your favourite editor.

Let's make some changes.  
I delete two players,  
change JOHANSSON_Lennart to NILSSON_Christer and elo 1234  
don't forget to change spaces to underscores.  
I will also update the Date.

Save and make a copy like before that is pasted in the URL field of your browser.
Press Enter and now you should know how to continue.

Good Luck!





# FairPair 2

FairPair 2 är en total omskrivning av FairPair 1

* Enbart två sidor används: Ställning och Bordslista
* Performance Rating med extrapolation (Magnus Karlsson) för 0% och 100% används
* Uppskjutna partier: väntevärde beräknas mha elodiff. T ex 100 => 0.64
* Ren HTML och Javascript

## Fördelar med FairPair

[Try it!](https://christernilsson.github.io/FairPair2)

* FairPair parar ihop spelare med samma spelstyrka
* Performance Rating avgör vem som vann

## Nackdelar med Swiss

* En vinst mot den starkaste är värt exakt lika mycket som en vinst mot den svagaste
* Stora elogap ger mycket lite ny information

## Motivation

[Swiss Matrix](swiss-78.txt)  
[ELO Matrix](elo-78.txt)  

Swiss Matrix visar partier som verkligen spelades i en Swiss-turnering  
ELO Matrix visar vilka partier som skulle spelats i en FairPair-turnering.  
Diagonalen visar partier som inte spelas pga att man inte möter sig själv.  
Axlarna innehåller spelarnas elo.  
Talen i matrisen anger rondnummer.  
Swiss är ganska utspridd, vilket indikerar stora elogap.  

## Swiss vs FairPair

* Övre högra hörnet
* Upper left corner: the strongest players
* Lower right corner: the weakest players
* Upper right and lower left corner: Big gaps where strong meets weak

[Bubble Chart](https://christernilsson.github.io/2024/027-BubbleChart)  

[Manual](markdown/manual.md)  

## Turneringar

[14 spelare](tournaments/14.txt)  

[78 spelare](tournaments/78.txt)  

## Instruktioner för lottare
* Redigera en av filerna ovan.
* Lägg till elo och namn för spelarna, lämpligen i alfabetisk ordning. T ex 1650!NILSSON Christer
* Fält
	* **TITLE** Turneringens namn. Frivillig
	* **DATE** Startdatum
	* **ROUND** 0 initialt
	* **ROUNDS** Antal ronder totalt
	* **PAUSED** Pausade spelare. Spelarnummer separerade med utropstecken.
	* elos och namn separerade med utropstecken

[Kalkylering](markdown/calculation.md)

## Frågor och Svar

F1. Varför har man inte exakt 50% vita ronder?  
S1. Störst obalans kan inträffa vid jämnt antal ronder, t ex 3+5, för en del spelare. Problemet minskar om man använder udda antal ronder.

## Regler vid beräkning av PR.

Lite speciellt pga att partipoäng inte används.  
Eftersom grupperna har liten elo-variation, kan man i vissa lägen bedömas ha spelat mot sig själv, då PR beräknas.  

* [opp col res]
* [ -1  _   +] Får man en frirond räknas det som vinst mot sig själv.
* [ -1  _   -] Är man deaktiverad räknas det som förlust mot sig själv.
* [ 27  _   +] Ospelat parti mot avhoppare, räknas som vinst mot avhopparen.
* [ 27  b   ?] Uppskjutet parti: väntevärdet beräknas mha elodiff.

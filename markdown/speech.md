# ELO Pairings - ett alternativ till Swiss ?

## Historik

* Swiss skapades 1895 av Dr. Julius Müller (1857-1917) i Zürich.
* Monrad 1925
* Dutch (FIDE 1998)
* Burstein (1998?)

## Swiss

* Spelarna sorteras enligt ratingtalet
* Inga spelare får mötas två gånger
* Färgerna ska fördelas jämnt, max två eller tre i rad
* Spelare delas in i *grupper* efter antal poäng
* Spelarna inom en *grupp* kan paras på olika sätt
  * Monrad: *Närliggande* paras ihop först
  * Dutch: *Mittemellan*. Gruppen delas i två. De starkaste i delgrupperna paras ihop först
  * Burstein: *Avlägsna* paras ihop först
* Om paret i slutet inte kan mötas måste man [backtracka](https://en.wikipedia.org/wiki/Backtracking).

## Kritik av Swiss
* Ojämna spelstyrkor i de flesta partier, ffa i inledande ronder, även kallade *slaktronder*
* Komplex algoritm, se FIDE:s handbok
* [JaVaFo](http://www.rrweb.org/javafo/aum/JaVaFo2_AUM.htm) används av de flesta lottningsprogram, t ex [Swiss Manager](https://swiss-manager.at/)
* Källkoden till JavaFo ej publicerad
* Metoden i FIDE:s handbok verkar utgå från hur programmet fungerar, vilket känns bakvänt

## Elo-rating

* Skapades av fysikprofessorn Arpad Elo (1903-1992)
* Introducerades 1960 i USA
* Bygger på normalfördelningen
* Givet en ratingskillnad räknas en ratingförändring ut.
* Vidarutvecklingen Glicko används av chess.com och lichess.

## Teaser

Här visar jag hur en turnering med 78 deltagare, [Tyresö Open 2024](https://member.schack.se/ShowTournamentServlet?id=13664&listingtype=2), hanteras med Swiss samt ELO Pairings.  
Utgången av inledande ronder är ofta given och innebär en mindre stimulerande transportsträcka för båda spelarna.  
I denna turnering snabbades denna resa upp genom att de fyra första ronderna spelades med kortare betänktetid, 15m + 5s.  
Därefter följde fyra långpartier, 90m + 30s.  

För att bestämma hur väl en lottning motsvarar målet, utvecklades ett mätetal, benämnt Sparseness (gleshet).  
Detta beräknas genom att ta fram medelvärdet av alla partiers absoluta elo-differens.  
Sparseness för Swiss blev 220.4 och för ELO Pairings 44.85 (simulerat).  
Swiss är i detta fall, alltså fem gånger glesare än ELO Pairings.

[Swiss Dutch](swiss-78.txt)  
[ELO Pairings](elo-78.txt)  
[ELO Pairings vs Swiss](https://docs.google.com/spreadsheets/d/1DHRnlp8Q6RnnG-gF-fg0liyS2zZINEF5typxI497JyE/edit?usp=sharing)

ELO Pairings har utgångspunkten att alla ska möta spelare med liknande spelstyrka.  
Idealet är att varje spelare har en egen grupp đär spelaren själv ligger i mitten.  
Detta är dock omöjligt för spelarna i början och slutet av listan.  
Den som har högst rating kan bara spela med lägre ratade och tvärtom.  

### ELO Pairings

I varje rond paras spelare med närliggande rating ihop.  
Detta under förutsättning att de ej mötts förut och att färgerna är tillåtna.  
Partiresultat användes enbart för att avgöra ställningen efter varje rond och påverkar EJ lottningen.  
Detta innebär att när turneringen är färdigspelad kan det finnas flera spelare som har maximal poäng.    

Detta hanteras genom att istället för partipoäng ackumuleras elo-poäng för varje vinst eller remi.

* En vinst ger vinnaren hela förlorarens elo-rating.
* En remi ger båda spelarna halva motståndarens elo-rating.

Metodiken påminner om [Sonneborn-Berger](https://en.wikipedia.org/wiki/Sonneborn%E2%80%93Berger_score).  
I Swiss är en vinst mot den starkaste värd exakt lika mycket som en vinst mot den svagaste, vilket ELO Pairings alltså ändrar på.

## Några exempel på beräkningar

Nedanstående elos används enbart för att räkna ut ställningen, inte för att lotta.  

```
1600 Anna    - 1650 Britta   1-0
1700 Cecilia - 1770 Greta    0-1
1800 Sven    - 1900 Ture     ½-½

Anna får 1650 elos
Greta får 1700 elos
Sven får 950 elos (remi)
Ture får 900 elos (remi)
```

## Maximum Weight Matching
* Länkar skapas mellan alla spelare som *kan* paras (78 * 77 / 2 = 3003 stycken)
* Varje länk har en kostnad, i vårt fall den absoluta elo-skillnaden
* Algoritmen levererar en lista med de länkar som ger lägsta totala kostnad

## ELO Pairings vs Bergergrupper
* Berger ger större gleshet, pga fler hörn
* Berger ger fler frironder, eftersom spelare ej flyttas mellan grupperna
* Berger ger flera vinnare, som ej är jämförbara
* Berger ger samma poäng för ett vinstparti oavsett spelstyrka.

## Förskjutning av Elo-talet
* FACTOR == 0 innebär att scoringProbability används
* FACTOR > 0:
* Deltagarnas elo-tal anpassas till intervallet [a,b] så att b = FACTOR * a
* T ex kan Tyresö Opens ELO-spread [1406,2416], justeras till [1010,2020] genom att sätta OFFSET = -396
* Detta innebär att en vinst i lägsta grupp motsvarar en remi i högsta grupp
  * Är det rimligt att en person med 100% mot låga elo, placeras före en person med 50% mot höga elo?
* Man kan laborera med faktorn 2 ovan för att öka eller minska chansen för lägre ratade att vinna turneringen
  * Faktorn 3 t ex ger intervallet [505,1515]. Uppnås med OFFSET = -901. Mycket svårare för lågrankade nu
  * Det kan finnas en optimal faktor, troligen krävs det ett antal turneringar för att hitta en *sweet spot*
* Kan eventuellt vara intressant att ta medianen/medelvärdet av de 10% lägsta/högsta deltagarna

## Beräkning av OFFSET givet XMIN, XMAX samt FACTOR 
* DIFF = XMAX - XMIN


## Citat

*Personligen - som patzer - tycker jag det vore skönt att slippa sitta fast i Schweizerhissen i öppna turneringar* - Ingemar Falk  
*ELO Pairings is a system for both patzers and masters* - Christer Nilsson  
*Inom boxning skulle man aldrig tillåta en tungviktare att krossa en flugviktare. Inom schack anses det vara en förmån.* - Christer Nilsson  

[Thoughts on replacing Swiss system tournaments](https://www.chess.com/forum/view/general/thoughts-on-replacing-swiss-system-tournaments-with-mcmahon)

## Referenser

* [Swiss Tournament](https://en.wikipedia.org/wiki/Swiss-system_tournament)
* [Elo Rating](https://en.wikipedia.org/wiki/Elo_rating_system)
* [Maximum Weight Matching: Jack Edmonds 1965](https://en.wikipedia.org/wiki/Blossom_algorithm)
* [FIDE Handbook](https://handbook.fide.com)
* [Glicko Rating System](https://en.wikipedia.org/wiki/Glicko_rating_system)
* [Improving Ranking Quality and Fairness in Swiss-System Chess Tournaments](https://arxiv.org/html/2112.10522v2)
* [Designing Chess Pairing Mechanisms](https://real.mtak.hu/80729/7/jXaio4T11ygd57-77-86.pdf)

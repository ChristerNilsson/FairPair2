# Advanced

## Vad kan man göra med turneringsfilen?

* Lägg upp spelare tillsammans med deras rating
    * 1234!Persson
* Har du lottat en rond, får du inte ändra ordningen på dessa spelare, bara lägga till nya spelare i slutet
    * Varje spelare har tilldelats en id.
* Nedanstående ändringar påverkar framtida lottningar och/eller slutställning
* Du kan ändra på opponent. Borde aldrig behövas.
    * Om två spelare bytt plats är fyra spelare inblandade. 
    * Observera att spelarnas id är noll-baserat internt och ett-baserat externt.
* Du kan ändra på färg
    * Se till att ändra på **båda** spelarna
        * b-w
        * w-b
* Du kan ändra på resultat.
    * Se till att ändra på **båda** spelarna
        * 2-0 (vinst för vit)
        * 1-1 (remi)
        * 0-2 (vinst för svart)
* Du kan även ändra på 
    * TITLE
    * DATE
    * FACTOR (används bara för att visa ställning)
    * K Hastighet
    * TPP Antal bord per sida (utskrift)    
    * PPP Antal spelare per sida (utskrift)
* Dessa ändringar görs på den senaste textfilen, t ex DEMO-R1.txt och därefter måste den filen läsas in.
* Textfilerna skrivs **aldrig** över. Därför går det bra att prova sig fram.

## Färgrättvisa vs eloskillnad

Det finns en motsättning mellan färgrättvisa och minimal eloskillnad.  
Man kan minska eloskillnaden om man tillåter skevare färgfördelning, t ex 3 vs 5.  
Med udda antal ronder blir denna risk mindre.  
Just nu är färgväxling hårt reglerad. abs balans() måste vara <= 1  

Exempel:
```
FACTOR=2
ROUND=10
TITLE=Tyresö Open 2024
DATE=2024-05-03
K=20
TPP=30
PPP=60
PAUSED=12!18
2416!Hampus Sörensen!19w1!17b1!18w1!16b1!15w1!14b1!13w1!12b1!3w1!32b1
```

# Obligatoriska fält

* Spelarnas elo och namn, separerade med !

# Fält som skapas automatiskt (default)

* ROUND - aktuell rond (0)
* PAUSED - inaktiva spelare

# Fält som kan läggas till
* DATE
* FACTOR - 0=elo change >=1.2 translation of elo origin. Default: 2
* K - hastighet. 10, 20 eller 40 är det normala
* TPP - Tables Per Page (30)
* PPP - Players Per Page (60)

# Backup skapas vid varje lottning

Den hamnar på Downloads

# Använd bordsformulär för backup

Bra att ha om resultaten måste matas in igen.

# Teckenhantering

* Utropstecken (!) används som särskiljare och är därmed reserverad

# FairPair 

## Öva med demo-turneringen

|Tangent|Betydelse|
|:-:|-|
|**Enter**|Lotta nästa rond|
|**1**|Vinst|
|**Space**|Remi|
|**0**|Förlust|
|+|Ospelad vinst|
|-|Ospelad förlust|
|?|Uppskjutet parti|
|Delete|Ta bort ett resultat|
|Pause|aktivera/deaktivera EN spelare|
|*|aktivera/deaktivera ALLA spelare|
|a-ö|Sök efter första bokstaven i namnet, framåt|
|A-Ö|Sök efter första bokstaven i namnet, bakåt|
|ctrl +|Zooma in|
|ctrl -|Zooma ut|
|ctrl p|Skriv ut|
|Vänsterpil|Växla mellan Bord och Ställning|
|Högerpil|Växla mellan Bord och Ställning|

## Bordslistan

|kolumn|betydelse|
|:-:|-|
|b|Bordsnummer|
|vit|vits namn|
|elo|elo för vit|
|result|partiets resultat|
|elo|elo för svart|
|svart|svarts namn|
|diff|vit elo minus svart elo|

## Ställningslistan

|kolumn|betydelse|
|:-:|-|
|id|spelarens nummer|
|namn|spelarens namn|
|elo|spelarens elo|
|pr|total Performance Rating|
|pp|total PartiPoäng|
|bf|Bord och Färg i nästa rond|
|*|*=närvarande|
|avg|motståndarnas elos medelvärde|

## Skapa en egen turnering

* Har du lottat demo-turneringen, bör det finnas en fil med ungefärligt namn **Demo-R0-2025-01-31 12h34.txt** i "Nerladdningar" som du kan utgå ifrån
* Flytta denna textfil till din egen katalog och byt namn på den.
* Redigera textfilen med t ex Notepad och lägg in spelarna med elo-tal och namn.
* Läs därefter in din egen turnering med **Välj fil**

## Backup

* Varje gång du lottar skapas en fil i "Nerladdningar"
	* Denna kan du läsa in om du vill gå tillbaka en eller flera ronder

## Tips

* Skriv ut bordslistan efter varje lottning
	* Det går snabbt att knappa in resultaten igen vid strömavbrott
	* Det går även bra utan utskrifter.

## Parametrar

|Parameter|Betydelse|
|:-:|-|
|TITLE|Turneringens namn|
|DATE|Turneringens startdatum|
|ROUND|0 initialt|
|ROUNDS|antal ronder totalt|
|PAUSED|id för pausade spelare separerade med utropstecken|

## Spelare

2340!Klas Andersson  
2345!Bengt Svensson  
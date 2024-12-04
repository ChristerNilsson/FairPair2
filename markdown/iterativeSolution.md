## Uppsnabbning vid stora turneringar.

Eftersom blossoms är kvadratisk kan exekveringstiderna växa ganska snabbt.  

Min metod för att hantera detta:
1. Skapa alla tänkbara länkar från a till b. n=1000 => cirka 500K länkar. [a,b,cost]
2. sortera dessa på cost stigande
3. antal = 0
4. antal = antal + 1000
5. plocka ut de första antal länkarna
6. anropa solve.
7. Gå till punkt 4 om solve misslyckades

Kostnaden kvadreras (eller ** 1.01) för att undvika extrema kostnader.

På detta sätt kan man hitta lösningen genom att använda cirka 6K av länkarna.  
För n=1000 sker detta på en halv sekund.  

Detta innebär att länkarna närmast diagonalen undersöks först. De med lägst kostnad.  

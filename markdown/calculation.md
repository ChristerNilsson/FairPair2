## Elo calculation

Elo is calculated using this formula:  

![formula](/images/image.png)

PA = probability of win for player A  
RA = rating for player A  
RB = rating for player B  
	
## Logistics

![](/images/logistics.webp)

* The x-axis = RA - RB
* The y-axis = PA

## ELO Calculation

[Calculator](https://christernilsson.github.io/2023-008-Kalkyl/?content=K%20%3D%2020%20%23%20development%20coefficent%0A%0ASD%20%3D%20400%20%23%20Standard%20Deviation%0A%0Adiff%20%3D%201800%20-%201800%20%23%20RA%20-%20RB%0A%0A%5BLOSS,%20DRAW,%20WIN%5D%20%3D%20%5B0,%200.5,%201%5D%0A%0APA%20%3D%20(diff)%20-%3E%201%20/%20(1%20+%2010%20**%20(-diff%20/%20SD))%0A%0Af%20%3D%20(diff,score)%20-%3E%20K%20*%20(score%20-%20PA%20diff)%0A%0Af%20diff,LOSS%0Af%20diff,DRAW%0Af%20diff,WIN%0A%0A%23-----%20asserts%20-----%0A0.5%20%3D%3D%20PA%200%20%0A0.6400649998028851%20%3D%3D%20PA%20100%0A-12.801299996057702%20%3D%3D%20f%20100,%20LOSS%0A-7.198700003942299%20%3D%3D%20f%20-100,%20LOSS%0A&config=%7B%22angleMode%22:0,%22language%22:0,%22displayMode%22:0,%22digits%22:3%7D)


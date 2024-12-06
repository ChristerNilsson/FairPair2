# ½ •

PPR = 2 # Partier Per Rond och spelare

table = (s,attrs="") -> "<table #{attrs}>\n#{s}</table>"
tr    = (s,attrs="") -> "<tr #{attrs}>#{s}</tr>\n"
td    = (s,attrs="") -> "<td #{attrs}>#{s}</td>"
th    = (s,attrs="") -> "<th #{attrs}>#{s}</th>"
input = (s,attrs="") -> "<input #{attrs}>#{s}</input>"
b     = (s,attrs="") -> "<b>#{s}</b>"

seed = 0
random = -> (((Math.sin(seed++)/2+0.5)*10000)%100)/100

players = []

class Player
	constructor : (@elo,@name,@opp,@col,@res) ->
		# @opp är en array med heltal
		# @col är en sträng med w eller b.
		# @res håller ihop partierna i en sträng per rond och spelare
		# Detta för att hantera dubbelrond
		# Enkelrond:  ["2","0"]   => 1.0 pp
		# Dubbelrond: ["22","01"] => 2.5 pp
	score : ->
		summa = 0
		for res in @res
			for ch in res
				summa += parseInt ch
		(summa/2).toFixed 1

	prettyRes : (r) -> ("0½1"[ch] for ch in @res[r]).join "" # "12" => "½1"

	result: (r) ->
		if @res[r]
			"#{@opp[r]+1}#{"bw"[@col[r]]} #{@prettyRes r}"
		else
			"#{@opp[r]+1}#{b "bw"[@col[r]]} "

matrix = (i) ->
	res = Array(players.length).fill('•') 
	res[i] = '*'
	if i==0 then res[0]='H'
	if i==players.length-1 then res[i]='L'
	pi = players[i]
	for r in range pi.opp.length
		res[pi.opp[r]]=(r+1) % 10
	res.join " "

add = (elo,name) -> 
	opp = []
	col = []
	res = []
	players.push new Player elo,name,opp,col,res

range = _.range
echo = console.log

show = (players) ->
	R = players[0].opp.length
	t = ""

	right = 'style="text-align:right"'
	center = 'style="text-align:center"'
	for i in range players.length
		p = players[i]
		s = ""
		s += td i+1,center
		s += td p.id+1,center
		for r in range R
			game = p.result r
			if r == R-1
				if PPR == 2 then s += td game + input("",'type="text" maxlength="2" style="width:16px" oninput="moveToNext(this)"'),right
				if PPR == 1 then s += td game + input("",'type="text" maxlength="1" style="width:8px" oninput="moveToNext(this)"'),right
			else
				s += td game,right
			
		s += td p.score(),right
		s += td p.elo
		s += td p.name
		s += td b(p.table),center
		s += td matrix i
		t += tr s

	h = ""
	h += th "pos"
	h += th "#"
	for i in range R
		h += th i+1
	h += th "pp"
	h += th "elo"
	h += th "namn"
	h += th "bord"
	h += th "1 2 3 4 5 6 7 8 9 0 1 2 3 4" # matris

	t = tr(h) + t
	t = table t,'style="border:1px solid black"'
	echo t
	t

para = (pairs,flag) ->
	bord = 0
	for i in range pairs.length
		a = pairs[i]
		if i < a
			bord += 1
			players[i].opp.push a
			players[a].opp.push i
			players[i].table = bord
			players[a].table = bord
			
			if random() < 0.5
				players[i].col.push 0
				players[a].col.push 1
			else
				players[i].col.push 1
				players[a].col.push 0

			if flag
				si = ""
				sa = ""
				for ppr in range PPR
					z = random()
					if z < 0.4
						si += "2"
						sa += "0"
					else if z > 0.6
						si += "0"
						sa += "2"
					else 
						si += "1"
						sa += "1"
				players[i].res.push si
				players[a].res.push sa
			
add 1598,"AIKIO Onni"
add 1539,"ANDERSSON Lars Owe"
add 1532,"ANTONSSON Görgen"
add 1697,"BJÖRKDAHL Göran"
add 1598,"ISRAEL Dan"
add 1825,"JOHANSSON Lennart"
add 1559,"LEHVONEN Jouko"
add 1561,"LILJESTRÖM Tor"
add 1583,"PERSSON Kjell"
add 1644,"PETTERSSON Lars-Åke"
add 1684,"SILINS Peteris"
add 1681,"STOLOV Leonid"
add 1400,"STRÖMBÄCK Henrik"
add 1535,"ÅBERG Lars-Erik"

players.sort (a,b)-> b.elo - a.elo

for i in range players.length
	player = players[i]
	player.id = i # zero based internally

echo players 

#      0  1  2  3  4  5  6  7  8  9  0  1  2  3
para [ 1, 0, 3, 2, 5, 4, 7, 6, 9, 8,11,10,13,12],true
para [13,12,11,10, 7, 8, 9, 4, 5, 6, 3, 2, 1, 0],true
para [ 2, 3, 0, 1, 6, 7, 4, 5,10,13, 8,12,11, 9],false

app = document.getElementById 'app'
app.innerHTML = show players

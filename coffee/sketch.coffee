# ½ •

import { Edmonds } from './blossom.js' 

PPR = 1 # Partier Per Rond och spelare

BYE = -1
PAUSE = -2

span  = (s,attrs="") -> "<span #{attrs}>#{s}</span>"
table = (s,attrs="") -> "<table #{attrs}>\n#{s}</table>"
tr    = (s,attrs="") -> "<tr #{attrs}>#{s}</tr>\n"
td    = (s,attrs="") -> "<td #{attrs}>#{s}</td>"
th    = (s,attrs="") -> "<th #{attrs}>#{s}</th>"
input = (s,attrs="") -> "<input #{attrs}>#{s}</input>"
bold  = (s)          -> "<b>#{s}</b>"

boldify = (s) -> if 'b' in s then bold s else s

seed = 0
random = -> (((Math.sin(seed++)/2+0.5)*10000)%100)/100

sum = (s) ->
	res = 0
	for item in s
		res += parseFloat item
	res

sumNumbers = (arr) ->
	res = 0
	for item in arr
		res += item
	res

playersByELO = []

class Player
	constructor : (@elo,@name,@opp,@col,@res) ->
		@active = true
		# @opp är en lista med heltal
		# @col är en lista med -1 och 1
		# @res håller ihop partierna i en sträng per rond och spelare
		# Detta för att hantera dubbelrond
		# Enkelrond:  ["2","0"]   => 1.0 pp
		# Dubbelrond: ["22","01"] => 2.5 pp

	balans : -> sum @col

	score : ->
		summa = 0
		for res in @res
			for ch in res
				summa += parseInt ch
		summa/2

	expected_score : (ratings, own_rating) ->
		sumNumbers(1 / (1 + 10**((rating - own_rating) / 400)) for rating in ratings)

	performance_rating : (ratings, score) ->
		lo = 0
		hi = 4000
		while hi - lo > 0.001
			rating = (lo + hi) / 2
			if score > @expected_score ratings, rating
				lo = rating
			else
				hi = rating
		rating

	performance : ->
		total = @score()
		ratings = []
		for r in range @res.length
			# if @opp[r] == BYE then continue
			# if @opp[r] == PAUSE then continue
			ratings.push playersByELO[@opp[r]].elo
		@performance_rating ratings,total

	enhanced_performance : ->
		total = @score() + 0.5 # fiktiv remi
		ratings = [tournament.average]
		for r in range @res.length
			# if @opp[r] == BYE then continue
			# if @opp[r] == PAUSE then continue
			ratings.push playersByELO[@opp[r]].elo
		@performance_rating ratings,total

	prettyRes : (r) -> ("0½1"[ch] for ch in @res[r]).join "" # "12" => "½1"
	prettyCol : (r) -> if @col[r]==1 then "black" else "white"  # "12" => "½1"

	result: (r) ->
		s = span @opp[r]+1, "class='#{@prettyCol r}'" 
		t = if @res[r] then span @prettyRes(r), "class='center'" else ""
		td s + t

matrix = (i) ->
	res = Array(playersByELO.length).fill('•') 
	res[i] = '*'
	if i == 0 then res[0]='H'
	if i == playersByELO.length-1 then res[i]='L'
	pi = playersByELO[i]
	for r in range pi.opp.length
		res[pi.opp[r]] = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"[r] # (r+1) % 10
	res.join " "

add = (elo,name) -> 
	opp = []
	col = []
	res = []
	playersByELO.push new Player elo,name,opp,col,res

range = _.range
echo = console.log

class Tournament
	constructor : (players) ->
		@playersByScore = _.clone players
		echo 'playersByScore', @playersByScore
		@average = @calc_average()
		echo 'average',@average

	ok : (a,b) -> a.id != b.id and a.id not in b.opp and Math.abs(a.balans() + b.balans()) <= 2

	calc_average : ->
		res = 0
		for p in @playersByScore
			res += p.elo
		res / @playersByScore.length

	makeEdges : (iBye) -> # iBye är ett id eller -1
		arr = []
		for pa in @playersByScore
			a = pa.id
			if not pa.active or a == iBye then continue
			for pb in @playersByScore
				b = pb.id
				if a == b then continue
				if not pb.active or b == iBye then continue
				diff = Math.abs pa.elo - pb.elo
				cost = 9999 - diff ** 1.01
				if a < b then continue
				if @ok pa,pb then arr.push [a,b, cost]
		arr.sort (a,b) -> b[2] - a[2] # cost
		# echo arr
		arr

	findSolution : (edges) -> 
		edmonds = new Edmonds edges
		edmonds.maxWeightMatching edges

	# sort : -> @playersByScore.sort (a,b)-> b.score() - a.score()
	# sort : -> @playersByScore.sort (a,b)-> b.performance() - a.performance()
	sort : -> @playersByScore.sort (a,b)-> b.enhanced_performance() - a.enhanced_performance()

	show : ->
		R = @playersByScore[0].opp.length
		t = ""

		left   = 'style="text-align:left"'
		right  = 'style="text-align:right"'
		center = 'style="text-align:center"'
		for i in range @playersByScore.length
			p = @playersByScore[i]
			s = ""
			s += td i+1,center
			for r in range R
				s += p.result r
				
			# s += td p.score(),right
			# s += td p.performance().toFixed(1),right
			s += td p.enhanced_performance().toFixed(1),right
			# s += td p.performance().toFixed(1),right

			s += td p.elo
			s += td p.id+1,center
			s += td p.name,left

			s += td p.table + p.prettyCol(R-1)[0],center

			# s += td matrix i
			t += tr s

		h = ""
		h += th "pos"
		for i in range R
			h += th i+1
		h += th "EPR"
		# h += th "PR"
		h += th "elo"
		h += th "#"
		h += th "namn"
		h += th "bd"
		# h += th "1 2 3 4 5 6 7 8 9 0 1 2 3 4" # matris

		t = tr(h) + t
		table t,'style="border:1px solid black"'

	handleCol : (pi,pa) ->
		if pi.col.length == 0
			pi.col.push -1
			pa.col.push 1
		else
			if pi.balans() > pa.balans()
				pi.col.push -1
				pa.col.push 1
			else if pi.balans() < pa.balans()
				pi.col.push 1
				pa.col.push -1
			else # samma balans
				foundDiff = false
				for j in range pi.col.length-1,-1,-1
					if pi.col[j] != pa.col[j]
						foundDiff = true
						pi.col.push -pi.col[j]
						pa.col.push -pa.col[j]
						break
				if not foundDiff
					pi.col.push -1
					pa.col.push 1

	handleRes : (pi,pa) ->
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
		pi.res.push si
		pa.res.push sa

	makeOppColRes : (pairs,flag) ->
		bord = 0
		for pair in pairs
			a = pair[0]
			b = pair[1]

			pa = @playersByScore[a]
			pb = @playersByScore[b]

			bord += 1
			pa.table = bord
			pb.table = bord

			pa.opp.push b
			pb.opp.push a

			@handleCol pa,pb
			if flag then @handleRes pa,pb
			
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

playersByELO.sort (a,b)-> b.elo - a.elo

for i in range playersByELO.length
	player = playersByELO[i]
	player.id = i # zero based internally

echo playersByELO

tournament = new Tournament playersByELO

makePairs = (solution) ->
	res = []
	for j in range solution.length
		if j < solution[j] then res.push [j,solution[j]]
	res

antal = 13
for i in range antal
	solution = tournament.findSolution tournament.makeEdges -1
	echo solution
	arr = makePairs solution
	# sortera på summan av elo-talen för paren.
	arr.sort (a,b)-> 
		a0 = playersByELO[a[0]].elo
		a1 = playersByELO[a[1]].elo
		b0 = playersByELO[b[0]].elo
		b1 = playersByELO[b[1]].elo
		b0 + b1 - a0 - a1
	echo 'arr',arr
	echo (playersByELO[a].elo + playersByELO[b].elo for [a,b] in arr)

	tournament.makeOppColRes arr, i < antal-1

tournament.sort()

app = document.getElementById 'app'
app.innerHTML = tournament.show()

echo app.innerHTML

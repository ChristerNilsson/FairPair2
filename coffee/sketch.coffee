# ½ •

import { Edmonds } from './blossom.js' 

PPR = 1 # Partier Per Rond och spelare

BYE = -1
PAUSE = -2

table = (s,attrs="") -> "<table #{attrs}>\n#{s}</table>"
tr    = (s,attrs="") -> "<tr #{attrs}>#{s}</tr>\n"
td    = (s,attrs="") -> "<td #{attrs}>#{s}</td>"
th    = (s,attrs="") -> "<th #{attrs}>#{s}</th>"
input = (s,attrs="") -> "<input #{attrs}>#{s}</input>"
bold  = (s)          -> "<b>#{s}</b>"

seed = 0
random = -> (((Math.sin(seed++)/2+0.5)*10000)%100)/100

sum = (s) ->
	res = 0
	for item in s
		res += parseFloat item
	res
# assert 6, g.sum '012012'

sumNumbers = (arr) ->
	# print 'sumNumbers',arr
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
		# result = 0
		# for ch in @col
		# 	result += ch
		# 	# if ch==1 then result += 1
		# echo 'balans',@col,result
		# result

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
	prettyCol : (r) -> if @col[r]==1 then "b" else "w"  # "12" => "½1"

	result: (r) ->
		if @res[r]
			"#{@opp[r]+1}#{@prettyCol r}#{@prettyRes r}"
		else
			"#{@opp[r]+1}#{@prettyCol r}"

matrix = (i) ->
	res = Array(playersByELO.length).fill('•') 
	res[i] = '*'
	if i==0 then res[0]='H'
	if i==playersByELO.length-1 then res[i]='L'
	pi = playersByELO[i]
	for r in range pi.opp.length
		res[pi.opp[r]]=(r+1) % 10
	res.join ""

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

	ok : (a,b) -> a.id != b.id and a.id not in b.opp and Math.abs(a.balans() + b.balans()) <= 2 #2

	calc_average : ->
		res = 0
		for p in @playersByScore
			res += p.elo
		Math.round(res / @playersByScore.length)

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

		right = 'style="text-align:right"'
		center = 'style="text-align:center"'
		for i in range @playersByScore.length
			p = @playersByScore[i]
			s = ""
			s += td i+1,center
			s += td p.id+1,center
			for r in range R
				game = p.result r
				if r == R-1
					if PPR == 2 then s += td game + input("",'type="text" maxlength="2" style="width:16px" oninput="moveToNext(this)"'),right
					if PPR == 1 then s += td game + input("",'type="text" maxlength="1" style="width:8px" oninput="moveToNext(this)"'),right
				else
					txt = game.replace('w','•').replace('b','•')
					if 'b' in game
						s += td bold(txt),right
					else
						s += td txt,right
				
			# s += td p.score(),right
			s += td p.enhanced_performance().toFixed(1),right
			# s += td p.performance().toFixed(1),right

			s += td p.elo
			s += td p.name
			s += td p.table,center
			# s += td matrix i
			t += tr s

		h = ""
		h += th "pos"
		h += th "#"
		for i in range R
			h += th i+1
		h += th "EPR"
		h += th "elo"
		h += th "namn"
		h += th "bd"
		# h += th "12345678901234" # matris

		t = tr(h) + t
		table t,'style="border:1px solid black"'

	makeOppColRes : (pairs,flag) ->
		bord = 0
		for i in range pairs.length
			a = pairs[i]
			if i < a
				bord += 1
				pi = @playersByScore[i]
				pa = @playersByScore[a]
				pi.opp.push a
				pa.opp.push i
				pi.table = bord
				pa.table = bord

				if pi.col.length == 0
					pi.col.push -1
					pa.col.push 1
					echo 'empty',pi.col,pa.col
				else
					foundDiff = false
					for j in range pi.col.length-1,-1,-1
						if pi.col[j] != pa.col[j]
							foundDiff = true
							pi.col.push -pi.col[j]
							pa.col.push -pa.col[j]
							echo 'found diff',pi.col,pa.col
							break
					if not foundDiff
						pi.col.push -1
						pa.col.push 1
						echo 'hittade inget',pi.col,pa.col

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
					pi.res.push si
					pa.res.push sa
			
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

antal = 14
for i in range antal
	solution = tournament.findSolution tournament.makeEdges -1
	echo solution
	tournament.makeOppColRes solution,i < antal-1

tournament.sort()

app = document.getElementById 'app'
app.innerHTML = tournament.show()

# echo app.innerHTML

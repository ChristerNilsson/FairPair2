# ½ •

import { Edmonds } from './blossom.js' 

range = _.range
echo = console.log

PPR = 1 # enkelrond
#PPR = 2 # dubbelrond

BYE = -1
PAUSE = -2

current = 1 # anger id

span  = (s,attrs="") -> "<span #{attrs}>#{s}</span>"
table = (s,attrs="") -> "<table #{attrs}>\n#{s}</table>"
tr    = (s,attrs="") -> "<tr #{attrs}>#{s}</tr>\n"
td    = (s,attrs="") -> "<td #{attrs}>#{s}</td>"
th    = (s,attrs="") -> "<th #{attrs}>#{s}</th>"

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

moveFocus = (currentElement,next) ->
	focusable = document.querySelectorAll('[tabindex]')
	focusableArray = Array.from(focusable)
	# currentIndex = focusableArray.indexOf(currentElement)
	newIndex = next %% focusableArray.length
	focusableArray[newIndex].focus()

inverse = (s) -> 
	res = ""
	for ch in s
		res += "210"[parseInt ch]
	res
console.assert "22" == inverse "00"
console.assert "11" == inverse "11"
console.assert "00" == inverse "22"

check = (p,q) ->
	r = p.opp.length-1
	if p.res[r] == undefined then p.res[r] = "" 
	if q.res[r] == undefined then q.res[r] = "" 
	echo p.res[r].length, q.res[r].length, p.res[r], q.res[r], inverse p.res[r]

#	p.error = p.res[r].length == 2 and q.res[r].length == 2 and p.res[r] != inverse q.res[r]
	p.error = p.res[r] != inverse q.res[r]

	if p.error then echo "error",p.name,q.name

export handleKeyDown = (event) ->
	if PPR == 1 then handleKeyDown_1 event else handleKeyDown_2 event

handleKeyDown_1 = (event) -> # Enkelrond
	trans = {"0":"0", 'r':"1", "1": "2", " ": "1"}
	if event == undefined then return
	index = event.target.tabIndex - 1
	p = tournament.playersByScore[index]
	r = p.opp.length-1
	q = playersByELO[p.opp[r]]

	echo 'c o f f e e', event.key

	if event.key == 'Delete'
		p.res[r] = ""
		event.target.innerHTML = p.result r,index-1
		moveFocus event.target, index + 1
	if event.key == 'ArrowDown' then moveFocus event.target, index+1
	if event.key == 'ArrowUp'   then moveFocus event.target, index-1
	if event.key == 'Home'      then moveFocus event.target, 0
	if event.key == 'End'       then moveFocus event.target, playersByELO.length - 1

	if event.key in "0r 1"
		p.res[r] = trans[event.key]
		check p, q
		event.target.innerHTML = p.result r,index-1
		echo p.result r,index-1
		moveFocus event.target, index + 1

handleKeyDown_2 = (event) -> # Dubbelrond
	trans = {"0":"0", 'r':"1", "1": "2", " ": "1"}
	if event == undefined then return
	index = event.target.tabIndex - 1
	p = tournament.playersByScore[index]
	r = p.opp.length-1
	q = playersByELO[p.opp[r]]
	echo 'c o f f e e', event.key,p.name,q.name

	if event.key == 'Delete'
		p.res[r] = ""
		event.target.innerHTML = p.result r,index-1
		moveFocus event.target, index + 1
	if event.key == 'ArrowDown' then moveFocus event.target, index+1
	if event.key == 'ArrowUp'   then moveFocus event.target, index-1
	if event.key == 'Home'      then moveFocus event.target, 0
	if event.key == 'End'       then moveFocus event.target, playersByELO.length - 1

	if p.res[r] == undefined then p.res[r] = ""

	if event.key in "0r 1"
		if p.res[r].length == 1
			p.res[r] += trans[event.key]
			check p, q
			event.target.innerHTML = p.result r,index-1
			echo '1',p.result r,index-1
			moveFocus event.target, index + 1
		else # 0 or 2
			p.res[r] = trans[event.key]
			check p, q
			event.target.innerHTML = p.result r,index-1
			echo '02',p.result r,index-1

xs = (ratings, own_rating) -> sumNumbers(1 / (1 + 10**((rating - own_rating) / 400)) for rating in ratings)

pr = (rs, s, lo=0, hi=4000, r=(lo+hi)/2) -> if hi - lo < 0.001 then r else if s > xs rs, r then pr rs, s, r, hi else pr rs, s, lo, r
echo 'pr', pr [1900,2100], 1

class Player
	constructor : (@elo,@name,@opp,@col,@res) ->
		@active = true
		@error = false
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

	performance_rating : (ratings, score) ->
		lo = 0
		hi = 4000
		while hi - lo > 0.001
			rating = (lo + hi) / 2
			if score > xs ratings, rating
				lo = rating
			else
				hi = rating
		rating

	magnusKarlsson : (ratings, total) -> # linjär extrapolation när spelaren har 0% eller 100%
		d = if total == 0 then 0.5 else - 0.5 
		a = @performance_rating ratings,total + d
		b = @performance_rating ratings,total + 2 * d
		2 * a - b

	performance : ->
		total = @score() / PPR
		ratings = []
		for r in range @res.length
			# if @opp[r] == BYE then continue
			# if @opp[r] == PAUSE then continue
			ratings.push playersByELO[@opp[r]].elo
		prel = @performance_rating ratings,total
		if 1 < prel < 3999 then return prel
		@magnusKarlsson ratings,total

	prettyRes : (r) -> 
		if @res[r] is undefined then return ""
		("0½1"[ch] for ch in @res[r]).join "" # "12" => "½1"

	prettyCol : (r) -> if @col[r]==1 then "black" else "white"  # 1 => "black"
	prettyCol2: (r) -> if @col[r]==1 then "white" else "black"  # 1 => "white"

	result: (r,index) ->
		s = span @opp[r]+1, "class=" + @prettyCol r
		# if @res[r] and @res[r] != ""
		if r < @opp.length-1
			echo 'tidigare ronder'
			t = span @prettyRes(r), "class='center'"
			echo 'bertil',td s + t
			td s + t
		else # senaste ronden
			echo 'result sista ronden',@error
			t = span @prettyRes(r), "class='center'"
			if @error
				attrs = "class='current' style='background-color: red'   tabindex='#{index+1}'"
			else
				attrs = "class='current' style='background-color: green' tabindex='#{index+1}'"
			echo 'cesar', td s + t, attrs
			td s + t, attrs

matrix = (i) ->
	res = Array(playersByELO.length).fill('•') 
	res[i] = '*'
	if i == 0 then res[0]='H'
	if i == playersByELO.length-1 then res[i]='L'
	pi = playersByELO[i]
	for r in range pi.opp.length
		res[pi.opp[r]] = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"[r]
	res.join " "

add = (elo,name) -> 
	opp = []
	col = []
	res = []
	playersByELO.push new Player elo,name,opp,col,res

class Tournament
	constructor : (players) ->
		@playersByScore = _.clone players
		echo 'playersByScore', @playersByScore

	ok : (a,b) -> a.id != b.id and a.id not in b.opp and Math.abs(a.balans() + b.balans()) <= 2

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

	sort : -> @playersByScore.sort (a,b)-> b.performance() - a.performance()

	makeHTML : ->
		R = @playersByScore[0].opp.length
		t = ""

		ta_left   = "style='text-align:left'"
		ta_right  = "style='text-align:right'"
		ta_center = "style='text-align:center'"
		for i in range @playersByScore.length
			p = @playersByScore[i]
			if i==0 then current = p.id
			s = ""
			s += td i+1,ta_center
			for r in range R
				s += p.result r,i
				
			s += td p.performance().toFixed(1),ta_right
			s += td p.score().toFixed(1),ta_right

			s += td p.elo
			s += td p.id+1,ta_center
			s += td p.name,ta_left

			s += td p.table + p.prettyCol(R-1)[0] + p.prettyCol2(R-1)[0],ta_center

			# s += td matrix i
			t += tr s

		h = ""
		h += th "pos"
		for i in range R
			h += th i+1
		h += th "PR"
		h += th "pp"
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
		remi = 0.05
		for ppr in range PPR
			z = random()
			if z < 0.5 - remi
				si += "2" # 2
				sa += "0" # 0
			else if z > 0.5 + remi 
				si += "0" # 0 
				sa += "2" # 2
			else 
				si += "1" # 1
				sa += "1" # 1
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
	arr = makePairs solution
	# paret med högst elo sitter på bord 1
	arr.sort (a,b)-> 
		a0 = playersByELO[a[0]].elo
		a1 = playersByELO[a[1]].elo
		b0 = playersByELO[b[0]].elo
		b1 = playersByELO[b[1]].elo
		b0 + b1 - a0 - a1

	tournament.makeOppColRes arr, i < antal-1

tournament.sort()

app = document.getElementById 'app'

app.innerHTML = tournament.makeHTML()

for control in document.querySelectorAll '[tabindex]'
	control.onkeydown = handleKeyDown

echo app.innerHTML

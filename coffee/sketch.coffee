# ½ •

import { Edmonds } from './blossom.js' 

range = _.range
echo = console.log

current = 0 

BYE = -1
PAUSE = -2

KEYWORDS = {}
KEYWORDS.TITLE = 'text'
KEYWORDS.DATE = 'text'
KEYWORDS.ROUND = 'integer'
KEYWORDS.PAUSED = '!-separated integers'
KEYWORDS.TPP = 'integer (Tables Per Page, default: 30)'
KEYWORDS.PPP = 'integer (Players Per Page, default: 60)'

g = {}

# Dessa tre arrayer pekar alla på samma data. De är dock olika sorterade
playersByELO = []
playersByID = []
playersByScore = []

span  = (s,attrs="") -> "<span #{attrs}>#{s}</span>"
table = (s,attrs="") -> "<table #{attrs}>\n#{s}</table>"
tr    = (s,attrs="") -> "<tr #{attrs}>#{s}</tr>\n"
td    = (s,attrs="") -> "<td #{attrs}>#{s}</td>"
th    = (s,attrs="") -> "<th #{attrs}>#{s}</th>"

seed = 0
random = -> (((Math.sin(seed++)/2+0.5)*10000)%100)/100

app = document.getElementById 'app'
info = document.getElementById 'info'

export handleFile = (filename,data) ->
	echo 'handleFile',filename,data
	tournament.fetchData filename,data

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

moveFocus = (next) ->
	focusable = document.querySelectorAll('[tabindex]')
	focusableArray = Array.from(focusable)
	newIndex = next %% focusableArray.length
	current = newIndex
	focusableArray[newIndex].focus()
	info.innerHTML = tournament.info()

inverse = (s) -> 
	res = []
	for ch in s
		res.push "210"[parseInt ch]
	res
console.assert ["2","2"], inverse ["0","0"]
console.assert ["1","1"], inverse ["1","1"]
console.assert ["0","0"], inverse ["2","2"]

# Kontrollerar att de båda resultaten matchar. Dvs 0-2 1-1 eller 2-0
check = (p,q) ->
	echo 'check',p.res,q.res
	r = p.opp.length-1
	if p.res[r] == undefined then p.res[r] = "" 
	if q.res[r] == undefined then q.res[r] = "" 
	#echo p.res[r].length, q.res[r].length, p.res[r], q.res[r], inverse p.res[r]

#	p.error = p.res[r].length == 2 and q.res[r].length == 2 and p.res[r] != inverse q.res[r]
#	p.error = p.res[r] != inverse q.res[r]
	p.error = p.res[r] != inverse q.res[r]

	if p.error then echo "error",p.name,q.name

export handleKeyDown = (event) -> # Enkelrond
	trans = {"0":"0", ' ':"1", "1": "2"}
	if event == undefined then return
	index = event.target.tabIndex # - 1
	p = playersByScore[index]
	r = p.opp.length-1
	cell = event.target.children[3+r]
	# echo 'c o f f e e', event.key, cell #.target.tabIndex
	q = playersByELO[p.opp[r]]

	if event.key == 'Delete'
		p.res[r] = ""
		cell.innerHTML = p.result r,index-1
		moveFocus index + 1
	if event.key == 'ArrowDown' then moveFocus index+1
	if event.key == 'ArrowUp'   then moveFocus index-1
	if event.key == 'Home'      then moveFocus 0
	if event.key == 'End'       then moveFocus playersByELO.length - 1

	if event.key in "0 1"
		p.res[r] = trans[event.key]
		# check p, q
		cell.innerHTML = p.result r,index-1
		#echo p.result r,index-1
		moveFocus index + 1

	key = event.key.toUpperCase()
	if key == event.key then dir = -1 else dir = 1
	if key in "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ"
		index = event.target.tabIndex # - 1
		#echo index
		n = playersByScore.length
		for i in range n
			if dir==1 then ix=(index+i+1) % n else ix = (index-i-1) %% n
			p = playersByScore[ix]
			if p.name.startsWith key
				moveFocus ix
				break
	
xs = (ratings, own_rating) -> sumNumbers(1 / (1 + 10**((rating - own_rating) / 400)) for rating in ratings)

pr = (rs, s, lo=0, hi=4000, r=(lo+hi)/2) -> if hi - lo < 0.001 then r else if s > xs rs, r then pr rs, s, r, hi else pr rs, s, lo, r
# echo 'pr', pr [1900,2100], 1

class Player
	constructor : (@elo,@name,@opp=[],@col=[],@res=[]) ->
		@active = true
		@error = false
		# @opp är en lista med heltal
		# @col är en lista med -1 och 1
		# @res håller ihop partierna i en sträng per rond och spelare
		# ["2","0"]   => 1.0 pp

	balans : -> sum @col

	read : (player) ->
		@elo = parseInt player[0]
		@name = player[1]
		@opp = []
		@col = []
		@res = []
		if player.length < 3 then return
		ocrs = player.slice 2
		for ocr in ocrs
			if 'w' in ocr then col='w'
			if 'b' in ocr then col='b'
			# if '_' in ocr then col='_'
			arr = ocr.split col
			@opp.push parseInt arr[0]
			@col.push {w:1, b:-1}[col]
			if arr.length == 2 and arr[1].length == 1 then @res.push arr[1]

	write : -> # 1234!Christer!12w0!23b1!14w2   Elo:1234 Name:Christer opponent:23 color:b result:1
		res = []
		res.push @elo
		res.push @name
		r = @opp.length
		if r == 0 then return res.join SEPARATOR
		ocr = ("#{@opp[i]}#{@col[i]}#{if i < r then @res[i] else ''}" for i in range r)
		res.push ocr.join SEPARATOR
		res.join SEPARATOR

	score : ->
		summa = 0
		if @opp.length == 0 then return 0
		for i in range @opp.length - 1
			for ch in @res[i]
				summa += parseInt ch
		summa/2

	prettyScore : ->
		@score().toFixed(1).replace('.5','½').replace('.0','&nbsp;').replace("0½","½&nbsp;")

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

	# Använd två extremvärden då man har 0% eller 100%
	extrapolate : (a0, b0, elos) ->
		a = @performance_rating elos,a0
		b = @performance_rating elos,b0
		b + b - a

	performance : ->
		pp = @score()
		elos = []
		if @opp.length == 0 then return 0
		for r in range @opp.length - 1
			# if @opp[r] == BYE then continue
			# if @opp[r] == PAUSE then continue
			elos.push playersByELO[@opp[r]].elo

		n = elos.length
		if n == 1
			if pp == 0 then return @extrapolate 0.50,0.25,elos
			if pp == n then return @extrapolate 0.50,0.75,elos
		else
			if pp == 0 then return @extrapolate   1,  0.5,elos
			if pp == n then return @extrapolate n-1,n-0.5,elos

		@performance_rating elos,pp

	prettyRes : (r) -> 
		if @res[r] is undefined then return ""
		("0½1"[ch] for ch in @res[r]).join "" # "12" => "½1"

	prettyCol : (r) -> if @col[r]==1 then "ul" else "ur"  # 1 => "black"
	prettyCol2: (r) -> if @col[r]==1 then "lr" else "ll"  # 1 => "white"

	result: (r,index) ->
		s = span @opp[r]+1, "class=" + @prettyCol r
		t = span @prettyRes(r), "class=" + @prettyCol2 r
		td s + t

	info : ->
		return 'no info'
		res = []
		for i in range @opp.length-1
			res.push playersByELO[@opp[i]].elo.toString()
		res.push @score().toFixed 1
		res.push "=>"
		res.push @performance().toFixed 3
		res.join " "

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
	constructor : (filename, data) ->
		@fetchData filename, data
		playersByScore = _.clone playersByID
		echo 'playersByScore', playersByScore

	fetchData : (filename, data) ->
		# randomSeed 99
		@filename = filename.replaceAll ".txt",""

		data = data.split '\n'

		hash = {}

		# default values
		hash.PLAYERS = []
		hash.TITLE = ''
		hash.DATE = ''
		hash.ROUND = 0
		hash.TPP = 30
		hash.PPP = 60
		hash.PAUSED = ""

		for line,nr in data	
			line = line.trim()
			if line.length == 0 then continue
			arr = line.split '='
			if arr.length == 2
				if arr[0] not of KEYWORDS
					helpText = ("    #{key}: #{value}" for key,value of KEYWORDS).join '\n'
					keyword = "\"#{arr[0]}\""
					alert "#{keyword} in line #{nr+1} is not one of\n#{helpText}"
					return
				hash[arr[0]] = arr[1]
			else 
				if '!' not in line
					alert "#{line}\n in line #{nr+1}\n must look like\n    2882!CARLSEN Magnus or\n    1601!NILSSON Christer!2w0"
					return
				arr = line.split '!'
				if not /^\d{4}$/.test arr[0]
					alert "#{arr[0]}\n in line #{nr+1}\n must have four digits"
					return
				for i in range 2,arr.length
					item = arr[i]
					if not /^-?\d+(w|_|b)[0-2]$/.test item
						alert "#{item}\n in line #{nr+1}\n must follow the format <number> <color> <result>\n  where color is one of w,b or _\n  and result is one of 0, 1 or 2"
						return
				hash.PLAYERS.push arr
		@players = []
		@title = hash.TITLE
		@datum = hash.DATE
		@round = parseInt hash.ROUND
		@tpp = parseInt hash.TPP # Tables Per Page
		@ppp = parseInt hash.PPP # Players Per Page
		@paused = hash.PAUSED # list of zero based ids

		players = hash.PLAYERS
		g.N = players.length

		if not (4 <= g.N < 1000)
			alert "Number of players must be between 4 and 999!"
			return

		playersByID = []
		for i in range g.N
			player = new Player i
			player.read players[i]
			playersByID.push player

		if @paused == ""
			@paused = []
		else
			@paused = @paused.split '!'
			for id in @paused
				if id != "" then playersByID[id].active = false

		g.average = 0
		for i in range g.N
			playersByID[i].elo = parseInt playersByID[i].elo
			g.average += playersByID[i].elo
		g.average /= g.N
		# console.log 'average',g.average

		playersByID.sort (a,b) ->  
			if a.elo != b.elo then return b.elo - a.elo
			if a.name > b.name then 1 else -1

		for i in range g.N
			playersByID[i].id = i
		
		playersByELO = _.clone playersByID

		echo 'playersByELO', playersByELO
		echo 'playersByID', playersByID 

		# @playersByName = _.sortBy @playersByID, (player) -> player.name
		# echo 'playersByName', @playersByName

		# extract @pairs from the last round
		@pairs = []
		for p in playersByID
			a = p.id
			b = _.last p.opp
			if a < b 
				pa = playersByID[a]
				pb = playersByID[b]
				@pairs.push if 1 == _.last p.col # w
					pa.chair = 2 * @pairs.length
					pb.chair = 2 * @pairs.length + 1
					[a,b]
				else 
					pa.chair = 2 * @pairs.length + 1
					pb.chair = 2 * @pairs.length
					[b,a]

		echo '@pairs',@pairs

		# @dump 'fetch'
		
		@virgin = true

		# g.pages = [new Tables, new Standings]

		# g.pages[g.ACTIVE].setLista()
		# g.pages[g.NAMES].setLista()
		# g.pages[g.TABLES].setLista()
		# g.pages[g.STANDINGS].setLista()

		# g.state = g.TABLES


	ok : (a,b) -> a.id != b.id and a.id not in b.opp and Math.abs(a.balans() + b.balans()) <= 2

	makeEdges : (iBye) -> # iBye är ett id eller -1
		arr = []
		for pa in playersByScore
			a = pa.id
			if not pa.active or a == iBye then continue
			for pb in playersByScore
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

	sort : -> playersByScore.sort (a,b)-> b.performance() - a.performance()

	info : -> 
		playersByScore[current].info()

	headers : (R) ->
		h = ""
		#h += th "pos",'style="border:none"'
		h += th "id",'style="border:none"'
		h += th "namn",'style="border:none"'
		h += th "elo",'style="border:none"'
		for i in range R
			h += th i+1,'style="border:none"'
		h += th "pr",'style="border:none"'
		h += th "pp",'style="border:none"'
		h += th "",'style="border:none"'
		h += th "bf",'style="border:none"'
		h += th "diff",'style="border:none"'
		h += th "id:bf",'style="border:none"'
		h

	makeHTML : ->
		R = playersByScore[0].opp.length
		echo 'makeHTML',R
		t = ""

		ta_left   = "style='text-align:left'"
		ta_right  = "style='text-align:right'"
		ta_center = "style='text-align:center'"
		ta_center_strong = "style='text-align:center; font-weight: bold;'"
		for i in range playersByScore.length
			p = playersByScore[i]
			#if i==0 then current = p.id
			s = ""

			#s += td i+1,ta_right # pos
			s += td p.id+1,ta_right # id
			s += td p.name,ta_left # namn
			s += td p.elo # elo

			for r in range R
				s += p.result r,i # ronder
				
			# pr
			pr = p.performance()
			s += td pr.toFixed(1) #,ta_right

			s += td p.prettyScore(),ta_right # pp

			s += td "",'style="width:5px;border-top:none; border-bottom:none"' # empty

			# s += td p.table + p.prettyCol(R-1)[0] + p.prettyCol2(R-1)[0],ta_center
			# bf
			if p.table
				bf = p.table + {l:'B',r:'W'}[p.prettyCol(R-1)[1]]
			else
				bf = ""
			s += td bf, ta_center_strong

			# diff
			if R >= 1 then s += td playersByELO[p.opp[R-1]].elo - p.elo, ta_right else s += td ""


			# id:bd
			q = playersByELO[i]
			if R >= 1 then s += td "#{i+1}:#{q.table + {l:'B',r:'W'}[q.prettyCol(R-1)[1]]}" , ta_right else s += td ""

			# s += td matrix i
			t += tr s, "tabindex=#{i}"

		t = tr(@headers(R)) + t
		table t,'style="border:none"'

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
		# for ppr in range PPR
		z = random()
		if z < 0.5 - remi
			si = "2" # 2
			sa = "0" # 0
		else if z > 0.5 + remi 
			si = "0" # 0 
			sa = "2" # 2
		else 
			si = "1" # 1
			sa = "1" # 1
		pi.res.push si
		pa.res.push sa

	makeOppColRes : (pairs,flag) ->
		bord = 0
		for pair in pairs
			a = pair[0]
			b = pair[1]

			pa = playersByScore[a]
			pb = playersByScore[b]

			bord += 1
			pa.table = bord
			pb.table = bord

			pa.opp.push b
			pb.opp.push a

			@handleCol pa,pb
			if flag then @handleRes pa,pb
			
# add 1598,"AIKIO Onni"
# add 1539,"ANDERSSON Lars Owe"
# add 1532,"ANTONSSON Görgen"
# add 1697,"BJÖRKDAHL Göran"
# add 1598,"ISRAEL Dan"
# add 1825,"JOHANSSON Lennart"
# add 1559,"LEHVONEN Jouko"
# add 1561,"LILJESTRÖM Tor"
# add 1583,"PERSSON Kjell"
# add 1644,"PETTERSSON Lars-Åke"
# add 1684,"SILINS Peteris"
# add 1681,"STOLOV Leonid"
# add 1400,"STRÖMBÄCK Henrik"
# add 1535,"ÅBERG Lars-Erik"

data = """
TITLE=Senior Stockholm
DATE=2025-01-19
ROUND=0
TPP=30
PPP=60
PAUSED=

1825!JOHANSSON Lennart
1697!BJÖRKDAHL Göran
1684!SILINS Peteris
1681!STOLOV Leonid
1644!PETTERSSON Lars-Åke
1598!ISRAEL Dan
1598!AIKIO Onni
1583!PERSSON Kjell
1561!LILJESTRÖM Tor
1559!LEHVONEN Jouko
1539!ANDERSSON Lars Owe
1535!ÅBERG Lars-Erik
1532!ANTONSSON Görgen
1400!STRÖMBÄCK Henrik
"""

# playersByELO.sort (a,b)-> b.elo - a.elo

# for i in range playersByELO.length
# 	player = playersByELO[i]
# 	player.id = i # zero based internally

# echo playersByELO

tournament = new Tournament "demo", data # playersByELO

makePairs = (solution) ->
	res = []
	for j in range solution.length
		if j < solution[j] then res.push [j,solution[j]]
	res

antal = 4
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

app.innerHTML = tournament.makeHTML()
info.innerHTML = tournament.info()

for control in document.querySelectorAll '[tabindex]'
	control.onkeydown = handleKeyDown

moveFocus 0
echo app.innerHTML

document.addEventListener 'DOMContentLoaded', ->
	# app = document.getElementById 'app'
	app.onwheel = (event) ->
		event.preventDefault()
		n = playersByELO.length-1
		if event.deltaY < 0 
			if current > 0 then moveFocus current - 1
		else 
			if current < n then moveFocus current + 1

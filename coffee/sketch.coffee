# ½ •

import { Edmonds } from './blossom.js' 

range = _.range
echo = console.log

FAIRPAIR = false
SWISS = true

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

# Dessa två listor pekar båda på samma data. De är dock olika sorterade
playersByID = []    # ELO
playersByScore = [] # Performance

tournament = null

currentPage = null

span  = (s,attrs="") -> "<span #{attrs}>#{s}</span>"
table = (s,attrs="") -> "<table #{attrs}>\n#{s}</table>"
tr    = (s,attrs="") -> "<tr #{attrs}>#{s}</tr>\n"
td    = (s,attrs="") -> "<td #{attrs}>#{s}</td>"
th    = (s,attrs="") -> "<th #{attrs}>#{s}</th>"

seed = 0
random = -> (((Math.sin(seed++)/2+0.5)*10000)%100)/100

header    = document.getElementById 'header'

makePairs = (solution) ->
	res = []
	for j in range solution.length
		if j < solution[j] then res.push [j,solution[j]]
	res

findNumberOfDecimals = (lst) ->
	best = 0
	for i in range 6
		unik = _.uniq (item.toFixed(i) for item in lst)
		if unik.length > best then [best,ibest] = [unik.length,i]
	ibest
console.assert 0 == findNumberOfDecimals [1234,1235]
console.assert 0 == findNumberOfDecimals [1234.146,1234.146]
console.assert 0 == findNumberOfDecimals [1235.123,1236.123]
console.assert 1 == findNumberOfDecimals [1234,1234.4]
console.assert 3 == findNumberOfDecimals [1234.146,1234.147]

export handleFile = (filename,data) ->
	echo 'handleFile',filename,data
	tournament = new Tournament filename,data
	pageStandings.makeHTML()

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

inverse = (s) -> 
	res = []
	for ch in s
		res.push "210"[parseInt ch]
	res
console.assert ["2","2"], inverse ["0","0"]
console.assert ["1","1"], inverse ["1","1"]
console.assert ["0","0"], inverse ["2","2"]

xs = (ratings, own_rating) -> sumNumbers(1 / (1 + 10**((rating - own_rating) / 400)) for rating in ratings)

pr = (rs, s, lo=0, hi=4000, r=(lo+hi)/2) -> if hi - lo < 0.001 then r else if s > xs rs, r then pr rs, s, r, hi else pr rs, s, lo, r
# echo 'pr', pr [1900,2100], 1

class Player
	constructor : (@elo, @name, @opp=[], @col=[], @res=[]) ->
		@active = true
		@error = false
		# @opp är en lista med heltal
		# @col är en lista med -1 och 1
		# @res är en lista med strängar "0", "1" eller "2"
		# ["2","0"]   => 1.0 pp

	check : -> # Kontrollerar att resultaten är konsistenta
		return true
		r = @opp.length - 1
		if r == -1 then return true
		q = playersByID[@opp[r]]
		if @res.length-1 < r 
			echo "Resultat saknas för #{@name}"
			return false
		if q.res.length-1 < r 
			echo "Resultat saknas för #{q.name}"
			return false
		a = @res[r] / 2
		b = q.res[r] / 2
		if a + b == 1 then return true
		echo "Felaktigt resultat för #{@name} mot #{q.name}: #{a} - #{b}"
		false

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
		for i in range @res.length # - 1
			for ch in @res[i]
				summa += parseInt ch
		summa/2

	average : ->
		summa = 0
		n = @opp.length - 1
		if n == -1 then return 0
		for i in range n
			opp = @opp[i]
			p = playersByID[opp]
			summa += p.elo
		if n==0 then 0 else summa/n

	prettyScore : ->
		@score().toFixed(1).replace('.5','½').replace('.0','&nbsp;').replace("0½","½&nbsp;")

	performance_rating : (ratings, score) ->
		lo = 0
		hi = 4000
		while hi - lo > 0.0000001
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
			elos.push playersByID[@opp[r]].elo

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

matrix = (i) ->
	res = Array(playersByID.length).fill('•') 
	res[i] = '*'
	if i == 0 then res[0]='H'
	if i == playersByID.length-1 then res[i]='L'
	pi = playersByID[i]
	for r in range pi.opp.length
		res[pi.opp[r]] = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"[r]
	res.join "   "

class Page 
	constructor : ->
	makeHeader : ->
		isoDate = new Date().toLocaleString('sv-se',{hour12:false}).replace(',','')
		s = ""
		s += td "Rond #{tournament.round}", 'style="border:none; width:33%; text-align:left"'
		s += td tournament.title,           'style="border:none; width:33%; text-align:center"'
		s += td isoDate,                    'style="border:none; width:33%; text-align:right"'
		header = document.getElementById 'header'
		header.innerHTML = table tr(s), 'style="width: 100%; font-weight: bold"'
	moveFocus : (next) ->
		@current = next
		focusableArray = document.querySelectorAll('[tabindex]')
		n = focusableArray.length
		if @current <= -1 then @current = 0
		if @current >= n then @current = n - 1
		focusableArray[@current].focus()

class PageTables extends Page
	constructor : -> 
		super()
		@app = document.getElementById 'app'
		@klass = 'PageTables'
		@current = 0 

	headers : ->
		h = ""
		h += th "b",    'style="border:none"'
		h += th "vit",  'style="border:none"'
		h += th "elo",  'style="border:none"'
		h += th "result",'style="border:none"'
		h += th "elo",  'style="border:none"'
		h += th "svart",'style="border:none"'
		h += th "diff", 'style="border:none"'
		h

	makeHTML : ->
		R = tournament.round # playersByScore[0].opp.length
		# echo 'PageTables.makeHTML',R
		ta_left   = "style='text-align:left'"
		ta_right  = "style='text-align:right'"
		t = ""

		totalDiff = 0

		for i in range tournament.tables.length # playersByScore.length
			[a,b] = tournament.tables[i]
			p = playersByID[a]
			q = playersByID[b]
			s = ""

			s += td i+1 # id
			s += td p.name,ta_left # namn
			s += td p.elo # elo

			# fyll i senaste resultaten om de finns!
			s += td "&nbsp; - &nbsp;" # res

			s += td q.elo # elo
			s += td q.name,ta_left # namn
			s += td p.elo - q.elo, ta_right # diff
			totalDiff += Math.abs p.elo - q.elo

			t += tr s, "tabindex=#{i}"

		# for i in range playersByID.length
		# 	echo matrix i

		# echo 'totalDiff',totalDiff
		t = tr(@headers(R)) + t
		@app.innerHTML = table t,'style="border:none"'

	handleKeyDown : (event) ->
		# echo 'handleKeyDown Tables',event.key

		if event.key in ['ArrowLeft','ArrowRight']
			currentPage = pageStandings
			currentPage.makeHTML()
			currentPage.moveFocus currentPage.current
			return

		index = event.target.tabIndex
		if event.key == 'ArrowDown' then currentPage.moveFocus index+1
		if event.key == 'ArrowUp'   then currentPage.moveFocus index-1
		if event.key == 'Home'      then currentPage.moveFocus 0
		if event.key == 'End'       then currentPage.moveFocus tournament.tables.length - 1

		if event.key == 'Enter'
			echo 'Pair'
			if tournament.pair()
				pageTables.makeHTML()

		if event.key in ['Delete','0', ' ', '1']
			tbl = tournament.tables[index]
			p = playersByID[tbl[0]]
			q = playersByID[tbl[1]]
			r = p.opp.length-1
			cell = event.target.children[3]

			if event.key == 'Delete'
				p.res[r] = ""
				q.res[r] = ""
				cell.innerHTML = "&nbsp; - &nbsp;" # p.result r,index-1
				currentPage.moveFocus index + 1
			if event.key in "0 1"
				trans = {"0":"0", ' ':"1", "1": "2"}
				snart = {"0":"2", ' ':"1", "1": "0"}
				p.res[r] = trans[event.key]
				q.res[r] = snart[event.key]
				cell.innerHTML = {"0":"0 - 1", ' ':"½ - ½", "1": "1 - 0"}[event.key] # p.result r,index-1
				currentPage.moveFocus index + 1


class PageStandings extends Page
	constructor : -> 
		super()
		@app = document.getElementById 'app'
		@klass = 'PageStandings'
		@current = 0

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
		h += th "bf",'style="border:none"'
		h += th "*",'style="border:none"'
		h += th "avg",'style="border:none"'
		h

	makeHTML : ->
		R = tournament.round # playersByScore[0].opp.length
		# echo 'PageStandings.makeHTML',R

		ta_left   = "style='text-align:left'"
		ta_right  = "style='text-align:right'"
		ta_center = "style='text-align:center'"
		ta_center_strong = "style='text-align:center; font-weight: bold;'"

		prs = (p.performance() for p in playersByID)
		decimals = findNumberOfDecimals prs

		t = ""
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
			if pr < 3999
				s += td pr.toFixed(decimals) #,ta_right
			else
				s += td ""

			s += td p.prettyScore(),ta_right # pp

			# s += td "",'style="width:5px;border-top:none; border-bottom:none"' # empty

			# s += td p.table + p.prettyCol(R-1)[0] + p.prettyCol2(R-1)[0],ta_center
			# bf
			if p.table
				bf = p.table + {l:'B',r:'W'}[p.prettyCol(R-1)[1]]
			else
				bf = ""
			s += td bf, ta_center_strong

			# diff
			# if R >= 1 then s += td playersByID[p.opp[R-1]].elo - p.elo, ta_right else s += td "",ta_right

			# id:bf
			# q = playersByID[i]
			# if R >= 1 then s += td "#{i+1}:#{q.table + {l:'B',r:'W'}[q.prettyCol(R-1)[1]]}" , ta_right else s += td "",ta_right

			# s += td matrix i
			# echo matrix i
			s += td "" # * (pause)
			s += td p.average().toFixed 1
			t += tr s, "tabindex=#{i}"

		t = tr(@headers(R)) + t
		@app.innerHTML = table t,'style="border:none"'

	handleKeyDown : (event) -> # Enkelrond
		if event.key in [' ','ArrowDown','ArrowUp'] then event.preventDefault()

		if event.key in ['ArrowLeft','ArrowRight']
			currentPage = pageTables
			currentPage.makeHTML()
			currentPage.moveFocus currentPage.current
			return 

		# echo 'handleKeyDown Standings',event.key
		if event == undefined then return
		index = event.target.tabIndex # - 1
		p = playersByScore[index]
		r = p.opp.length-1
		cell = event.target.children[3+r]

		if event.key == 'Enter'
			if tournament.pair()
				currentPage = pageTables
				pageTables.makeHTML()

		if event.key == 'ArrowDown' then currentPage.moveFocus index+1
		if event.key == 'ArrowUp'   then currentPage.moveFocus index-1
		if event.key == 'Home'      then currentPage.moveFocus 0
		if event.key == 'End'       then currentPage.moveFocus playersByID.length - 1

		# Sökning
		key = event.key.toUpperCase()
		if key == event.key then dir = -1 else dir = 1
		if key in "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ"
			index = event.target.tabIndex # - 1
			n = playersByScore.length
			for i in range n
				if dir==1 then ix=(index+i+1) % n else ix = (index-i-1) %% n
				p = playersByScore[ix]
				if p.name.startsWith key
					currentPage.moveFocus ix
					break

class Tournament
	constructor : (filename, data) ->
		@fetchData filename, data
		playersByScore = _.clone playersByID
		@tables = []
		@round = 0

		echo 'playersByScore', playersByScore

	pair : ->
		for p in playersByID
			if not p.check() then return false
		solution = @findSolution @makeEdges -1
		@tables = makePairs solution

		@round += 1
		currentPage.makeHeader()

		echo 'tables',@tables
		# paret med högst elo sitter på bord 1
		if FAIRPAIR 
			@tables.sort (a,b)-> 
				a0 = playersByID[a[0]].elo
				a1 = playersByID[a[1]].elo
				b0 = playersByID[b[0]].elo
				b1 = playersByID[b[1]].elo
				b0 + b1 - a0 - a1
		if SWISS
			@tables.sort (a,b)-> 
				a0 = playersByID[a[0]].score()
				a1 = playersByID[a[1]].score()
				b0 = playersByID[b[0]].score()
				b1 = playersByID[b[1]].score()
				b0 + b1 - a0 - a1
		@tables = @makeOppColRes @tables
		
		@sort()
		
		echo 'playersByID',playersByID
		for i in range playersByID.length
			echo matrix i

		currentPage.makeHTML()
		true

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

		if not (4 <= g.N < 100)
			alert "Number of players must be between 4 and 99!"
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

		playersByID.sort (a,b) ->  
			if a.elo != b.elo then return b.elo - a.elo
			if a.name > b.name then 1 else -1

		for i in range g.N
			playersByID[i].id = i
		
		echo 'playersByID', playersByID 

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

	ok : (a,b) -> a.id != b.id and a.id not in b.opp and Math.abs(a.balans() + b.balans()) <= 2

	makeEdges_FAIRPAIR : (iBye) -> # iBye är ett id eller -1
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
		echo 'edges',arr
		arr

	makeEdges_SWISS : (iBye) -> # iBye är ett id eller -1

		@sort()

		echo 'makeEdges',playersByScore

		hashx = {}
		for i in range playersByScore.length
			p = playersByScore[i]
			p.rank = i
			p.group = p.score().toFixed 1
			if p.group not of hashx then hashx[p.group] = 0
			hashx[p.group] += 1

		echo 'hashx',hashx
		for p in playersByID
			p.groupSize = hashx[p.group]

		echo 'playersByScore',playersByScore
		echo 'playersByID',playersByID

		arr = []
		for pa in playersByID
			a = pa.id
			if not pa.active or a == iBye then continue
			for pb in playersByID
				b = pb.id
				if b <= a then continue
				if not pb.active or b == iBye then continue
				if not @ok pa,pb then continue

				d0 = Math.abs pa.score() - pb.score()
				d1 = Math.abs pa.balans() + pb.balans()
				if pa.group == pb.group 
					d2 = Math.abs pa.groupSize/2 - Math.abs pa.rank - pb.rank
				else
					d2 = Math.abs pa.rank - pb.rank

				diff = 10000 * d0 + 100 * d1 + d2 ** 1.01
				echo "diff för #{a} #{b}: pag=#{pa.group} pbg=#{pb.group} pags=#{pa.groupSize} pbgs=#{pb.groupSize}  par=#{pa.rank} pbr=#{pb.rank} d0=#{d0} d1=#{d1} d2=#{d2} diff=#{diff} #{pa.name} vs #{pb.name}"

				cost = 99999 - diff
				arr.push [a, b, cost]

		echo 'edges',arr
		arr

	makeEdges : (iBye) -> # iBye är ett id eller -1
		if SWISS then return makeEdges_SWISS iBye
		if FAIRPAIR then return makeEdges_FAIRPAIR iBye

	findSolution : (edges) ->
		edmonds = new Edmonds edges
		edmonds.maxWeightMatching edges

	sort : -> playersByScore.sort (a,b) ->
		if SWISS then return b.score() - a.score()
		if FAIRPAIR then return b.performance() - a.performance()

	handleCol : (pi,pa,flag) ->
		if pi.col.length == 0
			if flag
				pi.col.push -1
				pa.col.push 1
			else
				pi.col.push 1
				pa.col.push -1
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
					if flag 
						pi.col.push -1
						pa.col.push 1
					else
						pi.col.push 1
						pa.col.push -1

	handleRes : (pi,pa) ->
		z = random()
		[si,sa] = [1,1]
		if z < 0.45 then [si,sa] = [2,0]
		if z > 0.55 then [si,sa] = [0,2]
		pi.res.push si.toString()
		pa.res.push sa.toString()

	# uppdaterar opp och col
	makeOppColRes : (pairs, flag=false) ->
		bord = 0
		res = []
		for pair in pairs
			a = pair[0]
			b = pair[1]

			pa = playersByID[a]
			pb = playersByID[b]

			bord += 1
			pa.table = bord
			pb.table = bord

			pa.opp.push b
			pb.opp.push a

			@handleCol pa,pb, bord % 2 == 0

			# vid lika färgvärden, alternera
			n = pa.col.length
			if pa.col[n-1] == 1
				res.push [a,b]
			else
				res.push [b,a]
		res
			
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

pageStandings = new PageStandings()
pageTables = new PageTables() 

tournament = new Tournament "demo", data
currentPage = pageStandings
currentPage.makeHeader()
currentPage.makeHTML()

currentPage.moveFocus 0

window.addEventListener 'keydown', (event) ->
	# echo 'keydown',currentPage.klass
	currentPage.handleKeyDown event
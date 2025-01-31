# ½ •

# Resultat
# 0 Förlust (0)
# = Remi (0.5)
# 1 Vinst (1)
# + Ej spelad vinst
# - Ej spelad förlust
# ? Uppskjutet

import { Edmonds } from './blossom.js' 

range = _.range
echo = console.log

# https://arxiv.org/html/2112.10522v2 Swiss using Blossom

BYE = -1
PAUSE = -2
SEPARATOR = '!'

FIRST = 0

KEYWORDS = {}
KEYWORDS.TITLE = 'text'
KEYWORDS.DATE = 'text' 
KEYWORDS.TYPE = 'FairPair or Swiss'
KEYWORDS.ROUND = 'integer'
KEYWORDS.ROUNDS = 'integer'
KEYWORDS.PAUSED = '!-separated integers'

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

header = document.getElementById 'header'

isoDate = -> new Date().toLocaleString('sv-se',{hour12:false}).replace(',','').replace(':','h').substring(0,16)

backa = (s) -> s.substring(0,s.length-1)
console.assert "ab" == backa "abc"
console.assert "a" == backa "ab"
console.assert "" == backa "a"
console.assert "" == backa ""

makePairs = (solution) ->
	result = []
	for j in range solution.length
		if j < solution[j] then result.push [j,solution[j]]
	result

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
	echo 'handleFile',filename
	echo data
	tournament = new Tournament filename,data
	pageStandings.makeHTML()

sum = (s) ->
	result = 0
	for item in s
		result += parseFloat item
	result

sumNumbers = (arr) ->
	result = 0
	for item in arr
		result += item
	result

inverse = (s) ->
	hash = {'0':'1', '=':'=', '1':'0', '+','-', '-':'+'}
	result = ""
	for ch in s
		result += hash[s]
	result
console.assert "0=1+-", inverse "1=0-+"

xs = (ratings, own_rating) -> sumNumbers(1 / (1 + 10**((rating - own_rating) / 400)) for rating in ratings)

pr = (rs, s, lo=0, hi=4000, r=(lo+hi)/2) -> if hi - lo < 0.001 then r else if s > xs rs, r then pr rs, s, r, hi else pr rs, s, lo, r
# echo 'pr', pr [1900,2100], 1

class Player
	constructor : (@elo, @name, @opp=[], @col="", @res="") ->
		@active = true
		@error = false
		# @opp är en lista med heltal
		# @col är en sträng med w eller b, ett tecken för varje rond
		# @res är en sträng med 0=1+- # + och - innebär att partiet ej spelats

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

	balans : ->
		result = 0
		n = @col.length
		for r in range n
			if @res[r] in '0=1' # ignorera + och - 
				if @col[r] == 'w' then result += 1
				if @col[r] == 'b' then result -= 1
		result

	# det interna och externa formatet bör överensstämma maximalt
	read : (player) ->
		@elo = parseInt player[0]
		@name = player[1]
		if player.length < 3 then return
		ocrs = player.slice 2
		@opp = []
		@col = ""
		@res = ""
		for ocr in ocrs
			if 'w' in ocr then col = 'w'
			if 'b' in ocr then col = 'b'
			@col += col
			arr = ocr.split col
			@opp.push parseInt(arr[0]) - FIRST # opponenten
			if arr.length==2 then @res += arr[1] # resultatet

	write : -> # 1631!Christer!12w0!23b=!14w1   Elo:1631 Name:Christer opponent:23 color:b result:remi
		result = []
		result.push @elo
		result.push @name
		r = @opp.length
		if r == 0 then return result.join SEPARATOR
		echo @opp,@col,@res
		ocr = []
		for i in range r
			s = ""
			s += @opp[i] + FIRST
			s += @col[i]
			s += @res[i]
			echo 's',s
			ocr.push s
		result.push ocr.join SEPARATOR
		result.join SEPARATOR

	score : ->
		hash = {'0':0, '=': 0.5, '1':1, '+':1, '-':0, '?':0.5}
		summa = 0
		if @opp.length == 0 then return 0
		for i in range @res.length # - 1
			for ch in @res[i]
				summa += hash[ch]
		summa

	average : ->
		summa = 0
		n = @opp.length - 1
		if n == -1 then return 0
		for i in range n
			opp = @opp[i]
			p = playersByID[opp]
			summa += p.elo
		if n==0 then 0 else summa/n

	prettyScore : -> @score().toFixed 1 # .replace('.5','=').replace('.0','&nbsp;').replace("0=","=&nbsp;")

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
		echo 'performance'
		# pp = @score()
		hash = {'0':0, '=': 0.5, '1':1}
		elos = []
		if @res.length == 0 then return 0
		pp = 0
		for r in range @res.length # - 1
			# if @opp[r] == BYE then continue
			# if @opp[r] == PAUSE then continue
			if @res[r] in "0=1" # +-?
				elos.push playersByID[@opp[r]].elo
				pp += hash[@res[r]]

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
		@res[r]
		#("0½1"[ch] for ch in @res[r]).join "" # "12" => "½1"

	prettyCol : (r) -> if @col[r] == 'b' then "ul" else "ur"  # 1 => "black"
	prettyCol2: (r) -> if @col[r] == 'w' then "lr" else "ll"  # 1 => "white"

	result: (r,index) ->
		s = span @opp[r]+1, "class=" + @prettyCol r
		t = span @prettyRes(r) , "class=" + @prettyCol2 r
		td s + t

class Page 
	constructor : ->
	makeHeader : ->
		s = ""
		s += td "Rond #{tournament.round} av #{tournament.rounds}", 'style="border:none; width:33%; text-align:left"'
		s += td tournament.type,                                    'style="border:none; width:33%; text-align:center"'
		s += td tournament.title + ' ' + isoDate(),                 'style="border:none; width:33%; text-align:right"'
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

		if event.key in '0 1+-?' or event.key == 'Delete'
			tbl = tournament.tables[index]
			p = playersByID[tbl[0]]
			q = playersByID[tbl[1]]
			r = p.opp.length # -1
			cell = event.target.children[3]

			if event.key == 'Delete'
				p.res = p.res.substring(0,r-1) # KOLLAS!
				q.res = q.res.substring(0,r-1)
				cell.innerHTML = "&nbsp; - &nbsp;" # p.result r,index-1
				currentPage.moveFocus index + 1
			if event.key in "0 1+-"
				trans = {"0":"0", ' ':"=", "1": "1", '+':"+", "-": "-", "?":"?"}
				snart = {"0":"1", ' ':"=", "1": "0", '+':"-", "-": "+", "?":"?"}
				if p.res.length < p.opp.length
					if r > 0 then p.res += trans[event.key]
					if r > 0 then q.res += snart[event.key]
				else
					if r > 0 then p.res = backa(p.res) + trans[event.key]
					if r > 0 then q.res = backa(q.res) + snart[event.key]
				cell.innerHTML = {"0":"0 - 1", ' ':"½ - ½", "1": "1 - 0", "+": "+ - -", "-": "- - +","?":"uppsk"}[event.key] # p.result r,index-1
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

		if event.ctrlKey && event.shiftKey && event.key.toLowerCase() == "i"
			event.preventDefault()
			return

		echo 'handleKeyDown',event.key
		# if event.key in [' ','ArrowDown','ArrowUp'] then event.preventDefault()

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
		@round = 0
		@type = 'FairPair'
		@fetchData filename, data
		playersByScore = _.clone playersByID
		@tables = []

		echo 'playersByScore', playersByScore

	makePaused : -> @paused.join SEPARATOR # (12!34)

	makePlayers : ->
		players = (p.write() for p in playersByID)
		players.join "\n"

	makeTournament : ->
		result = []
		result.push "TITLE:" + @title
		result.push "DATE:" + @date
		result.push "TYPE:" + @type
		result.push "ROUND:" + @round
		result.push "ROUNDS:" + @rounds
		result.push "PAUSED:" + @makePaused()
		result.push ""
		result.push @makePlayers()
		result.join '\n'
		
	downloadFile : (txt,filename) ->
		# filename = filename.substring 0,@title.length
		echo 'downloadFile',filename
		blob = new Blob [txt], { type: 'text/plain' }
		url = URL.createObjectURL blob
		a = document.createElement 'a'
		a.href = url
		a.download = filename
		document.body.appendChild a
		a.click()
		document.body.removeChild a
		URL.revokeObjectURL url

	pair : ->
		for p in playersByID
			if not p.check() then return false

		@virgin = false
		@downloadFile @makeTournament(), "#{@title}-R#{@round}-#{isoDate()}.txt"

		echo ""
		echo "Lottning av rond #{@round} ====================================================="
		document.title = "Round #{@round+1}"

		solution = @findSolution @makeEdges -1
		@tables = makePairs solution

		@round += 1
		currentPage.makeHeader()

		echo 'tables',@tables
		# spelaren med högst PR sitter på bord 1. Vid lika avgör bordens lägre spelare
		if @type == 'FairPair' 
			arr = []
			echo @tables
			for [a,b] in @tables
				a0 = playersByID[a].performance()
				b0 = playersByID[b].performance()
				arr.push [Math.max(a0,b0), Math.min(a0,b0), a, b]
			arr.sort (a,b) ->
				diff = b[0] - a[0]
				if diff == 0 then return b[1] - a[1]
				diff

			@tables = ([c,d] for [a,b,c,d] in arr)

			# @tables.sort (a,b) ->
			# 	a0 = playersByID[a[0]].performance()
			# 	a1 = playersByID[a[1]].performance()
			# 	b0 = playersByID[b[0]].performance()
			# 	b1 = playersByID[b[1]].performance()
			# 	echo 'performance 4'
			# 	amax = Math.max(a0,a1)
			# 	bmax = Math.max(b0,b1)
			# 	amin = Math.min(a0,a1)
			# 	bmin = Math.min(b0,b1)
			# 	if amax == bmax then bmin - amin else bmax - amax
		if @type == 'Swiss'
			@tables.sort (a,b) ->
				a0 = playersByID[a[0]].score()
				a1 = playersByID[a[1]].score()
				b0 = playersByID[b[0]].score()
				b1 = playersByID[b[1]].score()
				b0 + b1 - a0 - a1
		@tables = @makeOppColRes @tables
		@sort()
		
		echo 'playersByID',playersByID
		for i in range playersByID.length
			echo @matrix i

		currentPage.makeHTML()
		true

	fetchData : (filename, data) ->

		@filename = filename.replaceAll ".txt",""

		if @filename == 'bbp60' then FIRST = 1

		data = data.split '\n'

		hash = {}

		# default values
		hash.PLAYERS = []
		hash.TITLE = ''
		hash.DATE = ''
		hash.TYPE = 'FairPair' # or Swiss
		hash.ROUND = 0
		hash.ROUNDS = 10
		hash.PAUSED = ""

		for line,nr in data
			line = line.trim()
			if line.length == 0 then continue
			arr = line.split ':'
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
				arr[1] = arr[1].trim() # namnet
				for i in range 2,arr.length
					arr[i] = arr[i].replaceAll ' ',''
				if not /^\d{4}$/.test arr[0]
					alert "#{arr[0]}\n in line #{nr+1}\n must have four digits"
					return
				for i in range 2,arr.length
					item = arr[i]
					if not /^-?\d+(w|b)[0=1+-]$/.test item
						alert "#{item}\n in line #{nr+1}\n must follow the format <number> <color> <result>\n  where color is one of w,b or _\n  and result is one of 0, = or 1"
						return
				hash.PLAYERS.push arr
		@players = []
		@title = hash.TITLE
		@date = hash.DATE
		@type = hash.TYPE
		@round = parseInt hash.ROUND
		@rounds = parseInt hash.ROUNDS
		@paused = hash.PAUSED # list of zero based ids

		players = hash.PLAYERS
		g.N = players.length

		if not (4 <= g.N < 100)
			alert "Number of players must be between 4 and 99!"
			return

		playersByID = []
		for i in range g.N
			player = new Player i
			echo players[i]
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

		# for p in playersByID
		# 	echo p.res
		# 	echo p.col,p.balans()

		# extract @pairs from the last round
		@pairs = []
		for p in playersByID
			a = p.id
			b = _.last p.opp
			#echo "a,b",a,b
			if a < b 
				pa = playersByID[a]
				pb = playersByID[b]
				@pairs.push if 'w' == p.col[p.col.length-1] # w
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

	ok : (a,b) -> a.id != b.id and a.id not in b.opp and Math.abs(a.balans() + b.balans()) <= 1

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
				# diff = 10000 * d0 + d1 + 100 * d2 # ** 1.01
				#echo "#{a} #{b}: pag=#{pa.group} pbg=#{pb.group} pags=#{pa.groupSize} pbgs=#{pb.groupSize}  par=#{pa.rank} pbr=#{pb.rank} d0=#{d0} d1=#{d1} d2=#{d2} diff=#{diff} #{pa.name} vs #{pb.name}"

				cost = 99999 - diff # ** 1.01
				arr.push [a, b, cost]

		echo 'edges',arr
		arr
	
	matrix : (i) ->
		n = playersByID.length
		result = Array(n).fill('•')
		result[i] = '*'
		if i == 0   then result[0]='H'
		if i == n-1 then result[i]='L'
		pi = playersByID[i]
		for r in range pi.opp.length
			result[pi.opp[r]] = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"[r]
		if n > 120 then return result.join ""
		if n >  70 then return result.join " "
		if n >  40 then return result.join "  "
		result.join "   "

	makeEdges : (iBye) -> # iBye är ett id eller -1
		if @type == 'Swiss' then return @makeEdges_SWISS iBye
		if @type == 'FairPair' then return @makeEdges_FAIRPAIR iBye

	findSolution : (edges) ->
		edmonds = new Edmonds edges
		edmonds.maxWeightMatching edges

	sort : -> playersByScore.sort (a,b) =>
		#echo '@type', @type
		if @type == 'Swiss'
			diff = b.score() - a.score()
			if diff == 0 then diff = b.elo - a.elo
			return diff
		if @type == 'FairPair' then return b.performance() - a.performance()

	handleCol : (pi,pa,flag) ->
		if pi.col.length == 0
			if flag
				pi.col += 'b'
				pa.col += 'w'
			else
				pi.col += 'w'
				pa.col += 'b'
		else
			if pi.balans() > pa.balans()
				pi.col += "b"
				pa.col += "w"
			else if pi.balans() < pa.balans()
				pi.col += 'w'
				pa.col += 'b'
			else # samma balans
				otherCol = {'w':'b', 'b':'w'}
				foundDiff = false
				for j in range pi.col.length-1,-1,-1
					if pi.col[j] != pa.col[j]
						foundDiff = true
						pi.col += otherCol[pi.col[j]]
						pa.col += otherCol[pa.col[j]]
						break
				if not foundDiff
					if flag 
						pi.col += "b"
						pa.col += "w"
					else
						pi.col += 'w'
						pa.col += 'b'

	# handleRes : (pi,pa) ->
	# 	z = random()
	# 	[si,sa] = [1,1]
	# 	if z < 0.45 then [si,sa] = [2,0]
	# 	if z > 0.55 then [si,sa] = [0,2]
	# 	pi.res.push si.toString()
	# 	pa.res.push sa.toString()

	# uppdaterar opp och col
	makeOppColRes : (pairs, flag=false) ->
		bord = 0
		result = []
		echo pairs
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
			if pa.col[n-1] == 'w' then result.push [a,b]
			if pa.col[n-1] == 'b' then result.push [b,a]
		result
			
data = """
TITLE:Demo
DATE:2025-01-19
TYPE:FairPair
ROUND:0
ROUNDS:4
PAUSED:

1825!JOHANSSON Lennart  ! 7 b 1
1697!BJÖRKDAHL Göran    ! 8 w =
1684!SILINS Peteris     ! 9 w 0
1681!STOLOV Leonid      !10 b 1
1644!PETTERSSON Lars-Åke!11 b =
1598!AIKIO Onni         !12 w 0
1598!ISRAEL Dan         !13 w 1
1583!PERSSON Kjell      ! 0 b 0
1561!LILJESTRÖM Tor     ! 1 b =
1559!LEHVONEN Jouko     ! 2 w 1
1539!ANDERSSON Lars Owe ! 3 w 0
1535!ÅBERG Lars-Erik    ! 4 b =
1532!ANTONSSON Görgen   ! 5 b 1
1400!STRÖMBÄCK Henrik   ! 6 w 0
"""

# 1825!JOHANSSON Lennart
# 1697!BJÖRKDAHL Göran
# 1684!SILINS Peteris
# 1681!STOLOV Leonid
# 1644!PETTERSSON Lars-Åke
# 1598!AIKIO Onni
# 1598!ISRAEL Dan
# 1583!PERSSON Kjell
# 1561!LILJESTRÖM Tor
# 1559!LEHVONEN Jouko
# 1539!ANDERSSON Lars Owe
# 1535!ÅBERG Lars-Erik
# 1532!ANTONSSON Görgen
# 1400!STRÖMBÄCK Henrik


pageStandings = new PageStandings()
pageTables = new PageTables() 

tournament = new Tournament "demo", data
currentPage = pageStandings
currentPage.makeHeader()
currentPage.makeHTML()

currentPage.moveFocus 0

window.addEventListener 'keydown', (event) ->
	currentPage.handleKeyDown event
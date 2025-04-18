# ½ •

# 0 Förlust (0.0)
# = Remi    (0.5)
# 1 Vinst   (1.0)

# + Ospelad vinst
# - Ospelad förlust
# ? Ospelad uppskjutet, använd elodiff för att beräkna väntevärdet

# _ innebär att resultat saknas

import { Edmonds } from './blossom.js' 

range = _.range
echo = console.log

# https://arxiv.org/html/2112.10522v2 Swiss using Blossom

BYE = -1
PAUSE = -2
SEPARATOR = '!'

FIRST = 1

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

shorten = (s,n) ->
	if s.length > n then s = s.substring 0,n
	s.padEnd n

padCenter = (str, length, char = " ") ->
	padding = length - str.length
	leftPad = Math.floor(padding / 2)
	rightPad = padding - leftPad
	char.repeat(leftPad) + str + char.repeat(rightPad)


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
	# echo 'handleFile',filename
	# echo data
	tournament = new Tournament filename,data
	pageStandings.makeHTML()
	pageStandings.makeHeader()

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
		@candidate = false
		# @opp är en lista med heltal
		# @col är en sträng med w eller b, ett tecken för varje rond
		# @res är en sträng med 0=1+-?  # + och - innebär att partiet ej spelats

	check : -> # Kontrollera att opponent, färger och resultat är konsistenta
		
		colors = 'bw wb'.split ' '
		results = '01 10 == +- -+ ?? __'.split ' '

		for r in range @opp.length
			if @opp[r] < 0 then continue # frirond eller inaktiv
			p = @
			q = playersByID[@opp[r]]

			if p.res.length-1 < r then return "Resultat saknas för #{p.name}"
			if q.res.length-1 < r then return "Resultat saknas för #{q.name}"

			a = p.opp[r]
			b = q.opp[r]
			if b != p.id or a != q.id then return "Opponenter stämmer ej för #{p.name} och #{q.name}"

			a = p.col[r]
			b = q.col[r]
			if a+b not in colors then return "Felaktiga färger för #{p.name} mot #{q.name}: #{a} vs #{b}"

			a = p.res[r]
			b = q.res[r]
			if a+b not in results then return "Felaktigt resultat för #{p.name} mot #{q.name}: #{a} vs #{b}"

		""

	balans : ->
		result = 0
		n = @col.length
		for r in range n
			if @res[r] in '0=1?' # ignorera + och - 
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
		#echo @opp,@col,@res
		ocr = []
		for i in range r
			s = ""
			if @opp[i] < 0 
				s += @opp[i]
			else
				s += @opp[i] + FIRST
			s += @col[i]
			s += @res[i]
			#echo 's',s
			ocr.push s
		result.push ocr.join SEPARATOR
		result.join SEPARATOR

	# writeResult : ->
	# 	rounds = []
	# 	for i in range tournament.round
	# 		rounds.push "#{@opp[i]}#{@col[i]}#{@res[i]}" 
	# 	echo "#{@elo} #{@name} #{rounds.join ' '} #{@performance()}"

	score : ->
		hash = {'0':0, '=': 0.5, '1':1, '+':1, '-':0, '?':0.0}
		summa = 0
		if @opp.length == 0 then return 0
		for i in range tournament.round - 1 # @res.length - 1
			for ch in @res[i]
				summa += hash[ch]
		summa

	average : ->
		result = []
		# n = @opp.length - 1
		n = tournament.round - 1
		if n == -1 then return 0
		for i in range n
			opp = @opp[i]
			if opp >= 0
				p = playersByID[opp]
				result.push p.elo
		n = result.length
		if n == 0 then return 0
		sum(result) / n 

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
		hash = {'0':0, '=':0.5, '1':1, '+':1, '-':0} #, '?':0.5}
		elos = []
		if @res.length == 0 then return 0
		pp = 0
		for r in range tournament.round - 1 # @res.length
			# if @opp[r] == BYE then continue
			# if @opp[r] == PAUSE then continue
			if @opp[r] >= 0
				# @res[r] kan vara underscore, vilket ska ignoreras
				q = playersByID[@opp[r]]
				if @res[r] == "?"
					elos.push q.elo
					pp += xs [q.elo], @elo
				else if @res[r] in "0=1+-"
					elos.push q.elo
					pp += hash[@res[r]]
			else # både frirond och frånvaro
				elos.push @elo
				pp += hash[@res[r]]


		n = elos.length
		if n == 1
			if pp == 0 then return @extrapolate 0.50,0.25,elos
			if pp == n then return @extrapolate 0.50,0.75,elos
		else
			if pp == 0 then return @extrapolate   1,  0.5,elos
			if pp == n then return @extrapolate n-1,n-0.5,elos

		@performance_rating elos,pp
		# echo 'performance',elos,pp,result

	prettyRes : (r) -> if @res[r] is undefined then "" else	@res[r]
	prettyCol : (r) -> if @col[r] == 'b' then "ul" else "ur"  # 1 => "black"
	prettyCol2: (r) -> if @col[r] == 'w' then "lr" else "ll"  # 1 => "white"
	prettyOpp: (r) -> 
		opp = @opp[r]
		if opp == -2 then return '*'
		if opp == -1 then return 'F'
		opp + 1

	result: (r,index) ->
		s = span @prettyOpp(r), "class=" + @prettyCol r
		t = span @prettyRes(r) , "class=" + @prettyCol2 r
		td s + t

	finalResult: (r,index) -> "#{@prettyOpp(r)}#{@col[r]}#{@res[r]}"

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
		footer = document.getElementById 'footer'
		if tournament.candidate then footer.innerHTML = "Frirond: " + tournament.candidate.name 

		@moveFocus 0


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
			#echo 'Pair'
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
			if event.key in "0 1+-?"
				trans = {"0":"0", ' ':"=", "1": "1", '+':"+", "-": "-", "?":"?"}
				snart = {"0":"1", ' ':"=", "1": "0", '+':"-", "-": "+", "?":"?"}
				# if p.res.length < p.opp.length
				# 	if r > 0 then p.res += trans[event.key]
				# 	if r > 0 then q.res += snart[event.key]
				# else
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
		h += th "medel",'style="border:none"'
		h

	makeHTML : ->
		R = tournament.round

		ta_left   = "style='text-align:left'"
		ta_right  = "style='text-align:right'"
		ta_center = "style='text-align:center'"
		ta_center_strong = "style='text-align:center; font-weight: bold;'"

		prs = (p.performance() for p in playersByID)
		decimals = findNumberOfDecimals prs

		t = ""
		for i in range playersByScore.length
			p = playersByScore[i]
			s = ""

			s += td p.id+1,ta_right # id
			s += td p.name,ta_left # namn
			s += td p.elo # elo

			for r in range R
				s += p.result r,i # ronder
				
			pr = p.performance()
			if pr < 3999
				s += td pr.toFixed(decimals) #,ta_right
			else
				s += td ""

			s += td p.prettyScore(),ta_right # pp

			if p.table
				bf = p.table + {l:'B',r:'W'}[p.prettyCol(R-1)[1]]
			else
				bf = ""
			s += td bf, ta_center_strong

			s += td if p.active then "*" else ""
			s += td p.average().toFixed 1
			t += tr s, "tabindex=#{i}"

		t = tr(@headers(R)) + t
		@app.innerHTML = table t,'style="border:none"'
		@moveFocus 0


	handleKeyDown : (event) -> # Enkelrond

		# if event.ctrlKey && event.shiftKey && event.key.toLowerCase() == "i"
		# 	event.preventDefault()
		# 	return

		if event.key in ['Control' ,'Shift'] then return

		#echo 'handleKeyDown',event.key
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

		if event.key == 'Pause'
			p.active = not p.active
			echo 'Pause', p.active
			cell = event.target.children[r+7]
			cell.innerHTML = if p.active then '*' else ''
			return

		if event.key == '*'
			echo '* detected'
			active = playersByID[0].active
			for p in playersByID
				p.active = not active
			pageStandings.makeHTML()

		if event.key == 'Enter'
			#echo 'paused',tournament.paused
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

		#echo 'playersByScore', playersByScore

	missingResults : ->
		for p in playersByID
			if p.active and "_" == p.res.substring(p.res.length-1) then return true
		false

	makePaused : -> (p.id + 1 for p in playersByID when not p.active).join SEPARATOR # (12!34)

	makePlayers : ->
		# for p in playersByScore
		# 	p.writeResult()

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
		#echo 'downloadFile',filename
		blob = new Blob [txt], { type: 'text/plain' }
		url = URL.createObjectURL blob
		a = document.createElement 'a'
		a.href = url
		a.download = filename
		document.body.appendChild a
		a.click()
		document.body.removeChild a
		URL.revokeObjectURL url

	handleBye : ->
		antal = 0
		@candidate = null

		for p in playersByScore
			#echo 'handleBye',p
			p.candidate = false
			if p.active
				antal++
				if -1 not in p.opp 
					@candidate = p 
		
		# antal = playersByID.length - @paused.length
		# @paused.length troligen ej satt.

		#echo 'handleBye',antal
		if antal % 2 == 1
			#echo 'udda antal spelare'
			if @candidate == null
				echo 'frirondskandidat saknas!'
			else
				@candidate.candidate = true
				@candidate.opp.push BYE
				@candidate.col += '_'
				@candidate.res += '1'
				echo "frirondskandidat = " + @candidate.name
		else
			@candidate = null

	medalize : (i) -> if i<9 then 'GSB456789'[i] else '•'

	makeTxt : ->
		result = []
		R = tournament.round
		prs = (p.performance() for p in playersByID)
		decimals = findNumberOfDecimals prs

		# Header
		result.push 'FairPair' + ' ' + tournament.title + ' ' + tournament.date + ' ' + tournament.rounds + ' ronder'
		result.push ""
		line = []
		line.push 'p'.padStart 1
		line.push 'id'.padStart 3
		line.push ' namn'.padEnd 24
		line.push '  elo '
		for i in range R - 1
			line.push padCenter "#{i+1}", 6
		line.push '   pr'
		result.push line.join ''

		# players
		for i in range playersByScore.length
			p = playersByScore[i]
			s = []
			s.push "#{@medalize(i)}".padStart 1
			s.push "#{p.id+1}".padStart 3
			s.push shorten " #{p.name}", 24
			s.push " #{p.elo}".padEnd 4

			for r in range R - 1
				s.push p.finalResult(r,i).padStart 6

			pr = p.performance()
			if pr < 3999 then s.push ' ' + pr.toFixed(decimals).padStart 7

			result.push s.join ''
		result.join "\n"

	pair : ->

		if @missingResults() then return

		@handleBye()

		for p in playersByID
			message = p.check()
			if message != ""
				alert message
				return false

		@virgin = false
		# @downloadFile @makeTournament(), "#{@title}-R#{@round}-#{isoDate()}.txt"

		echo ""
		echo "Lottning av rond #{@round} ====================================================="
		document.title = "Round #{@round+1}"

		solution = @findSolution @makeEdges -1
		@tables = makePairs solution

		@round += 1
		currentPage.makeHeader()

		#echo 'tables',@tables
		# spelaren med högst PR sitter på bord 1. Vid lika avgör bordens lägre spelare
		if @type == 'FairPair'
			arr = []
			#echo @tables
			for [c,d] in @tables
				a = playersByID[c].performance()
				b = playersByID[d].performance()
				abal = playersByID[c].balans()
				bbal = playersByID[d].balans()
				# echo 'balans',Math.round(a), Math.round(b), abal + bbal
				arr.push [Math.max(a,b), Math.min(a,b), c, d]
			arr.sort (a,b) -> if b[0] == a[0] then b[1] - a[1] else b[0] - a[0]
			@tables = ([c,d] for [a,b,c,d] in arr)

		if @type == 'Swiss'
			arr = []
			for [c,d] in @tables
				a = playersByID[c].score()
				b = playersByID[d].score()
				arr.push [Math.max(a,b), Math.min(a,b), c, d]
			arr.sort (a,b) -> if b[0] == a[0] then b[1] - a[1] else b[0] - a[0]
			@tables = ([c,d] for [a,b,c,d] in arr)

		for p in playersByID
			if not p.active 
				p.opp.push PAUSE
				p.col += '_'
				p.res += '0'

		@tables = @makeOppColRes @tables

		for i in range playersByID.length
			echo @matrix i

		@sort()
		
		# echo 'playersByID',playersByID
		# for i in range playersByID.length
		# 	echo @matrix i

		currentPage.makeHTML()

		if tournament.round == tournament.rounds + 1
			filename = "#{@title}-Resultat-#{isoDate()}.txt"
			@downloadFile @makeTxt(), filename
			alert "Glöm inte ta en kopia på " + filename + " i Downloads (eller skriva ut) !"
		@downloadFile @makeTournament(), "#{@title}-R#{@round}-#{isoDate()}.txt"

		true

	fetchData : (filename, data) ->

		@filename = filename.replaceAll ".txt",""
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

		# Läs in parametrarna först
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

		@title = hash.TITLE
		@date = hash.DATE
		@type = hash.TYPE
		#echo @type
		@round = parseInt hash.ROUND
		@rounds = parseInt hash.ROUNDS
		@paused = hash.PAUSED # list of one based ids

		# Läs därefter in spelarna
		for line,nr in data
			line = line.trim()
			if line.length == 0 then continue
			arr = line.split ':'
			if arr.length == 1
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
					echo 'item',item
					if not /^-?\d+(w|b)[_0=1+-\?]$/.test item
						alert "#{item}\n in line #{nr+1}\n must follow the format <number> <color> <result>\n  where color is in wb\n  and result is in 0=1+-?"
						return
				hash.PLAYERS.push arr.slice 0, @round + 2
		@players = []
		players = hash.PLAYERS
		g.N = players.length

		if not (4 <= g.N < 100)
			alert "Number of players must be between 4 and 99!"
			return

		playersByID = []
		for i in range g.N
			player = new Player i
			# echo players[i]
			player.read players[i]
			playersByID.push player

		if @paused == ""
			@paused = []
		else
			for p in playersByID
				p.active = true
			@paused = @paused.split '!'
			for id in @paused
				if id != "" then playersByID[id-1].active = false

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
		
		for p in playersByID
			message = p.check()
			if message != "" then alert message

		#echo 'playersByID', playersByID 

		# extract @pairs from the last round
		@pairs = []
		for p in playersByID
			a = p.id
			b = _.last p.opp
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

		#echo '@pairs',@pairs

		# @dump 'fetch'
		
		@virgin = true

		alert "Efter varje lottning kan man ta en kopia på senaste filen i Downloads! (Alternativt mata in resultaten från bordslistorna)"

		true

	ok : (pa,pb) -> pa.id != pb.id and pa.id not in pb.opp and Math.abs(pa.balans() + pb.balans()) <= 2 # 1 riskerar tappa två ronder i slutet och ge större elodiffar.

	makeEdges_FAIRPAIR : (iBye) -> # iBye är ett id eller -1
		arr = []
		for pa in playersByScore
			# echo 'FAIRPAIR',pa
			a = pa.id
			if pa.active == false then continue
			if pa.candidate == true then continue
			for pb in playersByScore
				b = pb.id
				if a == b then continue
				if pb.active == false then continue
				if pb.candidate == true then continue
				diff = Math.abs pa.elo - pb.elo
				cost = 9999 - diff ** 1.01
				if a < b then continue
				if @ok pa,pb then arr.push [a,b, cost]

		arr.sort (a,b) -> b[2] - a[2] # cost
		#echo 'edges',arr
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
		if @type == 'Swiss' then diff = b.score() - a.score()
		if @type == 'FairPair' then diff = b.performance() - a.performance()
		if diff == 0 then b.elo - a.elo else diff

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

	# uppdaterar opp, col samt res+="_"
	makeOppColRes : (pairs, flag=false) ->
		bord = 0
		result = []
		#echo pairs

		for p in playersByID
			p.table = null

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

			@handleCol pa,pb, bord % 2 == 1

			pa.res += '_'
			pb.res += '_'

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

1825!JOHANSSON Lennart
1697!BJÖRKDAHL Göran
1684!SILINS Peteris
1681!STOLOV Leonid
1650!Christer Nilsson
1644!PETTERSSON Lars-Åke
1598!AIKIO Onni
1598!ISRAEL Dan
1583!PERSSON Kjell
1561!LILJESTRÖM Tor
1559!LEHVONEN Jouko
1539!ANDERSSON Lars Owe
1535!ÅBERG Lars-Erik
1532!ANTONSSON Görgen
1400!STRÖMBÄCK Henrik

"""

"""
PAUSED:1!2!3!4
1825!JOHANSSON Lennart  ! 8 b 1
1697!BJÖRKDAHL Göran    ! 9 w =
1684!SILINS Peteris     !10 w 0
1681!STOLOV Leonid      !11 b 1
1644!PETTERSSON Lars-Åke!12 b =
1598!AIKIO Onni         !13 w 0
1598!ISRAEL Dan         !14 w 1

1583!PERSSON Kjell      ! 1 w 0
1561!LILJESTRÖM Tor     ! 2 b =
1559!LEHVONEN Jouko     ! 3 b 1
1539!ANDERSSON Lars Owe ! 4 w 0
1535!ÅBERG Lars-Erik    ! 5 w =
1532!ANTONSSON Görgen   ! 6 b 1
1400!STRÖMBÄCK Henrik   ! 7 b 0
"""

pageStandings = new PageStandings()
pageTables = new PageTables()

tournament = new Tournament "demo", data
currentPage = pageStandings
currentPage.makeHeader()
currentPage.makeHTML()

currentPage.moveFocus 0

window.addEventListener 'keydown', (event) ->
	currentPage.handleKeyDown event
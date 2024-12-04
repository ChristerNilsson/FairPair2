import { g, range, print, scalex, scaley, assert, SEPARATOR } from './globals.js' 
import { parseExpr } from './parser.js'
import { Player } from './player.js'
import { Edmonds } from './blossom.js' 
import { Tables } from './page_tables.js' 
import { Names } from './page_names.js' 
import { Standings } from './page_standings.js' 
import { Active } from './page_active.js' 

KEYWORDS = {}
KEYWORDS.TITLE = 'text'
KEYWORDS.DATE = 'text'
KEYWORDS.ROUND = 'integer'
KEYWORDS.PAUSED = '!-separated integers'
KEYWORDS.TPP = 'integer (Tables Per Page, default: 30)'
KEYWORDS.PPP = 'integer (Players Per Page, default: 60)'

export class Tournament 
	constructor : ->
		@title = ''
		@round = 0
		@tpp = 30
		@ppp = 60

		# dessa tre listor pekar på samma objekt
		@players = []
		@playersByID = [] # sorterad på id
		@playersByELO = [] # sorterad på elo och name
		@pairs = [] # varierar med varje rond

		@robin = range g.N
		@mat = []
		@virgin = true
		@meetings = []

	write : ->
	
	makeEdges : (iBye) -> # iBye är ett id eller -1
		arr = []
		for pa in @playersByELO
			a = pa.id
			if not pa.active or a == iBye then continue
			for pb in @playersByELO
				b = pb.id
				if a == b then continue
				if not pb.active or b == iBye then continue
				diff = abs pa.elo - pb.elo
				cost = 9999 - diff ** g.EXPONENT
				if a < b then continue
				if g.ok pa,pb then arr.push [a,b, cost]
		arr.sort (a,b) -> b[2] - a[2] # cost
		arr

	findSolution : (edges) -> 
		edmonds = new Edmonds edges
		edmonds.maxWeightMatching edges

	assignColors : (p0,p1) ->
		b0 = p0.balans()
		b1 = p1.balans()
		if b0 < b1 then x = 0
		else if b0 > b1 then x = 1
		else if p0.id < p1.id then x = 0 else x = 1
		p0.col += 'wb'[x]
		p1.col += 'bw'[x]

	unscramble : (solution) -> # [5,3,4,1,2,0] => [[0,5],[1,3],[2,4]]
		solution = _.clone solution
		result = []
		for i in range solution.length
			if solution[i] != -1
				j = solution[i]
				result.push [i,j]
				solution[j] = -1
				solution[i] = -1
		result

	solutionCost : (pair) ->
		[a,b] = pair
		pa = @playersByID[a]
		pb = @playersByID[b]
		da = pa.elo
		db = pb.elo
		diff = Math.abs da - db
		diff ** g.EXPONENT
	
	solutionCosts : (pairs) -> g.sumNumbers (@solutionCost(pair) for pair in pairs)

	preMatch : -> # return id för spelaren som ska ha bye eller -1 om bye saknas

		for p in @playersByID
			if not p.active then p.res += '0'

		temp = _.filter @playersByELO, (p) -> p.active 
		if temp.length % 2 == 1 # Spelaren med lägst elo och som inte har haft frirond, får frironden
			temp = _.filter @playersByELO, (p) -> p.active and p.bye() == false
			pBye = _.last temp
			pBye.opp.push g.BYE
			pBye.col += '_'
			pBye.res += '2'
			return pBye.id
		g.BYE

	postMatch : ->
		for p in @playersByID
			if p.active then continue
			p.opp.push g.PAUSE
			p.col += '_'

		for [a,b] in @pairs
			pa = @playersByID[a]
			pb = @playersByID[b]
			pa.opp.push pb.id
			pb.opp.push pa.id

		if @round == 0
			for i in range @pairs.length
				[a,b] = @pairs[i]
				pa = @playersByID[a]
				pb = @playersByID[b]
				col1 = "bw"[i%2]
				col0 = g.other col1
				pa.col += col0
				pb.col += col1
				if i%2==1 then @pairs[i].reverse()
		else
			for i in range @pairs.length
				[a,b] = @pairs[i]
				pa = @playersByID[a]
				pb = @playersByID[b]
				@assignColors pa,pb
				if pa.col[@round]=='b' then @pairs[i].reverse()

		for [a,b],i in @pairs
			pa = @playersByID[a]
			pb = @playersByID[b]
			pa.chair = 2*i
			pb.chair = 2*i + 1

	downloadFile : (txt,filename) ->
		blob = new Blob [txt], { type: 'text/plain' }
		url = URL.createObjectURL blob
		a = document.createElement 'a'
		a.href = url
		a.download = filename
		document.body.appendChild a
		a.click()
		document.body.removeChild a
		URL.revokeObjectURL url

	lotta : ->

		if @round > 0 and g.calcMissing() > 0
			print 'lottning ej genomförd!'
			return

		@virgin = false
		@downloadFile @makeTournament(), "#{@filename}-R#{@round}.txt"

		print ""
		print "Lottning av rond #{@round} ====================================================="
		document.title = "Round #{@round+1}"

		arr = @makeEdges @preMatch() # -1 om bye saknas
		start = new Date()
		n = 1000000 # 1000 celler

		for end in range n, arr.length+n, n
			edges = arr.slice 0,end

			start = new Date()
			print 'edges',edges
			solution = @findSolution edges
			print 'cpu',end, (new Date() - start)

			print 'solution', -1 not in solution, solution
			# if solution.length == g.N and -1 not in solution then break # tag hänsyn till BYE och PAUSED senare
		# if not (solution.length == g.N and -1 not in solution)
		# 	alert 'Pairing impossible. Too many rounds or paused players'
		# 	return

		@pairs = @unscramble solution

		if @pairs.length < (@playersByID.length - @paused.length) // 2 
			print 'Pairing impossible'
			return 

		print 'pre pairs', @pairs

		@pairs.sort (a,b) => 
			aelo = @playersByID[a[0]].elo + @playersByID[a[1]].elo
			belo = @playersByID[b[0]].elo + @playersByID[b[1]].elo
			belo - aelo

		for a,b in @pairs
			@meetings.push "#{@playersByID[a[0]].elo} #{@playersByID[a[1]].elo}"
			@meetings.push "#{@playersByID[a[1]].elo} #{@playersByID[a[0]].elo}"

		if @round == 0 then print 'pairs', @pairs
		if @round > 0  then print 'pairs', ([a, b, @playersByID[a].elo, @playersByID[b].elo, Math.abs(@playersByID[a].elo - @playersByID[b].elo).toFixed(1)] for [a,b] in @pairs)
		print 'solutionCosts', @solutionCosts @pairs

		@postMatch()

		g.pages[g.NAMES].setLista()
		g.pages[g.TABLES].setLista()
		g.pages[g.STANDINGS].setLista()

		@downloadFile @meetings.join("\n"), "meetings-R#{@round}.txt"
		@downloadFile @makeStandardFile(), "#{@filename}-R#{@round}.prn"

		@round += 1
		print @makeMatrix 80 # skriver till debug-fönstret, time outar inte.

		g.state = g.TABLES

	dump : (title) ->
		print "##### #{title} #####"
		print 'TITLE',@title
		print 'DATE',@datum
		print 'ROUND',@round
		print 'TPP',@tpp
		print 'PPP',@ppp
		print 'PAUSED',@paused
		print '################'

	fetchData : (filename, data) ->
		randomSeed 99
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

		@playersByID = []
		for i in range g.N
			player = new Player i
			player.read players[i]
			@playersByID.push player

		if @paused == ""
			@paused = []
		else
			@paused = @paused.split '!'
			for id in @paused
				if id != "" then @playersByID[id].active = false

		g.average = 0
		for i in range g.N
			@playersByID[i].elo = parseInt @playersByID[i].elo
			g.average += @playersByID[i].elo
		g.average /= g.N
		console.log 'average',g.average

		@playersByID.sort (a,b) ->  
			if a.elo != b.elo then return b.elo - a.elo
			if a.name > b.name then 1 else -1

		for i in range g.N
			@playersByID[i].id = i
		
		@playersByELO = _.clone @playersByID

		print 'playersByELO', @playersByELO
		print 'playersByID', @playersByID 

		@playersByName = _.sortBy @playersByID, (player) -> player.name
		print 'playersByName', @playersByName

		# extract @pairs from the last round
		@pairs = []
		for p in @playersByID
			a = p.id
			b = _.last p.opp
			if a < b 
				pa = @playersByID[a]
				pb = @playersByID[b]
				@pairs.push if 'w' == _.last p.col
					pa.chair = 2 * @pairs.length
					pb.chair = 2 * @pairs.length + 1
					[a,b]
				else 
					pa.chair = 2 * @pairs.length + 1
					pb.chair = 2 * @pairs.length
					[b,a]

		print '@pairs',@pairs

		@dump 'fetch'
		
		@virgin = true

		g.pages = [new Tables, new Names, new Standings, new Active]

		g.pages[g.ACTIVE].setLista()
		g.pages[g.NAMES].setLista()
		g.pages[g.TABLES].setLista()
		g.pages[g.STANDINGS].setLista()

		g.state = g.ACTIVE

	makePaused : -> @paused.join SEPARATOR # (12!34)

	makePlayers : ->
		players = (p.write() for p in @playersByID)
		players.join "\n"

	makeTournament : () ->
		res = []
		res.push "ROUND=" + @round
		res.push "TITLE=" + @title
		res.push "DATE=" + @datum
		res.push "TPP=" + @tpp
		res.push "PPP=" + @ppp
		res.push "PAUSED=" + @makePaused()
		res.push ""
		res.push @makePlayers()
		res.join '\n'

	makeStandardFile : ->
		res = []
		header_after = " for " + @title + " after Round #{@round}"
		header_in    = " for " + @title + " in Round #{@round+1}"

		if @round < 999 then g.pages[g.STANDINGS].make res, header_after
		if @round >= 0  then g.pages[g.NAMES].make     res, header_in,@playersByName
		if @round < 999 then g.pages[g.TABLES].make    res, header_in

		res.join "\n"	

	distans : (rounds) ->
		print rounds
		if rounds.length == 0 then return "0"
		result = []
		for i in range rounds.length
			for [a,b] in rounds[i]
				if b==undefined then continue
				if a < 0 or b < 0 then continue
				pa = @playersByID[a]
				pb = @playersByID[b]
				# if pa.active and pb.active 
				result.push abs(pa.elo - pb.elo) 
		(g.sum(result)/result.length).toFixed 2

	makeCanvas : (n) ->
		result = []
		for i in range n
			line = new Array n
			_.fill line, '·'
			line[i] = '*'
			result.push line
		result

	dumpCanvas : (title,average,canvas,n) ->
		output = []
		if title != "" then output.push title
		header = (str((i + 1) % 10) for i in range n).join(' ')
		output.push '     ' + header
		ordning = (p.elo for p in @playersByELO)
		total = 0
		for i in range canvas.length
			row = canvas[i]
			nr = str(i + 1).padStart(3)
			subTotal = @playersByELO[i].eloDiffAbs()
			total += subTotal
			output.push "#{nr}  #{(str(item) for item in row).join(" ")}  #{ordning[i]} #{subTotal.toFixed(0).padStart(6)}"
		output.push '     ' + header + ' ' + total.toFixed(0).padStart(12)
		output.join '\n'

	drawMatrix : (title,rounds,n) ->
		canvas = @makeCanvas n
		for i in range rounds.length
			for [a,b] in rounds[i]
				if a == undefined then continue
				if b == undefined then continue
				inside = 0 <= a < n and 0 <= b < n
				if not inside then continue
				canvas[a][b] = g.ALFABET[i]
				canvas[b][a] = g.ALFABET[i]
		@dumpCanvas title,@distans(rounds),canvas,n

	makeMatrix : (n) ->
		if n > g.N then n = g.N
		inv = g.invert (p.id for p in @playersByELO)
		matrix = (([inv[p.id],inv[p.opp[r]]] for p in @playersByELO) for r in range @round)
		print 'matrix',matrix
		@drawMatrix @title, matrix, n

	makeBubbles : ->
		res = []
		for pa in @playersByID
			for r in range @round
				if pa.opp[r] >= 0 
					pb = @playersByID[pa.opp[r]]
					res.push "#{pa.elo}\t#{pb.elo}"
		res.join '\n'

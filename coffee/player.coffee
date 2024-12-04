import { g,print,range,scalex,scaley,SEPARATOR } from './globals.js' 

export class Player
	constructor : (@id, @name="", @elo="1400", @opp=[], @col="", @res="", @active = true) -> @pos = []

	toggle : -> 
		@active = not @active
		g.tournament.paused = (p.id for p in g.tournament.playersByID when not p.active)

	bye : -> g.BYE in @opp

	explanation : (r) ->
		if @opp[r] == g.BYE   then return ""
		if @opp[r] == g.PAUSE then return ""
		res = ['Loss','Draw','Win'][@res[r]]
		opp = g.tournament.playersByID[@opp[r]]
		col = if @col[r]=='w' then 'white' else 'black'
		"#{res} against #{opp.elo} #{opp.name} as #{col}"

	expected_score : (ratings, own_rating) ->
		g.sum(1 / (1 + 10**((rating - own_rating) / 400)) for rating in ratings)   

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
		score = 0
		ratings = []
		for r in range @res.length
			if @opp[r] == g.BYE then continue
			if @opp[r] == g.PAUSE then continue
			score += @res[r]/2
			ratings.push g.tournament.playersByID[@opp[r]].elo
		@performance_rating ratings,score

	enhanced_performance : ->
		score = 0 
		ratings = []
		for r in range @res.length
			if @opp[r] == g.BYE then continue
			if @opp[r] == g.PAUSE then continue
			score += @res[r]/2
			ratings.push g.tournament.playersByID[@opp[r]].elo
		score += 0.5 # fiktiv remi
		ratings.push g.average # global average opponent elo
		@performance_rating ratings,score

	change : (rounds) -> @enhanced_performance()
	score : (rounds) -> g.sum (parseInt @res[r] for r in range rounds-1)

	eloDiffAbs : ->
		res = []
		for id in @opp.slice 0, @opp.length # - 1
			if id >= 0 then res.push abs @elo - g.tournament.playersByID[id].elo
		g.sum res

	balans : -> # färgbalans
		result = 0
		for ch in @col
			if ch=='b' then result -= 1
			if ch=='w' then result += 1
		result

	read : (player) -> 
		@elo = parseInt player[0]
		@name = player[1]
		@opp = []
		@col = ""
		@res = ""
		if player.length < 3 then return
		ocrs = player.slice 2
		for ocr in ocrs
			if 'w' in ocr then col='w'
			if 'b' in ocr then col='b'
			if '_' in ocr then col='_'
			arr = ocr.split col
			@opp.push parseInt arr[0]
			@col += col
			if arr.length == 2 and arr[1].length == 1 then @res += arr[1]

	write : -> # 1234!Christer!12w0!23b1!14w2   Elo:1234 Name:Christer opponent:23 color:b result:1
		res = []
		res.push @elo
		res.push @name		
		r = @opp.length
		if r == 0 then return res.join SEPARATOR
		ocr = ("#{@opp[i]}#{@col[i]}#{if i < r then @res[i] else ''}" for i in range r)
		res.push ocr.join SEPARATOR
		res.join SEPARATOR

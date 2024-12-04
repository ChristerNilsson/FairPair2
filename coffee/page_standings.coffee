import { g,print,range,scalex,scaley } from './globals.js' 
import { Page } from './page.js' 
import { Button,spread } from './button.js'  
import { Lista } from './lista.js' 

export class Standings extends Page

	constructor : ->
		super()
		@t = g.tournament
		@buttons.ArrowLeft  = new Button '', '', () => g.setState g.ACTIVE
		@buttons.ArrowRight = new Button '', '', () => g.setState g.TABLES
		@buttons.s.active = false

	setLista : ->

		rheader = _.map range(1,@t.round+1), (i) -> " #{i%10} "
		rheader = rheader.join ''
		header = ""
		header +=       g.txtT "Pos",          3, RIGHT
		header += ' ' + g.txtT "Id",           3, RIGHT
		header += ' ' + g.txtT "Elo",          4, RIGHT
		header += ' ' + g.txtT "Name",        25, LEFT
		header += ''  + g.txtT rheader, 3*@round, LEFT
		header += ' ' + g.txtT "EPR",          7, RIGHT
		header += ' ' + g.txtT "PP",           7, RIGHT

		@playersByPerformance = _.clone @t.playersByID.slice 0,g.N
		@playersByPerformance = @playersByPerformance.sort (a,b) => b.enhanced_performance() - a.enhanced_performance()

		# array = (p.performance().toFixed(1) for p in @playersByPerformance)
		# dubletter = _.uniq(_.filter(array, (value, index, array) => _.indexOf(array, value) != _.lastIndexOf(array, value)));

		@lista = new Lista @playersByPerformance, header, @buttons, (p,index,pos) => # returnera strängen som ska skrivas ut. Dessutom ritas lightbulbs här.
			@y_bulb = (5 + index) * g.ZOOM[g.state] 
			textAlign LEFT
			fill 'black' 
			s = ""
			s +=       g.txtT (1+pos).toString(),     3,  RIGHT
			s += ' ' + g.txtT (1+p.id).toString(),    3,  RIGHT
			s += ' ' + g.txtT p.elo.toString(),       4,  RIGHT
			s += ' ' + g.txtT p.name,                25,  LEFT
			s += ' ' + g.txtT '',      3 * (@t.round-1),  CENTER
			s += ' ' + g.txtT p.enhanced_performance().toFixed(1),8,RIGHT
			s += ' ' + g.txtT (p.score(@t.round)/2).toFixed(1),6,RIGHT

			for r in range g.tournament.round - 1 #- 1
				x = g.ZOOM[g.state] * (24.2 + 1.8*r)
				@lightbulb p.id, p.col[r], x, @y_bulb, p.res.slice(r,r+1), p.opp[r]
			s
		@lista.paintYellowRow = false
		spread @buttons, 10, @y, @h

	# mouseMoved : =>
	# 	r = round ((mouseX / g.ZOOM[g.state] - 24.2) / 1.8)
	# 	iy = @lista.offset + round mouseY / g.ZOOM[g.state] - 5
	# 	if 0 <= iy < @playersByPerformance.length and 0 <= r < g.tournament.round - 1
	# 		pa = @playersByPerformance[iy]
	# 		b = pa.opp[r]

	# 		if b == g.BYE 
	# 			s = ""
	# 			s +=       g.txtT '',                      3,  RIGHT
	# 			s += ' ' + g.txtT '',                      3,  RIGHT
	# 			s += ' ' + g.txtT '',                      4,  RIGHT
	# 			s += ' ' + g.txtT 'has a bye',            25,  LEFT
	# 			s += ' ' + g.txtT '',       3 * (@t.round-1),  LEFT
	# 			s += ' ' + g.txtT "#{pa.elo.toFixed(1)}",        7, RIGHT
	# 			g.help = s

	# 		if b == g.PAUSE
	# 			s = ""
	# 			s +=       g.txtT '',                      3,  RIGHT
	# 			s += ' ' + g.txtT '',                      3,  RIGHT
	# 			s += ' ' + g.txtT '',                      4,  RIGHT
	# 			s += ' ' + g.txtT 'has a pause',          25,  LEFT
	# 			s += ' ' + g.txtT '',       3 * (@t.round-1),  LEFT
	# 			s += ' ' + g.txtT "0.0",                         7, RIGHT
	# 			g.help = s

	# 		if b >= 0				
	# 			pb = @t.playersByID[b]
	# 			chg = 1234 #pa.calcRound r

	# 			s = ""
	# 			s +=       g.txtT '',                      3,  RIGHT
	# 			s += ' ' + g.txtT (1+pb.id).toString(),    3,  RIGHT
	# 			s += ' ' + g.txtT pb.elo.toString(),       4,  RIGHT
	# 			s += ' ' + g.txtT pb.name,                25,  LEFT
	# 			s += ' ' + g.txtT '',       3 * (@t.round-1),  LEFT
	# 			s += ' ' + g.txtT chg.toFixed(1), 7,  RIGHT
	# 			if pa.res[r] == '1' then s += " = 0.5 * (#{g.txtT pb.elo, 7, RIGHT})"
	# 			if pa.res[r] == '2' then s += " = #{g.txtT pb.elo, 7, RIGHT}"
					
	# 			g.help = pa.explanation r
	# 	else
	# 		g.help = ""

	mouseWheel   : (event )-> @lista.mouseWheel event
	mousePressed : (event) -> @lista.mousePressed event
	keyPressed   : (event) -> @buttons[key].click()

	draw : ->
		fill 'white'
		@showHeader @t.round-1
		@lista.draw()
		for key,button of @buttons
			button.draw()
		textAlign LEFT
		text g.help, 10, 3*g.ZOOM[g.state]

	show : (s,x,y,bg,fg) ->
		# fill bg
		# rect x, y, 1.6 * g.ZOOM[g.state], 0.9 * g.ZOOM[g.state]
		# fill fg
		@txt s, x, y+1,  CENTER

	lightbulb : (id, color, x, y, result, opponent) ->
		push()
		rectMode  CENTER
		s = 1 + opponent
		if opponent == g.PAUSE then @show " P ",x,y,"gray",'yellow'
		if opponent == g.BYE   then @show "BYE",x,y,"green",'yellow'
		if opponent >= 0
			result = '012'.indexOf result
			@show 1+opponent, x, y, 'red gray green'.split(' ')[result], {b:'black', ' ':'yellow', w:'white'}[color]
		pop()

	make : (res,header) ->
		if @t.pairs.length == 0 then res.push "This ROUND can't be paired! (Too many rounds)"

		res.push "STANDINGS" + header
		res.push ""

		header = ""
		header +=       g.txtT "Pos",   3,  RIGHT
		header += ' ' + g.txtT 'Id',    3,  RIGHT
		header += ' ' + g.txtT "Elo",   4,  RIGHT
		header += ' ' + g.txtT "Name", 25,  LEFT
		for r in range @t.round
			header += g.txtT "#{r+1}",  6, RIGHT
		header += ' ' + g.txtT "EPR",   7, RIGHT
		header += ' ' + g.txtT "PP",    7, RIGHT
		header += ' ' + g.txtT " ELOS",  7, LEFT
		
		for player,i in @playersByPerformance
			if i % @t.ppp == 0 then res.push header
			s = ""
			s +=       g.txtT (1+i).toString(),          3,  RIGHT
			s += ' ' + g.txtT (1+player.id).toString(),  3,  RIGHT
			s += ' ' + g.txtT player.elo.toString(),     4,  RIGHT
			s += ' ' + g.txtT player.name,              25,  LEFT
			s += ' '
			for r in range @t.round
				if player.opp[r] == -2 then s += '    P '
				if player.opp[r] == -1 then s += '   BYE'
				if player.opp[r] >= 0
					s += g.txtT "#{1+player.opp[r]}#{g.RINGS[player.col[r][0]]}#{"0½1"[player.res[r]]}", 6,  RIGHT

			p = player
			s += ' ' + g.txtT p.enhanced_performance().toFixed(1), 8, RIGHT
			s += ' ' + g.txtT (p.score(@t.round+1)/2).toFixed(1), 6, RIGHT

			for r in range @t.round
				id = p.opp[r]
				s += " " + @t.playersByID[id].elo
			s += " " + g.average.toFixed 0
			res.push s 
			if i % @t.ppp == @t.ppp-1 then res.push "\f"
		res.push "\f"
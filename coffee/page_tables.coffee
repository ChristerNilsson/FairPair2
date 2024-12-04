import { g,print,range,scalex,scaley } from './globals.js' 
import { Page } from './page.js' 
import { Button,spread } from './button.js'  
import { Lista } from './lista.js' 

compare = (pa,pb) ->
	a = pa.name[0]
	b = pb.name[0]
	if a > b  then return 0
	if a == b then return 1
	if a < b  then return 2

export class Tables extends Page

	constructor : ->
		super()

		@buttons.ArrowLeft  = new Button '', '', () => g.setState g.STANDINGS
		@buttons.ArrowRight = new Button '', '', () => g.setState g.NAMES

		@buttons.p      = new Button 'Pair',   'P = Perform pairing now',() => @t.lotta()
		@buttons.K0     = new Button '0',      '0 = White Loss',         () => @handleResult '0'
		@buttons[' ']   = new Button '½',      'space = Draw',           () => @handleResult ' '
		@buttons.K1     = new Button '1',      '1 = White Win',          () => @handleResult '1'
		@buttons.Delete = new Button 'Delete', 'delete = Remove result', () => @handleDelete()
		@buttons.r      = new Button 'Random', 'R = Random results',     () => @randomResult()

		@buttons.t.active = false

	setLista : =>
		# print 'Lista', g.tournament.pairs.length
		header = ""
		header +=       g.txtT 'Tbl',    3, RIGHT
		header += ' ' + g.txtT 'Elo',    4, RIGHT
		header += ' ' + g.txtT 'White', 25, LEFT
		header += ' ' + g.txtT 'Result', 7, CENTER
		header += ' ' + g.txtT 'Black', 25, LEFT
		header += ' ' + g.txtT 'Elo',    4, RIGHT

		@lista = new Lista @t.pairs, header, @buttons, (pair,index,pos) =>
			[a,b] = pair
			pa = @t.playersByID[a]
			pb = @t.playersByID[b]
			both = if pa.res.length == pa.col.length then g.prBoth _.last(pa.res) else "   -   "

			nr = index + 1
			s = ""
			s +=       g.txtT (pos+1).toString(), 3,  RIGHT
			s += ' ' + g.txtT pa.elo.toString(),  4,  RIGHT
			s += ' ' + g.txtT pa.name,           25,  LEFT
			s += ' ' + g.txtT both,               7,  CENTER
			s += ' ' + g.txtT pb.name,           25,  LEFT
			s += ' ' + g.txtT pb.elo.toString(),  4,  RIGHT
			s

		@lista.errors = []
		spread @buttons, 10, @y, @h
		@setActive()

	mouseWheel   : (event )-> @lista.mouseWheel event
	mousePressed : (event) -> @lista.mousePressed event
	keyPressed   : (event,key) -> @buttons[key].click()

	draw : ->
		fill 'white'
		@showHeader @t.round
		for key,button of @buttons
			button.draw()
		@lista.draw()

	elo_probabilities : (diff) ->
		if random() < 0.1 then return 1 # draw
		if random() > g.F diff then 0 else 2
	
	setActive : ->
		@buttons.p.active = g.calcMissing() == 0
		if g.pages[g.ACTIVE] then g.pages[g.ACTIVE].buttons.p.active = @buttons.p.active

	handleResult : (key) =>
		[a,b] = @t.pairs[@lista.currentRow]
		pa = @t.playersByID[a]
		pb = @t.playersByID[b]
		index = '0 1'.indexOf key
		ch = "012"[index]
		if pa.res.length == pa.col.length 
			if ch != _.last pa.res then @lista.errors.push @lista.currentRow
		else
			if pa.res.length < pa.col.length then pa.res += "012"[index]
			if pb.res.length < pb.col.length then pb.res += "210"[index]
		@lista.currentRow = (@lista.currentRow + 1) %% @t.pairs.length
		@setActive()

	randomResult : ->
		for [a,b] in @t.pairs
			pa = @t.playersByID[a]
			pb = @t.playersByID[b]
			res = @elo_probabilities pa.elo - pb.elo
			if pa.res.length < pa.col.length 
				pa.res += res
				pb.res += 2 - res
		@setActive()

	handleDelete : ->
		i = @lista.currentRow
		[a,b] = @t.pairs[i]
		pa = @t.playersByID[a]
		pb = @t.playersByID[b]
		@lista.errors = (e for e in @lista.errors when e != i)
		if pa.res.length == pb.res.length
			[a,b] = @t.pairs[i]
			pa = @t.playersByID[a]
			pb = @t.playersByID[b]
			pa.res = pa.res.substring 0,pa.res.length-1
			pb.res = pb.res.substring 0,pb.res.length-1
		@lista.currentRow = (@lista.currentRow + 1) %% @t.pairs.length
		@setActive()

	make : (res,header) ->
		res.push "TABLES" + header
		res.push ""
		for i in range @t.pairs.length
			[a,b] = @t.pairs[i]
			if i % @t.tpp == 0 then res.push "Table      #{g.RINGS.w}".padEnd(25) + _.pad("",28+10) + "#{g.RINGS.b}" #.padEnd(25)
			pa = @t.playersByID[a]
			pb = @t.playersByID[b]
			res.push ""
			res.push _.pad(i+1,6) + pa.elo + ' ' + g.txtT(pa.name, 25,  LEFT) + ' ' + _.pad("|____| - |____|",20) + ' ' + pb.elo + ' ' + g.txtT(pb.name, 25,  LEFT)
			if i % @t.tpp == @t.tpp-1 then res.push "\f"
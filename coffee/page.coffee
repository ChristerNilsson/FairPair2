import { g,print,range,scalex,scaley } from './globals.js' 
import { Button,spread } from './button.js' 
import { Lista } from './lista.js' 

export class Page
 
	constructor : ->

		@HELP = "A = Active"
		@buttons = {}

		@buttons.s = new Button 'Standings', 'S = Standings', () => g.setState g.STANDINGS
		@buttons.t = new Button 'Tables',    'T = Tables',    () => g.setState g.TABLES
		@buttons.n = new Button 'Names',     'N = Names',     () => g.setState g.NAMES
		@buttons.a = new Button 'Active',    'A = Active',    () => g.setState g.ACTIVE

		@buttons.ArrowUp = new Button '', '', () => @lista.ArrowUp()
		@buttons.ArrowDown = new Button '','', () => @lista.ArrowDown()

		@buttons.PageUp = new Button '', '', () => @lista.PageUp()
		@buttons.PageDown = new Button '','', () => @lista.PageDown()

		@buttons.Home = new Button '', '', () => @lista.Home()
		@buttons.End = new Button '','', () => @lista.End()

		@buttons.i = new Button 'In', 'I = zoom In', () => g.zoomIn g.N//2
		@buttons.o = new Button 'Out', 'O = zoom Out', () => g.zoomOut g.N//2

		@t = g.tournament
		@y = 1.3
		@h = 1
		@lista = new Lista

	mouseMoved : ->

	showHeader : (round) ->
		y = 0.6
		textAlign LEFT,CENTER
		s = ''
		s += g.txtT "#{@t.title} #{@t.datum}", 30, LEFT
		s += g.txtT "#{g.message}", 30, CENTER
		s += g.txtT "#{@t.round}", 24, CENTER
		text s,10,scaley(y)

	txt : (value, x, y, align=null, color=null) ->
		push()
		if align then textAlign align, CENTER
		if color then fill color
		text value,x,y
		pop()
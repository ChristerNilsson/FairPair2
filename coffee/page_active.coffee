import { g,print,range,scalex,scaley } from './globals.js' 
import { Page } from './page.js' 
import { Button,spread } from './button.js' 
import { Lista } from './lista.js' 

export class Active extends Page 

	constructor : ->
		super()

		@buttons.ArrowLeft  = new Button '', '', () => g.setState g.NAMES
		@buttons.ArrowRight = new Button '', '', () => g.setState g.STANDINGS
		@buttons.p          = new Button 'Pair','P = Perform pairing now', () => 
			@buttons.t.active = true
			@buttons.n.active = true
			@buttons.s.active = true
			@t.lotta()
		@buttons[' ']       = new Button 'toggle', 'space = pause/activate', 
			() => @t.playersByName[g.pages[g.state].lista.currentRow].toggle()

		@buttons.a.active = false
		@buttons.a.help = @HELP
		@setLista()

	setLista : ->
		@lista = new Lista @t.playersByName, "Pause Name", @buttons, (p) ->
			s = if p.active then '      ' else 'pause '
			s + g.txtT p.name, 25,  LEFT
		spread @buttons, 10, @y, @h
		if g.tournament.virgin #round == 0
			@buttons.t.active = false
			@buttons.n.active = false
			@buttons.s.active = false

	draw : ->
		fill 'white'
		@showHeader @t.round
		@lista.draw()
		for key,button of @buttons
			button.draw()

	mouseWheel : (event )-> @lista.mouseWheel event
	mousePressed : (event) -> @lista.mousePressed event
	keyPressed : (event) -> if @buttons[key].active or key in ['p',' '] then @buttons[key].click()
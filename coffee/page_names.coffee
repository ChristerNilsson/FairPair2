import { g,print,range,scalex,scaley } from './globals.js' 
import { Page } from './page.js' 
import { Button,spread } from './button.js' 
import { Lista } from './lista.js'  

export class Names extends Page

	constructor : ->
		super()
		@buttons.n.active = false
		@buttons.ArrowLeft  = new Button '', '', () => g.setState g.TABLES
		@buttons.ArrowRight = new Button '', '', () => g.setState g.ACTIVE

	setLista : ->
		@lista = new Lista @t.playersByName, "Table Name", @buttons, (p) =>
			r = @t.round - 1
			if p.active and g.BYE != _.last p.opp
				s = "#{str(1 + p.chair // 2).padStart(3)} #{g.RINGS[p.col[r][0]]} "
			else if not p.active
				s = "   P  "
			else 
				s = "  BYE "
			s + g.txtT p.name, 25,  LEFT
		spread @buttons, 10, @y, @h

	mouseWheel   : (event )-> @lista.mouseWheel event
	mousePressed : (event) -> @lista.mousePressed event
	keyPressed   : (event) -> @buttons[key].click()

	make : (res,header,playersByName) ->
		res.push "NAMES" + header
		res.push ""
		r = @t.round
		for player,i in playersByName
			if i % @t.ppp == 0 then res.push "Table Name"
			if player.active and g.BYE != player.opp[r]
				res.push "#{str(1 + player.chair // 2).padStart(3)} #{g.RINGS[player.col[r][0]]} #{player.name}"
			else if not player.active
				res.push "   P  #{player.name}"
			else 
				res.push "  BYE #{player.name}"
			if i % @t.ppp == @t.ppp-1 then res.push "\f"
		res.push "\f"

	draw : ->
		fill 'white'
		@showHeader @t.round
		@lista.draw()
		for key,button of @buttons
			button.draw()
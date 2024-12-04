import { g,print,range,scalex,scaley } from './globals.js' 

export class Button
	constructor : (@title, @help, @click) -> 
		@active = true
		@t = g.tournament

	draw : ->
		textAlign CENTER,CENTER
		if @title == '' then return

		fill if @active then 'yellow' else 'lightgray'
		rect scalex(@x),scaley(@y),scalex(@w),scaley(@h)

		fill 'black'
		text @title,scalex(@x+@w/2),scaley(@y+@h/2)
		textAlign LEFT,CENTER
		if @inside mouseX,mouseY
			text @help,10,scaley(@y+3.2*@h/2)
		else if mouseY < 20
			if @title == 'In' then text "Missing results=#{g.calcMissing()} Players=#{g.N} Paused=#{@t.paused.length}",10,scaley(@y+3.2*@h/2) # else painted many times

	inside : (x,y) -> scalex(@x) <= x <= scalex(@x + @w) and scaley(@y) <= y <= scaley(@y + @h)

export spread = (buttons, letterWidth, y, h) ->
	x = letterWidth
	for key,button of buttons
		button.x = x
		button.y = y
		button.w = (button.title.length + 2) * letterWidth
		button.h = h
		if button.title.length > 0 or key == "ArrowUp" then x += button.w + letterWidth

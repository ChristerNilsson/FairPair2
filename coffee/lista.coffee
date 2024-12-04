import { g,print,range,scalex,scaley } from './globals.js' 

export class Lista
	constructor : (@objects=[], @columnTitles="", @buttons={}, @drawFunction=null) -> # a list of players. Or a list of pairs of players
		@N = @objects.length
		@paintYellowRow = true
		@errors = [] # list with index of erroneous rows
		@currentRow = 0
		@offset = 0
		@adjustOffset 0

	draw : -> # ritar de rader som syns i fönstret enbart
		s = @columnTitles
		fill 'white'
		textAlign  LEFT
		text s,10,scaley(4)

		fill 'black'
		for i in range g.LPP # i inom fönstret
			iRow = @offset + i # index till listan
			if iRow >= @N then continue
			p = @objects[iRow]
			s = @drawFunction p, i, iRow
			if iRow == @currentRow
				fill 'yellow'
				w = if @paintYellowRow then width else scaley(23.4)
				rect 0, scaley(i + 4.5), w, scaley(1)
				fill 'black'
			fill if iRow in @errors then 'red' else 'black'
			text s,10, scaley(i + 5)

	keyPressed : (event, key) -> @buttons[key].click()
	mouseWheel : (event) -> @adjustOffset if event.delta < 0 then -1 else 1
	mousePressed : -> 
		if mouseY < scaley(4)
			for key,button of @buttons
				if button.active and button.inside mouseX,mouseY then button.click()
		else
			@adjustOffset round mouseY / g.ZOOM[g.state] - 5 - @currentRow + @offset

	adjustOffset : (delta) ->
		if 0 <= @currentRow + delta < @N then @currentRow += delta
		if @currentRow < @offset then @offset = @currentRow
		else 
			if @currentRow >= @offset + g.LPP then @offset = @currentRow - g.LPP + 1

	ArrowUp   : -> if @currentRow > 0      then @adjustOffset -1
	ArrowDown : -> if @currentRow < @N - 1 then @adjustOffset +1
	PageUp    : -> if @currentRow > 0      then @adjustOffset(Math.max(@currentRow - g.LPP, 0) - @currentRow )
	PageDown  : -> if @currentRow < @N - 1 then @adjustOffset(Math.min(@currentRow + g.LPP, @N - 1) - @currentRow)
	Home      : -> @adjustOffset 0 - @currentRow
	End       : -> @adjustOffset @N-1 - @currentRow

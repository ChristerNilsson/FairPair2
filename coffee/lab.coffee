echo = console.log 

cells = []
currCell = null

players = []

add = (elo,name) -> 
	id = players.length
	players.push {id, name, elo}

add 1825,"JOHANSSON Lennart"
add 1697,"BJÖRKDAHL Göran"
add 1684,"SILINS Peteris"
add 1681,"STOLOV Leonid"
add 1644,"PETTERSSON Lars-Åke"
add 1583,"PERSSON Kjell"
add 1598,"AIKIO Onni"
add 1598,"ISRAEL Dan"
add 1561,"LILJESTRÖM Tor"
add 1559,"LEHVONEN Jouko"
add 1539,"ANDERSSON Lars Owe"
add 1535,"ÅBERG Lars-Erik"
add 1532,"ANTONSSON Görgen"
add 1400,"STRÖMBÄCK Henrik"

tables = [[1,0],[3,2],[5,4],[7,6],[9,8],[11,10],[13,12]]

formatScore = -> if currCell then currCell.dataset.white.padEnd(2) + ' - ' + currCell.dataset.black.padStart(2) else "-"

tableBody = document.getElementById "table-body"

for i in [0...tables.length]
	[w,b] = tables[i]
	row = document.createElement "tr"

	nr = document.createElement "td"
	nr.style.textAlign = "center"
	nr.textContent = i+1
	row.appendChild nr

	white = document.createElement "td"
	white.textContent = players[w].name
	white.dataset.value = w
	row.appendChild white

	score = document.createElement "td"
	score.style.textAlign = "center"
	score.setAttribute "tabindex", "0"
	score.setAttribute "width", "90px"
	score.dataset.white = ""
	score.dataset.black = ""
	score.textContent = formatScore()
	row.appendChild score

	black = document.createElement "td"
	black.textContent = players[b].name
	black.dataset.value = b
	row.appendChild black

	diff = document.createElement "td"
	diff.style.textAlign = "right"
	diff.textContent = players[w].elo - players[b].elo
	row.appendChild diff

	tableBody.appendChild row

cells = document.querySelectorAll "[tabindex]"

goto = (index) ->
	currCell = cells[index %% cells.length]
	currCell.focus()

inverse = (key) -> {'0':'1', '½':'½', '1':'0'}[key]

cells.forEach (cell, index) =>
	cell.addEventListener "focus", => 
		cell.style.backgroundColor = 'yellow'
		currCell = cell

	cell.addEventListener "blur", => cell.style.backgroundColor = "white"

	cell.addEventListener "keydown", (event) =>
		if event.key == '0' then key = '0'
		if event.key == '1' then key = '1'
		if event.key == 'r' then key = '½'
		if event.key == ' ' then key = '½'

		if key in '0½1'
			n = currCell.dataset.white.length
			if n==0 or n==2
				currCell.dataset.white = key
				currCell.dataset.black = inverse key
				currCell.textContent = formatScore()
			else # n==1
				currCell.dataset.white += key
				currCell.dataset.black += inverse key
				currCell.textContent = formatScore()
				goto index + 1

		if event.key == "Delete"
			currCell.dataset.white = ""
			currCell.dataset.black = ""
			currCell.textContent = '-'
			goto index + 1

		if event.key == "Home"      then goto 0
		if event.key == "End"       then goto cells.length-1
		if event.key == "ArrowDown" then goto index + 1
		if event.key == "ArrowUp"   then goto index - 1

goto 0
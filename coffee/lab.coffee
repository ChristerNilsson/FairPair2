tableBody = document.getElementById "table-body"

for i in [0...16]
	row = document.createElement "tr"
	cell = document.createElement "td"
	randomNum = Math.floor Math.random() * 10)
	cell.setAttribute "tabindex", "0"
	cell.dataset.value = randomNum
	cell.textContent = randomNum
	row.appendChild cell
	tableBody.appendChild row

cells = document.querySelectorAll "td"

cells.forEach (cell, index) => # Lägg till fokuslogik för varje cell
	cell.addEventListener "focus", =>
		value = parseInt cell.dataset.value, 10 # Hämta lagrat värde
		cell.style.backgroundColor = if value % 2 == 0 then "lightblue" else "lightcoral"

	cell.addEventListener "blur",  => cell.style.backgroundColor = "" # Återställ färg

	cell.addEventListener "keydown", (event) => # Wrappa med tangentbordsnavigation
		if event.key == "ArrowDown"
			event.preventDefault()
			nextindex = (index + 1) %% cells.length # Nästa med wrapping
			cells[nextindex].focus()
		else if event.key == "ArrowUp"
			event.preventDefault()
			nextindex = (index - 1) %% cells.length # Föregående med wrapping
			cells[nextindex].focus()

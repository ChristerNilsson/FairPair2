import { parseExpr } from './parser.js'
import { g,print,range } from './globals.js' 
import { Button,spread } from './button.js' 
import { Lista } from './lista.js' 
import { Tournament } from './tournament.js' 
import { Tables } from './page_tables.js' 
import { Names } from './page_names.js' 
import { Standings } from './page_standings.js' 
import { Active } from './page_active.js' 

export handleFile = (filename,data) -> g.tournament.fetchData filename,data	

g.RINGS = {'b':'b', ' ':' ', 'w':'w'}
g.ASCII = '0123456789abcdefg'
g.ALFABET = '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' # 62 ronder maximalt

datum = ''

g.tournament = null
g.errors = [] # id för motsägelsefulla resultat. Tas bort med Delete
g.pages = []
 
data = """
TITLE=Senior Stockholm
DATE=2024-05-28

1598!AIKIO Onni
1539!ANDERSSON Lars Owe
1532!ANTONSSON Görgen
1697!BJÖRKDAHL Göran
1598!ISRAEL Dan
1825!JOHANSSON Lennart
1559!LEHVONEN Jouko
1561!LILJESTRÖM Tor
1583!PERSSON Kjell
1644!PETTERSSON Lars-Åke
1684!SILINS Peteris
1681!STOLOV Leonid
1400!STRÖMBÄCK Henrik
1535!ÅBERG Lars-Erik
"""

window.windowResized = -> 
	resizeCanvas windowWidth, windowHeight - 4
	g.LPP = Math.trunc height / g.ZOOM[g.state] - 4.5
	xdraw()

window.setup = ->
	createCanvas windowWidth-4,windowHeight-4
	textFont 'Courier New'
	# textAlign window.LEFT,window.TOP
	textAlign CENTER,CENTER
	rectMode window.CORNER
	noStroke()

	g.ZOOM = [20,20,20,20] # vertical line distance for four states
	g.state = g.TABLES
	g.LPP = Math.trunc height / g.ZOOM[g.state] - 4.5

	g.N = 0 # number of players
	g.tournament = new Tournament()
	g.state = g.ACTIVE

	g.pages = [new Tables, new Names, new Standings, new Active]
	print g.pages

	# print data
	g.tournament.fetchData "DEMO",data

	window.windowResized()

xdraw = -> 
	background 'gray'
	textSize g.ZOOM[g.state]
	g.pages[g.state].draw()

window.mouseMoved = (event) -> 
	g.pages[g.state].mouseMoved event
	xdraw()

window.mousePressed = (event) -> 
	g.pages[g.state].mousePressed event
	xdraw()

window.mouseWheel = (event) -> 
	g.pages[g.state].mouseWheel event
	xdraw()

window.keyPressed   = (event) -> 
	key2 = key
	if key2 in ['Control','Shift','I'] then return
	if key2 == '1' then key2 = 'K1'
	if key2 == '0' then key2 = 'K0'
	g.pages[g.state].keyPressed event,key2
	xdraw()

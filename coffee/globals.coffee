# import { Tournament } from './tournament.js' 
import { Tables } from './page_tables.js' 
import { Names } from './page_names.js' 
import { Standings } from './page_standings.js' 
import { Active } from './page_active.js' 

export g = {}

###########################################

g.EXPONENT = 1.01 # 1 or 1.01 (or 2)
g.COLORS = 2 # 2 ej tillåtet, då kan www eller bbb uppstå.

###########################################

export print = console.log
export range = _.range
export scalex = (x) -> x * g.ZOOM[g.state] / 20
export scaley = (y) -> y * g.ZOOM[g.state]

g.seed = 0
export random = -> (((Math.sin(g.seed++)/2+0.5)*10000)%100)/100

export wrap = (s) -> "(#{s})"

g.BYE = -1
g.PAUSE = -2

export SEPARATOR = '!'

g.TABLES    = 0
g.NAMES     = 1
g.STANDINGS = 2
g.ACTIVE    = 3

g.pages = []

g.message = ""

g.F = (diff) -> 1 / (1 + pow 10, -diff/400)

g.showType = (a) -> if typeof a == 'string' then "'#{a}'" else a
export assert = (a,b) -> if not _.isEqual a,b then print "Assert failure: #{JSON.stringify a} != #{JSON.stringify b}"

g.ok = (a,b) -> 
	# if g.tournament.round < 7
	a.id != b.id and a.id not in b.opp and abs(a.balans() + b.balans()) <= 2
	# else
	# 	a.id != b.id and a.id not in b.opp and abs(a.balans() + b.balans()) <= 2 #1

# g.ok = (a,b) -> 
# 	mand = a.mandatory() + b.mandatory()
# 	a.id != b.id and a.id not in b.opp and mand != "bb" and mand != "ww"

g.other = (col) -> if col == 'b' then 'w' else 'b'

g.myRound = (x,decs) -> x.toFixed decs
assert "2.0", g.myRound 1.99,1
assert "0.6", g.myRound 0.61,1

g.ints2strings = (ints) -> "#{ints}"
assert "1,2,3", g.ints2strings [1,2,3]
assert "1", g.ints2strings [1]
assert "", g.ints2strings []

g.res2string = (ints) -> (i.toString() for i in ints).join ''
assert "123", g.res2string [1,2,3]
assert "1", g.res2string [1]
assert "", g.res2string []

g.zoomIn  = (n) -> g.ZOOM[g.state]++
g.zoomOut = (n) -> g.ZOOM[g.state]--
g.setState = (newState) -> if g.tournament.round > 0 then g.state = newState

g.invert = (arr) ->
	res = []
	for i in range arr.length
		res[arr[i]] = i
	res
assert [0,1,2,3], g.invert [0,1,2,3]
assert [3,2,0,1], g.invert [2,3,1,0]
assert [2,3,1,0], g.invert g.invert [2,3,1,0]

xxx = [[2,1],[12,2],[12,1],[3,4]]
xxx.sort (a,b) -> 
	diff = a[0] - b[0] 
	if diff == 0 then a[1] - b[1] else diff
assert [[2,1], [3,4], [12,1], [12,2]], xxx	
assert true, [2] > [12]
assert true, "2" > "12"
assert false, 2 > 12

# xxx = [[2,1],[12,2],[12,1],[3,4]]
# assert [[2,1],[12,1],[12,2],[3,4]], _.sortBy(xxx, (x) -> [x[0],x[1]])
# assert [[3,4],[2,1],[12,1],[12,2]], _.sortBy(xxx, (x) -> -x[0])
# assert [[2,1],[12,1],[3,4],[12,2]], _.sortBy(xxx, (x) -> x[1])
# assert [[3,4],[12,1],[2,1],[12,2]], _.sortBy(xxx, (x) -> -x[1])

g.calcMissing = ->
	missing = 0
	for p in g.tournament.playersByID
		if not p.active then continue
		if g.BYE == _.last p.opp then continue
		if p.res.length < p.col.length then missing++
	# g.message = "#{missing//2} results missing"
	missing//2

g.sum = (s) ->
	res = 0
	for item in s
		res += parseFloat item
	res
assert 6, g.sum '012012'

g.sumNumbers = (arr) ->
	# print 'sumNumbers',arr
	res = 0
	for item in arr
		res += item
	res
assert 15, g.sumNumbers [1,2,3,4,5]

g.txtT = (value, w, align= CENTER) -> 
	if value.length > w then value = value.substring 0,w
	if value.length < w and align== RIGHT then value = value.padStart w
	if align== LEFT then res = value + _.repeat ' ',w-value.length
	if align== RIGHT then res = _.repeat(' ',w-value.length) + value
	if align== CENTER 
		diff = w-value.length
		lt = _.repeat ' ',(1+diff)//2
		rt = _.repeat ' ',diff//2
		res = lt + value + rt
	res

g.prBth = (score) -> "#{'0½1'[score]}-#{'1½0'[score]}"
g.prBoth = (score) -> " #{'0½1'[score]} - #{'1½0'[score]} "

###########################


import _ from "lodash"
import {marked} from "marked"

# import _                from 'https://cdn.skypack.dev/lodash'
# import h                from "https://cdn.skypack.dev/solid-js@1.2.6/h"
# import { render }       from "https://cdn.skypack.dev/solid-js@1.2.6/web"
# import "https://cdnjs.cloudflare.com/ajax/libs/marked/14.1.0/marked.min.js"

export md = marked
# export md = (s) -> s

minimd = (s) -> md(s).replace("<p>","").replace("</p>","") # unwrap behöver definieras så att <p></p> skapad av marked tas bort

export echo = console.log

# export dump = (obj) =>
# 	console.log obj #.outerHTML
# 	obj

# export N = 8

# export col = (n) => n %% N
# export row = (n) => n // N
# export sum = (arr) => arr.reduce(((a, b) => a + b), 0)
# export r4r = (a) => render a, document.getElementById "app"

# export map = _.map
export range = _.range
# export log = console.log
# export abs = Math.abs

# # export Position = (index) -> "#{"abcdefgh"[col index]}#{"87654321"[row index]}"

# # export removeIndex = (array, index) =>
# # 	# [...array.slice 0, index, ...array.slice index + 1]
# # 	a = array.slice 0, index 
# # 	b = array.slice index + 1
# # 	console.log a.concat b
# # 	a.concat b

# # countTabs = (s) =>
# # 	n = 0
# # 	for c in s
# # 		if c == "\t" then n++ else return n

# TOUR  = "https://member.schack.se/ShowTournamentServlet?id="
# ANMÄL = "https://member.schack.se/turnering/"
# BB2   = "https://storage.googleapis.com/bildbanken2/index.html?query="
# WASA  = "https://www.wasask.se/"

wrap = (type,attr,b...) ->
	b = b.join ""
	if attr == '' then "<#{type}>#{b}</#{type}>"
	else "<#{type} #{attr}>#{b}</#{type}>"

export table = (attr,b...) -> wrap 'table',attr,b...
export tr    = (attr,b...) -> wrap 'tr',attr,b...
export td    = (attr,b)    -> wrap 'td',attr, minimd b
export a     = (attr,b)    -> wrap 'a',attr, minimd b
export div   = (attr,b...) -> wrap 'div',attr,b...

export menu = (attr,b...) -> 
	res = []
	for item in b
		[title,href] = item.split '|'
		res.push tr "", td "", a "href=#{href}", title
	table attr, res...

# graveyard

# export a = (a...) => h "a", a
# export b = (a...) => h "b", a
# export br = (a...) => h "br", a
# export button = (a...) => h "button", a
# export circle = (a...) => h "circle", a
# export defs = (a...) => h "defs", a
# export div = (a...) => h "div", a
# export ellipse = (a...) => h "ellipse", a
# export figure = (a...) => h "figure", a
# export figCaption = (a...) => h "figCaption", a
# export form = (a...) => h "form", a
# export g = (a...) => h "g", a
# export h1 = (a...) => h "h1", a
# export h2 = (a...) => h "h2", a
# export h3 = (a...) => h "h3", a
# export h4 = (a...) => h "h4", a
# export h5 = (a...) => h "h5", a
# export header = (a...) => h "header",a
# export img = (a...) => h "img", a
# export input = (a...) => h "input", a
# export li = (a...) => h "li", a
# export linearGradient = (a...) => h "linearGradient", a
# export option = (a...) => h "option", a
# export p = (a...) => h "p", a
# # export table = (a...) => h "table", a
# export tr = (a...) => h "tr", a
# export td = (a...) => h "td", a
# export th = (a...) => h "th", a
# export rect   = (a...) => h "rect",a
# export select = (a...) => h "select", a
# export span = (a...) => h "span", a
# export stop = (a...) => h "stop", a
# export strong = (a...) => h "strong", a
# export svg = (a...) => h "svg", a
# export text   = (a...) => h "text",a
# export ul = (a...) => h "ul", a

# export indented = (s) =>
# 	div {style:"font-family:monospace; font-size:16px"},
# 		for line in s.split "\n"
# 			n = countTabs line
# 			line = line.trim()
# 			arr = line.split "|"
# 			cmd = arr[0]
# 			div {style:"margin-left:" + n*20 + "px"},
# 				if cmd == "LINK" then a {href:arr[2]}, arr[1]
# 				else if cmd == "TOUR" then a {href:TOUR + arr[2]}, arr[1]
# 				else if cmd == "ANMÄL" then a {href:ANMÄL + arr[2] + "/anmalan"}, arr[1]
# 				else if cmd == "" then br {}
# 				else if cmd == "HEADER" then h2 {}, arr[1]
# 				else if cmd == "BB2" then a {href:BB2 + arr[2]},arr[1]
# 				else if cmd == "WASA" then a {href:WASA + arr[2]},arr[1]
# 				else if cmd == "BOLD" then b {}, arr[1]
# 				else line

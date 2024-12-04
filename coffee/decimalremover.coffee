export class DecimalRemover
	constructor : (numbers) ->
		temp = {} # används för att bli av med dubletter
		for number in numbers
			temp[number] = number
		numbers = _.values temp
		numbers = ([nr,0] for nr in numbers)

		# anropa en extra gång för att förbättra resultatet. (decimaler läggs till vid behov)
		@data = @update @update numbers

		# Sök upp största antal decimaler
		@n = _.maxBy @data, (item) -> item[1]
		print @n
		@n = @n[1]

		@hash = {}
		for [nr,decimals] in @data
			@hash[nr] = decimals

		print 'hash',@hash

		print 'DecimalRemover',@data
		for [nr,decimals] in @data
			print nr,@format nr

	update : (pairs, levels=0) ->
		result = []
		if pairs.length == 1
			pairs[0][1] -= 1
			return pairs
		hash = {}
		for [nr,decimals] in pairs
			key = nr.toFixed decimals
			if key not of hash then hash[key] = []
			hash[key].push [nr,decimals+1]
		for key of hash
			result = result.concat @update hash[key], levels+1
		return result

	# uppdatera antalet decimaler så att varje tal blir unikt.
	# Börja med noll decimaler och lägg till fler vid behov.
	format : (number) -> # lista med flyttal
		if number not of @hash then return 'saknas'
		decimals = Math.abs @hash[number]
		# print 'format',number,decimals
		s = number.toFixed decimals
		# strings = (nr.toFixed decs for [nr,decs] in data)
		# Se till att decimalpunkterna kommer ovanför varandra
		# Lägg till blanktecken på höger sida.
		p = _.lastIndexOf s, '.'
		if p >= 0 then p = s.length - 1 - p
		s + _.repeat ' ', @n - p

rd = new DecimalRemover [1.23001, -1.19, 1.23578, 1.2397, 0, -10.3]
assert   "1.240", rd.format 1.2397
assert   "1.236", rd.format 1.23578
assert   "1.23 ", rd.format 1.23001
assert   "0    ", rd.format 0
assert  "-1    ", rd.format -1.19
assert "-10    ", rd.format -10.3

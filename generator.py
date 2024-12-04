cn = 'ASP BJöRK EN EN GRAN HASSEL LIND RÖNN SÄLG TALL'.split(' ')
an = 'Adam Bertil Cesar David Erik Filip Gustav Helge Ivar Johan'.split(' ')
bn = 'Kalle Ludvig Olof Petter Quintus Rudolf Sigurd Tore Urban Viktor'.split(' ')

i=1400
for a in an:
	for b in bn:
		for c in cn:
			name = str(i) + '!' + c + ' ' + a + '-'+ b
			print(name)
			i += 1
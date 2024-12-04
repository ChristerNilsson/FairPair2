from random import random

numbers = []
for i in range(100):
	numbers.append(20*random() - 15)
numbers.append(numbers[47])

numbers = list(set(numbers))
numbers = sorted(numbers)
numbers = [[nr,0] for nr in numbers]

def f(pairs, levels=0) :
	result = []
	if len(pairs) == 1:
		pairs[0][1] -= 1
		return pairs
	hash = {}
	for pair in pairs:
		nr, decimals = pair
		key = round(nr,decimals)
		if key not in hash: hash[key] = []
		hash[key].append([nr,decimals+1])
	for key in hash:
		result += f(hash[key], levels+1)
	return result

a = f(f(numbers))

for [nr,decs] in a:
	if decs == 0:
		print(int(nr),nr)
	else:
		print(round(nr, decs),nr)

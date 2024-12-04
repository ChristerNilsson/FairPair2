from mwmatching import maxWeightMatching
import copy
import math

K = 40
rond = 0

EXPONENT = 1.01

elos = [1825,1697,1684,1681,1644,1600,1598,1583,1561,1559,1539,1535,1532,1400]
names = "Johansson Björkdahl Silins Stolov Pettersson Aikio Israel Persson Liljeström Lehvonen Andersson Åberg Antonsson Strömbäck".split(' ')

def scoringProbability(diff): return 1 / (1 + 10 ** (diff / 400))

def updateElo(pa,pb) :
	diff = pb.elo - pa.elo
	amount = pa.res[rond] / 2 - scoringProbability(diff)
	aold = pa.elo
	bold = pb.elo
	pa.elo +=  K * amount
	pb.elo += -K * amount
	print (pa.name, aold, '->',pa.elo, pb.name, bold, '->',pb.elo, diff, K * amount)

class Player:
	def __init__(self,id,elo,name):
		self.id = id
		self.elo = elo
		self.name = name
		self.opp = []
		self.col = []
		self.res = []

	def __str__(self):
		return f"{self.id:2} {self.elo:.1f} {self.opp} {''.join(self.col)} {self.res} {self.name}"

	def balans(self):
		res = 0
		for c in self.col:
			if c=='w': res += 1
			if c=='b': res -= 1
		return res

def ok(pa,pb):
	if pa.id in pb.opp: return False
	return abs(pa.balans() + pb.balans()) < 2

def	unscramble (solution): # [5,3,4,1,2,0] => [[0,5],[1,3],[2,4]]
	#solution = _.clone solution
	result = []
	for i in range(len(solution)):
		if solution[i] != -1:
			j = solution[i]
			result.append([i,j]) #[@players[i].id,@players[j].id]
			solution[j] = -1
			solution[i] = -1
	return result

def otherResult(res): return 2 - res
def otherColor(col):  return 'w' if col == 'b' else 'b'

def assignColors (a,b):
	b0 = a.balans()
	b1 = b.balans()
	if b0 < b1: x = 0
	elif b0 > b1: x = 1
	else:
		if a.id < b.id: x = 0
		else: x = 1
	a.col += 'wb'[x]
	b.col += 'bw'[x]

def compare(pa,pb):
	a = pa.name[0]
	b = pb.name[0]
	if a > b: return 0
	if a == b: return 1
	if a < b: return 2

def exec():

	def solutionCost(pair):
		[a, b] = pair
		pa = players[a]
		pb = players[b]
		da = pa.elo
		db = pb.elo
		diff = abs(da - db)
		return diff ** EXPONENT

	def solutionCosts(pairs):
		return sum(solutionCost(pair) for pair in pairs)

	global rond

	edges = []
	n = len(elos)
	for a in range(n):
		pa = players[a]
		for b in range(a+1,n):
			pb = players[b]
			if ok(pa,pb):
				cost = abs(pa.elo - pb.elo) ** 1.01
				edges.append([a,b,9999-cost])

	for [a,b,c] in edges:
		print(a,b,f"{9999-c:.1f}")

	solution = maxWeightMatching(edges, maxcardinality=False)
	print('solution',solution)
	pairs = unscramble(solution)
	print('solutionCosts',solutionCosts(pairs))

	for i in range(len(pairs)):
		[a,b] = pairs[i]
		pa = players[a]
		pb = players[b]

		pa.opp.append(pb.id)
		pb.opp.append(pa.id)

		result = compare(pa,pb)
		pa.res.append(result)
		pb.res.append(2 - result)

		if rond == 0:
			col1 = "bw"[i%2]
			col0 = otherColor(col1)
			pa.col += col0
			pb.col += col1
			if col1=='w' : pairs[i].reverse()
		else:
			assignColors(pa,pb)
			if pa.col[rond]=='b':
				pairs[i].reverse()

		[a,b] = pairs[i]
		pa = players[a]
		pb = players[b]
		updateElo(pa,pb)

	print('Standings')
	for [a,b] in pairs:
		pa = players[a]
		pb = players[b]
		print(pa.elo,pa.name,pb.elo,pb.name)

	temp = copy.deepcopy(players)
	# temp = players.copy()
	temp.sort(key=lambda p: -p.elo)
	for p in temp:
		print(p)
	print("")

	rond += 1

# elos = [1000 + random()*1000 for i in range(n)]
players = []
for i in range(len(elos)):
	players.append(Player(i+1, elos[i], names[i]))

for i in range(7):
	exec()


fw = open('bad.cl', 'w')

count = 0
s = ""
while count < 1024:
	s = s + "weimer!candy!yay"
	count += 16

fw.write(s)
print(len(s))


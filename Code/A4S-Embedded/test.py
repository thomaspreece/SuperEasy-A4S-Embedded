def testfun(abc):
	print(abc['2'])
	abc['2']="hello again"



a = dict()
a = {
	'1':'hello',
	'2':'my',
	'3':'friend',
}

testfun(a)

print(a['2'])
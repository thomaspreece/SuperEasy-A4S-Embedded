import JsonInoConvertorWithARTKV3 as JsonInoConvertor
import sys, getopt


inputfile = ''
outputfile = ''
arduinotype = ''

try:
	opts, args = getopt.getopt(sys.argv[1:],"hi:o:t:",["ifile=","ofile=","arduinotype="])
except getopt.GetoptError:
	print('CommandLineConverter.py -i <inputfile> -o <outputfile> -t <arduinotype>')
	sys.exit(2)
for opt, arg in opts:
	if opt == '-h':
		print('CommandLineConverter.py -i <inputfile> -o <outputfile> -t <ArduinoType>')
		sys.exit()
	elif opt in ("-i", "--ifile"):
		inputfile = arg
	elif opt in ("-o", "--ofile"):
		outputfile = arg
	elif opt in ("-t", "--ArduinoType"):
		arduinotype = arg
print('Input file is', inputfile)
print('Output file is', outputfile)
print('Arduino type is', arduinotype)


convertor = JsonInoConvertor.JsonInoConvertor(typeArduino=arduinotype)

try:
	convertor.convertSpriteScripts(inputfile,outputfile)
except Exception as expt:
	error = str()
	for mess in expt.args:
		error += mess + " "
	print(error)

finally:
	del convertor
	convertor = None


import JsonInoConvertor as JsonInoConvertor
import sys, getopt, os

def main():
	inputfile = ''
	outputfile = ''
	arduinotype = ''

	try:
		opts, args = getopt.getopt(sys.argv[1:],"hi:o:t:",["ifile=","ofile=","arduinotype="])
	except getopt.GetoptError:
		usage()
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			usage()
			sys.exit(3)
		elif opt in ("-i", "--ifile"):
			inputfile = arg
		elif opt in ("-o", "--ofile"):
			outputfile = arg
		elif opt in ("-t", "--ArduinoType"):
			arduinotype = arg
	if inputfile=='' or outputfile=='' or arduinotype=='':
		usage()
		sys.exit(4)	

	if not os.path.exists(inputfile):
		print("Invalid input file")
		sys.exit(5)
	if not os.access(os.path.dirname(outputfile), os.W_OK): 
		print("Invalid output file")
		sys.exit(5)
		
	print('Input file is', inputfile)
	print('Output file is', outputfile)
	print('Arduino type is', arduinotype)
	
	convertor = JsonInoConvertor.JsonInoConvertor(typeArduino=arduinotype)

	try:
		convertor.doFileConversion(inputfile,outputfile)
	except Exception as expt:
		error = str()
		for mess in expt.args:
			error += mess + " "
		print(error)

	finally:
		del convertor
		convertor = None

def usage():
	print('CommandLineConverter.py -i <inputfile> -o <outputfile> -t <arduinotype>')
	
	
if __name__ == "__main__":
    main()
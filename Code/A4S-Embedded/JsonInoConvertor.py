#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import unicode_literals

import json
import codecs

# from fileinput import close
import zipfile

try:
	unicode = unicode
except NameError:
	# 'unicode' is undefined, must be Python 3
	str = str
	unicode = str
	bytes = bytes
	basestring = (str,bytes)
else:
	# 'unicode' exists, must be Python 2
	str = str
	unicode = unicode
	bytes = str
	basestring = basestring


class JsonInoConvertor(object):
	
	scriptsToProcess = dict()
	controlInstructions = dict()
	a4sInstructions = dict()
	variables = dict()
	servos = dict()
	
	instructions = dict()
	booleanTests = dict()
	globalVarStr = str()
	setupFunctionStr = str()
	loopFunctionStr = str()
	functionNameStr = str()
	nb_block = 0
	# nbBlockStr = str()
	pins = dict()
	var = []
	unknownVar = []
	servohashlist = []
	indentation = str()
	incr = 1
	typeArduino = 0
	sleep_var = False

	def __init__(self, indentation="   ", typeArduino=0):
		super(JsonInoConvertor, self).__init__()
		
		self.scriptsToProcess = dict()
		self.controlInstructions = dict()
		self.a4sInstructions = dict()
		self.variables = dict()
		self.servos = dict() 
		
		self.instructions = dict()
		self.booleanTests = dict()
		self.globalVarStr = str()
		self.setupFunctionStr = str()
		self.loopFunctionStr = str()
		self.functionNameStr = str()
		self.nb_block = 0
		self.pins = dict()
		self.var = []
		self.unknownVar = []
		self.servohashlist = []
		self.indentation = str()
		self.incr = 1
		self.typeArduino = 0
		self.sleep_var = False

		self.scriptsToProcess = {
			'threaded': [],
			'unthreaded': [],
		}
		
		self.variables = {}
		self.servos = {}
		
		#If a script uses any of these it will need a separate thread
		self.controlInstructions = {
			'doWaitUntil': 1,
			'wait:elapsed:from:': 1,
			'doRepeat': 1,
			'doForever': 1,
			'doUntil': 1,
		}
		
		#Only consider scripts with at least one of these blocks
		self.a4sInstructions = {
			'A4S (Arduino For Scratch).tone': 1,
			'A4S (Arduino For Scratch).pinMode': 1,
			'A4S (Arduino For Scratch).digitalWrite': 1,
			'A4S (Arduino For Scratch).analogWrite': 1,
			'A4S (Arduino For Scratch).servoWrite': 1,
			'A4S (Arduino For Scratch).tone': 1,
			'A4S (Arduino For Scratch).notone': 1,
			'A4S (Arduino For Scratch).digitalRead': 1,
			'A4S (Arduino For Scratch).analogRead': 1,
		}
		
		#TODO: Add instructions and booleanTests to digitalWrite, analogWrite, pinMode, servoWrite, digitalRead, analogRead
		
		self.instructions = {
			'A4S (Arduino For Scratch).digitalWrite': self.digitalWriteConvertion,
			'A4S (Arduino For Scratch).pinMode': self.pinModeConvertion,
			'doIf': self.doIfConvertion,
			'doIfElse': self.doIfElseConvertion,
			'readVariable': self.doReadVariable,
			'setVar:to:': self.SetVar,
			'changeVar:by:': self.ChangeVar,
			'A4S (Arduino For Scratch).analogRead': self.AnalogReadingConvertion,
			'A4S (Arduino For Scratch).analogWrite': self.AnalogWriteConvertion,
			'A4S (Arduino For Scratch).servoWrite': self.ServoWriteConvertion,
			'A4S (Arduino For Scratch).tone': self.toneConvertion,
			'A4S (Arduino For Scratch).notone': self.notoneConvertion,
			'*': self.OpertationConvertion,
			'+': self.OpertationConvertion,
			'-': self.OpertationConvertion,
			'/': self.OpertationConvertion,
			'%': self.OpertationConvertion,
			'doRepeat': self.doRepeatConvertion,
			'doUntil': self.doUntilConvertion,
			'wait:elapsed:from:': self.doWaitConvertion,
			'doWaitUntil': self.doWaitUntilConvertion,
		}

		self.booleanTests = {

			'&': self.reportAndOrConvertion,
			'|': self.reportAndOrConvertion,
			'=': self.reportCompareConvertion,
			'A4S (Arduino For Scratch).digitalRead': self.reportDigitalReadingConvertion,
			'low': self.reportFalseConvertion,
			'high': self.reportTrueConvertion,
			'not': self.reportNot,
			'<': self.reportCompareConvertion,
			'>': self.reportCompareConvertion,
		}

		self.functionNameStr = "void consumer"
		# self.nbBlockStr = "# define MAX_THREAD_LIST "
		self.setupFunctionStr = "void SetupARTK() {\n"
		# self.loopFunctionStr = "void consumer1() {\n	while(1){\n"
		# Voir pour incrémentation des consumer: créer à chaque
		# fois l'objet loopfunction différent pour chaque groupe de blocs

		self.indentation = indentation
		self.typeArduino = typeArduino

	def doIfConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)			
		
		if block[1]==False:
			e = Exception("\nError: If Block doesn't have condition")
			raise(e)
		
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += indentation + "if( "
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += indentation + "if( "

		self.booleanTests[block[1][0]](block[1], codeDict, indentation, insertCodeIntoSection)
		
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += " ){\n"
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += " ){\n"		
		
		self.convertScript(block[2],codeDict,indentation+self.indentation,insertCodeIntoSection)

		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += indentation + "}\n"
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += indentation + "}\n"

	def doUntilConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		self.sleep_var = False
		code = indentation + "while( "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
			
		self.booleanTests[block[1][0]](block[1], codeDict, indentation, insertCodeIntoSection)

		code = " ){\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
			
		
		self.convertScript(block[2], codeDict, indentation+self.indentation, insertCodeIntoSection)
		
		code = ''
		if codeDict['Threads']!='Single':
			if (not (self.sleep_var)):
				code += indentation+self.indentation + "ARTK_Yield();\n"
			self.sleep_var = False
		
		code += indentation + "}\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code			

	def doWaitConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		x = float(block[1]) * 1000
		code = ''

		if codeDict['Threads']=='Single':
			code += indentation+"delay("+str(int(x))+");\n"
		else:
			code += indentation+"ARTK_Sleep("+str(int(x))+");\n"
			self.sleep_var = True

			
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
		else:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		

	def doWaitUntilConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)	
		
		code = indentation + "while( !( "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
			
		self.booleanTests[block[1][0]](block[1], codeDict, indentation, insertCodeIntoSection)

		if codeDict['Threads']=='Single':
			code = " ) ){\n"+ indentation + self.indentation + "delay(50);\n" + indentation + "}\n"
		else:
			code = " ) ){\n"+ indentation + self.indentation + "ARTK_Sleep(50);\n" + indentation + "}\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code


	def doRepeatConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)	
			
		self.sleep_var = False 
		this_incr = "loop"+str(self.incr)
		
		code =  indentation + "for(int "+this_incr+"=0; "+this_incr+"<" + str(block[1])+ "; "+this_incr+"++){\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
		
		self.convertScript(block[2], codeDict, indentation + self.indentation, insertCodeIntoSection)
		
		
		code = ''
		if codeDict['Threads'] != 'Single':
			if (not (self.sleep_var)):
				code += indentation + self.indentation + "ARTK_Yield();\n"
			self.sleep_var = False
		
		code += indentation +"}\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code		
		
		self.incr += 1
		
		
	def pinModeConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		pin = str(block[1])
		if str(block[2])=="Digital Input" or str(block[2])=="input":
			mode = "INPUT"
		elif str(block[2])=="Digital Output" or str(block[2])=="Analog Output(PWM)" or str(block[2])=="output":
			mode = "OUTPUT"
		else:
			#Don't need to add anything for Analog Input or Servo
			return

		code = indentation+"pinMode("+pin+","+mode+");\n"
		
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
		else:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
	def digitalWriteConvertion(self, block, codeDict, indentation, insertCodeIntoSection):

		pin = str(block[1])
		state = str(block[2]).upper()
		
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += indentation+"digitalWrite("+pin+","+state+");\n"
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += indentation+"digitalWrite("+pin+","+state+");\n"
		else:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
		
	def toneConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)	
			
		pin = block[1]
		note = block[2]
		
		code = indentation + "tone( " + str(pin) + ", "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code		
		
		code =  ''
		if isinstance(note, int) or isinstance(note, basestring):
			code += str(note)
		else:
			#TODO: digitalRead is not processed:
			self.instructions[block[2][0]](block[2], codeDict, indentation, insertCodeIntoSection)

		code += " );\n"
		
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
			
	def notoneConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		pin = block[1]
		
		code = indentation + "noTone( " + str(pin) + " );\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
			
	def ServoWriteConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		pin = block[1]

		if not pin in self.servos:
			self.servos[pin] = 'used'
		
		code = indentation + "myservo" + str(pin) + ".write( "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
		code = ''
		
		if isinstance(block[2], int) or isinstance(block[2], basestring):
			code += str(block[2])
		else:
			self.instructions[block[2][0]](block[2], codeDict, indentation, insertCodeIntoSection)
	
		code += " );\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code		

	def AnalogWriteConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		pin = block[1]
		

		code = indentation + "AnalogWrite( " + str(pin) + ", "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
		code = ''		
		if isinstance(block[1], basestring) or isinstance(block[1], int):
			code += str(block[1])
		else:
			self.instructions[block[1][0]](block[1], codeDict, indentation, insertCodeIntoSection)

		code += " );\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
			
	def doIfElseConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		if block[1]==False:
			e = Exception("\nError: If Block doesn't have condition")
			raise(e)			
			
		code = indentation + "if ( "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
			
		self.booleanTests[block[1][0]](block[1], codeDict, indentation, insertCodeIntoSection)
		
		code = " ){\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
			
		self.convertScript(block[2], codeDict, indentation+self.indentation , insertCodeIntoSection)

		code = indentation + "}else{\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code		
		
		self.convertScript(block[3], codeDict, indentation+self.indentation , insertCodeIntoSection)

		code = indentation + "}\n"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code		
			
	def reportDigitalReadingConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		pin = str(block[1])
		code = "digitalRead( " + pin + " )"
		
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code
		

	def AnalogReadingConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		pin = block[1]
		code = indentation +"analogRead( " + str(pin) + " )"
		
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code			

	def reportCompareConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)	
			
		code = ''
		if (not isinstance(block[1], basestring)):
			if block[1][0] in self.instructions:
				#Code for round value blocks
				self.instructions[block[1][0]](block[1], codeDict, '', insertCodeIntoSection)
			elif block[1][0] in self.booleanTests:
				#Code for silly but valid logic: (a < b) < c         (or >,=)
				code = '( '
				if insertCodeIntoSection == 1:
					codeDict['setupStr'] += code 
				elif insertCodeIntoSection == 2:
					codeDict['loopStr'] += code				
				self.booleanTests[block[1][0]](block[1], codeDict, '', insertCodeIntoSection)
				code = ' )'
			else:
				e = Exception("Invalid block")
				raise(e)	
		else:
			if str(block[1]) == '':
				e = Exception("\nError: Empty 1st argument in "+str(block[0])+" block")
				raise(e)
			elif is_number(block[1])==False:
				e = Exception("\nError: Invalid 1st argument in "+str(block[0])+" block")
				raise(e)
			else:
				code += str(block[1])

		if block[0]=='=':
			code += " == "
		else:
			# > or <
			code += " "+block[0]+" "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code			
		code = ''
			
		if (not isinstance(block[2], basestring)):
			if block[2][0] in self.instructions:
				#Code for round value blocks
				self.instructions[block[2][0]](block[2], codeDict, '', insertCodeIntoSection)
			elif block[2][0] in self.booleanTests:
				#Code for silly but valid logic: a < (b < c)         (or >,=)
				code = '( '
				if insertCodeIntoSection == 1:
					codeDict['setupStr'] += code 
				elif insertCodeIntoSection == 2:
					codeDict['loopStr'] += code					
				self.booleanTests[block[2][0]](block[2], codeDict, '', insertCodeIntoSection)
				code = ' )'			
			else:
				e = Exception("Invalid block")
				raise(e)
		else:
			if str(block[2]) == '':
				e = Exception("\nError: Empty 2nd argument in "+str(block[0])+" block")
				raise(e)
			elif is_number(block[2])==False:
				e = Exception("\nError: Invalid 2nd argument in "+str(block[0])+" block")
				raise(e)
			else:
				code += str(block[2])
		
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code	
			
			
	def OpertationConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)	
		
		code = "( "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code			
		code = ''
		
		if isinstance(block[1], basestring) or isinstance(block[1], int):
			code += str(block[1])
		else:
			#TODO: Add Boolean test
			self.instructions[block[1][0]](block[1], codeDict, "", insertCodeIntoSection)

		code += " " + block[0] + " "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code			
		code = ''
		
		if isinstance(block[2], basestring) or isinstance(block[2], int):
			code += str(block[2])
		else:
			#TODO: Add Boolean test
			self.instructions[block[2][0]](block[2], codeDict, "", insertCodeIntoSection)	

		code += " )"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code										

	def SetVar(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
		
		variableName = "var_"+str(codeDict['Sprite'])+"_"+str(block[1])
		if is_number(block[2]):
			#variable is number (int/float)
			if "." in str(block[2]):
				variableType = 'float'
			else:
				variableType = 'int'
		elif isinstance(block[2], basestring):
			#variable is string
			variableType = 'String'
		else:
			#variable is using other blocks so likely requires int
			variableType = 'int'
		
		if (codeDict['Sprite'] in self.variables) and (block[1] in self.variables[codeDict['Sprite']]):
			if self.variables[codeDict['Sprite']][block[1]] == variableType :
				#do nothing 
				pass 
			elif self.variables[codeDict['Sprite']][block[1]] == 'unused':
				#Variable is unused so set variable to correct type
				self.variables[codeDict['Sprite']][block[1]] = variableType
			elif (self.variables[codeDict['Sprite']][block[1]] == 'int') and (variableType == 'float'):
				#Variable is currently an int so convert so set it to float as it will still function correctly
				self.variables[codeDict['Sprite']][block[1]] = variableType
			else:
				e = Exception("Variable incorrect")
				raise(e)
		else:
			e = Exception("Variable not found")
			raise(e)
				
		code = indentation + variableName + " = "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code			

		if isinstance(block[2], basestring) or isinstance(block[2], int):
			code = str(block[2]) + ";\n"	
		else:
			self.instructions[block[2][0]](block[2], codeDict, "", insertCodeIntoSection)
			code = ";\n"
			
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code	

	def ChangeVar(self, block, codeDict, indentation, insertCodeIntoSection):
		
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
	
		if (codeDict['Sprite'] in self.variables) and (block[1] in self.variables[codeDict['Sprite']]):
			if self.variables[codeDict['Sprite']][block[1]] == 'String':
				e = Exception("cannot change String variable")
				raise(e)
		else:
			e = Exception("Variable not found")
			raise(e)		
		
		variableName = "var_"+str(codeDict['Sprite'])+"_"+str(block[1])
		
		if (isinstance(block[2], basestring) or isinstance(block[2], int)) and "-" in str(block[2]):
			code = indentation + variableName + " = " + variableName + " - "
		else:
			code = indentation + variableName + " = " + variableName + " + "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code			
		
		
		if isinstance(block[2], basestring) or isinstance(block[2], int):
			if "-" in str(block[2]):
				code = str(block[2])[1:] + ";\n"
			else:
				code = str(block[2]) + ";\n"	
		else:
			self.instructions[block[2][0]](block[2], codeDict, "", insertCodeIntoSection)
			code = ";\n"
			
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code	

	def reportAndOrConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)	
		
		if block[1]==False or block[2]==False:
			e = Exception("\nError: Empty argument in "+str(block[0])+" block")
			raise(e)	
			
		code = "( "
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code				
			
		self.booleanTests[block[1][0]](block[1], codeDict, indentation, insertCodeIntoSection)
		
		if block[0]=='&':
			code = " ) && ( "
		elif block[0]=='|':
			code = " ) || ( "
		else:
			e = Exception("Invalid block type")
			raise(e)	
			
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code	
			
		self.booleanTests[block[2][0]](block[2], codeDict, indentation, insertCodeIntoSection)

		code = " )"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code					
	

	def reportNot(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
		
		if block[1]==False:
			e = Exception("\nError: Empty argument in "+str(block[0])+" block")
			raise(e)	
		
		code = "! ("
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code	
			
		if block[1][0] in self.instructions:
			self.instructions[block[1][0]](block[1], codeDict, "", insertCodeIntoSection)
		elif block[1][0] in self.booleanTests:
			self.booleanTests[block[1][0]](block[1], codeDict, "", insertCodeIntoSection)
		else:
			e = Exception(
				"Invalid Block in Not block")
			raise(e)
		
		code = ")"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code			

	def doReadVariable(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		code = block[1]
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code	
			
	def reportFalseConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)
			
		code = "LOW"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code				

	def reportTrueConvertion(self, block, codeDict, indentation, insertCodeIntoSection):
		if insertCodeIntoSection != 1 and insertCodeIntoSection != 2:
			e = Exception("Invalid insertCodeIntoSection")
			raise(e)	

		code = "HIGH"
		if insertCodeIntoSection == 1:
			codeDict['setupStr'] += code 
		elif insertCodeIntoSection == 2:
			codeDict['loopStr'] += code		

	#Returns number of threads required for Scratch code. Will ignore threads without A4S code in.
	#Return value of 0 does NOT imply that there is no A4S code, it does however imply that all code can be put in arduino setup() function
	def scanForA4SThreads(self,json):	
		print("-----SCANNING FOR THREADS-----")
		threads = 0 
		if 'scripts' in json:	
			#Stage has scripts, 
			print("Has "+str(len(json['scripts']))+" Stage Scripts")
			print()
			#Loop through scripts and check if each one requires a separate thread
			for i in range(len(json['scripts'])):
				threads = threads + self.validA4SThread(json['scripts'][i],"")
		if 'children' in json:
			#There are sprites
			print("Has "+str(len(json['children']))+" Children Sprites")
			#Loop through each sprite
			for i in range(len(json['children'])):
				if 'scripts' in json['children'][i]:
					print("Sprite: "+json['children'][i]['objName']+" has "+str(len(json['children'][i]['scripts']))+" scripts")
					#Loop through each sprites set of scripts
					for j in range(len(json['children'][i]['scripts'])):
						threads = threads + self.validA4SThread(json['children'][i]['scripts'][j],json['children'][i]['objName'])
		print()
		print("Threads Required: "+str(threads))
		print()
		return threads 
		
	#Returns true if blocks will require a separate thread
	def validA4SThread(self,json,spriteName):
		a4sBlocks = False
		controlBlocks = False
		retVal = 0
		
		blocks = json[2]
		print("Blocks: "+str(blocks))
		if blocks[0][0] == 'whenGreenFlag':
			retVal = self.validA4SThreadCheckBlocks(blocks)
			if retVal & 0b01:
				a4sBlocks = True
			if retVal & 0b10:
				controlBlocks = True
		print("RetVal: "+str(retVal))	
		
		if a4sBlocks == True:
			if controlBlocks == True:
				blocks[0][0] = spriteName
				self.scriptsToProcess['threaded'].append(blocks)
			else:
				blocks[0][0] = spriteName
				self.scriptsToProcess['unthreaded'].append(blocks)
			
		
		if a4sBlocks == True and controlBlocks == True:
			print("+Needs Separate Thread")
			print()
			return 1
		else:
			print()
			return 0

	#a4sBlocks and controlBlocks false = return 0
	#a4sBlocks true and controlBlocks false = return 1
	#a4sBlocks false and controlBlocks true = return 2
	#a4sBlocks true and controlBlocks true = return 3
	def validA4SThreadCheckBlocks(self,blocks):
		a4sBlocks = False
		controlBlocks = False		
		retedVal = 0
		
		if blocks == None:
			e = Exception("\nError: Empty Block")
			raise(e)
		
		for i in range(len(blocks)):
			if str(blocks[i][0]) in self.a4sInstructions:
				a4sBlocks = True
			if str(blocks[i][0]) in self.controlInstructions:
				controlBlocks = True
			if blocks[i][0] == 'doForever':
				retedVal = self.validA4SThreadCheckBlocks(blocks[i][1])
			elif blocks[i][0] == 'doUntil' or blocks[i][0] == 'doIf' or blocks[i][0] == 'doRepeat':
				retedVal = self.validA4SThreadCheckBlocks(blocks[i][2])
			elif blocks[i][0] == 'doIfElse':
				retedVal = self.validA4SThreadCheckBlocks(blocks[i][2]) | self.validA4SThreadCheckBlocks(blocks[i][3])
			if retedVal & 0b01:
				a4sBlocks = True 
			if retedVal & 0b10:
				controlBlocks = True
			if controlBlocks==True and a4sBlocks==True:
				break
			
		retVal = 0
		if a4sBlocks == True:
			retVal = retVal | 0b01
		if controlBlocks == True:
			retVal = retVal | 0b10
		
		return retVal
	
	def removeNestedLoops(self):
		#Todo: Remove any repeat within repeats etc
		print()
		return 
	
	def doFileConversion(self,fileINName, fileOUTName):
		#Scratch Files are a standard zip file. We extract the project.json file from this zip
		fileOUT = open(fileOUTName, "w")
		archive = zipfile.ZipFile(fileINName, 'r')
		json_data = archive.read('project.json')
		
		#Parse JSON data
		data = json.loads(json_data.decode('utf-8'))
		threads = self.scanForA4SThreads(data)
		
		print("-----FIXING CODE-----")
		
		self.removeNestedLoops()
		
		print("-----SCANNING FOR VARIABLES-----")
		
		self.gatherVariables(data)
		
		print("-----GENERATING CODE-----")
		if threads > 1:
			print("Multiple Threads required: ARTK Enabled")
		else:
			print("Single Thread required: Standard Arduino setup/loop format")
		
		print("threaded: ")
		print(self.scriptsToProcess['threaded'])
		print("unthreaded: ")
		print(self.scriptsToProcess['unthreaded'])
		print()
		
		
		codeDict = dict()
		codeDict = {
			'includeStr':'',
			'globalStr':'',
			'loopStr':'',
			'setupStr':'',
			'Threads':'',
			'Sprite':'',
		}
			
		if threads > 1:
			globalStr = ""
			setupArtkStr = ""
			codeDict['Threads'] = 'Multiple'
		else:
			codeDict['Threads'] = 'Single'
			
			#Process unthreaded scripts first
			for i in range(len(self.scriptsToProcess['unthreaded'])):
				codeDict['Sprite'] = self.scriptsToProcess['unthreaded'][i][0][0]
				self.convertScriptMain(self.scriptsToProcess['unthreaded'][i][1:],codeDict,self.indentation,1)
			
			#Process threaded script last
			for i in range(len(self.scriptsToProcess['threaded'])):
				codeDict['Sprite'] = self.scriptsToProcess['threaded'][i][0][0]
				self.convertScriptMain(self.scriptsToProcess['threaded'][i][1:],codeDict,self.indentation,1)
			
			#Add in setup and loop functions 
			codeDict['setupStr'] = 'void setup(){\n'+codeDict['setupStr']+'}\n'
			codeDict['loopStr'] = 'void loop(){\n'+codeDict['loopStr']+'}\n'
			
			#Add in servos
			if bool(self.servos):
				codeDict['includeStr'] += "#include <Servo.h>\n"
				for servo in self.servos:
					codeDict['globalStr'] += "Servo myservo"+str(servo)+";\n"
				codeDict['globalStr'] += "\n"
			
			#Add in variable declarations to top of file
			for sprite in self.variables:
				for variableName in self.variables[sprite]:
					codeDict['globalStr'] += self.variables[sprite][variableName]+" "+"var_"+sprite+"_"+variableName+";\n"
			
			
			
		print()
		print("Code:")
		print(codeDict['includeStr'])
		print(codeDict['globalStr'])
		print(codeDict['setupStr'])
		print(codeDict['loopStr'])
		

			
	def convertScriptMain(self,script,codeDict,indentation,insertCodeIntoSection):
		for element in script:
			if element[0] == 'doForever' and insertCodeIntoSection == 1:
				insertCodeIntoSection = 2
				indentation = self.indentation
				#Process Forever loop code 
				self.convertScript(element[1],codeDict,indentation,insertCodeIntoSection)
				#Code after forever loop never executes so exit function
				return
			elif element[0] in self.instructions:
				self.instructions[element[0]](element, codeDict, indentation, insertCodeIntoSection)
			elif element[0] in self.booleanTests:
				self.booleanTests[element[0]](element, codeDict, indentation, insertCodeIntoSection)
			else:
				print("Unprocessed block: "+str(element[0]))
	
	
	def convertScript(self,script,codeDict,indentation,insertCodeIntoSection):
		
		for element in script:
			if element[0] in self.instructions:
				self.instructions[element[0]](element, codeDict, indentation, insertCodeIntoSection)
			elif element[0] in self.booleanTests:
				self.booleanTests[element[0]](element, codeDict, indentation, insertCodeIntoSection)
			else:
				print("Unprocessed block: "+str(element[0]))

	def gatherVariables(self,json):	
			
		if 'variables' in json:	
			#Stage has variables, 
			if not '' in self.variables:
				self.variables[''] = {}
			#Loop through variables and add each one
			for i in range(len(json['variables'])):
				if not json['variables'][i]['name'] in self.variables['']:
					self.variables[''][json['variables'][i]['name']] = 'unused'
					
		if 'children' in json:
			#There are sprites
			
			#Loop through each sprite
			for i in range(len(json['children'])):
				if 'variables' in json['children'][i]:
					#Sprite has variables 
					if not json['children'][i]['objName'] in self.variables:
						self.variables[json['children'][i]['objName']] = {}
					#Loop through each variable and add each one
					for j in range(len(json['children'][i]['variables'])):
						if not json['children'][i]['variables'][j]['name'] in self.variables['']:
							self.variables[json['children'][i]['objName']][json['children'][i]['variables'][j]['name']] = 'unused'
		print(self.variables)
		print()

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
















	
#	def convertSpriteScripts(self, fileINName, fileOUTName):
#
#		fileOUT = open(fileOUTName, "w")
#		archive = zipfile.ZipFile(fileINName, 'r')
#		json_data = archive.read('project.json')
#		
#		# json_data=open(jsondata)
#
#		data = json.loads(json_data.decode('utf-8'))
#		curs = None
#		for kindern in range(len(data['children'])):
#			lala = data['children'][kindern]
#			if lala.get('scripts', None) is not None:
#				curs = kindern
#		if curs is not None:
#			for threadScript in data['children'][curs]['scripts']:
#				print(threadScript[2])
#				self.convertThreadScript(threadScript[2], self.indentation, [])
#			if (self.unknownVar):
#				mess = "Error : Variable "
#				for uvar in self.unknownVar:
#					mess += "\"" + str(uvar) + "\" "
#				mess += "read but never set"
#				raise(Exception(mess))
#			self.setupFunctionStr += self.indentation + "ARTK_SetOptions("\
#				+ str(self.typeArduino) + ") ;\n"
#			for i in range(1, self.nb_block + 1):
#				self.setupFunctionStr += self.indentation\
#					+ "ARTK_CreateTask(consumer" + str(i) + ");\n"
#			self.setupFunctionStr += "}\n"
#			# self.loopFunctionStr += "ARTK_Yield();\n}\n}\n"
#
#			print("#include <ARTK.h>\n")
#			if len(self.servohashlist) > 0:
#				print("#include <Servo.h>\n")
#				for servohash in self.servohashlist:
#					print("Servo myservo"+str(servohash["pin"])+";\n")
#			print(self.globalVarStr\
#				+ self.loopFunctionStr\
#				+ self.setupFunctionStr)
#			# Write in file
#			fileOUT.write("#include <ARTK.h>\n")
#			if len(self.servohashlist) > 0:
#				fileOUT.write("#include <Servo.h>\n")
#				for servohash in self.servohashlist:
#					fileOUT.write("Servo myservo"+str(servohash["pin"])+";\n")
#			fileOUT.write(self.globalVarStr)
#			fileOUT.write(self.loopFunctionStr)
#			fileOUT.write(self.setupFunctionStr)
#		else:
#			raise(Exception("Scripts not found in sb2"))
#		fileOUT.close()
#		# print data
#
#		# json_data.close()
#		# print self.loopFunctionStr
#
#	def convertThreadScript(self, threadScript, i, localVar):
#		# print "on m'appelle"
#		# print threadScript
#		if (len(threadScript) >= 2):
#			receiveGoBlock = threadScript[0]
#			# print receiveGoBlock[0]
#			# print doForeverBlock[1]
#			if receiveGoBlock[0] != "whenGreenFlag" or (not receiveGoBlock[0]):
#				e = Exception(
#					"Warning convertThreadScript : expected block receiveGo")
#				raise(e)
#			else:
#				self.nb_block = self.nb_block + 1
#				self.loopFunctionStr += "void consumer" \
#					+ str(self.nb_block) + "() {\n"
#				for bl in range(1, len(threadScript)):
#					afterGoBlock = threadScript[bl]
#					if afterGoBlock[0] != 'doForever' or (
#											not afterGoBlock[0]):
#						if afterGoBlock[0] == 'setVar:to:':
#							self.instructions[afterGoBlock[0]](
#								afterGoBlock, self.indentation, localVar)
#							localVar.append(afterGoBlock[1])
#						elif afterGoBlock[0] == 'changeVar:by:':
#							self.instructions[afterGoBlock[0]](
#								afterGoBlock, self.indentation, localVar)
#						else:
#							e = Exception(
#								"Warning convertThreadScript : "
#								"expected block doForever or setVar:to")
#							raise e
#					else:
#						print(i)
#						self.loopFunctionStr += i + "while(1){\n"
#						self.convertScript(afterGoBlock[1], i, localVar)
#						self.loopFunctionStr += i + self.indentation\
#							+ "ARTK_Yield();\n"
#
#						self.sleep_var = False
#				self.loopFunctionStr += i + "}\n}\n"

#	def convertScript(self, script, i, localVar):
#		for element in script:
#			# print element
#			if element[0] in self.instructions:
#				# print "c'est une instruction :"
#				# print element
#				self.instructions[element[0]](element,
#											  i + self.indentation,
#											  localVar)
#				if element[0] == "setVar:to:":
#					localVar.append(element[1])
#			elif element[0] in self.booleanTests:
#				# print "c'est un test booleen :"
#				# print element
#				self.booleanTests[element[0]](element, localVar)
#			else:
#				e = Exception(
#					"Warning script : bloc", element[0], "non géré...")
#				raise(e)

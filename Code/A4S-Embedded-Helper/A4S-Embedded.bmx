Framework BRL.StandardIO
Import wx.wxApp
Import wx.wxTimer
Import wx.wxStaticText
Import wx.wxTextCtrl
Import wx.wxComboBox
Import wx.wxPanel
Import wx.wxButton
Import wx.wxFrame
Import wx.wxMessageDialog
Import wx.wxNotebook 
Import wx.wxAboutBox

Import BaH.Serial
Import BaH.Volumes

Import brl.linkedlist 
Import pub.freeprocess
Import BRL.Retro
Import BRL.PolledInput
Import BRL.FileSystem
Import BRL.Blitz
Import BRL.System

?Not MacOS
Import "A4S-helperApp.o"
?

Const RPB:int = 1
Const SSB:Int = 2
Const ST:Int = 3
Const RPB2:Int = 4
Const SSB2:Int = 5
Const TLOG:Int =6
Const AID:Int = 7
Const PCB1:Int = 8
Const PCB2:Int = 9
Const BCB:Int = 10
Const TADO:Int = 11
Const BACB:Int = 12
Const BACB2:int = 13
Const BSFB:int = 14
Const SFC:int = 15
Const CCT:int = 16
Const TCOD:int = 17

?Not MacOS
Const Slash:String="\"
?MacOS
Const Slash:String="/"
?

Const VERSION:String = "V1.0"

Global EXPLAINTEXT1:String
Global EXPLAINTEXT2:String
Global EXPLAINTEXT3:String
Global APPWINTITLE:String
Global APPLOGTITLE:String
Global APPCODEVIEWTITLE:String 
Global TAB1:String
Global TAB2:String
Global TAB3:String
Global LABEL1:String
Global LABEL2:String
Global LABEL3:String
Global LABEL4:String
Global LABEL5:String
Global LABEL6:String
Global LABEL7:String
Global MENU1:String
Global MENU2:String
Global MENU3:String
Global MENU4:String
Global MENU5:String
Global MENU6:String
Global MENU7:String
Global BUTTON1:String
Global BUTTON2:String
Global BUTTON3:String
Global BUTTON4:String
Global ERROR1:String
Global ERROR2:String
Global ERROR3:String
Global ERROR4:String
Global ERROR5:String
Global ERROR6:String
Global ERROR7:String
Global ERROR8:String
Global ERROR9:String
Global ERROR10:String
Global STATUS1:String
Global STATUS2:String
Global STATUS3:String
Global STATUS4:String
Global STATUS5:String
Global STATUS6:String
Global STATUS7:String
Global STATUS8:String
Global STATUS9:String

?Win32
Global AppResources:String=""
Global PROGRAMICON:String = "Resources"+Slash+"microcontroller.ico"
?MacOS
Global AppResources:String= ExtractDir(AppFile) + "/../Resources/"
Global PROGRAMICON:String = "microcontroller.ico"
?
ChangeDir(AppResources)

If FileType("LanguageFile.txt")=1 Then 
	ReadLanguage = ReadFile("LanguageFile.txt")
	
	ReadLine(ReadLanguage)
	
	EXPLAINTEXT1 = ReadLine(ReadLanguage)
	EXPLAINTEXT2 = ReadLine(ReadLanguage)
	EXPLAINTEXT3 = ReadLine(ReadLanguage)
	
	EXPLAINTEXT1 = Replace(EXPLAINTEXT1,"~~n","~n")
	EXPLAINTEXT2 = Replace(EXPLAINTEXT2,"~~n","~n")
	EXPLAINTEXT3 = Replace(EXPLAINTEXT3,"~~n","~n")			
	
	APPWINTITLE = ReadLine(ReadLanguage)
	APPLOGTITLE = ReadLine(ReadLanguage)
	APPCODEVIEWTITLE = ReadLine(ReadLanguage)
	TAB1 = ReadLine(ReadLanguage)
	TAB2 = ReadLine(ReadLanguage)
	TAB3 = ReadLine(ReadLanguage)
	LABEL1 = ReadLine(ReadLanguage)
	LABEL2 = ReadLine(ReadLanguage)
	LABEL3 = ReadLine(ReadLanguage)
	LABEL4 = ReadLine(ReadLanguage)
	LABEL5 = ReadLine(ReadLanguage)
	LABEL6 = ReadLine(ReadLanguage)
	LABEL7 = ReadLine(ReadLanguage)
	MENU1 = ReadLine(ReadLanguage)
	MENU2 = ReadLine(ReadLanguage)
	MENU3 = ReadLine(ReadLanguage)
	MENU4 = ReadLine(ReadLanguage)
	MENU5 = ReadLine(ReadLanguage)
	MENU6 = ReadLine(ReadLanguage)
	MENU7 = ReadLine(ReadLanguage)
	BUTTON1 = ReadLine(ReadLanguage)
	BUTTON2 = ReadLine(ReadLanguage)
	BUTTON3 = ReadLine(ReadLanguage)
	BUTTON4 = ReadLine(ReadLanguage)
	ERROR1 = ReadLine(ReadLanguage)
	ERROR2 = ReadLine(ReadLanguage)
	ERROR3 = ReadLine(ReadLanguage)
	ERROR4 = ReadLine(ReadLanguage)
	ERROR5 = ReadLine(ReadLanguage)
	ERROR6 = ReadLine(ReadLanguage)
	ERROR7 = ReadLine(ReadLanguage)
	ERROR8 = ReadLine(ReadLanguage)	
	ERROR9 = ReadLine(ReadLanguage)	
	ERROR10 = ReadLine(ReadLanguage)	
	STATUS1 = ReadLine(ReadLanguage)
	STATUS2 = ReadLine(ReadLanguage)
	STATUS3 = ReadLine(ReadLanguage)
	STATUS4 = ReadLine(ReadLanguage)
	STATUS5 = ReadLine(ReadLanguage)
	STATUS6 = ReadLine(ReadLanguage)
	STATUS7 = ReadLine(ReadLanguage)
	STATUS8 = ReadLine(ReadLanguage)
	STATUS9 = ReadLine(ReadLanguage)
	
	CloseFile(ReadLanguage)
Else
	?Win32
	EXPLAINTEXT1 = "Firstly we need to install the drivers of our Arduino board. If you have already done this before please proceed to step 2. Also if you are in a school this may have already been done for you, please confirm with your teacher as to whether you need to do this step.~n~n"+..
	"INSTRUCTIONS ~n~n"+..
	"A) Plug one end of your USB cable into the Arduino and the other into a USB socket on your computer. The power light on the LED will light up and you may get a 'Found New Hardware' message from Windows. Ignore this message and cancel any attempts that Windows makes to try and install drivers automatically for you.~n~n"+..
	"B) We now load up the Device Manager. This is accessed in different ways depending on your version of Windows. In Windows Vista/7, you first have to open the Control Panel, then select View by: 'Large icons', and you should find 'Device Manager' in the list. In Windows XP, first open Control Panel then click 'Administrative Tools' then 'Computer Management' and then select 'Device Manager' from the list on the left.~n~n"+..
	"C) Under the section 'Other Devices' you should see an icon for 'unknown device' with a little yellow warning triangle next to it. This is your Arduino.~n~n"+..
	"D) Right-click on the device and select the top menu option (Update Driver Software...). You will then be prompted in Windows Vista/7 to either 'Search Automatically for updated driver software' or 'Browse my computer for driver software'. Or prompted in Windows XP to 'Install the software automatically' or 'Install from a list or specific location'. Select the option 'Browse my computer for driver software'/'Install from a list or specific location' and navigate to the drivers folder contained within this programs folder.~n~n"+..
	"E) Click 'Next' and you may get a security warning, if so, allow the software to be installed. Once the software has been installed, you will get a confirmation message.~n~n"+..
	"F) Now proceed to step 2.~n~n"+..
	"[Credit for the above text goes to: https://learn.adafruit.com/lesson-0-getting-started/installing-arduino-windows]"
	
	EXPLAINTEXT2 = ""
	EXPLAINTEXT3 = ""
	APPWINTITLE = "Arduino Scratch Server Starter"
	APPLOGTITLE = "Log"
	APPCODEVIEWTITLE = "Code"
	
	TAB1 = "Step 1 - Arduino Driver"
	TAB2 = "Step 2 - Uploading"
	TAB3 = "Step 3 - Start Server"
	LABEL1 = "Port: "
	LABEL2 = "Refresh"
	LABEL3 = "Board: "
	LABEL4 = "Status of Upload: "
	LABEL5 = "Status of Helper App: "
	LABEL6 = "Scratch File: "
	LABEL7 = "Browse"
	MENU1 = "&Quit"
	MENU2 = "&Debug Log"
	MENU3 = "&File"
	MENU4 = "&View"
	MENU5 = "&About"
	MENU6 = "&Toggle Advanced Options"
	MENU7 = "&View Code "
	BUTTON1 = "Start Upload"
	BUTTON2 = "Finished Upload. Upload Again?"
	BUTTON3 = "Stop"
	BUTTON4 = "Start Helper App"
	
	ERROR1 = "Please Select a Port and Board"
	ERROR2 = "Closing now may cause damage to your Arduino if you do not wait for it to finish. Do you still wish to close?"
	ERROR3 = "Please Select a Port"
	ERROR4 = "Helper App could not start. Please make sure you have java installed on your system!"
	ERROR5 = "ArduinoUploader could not start."
	ERROR6 = "Error"
	ERROR7 = "Failed to generate Arduino code"
	ERROR8 = "Please install Arduino IDE into your applications folder (http://arduino.cc/en/Main/Software)"
	ERROR9 = "Cannot find Scratch Files."
	ERROR10 = "Cannot copy Scratch Files."
		
	STATUS1 = "Not Started Yet"
	STATUS2 = "Stopped"
	STATUS3 = "Stopped By User"
	STATUS4 = "Error (see log)"
	STATUS5 = "Finished"
	STATUS6 = "Uploading..."
	STATUS7 = "Compiling..."
	STATUS8 = "Started!"
	STATUS9 = "Starting..."	

	?MacOS
	EXPLAINTEXT1 = "Firstly we need to install the Arduino program and in some cases a driver. If you have already done this before please proceed to step 2. Also if you are in a school this may have already been done for you, please confirm with your teacher as to whether you need to do this step.~n~n"+..
	"INSTRUCTIONS ~n~n"+..
	"A) Goto http://arduino.cc/en/Main/Software and download the latest stable version of the Arduino IDE, at time of writing that is version 1.0.5. ~n~n"+..
	"B) Now install the Arduino program into your Applications folder. ~n~n"+..
	"C) If you're using an older board ( Duemilanove, Diecimila, or any board with an FTDI driver chip that looks like the picture here: http://arduino.cc/en/Guide/MacOSX#toc3 ) you will need to install the drivers for the FTDI chip on the board. To get the drivers see http://www.ftdichip.com/Drivers/VCP.htm. ~n~n"+..
	"D) Plug in your Arduino, if any windows pop up you can close them off. Now continue to step 2."
	
	EXPLAINTEXT2 = ""
	
	EXPLAINTEXT3 = ""
	APPWINTITLE = "Arduino Scratch Server Starter"
	APPLOGTITLE = "Log"
	APPCODEVIEWTITLE = "Code"
	
	TAB1 = "Step 1 - Arduino Installation"
	TAB2 = "Step 2 - Uploading"
	TAB3 = "Step 3 - Start Server"
	LABEL1 = "Port: "
	LABEL2 = "Refresh"
	LABEL3 = "Board: "
	LABEL4 = "Status of Arduino IDE: "
	LABEL5 = "Status of Helper App: "
	LABEL6 = "Scratch File: "
	LABEL7 = "Browse"	
	MENU1 = "&Quit"
	MENU2 = "&Debug Log"
	MENU3 = "&File"
	MENU4 = "&View"
	MENU5 = "&About"
	MENU6 = "&Toggle Advanced Options"
	MENU7 = "&View Code "
	BUTTON1 = "Start Arduino IDE"
	BUTTON2 = "Start Arduino IDE Again?"
	BUTTON3 = "Stop"
	BUTTON4 = "Start Helper App"
	
	ERROR1 = "Please Select a Port and Board"
	ERROR2 = "Closing now will close the Arduino IDE. Do you still wish to close?"
	ERROR3 = "Please Select a Port"
	ERROR4 = "Helper App could not start. Please make sure you have java installed on your system!"
	ERROR5 = "ArduinoUploader could not start."
	ERROR6 = "Error"
	ERROR7 = "Failed to generate Arduino code"
	ERROR8 = "Please install Arduino IDE into your applications folder (http://arduino.cc/en/Main/Software)"
	ERROR9 = "Cannot find Scratch Files."
	ERROR10 = "Cannot copy Scratch Files."
		
	STATUS1 = "Not Started Yet"
	STATUS2 = "Stopped"
	STATUS3 = "Stopped By User"
	STATUS4 = "Error (see log)"
	STATUS5 = "Finished"
	STATUS6 = "Uploading..."
	STATUS7 = "Compiling..."
	STATUS8 = "Started!"
	STATUS9 = "Starting..."	
		
	?
EndIf 

Global PortSelection:int = 0
Global BoardSelection:int = 0
Global ScratchFile:String = ""
Global ScratchFileModified:int = 0

'Check if settings file available

If FileType(GetUserAppDir() + Slash + "A4S-Embedded") = 2 then
	'Continue
Else
	'Create Directory
	CreateDir(GetUserAppDir() + Slash + "A4S-Embedded")
	'Check that directory actually created
	If FileType(GetUserAppDir() + Slash + "A4S-Embedded") = 2 then
		'Continue
	Else	
		Notify("Error Creating User Folder", True)
	EndIf
EndIf 

If FileType(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "Settings.txt") = 1 then
	'Continue
Else 
	'CreateFile
	UpdateSettings()
	If FileType(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "Settings.txt") = 1 then
	
	Else
		Notify("Error Creating User settings file",True)	
	EndIf
EndIf

Local SettingsFile:TStream 
SettingsFile = ReadFile(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "Settings.txt")
PortSelection = Int(ReadLine(SettingsFile))
BoardSelection = int(ReadLine(SettingsFile) )
ScratchFile = ReadLine(SettingsFile)
CloseFile(SettingsFile)

Global BOARDCHOICES:String[] = ["1 - Arduino Uno", "2 - Arduino Leonardo", "3 - Arduino Esplora", "4 - Arduino Micro", "5 - Arduino Duemilanove (328)", "6 - Arduino Duemilanove (168)", "7 - Arduino Nano (328)", "8 - Arduino Nano (168)", "9 - Arduino Mini (328)", "10 - Arduino Mini (168)", "11 - Arduino Pro Mini (328)", "12 - Arduino Pro Mini (168)", "13 - Arduino Mega 2560/ADK", "14 - Arduino Mega 1280", "15 - Arduino Mega 8", "16 - Microduino Core+ (644)", "17 - Freematics OBD-II Adapter"]

Global A4SHelperApp:A4SHelperAppType
A4SHelperApp = New A4SHelperAppType
A4SHelperApp.Run()

Type A4SHelperAppType Extends wxApp
	Field A4SHelperFrame:A4SHelperFrameType

	
	Method OnInit:Int()	
		wxImage.AddHandler( New wxICOHandler)			

		A4SHelperFrame = A4SHelperFrameType(New A4SHelperFrameType.Create(Null , wxID_ANY, APPWINTITLE, - 1, - 1, 600, 490) )
		
		Return True

	End Method
	
	Method OnExit()
		TProcess.TerminateAll()
		Super.OnExit()
	End Method
	
End Type



Type A4SHelperFrameType Extends wxFrame

	Field ScratchFileLocation:wxTextCtrl
	Field PortComboBox:wxComboBox
	Field BoardComboBox:wxComboBox 
	Field BaText:wxStaticText

	Field UploadButton:wxButton 
		
	
	Field UploadProcess:TProcess
	
	Field StatusText:wxStaticText	
		
	Field A4SHelperLog:A4SHelperLogType
	Field A4SHelperCodeView:A4SHelperCodeViewType
	Field MenuBar:wxMenuBar
	
	Field CodeConverterTimer:wxTimer
	
	Field AdvancedOptionsShown = True   

	Method OnInit()	
		CodeConverterTimer = New wxTimer.Create(Self, CCT)
		
		?MacOS
		Local MessageBox:wxMessageDialog
		
		CreateSb2Status = CreateSb2Files()
		
		If CreateSb2Status = 1 Then 
			MessageBox = New wxMessageDialog.Create(Null , ERROR9 , ERROR6 , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return
		ElseIf CreateSb2Status = 2 Then
			MessageBox = New wxMessageDialog.Create(Null , ERROR10 , ERROR6 , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return
		EndIf 
		?	
			
		MenuBar = New wxMenuBar.Create()
		Local FileMenu:wxMenu = New wxMenu.Create()
		FileMenu.Append(AID, MENU5)
		FileMenu.Append(wxID_CLOSE, MENU1)
		
		Local ViewMenu:wxMenu = New wxMenu.Create()
		ViewMenu.Append(TCOD, MENU7)
		ViewMenu.Append(TLOG, MENU2)
		ViewMenu.Append(TADO, MENU6)
		MenuBar.Append(FileMenu, MENU3)
		MenuBar.Append(ViewMenu, MENU4)
		Self.SetMenuBar(MenuBar)
		

		 
		A4SHelperLog = A4SHelperLogType(New A4SHelperLogType.Create(Null , wxID_ANY, APPLOGTITLE, - 1, - 1, 600, 450) )
		A4SHelperCodeView = A4SHelperCodeViewType(New A4SHelperCodeViewType.Create(Null , wxID_ANY, APPCODEVIEWTITLE, - 1, - 1, 600, 450) )

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		
		Local Tabs:wxNotebook = New wxNotebook.Create(Self, wxID_ANY , -1 , -1 , -1 , -1 , 0)


		Local DriverPanel:wxPanel = New wxPanel.Create(Tabs , - 1)
		Local DriverPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	

	
		Local S1_TextPanel:wxPanel = New wxPanel.Create(DriverPanel , - 1)
		Local S1_TextPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		Local S1_ExplainText1:wxTextCtrl = 	New wxTextCtrl.Create(S1_TextPanel , wxID_ANY , EXPLAINTEXT1 , - 1 , - 1 , - 1 , - 1 , wxTE_MULTILINE | wxTE_READONLY)
		
		
		S1_TextPanel.setbackgroundcolour(New wxColour.createcolour(240,240,240))
		S1_TextPanelvbox.Add(S1_ExplainText1 , 1 , wxEXPAND | wxALL , 4 )
		S1_TextPanel.SetSizer(S1_TextPanelvbox)
		
		DriverPanelvbox.Add(S1_TextPanel , 1 , wxEXPAND | wxALL , 4 )

		DriverPanel.SetSizer(DriverPanelvbox)

		
		Tabs.AddPage(DriverPanel,TAB1)
		
		
		Local UploadPanel:wxPanel = New wxPanel.Create(Tabs , - 1)
		Local UploadPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		
		Local S2_TextPanel:wxPanel = New wxPanel.Create(UploadPanel , - 1)
		Local S2_TextPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		Local S2_ExplainText1:wxTextCtrl = 	New wxTextCtrl.Create(S2_TextPanel , wxID_ANY , EXPLAINTEXT2 , -1 , -1 , - 1 , - 1 , wxTE_MULTILINE| wxTE_READONLY )
		
		'S2_ExplainText1.setbackgroundcolour(New wxColour.createcolour(255,255,240))
		S2_TextPanel.setbackgroundcolour(New wxColour.createcolour(240,240,240))
		S2_TextPanelvbox.Add(S2_ExplainText1 , 1 , wxEXPAND | wxALL , 4 )
		S2_TextPanel.SetSizer(S2_TextPanelvbox)
		
		
		Line4hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local SFLText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , LABEL6 , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		ScratchFileLocation = 	New wxTextCtrl.Create(UploadPanel , SFC , ScratchFile , - 1 , - 1 , - 1 , - 1)
		Local BrowseScratchFileButton:wxButton = New wxButton.Create(UploadPanel , BSFB , LABEL7)	
		Line4hbox.Add(SFLText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		Line4hbox.Add(ScratchFileLocation , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 4)
		Line4hbox.Add(BrowseScratchFileButton , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
	
		Line1hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local PText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , LABEL1 , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		PortComboBox = New wxComboBox.Create(UploadPanel , PCB1 , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_READONLY)
		Local RefreshPortsButton:wxButton = New wxButton.Create(UploadPanel , RPB , LABEL2)	

		Line1hbox.Add(PText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		Line1hbox.Add(PortComboBox , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		Line1hbox.Add(RefreshPortsButton , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		
		?Win32
		Line2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local BText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , LABEL3 , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		BoardComboBox = New wxComboBox.Create(UploadPanel , BCB , BOARDCHOICES[BoardSelection] , BOARDCHOICES , - 1 , - 1 , - 1 , - 1 , wxCB_READONLY)		
		
		Line2hbox.Add(BText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		Line2hbox.Add(BoardComboBox , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )		
		?
		
		UploadPanelvbox.Add(S2_TextPanel , 10 , wxEXPAND | wxALL , 4 )
		UploadPanelvbox.AddSizer(Line4hbox, 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		UploadPanelvbox.AddSizer(Line1hbox, 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )

		?Win32
		UploadPanelvbox.AddSizer(Line2hbox, 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		?
				
				
		Line3hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)
		Local SText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , LABEL4 , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		StatusText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , "" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		StatusText.SetLabel(STATUS1)
		StatusText.SetForegroundColour(New wxColour.createcolour(255,0,0))	
		
		Line3hbox.Add(SText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		Line3hbox.Add(StatusText , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		UploadPanelvbox.AddSizer(Line3hbox, 0 , wxEXPAND | wxALL , 4 )		



		


		UploadButton = New wxButton.Create(UploadPanel , SSB , BUTTON1)
		UploadButton.setbackgroundcolour(New wxColour.createcolour(70,255,140))
		Local UploadFont:wxFont = UploadButton.GetFont()
		UploadFont.SetPointSize(12)
		UploadButton.setfont(UploadFont) 

		
		UploadPanelvbox.Add(UploadButton , 0 , wxEXPAND | wxALL , 4 )
	
		UploadPanel.SetSizer(UploadPanelvbox)
		
		Tabs.AddPage(UploadPanel,TAB2)
			
		
		vbox.Add(Tabs , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 0 )		
		Self.SetSizer(vbox)
		
		
		Self.UpdatePorts()
		Self.Center()
		Self.Show()		
		
		Connect(PCB1 , wxEVT_COMMAND_COMBOBOX_SELECTED , PortUpdatedFun)

		
		CodeConverterTimer.Start(1000)
		
		?Win32
		Connect(BCB , wxEVT_COMMAND_COMBOBOX_SELECTED , BoardUpdatedFun )		
		?
		
		Connect(RPB , wxEVT_COMMAND_BUTTON_CLICKED , UpdatePortsFun)
		Connect(BSFB, wxEVT_COMMAND_BUTTON_CLICKED, BrowseScratchFun)
		Connect(TLOG , wxEVT_COMMAND_MENU_SELECTED, ShowLogFun)
		Connect(TCOD , wxEVT_COMMAND_MENU_SELECTED, ShowCodeFun)
		Connect(TADO , wxEVT_COMMAND_MENU_SELECTED, ToggleAdvancedOptionsFun)		
		Connect(wxID_CLOSE, wxEVT_COMMAND_MENU_SELECTED, CloseFun)			
		Connect(AID, wxEVT_COMMAND_MENU_SELECTED, AboutFun)	
		Connect(SSB , wxEVT_COMMAND_BUTTON_CLICKED , UploadFun)
		
		Connect(SFC, wxEVT_COMMAND_TEXT_UPDATED, ScratchFileLocationUpdateFun)
		
		Connect(CCT, wxEVT_TIMER, CodeConverterRunFun)
		ConnectAny(wxEVT_CLOSE , CloseFun)
	End Method
	
	Function CodeConverterRunFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		A4SHelperFrame.CodeConverterRun()
	End Function
	
	Method CodeConverterRun()
		Local s:String
		If FileType(ScratchFile) = 1 then
			If FileTime(ScratchFile) > ScratchFileModified Or FileType(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino") = 0 then
				ScratchFileModified = FileTime(ScratchFile)

				A4SHelperLog.AddText("===============Processing Scratch Code===============~n")
				
				Local Process:TProcess = New TProcess.Create("..\A4S-Embedded\build\exe.win32-3.4\CommandLineConverter.exe -i~q" + ScratchFile + "~q -o~q" + GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino~q -t1", 1)
				
				Print
				
				Repeat
					If ProcessStatus(Process) = 1 then
						ProcessCodeConverterCMDOutput(Process, A4SHelperLog)
					Else	
						ProcessCodeConverterCMDOutput(Process, A4SHelperLog)
						Delay 100
						Exit
					EndIf	
					
					A4SHelperApp.Yield()
				Forever
				
				If FileType(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino") = 1 then
				
					Local CodeFile = ReadFile(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino")
					Self.A4SHelperCodeView.ClearText()
					Repeat
						s = ReadLine(CodeFile)
						Self.A4SHelperCodeView.AddText(s + "~n")
						If Eof(CodeFile) then Exit
					Forever
					CloseFile(CodeFile)
				
				Else
					Self.A4SHelperCodeView.ClearText()
				EndIf
										
				A4SHelperLog.AddText("===============================================~n")
			EndIf
		EndIf
	End Method
		
	Function ProcessCodeConverterCMDOutput(Process:TProcess,Console:A4SHelperLogType)
			Local s:String
			While Process.pipe.ReadAvail() Or Process.err.ReadAvail()	
				While Process.pipe.ReadAvail()
					s=Process.pipe.ReadString (Process.pipe.ReadAvail())
					If EmptyString(s) Then 
					
					Else
						Console.AddText(s)	
					EndIf 
				Wend 
				
				While Process.err.readavail()
					s=Process.err.ReadString (Process.err.ReadAvail())
					If EmptyString(s) Then 
					
					Else
						Console.AddText(s)	
					EndIf	
				Wend
				A4SHelperApp.Yield()
			Wend

			
		End Function	
	
	Function BrowseScratchFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		A4SHelperFrame.BrowseScratch()
	End Function
	
	Method BrowseScratch()
		Local Filter:String = "Scratch Files:sb2;All Files:*"
		Local ScratchFilename:String = RequestFile( "Select Scratch File", Filter$ )
		If ScratchFilename = "" then
		
		Else
			Self.ScratchFileLocation.SetValue(ScratchFilename)
			ScratchFile = ScratchFilename
			ScratchFileModified = 0
			Self.A4SHelperCodeView.ClearText()
			DeleteFile(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino")
			UpdateSettings()
		EndIf
		
	End Method
	
	Function ScratchFileLocationUpdateFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		ScratchFile = A4SHelperFrame.ScratchFileLocation.GetValue()
		ScratchFileModified = 0
		A4SHelperFrame.A4SHelperCodeView.ClearText()
		DeleteFile(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino")
		UpdateSettings()
	End Function
	
	Function ToggleAdvancedOptionsFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		A4SHelperFrame.ToggleAdvancedOptions()
	End Function
	
	Method ToggleAdvancedOptions()
		If AdvancedOptionsShown=True Then
			AdvancedOptionsShown = False
		Else
			AdvancedOptionsShown = True
		EndIf
	End Method
	
	?Win32
	Function BoardUpdatedFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		Local Selection:Int = A4SHelperFrame.BoardComboBox.GetSelection()
		
		If Selection = wxNOT_FOUND Then

		Else
			BoardSelection = Selection
			UpdateSettings()
		EndIf 
		
	End Function
	?
	
	Function PortUpdatedFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		Local Selection:Int
		
		Selection = A4SHelperFrame.PortComboBox.GetSelection()
			
		If Selection = wxNOT_FOUND Then
		
		Else
			PortSelection = Selection
			UpdateSettings()
			A4SHelperFrame.PortComboBox.SetSelection(Selection)
			
		EndIf 
		
	End Function
	
	Function AboutFun(event:wxEvent)
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Local Info:wxAboutDialogInfo = New wxAboutDialogInfo.Create()
		Info.seticon(Icon)
		Info.SetDescription("This is an application that handles automatically all the complicated parts of using Arduino with Scratch")

		Info.addDeveloper("Thomas Preece")
		Info.addDocWriter("Thomas Preece")
		Info.AddDocWriter("Simon Monk")

		Info.setName("A4S")
		Info.setVersion(VERSION)
		Info.setWebsite("http://thomaspreece.com","Lead developers personal website")
		wxAboutBox(Info)
	End Function
	
	
	
	Function ShowCodeFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		A4SHelperFrame.A4SHelperCodeView.Show(1)
	End Function
	
	Function ShowLogFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		A4SHelperFrame.A4SHelperLog.Show(1)
	End Function
	
	Function CloseFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		If A4SHelperFrame.UploadButton.GetLabel() = BUTTON1 Or A4SHelperFrame.UploadButton.GetLabel() = BUTTON2 Then
			
		Else 
			Local MessageBox:wxMessageDialog 
			MessageBox = New wxMessageDialog.Create(Null, ERROR2 , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_YES Then
				
			Else
				Return 
			EndIf
		EndIf 

		A4SHelperFrame.A4SHelperLog.Destroy()
		A4SHelperApp.OnExit()
		End 		
		
	End Function 
	
	Function UploadFun(event:wxEvent)

		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
			
		If A4SHelperFrame.UploadButton.GetLabel() = BUTTON1 Or A4SHelperFrame.UploadButton.GetLabel() = BUTTON2 then
			Local Port:String = A4SHelperFrame.PortComboBox.GetValue()
			?Win32
			Local Board:Int = Int(A4SHelperFrame.BoardComboBox.GetValue())
			?Not Win32
			Local Board:Int = 1
			?
			
			Local MessageBox:wxMessageDialog
			If Port = "" Or Port = " " Then
				MessageBox = New wxMessageDialog.Create(Null , ERROR1 , ERROR6 , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()	
				Return
			EndIf
			A4SHelperFrame.CodeConverterRun()
			A4SHelperFrame.ProcessUpload(ExtractPort(Port), Board)
		Else
			MessageBox = New wxMessageDialog.Create(Null, ERROR2 , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_YES Then
				A4SHelperFrame.StatusText.SetLabel(STATUS3)
				A4SHelperFrame.A4SHelperLog.AddText("Process Terminated By User~n")	
				TerminateProcess(A4SHelperFrame.UploadProcess)
			EndIf
			MessageBox.Free()	
		EndIf 
		
	End Function
	
	Method ProcessUpload(Port:String, Board:Int)

		Local MessageBox:wxMessageDialog
		A4SHelperLog.AddText("===============Uploading===============~n")	
		UploadButton.SetLabel(BUTTON3)
		UploadButton.setbackgroundcolour(New wxColour.createcolour(255,100,100))
		A4SHelperLog.AddText("Starting Upload on "+Port+" ~n")
		StatusText.SetLabel("Started")
		StatusText.SetForegroundColour(New wxColour.createcolour(255,140,0))	

		If FileType(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino") = 0 then
			MessageBox = New wxMessageDialog.Create(Null , ERROR7 , ERROR6 , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()
			
			UploadButton.SetLabel(BUTTON1)
			UploadButton.setbackgroundcolour(New wxColour.createcolour(70,255,140))
		
			StatusText.SetLabel(STATUS4)
			StatusText.SetForegroundColour(New wxColour.createcolour(255,0,0))
			A4SHelperLog.AddText("Failed to generate Arduino Source")						Return
		EndIf 

		?Not MacOS
		A4SHelperLog.AddText("Starting: ArduinoUploader.exe  " + Chr(34) + GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino" + Chr(34) + " " + Board + " " + Port + " ~n")
		ChangeDir("ArduinoUploader")
		Self.UploadProcess = CreateProcess("ArduinoUploader.exe  " + Chr(34) + GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino" + Chr(34) + " " + Board + " " + Port, 1)
		ChangeDir("..")
		?MacOS
		If FileType("/Applications/Arduino.app/Contents/MacOS/JavaApplicationStub")=1 Then 
			Self.UploadProcess = CreateProcess("/Applications/Arduino.app/Contents/MacOS/JavaApplicationStub " + Chr(34) + GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino" + Chr(34), 1)
		Else
			MessageBox = New wxMessageDialog.Create(Null , ERROR8 , ERROR6 , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
		EndIf 
		?
		
		
		Local s:String
		
		If UploadProcess = Null Then 
			MessageBox = New wxMessageDialog.Create(Null , ERROR5 , ERROR6 , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			UploadButton.SetLabel(BUTTON1)
			UploadButton.setbackgroundcolour(New wxColour.createcolour(70,255,140))
		
			StatusText.SetLabel(STATUS4)
			StatusText.SetForegroundColour(New wxColour.createcolour(255,0,0))
			?Win32
			A4SHelperLog.AddText("ArduinoUploader could not start. This probabily means ArduinoUploader.exe is missing or corrupt. Please reinstall ArduinoUploader.~n")
			?MacOS
			A4SHelperLog.AddText("Arduino could not start. This could be because the installation is corrupt or missing~n")			
			?
			Return 

		EndIf 
		
		Repeat
			If ProcessStatus(UploadProcess)=1 Then 
				ProcessUploadCMDOutput(UploadProcess,A4SHelperLog,StatusText)
			Else	
				ProcessUploadCMDOutput(UploadProcess,A4SHelperLog,StatusText)
				Delay 100
				Exit
			EndIf	
			
			A4SHelperApp.Yield()
		Forever

		?Win32
		If StatusText.GetLabel()=STATUS5 Or StatusText.GetLabel()=STATUS3 Then
		
		Else
			StatusText.SetLabel(STATUS4)
			StatusText.SetForegroundColour(New wxColour.createcolour(255,0,0))
		EndIf 
		?MacOS
		'Mac version just loads up Arduino Environment, so always show finished correctly status
		StatusText.SetLabel(STATUS5)
		StatusText.SetForegroundColour(New wxColour.createcolour(0,120,0))		
		?
		
		UploadButton.SetLabel(BUTTON2)
		UploadButton.setbackgroundcolour(New wxColour.createcolour(70,255,140))
		TerminateProcess(UploadProcess)
		'ChangeDir("..")
		
		A4SHelperLog.AddText("~n~n===============Finished Uploading===============~n")	
		Return	
				
	End Method
	
	
	
	Function ProcessUploadCMDOutput(Process:TProcess,Console:A4SHelperLogType,Status:wxStaticText)
		Local s:String
		Local a:Int = 0
		Local Totals:String = ""
		While Process.pipe.ReadAvail() Or Process.err.ReadAvail()	
			While Process.pipe.readavail()
				s=Process.pipe.ReadString (Process.pipe.ReadAvail())
				If EmptyString(s) Then 
				
				Else
					Totals = Totals + s
					If Instr(Totals, "avrdude.exe done.  Thank you.") Then
						If Status.GetLabel()=STATUS4 Then
						
						Else
							Status.SetLabel(STATUS5)
							Status.SetForegroundColour(New wxColour.createcolour(0,120,0))							
						EndIf 
					ElseIf Instr(Totals,"not in sync") Then
						If Status.GetLabel()=STATUS3 Then 
						
						Else
							Console.AddText("Arduino out of sync!.~n")
							Status.SetLabel(STATUS4)
							Status.SetForegroundColour(New wxColour.createcolour(255,0,0))							
						EndIf 
					ElseIf Instr(Totals,"Writing") Then 
						If Status.GetLabel()=STATUS3 Then 
						
						Else
							Status.SetLabel(STATUS6)
							Status.SetForegroundColour(New wxColour.createcolour(255,140,0))						
						EndIf 
					ElseIf Instr(Totals,"Compiliation") Then
						If Status.GetLabel()=STATUS3 Then 
						
						Else					
							Status.SetLabel(STATUS7)
							Status.SetForegroundColour(New wxColour.createcolour(255,140,0))	
						EndIf
					EndIf 
					Console.AddText(s)	
				EndIf 
			Wend 
			
			While Process.err.readavail()
				s=Process.err.ReadString (Process.err.ReadAvail())
				If EmptyString(s) Then 
				
				Else
					Console.AddText(s)	
				EndIf	
			Wend
			A4SHelperApp.Yield()
		Wend

		
	End Function
	
	Function UpdatePortsFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		A4SHelperFrame.UpdatePorts()
	End Function
	
	
	Method UpdatePorts()
		Local COMPortsList:TList = GetPorts()
		A4SHelperLog.AddText("===============Refreshing Ports===============~n")	

	
		PortComboBox.Clear()
	
		For Port:String = EachIn COMPortsList
			PortComboBox.Append(Port)
		Next
		If CountList(COMPortsList)-1<PortSelection Then 
			PortSelection=0
		EndIf 
		
		PortComboBox.SetSelection(PortSelection)
		
		If ListIsEmpty(COMPortsList) Then
			A4SHelperLog.AddText("No COM ports found. ~nThis program will not find ports that are currently in use by another program. Please close any open programs that are using the port.~n")		
		Else
			If CountList(COMPortsList)=1 Then
				A4SHelperLog.AddText(CountList(COMPortsList)+" COM port found. ~n")
			Else
				A4SHelperLog.AddText(CountList(COMPortsList)+" COM ports found. ~n")			
			EndIf
		EndIf
	
		A4SHelperLog.AddText("===============Finished Refreshing Ports===============~n")
	End Method
End Type


Type A4SHelperLogType Extends wxFrame
	Field LogBox:wxTextCtrl
	
	Method OnInit()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )		
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		LogBox = New wxTextCtrl.Create(Self, wxID_ANY, "", -1 , -1 , -1 , -1, wxTE_READONLY | wxTE_MULTILINE | wxTE_BESTWRAP)
		hbox.Add(LogBox,  1 , wxEXPAND, 0)		
		SetSizer(hbox)
		Centre()
		Show(0)	
		ConnectAny(wxEVT_CLOSE , CloseLog)
	End Method
	
	Function CloseLog(event:wxEvent)
		Log1:A4SHelperLogType = A4SHelperLogType(event.parent)
		Log1.Show(0)
	End Function

	Method AddText(Tex:String)
		LogBox.AppendText(Tex)	
	End Method
	
End Type

Type A4SHelperCodeViewType Extends wxFrame
	Field CodeBox:wxTextCtrl
	
	Method OnInit()
		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON,wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )		
		Local hbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		CodeBox = New wxTextCtrl.Create(Self, wxID_ANY, "", - 1 , - 1 , - 1 , - 1, wxTE_READONLY | wxTE_MULTILINE | wxTE_BESTWRAP)
		hbox.Add(CodeBox, 1 , wxEXPAND, 0)		
		SetSizer(hbox)
		Centre()	
		Show(0)	
		ConnectAny(wxEVT_CLOSE , CloseLog)
	End Method
	
	Function CloseLog(event:wxEvent)
		Log1:A4SHelperCodeViewType = A4SHelperCodeViewType(event.parent)
		Log1.Show(0)
	End Function

	Method AddText(Tex:String)
		CodeBox.AppendText(Tex)	
	End Method

	Method ClearText()
		CodeBox.Clear()
	End Method
	
End Type

Function ExtractPort:String(Text:String)
	For a=1 To Len(Text)
		If Mid(Text,a,3)=" - " Then
			Return Left(Text,a-1)
		EndIf 
	Next
End Function

Function GetPorts:TList()
	Local COMPortsList:TList = CreateList()
	
	Local Ports:TList = TSerial.listPorts()

	For Local Port:TSerialPortInfo = EachIn Ports
		?Not MacOS
		If Left(Port.portName,3)="COM" Then
			If Port.productName="" Or Port.productName=" " Then 
				ListAddFirst(COMPortsList,Port.portName+" - [No Product Name]")
			Else
				ListAddFirst(COMPortsList, Port.portName + " - " + Port.productName)
			EndIf 
		EndIf
		?MacOS
		If Left(Port.portName,5)="/dev/" Then
			If Port.productName="" Or Port.productName=" " Then 
				ListAddFirst(COMPortsList, Port.portName + " - [No Product Name]")
			Else		
				ListAddFirst(COMPortsList, Port.portName + " - " + Port.productName)
			EndIf 
		EndIf
		?
	Next
	
	If CountList(COMPortsList) = 0 Then 
		ListAddLast(COMPortsList,"")
	EndIf 
	
	Return COMPortsList
End Function


Function UpdateSettings()
	Local SettingsFile:TStream
	SettingsFile = WriteFile(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "Settings.txt")
	WriteLine(SettingsFile, PortSelection)
	WriteLine(SettingsFile, BoardSelection)
	WriteLine(SettingsFile, ScratchFile)
	CloseFile(SettingsFile)
End Function

Function CreateSb2Files()
	If FileType("examples" + Slash + "ImportBlocks.sb2") = 1 then
	
	Else
		Return 2
	EndIf 
			
	If FileType(GetUserDocumentsDir() + Slash + "SuperEasy-A4S-Embedded") = 2 then
	
	Else
		CreateDir(GetUserDocumentsDir() + Slash + "SuperEasy-A4S-Embedded")
	EndIf
	If FileType(GetUserDocumentsDir() + Slash + "SuperEasy-A4S-Embedded") = 2 then
	
	Else
		Return 1
	EndIf
	
	If FileType(GetUserDocumentsDir() + Slash + "SuperEasy-A4S-Embedded" + Slash + "ImportBlocks.sb2") = 1 then
	
	Else
		CopyFile("examples" + Slash + "ImportBlocks.sb2", GetUserDocumentsDir() + Slash + "SuperEasy-A4S-Embedded" + Slash + "ImportBlocks.sb2")
	EndIf
	If FileType(GetUserDocumentsDir() + Slash + "SuperEasy-A4S-Embedded" + Slash + "ImportBlocks.sb2") = 1 then
	
	Else
		Return 1
	EndIf	
		
	Return 0
End Function 

Function EmptyString(Text:String)
	If Text = "" Or Text = " " Then 
		Return 1
	EndIf
	Local Empty=True
	For a=1 To Len(Text)
		If Mid(Text,a,1)=Chr(10) Or Mid(Text,a,1)=" " Then
		
		Else
			Empty = False 
			Exit
		EndIf
	Next
	
	Return Empty
End Function

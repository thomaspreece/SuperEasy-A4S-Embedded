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
Import BaH.Locale

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

?Win32
Global AppResources:String=""
Global PROGRAMICON:String = "Resources"+Slash+"microcontroller.ico"
?MacOS
Global AppResources:String= ExtractDir(AppFile) + "/../Resources/"
Global PROGRAMICON:String = "microcontroller.ico"
?
ChangeDir(AppResources)

LoadLocaleFile("LanguageFile.blf")
SetCurrentLocale(GetDefaultLocale() )

Global PortSelection:int = 0
Global BoardSelection:int = 0
Global ScratchFile:String = ""
Global ScratchFileModified:int = 0
Global CodeViewShown = False

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
BoardSelection = Int(ReadLine(SettingsFile) )
ScratchFile = ReadLine(SettingsFile)
CodeViewShown = Int(ReadLine(SettingsFile) )
CloseFile(SettingsFile)

Global BOARDCHOICES:String[] = ["1 - Arduino Uno", "2 - Arduino Leonardo", "3 - Arduino Esplora", "4 - Arduino Micro", "5 - Arduino Duemilanove (328)", "6 - Arduino Duemilanove (168)", "7 - Arduino Nano (328)", "8 - Arduino Nano (168)", "9 - Arduino Mini (328)", "10 - Arduino Mini (168)", "11 - Arduino Pro Mini (328)", "12 - Arduino Pro Mini (168)", "13 - Arduino Mega 2560/ADK", "14 - Arduino Mega 1280", "15 - Arduino Mega 8", "16 - Microduino Core+ (644)", "17 - Freematics OBD-II Adapter"]

Global A4SHelperApp:A4SHelperAppType
A4SHelperApp = New A4SHelperAppType
A4SHelperApp.Run()

Type A4SHelperAppType Extends wxApp
	Field A4SHelperFrame:A4SHelperFrameType

	
	Method OnInit:Int()	
		wxImage.AddHandler( New wxICOHandler)			

		A4SHelperFrame = A4SHelperFrameType(New A4SHelperFrameType.Create(Null , wxID_ANY, GetLocaleText("AppTitle"), - 1, - 1, 600, 490) )
		
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
	
	Field AdvancedOptionsShown = False
	

	Method OnInit()	
		CodeConverterTimer = New wxTimer.Create(Self, CCT)
		
		?MacOS
		Local MessageBox:wxMessageDialog
		
		CreateSb2Status = CreateSb2Files()
		
		If CreateSb2Status = 1 Then 
			MessageBox = New wxMessageDialog.Create(Null , GetLocaleText("ErrorFindScratchFiles") , GetLocaleText("ErrorTitle") , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return
		ElseIf CreateSb2Status = 2 Then
			MessageBox = New wxMessageDialog.Create(Null , GetLocaleText("ErrorCopyScratchFiles") , GetLocaleText("ErrorTitle") , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			Return
		EndIf 
		?	
			
		MenuBar = New wxMenuBar.Create()
		Local FileMenu:wxMenu = New wxMenu.Create()
		FileMenu.Append(AID, GetLocaleText("MenuAbout"))
		FileMenu.Append(wxID_CLOSE, GetLocaleText("MenuQuit") )
		
		Local ViewMenu:wxMenu = New wxMenu.Create()
		ViewMenu.Append(TCOD, GetLocaleText("MenuViewCode") )
		ViewMenu.Append(TLOG, GetLocaleText("MenuDebugLog") )
		'ViewMenu.Append(TADO, GetLocaleText("MenuTAdvOpt") )
		MenuBar.Append(FileMenu, GetLocaleText("MenuFile"))
		MenuBar.Append(ViewMenu, GetLocaleText("MenuView") )
		Self.SetMenuBar(MenuBar)
				 
		A4SHelperLog = A4SHelperLogType(New A4SHelperLogType.Create(Null , wxID_ANY, GetLocaleText("AppLogTitle"), - 1, - 1, 600, 450) )
		A4SHelperCodeView = A4SHelperCodeViewType(New A4SHelperCodeViewType.Create(Null , wxID_ANY, GetLocaleText("AppCodeTitle"), - 1, - 1, 600, 490) )
		
		If CodeViewShown = True then
			Self.A4SHelperCodeView.Show(1)
		Else
			Self.A4SHelperCodeView.Show(0)
		EndIf

		Local Icon:wxIcon = New wxIcon.CreateFromFile(PROGRAMICON, wxBITMAP_TYPE_ICO)
		Self.SetIcon( Icon )
		
		Local vbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)		
		
		Local Tabs:wxNotebook = New wxNotebook.Create(Self, wxID_ANY , -1 , -1 , -1 , -1 , 0)


		Local DriverPanel:wxPanel = New wxPanel.Create(Tabs , - 1)
		Local DriverPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	

	
		Local S1_TextPanel:wxPanel = New wxPanel.Create(DriverPanel , - 1)
		Local S1_TextPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)
		?WIN32						
			Local S1_ExplainText1:wxTextCtrl = 	New wxTextCtrl.Create(S1_TextPanel , wxID_ANY , GetLocaleText("Tab1ExplainText_WIN") , - 1 , - 1 , - 1 , - 1 , wxTE_MULTILINE | wxTE_READONLY)
		?MacOS
			Local S1_ExplainText1:wxTextCtrl = 	New wxTextCtrl.Create(S1_TextPanel , wxID_ANY , GetLocaleText("Tab1ExplainText_MAC") , - 1 , - 1 , - 1 , - 1 , wxTE_MULTILINE | wxTE_READONLY)
		?
		
		S1_TextPanel.SetBackgroundColour(New wxColour.CreateColour(240, 240, 240) )
		S1_TextPanelvbox.Add(S1_ExplainText1 , 1 , wxEXPAND | wxALL , 4 )
		S1_TextPanel.SetSizer(S1_TextPanelvbox)
		
		DriverPanelvbox.Add(S1_TextPanel , 1 , wxEXPAND | wxALL , 4 )

		DriverPanel.SetSizer(DriverPanelvbox)

		
		Tabs.AddPage(DriverPanel, GetLocaleText("Tab1") )
		
		
		Local UploadPanel:wxPanel = New wxPanel.Create(Tabs , - 1)
		Local UploadPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		
		Local S2_TextPanel:wxPanel = New wxPanel.Create(UploadPanel , - 1)
		Local S2_TextPanelvbox:wxBoxSizer = New wxBoxSizer.Create(wxVERTICAL)	
		Local S2_ExplainText1:wxTextCtrl = 	New wxTextCtrl.Create(S2_TextPanel , wxID_ANY , GetLocaleText("Tab2ExplainText") , - 1 , - 1 , - 1 , - 1 , wxTE_MULTILINE | wxTE_READONLY )
		
		'S2_ExplainText1.setbackgroundcolour(New wxColour.createcolour(255,255,240))
		S2_TextPanel.setbackgroundcolour(New wxColour.createcolour(240,240,240))
		S2_TextPanelvbox.Add(S2_ExplainText1 , 1 , wxEXPAND | wxALL , 4 )
		S2_TextPanel.SetSizer(S2_TextPanelvbox)
		
		
		Line4hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local SFLText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , GetLocaleText("ScratchFile") , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		ScratchFileLocation = 	New wxTextCtrl.Create(UploadPanel , SFC , ScratchFile , - 1 , - 1 , - 1 , - 1)
		Local BrowseScratchFileButton:wxButton = New wxButton.Create(UploadPanel , BSFB , GetLocaleText("Browse") )	
		Line4hbox.Add(SFLText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		Line4hbox.Add(ScratchFileLocation , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 4)
		Line4hbox.Add(BrowseScratchFileButton , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
	
		Line1hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local PText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , GetLocaleText("Port") , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		PortComboBox = New wxComboBox.Create(UploadPanel , PCB1 , "" , Null , - 1 , - 1 , - 1 , - 1 , wxCB_READONLY)
		Local RefreshPortsButton:wxButton = New wxButton.Create(UploadPanel , RPB , GetLocaleText("Refresh"))	

		Line1hbox.Add(PText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		Line1hbox.Add(PortComboBox , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		Line1hbox.Add(RefreshPortsButton , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		
		?Win32
		Line2hbox:wxBoxSizer = New wxBoxSizer.Create(wxHORIZONTAL)	
		Local BText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , GetLocaleText("Board") , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
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
		Local SText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , GetLocaleText("UploadStatus") , - 1 , - 1 , - 1 , - 1 , wxALIGN_LEFT)
		StatusText:wxStaticText = New wxStaticText.Create(UploadPanel , wxID_ANY , "" , -1 , -1 , - 1 , - 1 , wxALIGN_LEFT)
		StatusText.SetLabel(GetLocaleText("StatusNotStarted"))
		StatusText.SetForegroundColour(New wxColour.createcolour(255,0,0))	
		
		Line3hbox.Add(SText , 0 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		Line3hbox.Add(StatusText , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxTOP , 4 )
		UploadPanelvbox.AddSizer(Line3hbox, 0 , wxEXPAND | wxALL , 4 )		



		


		UploadButton = New wxButton.Create(UploadPanel , SSB , GetLocaleText("ButtonUpload"))
		UploadButton.setbackgroundcolour(New wxColour.createcolour(70,255,140))
		Local UploadFont:wxFont = UploadButton.GetFont()
		UploadFont.SetPointSize(12)
		UploadButton.setfont(UploadFont) 

		
		UploadPanelvbox.Add(UploadButton , 0 , wxEXPAND | wxALL , 4 )
	
		UploadPanel.SetSizer(UploadPanelvbox)
		
		Tabs.AddPage(UploadPanel,GetLocaleText("Tab2"))
			
		
		vbox.Add(Tabs , 1 , wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM , 0 )		
		Self.SetSizer(vbox)
		
		
		Self.UpdatePorts()
		Self.Center()
		
		Local x:Int, y:Int
		Self.GetPosition(x, y)
		Self.Move(x, y + 25)
		Self.Show()		
		
		Connect(PCB1 , wxEVT_COMMAND_COMBOBOX_SELECTED , PortUpdatedFun)

		
		CodeConverterTimer.Start(1000)
		
		?Win32
		Connect(BCB , wxEVT_COMMAND_COMBOBOX_SELECTED , BoardUpdatedFun )		
		?
		
		Connect(RPB , wxEVT_COMMAND_BUTTON_CLICKED , UpdatePortsFun)
		Connect(BSFB, wxEVT_COMMAND_BUTTON_CLICKED, BrowseScratchFun)
		Connect(TLOG , wxEVT_COMMAND_MENU_SELECTED, ShowLogFun)
		Connect(TCOD , wxEVT_COMMAND_MENU_SELECTED, ToggleCodeFun)
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
		If FileType(ScratchFile) = 1 And FileType("Converter\CommandLineConverter.exe") = 1 then
			If FileTime(ScratchFile) > ScratchFileModified Or FileType(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino") = 0 then
				ScratchFileModified = FileTime(ScratchFile)

				A4SHelperLog.AddText("===============Processing Scratch Code===============~n")
				
				Local Process:TProcess = New TProcess.Create("Converter\CommandLineConverter.exe -i~q" + ScratchFile + "~q -o~q" + GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino~q -t1", 1)
				
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
		If AdvancedOptionsShown = True then
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

		Info.AddDeveloper("Thomas Preece")
		Info.AddDocWriter("Thomas Preece")
		Info.AddDocWriter("Simon Monk")

		Info.setName("A4S")
		Info.setVersion(VERSION)
		Info.setWebsite("http://thomaspreece.com","Lead developers personal website")
		wxAboutBox(Info)
	End Function
	
	Method ToggleCode()
		If CodeViewShown = True then
			CodeViewShown = False
			Self.A4SHelperCodeView.Show(0)
		Else
			CodeViewShown = True
			Self.A4SHelperCodeView.Show(1)
		EndIf
		UpdateSettings()
	End Method	
	
	Function ToggleCodeFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		A4SHelperFrame.ToggleCode()
	End Function
	
	Function ShowLogFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		A4SHelperFrame.A4SHelperLog.Show(1)
	End Function
	
	Function CloseFun(event:wxEvent)
		Local A4SHelperFrame:A4SHelperFrameType = A4SHelperFrameType(event.parent)
		If A4SHelperFrame.UploadButton.GetLabel() = GetLocaleText("ButtonUpload") Or A4SHelperFrame.UploadButton.GetLabel() = GetLocaleText("ButtonFinished") Then
			
		Else
			Local MessageBox:wxMessageDialog 
			MessageBox = New wxMessageDialog.Create(Null, GetLocaleText("ErrorClose") , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
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
			
		If A4SHelperFrame.UploadButton.GetLabel() = GetLocaleText("ButtonUpload") Or A4SHelperFrame.UploadButton.GetLabel() = GetLocaleText("ButtonFinished") then
			Local Port:String = A4SHelperFrame.PortComboBox.GetValue()
			?Win32
			Local Board:Int = Int(A4SHelperFrame.BoardComboBox.GetValue())
			?Not Win32
			Local Board:Int = 1
			?
			
			Local MessageBox:wxMessageDialog
			If Port = "" Or Port = " " then
				MessageBox = New wxMessageDialog.Create(Null , GetLocaleText("ErrorPortBoard") , GetLocaleText("ErrorTitle") , wxOK | wxICON_ERROR)
				MessageBox.ShowModal()
				MessageBox.Free()	
				Return
			EndIf
			A4SHelperFrame.CodeConverterRun()
			A4SHelperFrame.ProcessUpload(ExtractPort(Port), Board)
		Else
			MessageBox = New wxMessageDialog.Create(Null, GetLocaleText("ErrorClose") , "Question", wxYES_NO | wxNO_DEFAULT | wxICON_QUESTION)
			If MessageBox.ShowModal() = wxID_YES Then
				A4SHelperFrame.StatusText.SetLabel(GetLocaleText("StatusStoppedUser"))
				A4SHelperFrame.A4SHelperLog.AddText("Process Terminated By User~n")	
				TerminateProcess(A4SHelperFrame.UploadProcess)
			EndIf
			MessageBox.Free()	
		EndIf 
		
	End Function
	
	Method ProcessUpload(Port:String, Board:Int)

		Local MessageBox:wxMessageDialog
		A4SHelperLog.AddText("===============Uploading===============~n")	
		UploadButton.SetLabel(GetLocaleText("ButtonStop"))
		UploadButton.setbackgroundcolour(New wxColour.createcolour(255,100,100))
		A4SHelperLog.AddText("Starting Upload on "+Port+" ~n")
		StatusText.SetLabel("Started")
		StatusText.SetForegroundColour(New wxColour.createcolour(255,140,0))	

		If FileType(GetUserAppDir() + Slash + "A4S-Embedded" + Slash + "ArduinoCode.ino") = 0 then
			MessageBox = New wxMessageDialog.Create(Null , GetLocaleText("ErrorGenArduinoCode") , GetLocaleText("ErrorTitle") , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()
			
			UploadButton.SetLabel(GetLocaleText("ButtonUpload"))
			UploadButton.setbackgroundcolour(New wxColour.createcolour(70,255,140))
		
			StatusText.SetLabel(GetLocaleText("StatusError"))
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
			MessageBox = New wxMessageDialog.Create(Null , GetLocaleText("ErrorInstallIDE_MAC") , GetLocaleText("ErrorTitle") , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
		EndIf 
		?
		
		
		Local s:String
		
		If UploadProcess = Null Then 
			MessageBox = New wxMessageDialog.Create(Null , GetLocaleText("ErrorArduinoUploader") , GetLocaleText("ErrorTitle") , wxOK | wxICON_ERROR)
			MessageBox.ShowModal()
			MessageBox.Free()	
			UploadButton.SetLabel(GetLocaleText("ButtonUpload"))
			UploadButton.setbackgroundcolour(New wxColour.createcolour(70,255,140))
		
			StatusText.SetLabel(GetLocaleText("StatusError"))
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
		If StatusText.GetLabel()=GetLocaleText("StatusFinished") Or StatusText.GetLabel()=GetLocaleText("StatusStoppedUser") Then
		
		Else
			StatusText.SetLabel(GetLocaleText("StatusError"))
			StatusText.SetForegroundColour(New wxColour.createcolour(255,0,0))
		EndIf 
		?MacOS
		'Mac version just loads up Arduino Environment, so always show finished correctly status
		StatusText.SetLabel(GetLocaleText("StatusFinished"))
		StatusText.SetForegroundColour(New wxColour.createcolour(0,120,0))		
		?
		
		UploadButton.SetLabel(GetLocaleText("ButtonFinished"))
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
						If Status.GetLabel()=GetLocaleText("StatusError") Then
						
						Else
							Status.SetLabel(GetLocaleText("StatusFinished"))
							Status.SetForegroundColour(New wxColour.createcolour(0,120,0))							
						EndIf 
					ElseIf Instr(Totals,"not in sync") Then
						If Status.GetLabel()=GetLocaleText("StatusStoppedUser") Then 
						
						Else
							Console.AddText("Arduino out of sync!.~n")
							Status.SetLabel(GetLocaleText("StatusError"))
							Status.SetForegroundColour(New wxColour.createcolour(255,0,0))							
						EndIf 
					ElseIf Instr(Totals,"Writing") Then 
						If Status.GetLabel()=GetLocaleText("StatusStoppedUser") Then 
						
						Else
							Status.SetLabel(GetLocaleText("StatusUploading"))
							Status.SetForegroundColour(New wxColour.createcolour(255,140,0))						
						EndIf 
					ElseIf Instr(Totals,"Compiliation") Then
						If Status.GetLabel()=GetLocaleText("StatusStoppedUser") Then 
						
						Else					
							Status.SetLabel(GetLocaleText("StatusCompiling"))
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
	WriteLine(SettingsFile, CodeViewShown)
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

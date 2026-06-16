unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ToolWin, ExtCtrls, Menus, OleCtrls, IniFiles,
  System.UITypes, Generics.Collections, Clipbrd, RichEdit;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ToolBar1: TToolBar;
    ComboBox1: TComboBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    RichEdit1: TRichEdit;
    StatusBar1: TStatusBar;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    ComboBox2: TComboBox;
    ColorDialog1: TColorDialog;
    SpeedButton11: TSpeedButton;
    PopupMenu1: TPopupMenu;
    SpeedButton12: TSpeedButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SpeedButton10: TSpeedButton;
    RichEdit2: TRichEdit;
    procedure ComboBox2Change(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure RichEdit1MouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure RichEdit1KeyUp(Sender: TObject; var Key: Word;
              Shift: TShiftState);
    procedure ComboBox1Change(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure RichEdit1Change(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SpeedButton12Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N19Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
  private
    { Private declarations }
    LineNumberMemo: TRichEdit;
    FSyntaxRules: TDictionary<string, TDictionary<string, TStringList>>;
    FHighlightTimer: TTimer;
    FOriginalRichEditWndProc: TWndMethod;
    FScrollTimer: TTimer;
    FLastScrollPos: Integer;
    FIsAdjusting: Boolean;
    procedure RichEditWindowProc(var Message: TMessage);
    procedure UpdateLineNumbers;
    procedure SyncScroll;
    procedure SaveFile(const AFileName: string);
    procedure AddToOutput(const AText: string; AColor: TColor);
    procedure LoadFile(const AFileName: string);
    procedure LoadSyntaxRules;
    procedure ApplySyntaxHighlighting(FullRepaint: Boolean);
    procedure HighlightLine(LineNum: Integer; Rules: TDictionary<string, TStringList>);
    function StringToColor(const S: string): TColor;
    procedure OnHighlightTimer(Sender: TObject);
    procedure OnScrollTimer(Sender: TObject);
    procedure AdjustScrollPosition;
  public
    { Public declarations }
  end;

type
  TOutputCallback = procedure(const AText: string; AColor: TColor) of object;

  TOutputReaderThread = class(TThread)
  private
    FPipeHandle: THandle;
    FOutputCallback: TOutputCallback;
    FColor: TColor;
    FBuffer: AnsiString;
    procedure DoUpdateOutput;
  protected
    procedure Execute; override;
  public
    constructor Create(APipeHandle: THandle; AOutputCallback: TOutputCallback; AColor: TColor);
  end;

type
  Settings = Record
    Align: TAlignment;
    Font_Name: String[50];
    Font_Size: Integer;
    Font_Color: TColor;
    Text_Attrib: String[3];
  End;

var
  Form1: TForm1;
  Param: Settings;
  Text_Attrib: String[3]; // Атрибуты текста: жирный, курсив или подчеркнутый
  File_Path, File_Name: String;

implementation

uses Unit2;

const
  EM_GETSCROLLPOS = $04DD;
  EM_SETSCROLLPOS = $04DE;

{ TOutputReaderThread }
constructor TOutputReaderThread.Create(APipeHandle: THandle; AOutputCallback: TOutputCallback; AColor: TColor);
begin
  inherited Create(False);
  FPipeHandle := APipeHandle;
  FOutputCallback := AOutputCallback;
  FColor := AColor;
  FreeOnTerminate := True;
end;

procedure TOutputReaderThread.Execute;
var
  Buffer: array[0..1024] of AnsiChar;
  BytesRead: DWORD;
begin
  while not Terminated do
  begin
    if ReadFile(FPipeHandle, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) then
    begin
      SetString(FBuffer, Buffer, BytesRead);
      Synchronize(DoUpdateOutput);
    end
    else
    begin
      // Pipe was closed or an error occurred, so exit the thread.
      Break;
    end;
  end;
end;

procedure TOutputReaderThread.DoUpdateOutput;
begin
  if Assigned(FOutputCallback) then
    FOutputCallback(String(FBuffer), FColor);
end;

Procedure SpeedButton_Settings;
Begin
  If Text_Attrib[1]='1' Then Form1.SpeedButton4.Down:=True
    Else Form1.SpeedButton4.Down:=False;
  If Text_Attrib[2]='1' Then Form1.SpeedButton5.Down:=True
    Else Form1.SpeedButton5.Down:=False;
  If Text_Attrib[3]='1' Then Form1.SpeedButton6.Down:=True
    Else Form1.SpeedButton6.Down:=False;
  If Form1.RichEdit1.Paragraph.Alignment=taLeftJustify Then
    Form1.SpeedButton7.Down:=True Else Form1.SpeedButton7.Down:=False;
  If Form1.RichEdit1.Paragraph.Alignment=taCenter Then
    Form1.SpeedButton8.Down:=True Else Form1.SpeedButton8.Down:=False;
  If Form1.RichEdit1.Paragraph.Alignment=taRightJustify Then
    Form1.SpeedButton9.Down:=True Else Form1.SpeedButton9.Down:=False;
End;

Procedure Font_Style;
Var Vrem, Code: Integer;
Begin
  Val(Text_Attrib, Vrem, Code);
  Case Vrem Of
    0: Form1.RichEdit1.SelAttributes.Style:=[];
    1: Form1.RichEdit1.SelAttributes.Style:=[fsUnderLine];
    10: Form1.RichEdit1.SelAttributes.Style:=[fsItalic];
    11: Form1.RichEdit1.SelAttributes.Style:=[fsItalic,fsUnderLine];
    100: Form1.RichEdit1.SelAttributes.Style:=[fsBold];
    101: Form1.RichEdit1.SelAttributes.Style:=[fsBold,fsUnderLine];
    110: Form1.RichEdit1.SelAttributes.Style:=[fsBold,fsItalic];
    111: Form1.RichEdit1.SelAttributes.Style:=[fsBold,fsItalic,fsUnderLine];
  End; {Case}
End;

Procedure Font_Delta; {Определение атрибутов шрифта в выделенном тексте}
Var Vrem: String;
begin
  Form1.SpeedButton11.Font.Color:=Form1.RichEdit1.SelAttributes.Color;
  Str(Form1.RichEdit1.SelAttributes.Size, Vrem);
  Form1.ComboBox2.Text:=Vrem;
  Form1.ComboBox1.Text:=Form1.RichEdit1.SelAttributes.Name;
  If Form1.RichEdit1.SelAttributes.Style=[] Then Text_Attrib:='000';
  If Form1.RichEdit1.SelAttributes.Style=[fsUnderLine] Then Text_Attrib:='001';
  If Form1.RichEdit1.SelAttributes.Style=[fsItalic] Then Text_Attrib:='010';
  If Form1.RichEdit1.SelAttributes.Style=[fsItalic,fsUnderLine] Then Text_Attrib:='011';
  If Form1.RichEdit1.SelAttributes.Style=[fsBold] Then Text_Attrib:='100';
  If Form1.RichEdit1.SelAttributes.Style=[fsBold,fsUnderLine] Then Text_Attrib:='101';
  If Form1.RichEdit1.SelAttributes.Style=[fsBold,fsItalic] Then Text_Attrib:='110';
  If Form1.RichEdit1.SelAttributes.Style=[fsBold,fsItalic,fsUnderLine] Then Text_Attrib:='111';
  SpeedButton_Settings;
end;

{$R *.dfm}

procedure TForm1.ComboBox2Change(Sender: TObject);
Var Vrem, Code: Integer;
begin
  Val(Form1.ComboBox2.Text, Vrem, Code);
  If Code = 0 Then
  begin
    Form1.RichEdit1.SelAttributes.Size := Vrem;
    LineNumberMemo.Font.Size := Vrem;
  end
  Else MessageDLG('Размер шрифта должен быть числовым значением.'+
         #13+'Введите правильное значение размера!',mtInformation,[mbOk],0);
end;

procedure TForm1.SpeedButton10Click(Sender: TObject);
var
  FullFileName, FileName, CmdLine: string;
  Strings: TStringList;
  SI: TStartupInfo;
  PI: TProcessInformation;
  AppPath: string;
  IniFile: TIniFile;
  Executable, Arguments: string;
  SecurityAttr: TSecurityAttributes;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  StdErrPipeRead, StdErrPipeWrite: THandle;
begin
  RichEdit2.Clear;

  AppPath := ExtractFileDir(Application.ExeName);
  IniFile := TIniFile.Create(AppPath + '\run_settings.ini');
  try
    Executable := IniFile.ReadString('Run', 'Executable', 'python');
    FileName := IniFile.ReadString('Run', 'FileName', 'source.py');
    Arguments := IniFile.ReadString('Run', 'Arguments', '');
  finally
    IniFile.Free;
  end;

  FullFileName := AppPath + '\' + FileName;

  Strings := TStringList.Create;
  try
    Strings.Text := RichEdit1.Text;
    Strings.SaveToFile(FullFileName);
  finally
    Strings.Free;
  end;

  SecurityAttr.nLength := SizeOf(TSecurityAttributes);
  SecurityAttr.bInheritHandle := True;
  SecurityAttr.lpSecurityDescriptor := nil;

  if not CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SecurityAttr, 0) then Exit;
  if not CreatePipe(StdErrPipeRead, StdErrPipeWrite, @SecurityAttr, 0) then
  begin
    CloseHandle(StdOutPipeRead);
    CloseHandle(StdOutPipeWrite);
    Exit;
  end;

  try
    // Ensure the read handles are not inherited by the child process.
    SetHandleInformation(StdOutPipeRead, HANDLE_FLAG_INHERIT, 0);
    SetHandleInformation(StdErrPipeRead, HANDLE_FLAG_INHERIT, 0);

    CmdLine := '"' + Executable + '" "' + FileName + '" ' + Arguments;

    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(SI);
    SI.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    SI.wShowWindow := SW_HIDE;
    SI.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
    SI.hStdOutput := StdOutPipeWrite;
    SI.hStdError := StdErrPipeWrite;

    if CreateProcess(nil, PChar(CmdLine), nil, nil, True, CREATE_NO_WINDOW, nil, PChar(AppPath), SI, PI) then
    begin
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess); // Close process handle, process continues running
      StatusBar1.Panels[0].Text := 'Launched: ' + Executable;

      TOutputReaderThread.Create(StdOutPipeRead, AddToOutput, clBlack);
      TOutputReaderThread.Create(StdErrPipeRead, AddToOutput, clRed);
    end
    else
    begin
      MessageDlg('Failed to execute command: ' + CmdLine + #13#10 +
                 'Error: ' + SysErrorMessage(GetLastError), mtError, [mbOK], 0);
    end;
  finally
    // The parent process no longer needs the write handles
    CloseHandle(StdOutPipeWrite);
    CloseHandle(StdErrPipeWrite);
    // The read handles will be closed by the threads implicitly because they will exit
    // but it is better to manage them if the threads were not FreeOnTerminate
  end;
end;

procedure TForm1.SpeedButton11Click(Sender: TObject);
begin
  If Form1.ColorDialog1.Execute Then
    begin
      Form1.SpeedButton11.Font.Color:=Form1.ColorDialog1.Color;
      Form1.RichEdit1.SelAttributes.Color:=Form1.ColorDialog1.Color;
    end;
  RichEdit1.Tag := 0;
end;

procedure TForm1.N12Click(Sender: TObject);
begin
  Form1.RichEdit1.ClearSelection;
end;

procedure TForm1.N8Click(Sender: TObject);
begin
  Form1.RichEdit1.SelectAll;
  Form1.N9.Enabled:=True;
  Form1.N12.Enabled:=True;
end;

procedure TForm1.N9Click(Sender: TObject);
begin
  Form1.RichEdit1.CopyToClipboard;
end;

procedure TForm1.N10Click(Sender: TObject);
begin
  Form1.RichEdit1.PasteFromClipboard;
end;

procedure TForm1.RichEdit1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If Form1.RichEdit1.SelText<>'' Then
    begin
      Form1.N9.Enabled:=True;
      Form1.N12.Enabled:=True;
    end Else begin
               Form1.N9.Enabled:=False;
               Form1.N12.Enabled:=False;
             end;
  Font_Delta;
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
begin
  If Form1.SpeedButton6.Down Then Text_Attrib[3]:='1' Else Text_Attrib[3]:='0';
  Font_Style;
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
  If Form1.SpeedButton5.Down Then Text_Attrib[2]:='1' Else Text_Attrib[2]:='0';
  Font_Style;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  If Form1.SpeedButton4.Down Then Text_Attrib[1]:='1' Else Text_Attrib[1]:='0';
  Font_Style;
end;

procedure TForm1.RichEdit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Font_Delta;
  if Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_HOME, VK_END] then
  begin
    // Запускаем таймер для корректировки после навигации
    FLastScrollPos := -1;
  end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  Form1.RichEdit1.SelAttributes.Name:=Form1.ComboBox1.Text;
  LineNumberMemo.Font.Name := Form1.RichEdit1.SelAttributes.Name;
end;

procedure TForm1.SpeedButton7Click(Sender: TObject);
begin
  Form1.RichEdit1.Paragraph.Alignment:=taLeftJustify;
end;

procedure TForm1.SpeedButton8Click(Sender: TObject);
begin
  Form1.RichEdit1.Paragraph.Alignment:=taCenter;
end;

procedure TForm1.SpeedButton9Click(Sender: TObject);
begin
  Form1.RichEdit1.Paragraph.Alignment:=taRightJustify;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
Var Vrem1: Integer;
begin
  Vrem1 := mrNo; // Initialize to a default value
  If Form1.RichEdit1.Tag=1 Then
  Vrem1:=MessageDLG('Текст в файле был изменен, но не сохранен. Сохранить?',
             mtConfirmation,[mbYes,mbNo,mbCancel],0);
  If Vrem1<>mrCancel Then
  BEGIN
  If Vrem1=mrYes Then Form1.SpeedButton3.Click;
  Form1.RichEdit1.Paragraph.Alignment:=taLeftJustify;
  Form1.ComboBox1.Text:=String(Param.Font_Name);
  Form1.RichEdit1.Font.Name:=String(Param.Font_Name);
  Form1.ComboBox2.Text:=IntToStr(Param.Font_Size);
  Form1.RichEdit1.Font.Size:=Param.Font_Size;
    Form1.SpeedButton11.Font.Color:=Param.Font_Color;
    Form1.RichEdit1.Font.Color:=Param.Font_Color;
  Text_Attrib:=Param.Text_Attrib;
  Form1.RichEdit1.SelectAll;
    SpeedButton_Settings;
    Font_Style;
  Form1.RichEdit1.Clear;
  Form1.RichEdit1.Tag:=0;
  File_Name:='NoName.rtf';
  Form1.StatusBar1.Panels[0].Text:=File_Path+File_Name;
  END;
end;

procedure TForm1.RichEdit1Change(Sender: TObject);
begin
  Form1.RichEdit1.Tag:=1;
  UpdateLineNumbers;
  if Assigned(FHighlightTimer) then
  begin
    FHighlightTimer.Enabled := False;
    FHighlightTimer.Enabled := True;
  end;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  if (File_Name = 'NoName.rtf') then
  begin
    N5Click(Sender);
  end
  else
  begin
    SaveFile(File_Path + File_Name);
  end;
end;

procedure TForm1.N5Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    SaveFile(SaveDialog1.FileName);
  end;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
  Form1.SpeedButton1.Click;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
  Form1.SpeedButton3.Click;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  If Form1.OpenDialog1.Execute Then
  Begin
    LoadFile(Form1.OpenDialog1.FileName);
  End;
end;

procedure TForm1.N3Click(Sender: TObject);
begin
  Form1.SpeedButton2.Click;
end;

procedure TForm1.N7Click(Sender: TObject);
Var Vrem: Integer;
begin
  Vrem := mrNo; // Initialize to a default value
  If Form1.RichEdit1.Tag=1 Then
  Vrem:=MessageDLG('Текст в файле был изменен, но не сохранен. Сохранить?',
             mtConfirmation,[mbYes,mbNo,mbCancel],0);
  If Vrem=mrYes Then Form1.SpeedButton3.Click;
  If Vrem=mrNo Then Form1.Close;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
Var Vrem1: Integer;
begin
  Vrem1 := mrNo; // Initialize to a default value
  If Form1.RichEdit1.Tag=1 Then
    Vrem1:=MessageDLG('Текст в файле был изменен, но не сохранен. Сохранить?',
               mtConfirmation,[mbYes,mbNo,mbCancel],0);

  If Vrem1 = mrYes Then
  begin
    Form1.SpeedButton3.Click;
    // After saving, we assume it's safe to close, but let's check if save was cancelled
    if Form1.RichEdit1.Tag = 1 then
      CanClose := False // User cancelled the save dialog
    else
      CanClose := True;
  end
  else if Vrem1 = mrNo then
  begin
    Form1.RichEdit1.Tag:=0; // to avoid second dialog
    CanClose := True;
  end
  else if Vrem1 = mrCancel then
  begin
    CanClose := False;
  end
  else // Default case if Tag was not 1
    CanClose := True;
end;

procedure TForm1.SpeedButton12Click(Sender: TObject);
Var F: File of Settings;
begin
  Param.Align:=Form1.RichEdit1.Paragraph.Alignment;
  Param.Font_Name := Copy(Form1.ComboBox1.Text, 1, 50);
  Param.Font_Size:=StrToInt(Form1.ComboBox2.Text);
  Param.Font_Color:=Form1.SpeedButton11.Font.Color;
  Param.Text_Attrib := Copy(Text_Attrib, 1, 3);
  AssignFile(F,ExtractFileDir(Application.ExeName)+'\Settings.inf');
  Rewrite(F);
  Write(F,Param);
  CloseFile(F);
end;

procedure TForm1.FormCreate(Sender: TObject);
Var F: File of Settings;
    i: Integer;
begin
  RichEdit2.Text := 'Консоль';
  RichEdit2.ScrollBars := ssBoth;
  OpenDialog1.Filter := 'Supported Files (*.rtf, *.txt)|*.rtf;*.txt|Rich Text Format (*.rtf)|*.rtf|Plain Text (*.txt)|*.txt|All files (*.*)|*.*';
  OpenDialog1.FilterIndex := 4;
  SaveDialog1.Filter := 'Rich Text Format (*.rtf)|*.rtf|Plain Text (*.txt)|*.txt|All files (*.*)|*.*';
  SaveDialog1.DefaultExt := 'rtf';

  // Создаем LineNumberMemo
  LineNumberMemo := TRichEdit.Create(Self);
  with LineNumberMemo do
  begin
    Parent := Panel1;
    Width := 50;
    Align := alLeft;
    ScrollBars := ssNone;
    ReadOnly := True;
    Color := RGB(245, 245, 245); // Светло-серый фон
    Font.Color := clDkGray; // Темно-серый цвет текста
    WordWrap := False;
    // Выравнивание по правому краю для номеров
    SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) or ES_RIGHT);
  end;

  // Ensure RichEdit1 is also in Panel1 and fills the remaining space
  RichEdit1.Parent := Panel1;
  RichEdit1.Align := alClient;

  If FileExists(ExtractFileDir(Application.ExeName)+'\Settings.inf')=True
    Then Begin
           AssignFile(F,ExtractFileDir(Application.ExeName)+'\Settings.inf');
           Reset(F);
           Read(F,Param);
           CloseFile(F);
           {Применение загруженных настроек}
           Form1.RichEdit1.Paragraph.Alignment:=Param.Align;
             Form1.ComboBox1.Text:=String(Param.Font_Name);
             Form1.RichEdit1.Font.Name:=String(Param.Font_Name);
           Form1.ComboBox2.Text:=IntToStr(Param.Font_Size);
           Form1.RichEdit1.Font.Size:=Param.Font_Size;
             Form1.SpeedButton11.Font.Color:=Param.Font_Color;
             Form1.RichEdit1.Font.Color:=Param.Font_Color;
           Text_Attrib:=Param.Text_Attrib;
           Form1.RichEdit1.SelectAll;
           SpeedButton_Settings;
           Font_Style;
         End Else
         Begin
           MessageDLG('Файл настроек не найден! Будут использованы'+#13+
                      'настройки по умолчанию.',mtError,[mbOk],0);
           Text_Attrib:='000';
           Param.Align:=taLeftJustify;
           Param.Font_Name:='Times New Roman';
           Param.Font_Size:=14;
           Param.Font_Color:=clBlack;
           Param.Text_Attrib:=Text_Attrib;
         End;
  LineNumberMemo.Font.Name := Param.Font_Name;
  LineNumberMemo.Font.Size := Param.Font_Size;
  UpdateLineNumbers;
  File_Path:=ExtractFileDir(Application.ExeName)+'\';
  File_Name:='NoName.rtf';
  Form1.StatusBar1.Panels[0].Text:=File_Path+File_Name;
  For i:=0 To Screen.Fonts.Count-1 do
    Form1.ComboBox1.Items.Add(Screen.Fonts.Strings[i]);
  RichEdit1.Paragraph.Alignment := taLeftJustify;

  LoadSyntaxRules;
  FHighlightTimer := TTimer.Create(Self);
  FHighlightTimer.Interval := 300;
  FHighlightTimer.OnTimer := OnHighlightTimer;
  FHighlightTimer.Enabled := False;

  // Создаем таймер для отслеживания окончания прокрутки
  FScrollTimer := TTimer.Create(Self);
  FScrollTimer.Interval := 50; // Проверяем каждые 50мс
  FScrollTimer.OnTimer := OnScrollTimer;
  FScrollTimer.Enabled := True;
  FLastScrollPos := -1;
  FIsAdjusting := False;

  FOriginalRichEditWndProc := RichEdit1.WindowProc;
  RichEdit1.WindowProc := RichEditWindowProc;
end;

procedure TForm1.N19Click(Sender: TObject);
begin
  Form2.ShowModal;
end;

procedure TForm1.UpdateLineNumbers;
var
  i, lineCount: Integer;
begin
  lineCount := SendMessage(RichEdit1.Handle, EM_GETLINECOUNT, 0, 0);
  if lineCount = 0 then lineCount := 1;

  if LineNumberMemo.Lines.Count <> lineCount then
  begin
    LineNumberMemo.Lines.BeginUpdate;
    try
      LineNumberMemo.Lines.Clear;
      for i := 1 to lineCount do
      begin
        LineNumberMemo.Lines.Add(IntToStr(i));
      end;
    finally
      LineNumberMemo.Lines.EndUpdate;
    end;
  end;
  SyncScroll;
end;

procedure TForm1.SyncScroll;
var
  firstVisible: Integer;
  lineNumFirstVisible: Integer;
begin
  if FIsAdjusting then Exit;
  
  firstVisible := SendMessage(RichEdit1.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
  lineNumFirstVisible := SendMessage(LineNumberMemo.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
  
  if (firstVisible >= 0) and (firstVisible <> lineNumFirstVisible) then
  begin
    SendMessage(LineNumberMemo.Handle, EM_LINESCROLL, 0, firstVisible - lineNumFirstVisible);
  end;
end;

procedure TForm1.AdjustScrollPosition;
var
  ScrollPos: TPoint;
  LineHeight: Integer;
  Remainder: Integer;
  ScrollInfo: TScrollInfo;
  FirstVisibleLine: Integer;
begin
  if FIsAdjusting then Exit;
  
  FIsAdjusting := True;
  try
    // Получаем высоту строки
    LineHeight := Abs(RichEdit1.Font.Height);
    if LineHeight = 0 then LineHeight := 16;
    
    // Увеличиваем высоту строки на межстрочный интервал (примерно 20%)
    LineHeight := Round(LineHeight * 1.2);
    
    // Получаем текущую позицию прокрутки
    FillChar(ScrollPos, SizeOf(ScrollPos), 0);
    SendMessage(RichEdit1.Handle, EM_GETSCROLLPOS, 0, Integer(@ScrollPos));
    
    // Вычисляем остаток от деления на высоту строки
    Remainder := ScrollPos.Y mod LineHeight;
    
    // Если строка обрезана (остаток больше 3 пикселей)
    if Remainder > 3 then
    begin
      // Определяем, куда ближе - вверх или вниз
      if Remainder < (LineHeight div 2) then
      begin
        // Докручиваем вверх
        ScrollPos.Y := ScrollPos.Y - Remainder + 3;
      end
      else
      begin
        // Докручиваем вниз до следующей строки
        ScrollPos.Y := ScrollPos.Y + (LineHeight - Remainder) + 3;
      end;
      
      // Устанавливаем новую позицию
      SendMessage(RichEdit1.Handle, EM_SETSCROLLPOS, 0, Integer(@ScrollPos));
    end;
    
    // Синхронизируем нумератор
    SyncScroll;
  finally
    FIsAdjusting := False;
  end;
end;

procedure TForm1.OnScrollTimer(Sender: TObject);
var
  CurrentPos: Integer;
begin
  if FIsAdjusting then Exit;
  
  CurrentPos := RichEdit1.Perform(EM_GETFIRSTVISIBLELINE, 0, 0);
  
  // Если позиция не изменилась с прошлой проверки
  if (CurrentPos = FLastScrollPos) and (FLastScrollPos >= 0) then
  begin
    // Прокрутка остановилась, корректируем позицию
    AdjustScrollPosition;
    FLastScrollPos := -1; // Сбрасываем для следующего раза
  end
  else
  begin
    FLastScrollPos := CurrentPos;
  end;
end;

procedure TForm1.SaveFile(const AFileName: string);
var
  Strings: TStringList;
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(AFileName));
  if Ext = '.rtf' then
  begin
    RichEdit1.Lines.SaveToFile(AFileName);
  end
  else // Save as Plain Text for all other extensions (.txt, .py, .pas, etc.)
  begin
    Strings := TStringList.Create;
    try
      Strings.Text := RichEdit1.Text;
      Strings.SaveToFile(AFileName);
    finally
      Strings.Free;
    end;
  end;

  File_Name := ExtractFileName(AFileName);
  File_Path := ExtractFilePath(AFileName);
  StatusBar1.Panels[0].Text := AFileName;
  RichEdit1.Tag := 0;
end;

procedure TForm1.LoadFile(const AFileName: string);
var
  Strings: TStringList;
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(AFileName));
  if Ext = '.rtf' then
  begin
    RichEdit1.Lines.LoadFromFile(AFileName);
  end
  else // Load as Plain Text for all other extensions
  begin
    Strings := TStringList.Create;
    try
      Strings.LoadFromFile(AFileName);
      RichEdit1.Text := Strings.Text;
    finally
      Strings.Free;
    end;
    RichEdit1.Paragraph.Alignment := taLeftJustify;
  end;

  File_Name := ExtractFileName(AFileName);
  File_Path := ExtractFilePath(AFileName);
  StatusBar1.Panels[0].Text := AFileName;
  RichEdit1.Modified := False;
  RichEdit1.Tag := 0;
  UpdateLineNumbers;
  ApplySyntaxHighlighting(True);
  SyncScroll;
end;

procedure TForm1.AddToOutput(const AText: string; AColor: TColor);
begin
  RichEdit2.SelStart := Length(RichEdit2.Text);
  RichEdit2.SelAttributes.Color := AColor;
  RichEdit2.SelText := AText;
end;

procedure TForm1.OnHighlightTimer(Sender: TObject);
begin
  FHighlightTimer.Enabled := False;
  ApplySyntaxHighlighting(False);
end;

procedure TForm1.LoadSyntaxRules;
var
  IniFile: TIniFile;
  Sections, Keys, Keywords: TStringList;
  i, j: Integer;
  Ext, ColorName: string;
  RulesForExt: TDictionary<string, TStringList>;
begin
  FSyntaxRules := TDictionary<string, TDictionary<string, TStringList>>.Create;
  IniFile := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\syntax_highlight.ini');
  try
    Sections := TStringList.Create;
    try
      IniFile.ReadSections(Sections);
      for i := 0 to Sections.Count - 1 do
      begin
        Ext := Sections[i];
        if not FSyntaxRules.ContainsKey(Ext) then
        begin
          RulesForExt := TDictionary<string, TStringList>.Create;
          FSyntaxRules.Add(Ext, RulesForExt);

          Keys := TStringList.Create;
          try
            IniFile.ReadSection(Ext, Keys);
            for j := 0 to Keys.Count - 1 do
            begin
              ColorName := Keys[j];
              Keywords := TStringList.Create;
              Keywords.CommaText := IniFile.ReadString(Ext, ColorName, '');
              RulesForExt.Add(ColorName, Keywords);
            end;
          finally
            Keys.Free;
          end;
        end;
      end;
    finally
      Sections.Free;
    end;
  finally
    IniFile.Free;
  end;
end;

procedure TForm1.ApplySyntaxHighlighting(FullRepaint: Boolean);
var
  Ext: string;
  Rules: TDictionary<string, TStringList>;
  CurrentLine, i: Integer;
  OriginalSelStart, OriginalSelLength: Integer;
begin
  Ext := LowerCase(Copy(ExtractFileExt(File_Name), 2, MaxInt));
  if not FSyntaxRules.TryGetValue(Ext, Rules) then
    Exit;

  OriginalSelStart := RichEdit1.SelStart;
  OriginalSelLength := RichEdit1.SelLength;
  SendMessage(RichEdit1.Handle, WM_SETREDRAW, Integer(False), 0);
  try
    if FullRepaint then
    begin
      for i := 0 to RichEdit1.Lines.Count - 1 do
        HighlightLine(i, Rules);
    end
    else
    begin
      CurrentLine := RichEdit1.Perform(EM_LINEFROMCHAR, OriginalSelStart, 0);
      HighlightLine(CurrentLine, Rules);
    end;
  finally
    RichEdit1.SelStart := OriginalSelStart;
    RichEdit1.SelLength := OriginalSelLength;
    SendMessage(RichEdit1.Handle, WM_SETREDRAW, Integer(True), 0);
    InvalidateRect(RichEdit1.Handle, nil, False);
  end;
end;

procedure TForm1.HighlightLine(LineNum: Integer; Rules: TDictionary<string, TStringList>);
var
  Line, PaddedLine: string;
  LineStart: Integer;
  Pair: TPair<string, TStringList>;
  Color: TColor;
  Keyword, PaddedKeyword: string;
  KeywordPos: Integer;
  CommentRules: TStringList;
  CommentStart: Integer;
begin
  if (LineNum < 0) or (LineNum >= RichEdit1.Lines.Count) then Exit;

  LineStart := RichEdit1.Perform(EM_LINEINDEX, LineNum, 0);
  Line := RichEdit1.Lines[LineNum];

  RichEdit1.SelStart := LineStart;
  RichEdit1.SelLength := Length(Line);
  RichEdit1.SelAttributes.Color := clWindowText;
  RichEdit1.SelAttributes.Style := [];

  if Rules.TryGetValue('Gray', CommentRules) and (CommentRules.Count > 0) then
  begin
    CommentStart := Pos(CommentRules[0], Line);
    if CommentStart > 0 then
    begin
      RichEdit1.SelStart := LineStart + CommentStart - 1;
      RichEdit1.SelLength := Length(Line) - CommentStart + 1;
      RichEdit1.SelAttributes.Color := StringToColor('Gray');
      SetLength(Line, CommentStart - 1);
    end;
  end;

  if Trim(Line) = '' then Exit;

  PaddedLine := ' ' + LowerCase(Line) + ' ';
  for Pair in Rules do
  begin
    Color := StringToColor(Pair.Key);
    if Color = StringToColor('Gray') then Continue;

    for Keyword in Pair.Value do
    begin
      if Keyword = '' then Continue;
      PaddedKeyword := ' ' + LowerCase(Keyword) + ' ';
      KeywordPos := Pos(PaddedKeyword, PaddedLine, 1);
      while KeywordPos > 0 do
      begin
        RichEdit1.SelStart := LineStart + KeywordPos - 1;
        RichEdit1.SelLength := Length(Keyword);
        RichEdit1.SelAttributes.Color := Color;
        RichEdit1.SelAttributes.Style := [fsBold];
        KeywordPos := Pos(PaddedKeyword, PaddedLine, KeywordPos + 1);
      end;
    end;
  end;
end;

function TForm1.StringToColor(const S: string): TColor;
begin
  Result := clWindowText;
  if SameText(S, 'Blue') then Result := clBlue
  else if SameText(S, 'Green') then Result := clGreen
  else if SameText(S, 'Purple') then Result := clPurple
  else if SameText(S, 'Gray') then Result := clGray
  else if SameText(S, 'Red') then Result := clRed
  else if SameText(S, 'Black') then Result := clBlack;
end;

procedure TForm1.RichEditWindowProc(var Message: TMessage);
begin
  FOriginalRichEditWndProc(Message);

  if (Message.Msg = WM_VSCROLL) or
     (Message.Msg = WM_HSCROLL) or
     (Message.Msg = WM_MOUSEWHEEL) then
  begin
    SyncScroll;
    // Сбрасываем счетчик при любой прокрутке
    FLastScrollPos := -1;
  end;
end;

end.
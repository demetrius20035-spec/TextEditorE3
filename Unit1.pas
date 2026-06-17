unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ToolWin, ExtCtrls, Menus, OleCtrls, IniFiles,
  ShellAPI, System.UITypes, Generics.Collections;

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
    ComboBox3: TComboBox;

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
    procedure ComboBox3Change(Sender: TObject);
  private
    { Private declarations }
    FGutter: TPaintBox;
    FSyntaxRules: TDictionary<string, TDictionary<string, TStringList>>;
    FHighlightTimer: TTimer;
    FOriginalRichEditWndProc: TWndMethod;
    FFindDialog: TFindDialog;
    FReplaceDialog: TReplaceDialog;
    FRunningProcess: THandle;
    FMRU: TStringList;
    FMRUMenu: TMenuItem;
    FStopItem: TMenuItem;
    FWrapItem: TMenuItem;
    FLineNumItem: TMenuItem;
    procedure RichEditWindowProc(var Message: TMessage);
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure UpdateLineNumbers;
    procedure GutterPaint(Sender: TObject);
    procedure InvalidateGutter;
    procedure FreeSyntaxRules;
    procedure DoDestroy(Sender: TObject);
    procedure UpdateCaption;
    procedure BuildMenus;
    procedure MenuClick(Sender: TObject);
    procedure RichEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ShowFind;
    procedure ShowReplace;
    procedure DoFind(Sender: TObject);
    procedure DoReplace(Sender: TObject);
    function FindInText(const ASearch: string; Options: TFindOptions; AllowWrap: Boolean): Integer;
    function FindNext(const ASearch: string; Options: TFindOptions): Boolean;
    procedure GoToLine;
    procedure ToggleComment;
    procedure ToggleWordWrap;
    procedure ToggleLineNumbers;
    procedure ShowCheatSheet;
    procedure ZoomBy(Delta: Integer);
    procedure RunScript;
    procedure StopRunning;
    procedure ProcessFinished(ExitCode: DWORD);
    procedure LoadMRU;
    procedure SaveMRU;
    procedure AddToMRU(const AFileName: string);
    procedure RebuildMRUMenu;
    procedure SaveFile(const AFileName: string);
    procedure AddToOutput(const AText: string; AColor: TColor);
    procedure LoadFile(const AFileName: string);
    procedure LoadSyntaxRules;
    procedure ApplySyntaxHighlighting(FullRepaint: Boolean);
    procedure HighlightLine(LineNum: Integer; Rules: TDictionary<string, TStringList>);
    function StringToColor(const S: string): TColor;
    procedure OnHighlightTimer(Sender: TObject);
    procedure UpdateCursorPosStatus;
    function GetSelectedEncoding: TEncoding;
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
    destructor Destroy; override;
  end;

  TProcessDoneEvent = procedure(ExitCode: DWORD) of object;

  // Waits for a launched process to exit, then reports its exit code back to
  // the form (on the main thread) so the Run UI can reset itself.
  TProcessWaitThread = class(TThread)
  private
    FProcess: THandle;
    FOnDone: TProcessDoneEvent;
    FExitCode: DWORD;
    procedure DoDone;
  protected
    procedure Execute; override;
  public
    constructor Create(AProcess: THandle; AOnDone: TProcessDoneEvent);
  end;

Settings=Record
           Align: TAlignment;
           Font_Name: String[50];
           Font_Size: Integer;
           Font_Color: TColor;
           Text_Attrib: String[3];
         End;

var
  Form1: TForm1;
  Param: Settings;
  Text_Attrib: String[3]; {Атрибуты стиля выделенного текста: [1]=жирный, [2]=курсив, [3]=подчёркнутый}
  File_Path,File_Name: String;

implementation

uses Unit2;

const
  // Rich Edit "extended set text limit" message (normally in Winapi.RichEdit);
  // re-declared here to lift the default ~32 KB editor limit without pulling in
  // the whole unit.
  EM_EXLIMITTEXT = $0435;
  // EM_SETTARGETDEVICE with a non-zero line width reliably turns OFF word wrap
  // in a Rich Edit (WordWrap := False alone is not enough — the engine keeps
  // wrapping to the window width, which de-synced the line-number gutter).
  EM_SETTARGETDEVICE = $0448;

  // Menu command ids (TMenuItem.Tag) dispatched by MenuClick.
  cmdFind = 10; cmdReplace = 11; cmdGoto = 12; cmdComment = 13;
  cmdWrap = 20; cmdZoomIn = 21; cmdZoomOut = 22; cmdZoomReset = 23;
  cmdRun = 30; cmdStop = 31;
  cmdLineNumbers = 40; cmdCheatSheet = 41;
  cmdMRUBase = 1000;

{ TOutputReaderThread }
constructor TOutputReaderThread.Create(APipeHandle: THandle; AOutputCallback: TOutputCallback; AColor: TColor);
begin
  inherited Create(False);
  FPipeHandle := APipeHandle;
  FOutputCallback := AOutputCallback;
  FColor := AColor;
  FreeOnTerminate := True;
end;

destructor TOutputReaderThread.Destroy;
begin
  if FPipeHandle <> 0 then
    CloseHandle(FPipeHandle);
  inherited;
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
    FOutputCallback(string(FBuffer), FColor);
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
Var Vrem,Code: Integer;
Begin
  Val(Text_Attrib,Vrem,Code);
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
  Str(Form1.RichEdit1.SelAttributes.Size,Vrem);
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
Var Vrem,Code: Integer;
begin
  Val(Form1.ComboBox2.Text,Vrem,Code);
  If Code=0 Then
  begin
    Form1.RichEdit1.SelAttributes.Size:=Vrem;
    InvalidateGutter;
  end
  Else MessageDLG('Размер шрифта должен быть числовым значением.'+
         #13+'Введите правильное значение размера!',mtInformation,[mbOk],0);
end;

procedure TForm1.SpeedButton10Click(Sender: TObject);
begin
  RunScript;
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
  UpdateCursorPosStatus;
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
    InvalidateGutter;
  UpdateCursorPosStatus;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  Form1.RichEdit1.SelAttributes.Name:=Form1.ComboBox1.Text;
  InvalidateGutter;
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
  Form1.ComboBox1.Text:=Param.Font_Name;
  Form1.RichEdit1.Font.Name:=Param.Font_Name;
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
  UpdateCursorPosStatus;
  UpdateCaption;
  END;
end;

procedure TForm1.RichEdit1Change(Sender: TObject);
begin
  Form1.RichEdit1.Tag:=1;
  UpdateLineNumbers;
  UpdateCaption;
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
  Param.Font_Name:=Form1.ComboBox1.Text;
  Param.Font_Size:=StrToInt(Form1.ComboBox2.Text);
  Param.Font_Color:=Form1.SpeedButton11.Font.Color;
  Param.Text_Attrib:=Text_Attrib;
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

  // Line-number gutter: a lightweight paint surface that draws numbers aligned
  // to the real on-screen position of each line (see GutterPaint). This replaces
  // the old "second RichEdit + scroll-sync timer" hack.
  FGutter := TPaintBox.Create(Self);
  FGutter.Parent := Panel1;
  FGutter.Align := alLeft;
  FGutter.Width := 48;
  FGutter.OnPaint := GutterPaint;

  // Setup StatusBar
  with StatusBar1.Panels.Add do
  begin
    Width := 150;
    Alignment := taRightJustify;
  end;

  // Ensure RichEdit1 is also in Panel1 and fills the remaining space
  RichEdit1.Parent := Panel1;
  RichEdit1.Align := alClient;
  RichEdit1.WordWrap := False;   // code shouldn't wrap; keeps 1 logical line = 1 row
  RichEdit1.HideSelection := False; // keep the selection visible (e.g. for Find)
  // Lift the default ~32 KB text limit so large source files load fully.
  // (Sent after the style changes above, which recreate the window handle.)
  SendMessage(RichEdit1.Handle, EM_EXLIMITTEXT, 0, $7FFFFFFE);
  // Actually disable word wrap (WordWrap := False alone is not reliable in
  // RichEdit). With wrap off, on-screen rows == logical lines, so the gutter
  // numbers line up exactly.
  SendMessage(RichEdit1.Handle, EM_SETTARGETDEVICE, 0, 1);

  If FileExists(ExtractFileDir(Application.ExeName)+'\Settings.inf')=True
    Then Begin
           AssignFile(F,ExtractFileDir(Application.ExeName)+'\Settings.inf');
           Reset(F);
           Read(F,Param);
           CloseFile(F);
           {Применение загруженных настроек}
           Form1.RichEdit1.Paragraph.Alignment:=Param.Align;
             Form1.ComboBox1.Text:=Param.Font_Name;
             Form1.RichEdit1.Font.Name:=Param.Font_Name;
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
           {Файл настроек не найден — молча применяем значения по умолчанию.}
           Text_Attrib:='000';
           Param.Align:=taLeftJustify;
           Param.Font_Name:='Times New Roman';
           Param.Font_Size:=14;
           Param.Font_Color:=clBlack;
           Param.Text_Attrib:=Text_Attrib;
         End;
  UpdateLineNumbers;
  File_Path:=ExtractFileDir(Application.ExeName)+'\';
  File_Name:='NoName.rtf';
  Form1.StatusBar1.Panels[0].Text:=File_Path+File_Name;
  UpdateCursorPosStatus;
  For i:=0 To Screen.Fonts.Count-1 do
    Form1.ComboBox1.Items.Add(Screen.Fonts.Strings[i]);
  RichEdit1.Paragraph.Alignment := taLeftJustify;

  LoadSyntaxRules;
  FHighlightTimer := TTimer.Create(Self);
  FHighlightTimer.Interval := 300;
  FHighlightTimer.OnTimer := OnHighlightTimer;
  FHighlightTimer.Enabled := False;

  FOriginalRichEditWndProc := RichEdit1.WindowProc;
  RichEdit1.WindowProc := RichEditWindowProc;
  RichEdit1.OnKeyDown := RichEdit1KeyDown;   // auto-indent on Enter
  Self.OnDestroy := DoDestroy;

  ComboBox3.Items.Clear;
  ComboBox3.Items.Add('UTF8');
  ComboBox3.Items.Add('CP1251');
  ComboBox3.Items.Add('CP866');
  ComboBox3.ItemIndex := 0;   // default to UTF-8 (best for source code / Python)

  // Find / Replace dialogs (created in code, no DFM surgery needed).
  FFindDialog := TFindDialog.Create(Self);
  FFindDialog.OnFind := DoFind;
  FReplaceDialog := TReplaceDialog.Create(Self);
  FReplaceDialog.OnFind := DoFind;
  FReplaceDialog.OnReplace := DoReplace;

  FRunningProcess := 0;

  // Edit / View / Run menus, shortcuts and the Recent-files list.
  BuildMenus;
  LoadMRU;
  RebuildMRUMenu;

  // Allow opening files by dropping them onto the window.
  DragAcceptFiles(Handle, True);

  UpdateCaption;
end;

procedure TForm1.N19Click(Sender: TObject);
begin
  Form2.ShowModal;
end;

procedure TForm1.UpdateLineNumbers;
var
  LineCount, Digits, NewWidth: Integer;
begin
  if FGutter = nil then Exit;

  LineCount := SendMessage(RichEdit1.Handle, EM_GETLINECOUNT, 0, 0);
  if LineCount < 1 then LineCount := 1;

  // Grow the gutter to fit the widest line number (minimum two digits).
  Digits := Length(IntToStr(LineCount));
  if Digits < 2 then Digits := 2;
  FGutter.Canvas.Font.Assign(RichEdit1.Font);
  NewWidth := FGutter.Canvas.TextWidth('0') * Digits + 12;
  if FGutter.Width <> NewWidth then
    FGutter.Width := NewWidth;

  InvalidateGutter;
end;

procedure TForm1.InvalidateGutter;
begin
  if FGutter <> nil then
    FGutter.Invalidate;
end;

procedure TForm1.GutterPaint(Sender: TObject);
var
  FirstLine, LineCount, i: Integer;
  CharIndex: Integer;
  Pt: TPoint;
  S: string;
  C: TCanvas;
  ClientH: Integer;
begin
  C := FGutter.Canvas;

  // Background + right-hand separator.
  C.Brush.Style := bsSolid;
  C.Brush.Color := clBtnFace;
  C.FillRect(FGutter.ClientRect);
  C.Pen.Color := clBtnShadow;
  C.MoveTo(FGutter.ClientWidth - 1, 0);
  C.LineTo(FGutter.ClientWidth - 1, FGutter.ClientHeight);

  if not RichEdit1.HandleAllocated then Exit;

  C.Font.Assign(RichEdit1.Font);
  C.Font.Color := clGrayText;
  C.Brush.Style := bsClear;

  LineCount := SendMessage(RichEdit1.Handle, EM_GETLINECOUNT, 0, 0);
  FirstLine := SendMessage(RichEdit1.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
  ClientH := RichEdit1.ClientHeight;

  // Walk the visible lines and paint each number at the line's real Y position,
  // so the numbers stay aligned no matter the font size or scroll offset.
  for i := FirstLine to LineCount - 1 do
  begin
    CharIndex := RichEdit1.Perform(EM_LINEINDEX, i, 0);
    if CharIndex < 0 then Continue;
    Pt.X := 0;
    Pt.Y := 0;
    SendMessage(RichEdit1.Handle, EM_POSFROMCHAR, WPARAM(@Pt), CharIndex);
    if Pt.Y > ClientH then Break;
    S := IntToStr(i + 1);
    C.TextOut(FGutter.ClientWidth - C.TextWidth(S) - 5, Pt.Y, S);
  end;
end;

procedure TForm1.SaveFile(const AFileName: string);
var
  Strings: TStringList;
  Ext: string;
  Encoding: TEncoding;
begin
  Ext := LowerCase(ExtractFileExt(AFileName));
  if Ext = '.rtf' then
  begin
    RichEdit1.Lines.SaveToFile(AFileName);
  end
  else // Save as Plain Text for all other extensions (.txt, .py, .pas, etc.)
  begin
    Strings := TStringList.Create;
    Encoding := GetSelectedEncoding;
    try
      Strings.Text := RichEdit1.Text;
      Strings.SaveToFile(AFileName, Encoding);
    finally
      Strings.Free;
    end;
  end;

  File_Name := ExtractFileName(AFileName);
  File_Path := ExtractFilePath(AFileName);
  StatusBar1.Panels[0].Text := AFileName;
  RichEdit1.Tag := 0;
  AddToMRU(AFileName);
  UpdateCaption;
end;

procedure TForm1.LoadFile(const AFileName: string);
var
  Strings: TStringList;
  Ext: string;
  Encoding: TEncoding;
begin
  Ext := LowerCase(ExtractFileExt(AFileName));
  if Ext = '.rtf' then
  begin
    RichEdit1.Lines.LoadFromFile(AFileName);
  end
  else // Load as Plain Text for all other extensions
  begin
    Strings := TStringList.Create;
    Encoding := GetSelectedEncoding;
    try
      Strings.LoadFromFile(AFileName, Encoding);
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
  InvalidateGutter;
  UpdateCursorPosStatus;
  AddToMRU(AFileName);
  UpdateCaption;
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
  // Ctrl + mouse wheel zooms instead of scrolling.
  if (Message.Msg = WM_MOUSEWHEEL) and
     ((TWMMouseWheel(Message).Keys and MK_CONTROL) <> 0) then
  begin
    if TWMMouseWheel(Message).WheelDelta > 0 then
      ZoomBy(10)
    else
      ZoomBy(-10);
    Message.Result := 0;
    Exit;
  end;

  FOriginalRichEditWndProc(Message);

  // Repaint the gutter whenever the editor scrolls or is resized so the numbers
  // track the visible text exactly. No timers, no scroll-position guessing.
  if (Message.Msg = WM_VSCROLL) or
     (Message.Msg = WM_MOUSEWHEEL) or
     (Message.Msg = WM_SIZE) then
    InvalidateGutter;
end;

procedure TForm1.UpdateCursorPosStatus;
var
  LineNum, ColNum, LineStart: Integer;
begin
  if StatusBar1.Panels.Count < 2 then Exit;

  LineNum := RichEdit1.Perform(EM_LINEFROMCHAR, RichEdit1.SelStart, 0);
  LineStart := RichEdit1.Perform(EM_LINEINDEX, LineNum, 0);
  ColNum := RichEdit1.SelStart - LineStart;

  StatusBar1.Panels[1].Text := Format('Ln: %d, Col: %d', [LineNum + 1, ColNum + 1]);
end;

procedure TForm1.ComboBox3Change(Sender: TObject);
var
  Vrem1: Integer;
begin
  if (File_Name <> '') and (File_Name <> 'NoName.rtf') and FileExists(File_Path + File_Name) then
  begin
    Vrem1 := MessageDLG('Перезагрузить файл "' + File_Name + '" с кодировкой ' + ComboBox3.Text + '?',
                 mtConfirmation, [mbYes, mbNo], 0);
    if Vrem1 = mrYes then
    begin
      LoadFile(File_Path + File_Name);
    end;
  end;
end;

function TForm1.GetSelectedEncoding: TEncoding;
var
  EncodingStr: string;
begin
  EncodingStr := ComboBox3.Text;
  if SameText(EncodingStr, 'CP1251') then
    Result := TEncoding.GetEncoding(1251)
  else if SameText(EncodingStr, 'CP866') then
    Result := TEncoding.GetEncoding(866)
  else // Default to UTF8
    Result := TEncoding.UTF8;
end;

procedure TForm1.FreeSyntaxRules;
var
  Outer: TPair<string, TDictionary<string, TStringList>>;
  Inner: TPair<string, TStringList>;
begin
  if FSyntaxRules = nil then Exit;
  for Outer in FSyntaxRules do
  begin
    for Inner in Outer.Value do
      Inner.Value.Free;
    Outer.Value.Free;
  end;
  FSyntaxRules.Free;
  FSyntaxRules := nil;
end;

procedure TForm1.DoDestroy(Sender: TObject);
begin
  if FRunningProcess <> 0 then
    TerminateProcess(FRunningProcess, 0);
  SaveMRU;
  FMRU.Free;
  FreeSyntaxRules;
end;

procedure TForm1.UpdateCaption;
const
  AppTitle = 'Текстовый редактор';
var
  Star: string;
begin
  if RichEdit1.Tag = 1 then Star := '*' else Star := '';
  Caption := Star + File_Name + ' — ' + AppTitle;
end;

{ ---- Menus -------------------------------------------------------------- }

procedure TForm1.BuildMenus;

  function Mk(AParent: TMenuItem; const ACaption: string; ATag: Integer;
    AShortCut: TShortCut): TMenuItem;
  begin
    Result := TMenuItem.Create(MainMenu1);
    Result.Caption := ACaption;
    Result.Tag := ATag;
    Result.ShortCut := AShortCut;
    if ATag >= 0 then
      Result.OnClick := MenuClick;
    AParent.Add(Result);
  end;

var
  EditMenu, ViewMenu, RunMenu, HelpMenu: TMenuItem;
begin
  // Accelerators for the existing File menu items.
  N2.ShortCut := ShortCut(Ord('N'), [ssCtrl]);
  N3.ShortCut := ShortCut(Ord('O'), [ssCtrl]);
  N4.ShortCut := ShortCut(Ord('S'), [ssCtrl]);
  N5.ShortCut := ShortCut(Ord('S'), [ssCtrl, ssShift]);

  // "Recent files" submenu, inserted into the File menu before its separator.
  FMRUMenu := TMenuItem.Create(MainMenu1);
  FMRUMenu.Caption := 'Последние файлы';
  N1.Insert(4, FMRUMenu);

  EditMenu := TMenuItem.Create(MainMenu1);
  EditMenu.Caption := 'Правка';
  MainMenu1.Items.Insert(1, EditMenu);
  Mk(EditMenu, 'Найти...', cmdFind, ShortCut(Ord('F'), [ssCtrl]));
  Mk(EditMenu, 'Заменить...', cmdReplace, ShortCut(Ord('H'), [ssCtrl]));
  Mk(EditMenu, 'Перейти к строке...', cmdGoto, ShortCut(Ord('G'), [ssCtrl]));
  Mk(EditMenu, '-', -1, 0);
  Mk(EditMenu, 'Комментировать строки', cmdComment, ShortCut(191, [ssCtrl]));

  ViewMenu := TMenuItem.Create(MainMenu1);
  ViewMenu.Caption := 'Вид';
  MainMenu1.Items.Insert(2, ViewMenu);
  FLineNumItem := Mk(ViewMenu, 'Номера строк', cmdLineNumbers, 0);
  FLineNumItem.Checked := FGutter.Visible;
  FWrapItem := Mk(ViewMenu, 'Перенос строк', cmdWrap, 0);
  FWrapItem.Checked := RichEdit1.WordWrap;
  Mk(ViewMenu, '-', -1, 0);
  Mk(ViewMenu, 'Увеличить', cmdZoomIn, ShortCut(187, [ssCtrl]));
  Mk(ViewMenu, 'Уменьшить', cmdZoomOut, ShortCut(189, [ssCtrl]));
  Mk(ViewMenu, 'Сбросить масштаб', cmdZoomReset, ShortCut(Ord('0'), [ssCtrl]));

  RunMenu := TMenuItem.Create(MainMenu1);
  RunMenu.Caption := 'Запуск';
  MainMenu1.Items.Insert(3, RunMenu);
  Mk(RunMenu, 'Выполнить', cmdRun, ShortCut(VK_F5, []));
  FStopItem := Mk(RunMenu, 'Остановить', cmdStop, ShortCut(VK_F2, [ssCtrl]));
  FStopItem.Enabled := False;

  HelpMenu := TMenuItem.Create(MainMenu1);
  HelpMenu.Caption := 'Справка';
  MainMenu1.Items.Add(HelpMenu);
  Mk(HelpMenu, 'Шпаргалка (возможности и клавиши)', cmdCheatSheet, ShortCut(VK_F1, []));
end;

procedure TForm1.MenuClick(Sender: TObject);
var
  ATag: Integer;
begin
  ATag := (Sender as TMenuItem).Tag;
  case ATag of
    cmdFind: ShowFind;
    cmdReplace: ShowReplace;
    cmdGoto: GoToLine;
    cmdComment: ToggleComment;
    cmdWrap: ToggleWordWrap;
    cmdZoomIn: ZoomBy(10);
    cmdZoomOut: ZoomBy(-10);
    cmdZoomReset:
      begin
        RichEdit1.Zoom := 100;
        InvalidateGutter;
      end;
    cmdRun: RunScript;
    cmdStop: StopRunning;
    cmdLineNumbers: ToggleLineNumbers;
    cmdCheatSheet: ShowCheatSheet;
  else
    if (ATag >= cmdMRUBase) and ((ATag - cmdMRUBase) < FMRU.Count) then
    begin
      if FileExists(FMRU[ATag - cmdMRUBase]) then
        LoadFile(FMRU[ATag - cmdMRUBase])
      else
        MessageDlg('Файл не найден: ' + FMRU[ATag - cmdMRUBase],
                   mtWarning, [mbOk], 0);
    end;
  end;
end;

{ ---- Recent files ------------------------------------------------------- }

procedure TForm1.LoadMRU;
var
  Ini: TIniFile;
  i: Integer;
  S: string;
begin
  if FMRU = nil then FMRU := TStringList.Create;
  FMRU.Clear;
  Ini := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\recent.ini');
  try
    for i := 0 to 7 do
    begin
      S := Ini.ReadString('Recent', IntToStr(i), '');
      if S <> '' then FMRU.Add(S);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TForm1.SaveMRU;
var
  Ini: TIniFile;
  i: Integer;
begin
  if FMRU = nil then Exit;
  Ini := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\recent.ini');
  try
    Ini.EraseSection('Recent');
    for i := 0 to FMRU.Count - 1 do
      Ini.WriteString('Recent', IntToStr(i), FMRU[i]);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TForm1.AddToMRU(const AFileName: string);
var
  idx: Integer;
begin
  if FMRU = nil then Exit;
  idx := FMRU.IndexOf(AFileName);
  if idx >= 0 then FMRU.Delete(idx);
  FMRU.Insert(0, AFileName);
  while FMRU.Count > 8 do
    FMRU.Delete(FMRU.Count - 1);
  RebuildMRUMenu;
end;

procedure TForm1.RebuildMRUMenu;
var
  i: Integer;
  Item: TMenuItem;
begin
  if FMRUMenu = nil then Exit;
  FMRUMenu.Clear;
  if FMRU.Count = 0 then
  begin
    Item := TMenuItem.Create(MainMenu1);
    Item.Caption := '(пусто)';
    Item.Enabled := False;
    FMRUMenu.Add(Item);
    Exit;
  end;
  for i := 0 to FMRU.Count - 1 do
  begin
    Item := TMenuItem.Create(MainMenu1);
    Item.Caption := '&' + IntToStr(i + 1) + '   ' + FMRU[i];
    Item.Tag := cmdMRUBase + i;
    Item.OnClick := MenuClick;
    FMRUMenu.Add(Item);
  end;
end;

{ ---- Find / Replace ----------------------------------------------------- }

procedure TForm1.ShowFind;
begin
  if FReplaceDialog <> nil then FReplaceDialog.CloseDialog;
  FFindDialog.Execute;
end;

procedure TForm1.ShowReplace;
begin
  if FFindDialog <> nil then FFindDialog.CloseDialog;
  FReplaceDialog.Execute;
end;

function TForm1.FindInText(const ASearch: string; Options: TFindOptions;
  AllowWrap: Boolean): Integer;
var
  StartPos, FoundAt, TextLen: Integer;
  ST: TSearchTypes;
begin
  Result := -1;
  if ASearch = '' then Exit;
  ST := [];
  if frMatchCase in Options then Include(ST, stMatchCase);
  if frWholeWord in Options then Include(ST, stWholeWord);
  TextLen := RichEdit1.GetTextLen;
  StartPos := RichEdit1.SelStart + RichEdit1.SelLength;
  FoundAt := RichEdit1.FindText(ASearch, StartPos, TextLen - StartPos, ST);
  if (FoundAt = -1) and AllowWrap then
    FoundAt := RichEdit1.FindText(ASearch, 0, TextLen, ST);
  if FoundAt <> -1 then
  begin
    RichEdit1.SelStart := FoundAt;
    RichEdit1.SelLength := Length(ASearch);
    InvalidateGutter;
  end;
  Result := FoundAt;
end;

function TForm1.FindNext(const ASearch: string; Options: TFindOptions): Boolean;
begin
  Result := FindInText(ASearch, Options, True) <> -1;
  if (not Result) and (ASearch <> '') then
    MessageDlg('Не найдено: "' + ASearch + '"', mtInformation, [mbOk], 0);
end;

procedure TForm1.DoFind(Sender: TObject);
begin
  if Sender = FReplaceDialog then
    FindNext(FReplaceDialog.FindText, FReplaceDialog.Options)
  else
    FindNext(FFindDialog.FindText, FFindDialog.Options);
end;

procedure TForm1.DoReplace(Sender: TObject);
var
  Cnt: Integer;
begin
  if frReplaceAll in FReplaceDialog.Options then
  begin
    Cnt := 0;
    RichEdit1.SelStart := 0;
    RichEdit1.SelLength := 0;
    RichEdit1.Lines.BeginUpdate;
    try
      while FindInText(FReplaceDialog.FindText, FReplaceDialog.Options, False) <> -1 do
      begin
        RichEdit1.SelText := FReplaceDialog.ReplaceText;
        RichEdit1.SelStart := RichEdit1.SelStart + Length(FReplaceDialog.ReplaceText);
        RichEdit1.SelLength := 0;
        Inc(Cnt);
      end;
    finally
      RichEdit1.Lines.EndUpdate;
    end;
    MessageDlg(Format('Заменено вхождений: %d', [Cnt]), mtInformation, [mbOk], 0);
  end
  else
  begin
    if RichEdit1.SelLength > 0 then
      RichEdit1.SelText := FReplaceDialog.ReplaceText;
    FindNext(FReplaceDialog.FindText, FReplaceDialog.Options);
  end;
end;

{ ---- Go to line / comment / wrap / zoom -------------------------------- }

procedure TForm1.GoToLine;
var
  S: string;
  LineNo, Idx, MaxLine, CurLine: Integer;
begin
  MaxLine := SendMessage(RichEdit1.Handle, EM_GETLINECOUNT, 0, 0);
  CurLine := RichEdit1.Perform(EM_LINEFROMCHAR, RichEdit1.SelStart, 0) + 1;
  S := IntToStr(CurLine);
  if InputQuery('Перейти к строке', Format('Номер строки (1..%d):', [MaxLine]), S) then
  begin
    LineNo := StrToIntDef(S, CurLine);
    if LineNo < 1 then LineNo := 1;
    if LineNo > MaxLine then LineNo := MaxLine;
    Idx := RichEdit1.Perform(EM_LINEINDEX, LineNo - 1, 0);
    if Idx >= 0 then
    begin
      RichEdit1.SelStart := Idx;
      RichEdit1.SelLength := 0;
      RichEdit1.SetFocus;
      InvalidateGutter;
      UpdateCursorPosStatus;
    end;
  end;
end;

procedure TForm1.ToggleComment;
var
  Ext, Prefix, Line: string;
  Rules: TDictionary<string, TStringList>;
  GrayList: TStringList;
  FirstLine, LastLine, i, P: Integer;
  AllCommented: Boolean;
begin
  Ext := LowerCase(Copy(ExtractFileExt(File_Name), 2, MaxInt));
  if (FSyntaxRules = nil) or (not FSyntaxRules.TryGetValue(Ext, Rules)) then Exit;
  if (not Rules.TryGetValue('Gray', GrayList)) or (GrayList.Count = 0) then Exit;
  Prefix := GrayList[0];
  if Prefix = '' then Exit;

  // Only single-line comment tokens are safe to toggle per line. Block-comment
  // languages (CSS /*, HTML <!--) would get an unterminated comment otherwise.
  if (Prefix <> '//') and (Prefix <> '#') and (Prefix <> '--') and (Prefix <> ';') then
  begin
    MessageDlg('Построчное комментирование для этого типа файла не поддерживается.',
               mtInformation, [mbOk], 0);
    Exit;
  end;

  FirstLine := RichEdit1.Perform(EM_LINEFROMCHAR, RichEdit1.SelStart, 0);
  if RichEdit1.SelLength > 0 then
    LastLine := RichEdit1.Perform(EM_LINEFROMCHAR,
                  RichEdit1.SelStart + RichEdit1.SelLength, 0)
  else
    LastLine := FirstLine;

  // Comment only if at least one selected line is NOT yet commented.
  AllCommented := True;
  for i := FirstLine to LastLine do
  begin
    if i >= RichEdit1.Lines.Count then Break;
    Line := RichEdit1.Lines[i];
    if Trim(Line) = '' then Continue;
    if Copy(TrimLeft(Line), 1, Length(Prefix)) <> Prefix then
    begin
      AllCommented := False;
      Break;
    end;
  end;

  RichEdit1.Lines.BeginUpdate;
  try
    for i := FirstLine to LastLine do
    begin
      if i >= RichEdit1.Lines.Count then Break;
      Line := RichEdit1.Lines[i];
      if (Trim(Line) = '') and (FirstLine <> LastLine) then Continue;
      if AllCommented then
      begin
        P := Pos(Prefix, Line);
        if P > 0 then
        begin
          Delete(Line, P, Length(Prefix));
          if (P <= Length(Line)) and (Line[P] = ' ') then
            Delete(Line, P, 1);
        end;
      end
      else
        Line := Prefix + ' ' + Line;
      RichEdit1.Lines[i] := Line;
    end;
  finally
    RichEdit1.Lines.EndUpdate;
  end;
  RichEdit1.Tag := 1;
  UpdateLineNumbers;
  UpdateCaption;
end;

procedure TForm1.ToggleWordWrap;
begin
  RichEdit1.WordWrap := not RichEdit1.WordWrap;
  if RichEdit1.WordWrap then
    RichEdit1.ScrollBars := ssVertical
  else
    RichEdit1.ScrollBars := ssBoth;
  // The style changes above recreate the handle, so re-apply the text limit
  // and the wrap mode (0 = wrap to window, 1 = no wrap / horizontal scroll).
  SendMessage(RichEdit1.Handle, EM_EXLIMITTEXT, 0, $7FFFFFFE);
  if RichEdit1.WordWrap then
    SendMessage(RichEdit1.Handle, EM_SETTARGETDEVICE, 0, 0)
  else
    SendMessage(RichEdit1.Handle, EM_SETTARGETDEVICE, 0, 1);
  if FWrapItem <> nil then
    FWrapItem.Checked := RichEdit1.WordWrap;
  UpdateLineNumbers;
end;

procedure TForm1.ToggleLineNumbers;
begin
  FGutter.Visible := not FGutter.Visible;
  if FLineNumItem <> nil then
    FLineNumItem.Checked := FGutter.Visible;
  if FGutter.Visible then
    UpdateLineNumbers;
end;

procedure TForm1.ShowCheatSheet;
const
  CR = #13#10;
var
  Dlg: TForm;
  Memo: TMemo;
begin
  Dlg := TForm.Create(Self);
  try
    Dlg.Caption := 'Шпаргалка — возможности и горячие клавиши';
    Dlg.Position := poOwnerFormCenter;
    Dlg.BorderStyle := bsSizeable;
    Dlg.Width := 600;
    Dlg.Height := 560;

    Memo := TMemo.Create(Dlg);
    Memo.Parent := Dlg;
    Memo.Align := alClient;
    Memo.ReadOnly := True;
    Memo.ScrollBars := ssVertical;
    Memo.WordWrap := True;
    Memo.Font.Name := 'Consolas';
    Memo.Font.Size := 10;
    Memo.Text :=
      'ГОРЯЧИЕ КЛАВИШИ' + CR +
      '─────────────────────────────────────────────' + CR +
      'Ctrl+N / Ctrl+O / Ctrl+S   Новый / Открыть / Сохранить' + CR +
      'Ctrl+Shift+S               Сохранить как' + CR +
      'Ctrl+F / Ctrl+H            Найти / Заменить' + CR +
      'Ctrl+G                     Перейти к строке' + CR +
      'Ctrl+/                     Комментировать строки' + CR +
      'Ctrl++ / Ctrl+- / Ctrl+0   Масштаб: больше / меньше / сброс' + CR +
      'Ctrl+колесо мыши           Масштаб' + CR +
      'F5 / Ctrl+F2               Выполнить / Остановить' + CR +
      'Ctrl+Z / Ctrl+Y            Отменить / Повторить' + CR +
      'F1                         Эта шпаргалка' + CR +
      CR +
      'РЕДАКТИРОВАНИЕ' + CR +
      '─────────────────────────────────────────────' + CR +
      '• Поиск и замена, в т.ч. «Заменить всё» и поиск по кругу.' + CR +
      '• Переход к строке по номеру.' + CR +
      '• Комментирование/раскомментирование выделенных строк' + CR +
      '  (префикс берётся из правил подсветки текущего языка).' + CR +
      '• Авто-отступ: новая строка наследует отступ предыдущей.' + CR +
      CR +
      'ВИД' + CR +
      '─────────────────────────────────────────────' + CR +
      '• Номера строк (можно скрыть в меню «Вид»).' + CR +
      '• Масштаб (Ctrl+колесо или меню).' + CR +
      '• Перенос строк (вкл/выкл). Для кода рекомендуется ВЫКЛ —' + CR +
      '  тогда номера строк совпадают со строками точно.' + CR +
      CR +
      'ФАЙЛЫ' + CR +
      '─────────────────────────────────────────────' + CR +
      '• Открытие/сохранение .rtf и текстовых файлов.' + CR +
      '• Кодировки: UTF-8 (по умолчанию), CP1251, CP866 —' + CR +
      '  переключатель на панели инструментов.' + CR +
      '• Список последних файлов (меню «Файл»).' + CR +
      '• Открытие перетаскиванием файла в окно (drag & drop).' + CR +
      CR +
      'ЗАПУСК' + CR +
      '─────────────────────────────────────────────' + CR +
      '• F5 — выполнить; вывод программы идёт в нижнюю панель.' + CR +
      '• Запуск по расширению: если расширение открытого файла' + CR +
      '  указано в [Interpreters] файла run_settings.ini, запускается' + CR +
      '  именно этот файл (иначе — source.py из секции [Run]).' + CR +
      '• Ctrl+F2 — остановить; по завершении печатается код возврата.' + CR +
      '• Настройки запуска: меню «Настройки» → run_settings.ini.';

    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TForm1.ZoomBy(Delta: Integer);
var
  Z: Integer;
begin
  Z := RichEdit1.Zoom + Delta;
  if Z < 20 then Z := 20;
  if Z > 500 then Z := 500;
  RichEdit1.Zoom := Z;
  InvalidateGutter;
end;

{ ---- Run / Stop --------------------------------------------------------- }

procedure TForm1.RunScript;
var
  AppPath, RunFile, FullFileName, WorkDir, CmdLine: string;
  Executable, Arguments, Ext, Mapped: string;
  RunOpenFile: Boolean;
  Ini: TIniFile;
  Strings: TStringList;
  SI: TStartupInfo;
  PI: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  StdOutPipeRead, StdOutPipeWrite, StdErrPipeRead, StdErrPipeWrite: THandle;
begin
  if FRunningProcess <> 0 then
  begin
    MessageDlg('Процесс уже выполняется. Сначала остановите его (Ctrl+F2).',
               mtInformation, [mbOk], 0);
    Exit;
  end;

  RichEdit2.Clear;
  AppPath := ExtractFileDir(Application.ExeName);

  Ini := TIniFile.Create(AppPath + '\run_settings.ini');
  try
    Executable := Ini.ReadString('Run', 'Executable', 'python');
    RunFile := Ini.ReadString('Run', 'FileName', 'source.py');
    Arguments := Ini.ReadString('Run', 'Arguments', '');
    // Run-by-extension: if the open file's extension is mapped in [Interpreters],
    // run that actual file instead of the generic source.py target.
    Ext := LowerCase(Copy(ExtractFileExt(File_Name), 2, MaxInt));
    Mapped := '';
    if (Ext <> '') and (File_Name <> 'NoName.rtf') then
      Mapped := Ini.ReadString('Interpreters', Ext, '');
    RunOpenFile := Mapped <> '';
    if RunOpenFile then
      Executable := Mapped;
  finally
    Ini.Free;
  end;

  if RunOpenFile then
  begin
    FullFileName := File_Path + File_Name;
    WorkDir := ExcludeTrailingPathDelimiter(File_Path);
    if WorkDir = '' then WorkDir := AppPath;
    CmdLine := '"' + Executable + '" "' + File_Name + '" ' + Arguments;
  end
  else
  begin
    FullFileName := AppPath + '\' + RunFile;
    WorkDir := AppPath;
    CmdLine := '"' + Executable + '" "' + RunFile + '" ' + Arguments;
  end;

  // Save current editor content to the file we are about to run (UTF-8).
  Strings := TStringList.Create;
  try
    Strings.Text := RichEdit1.Text;
    Strings.SaveToFile(FullFileName, TEncoding.UTF8);
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
    SetHandleInformation(StdOutPipeRead, HANDLE_FLAG_INHERIT, 0);
    SetHandleInformation(StdErrPipeRead, HANDLE_FLAG_INHERIT, 0);

    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(SI);
    SI.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    SI.wShowWindow := SW_HIDE;
    SI.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
    SI.hStdOutput := StdOutPipeWrite;
    SI.hStdError := StdErrPipeWrite;

    if CreateProcess(nil, PChar(CmdLine), nil, nil, True, CREATE_NO_WINDOW,
                     nil, PChar(WorkDir), SI, PI) then
    begin
      CloseHandle(PI.hThread);
      FRunningProcess := PI.hProcess;   // kept open for Stop / exit-code wait
      if FStopItem <> nil then FStopItem.Enabled := True;
      StatusBar1.Panels[0].Text := 'Запущено: ' + Executable;

      TOutputReaderThread.Create(StdOutPipeRead, AddToOutput, clBlack);
      TOutputReaderThread.Create(StdErrPipeRead, AddToOutput, clRed);
      TProcessWaitThread.Create(PI.hProcess, ProcessFinished);
    end
    else
      MessageDlg('Не удалось выполнить: ' + CmdLine + #13#10 +
                 'Ошибка: ' + SysErrorMessage(GetLastError), mtError, [mbOK], 0);
  finally
    CloseHandle(StdOutPipeWrite);
    CloseHandle(StdErrPipeWrite);
  end;
end;

procedure TForm1.StopRunning;
begin
  if FRunningProcess <> 0 then
    TerminateProcess(FRunningProcess, 1);
  // The wait thread will fire ProcessFinished and reset the UI.
end;

procedure TForm1.ProcessFinished(ExitCode: DWORD);
begin
  AddToOutput(#13#10 + Format('=== Завершено, код возврата: %d ===', [ExitCode]) + #13#10,
              clBlue);
  if FRunningProcess <> 0 then
  begin
    CloseHandle(FRunningProcess);
    FRunningProcess := 0;
  end;
  if FStopItem <> nil then FStopItem.Enabled := False;
  StatusBar1.Panels[0].Text := File_Path + File_Name;
end;

{ ---- Auto-indent & drag-and-drop --------------------------------------- }

procedure TForm1.RichEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LineIdx, i: Integer;
  Line, Indent: string;
begin
  if (Key = VK_RETURN) and (Shift = []) then
  begin
    LineIdx := RichEdit1.Perform(EM_LINEFROMCHAR, RichEdit1.SelStart, 0);
    if (LineIdx >= 0) and (LineIdx < RichEdit1.Lines.Count) then
    begin
      Line := RichEdit1.Lines[LineIdx];
      Indent := '';
      for i := 1 to Length(Line) do
        if (Line[i] = ' ') or (Line[i] = #9) then
          Indent := Indent + Line[i]
        else
          Break;
      if Indent <> '' then
      begin
        RichEdit1.SelText := #13 + Indent;
        Key := 0;   // consume the default Enter so the line isn't broken twice
      end;
    end;
  end;
end;

procedure TForm1.WMDropFiles(var Msg: TWMDropFiles);
var
  Count: Integer;
  Buf: array[0..MAX_PATH] of Char;
begin
  Count := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
  if Count > 0 then
  begin
    DragQueryFile(Msg.Drop, 0, Buf, Length(Buf));
    if FileExists(Buf) then
      LoadFile(Buf);
  end;
  DragFinish(Msg.Drop);
  Msg.Result := 0;
end;

{ TProcessWaitThread }

constructor TProcessWaitThread.Create(AProcess: THandle; AOnDone: TProcessDoneEvent);
begin
  inherited Create(False);
  FProcess := AProcess;
  FOnDone := AOnDone;
  FreeOnTerminate := True;
end;

procedure TProcessWaitThread.Execute;
begin
  WaitForSingleObject(FProcess, INFINITE);
  FExitCode := 0;
  GetExitCodeProcess(FProcess, FExitCode);
  Synchronize(DoDone);
end;

procedure TProcessWaitThread.DoDone;
begin
  if Assigned(FOnDone) then
    FOnDone(FExitCode);
end;

end.

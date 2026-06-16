unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, IniFiles;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label5: TLabel;
    Memo1: TMemo;
    Label6: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    EditExecutable: TEdit;
    EditFileName: TEdit;
    EditArguments: TEdit;
    LabelExecutable: TLabel;
    LabelFileName: TLabel;
    LabelArguments: TLabel;
    function SettingsFileName: string;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

function TForm2.SettingsFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) +
            'run_settings.ini';
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Self.Caption := 'Настройки запуска';

  // The old build hid Memo1 and created three Edit boxes that were never wired
  // to anything, so the dialog edited an invisible memo. Build a small, working
  // "Run configuration" form instead.
  Memo1.Visible := False;
  Label2.Visible := False;

  // The Save button has Kind = bkYes (auto-closes with mrYes). Disarm it so we
  // can keep the dialog open when saving fails.
  BitBtn1.ModalResult := mrNone;

  LabelExecutable := TLabel.Create(Self);
  LabelExecutable.Parent := Self;
  LabelExecutable.Caption := 'Исполняемый файл (Executable):';
  LabelExecutable.SetBounds(16, 50, 200, 15);

  EditExecutable := TEdit.Create(Self);
  EditExecutable.Parent := Self;
  EditExecutable.SetBounds(16, 67, 195, 23);

  LabelFileName := TLabel.Create(Self);
  LabelFileName.Parent := Self;
  LabelFileName.Caption := 'Файл скрипта (FileName):';
  LabelFileName.SetBounds(16, 96, 200, 15);

  EditFileName := TEdit.Create(Self);
  EditFileName.Parent := Self;
  EditFileName.SetBounds(16, 113, 195, 23);

  LabelArguments := TLabel.Create(Self);
  LabelArguments.Parent := Self;
  LabelArguments.Caption := 'Аргументы (Arguments):';
  LabelArguments.SetBounds(16, 142, 200, 15);

  EditArguments := TEdit.Create(Self);
  EditArguments.Parent := Self;
  EditArguments.SetBounds(16, 159, 195, 23);
end;

procedure TForm2.FormShow(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(SettingsFileName);
  try
    EditExecutable.Text := Ini.ReadString('Run', 'Executable', 'python');
    EditFileName.Text   := Ini.ReadString('Run', 'FileName', 'source.py');
    EditArguments.Text  := Ini.ReadString('Run', 'Arguments', '');
  finally
    Ini.Free;
  end;
end;

procedure TForm2.BitBtn1Click(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(SettingsFileName);
  try
    try
      Ini.WriteString('Run', 'Executable', Trim(EditExecutable.Text));
      Ini.WriteString('Run', 'FileName', Trim(EditFileName.Text));
      Ini.WriteString('Run', 'Arguments', Trim(EditArguments.Text));
      Ini.UpdateFile;
      ModalResult := mrOk;
    except
      on E: Exception do
        MessageDlg('Не удалось сохранить файл настроек: ' + E.Message,
                   mtError, [mbOk], 0);
    end;
  finally
    Ini.Free;
  end;
end;

end.

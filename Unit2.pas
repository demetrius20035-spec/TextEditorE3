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
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  Self.Caption := 'Run Settings';
  Memo1.Visible := False;
  Label1.Visible := False;
  Label2.Visible := False;
  Label3.Visible := False;
  {Label4.Visible := False;}
  Label5.Visible := False;

  LabelExecutable := TLabel.Create(Self);
  LabelExecutable.Parent := Self;
  LabelExecutable.Caption := 'Executable:';
  LabelExecutable.Top := 20;
  LabelExecutable.Left := 10;

  EditExecutable := TEdit.Create(Self);
  EditExecutable.Parent := Self;
  EditExecutable.Top := 40;
  EditExecutable.Left := 10;
  EditExecutable.Width := Self.Width - 40;

  LabelFileName := TLabel.Create(Self);
  LabelFileName.Parent := Self;
  LabelFileName.Caption := 'File Name:';
  LabelFileName.Top := 70;
  LabelFileName.Left := 10;

  EditFileName := TEdit.Create(Self);
  EditFileName.Parent := Self;
  EditFileName.Top := 90;
  EditFileName.Left := 10;
  EditFileName.Width := Self.Width - 40;

  LabelArguments := TLabel.Create(Self);
  LabelArguments.Parent := Self;
  LabelArguments.Caption := 'Arguments:';
  LabelArguments.Top := 120;
  LabelArguments.Left := 10;

  EditArguments := TEdit.Create(Self);
  EditArguments.Parent := Self;
  EditArguments.Top := 140;
  EditArguments.Left := 10;
  EditArguments.Width := Self.Width - 40;

  BitBtn1.Top := 180;
end;

procedure TForm2.FormShow(Sender: TObject);
var
  SettingsFileName: string;
begin
  SettingsFileName := ExtractFileDir(Application.ExeName) + '\run_settings.ini';
  if FileExists(SettingsFileName) then
  begin
    Memo1.Lines.LoadFromFile(SettingsFileName);
  end
  else
  begin
    // Если файла нет, можно вставить текст по умолчанию
    Memo1.Lines.Clear;
    Memo1.Lines.Add('[Run]');
    Memo1.Lines.Add('Executable=python');
    Memo1.Lines.Add('FileName=source.py');
    Memo1.Lines.Add('Arguments=');
  end;
end;

procedure TForm2.BitBtn1Click(Sender: TObject);
var
  SettingsFileName: string;
begin
  SettingsFileName := ExtractFileDir(Application.ExeName) + '\run_settings.ini';
  try
    Memo1.Lines.SaveToFile(SettingsFileName);
    // Закрываем форму после успешного сохранения.
    // ModalResult := mrOk говорит главному окну, что мы нажали "ОК"
    ModalResult := mrOk;
  except
    on E: Exception do
    begin
      MessageDlg('Не удалось сохранить файл настроек: ' + E.Message, mtError, [mbOk], 0);
    end;
  end;
end;

end.

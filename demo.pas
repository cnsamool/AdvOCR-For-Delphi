unit demo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ExtDlgs, IniFiles;

type
  TForm1 = class(TForm)
    btn: TButton;
    edtResult: TEdit;
    Image: TImage;
    CbbType: TComboBox;
    Lbl: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    procedure btnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CbbTypeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  DLL_NAME = 'AdvOCR.dll';
  CFG_NAME = 'OCRtypedef.ini';

var
  Form1: TForm1;
  Ini : TIniFile;

  procedure IMG2BMP(filename : PChar); Stdcall;external DLL_NAME name 'IMG2BMP';
  function OcrInit : boolean; Stdcall;external DLL_NAME name 'OcrInit';
  procedure OcrDone; Stdcall;external DLL_NAME name 'OcrDone';
  function OCR_C(OCR_type,filename : PChar): PChar; Stdcall;external DLL_NAME name 'OCR_C';
  function OCR_B(OCR_type,filename : PChar; var CodeStr : PChar): boolean; Stdcall;external DLL_NAME name 'OCR_B';

implementation

{$R *.dfm}

procedure TForm1.btnClick(Sender: TObject);
var
  OpenDialog   : TOpenPictureDialog;
  OcrType,Code : String;
begin
  OcrType := CbbType.Text;
  OpenDialog := TOpenPictureDialog.Create(Self);
  with OpenDialog do
  begin
    try
      InitialDir := ExtractFilePath(ParamStr(0))+OcrType+'\';
      Filter := '*.jpg;*.gif;*.bmp;*.png|*.jpg;*.gif;*.bmp;*.png';
      if Execute then
      begin
        Code := StrPas(OCR_C(PChar(OcrType),PChar(FileName)));
        if Code <> '?' then
        begin
          IMG2BMP(PChar(FileName));
          Image.Picture.LoadFromFile(FileName+'.BMP');
          DeleteFile(FileName+'.BMP');
          edtResult.Text := Code;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Lbl.Caption := '';
  Ini := TIniFile.Create(GetCurrentDir+'\'+CFG_NAME);
  Ini.ReadSection('OcrType',CbbType.Items);
  CbbType.ItemIndex := 0;
  CbbTypeClick(nil);
  if not OcrInit then
  begin
    ShowMessage('OCR engine Init Fail!');
    Close;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  OcrDone;
  Ini.free;
end;

procedure TForm1.CbbTypeClick(Sender: TObject);
begin
  Lbl.Caption := Ini.ReadString('OcrType',CbbType.Text,'common');
end;

end.

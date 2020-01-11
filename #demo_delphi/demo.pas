unit demo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    btn: TButton;
    edtResult: TEdit;
    Image: TImage;
    CbbType: TComboBox;
    procedure btnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  DLL_NAME = 'AdvOCR.dll';

var
  Form1: TForm1;

  procedure IMG2BMP(filename : PChar); Stdcall;external DLL_NAME name 'IMG2BMP';
  function OcrInit : boolean; Stdcall;external DLL_NAME name 'OcrInit';
  procedure OcrDone; Stdcall;external DLL_NAME name 'OcrDone';
  function OCR_C(OCR_type,filename : PChar): PChar; Stdcall;external DLL_NAME name 'OCR_C';
  function OCR_B(OCR_type,filename : PChar; var CodeStr : PChar): boolean; Stdcall;external DLL_NAME name 'OCR_B';

implementation

{$R *.dfm}

procedure TForm1.btnClick(Sender: TObject);
var
  OpenDialog   : TOpenDialog;
  OcrType,Code : String;
begin
  OcrType := CbbType.Text;
  OpenDialog := TOpenDialog.Create(Self);
  with OpenDialog do
  begin
    try
      InitialDir := ExtractFilePath(ParamStr(0))+OcrType+'\';
      Filter := 'All Files(*.*)|*.*';
      if Execute then
      begin
        Code := StrPas(OCR_C(PChar(OcrType),PChar(FileName)));
        if Code <> '?' then
        begin
          IMG2BMP(PChar(FileName));
          Image.Picture.LoadFromFile(FileName + '.BMP');
          DeleteFile(FileName + '.BMP');
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
  CbbType.Items.Add('monternet');
  CbbType.Items.Add('keepc');
  CbbType.Items.Add('126_mail');
  CbbType.Items.Add('alipay');
  CbbType.Items.Add('yahoo_bulo');
  CbbType.Items.Add('alibaba');
  CbbType.ItemIndex := 0;
  if not OcrInit then
  begin
    ShowMessage('OCR engine Init Fail!');
    Close;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  OcrDone;
end;

end.

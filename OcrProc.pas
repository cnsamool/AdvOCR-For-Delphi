unit OcrProc;

interface

uses
  EnOcrEng,        { for TOcrEngine, TOcrDriver }
  EnDiGrph,        { for TDibGraphic }
  EnTrsOcr,        { for TTransymOcrDriver }
  EnConsoleOcr,    { for TConsoleOcrDriver }
  EnPpmGr,         { for TPpmGraphic }
  EnTransf,
  define,
  Windows, SysUtils, Classes, Graphics, Registry, Dialogs, Forms;

type
  TOcrProgress = class
  public
    _Percent : Byte;
    procedure OnProgress( const Sender          : TObject;
                          const PercentProgress : Byte );
  end;


  function OcrInit : boolean;stdcall;
  procedure OcrDone;stdcall;
  procedure IMG2BMP(filename : PChar); stdcall;

  function OCR_B(OCR_type,file_name: PChar; var CodeStr : PChar): boolean ;stdcall;
  function OCR_C(OCR_type,file_name: PChar): PChar; stdcall;

  function OCR_core(OCR_type,file_name : String; var CodeStr :String):boolean;

  function InstallOcrEngine : boolean;
{$ifndef unregister}
  function RestoreRegistry : boolean;
{$endif}
  function OcrImage(Img : TDibGraphic; DriverClass : TOcrDriverClass): String;
  procedure ConfigureGOCR( const OcrEngine : TOcrEngine );
  procedure SaveImg(BMP : TBitmap);
  
  function TRS_OCR(BMP : TBitmap) : String;
  function G_OCR(BMP : TBitmap) : String;
  procedure ROTATE_OCR(ResultSl : TStringList; BMP : TBitmap; Engine : TOcrEngineType; MinChrWidth, MinChrHeight, SampleCount,PickCount : Integer; SampleAngle : Double);

  function Common_OCR(BMP : TBitmap) : String;

{$ifdef 163_esales}
  function Esales_163_OCR(BMP : TBitmap) : String;
{$endif}

{$ifdef 16288}
  function Esales_16288_OCR(BMP : TBitmap) : String;
{$endif}

{$ifdef kingsoft}
  function Esales_KingSoft_OCR(BMP : TBitmap): String;
{$endif}

{$ifdef 126_mail}
  function Mail_126_OCR(BMP : TBitmap) : String;
{$endif}

{$ifdef keepc}
  function Keepc_OCR(BMP : TBitmap) : String;
{$endif}

{$ifdef qq}
  function Esales_QQ_OCR(BMP : TBitmap): String;
  function Esales_QQ_Mapping(Sl : TStringList): String;
{$endif}

{$ifdef alibaba}
  function Alibaba_OCR(BMP : TBitmap): String;
{$endif}

{$ifdef yahoo_bulo}
  function Yahoo_bulo_OCR(BMP : TBitmap): String;
  function Yahoo_bulo_Mapping(Sl : TStringList): String;
{$endif}

{$ifdef alipay}
  function AliPay_OCR(BMP : TBitmap): String;
{$endif}

{$ifdef mail139}
  function mail139_OCR(BMP : TBitmap): String;
{$endif}

{$ifdef monternet}
  function Monternet_OCR(BMP : TBitmap): String;
{$endif}

{$ifdef taobao}
  function TaoBao_OCR(BMP : TBitmap): String;
  function TaoBao_Mapping(Sl : TStringList): string;
{$endif}

{$ifdef 163_mail}
  function Mail_163_OCR(BMP : TBitmap): String;
{$endif}

{$ifdef the9}
  function Esales_the9_OCR(BMP : TBitmap): String;
{$endif}

{$ifdef 95599}
  function Bank_95599_OCR(BMP : TBitmap): string;
{$endif}

{$ifdef icbc}
  function Bank_icbc_OCR(BMP : TBitmap): string;
{$endif}

{$ifdef sina_bbs}
  function Sina_bbs_OCR(BMP : TBitmap): String;
  function Sina_bbs_Mapping(Sl : TStringList): string;
{$endif}

{$ifdef sina_mail}
  function Sina_Mail_OCR(BMP : TBitmap): String;
{$endif}

{$ifdef 163_bbs}
  function Bbs_163_OCR(BMP : TBitmap): String;
{$endif}

{$ifdef 12530}
  function Mobile_12530_OCR(BMP : TBitmap):string;  // poll
{$endif}

{$ifdef sostar}
  function Yahoo_sostar_OCR(BMP : TBitmap):string;  // poll
  function Yahoo_sostar_Mapping(Sl : TStringList): string;
{$endif}

{$ifdef sharebank}
  function ShareBank_OCR(BMP : TBitmap):string;
{$endif}

{$ifdef csdn}
  function Csdn_OCR(BMP : TBitmap):string;
{$endif}

{$ifdef tiancity}
  function TianCity_OCR(BMP : TBitmap):string;
{$endif}

{$ifdef qpgame}
  function QpGame_OCR(BMP : TBitmap):string;
{$endif}

{$IFDEF qpgame_new}
  function QpGame_New_OCR(BMP : TBitmap):string;
{$ENDIF}

{$IFDEF baidu}
  function Baidu_OCR(BMP : TBitmap): string;        
  function Baidu_Mapping(Sl : TStringList): string;
{$ENDIF}

{$ifdef dvbbs}
  function Dvbbs_OCR(BMP : TBitmap):string;
  function Dvbbs_Mapping(Sl : TStringList): string;
{$endif}

{$IFDEF china1168}
  function China1168_OCR(BMP : TBitmap): string;    //uncomplete
{$ENDIF}

{$IFDEF ly_poll}
  function LY_Poll_OCR(BMP : TBitmap): string;
{$ENDIF}

{$IFDEF qieee}
  function Qieee_OCR(BMP : TBitmap): string;
{$ENDIF}

{$IFDEF chinamobile}
  function ChinaMobile_OCR(BMP : TBitmap): string;
{$ENDIF}

{$IFDEF gamigo}
  function Gamigo_OCR(BMP : TBitmap): string;
{$ENDIF}

  function Test_OCR(BMP : TBitmap): string;


var
  OcrProgress : TOcrProgress;

implementation

uses
  ImgProc, MathUtil;

function OcrInit : boolean;stdcall;
begin
  Result := False;
  if Init_Succ then Exit;
  //added for using gocr 2006-3-26
  RegisterDibGraphic( 'PBM', 'Portable Bitmap', TPpmGraphic);
  
  Result := InstallOcrEngine;
  Init_Succ := Result;
  if Result then
  begin
{$ifndef unregister}
    RestoreRegistry;
{$endif}
    OcrProgress := TOcrProgress.Create;
    OCR_Count := 0;
    //OCR_Proc_Lock := False;
    AppPath := ExtractFilePath(ParamStr(0));
  end;
end;

procedure OcrDone; stdcall;
begin
  OcrProgress.Free;
{$ifndef unregister}
  RestoreRegistry;
{$endif}
end;

procedure IMG2BMP(filename : PChar); stdcall;
var
  format : string;
begin
  ToBmpFile(StrPas(filename),format);
end;

{$ifndef unregister}
function RestoreRegistry : boolean;
var
  ARegistry : TRegistry;
  SEED_REG,VERT_REG,HORZ_REG,IVAL_REG : Array[0..255] of Char;
begin
  Result := True;
  SEED_REG := SEED_REG_VAL;
  VERT_REG := VERT_REG_VAL;
  HORZ_REG := HORZ_REG_VAL;
  IVAL_REG := IVAL_REG_VAL;
  ARegistry := TRegistry.Create;
  with ARegistry do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      try
        if OpenKey(SEED_REGISTRY,false) then
        WriteBinaryData('Seed',SEED_REG,Length(SEED_REG_VAL));
        CloseKey;
        if OpenKey(VERT_REGISTRY,false) then
        WriteBinaryData('_IVertbin',VERT_REG,Length(VERT_REG_VAL));
        CloseKey;
        if OpenKey(HORZ_REGISTRY,false) then
        WriteBinaryData('_IHorzBin',HORZ_REG,Length(HORZ_REG_VAL));
        CloseKey;
        if OpenKey(IVAL_REGISTRY,false) then
        WriteBinaryData('_IValBin' ,IVAL_REG,Length(IVAL_REG_VAL));
        CloseKey;
      except
        Result := False;
      end;
    finally
      Free;
    end;
  end;
end;
{$endif}


function InstallOcrEngine : boolean;
var
  ARegistry : TRegistry;
  TOCRDLL,TOCRINI,TOCRSERVICE_PATH,TOCRSERVICE : String;
  AppPath,Service,Dll,Ini : String;
begin
  Result := False;
  AppPath := ExtractFilePath(ParamStr(0));
  TOCRINI :=  GetSpecialFolderDir(36)+'\TOCR.ini';
  TOCRDLL :=  GetSpecialFolderDir(37)+'\TOCRdll.dll';
  ARegistry := TRegistry.Create;
  with ARegistry do
  begin
    RootKey := HKEY_LOCAL_MACHINE;
    try
      if OpenKey(TOCR_REGISTRY,false) then
      begin
        TOCRSERVICE := ReadString('Service');
        Result :=  FileExists(TOCRDLL) and FileExists(TOCRSERVICE);
      end;
      if not Result then
      begin
        try
          TOCRSERVICE_PATH := GetSpecialFolderDir(38)+'\99kooOcrEngine\';
          TOCRSERVICE := TOCRSERVICE_PATH + 'TOCRservice.exe';
          if Not DirectoryExists(TOCRSERVICE_PATH) then
          CreateDirectory(PChar(TOCRSERVICE_PATH),nil);
          Application.ProcessMessages;
          Service := AppPath+'TRSOCR.dat';
          Dll := AppPath+'TRSOCR.dll';
          Ini := AppPath+'TRSOCR.ini';
          if FileExists(Service) and
             FileExists(Dll) and
             FileExists(Ini) then
          begin
            if not FileExists(TOCRSERVICE) then
            CopyFile(PChar(Service),PChar(TOCRSERVICE),TRUE);
            if not FileExists(TOCRDLL) then
            CopyFile(PChar(Dll),PChar(TOCRDLL),TRUE);
            if not FileExists(TOCRINI) then
            CopyFile(PChar(Ini),PChar(TOCRINI),TRUE);
            Result := OpenKey(TOCR_REGISTRY,True);
            if Result then
            WriteString('Service',TOCRSERVICE);
          end;
        except
          Result := False;
        end;
      end;
    finally
      Free;
    end;
  end;

end;


procedure TOcrProgress.OnProgress( const Sender          : TObject;
                                   const PercentProgress : Byte );
begin
  if PercentProgress < 100 then
  _Percent := PercentProgress;
    {if (PercentProgress < 100) then
    begin
        ProgressBar.Position := PercentProgress;
        if not ProgressBar.Visible then
            ProgressBar.Visible := True;
    end
    else
        ProgressBar.Visible := False;   }
end;


function OcrImage(Img : TDibGraphic; DriverClass : TOcrDriverClass): string;
var
    Results   : TStringList;
    st,ed : Cardinal;
    OcrEngine : TOcrEngine;
begin
    //TConsoleOcrDriver
    //OcrEngine := TOcrEngine.Create(TTransymOcrDriver);
    OcrEngine := TOcrEngine.Create(DriverClass);
    Results   := TStringList.Create;
    try
        ConfigureGOCR(OcrEngine);
        //st := GetTickCount;
        OcrEngine.Recognize( Img, Results, OcrProgress.OnProgress);
        //ed := GetTickCount;
        //Image.Hint := Format('%d ms',[ed-st]);
        Result := Results.Text;
        //RmEnter(Result);
    finally
        Results.Free;
        OcrEngine.Free;
    end;
end;


procedure ConfigureGOCR( const OcrEngine : TOcrEngine );
begin
    if OcrEngine.Driver is TConsoleOcrDriver then
    begin
        TConsoleOcrDriver(OcrEngine.Driver).InputFileFormat := 'pbm';
        TConsoleOcrDriver(OcrEngine.Driver).OcrProgram      := 'gocr.dll';
    end;
end;


procedure SaveImg(BMP : TBitmap);
begin
  BMP.SaveToFile(ExtractFilePath(ParamStr(0))+ SAMPLE_BMP);
end;

function G_OCR(BMP : TBitmap) : String;
var
  DibImg,Img : TDibGraphic;
  Transform :  TConvertToGrayTransform ;
begin
  PF1(BMP);
  DibImg := TDibGraphic.Create;
  DibImg.Assign(BMP);
  Img := TDibGraphic.Create;
  Transform := TConvertToGrayTransform.Create;
  try
    //Transform.OnProgress := Self.OnProgress;
    Transform.ApplyOnDest(DibImg, Img);
  finally
      Transform.Free;
  end;
  try
    Result := OcrImage(Img,TConsoleOcrDriver);
  finally
    Img.Free;
  end;
  DibImg.Free;
end;

function TRS_OCR(BMP : TBitmap) : String;
var
  DibImg : TDibGraphic;
begin
  DibImg := TDibGraphic.Create;
  try
    DibImg.Assign(BMP);
    Result := OcrImage(DibImg,TTransymOcrDriver);
  finally
    DibImg.Free;
  end;
end;

procedure ROTATE_OCR(ResultSl : TStringList; BMP : TBitmap; Engine : TOcrEngineType; MinChrWidth, MinChrHeight, SampleCount,PickCount : Integer; SampleAngle : Double);
var
  RotateSamples : Array[0..9] of TBitmap;
  i, ChrCt : Integer;
  OcrText : String;
begin
  ChrCt := Build_RotateSample_All(BMP, RotateSamples,MinChrWidth, MinChrHeight, SampleCount,PickCount, SampleAngle);
  for i:=0 to ChrCt-1 do
  begin
    // for debug
{$ifdef imgdebug}
    RotateSamples[i].SaveToFile(ExtractFilePath(ParamStr(0))+'Rotate_'+IntToStr(i+1)+'.bmp');
{$endif}
    case Engine of
    otTransym  : begin
                   OcrText := TRS_OCR(RotateSamples[i]);
                   RmEnter(OcrText);
                   if Trim(OcrText) = '' then
                   begin
                     OcrText := G_OCR(RotateSamples[i]);
                     RmEnter(OcrText);
                   end;
                   ResultSl.Add(OcrText);
                 end;
    otGOCR     : begin
                   OcrText := G_OCR(RotateSamples[i]);
                   RmEnter(OcrText);
                   ResultSl.Add(OcrText);
                 end;
    end;
  end;
end;


function Common_OCR(BMP : TBitmap) : String;
begin
  P2V(BMP,200);
  To_Sample(BMP,5,5);
  Result := TRS_OCR(BMP);
end;

{$ifdef 163_esales}
function Esales_163_OCR(BMP : TBitmap) : String;
var
  OcrSl,ASl : TStringList;
  i,j : Byte;
  RetStr,C : String;
begin
  Result := '';
  P2V(BMP,128);
  RetStr := TRS_OCR(BMP);
  for i:=1 to Length(RetStr) do
    if RetStr[i] in ['0'..'9'] then
    Result := Result + RetStr[i];
  if Length(Result)<>4 then
  begin
    Result := '';
    OcrSl := TStringList.Create;
    ROTATE_OCR(OcrSl,BMP,otTransym,0,0,5,5,20);
    ASl := TStringList.Create;
    for i:=0 to OcrSl.Count-1 do
    begin
      ASl.Clear;
      RetStr := OcrSl[i];
      for j:=1 to Length(RetStr) do
      begin
        if (RetStr[j] in ['0'..'9'])OR(RetStr[j] in ['O','G']) then
        AddSlPro(ASl,RetStr[j]);
        if ASl.Count > 0 then
        begin
          SortPro(ASl,0,ASl.Count-1);
          InvertSl(ASl);
          C := GetHead(ASl[0]);
          case C[1] of
          'O' : C := '0';
          'G' : C := '6';
          end;
        end;
      end;
      Result := Result + C;
    end;
    ASl.Free;
    OcrSl.Free;
  end;
end;
{$endif}

{$ifdef 16288}
function Esales_16288_OCR(BMP : TBitmap) : String;
var
  i : Byte;
  RetStr : String;
begin
  Result := '';
  P2V(BMP,150);

  //for i:=0 to 3 do
  RmNoise1p(BMP);
  RmNoise4p(BMP);
  RmNoise1pEx(BMP);
  //Thin(BMP);
  To_Sample(BMP,5,5);
  //MidV_Filter(BMP);
  //
  RetStr := TRS_OCR(BMP);
  for i:=1 to Length(RetStr) do
    if (RetStr[i] in ['A'..'Z']) OR (RetStr[i] in ['0'..'9'])then
    Result := Result + RetStr[i];
  for i:=1 to Length(Result) do
    if Result[i] = 'O' then
    Result[i] := 'Q'
    else if Result[i] = '0' then
    Result[i] := 'U'
    else if Result[i] = 'I' then
    Result[i] := '1';
end;
{$endif}

{$ifdef kingsoft}
function Esales_KingSoft_OCR(BMP : TBitmap): String;
begin
  P2V(BMP,128);
  if AveGrayV(BMP)<50 then RVS(BMP)
  else RmEdge(BMP,1);
  To_Sample(BMP,0,0);
  //
  Result := TRS_OCR(BMP);
end;
{$endif}

{$ifdef 126_mail}
function Mail_126_OCR(BMP : TBitmap) : String;
var
  RetStr : String;
  i : Integer;
begin
  Result := '';
  P2V(BMP,100);
  RetStr := TRS_OCR(BMP);
  for i := 1 to Length(RetStr) do
  if (RetStr[i] in ['0'..'9'])or(RetStr[i] in ['a'..'z'])or(RetStr[i] in ['A'..'Z'])then
  Result := Result + RetStr[i];
end;
{$endif}

{$ifdef keepc}
function Keepc_OCR(BMP : TBitmap) : String;
begin
  P2V(BMP,128);
  Result := TRS_OCR(BMP);
end;
{$endif}

{$ifdef yahoo_bulo}
function Yahoo_bulo_OCR(BMP : TBitmap): String;
var
  OcrSl : TStringList;
begin
  P2V(BMP,10);
  RVS(BMP);
  BlurEx(BMP,1,55);

  //
  OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,BMP,otTransym,0,0,5,5,20);
  Result := Yahoo_bulo_Mapping(OcrSl);
  OcrSl.Free;
end;

function Yahoo_bulo_Mapping(Sl : TStringList): String;
var
  i,j : Byte;
  AStr,C : String;
  ASl : TStringList;
begin
  Result := '';
  ASl := TStringList.Create;
  for i:=0 to Sl.Count-1 do
  begin
    AStr := Sl[i];
    ASl.Clear;
    for j:=1 to Length(AStr) do
      if (AStr[j] in ['0'..'9']) then
      AddSlPro(ASl,AStr[j]);
    if ASl.Count > 0 then
    begin
      SortPro(ASl,0,ASl.Count-1);
      InvertSl(ASl);
      C := GetHead(ASl[0]);
      if (C = '1') and (IndexOfPro(ASl,'7')<>-1) then
      C := '7';
      Result := Result + C ;
    end;
  end;
end;
{$endif}

{$ifdef alipay}
function AliPay_OCR(BMP : TBitmap): String;
const
  CharWidth = 9;
  CharHeight = 15;
  OffSet = {54 +} 11;
  Char1V = {6 +} 4;
  Char2V = {6 +} 1;
  Char3V = {6 +} 4;
  Char4V = {6 +} 0;
var
  CharBMP : Array[0..3] of TBitmap;
  ConbineBMP : TBitmap;
  i : Byte;
  RetStr : String;
begin
  Result := '';
  P2V(BMP,128);
  RetStr := TRS_OCR(BMP);

  for i:=1 to Length(RetStr) do
  if RetStr[i] in ['0'..'9'] then
  Result := Result + RetStr[i];

  if Length(Result) = 4 then exit;

  CharBMP[0] := CropChr(BMP,Char1V,Char1V+CharHeight,OffSet,OffSet+CharWidth);
  CharBMP[1] := CropChr(BMP,Char2V,Char2V+CharHeight,OffSet+10,OffSet+10+CharWidth);
  CharBMP[2] := CropChr(BMP,Char3V,Char3V+CharHeight,OffSet+20,OffSet+20+CharWidth);
  CharBMP[3] := CropChr(BMP,Char4V,Char4V+CharHeight,OffSet+30,OffSet+30+CharWidth);
  ConbineBMP := Conbine_Sample(CharBMP,4);
  //ConbineBMP.SaveToFile(ExtractFilePath(ParamStr(0))+'conbine.bmp');
  for i:=0 to 3 do
  begin
    //CharBMP[i].SaveToFile(ExtractFilePath(ParamStr(0))+'cropImg'+IntToStr(i+1)+'.bmp');
    //Result := Result + TRS_OCR(CharBMP[i]);
    CharBMP[i].Free;
  end;
  Result := TRS_OCR(ConbineBMP);
  ConbineBMP.Free;
  for i:=1 to Length(Result) do
  case Result[i] of
  'g': Result[i] := '9';
  'T': Result[i] := '7';
  'S': Result[i] := '5';
  end;
end;
{$endif}

{$ifdef alipay}   //139网站新邮箱
function mail139_OCR(BMP : TBitmap): String;
const
  CharWidth = 8;
  CharHeight = 15;
  OffSet = {54 +} 5;
  Char1V = {6 +} 1;  //垂直距离
  Char2V = {6 +} 1;
  Char3V = {6 +} 1;
  Char4V = {6 +} 1;
var
  CharBMP : Array[0..3] of TBitmap;
  ConbineBMP : TBitmap;
  i : Byte;
  RetStr : String;
  R1,R2,R3,Rok:string;
  myout:Integer;
begin
  Rok := '';
  P2V(BMP,128);
  RmEdge(BMP,1);
  RmNoise1pEx(BMP);
  RmNoise4p(BMP);
  RmNoise4pEx(BMP);
  RmNoise6pH(BMP);
  BlurEx(BMP,1,128);
  RmNoise1pEx(BMP);
  RmNoise6pH(BMP);
  RmNoise4pEx(BMP);

 { //首次直接识别
  RetStr := TRS_OCR(BMP);
  for i:=1 to Length(RetStr) do
  if RetStr[i] in ['0'..'9'] then
  Result := Result + RetStr[i];   }
  
  //拆分为4个数字
  CharBMP[0] := CropChr(BMP,Char1V,Char1V+CharHeight,OffSet,OffSet+CharWidth);
  CharBMP[1] := CropChr(BMP,Char2V,Char2V+CharHeight,OffSet+9,OffSet+10+CharWidth);
  CharBMP[2] := CropChr(BMP,Char3V,Char3V+CharHeight,OffSet+18,OffSet+20+CharWidth);
  CharBMP[3] := CropChr(BMP,Char4V,Char4V+CharHeight,OffSet+27,OffSet+30+CharWidth);
  ConbineBMP := Conbine_Sample(CharBMP,4);
  //ConbineBMP.SaveToFile(ExtractFilePath(ParamStr(0))+'conbine.bmp');
  //分别进行识别
  for i:=0 to 3 do
  begin
    //CharBMP[i].SaveToFile(ExtractFilePath(ParamStr(0))+'cropImg'+IntToStr(i+1)+'.bmp');
   // R1 := R1 + TRS_OCR(CharBMP[i]); //直接识别截取后的完整图
    CharBMP[i].Free;
  end;
  R2 := TRS_OCR(ConbineBMP);
  ConbineBMP.Free;

//  R3:=R1+'|'+R2;
  R3:=R2;

  //纠正错误
  for i:=1 to Length(R3) do
  case R3[i] of
  'g': Rok :=Rok+'9';
  'T': Rok :=Rok+'7';
  'S','&': Rok :=Rok+'5';
  '.': Rok :=Rok;
  ',': Rok :=Rok;
  '''':Rok :=Rok;
  ' ' :Rok :=Rok;
  ';' :Rok :=Rok;
  '-' :Rok :=Rok;
  '?' :Rok :=Rok;
  ':' :Rok :=Rok;
  'O','o' :Rok :=Rok+'0';
  '/':Rok :=Rok+'7';
  '*':Rok :=Rok;
  'G':Rok :=Rok+'6';
  'A':Rok :=Rok+'9';
  'B':Rok :=Rok+'5';
  'Y':Rok :=Rok+'1';
  else
       Rok:=Rok+R3[i];
  end;

  Result:=Trim(Rok);

end;
{$endif}

{$ifdef monternet}
function Monternet_OCR(BMP : TBitmap): String;
var
  AGray : Array[0..255] of Integer;
  Gray,M_h,M_w,ChrCt : Integer;
  i,iChr : Byte;
  ChrBMPs,Chrs : Array[0..3] of TBitmap;
  L_BMP,R_BMP,OCR_BMP : TBitmap;
  RetStr : String;
begin
  Result := '';
  GrayStatus(BMP,AGray);
  for i:=0 to 255 do
  begin
    //if AGray[i] <> 0 then ShowMessage('GRAY:'+IntToStr(i)+' VALUE:'+IntToStr(AGray[i]));
    if AGray[i] <> 0 then
    begin
      Gray := i+1;
      break;
    end;
  end;
  P2V(BMP,Gray);
  ChrCt := GetChars(BMP,ChrBMPs,0,0,M_w,M_h);
  iChr := 0;
  L_BMP := TBitmap.Create;
  R_BMP := TBitmap.Create;
  for i:=0 to ChrCt-1 do
  begin
    //ChrBMPs[i].SaveToFile(ExtractFilePath(ParamStr(0))+IntToStr(i)+'.bmp');
    if ChrBMPs[i].Width>12 then
    begin
      Spilt(ChrBMPs[i],L_BMP,R_BMP);
      Chrs[iChr]:=L_BMP;
      Inc(iChr);
      Chrs[iChr]:=R_BMP;
      Inc(iChr);
    end else begin
      Chrs[iChr]:=ChrBMPs[i];
      Inc(iChr);
    end;
  end;
  OCR_BMP := Conbine_Sample(Chrs,iChr);
  RetStr := TRS_OCR(OCR_BMP);

  for i:=1 to Length(RetStr) do
  if RetStr[i] in ['0'..'9'] then
  Result := Result + RetStr[i];

  for i:=0 to iChr-1 do
  Chrs[i].Free;
  //OCR_BMP.SaveToFile(ExtractFilePath(ParamStr(0))+'haha.bmp');
  OCR_BMP.Free;
end;
{$endif}

{$ifdef taobao}
function TaoBao_OCR(BMP : TBitmap): String;
var
  OcrSl : TStringList;
begin
  P2V(BMP,128);
  RmNoise1p(BMP);
  BlurEx(BMP,1,128);
  OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,BMP,otTransym,3,3,5,7,15);
  //ShowMessage(OcrSl.Text);
  Result := TaoBao_Mapping(OcrSl);
  OcrSl.Free;
end;


function TaoBao_Mapping(Sl : TStringList): string;
var
  i,j : Byte;
  AStr,C : String;
  ASl : TStringList;
  b : boolean;
begin
  Result := '';
  ASl := TStringList.Create;
  for i:=0 to Sl.Count-1 do
  begin
    AStr := Sl[i];
    ASl.Clear;
    {for j:=1 to Length(AStr) do
      case AStr[j] of
      'A': AStr[j] := '4';
      'C': AStr[j] := '0';
      'S': AStr[j] := '5';
      '$': AStr[j] := '5';
      end; }
    for j:=1 to Length(AStr) do
      if (AStr[j] in ['0'..'9'])or(AStr[j] in ['A'..'Z']) then
      AddSlPro(ASl,AStr[j]);

    if ASl.Count > 0 then
    begin
      SortPro(ASl,0,ASl.Count-1);
      InvertSl(ASl);
      C := GetHead(ASl[0]);
      b := False;
      if IndexOfPro(ASl,'W')<>-1 then
      begin
        b := True;
        C := 'W';
      end;
      if not b then
      begin
        if (C = '2') then
        C := 'Z';
        if ((C = 'V')OR(C = 'T')) and (IndexOfPro(ASl,'Y')<>-1) then
        C := 'Y';
        if (C = 'P') and (IndexOfPro(ASl,'F')<>-1) then
        C := 'F';
        if (C = '1') and (IndexOfPro(ASl,'7')<>-1) then
        C := '7';
      end;
      Result := Result + C ;
    end else
      Result := Result + '?';
  end;
end;
{$endif}

{$ifdef 163_mail}
function Mail_163_OCR(BMP : TBitmap): String;
var
  M_h,M_w,ChrCt : Integer;
  i,j,iChr,iSp,iSpM : Byte;
  ChrBMPs,Chrs,SpBMPs : Array[0..9] of TBitmap;
  OCR_BMP : TBitmap;
  RetStr : String;
begin
  P2V(BMP,95);
  RmEdge(BMP,1);
  RmNoise1pEx(BMP);
  //RmNoise4p(BMP);
  RmNoise4pEx(BMP);
  RmNoise6pH(BMP);
  BlurEx(BMP,1,128);
  RmNoise1pEx(BMP);
  RmNoise6pH(BMP);
  RmNoise4pEx(BMP);

  Result := '';
  ChrCt := GetChars(BMP,ChrBMPs,2,5,M_w,M_h);
  iChr := 0;
  for i:=0 to ChrCt-1 do
  begin
    //ChrBMPs[i].SaveToFile(ExtractFilePath(ParamStr(0))+IntToStr(i)+'.bmp');
    if ChrBMPs[i].Width>16 then
    begin
      iSpM := ChrBMPs[i].Width mod 11;
      if iSpM > 5 then
      iSp := (ChrBMPs[i].Width div 11)+1 else
      iSp := ChrBMPs[i].Width div 11;
      
      SpiltEx(ChrBMPs[i],iSp,SpBMPs);
      for j:=0 to iSp-1 do
      begin
        Chrs[iChr] := TBitmap.Create;
        Chrs[iChr].Assign(SpBMPs[j]);
        Inc(iChr);
        SpBMPs[j].Free;
      end;
    end else begin
      Chrs[iChr] := TBitmap.Create;
      Chrs[iChr].Assign(ChrBMPs[i]);
      Inc(iChr);
    end;
    ChrBMPs[i].Free;
  end;

  OCR_BMP := Conbine_Sample(Chrs,iChr,False);
  RmNoise1pEx(OCR_BMP);
  RmNoise4pEx(OCR_BMP);
  RetStr := TRS_OCR(OCR_BMP);
  OCR_BMP.SaveToFile(ExtractFilePath(ParamStr(0))+'haha.bmp');
  OCR_BMP.Free;
   {
  for i:=0 to iChr-1 do
  RetStr := RetStr + G_OCR(Chrs[i]);
  }
  for i:=1 to Length(RetStr) do
  if RetStr[i] in ['0'..'9'] then
  Result := Result + RetStr[i];

  for i:=0 to iChr-1 do
  Chrs[i].Free;
  
end;
{$endif}

{$ifdef the9}
function Esales_the9_OCR(BMP : TBitmap): String;
begin
  P2V(BMP,200);
  RVS(BMP);
  To_Sample(BMP,0,0);
  ReSample(BMP,100,20);
  Result := TRS_OCR(BMP);
end;
{$endif}

{$ifdef 95599}
function Bank_95599_OCR(BMP : TBitmap): string;
begin
  P2V(BMP,0);
  RmNoise1p(BMP);
  Result := TRS_OCR(BMP);
end;
{$endif}

{$ifdef icbc}
function Bank_icbc_OCR(BMP : TBitmap): string;
begin
  P2V(BMP,100);
  RmEdge(BMP,1);
  To_Sample(BMP,2,2);
  Result := TRS_OCR(BMP);
end;
{$endif}

{$ifdef sina_bbs}
function Sina_bbs_OCR(BMP : TBitmap): String;
var
  M_h,M_w,ChrCt : Integer;
  i,iChr : Byte;
  ChrBMPs,Chrs : Array[0..3] of TBitmap;
  L_BMP,R_BMP,OCR_BMP : TBitmap;
  RetStr : String;
  OcrSl : TStringList;
  procedure RM_NOISE(IN_BMP : TBitmap);
  begin
    RmNoise1p(IN_BMP);
    RmNoise1p(IN_BMP);
    RmNoise4pEx(IN_BMP);
    RmNoise4pEx(IN_BMP);
  end;
begin
  Result := '';
  P2V(BMP,160);
  RmEdge(BMP,1);
  RM_NOISE(BMP);
  ChrCt := GetChars(BMP,ChrBMPs,0,0,M_w,M_h);
  iChr := 0;
  L_BMP := TBitmap.Create;
  R_BMP := TBitmap.Create;
  for i:=0 to ChrCt-1 do
  begin
    //ChrBMPs[i].SaveToFile(ExtractFilePath(ParamStr(0))+IntToStr(i)+'.bmp');
    if ChrBMPs[i].Width>16 then
    begin
      Spilt(ChrBMPs[i],L_BMP,R_BMP);
      Chrs[iChr]:=L_BMP;
      RM_NOISE(Chrs[iChr]);
      Inc(iChr);
      Chrs[iChr]:=R_BMP;
      RM_NOISE(Chrs[iChr]);
      Inc(iChr);
    end else begin
      Chrs[iChr]:=ChrBMPs[i];
      Inc(iChr);
    end;
  end;
  OCR_BMP := Conbine_Sample(Chrs,iChr);
  //Result := TRS_OCR(OCR_BMP);
  OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,OCR_BMP,otTransym,2,2,5,5,20);
  //ShowMessage(OcrSl.Text);
  Result := Sina_bbs_Mapping(OcrSl);
  OcrSl.Free;

  {
  for i:=1 to Length(RetStr) do
  if RetStr[i] in ['0'..'9'] then
  Result := Result + RetStr[i];
  }
  for i:=0 to iChr-1 do
  Chrs[i].Free;
  OCR_BMP.SaveToFile(ExtractFilePath(ParamStr(0))+'haha.bmp');
  OCR_BMP.Free;
end;


function Sina_bbs_Mapping(Sl : TStringList): string;
var
  i,j : Byte;
  AStr,C : String;
  ASl : TStringList;
begin
  Result := '';
  ASl := TStringList.Create;
  for i:=0 to Sl.Count-1 do
  begin
    AStr := Sl[i];
    ASl.Clear;
    for j:=1 to Length(AStr) do
      case AStr[j] of
      'A': AStr[j] := '4';
      'C': AStr[j] := '0';
      'S': AStr[j] := '5';
      '$': AStr[j] := '5';
      end;
    for j:=1 to Length(AStr) do
      if (AStr[j] in ['0'..'9']) then
      AddSlPro(ASl,AStr[j]);
    if ASl.Count > 0 then
    begin
      SortPro(ASl,0,ASl.Count-1);
      InvertSl(ASl);
      C := GetHead(ASl[0]);
      if (C = '1') and (IndexOfPro(ASl,'7')<>-1) then
      C := '7';
      if (C = '9') and (IndexOfPro(ASl,'4')<>-1) then
      C := '4';
      if (C = '3') and (IndexOfPro(ASl,'5')<>-1) then
      C := '5';
      Result := Result + C ;
    end else
      Result := Result + '1';
  end;
end;
{$endif}

{$ifdef sina_mail}
function Sina_Mail_OCR(BMP : TBitmap): String;
var
  TmpBMP,LoosenBMP : TBitmap;
  ChrCt,i,M_w,M_h : Integer;
  ChrBMPs : Array[0..3] of TBitmap;
  ChrPos : Array[0..3] of Integer;
  ASl : TStringList;
  OcrStr : String;
begin
  Result := '';
  TmpBMP := TBitmap.Create;
  TmpBMP.Assign(BMP);
  SetBmpPixels(BMP,$BFBFBF,$FFFFFF,ctEqual);
  SetBmpPixels(BMP,$000000,$FFFFFF,ctEqual);
  P2V(BMP,150);
  ChrCt := GetChars(BMP,ChrBMPs,0,0,M_w,M_h);
  GetCharsPos(BMP,0,0,ChrPos);
  //
  ASl := TStringList.Create;
  for i:=0 to ChrCt-1 do
  begin
    LoosenBMP := Loosen(ChrBMPs[i],10);
    OcrStr := TRS_OCR(LoosenBMP);
    LoosenBMP.SaveToFile(AppPath + 'Loosen'+IntToStr(i)+'.bmp');
    LoosenBMP.Free;
    RmEnter(OcrStr);
    ASl.Add(OcrStr + SP + IntToStr(ChrPos[i]));
  end;
  //
  for i:=0 to ChrCt-1 do
  ChrBMPs[i].Free;
  //
  SetBmpPixels(TmpBMP,$000000,$FFFFFF,ctUnequal);
  RmLines(TmpBMP,2,15);
  RmNoise1pEx(TmpBMP);
  GetCharsPos(TmpBMP,0,0,ChrPos);
  LoosenBMP := Loosen(TmpBMP,10);
  OcrStr := TRS_OCR(LoosenBMP);
  LoosenBMP.Free;
  RmEnter(OcrStr);
  ASl.Add(OcrStr + SP + IntToStr(ChrPos[0]));
  TmpBMP.Free;
  //
  //ShowMessage(ASl.Text);
  SortPro(ASl,0,ASl.Count-1);
  for i:=0 to ASl.Count-1 do
  Result := Result + GetHead(ASl[i]);
  ASl.Free;
end;
{$endif}

{$ifdef 163_bbs}
function Bbs_163_OCR(BMP : TBitmap): String;
var
  M_h,M_w,ChrCt : Integer;
  i,iChr : Byte;
  ChrBMPs,Chrs : Array[0..3] of TBitmap;
  L_BMP,R_BMP,OCR_BMP : TBitmap;
  RetStr : String;
begin
  P2V(BMP,128);
  RmEdge(BMP,1);
  RmNoise1p(BMP);
  ChrCt := GetChars(BMP,ChrBMPs,0,0,M_w,M_h);
  iChr := 0;
  L_BMP := TBitmap.Create;
  R_BMP := TBitmap.Create;
  for i:=0 to ChrCt-1 do
  begin
    //ChrBMPs[i].SaveToFile(ExtractFilePath(ParamStr(0))+IntToStr(i)+'.bmp');
    if ChrBMPs[i].Width>12 then
    begin
      Spilt(ChrBMPs[i],L_BMP,R_BMP);
      Chrs[iChr]:=L_BMP;
      Inc(iChr);
      Chrs[iChr]:=R_BMP;
      Inc(iChr);
    end else begin
      Chrs[iChr]:=ChrBMPs[i];
      Inc(iChr);
    end;
  end;
  //OCR_BMP := Conbine_Sample(Chrs);
  for i:=0 to iChr-1 do
  RetStr := RetStr + TRS_OCR(Chrs[i]);
  //RetStr := TRS_OCR(OCR_BMP);

  for i:=1 to Length(RetStr) do
  if (RetStr[i] in ['0'..'9']) or (RetStr[i] in ['A'..'Z']) then
  Result := Result + RetStr[i];

  for i:=0 to iChr-1 do
  Chrs[i].Free;
  //OCR_BMP.SaveToFile(ExtractFilePath(ParamStr(0))+'haha.bmp');
  //OCR_BMP.Free;
end;
{$endif}

{$ifdef 12530}
function Mobile_12530_OCR(BMP : TBitmap):string;
var
  i : Byte;
  RetStr : String;
begin;
  Result := '';
  P2V(BMP,0);
  RmEdge(BMP,1);
  RmLines(BMP,2,5);
  RmLines(BMP,7,10,FALSE);
  RmLines(BMP,3,7);
  RmNoise1pEx(BMP);
  To_Sample(BMP,0,5,False);
  RetStr := TRS_OCR(BMP);
  for i:=1 to Length(RetStr) do
  case RetStr[i] of
  '/': RetStr[i] := '7';
  '$': RetStr[i] := '5';
  end;
  for i:=1 to Length(RetStr) do
  if RetStr[i] in ['0'..'9'] then
  Result := Result + RetStr[i];
end;
{$endif}

{$ifdef sostar}
function Yahoo_sostar_OCR(BMP : TBitmap):string;
var
  OcrSl : TStringList;
begin;

  P2V(BMP,0);
  RVS(BMP);
  RmNoise1pEx(BMP);
  BlurEx(BMP,1,50);
  //To_Sample(BMP,2,2);
  OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,BMP,otGOCR,2,2,5,7,20);
  //ShowMessage(OcrSl.Text);
  Result := Yahoo_sostar_Mapping(OcrSl);
  OcrSl.Free;
end;


function Yahoo_sostar_Mapping(Sl : TStringList): string;
var
  i,j : Byte;
  AStr,C : String;
  ASl : TStringList;
begin
  Result := '';
  ASl := TStringList.Create;
  for i:=0 to Sl.Count-1 do
  begin
    AStr := Sl[i];
    ASl.Clear;
    {for j:=1 to Length(AStr) do
      case AStr[j] of
      'O': AStr[j] := 'Q';
      end;  }
    for j:=1 to Length(AStr) do
      if (AStr[j] in ['0'..'9'])or(AStr[j] in ['a'..'z'])or(AStr[j] in ['A'..'Z']) then
      AddSlPro(ASl,AStr[j]);
    if ASl.Count > 0 then
    begin
      SortPro(ASl,0,ASl.Count-1);
      InvertSl(ASl);
      //ShowMessage(ASl.Text);
      if IndexOfPro(ASl,'M')<>-1 then
      C := 'M' else
      if IndexOfPro(ASl,'m')<>-1 then
      C := 'm' else
      if IndexOfPro(ASl,'W')<>-1 then
      C := 'W' else
      if IndexOfPro(ASl,'r')<>-1 then
      C := 'r' else
      if IndexOfPro(ASl,'w')<>-1 then
      C := 'w' else begin
        C := GetHead(ASl[0]);
        if (C = 'f') and (IndexOfPro(ASl,'1')<>-1) then
        C := '1';
        if C = 'a' then
        C := 'Q';
      end;
      Result := Result + C ;
    end else
      Result := Result + 'N';
  end;
end;
{$endif}

{$ifdef sharebank}
function ShareBank_OCR(BMP : TBitmap):string;       // for license test
var
  i : Integer;
begin
  P2V(BMP,150);
  To_Sample(BMP,0,0);
  Result := TRS_OCR(BMP);
end;
{$endif}

{$ifdef csdn}
function Csdn_OCR(BMP : TBitmap):string;
var
  AGray : Array[0..255] of Integer;
  TmpBMP : TBitmap;
  i,GrayV : Byte;
  RetStr : String;
begin
  Result := '';
  GrayV := 130;
  TmpBMP := TBitmap.Create;
  Repeat
    TmpBMP.Assign(BMP);
    P2V(TmpBMP,GrayV);
    RmEdge(TmpBMP,1);
    RmNoise1p(TmpBMP);
    BlurEx(TmpBMP,1,128);
    RmNoise1p(TmpBMP);
    RmNoise4p(TmpBMP);
    Inc(GrayV,20)
  Until CountChars(TmpBMP,5,5,22)=5;
  BMP.Assign(TmpBMP);
  TmpBMP.Free;
  To_Sample(BMP,5,5,FALSE);
  RetStr := TRS_OCR(BMP);
  for i:=1 to Length(RetStr) do
  begin
    if RetStr[i] = '/' then
    RetStr[i] := 'J';
    if (RetStr[i] in ['0'..'9']) or (RetStr[i] in ['A'..'Z']) then
    Result := Result + RetStr[i];
  end;
end;
{$endif}

{$ifdef tiancity}
function TianCity_OCR(BMP : TBitmap):string;
begin
  P2V(BMP,128);
  To_Sample(BMP,0,0,False);
  Result := TRS_OCR(BMP);
end;
{$endif}

{$ifdef qpgame}
function QpGame_OCR(BMP : TBitmap):string;
var
  i : Byte;
begin
  P2V(BMP,90);
  RmNoise1p(BMP);
  RmNoise4pEx(BMP);
  BlurEx(BMP,1,120);
  RmNoise1p(BMP);
  Result := TRS_OCR(BMP);
  for i:=1 to Length(Result) do
  if Result[i]='O' then Result[i]:='0';
end;
{$endif}

{$IFDEF qpgame_new}
function QpGame_New_OCR(BMP : TBitmap):string;
var
  i : Byte;
  OcrSl : TStringList;
begin
  P2V(BMP,215);
  RmEdge(BMP,1);
  RmNoise1pEx(BMP);
  RmNoise4pEx(BMP);
  //RmNoise4pEx(BMP);
  BlurEx(BMP,1,130);
  RmNoise1pEx(BMP);
  //ReSample(BMP,100,30);
  To_Sample(BMP,3,3);
  OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,BMP,otTransym,2,2,5,7,20);
//  ShowMessage(OcrSl.Text);
  OcrSl.Free;
  Result := TRS_OCR(BMP);
end;
{$ENDIF}

{$ifdef alibaba}
function Alibaba_OCR(BMP : TBitmap): String;
var
  RetStr : String;
  i : Byte;
  //http://china.alibaba.com/member/showimage
begin
  Result := '';
  P2V(BMP,160);
  RVS(BMP);
  RmNoise1p(BMP);
  RmNoise1p(BMP);
  RetStr := TRS_OCR(BMP);
  for i:=1 to Length(RetStr) do
    if RetStr[i] in ['0'..'9'] then
    Result := Result + RetStr[i];
  if (Length(Result)<>4) or (CountSub('8',Result)+CountSub('6',Result)>2) then
  begin
    To_Sample(BMP,5,5);
    Result := TRS_OCR(BMP);
    for i:=1 to Length(Result) do
      case Result[i] of
      'B' : Result[i] := '8';
      'O' : Result[i] := '0';
      'S' : Result[i] := '5';
      'P' : Result[i] := '9';
      'A' : Result[i] := '4';
      end;
  end;
end;
{$endif}

{$ifdef qq}
function Esales_QQ_Mapping(Sl : TStringList): String;
var
  i,j,Ct : Byte;
  AStr,C1,C2 : String;
  ASl : TStringList;
  b : boolean;
begin
  Result := '';
  Ct := Sl.Count;
  if Ct = 0 then exit;
  ASl := TStringList.Create;
  for i:=0 to Ct-1 do
  begin
    b := true;
    AStr := Sl[i];
    ASl.Clear;


    for j:=1 to Length(AStr) do
      if (AStr[j] in ['A'..'Z']) or (AStr[j] in ['0'..'9']) or (AStr[j] in ['$','f','O','d','y','w']) then
      AddSlPro(ASl,AStr[j]);



    if ASl.Count > 0 then
    begin
      if (IndexOfPro(ASl,'H')<>-1) and b then
      begin
        b := False;
        C1 := 'H';
      end;
      if (IndexOfPro(ASl,'W')<>-1) and b then
      begin
        b := False;
        C1 := 'W';
      end;
      if (IndexOfPro(ASl,'w')<>-1) and b then
      begin
        b := False;
        C1 := 'W';
      end;
      if (IndexOfPro(ASl,'M')<>-1) and b then
      begin
        b := False;
        C1 := 'M';
      end;
      if (IndexOfPro(ASl,'y')<>-1) and b then
      begin
        b := False;
        C1 := 'Y';
      end;
      if b then
      begin
        SortPro(ASl,0,ASl.Count-1);
        InvertSl(ASl);
        C1 := GetHead(ASl[0]);
        C2 := '';
        if ASl.Count > 1 then
        C2 := GetHead(ASl[1]);
        Case C1[1] of
        '$' : C1 := 'S';
        'd' : C1 := '6';
        '1' : begin
                if C2 = '2' then
                C1 := '2';
              end;
        'f' : begin
                C1 := 'F';
                if C2 = 'E' then
                C1 := 'E';
              end;
        '0','O' :
              begin
                if C2 = 'U' then
                C1 := 'U'
                else
                C1 := 'D';
                if C2 = '6' then
                C1 := 'G';
              end;
        '6' : begin
                if C2 = '5' then
                C1 := '5';
              end;
        '2' : begin
                if C2 = '7' then
                C1 := 'Z';
                if C2 = 'E' then
                C1 := 'E';
                if C2 = 'Z' then
                C1 := 'Z';
              end;
        '7' : begin
                if C2 = '2' then
                C1 := 'Z';
                if C2 = 'T' then
                C1 := 'T';
              end;
        //addition convertion
        'V' : begin
                if C2 = 'Y' then
                C1 := 'Y';
              end;
        'C' : begin
                if C2 = 'G' then
                C1 := 'G';
              end;
        '9' : begin
                if C2 = 'P' then
                C1 := 'P';
                if C2 = 'N' then
                C1 := 'N';
              end;
        '5' : begin
                if (C2 = '$') OR (C2 = 'S') then
                C1 := 'S';
              end;
        '8' : begin
                if C2 = 'N' then
                C1 := 'N';
                if C2 = '3' then
                C1 := '3';
                if C2 = '5' then
                C1 := '5';
              end;
        '4' : begin
                if C2 = 'V' then
                C1 := 'V';
                if C2 = 'R' then
                C1 := 'R';
              end;
        'R' : begin
                if C2 = 'K' then
                C1 := 'K';
              end;
        end;
      end;
      Result := Result + C1;
    end else
      Result := Result + '?';
  end;
  ASl.Free;

end;


function Esales_QQ_OCR(BMP : TBitmap): String;
var
  TmpBMP : TBitmap;
  GrayV : Byte;
  OcrSl : TStringList;
begin
  Result := '';
  GrayV := 128;        // fetch value
  TmpBMP := TBitmap.Create;
  Repeat
    TmpBMP.Assign(BMP);
    P2V(TmpBMP,GrayV);
    //add for http://pay.qq.com/zft/paycenter_account.shtml
    RmNoise1p(TmpBMP);
    RmNoise1p(TmpBMP);
    RmNoise4p(TmpBMP);

    Inc(GrayV,20);     // fetch value
    if GrayV > 250 then Break;
    //ShowMessage(IntToStr(AveGrayV(TmpBMP)));
  Until (CountChars(TmpBMP,5,5,15)=4) and (AveGrayV(TmpBMP)<85);
  //BlurEx(TmpBMP,1,150);
  BMP.Assign(TmpBMP);
  TmpBMP.Free;
  OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,BMP,otTransym,0,0,5,7,15);
//  ShowMessage(OcrSl.Text);
  Result := Esales_QQ_Mapping(OcrSl);
  OcrSl.Free;

end;
{$endif}


{$ifdef baidu}
function Baidu_OCR(BMP : TBitmap):string;
var
  TmpBMP : TBitmap;
  GrayV : Byte;
  OcrSl : TStringList;
begin
  Result := '';
  GrayV := 200;        // fetch value
  TmpBMP := TBitmap.Create;
  //Repeat
    //if GrayV > 250 then Break;
    TmpBMP.Assign(BMP);
    P2V(TmpBMP,GrayV);
    Inc(GrayV,50);     // fetch value
    RmEdge(TmpBMP,1);
    RmNoise4pEx(TmpBMP);
    RmNoise1p(TmpBMP);
    //RmNoise4p(BMP);
    //RmNoise1pEx(BMP);
    BlurEx(TmpBMP,1,50);
    //ShowMessage(IntToStr(AveGrayV(TmpBMP)));
  //Until CountChars(TmpBMP,5,5,25)=4;
  BMP.Assign(TmpBMP);
  TmpBMP.Free;

  //MidV_Filter(BMP);
  OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,BMP,otTransym,2,2,5,7,20);
  //To_Sample(BMP,5,5);
  //ShowMessage(OcrSl.Text);
  Result := Baidu_Mapping(OcrSl);
  OcrSl.Free;
end;

function Baidu_Mapping(Sl : TStringList): string;
var
  i,j : Byte;
  AStr,C1,C2 : String;
  ASl : TStringList;
begin
  Result := '';
  ASl := TStringList.Create;
  for i:=0 to Sl.Count-1 do
  begin
    AStr := Sl[i];
    ASl.Clear;
    for j:=1 to Length(AStr) do
      case AStr[j] of
      '$': AStr[j] := '8';
      'S': AStr[j] := '5';
      'T': AStr[j] := '7';
      'Z': AStr[j] := '2';
      end;
    for j:=1 to Length(AStr) do
      if AStr[j] in ['0'..'9'] then
      AddSlPro(ASl,AStr[j]);
    if ASl.Count > 0 then
    begin
      SortPro(ASl,0,ASl.Count-1);
      InvertSl(ASl);
      C1 := GetHead(ASl[0]);
      C2 := '';
      if ASl.Count > 1 then
      C2 := GetHead(ASl[1]);
      {if ((C1 = '7') and (C2 = '2')) or
         ((C1 = '9') and (C2 = '8')) then
      C1 := C2; }
      Result := Result + C1 ;
    end else
      Result := Result + '?';
  end;
end;
{$endif}

{$ifdef dvbbs}
function Dvbbs_OCR(BMP : TBitmap):string;
var
  OcrSl : TStringList;
begin
  P2V(BMP,128);
  RmNoise1p(BMP);
  BlurEx(BMP,1,150);
  To_Sample(BMP,5,5,False);
  {OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,BMP,otTransym,2,2,5,7,20);
  //ShowMessage(OcrSl.Text);
  Result := Dvbbs_Mapping(OcrSl);
  OcrSl.Free;     }
  SpiltEx2File(BMP,4,'g:\','dvbbs');
end;

function Dvbbs_Mapping(Sl : TStringList): string;
var
  i,j : Byte;
  AStr,C1,C2 : String;
  ASl : TStringList;
begin
  Result := '';
  ASl := TStringList.Create;
  for i:=0 to Sl.Count-1 do
  begin
    AStr := Sl[i];
    ASl.Clear;
    for j:=1 to Length(AStr) do
      case AStr[j] of
      'B': AStr[j] := '8';
      'S': AStr[j] := '5';
      end;
    for j:=1 to Length(AStr) do
      if AStr[j] in ['0'..'9'] then
      AddSlPro(ASl,AStr[j]);
    if ASl.Count > 0 then
    begin
      SortPro(ASl,0,ASl.Count-1);
      InvertSl(ASl);
      C1 := GetHead(ASl[0]);
      C2 := '';
      if ASl.Count > 1 then
      C2 := GetHead(ASl[1]);
      if ((C1 = '5') and (C2 = '3')) or
         ((C1 = '9') and (C2 = '8')) then
      C1 := C2;
      Result := Result + C1 ;
    end else
      Result := Result + '?';
  end;
end;
{$endif}

{$IFDEF china1168}
function China1168_OCR(BMP : TBitmap): string;
var
  OcrSl : TStringList;
begin
  P2V(BMP,230);
  RmNoise1p(BMP);
  RmNoise4p(BMP);
  BlurEx(BMP,2,128);
  RmNoise1p(BMP);
  To_Sample(BMP,5,5);
  OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,BMP,otTransym,2,2,5,7,20);
//  ShowMessage(OcrSl.Text);
  //Result := Dvbbs_Mapping(OcrSl);
  OcrSl.Free;
  Result := TRS_OCR(BMP);
end;
{$ENDIF}

{$IFDEF ly_poll}
function LY_Poll_OCR(BMP : TBitmap): string;
const
  PAIR : array[0..15] of string[2]=('01','23','45','67','89','qw','er','ty','uo','pk','az','xc','vb','ds','gf','jh');
var
  i : Byte;
  RetStr : string;
  function SmartCorrect(s : string): string;
  var
    x,y,iPos : Byte;
    tmp,strtoreplay,replaystr : string;
  begin
    Result := s;
    for x:=Low(PAIR) to High(PAIR) do
    begin
      tmp := PAIR[x];
      iPos:=Pos(tmp,s);
      if iPos>0 then
      Delete(s,iPos,2);
    end;
    strtoreplay := s;
    if s<>'' then
    begin
      for x:=Low(PAIR) to High(PAIR) do
      begin
        tmp := PAIR[x];
        if Length(s)=1 then
        begin
          if Pos(s,PAIR[x])>0 then
          begin
            replaystr := PAIR[x];
            Break;
          end;
        end else if Length(s)=2 then
        begin
          if (tmp[1]=s[1])or(tmp[2]=s[2]) then
          begin
            replaystr := PAIR[x];
            Break;
          end;
        end;
      end;
      if replaystr<>'' then
      begin
        iPos := Pos(strtoreplay,Result);
        Delete(Result,iPos,Length(strtoreplay));
        Insert(replaystr,Result,iPos);
      end;
    end;
  end;
begin
  Result := '';
  P2V(BMP,100);
  BlurEx(BMP,1,90);
  BlurEx(BMP,3,100);
  RmNoise1p(BMP);
  RmNoise4p(BMP);

  RetStr := TRS_OCR(BMP);
  for i:=1 to Length(RetStr) do
  if RetStr[i] in ['a'..'z','0'..'9','G','S',']','n','W'] then
  Result := Result + RetStr[i];
  for i:=1 to Length(Result) do
  begin
    case Result[i] of
    'G': Result[i] := '6';
    'S': Result[i] := '8';
    ']','i': Result[i] := 'j';
    't': if i mod 2 = 0 then Result[i] := 'f';
    'n': Result[i] := 'h';
    'W': Result[i] := 'w';
    end;
  end;
  Result := SmartCorrect(Result);
end;
{$ENDIF}

{$IFDEF qieee}
function Qieee_OCR(BMP : TBitmap): string;
var
  i : Integer;
  RetStr : string;
begin
  Result := '';
  P2V(BMP,160);
  RmNoise1pEx(BMP);
  To_Sample(BMP,5,5);
  ReSample(BMP,80,20);
  RetStr := TRS_OCR(BMP);

  for i:=0 to Length(RetStr) do
  begin
    case RetStr[i] of
    'D','O':RetStr[i] := '0';
    'Z':RetStr[i] := '2';
    '$':RetStr[i] := '9';
    '+':RetStr[i] := '4';
    end;
  end;
  for i:=0 to Length(RetStr) do
  if RetStr[i] in ['0'..'9'] then
  Result := Result + RetStr[i];
end;
{$ENDIF}

{$IFDEF chinamobile}
function ChinaMobile_OCR(BMP : TBitmap): string;
var
  i : Integer;
  RetStr : string;
begin
  P2V(BMP,140);
  Result := TRS_OCR(BMP);
end;
{$ENDIF}

{$IFDEF gamigo}
function Gamigo_OCR(BMP : TBitmap): string;
begin
  P2V(BMP,128);
  RVS(BMP);
  RmNoise1p(BMP);
  Result := TRS_OCR(BMP);
end;
{$ENDIF}

function Test_OCR(BMP : TBitmap): string;
var
  OcrSl : TStringList;
begin
  P2V(BMP,200);
  RmEdge(BMP,1);
//  RmNoise1pEx(BMP);
//  RmNoise4pEx(BMP);
  BlurEx(BMP,1,128);
  To_Sample(BMP,5,5,False);
  RmNoise1p(BMP);
  OcrSl := TStringList.Create;
  ROTATE_OCR(OcrSl,BMP,otTransym,5,5,5,7,20);
  
  ShowMessage(OcrSl.Text);
  OcrSl.Free;
//  Result := TRS_OCR(BMP);
end;

function OCR_core(OCR_type,file_name : String; var CodeStr :String):boolean;
var
  BMP : TBitmap;
  FMT : String;
begin
  if not FileExists(file_name) then exit;
  BMP := ToBmp(file_name,FMT);

  while OCR_Proc_Lock do SleepEx(100,False);
  OCR_Proc_Lock := True;

  if OCR_type = 'common' then
  CodeStr := Common_OCR(BMP);

{$ifdef alipay}
  if OCR_type = 'alipay' then
  CodeStr := AliPay_OCR(BMP);
{$endif}

{$ifdef alipay}
  if OCR_type = 'mail139' then
  CodeStr := mail139_OCR(BMP);
{$endif}

{$ifdef 163_esales}
  if OCR_type = '163_esales' then
  CodeStr := Esales_163_OCR(BMP);
{$endif}

{$ifdef 126_mail}
  if OCR_type = '126_mail' then
  CodeStr := Mail_126_OCR(BMP);
{$endif}

{$ifdef keepc}
  if OCR_type = 'keepc' then
  CodeStr := Keepc_OCR(BMP);
{$endif}

{$ifdef qq}
  if OCR_type = 'qq' then
  CodeStr := Esales_QQ_OCR(BMP);
{$endif}

{$ifdef kingsoft}
  if OCR_type = 'kingsoft' then
  CodeStr := Esales_KingSoft_OCR(BMP);
{$endif}

{$ifdef 16288}
  if OCR_type = '16288' then
  CodeStr := Esales_16288_OCR(BMP);
{$endif}

{$ifdef yahoo_bulo}
  if OCR_type = 'yahoo_bulo' then
  CodeStr := Yahoo_bulo_OCR(BMP);
{$endif}

{$ifdef alibaba}
  if OCR_type = 'alibaba' then
  CodeStr := Alibaba_OCR(BMP);
{$endif}

{$ifdef monternet}
  if OCR_type = 'monternet' then
  CodeStr := Monternet_OCR(BMP);
{$endif}

{$ifdef taobao}
  if OCR_type = 'taobao' then
  CodeStr := TaoBao_OCR(BMP);
{$endif}

{$ifdef 163_mail}
  if OCR_type = '163_mail' then
  CodeStr := Mail_163_OCR(BMP);
{$endif}

{$ifdef the9}
  if OCR_type = 'the9' then
  CodeStr := Esales_the9_OCR(BMP);
{$endif}

{$ifdef 95599}
  if OCR_type = '95599' then
  CodeStr := Bank_95599_OCR(BMP);
{$endif}

{$ifdef icbc}
  if OCR_type = 'icbc' then
  CodeStr := Bank_icbc_OCR(BMP);
{$endif}

{$ifdef sina_bbs}
  if OCR_type = 'sina_bbs' then
  CodeStr := Sina_bbs_OCR(BMP);
{$endif}

{$ifdef 163_bbs}
  if OCR_type = '163_bbs' then
  CodeStr := Bbs_163_OCR(BMP);
{$endif}

{$ifdef 12530}
  if OCR_type = '12530' then
  CodeStr := Mobile_12530_OCR(BMP);
{$endif}

{$ifdef sostar}
  if OCR_type = 'sostar' then
  CodeStr := Yahoo_sostar_OCR(BMP);
{$endif}

{$ifdef sina_mail}
  if OCR_type = 'sina_mail' then
  CodeStr := Sina_Mail_OCR(BMP);
{$endif}

{$ifdef sharebank}
  if OCR_type = 'sharebank' then
  CodeStr := ShareBank_OCR(BMP);
{$endif}

{$ifdef csdn}
  if OCR_type = 'csdn' then
  CodeStr := Csdn_OCR(BMP);
{$endif}

{$ifdef tiancity}
  if OCR_type = 'tiancity' then
  CodeStr := TianCity_OCR(BMP);
{$endif}

{$ifdef qpgame}
  if OCR_type = 'qpgame' then
  CodeStr := QpGame_OCR(BMP);
{$endif}

{$IFDEF qpgame_new}
  if OCR_type = 'qpgame_new' then
  CodeStr := QpGame_New_OCR(BMP);
{$ENDIF}

{$ifdef baidu}
  if OCR_type = 'baidu' then
  CodeStr := Baidu_OCR(BMP);
{$endif}

{$ifdef dvbbs}
  if OCR_type = 'dvbbs' then
  CodeStr := Dvbbs_OCR(BMP);
{$endif}

{$IFDEF china1168}
  if OCR_type = 'china1168' then
  CodeStr := china1168_OCR(BMP);
{$ENDIF}

{$IFDEF ly_poll}
  if OCR_type = 'ly_poll' then
  CodeStr := LY_Poll_OCR(BMP);
{$ENDIF}

{$IFDEF qieee}
  if OCR_type = 'qieee' then
  CodeStr := Qieee_OCR(BMP);
{$ENDIF}

{$IFDEF chinamobile}
  if OCR_type = 'chinamobile' then
  CodeStr := ChinaMobile_OCR(BMP);
{$ENDIF}

{$ifdef gamigo}
  if OCR_type = 'gamigo' then
  CodeStr := Gamigo_OCR(BMP);
{$ENDIF}

  if OCR_type = 'test' then
  CodeStr := Test_OCR(BMP);

  OCR_Proc_Lock := False;
{$ifdef imgdebug}
  SaveImg(BMP); //保存取杂点后的图片
{$endif}

{$ifndef unregister}
  RestoreRegistry;
{$endif}

  BMP.Free;

{$ifdef demo}
  Inc(OCR_Count);
{$endif}
  Result := Trim(CodeStr)<>'';
end;


function OCR_B(OCR_type,file_name: PChar; var CodeStr : PChar): boolean; stdcall;
var
  Code,OcrType,FileName : String;
begin
  Result := False;
  SRetStr := '?';
  OcrType := LowerCase(StrPas(OCR_type));
  FileName := StrPas(file_name);
  if Init_Succ and (OCR_Count<100) then
    if OCR_core(OcrType,FileName,Code) then
    begin
      Result := True;
      SRetStr := Code;
    end;
  CodeStr := @SRetStr[1];
end;

function OCR_C(OCR_type,file_name: PChar): PChar; stdcall;
var
  Code,OcrType,FileName : String;
begin
  ARetStr := #0;
  StrPCopy(ARetStr,'?');
  OcrType := LowerCase(StrPas(OCR_type));
  FileName := StrPas(file_name);
  if Init_Succ and (OCR_Count<100) then
    if OCR_core(OcrType,FileName,Code) then
      StrPCopy(ARetStr,Code);
  Result := ARetStr;
end;


end.

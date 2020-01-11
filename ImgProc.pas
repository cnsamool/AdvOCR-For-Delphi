unit ImgProc;

interface

uses
  Windows,
  Classes,
  Graphics,
  GIFImage,
  JPEG,
  PNGimage,
  CnGraphics,
  SysUtils,
  Math,
  define,
  Dialogs;
  

  function ToBmp(const InFile : String; var Format : String): TBitMap;
  function ToBmpFile(const InFile : String; var Format : String):boolean;
  procedure P2V(BMP : TBitmap; GrayV : Byte);
  function GetPixelColor(SrcRGB : PByteArray; i : Integer): TColor;
  procedure SetPixelColor(SrcRGB : PByteArray; i : Integer; Color : TColor);
  function GetBmpPixel(BMP : TBitmap; w,h : Integer): TColor;
  procedure SetBmpPixel(BMP : TBitmap; w,h : Integer; Color : TColor);
  procedure SetBmpPixels(BMP : TBitmap; SrcColor,DesColor : TColor; Condition : TCompareType);
  procedure RmNoise1p(BMP : TBitmap);
  procedure RmNoise1pEx(BMP : TBitmap);
  procedure RmNoise4p(BMP : TBitmap);
  procedure RmNoise4pEx(BMP : TBitmap);
  procedure RmNoise6pH(BMP : TBitmap);
  procedure RmLineByLenH(BMP : TBitmap; Len : Byte; Smooth : boolean = TRUE);
  procedure RmLineByLenV(BMP : TBitmap; Len : Byte; Smooth : boolean = TRUE);
  procedure RmLines(BMP : TBitmap; BeginLen,EndLen : Byte; Smooth : boolean = TRUE);
  procedure RmEdge(BMP : TBitMap; Len : Integer);
  function LockChr(BMP : TBitmap; StartW : Integer; var h_low,h_high,w_start,w_end : Integer): boolean;
  function CropChr(BMP : TBitmap; h_low,h_high,w_start,w_end : Integer): TBitmap;
  procedure RVS(BMP : TBitmap);
  function AveGrayV(BMP : TBitmap): Byte;
  function ScanXY(BMP : TBitmap; Direction : Byte):Integer;
  function Tighten(BMP : TBitmap): TBitmap;
  function Loosen(BMP : TBitmap; Edge : Byte): TBitmap;
  procedure PF1(BMP : TBitmap);
  function GetTwoColorPalette: hPalette;
  procedure ReSample(BMP : TBitmap; NewWidth, NewHeight : Integer);
  procedure ReSampleEx(BMP : TBitmap; Zoom : Double);
  function GetChars(BMP : TBitmap; var ChrBMPs : Array of TBitmap ; MinChrWidth, MinChrHeight : Integer; var MaxChrWidth,MaxChrHeight : Integer): Integer;
  function CountChars(BMP : TBitmap; MinChrWidth, MinChrHeight, AdjChrWidth : Integer): Integer;
  procedure GetCharsPos(BMP : TBitmap; MinChrWidth, MinChrHeight: Integer; var Offsets : Array of Integer);
  function Build_Sample(BMP : TBitmap; MinChrWidth, MinChrHeight : Integer; Resize : boolean = TRUE): TBitmap;
  procedure To_Sample(BMP : TBitmap; MinChrWidth, MinChrHeight : Integer; Resize : boolean = TRUE);
  function Conbine_Sample(var BMPs : Array of TBitmap; Count : Byte; Resize : boolean = TRUE): TBitmap;
  function Build_RotateSample(SrcBmp : TBitmap; SampleCount,PickCount : Integer; SampleAngle : Double): TBitmap;
  procedure To_RotateSample(SrcBmp : TBitmap; SampleCount,PickCount : Integer; SampleAngle : Double);
  function Build_RotateSample_All(BMP : TBitmap; var RotateSamples : Array of TBitmap; MinChrWidth, MinChrHeight, SampleCount,PickCount : Integer; SampleAngle : Double) : Integer;
  function Thin(Bitmap: TBitmap): Boolean;
  procedure BlurEx(BMP : TBitmap; Heavy,GrayV : Byte);
  function Erose(Bitmap: TBitmap; Horic: Boolean): Boolean;
  function Dilate(Bitmap: TBitmap; Hori: Boolean): Boolean;
  procedure EdgeDetect(BMP : TBitmap);
  procedure MidV_Filter(BMP : TBitmap);
  procedure Rotate(BMP,RBMP : TBitmap; Angle : Double);
  procedure Smooth(BMP : TBitmap);
  procedure Spilt(BMP,L_BMP,R_BMP : TBitmap);
  procedure SpiltEx(BMP : TBitmap; Count : Byte; var SpBMP : Array of TBitmap; bTighten : Boolean = True);
  procedure SpiltEx2File(BMP : TBitmap; Count : Byte; Path, Prefix : string; bTighten : Boolean = True; bReSample : Boolean= True; NewWidth : Integer = 20; NewHeight : Integer = 20);
  procedure GrayStatus(BMP : TBitmap; var AGray : Array of Integer);


implementation

uses
  MathUtil;

function ToBmp(const InFile : String; var Format : String): TBitMap;
var
  JPG: TJPEGImage;
  BMP: TBITMAP;
  PNG: TPNGobject;
  GIF: TGIFImage;
  FileEx : string;
begin
  ForMat := UNKNOWN_FORMAT;
  BMP := TBitMap.Create;
  FileEx := UpperCase(ExtractFileExt(InFile));
  BMP := TBITMAP.Create;
  if FileEx = '.PNG' then
  begin
    PNG := TPNGobject.Create;
    try
      PNG.LoadFromFile(InFile);
      ForMat := 'PNG';
      BMP.Assign(PNG);
    except
      //not png image
    end;
    PNG.Free;
  end else if FileEx = '.BMP' then
    try
      BMP.LoadFromFile(InFile);
      ForMat := 'BMP';
    except
      //not bmp image
    end
  else if FileEx = '.GIF' then
  begin
    GIF := TGIFImage.Create;
    try
      GIF.LoadFromFile(InFile);
      ForMat := 'GIF';
      BMP.Assign(GIF);
    except
      //not gif image
    end;
    GIF.Free;
  end else if (FileEx = '.JPG') or (FileEx = '.JPEG') then
  begin
    JPG := TJPEGImage.Create;
    try
      JPG.LoadFromFile(InFile);
      ForMat := 'JPG';
      JPG.Grayscale := TRUE;
      BMP.Assign(JPG);
    except
      //not jpg image
    end;
    JPG.Free;
  end;
  //
  if ForMat = UNKNOWN_FORMAT then
    try
      BMP.LoadFromFile(InFile);
      ForMat := 'BMP';
    except
    end;
  if ForMat = UNKNOWN_FORMAT then
  begin
    PNG := TPNGobject.Create;
    try
      PNG.LoadFromFile(InFile);
      ForMat := 'PNG';
      BMP.Assign(PNG);
      PNG.Free;
    Except
      PNG.Free;
    end;
  end;
  if ForMat = UNKNOWN_FORMAT then
  begin
    GIF := TGIFImage.Create;
    try
      GIF.LoadFromFile(InFile);
      ForMat := 'GIF';
      BMP.Assign(GIF);
      GIF.Free;
    Except
      GIF.Free;
    end;
  end;    
  if ForMat = UNKNOWN_FORMAT then
  begin
    JPG := TJPEGImage.Create;
    try
      JPG.LoadFromFile(InFile);
      JPG.Grayscale := TRUE;
      BMP.Assign(JPG);
      ForMat := 'JPG';
      JPG.Free;
    Except
      JPG.Free;
    end;
  end;
  Bmp.PixelFormat := pf24Bit;
  Result := BMP;
  if ForMat = UNKNOWN_FORMAT then
  BMP.Free;
end;


function ToBmpFile(const InFile : String; var Format : String):boolean;
var
  OutFile : String;
  BMP : TBitMap;
begin
  BMP := ToBmp(InFile,Format);
  Result := ForMat <> UNKNOWN_FORMAT ;
  if Result then
  begin
    OutFile := InFile+'.BMP';
    BMP.SaveToFile(OutFile);
  end;
  BMP.Free;
end;

procedure P2V(BMP : TBitmap; GrayV : Byte);
var
  p: PByteArray;
  Gray, x, y: Integer;
begin
  Bmp.PixelFormat := pf24Bit;
  for y := 0 to Bmp.Height - 1 do
  begin
     p := Bmp.scanline[y];
     for x := 0 to Bmp.Width - 1 do
     begin
       Gray := Round(p[x * 3 + 2] * 0.299 + p[x * 3 + 1] * 0.587 + p[x * 3] * 0.114);
       if gray > GrayV then
         SetPixelColor(p,x,clWhite)
       else
         SetPixelColor(p,x,clBlack);
     end;
  end;
end;

function GetPixelColor(SrcRGB : PByteArray; i : Integer): TColor;
begin
  Result := HexToInt(IntToHex(SrcRGB[i*3],2)+
                     IntToHex(SrcRGB[i*3+1],2)+
                     IntToHex(SrcRGB[i*3+2],2));
end;


procedure SetPixelColor(SrcRGB : PByteArray; i : Integer; Color : TColor);
var
  clHex : String;
begin
  clHex := IntToHex(Color,6);
  SrcRGB[i*3] := HexToInt(Copy(clHex,1,2));
  SrcRGB[i*3+1] := HexToInt(Copy(clHex,3,2));
  SrcRGB[i*3+2] := HexToInt(Copy(clHex,5,2));
end;


procedure RmNoise1p(BMP : TBitmap);
var
  i,j,w,h,Count : Integer;
  p1,p2: PByteArray;
begin
  for j:=0 to BMP.Height - 1 do
  begin
    p1 := Bmp.scanline[j];
    for i:=0 to BMP.Width - 1 do
    begin
      Count := 0;
      if GetPixelColor(p1,i) = clBlack then
        for h:=-1 to 1 do
          for w:=-1 to 1 do
          if ((j+h)<0) or ((i+w)<0) or ((j+h)>=BMP.Height) or ((i+w)>=BMP.Width) then
            Inc(Count)
          else begin
            p2 := Bmp.scanline[j+h];
            if GetPixelColor(p2,i+w) = clWhite then
            Inc(Count);
          end;
      if Count > 6 then
      SetPixelColor(p1,i,clWhite);
    end;
  end;
end;


procedure RmNoise1pEx(BMP : TBitmap);
var
  i,j,w,h : Integer;
  p1,p2: PByteArray;
  Top,Bottom,Left,Right : boolean;
begin
  for j:=0 to BMP.Height - 1 do
  begin
    p1 := Bmp.scanline[j];
    for i:=0 to BMP.Width - 1 do
    begin
      Top := False;
      Bottom := False;
      Left := False;
      Right := False;
      if GetPixelColor(p1,i) = clBlack then
        if ((j-1)<0) then
        Top := True
        else begin
          p2 := Bmp.scanline[j-1];
          Top := GetPixelColor(p2,i) = clWhite;
        end;
        //
        if ((i-1)<0) then
        Left := True
        else begin
          p2 := Bmp.scanline[j];
          Left := GetPixelColor(p2,i-1) = clWhite;
        end;
        //
        if ((j+1)>=BMP.Height) then
        Bottom := True
        else begin
          p2 := Bmp.scanline[j+1];
          Bottom := GetPixelColor(p2,i) = clWhite;
        end;
        //
        if ((i+1)>=BMP.Width) then
        Right := True
        else begin
          p2 := Bmp.scanline[j];
          Right := GetPixelColor(p2,i+1) = clWhite;
        end;
      if Right and Left and Top and Bottom then
      SetPixelColor(p1,i,clWhite);
    end;
  end;
end;


procedure RmNoise4p(BMP : TBitmap);
var
  i,j,w,h,Count : Integer;
  p1,p2,p3: PByteArray;
begin
  for j:=0 to BMP.Height - 2 do
  begin
    p1 := Bmp.scanline[j];
    for i:=0 to BMP.Width - 2 do
    begin
      Count := 0;
      if (GetPixelColor(p1,i) or GetPixelColor(p1,i+1)) = clBlack then
      begin
        p2 := Bmp.scanline[j+1];
        if (GetPixelColor(p2,i) or GetPixelColor(p2,i+1)) = clBlack then
        for h:=-1 to 2 do
          for w:=-1 to 2 do
          if ((j+h)<0) or ((i+w)<0) or ((j+h)>=BMP.Height) or ((i+w)>=BMP.Width) then
            Inc(Count)
          else begin
            p3 := Bmp.scanline[j+h];
            if GetPixelColor(p3,i+w) = clWhite then
            Inc(Count);
          end;
      end;
      if Count > 10 then
      begin
        SetPixelColor(p1,i,clWhite);
        SetPixelColor(p1,i+1,clWhite);
        SetPixelColor(p2,i,clWhite);
        SetPixelColor(p2,i+1,clWhite);
      end;
    end;
  end;
end;


procedure RmNoise4pEx(BMP : TBitmap);  // for baidu
var
  i,j,w,h : Integer;
  p1,p2,p3: PByteArray;
  Top,Bottom,Left,Right,b : boolean;
begin
  for j:=0 to BMP.Height - 2 do
  begin
    p1 := Bmp.scanline[j];
    for i:=0 to BMP.Width - 2 do
    begin
      Top := False;
      Bottom := False;
      Left := False;
      Right := False;
      if ((GetPixelColor(p1,i)= clBlack) or (GetPixelColor(p1,i+1)= clBlack))  then
      begin
        p2 := Bmp.scanline[j+1];
        if ((GetPixelColor(p2,i)= clBlack) or (GetPixelColor(p2,i+1)= clBlack)) then
          if ((j-1)<0) then
          Top := True
          else begin
            p3 := Bmp.scanline[j-1];
            Top := (GetPixelColor(p3,i) = clWhite)and(GetPixelColor(p3,i+1) = clWhite);
          end;
          //
          if ((i-1)<0) then
          Left := True
          else begin
            p3 := Bmp.scanline[j];
            b := GetPixelColor(p3,i-1) = clWhite;
            p3 := Bmp.scanline[j+1];
            Left := b and (GetPixelColor(p3,i-1) = clWhite);
          end;
          //
          if ((j+2)>=BMP.Height) then
          Bottom := True
          else begin
            p3 := Bmp.scanline[j+2];
            Bottom := (GetPixelColor(p3,i) = clWhite)and(GetPixelColor(p3,i+1) = clWhite);
          end;
          //
          if ((i+2)>=BMP.Width) then
          Right := True
          else begin
            p3 := Bmp.scanline[j];
            b := GetPixelColor(p3,i+2) = clWhite;
            p3 := Bmp.scanline[j+1];
            Right := b and (GetPixelColor(p3,i+2) = clWhite);
          end;
      end;
      if Right and Left and Top and Bottom then
      begin
        SetPixelColor(p1,i,clWhite);
        SetPixelColor(p1,i+1,clWhite);
        SetPixelColor(p2,i,clWhite);
        SetPixelColor(p2,i+1,clWhite);
      end;
    end;
  end;
end;


procedure RmNoise6pH(BMP : TBitmap);    // for 163_mail
var
  i,j,w,h : Integer;
  p1,p2,p3: PByteArray;
  Top,Bottom,Left,Right,b1,b2 : boolean;
begin
  for j:=0 to BMP.Height - 2 do
  begin
    p1 := Bmp.scanline[j];
    for i:=0 to BMP.Width - 3 do
    begin
      Top := False;
      Bottom := False;
      Left := False;
      Right := False;
      if (GetPixelColor(p1,i) or GetPixelColor(p1,i+1) or GetPixelColor(p1,i+2)) = clBlack then
      begin
        p2 := Bmp.scanline[j+1];
        if (GetPixelColor(p2,i) or GetPixelColor(p2,i+1) or GetPixelColor(p2,i+2)) = clBlack then
          if ((j-1)<0) then
          Top := True
          else begin
            p3 := Bmp.scanline[j-1];
            Top :=(GetPixelColor(p3,i) = clWhite)and(GetPixelColor(p3,i+1) = clWhite)and(GetPixelColor(p3,i+2) = clWhite);
          end;
          //
          if ((i-1)<0) then
          Left := True
          else begin
            p3 := Bmp.scanline[j];
            b1 := GetPixelColor(p3,i-1) = clWhite;
            p3 := Bmp.scanline[j+1];
            b2 := GetPixelColor(p3,i-1) = clWhite;
            Left := b1 or b2;
          end;
          //
          if ((j+2)>=BMP.Height) then
          Bottom := True
          else begin
            p3 := Bmp.scanline[j+2];
            Bottom :=(GetPixelColor(p3,i) = clWhite)and(GetPixelColor(p3,i+1) = clWhite)and(GetPixelColor(p3,i+2) = clWhite);
          end;
          //
          if ((i+3)>=BMP.Width) then
          Right := True
          else begin
            p3 := Bmp.scanline[j];
            b1 := GetPixelColor(p3,i+3) = clWhite;
            p3 := Bmp.scanline[j+1];
            b2 := GetPixelColor(p3,i+3) = clWhite;
            Right := b1 or b2;;
          end;
      end;
      if Right and Left and Top and Bottom then
      begin
        SetPixelColor(p1,i,clWhite);
        SetPixelColor(p1,i+1,clWhite);
        SetPixelColor(p1,i+2,clWhite);
        SetPixelColor(p2,i,clWhite);
        SetPixelColor(p2,i+1,clWhite);
        SetPixelColor(p2,i+2,clWhite);
      end;
    end;
  end;
end;


procedure RmLineByLenH(BMP : TBitmap; Len : Byte; Smooth : boolean = TRUE);
var
  i,j,w,h : Integer;
  p1,p2: PByteArray;
  Top,Bottom,Left,Right,LeftAndRight : boolean;
  //iCount : Byte;
  function bLineH(P : PByteArray; Start : Integer; Jclr : TColor): boolean;
  var
    x : Integer;
  begin
    Result := True;
    for x:=Start to Start+Len-1 do
    begin
      Result := Result and (GetPixelColor(P,x)=Jclr);
      if not Result then break;
    end;
  end;
  //
  function bBlankH(P : PByteArray; Start : Integer; Jclr : TColor): boolean;
  var
    x,Count : Integer;
  begin
    Count := 0;
    for x:=Start to Start+Len-1 do
    begin
      if GetPixelColor(P,x)<>Jclr then
      Inc(Count);
    end;
    Result := Count<2;
  end;
  //
  procedure SetLineH(P : PByteArray; Start : Integer; Jclr : TColor);
  var
    x : Integer;
  begin
    for x:=Start to Start+Len-1 do
    SetPixelColor(P,x,Jclr);
  end;
  //
begin
  for j:=0 to BMP.Height - 1 do
  begin
    p1 := Bmp.scanline[j];
    for i:=0 to BMP.Width - Len do
    begin
      Top := False;
      Bottom := False;
      Left := False;
      Right := False;
      //iCount := 0;
      if bLineH(p1,i,clBlack) then
      begin
        if ((j-1)<0) then
        Top := True
        else begin
          p2 := Bmp.scanline[j-1];
          if Smooth then
          Top := bLineH(p2,i,clWhite) else
          Top := bBlankH(p2,i,clWhite);
        end;
        //
        if ((i-1)<0) then
        Left := True
        else begin
          p2 := Bmp.scanline[j];
          Left := GetPixelColor(p2,i-1) = clWhite;
          //
          //if Left then Inc(iCount);
        end;
        //
        if ((j+1)>=BMP.Height) then
        Bottom := True
        else begin
          p2 := Bmp.scanline[j+1];
          if Smooth then
          Bottom := bLineH(p2,i,clWhite) else
          Bottom := bBlankH(p2,i,clWhite)
        end;
        //
        if ((i+Len)>=BMP.Width) then
        Right := True
        else begin
          p2 := Bmp.scanline[j];
          Right := GetPixelColor(p2,i+Len) = clWhite;
          //
          //if Right then Inc(iCount);
        end;
        LeftAndRight := Left or Right;
      end;
      if Smooth then
      begin
        if Right and Left and Top and Bottom then
        //if iCount < 2 then
        SetLineH(p1,i,clWhite);
      end else begin
        if LeftAndRight and Top and Bottom then
        SetLineH(p1,i,clWhite);
      end;
    end;
  end;
end;


procedure RmLineByLenV(BMP : TBitmap; Len : Byte; Smooth : boolean = TRUE);
var
  i,j,w,h : Integer;
  p2: PByteArray;
  Top,Bottom,Left,Right,TopAndBottom : boolean;
  //iCount : Byte;
  function bLineV(StartV,H : Integer; Jclr : TColor): boolean;
  var
    P : PByteArray;
    x : Integer;
  begin
    Result := True;
    for x:=StartV to StartV+Len-1 do
    begin
      P := Bmp.scanline[x];
      Result := Result and (GetPixelColor(P,H)=Jclr);
      if not Result then break;
    end;
  end;
  //
  function bBlankV(StartV,H : Integer; Jclr : TColor): boolean;
  var
    P : PByteArray;
    x,Count : Integer;
  begin
    Count := 0;
    for x:=StartV to StartV+Len-1 do
    begin
      P := Bmp.scanline[x];
      if GetPixelColor(P,H)<>Jclr then
      Inc(Count);
    end;
    Result := Count<2;
  end;
  //
  procedure SetLineV(StartV,H : Integer; Jclr : TColor);
  var
    P : PByteArray;
    x : Integer;
  begin
    for x:=StartV to StartV+Len-1 do
    begin
      P := Bmp.scanline[x];
      SetPixelColor(P,H,Jclr);
    end;
  end;
begin
  for j:=0 to BMP.Height - Len do
  begin
    for i:=0 to BMP.Width - 1 do
    begin
      Top := False;
      Bottom := False;
      Left := False;
      Right := False;
      //iCount := 0;
      if bLineV(J,I,clBlack) then
      begin
        if ((j-1)<0) then
        Top := True
        else begin
          p2 := Bmp.scanline[j-1];
          Top := GetPixelColor(p2,i)=clWhite;
        end;
        //
        if ((i-1)<0) then
        Left := True
        else begin
          if Smooth then
          Left := bLineV(J,I-1,clWhite) else
          Left := bBlankV(J,I-1,clWhite);
        end;
        //
        if ((j+Len)>=BMP.Height) then
        Bottom := True
        else begin
          p2 := Bmp.scanline[j+Len];
          Bottom := GetPixelColor(p2,i)=clWhite;
        end;
        //
        if ((i+1)>=BMP.Width) then
        Right := True
        else begin
          if Smooth then
          Right := bLineV(J,I+1,clWhite) else
          Right := bBlankV(J,I+1,clWhite);
        end;
      end;
      TopAndBottom := Top OR Bottom;
      if Smooth then
      begin
        if Right and Left and Top and Bottom then
        SetLineV(J,I,clWhite);
      end else begin
        if Right and Left and TopAndBottom then
        SetLineV(J,I,clWhite);
      end;
    end;
  end;
end;


procedure RmLines(BMP : TBitmap; BeginLen,EndLen : Byte; Smooth : boolean = TRUE);
var
  i : Integer;
begin
  for i:=BeginLen to EndLen do
  begin
    RmLineByLenH(BMP,i,Smooth);
    RmLineByLenV(BMP,i,Smooth);
  end;
end;


procedure RmEdge(BMP : TBitmap; Len : Integer);
var
  i,j : Integer;
  p : PByteArray;
begin
  for j := 0 to BMP.Height - 1 do
  begin
    p := BMP.ScanLine[j];
    for i := 0 to BMP.Width - 1 do
      if (i<Len)or(j<Len)or(i>BMP.Width-1-Len)or(j>BMP.Height-1-Len) then
      SetPixelColor(p,i,clWhite);
  end;
end;

function LockChr(BMP : TBitmap; StartW : Integer; var h_low,h_high,w_start,w_end : Integer): boolean;
var
  h, w : Integer;
  p: PByteArray;
  bCharSt, bBlankLine : boolean;
  BlankCt : Byte;
begin
  Result := False;
  bCharSt := False;

  //get w_st w_ed
  for w:=StartW to BMP.Width - 1 do
  begin
    bBlankLine := True;
    for h:=0 to BMP.Height - 1 do
    begin
      p := Bmp.scanline[h];
      if GetPixelColor(p,w) = clBlack then
      begin
        bBlankLine := False;
        Result := True;
        if not bCharSt then
        begin
          bCharSt := True;
          w_start := w;
        end;
        break;
      end;
    end;
    if bBlankLine and bCharSt then
    begin
      w_end := w-1;
      bCharSt := False;
      break;
    end;
    if w+1 = BMP.Width then
    begin
      w_end := w;
      bCharSt := False;
    end;
  end;

  BlankCt := 0;
  //get h_lo h_hi
  if Result then
    for h:=0 to BMP.Height - 1 do
    begin
      p := Bmp.scanline[h];
      bBlankLine := True;
      for w:=w_start to w_end do
      begin
        if GetPixelColor(p,w) = clBlack then
        begin
          bBlankLine := False;
          if not bCharSt then
          begin
            bCharSt := True;
            h_low := h;
          end;
          break;
        end;
      end;
      if bBlankLine then
      Inc(BlankCt) else
      BlankCt := 0;
      if (BlankCt>5) and bCharSt then
      begin
        h_high := h-BlankCt;
        break;
      end;
      if h+1 = BMP.Height then
      begin
        if bBlankLine then
        h_high := h-BlankCt else
        h_high := h;
      end;
    end;
  //red rect
  {
  if Result then
  begin
    for h:=h_low to h_high do
    begin
      p := Bmp.scanline[h];
      if w_start>0 then
      SetPixelColor(p,w_start-1,clRed);
      if w_end+1<BMP.Width then
      SetPixelColor(p,w_end+1,clRed);
    end;
    if w_start>0 then
    st := w_start-1 else
    st := w_start;
    if w_end+1<BMP.Width then
    ed := w_end+1 else
    ed := w_end;
    if h_low>0 then
    begin
      p := Bmp.scanline[h_low-1];
      for w:=st to ed do
      SetPixelColor(p,w,clRed);
    end;
    if h_high+1<BMP.Height then
    begin
      p := Bmp.scanline[h_high+1];
      for w:=st to ed do
      SetPixelColor(p,w,clRed);
    end;
  end;
  }
end;

function CropChr(BMP : TBitmap; h_low,h_high,w_start,w_end : Integer): TBitmap;
var
  w,h : Integer;
  //d,s : TRect;
  p1,p2 : PByteArray;
begin
  {
  Result := TBitmap.Create;
  s := Rect(w_start,h_low,w_end,h_high );
  with Result do
  begin
    Width := w_end - w_start+1;
    Height := h_high - h_low+1;
    d := Rect(0,0,Width-1 ,Height-1 );
    Canvas.Lock;
    BMP.Canvas.Lock;
    Canvas.CopyRect(d,BMP.Canvas,s);
    BMP.Canvas.Unlock;
    Canvas.Unlock;
    PixelFormat := pf24bit;
  end;
  }

  Result := TBitmap.Create;
  with Result do
  begin
    PixelFormat := pf24bit;
    //Canvas.Lock;
    Width := w_end - w_start+1;
    Height := h_high - h_low+1;
    //Canvas.Brush.Color := clBlack;
    //Canvas.FloodFill(1, 1, clWhite, fsBorder);
    for h:=h_low to h_high do
    begin
      p1 := Bmp.scanline[h];
      p2 := ScanLine[h-h_low];
      for w:=w_start to w_end do
      begin
        //if BMP.Canvas.Pixels[w,h] = clblack then
        //Canvas.Pixels[w-w_start,h-h_low] := clblack;
        SetPixelColor(p2,w-w_start,GetPixelColor(p1,w));
      end;
    end;
    //Canvas.Unlock;
    //PixelFormat := pf24bit;
  end;

  //Result.SaveToFile(ExtractFilePath(ParamStr(0))+IntToStr(w_start)+'.bmp');
end;

procedure RVS(BMP : TBitmap);
var
  w,h : Integer;
  p : PByteArray;
begin
  for h:=0 to BMP.Height - 1 do
  begin
    p := Bmp.scanline[h];
    for w:=0 to BMP.Width - 1 do
    begin
      if GetPixelColor(p,w) = clBlack then
      SetPixelColor(p,w,clWhite) else
      if GetPixelColor(p,w) = clWhite then
      SetPixelColor(p,w,clBlack);
    end;
  end;
end;

function AveGrayV(BMP : TBitmap): Byte;
var
  w,h : Integer;
  p : PByteArray;
  AveGray,WhitePct : Integer;
begin
  WhitePct := 0;
  for h:=0 to BMP.Height - 1 do
  begin
    p := BMP.scanline[h];
    for w:=0 to BMP.Width - 1 do
    begin
      AveGray := Round(p[w * 3 + 2] * 0.299 + p[w * 3 + 1] * 0.587 + p[w * 3] * 0.114);
      if AveGray > 128 then Inc(WhitePct)
    end;
  end;
  Result := Round(100 * WhitePct / (BMP.Height * BMP.Width));
end;

function ScanXY(BMP : TBitmap; Direction : Byte):Integer;
var
  w,h : Integer;
  p1 : PByteArray;
begin
  Result := 0;
  if Direction = $00 then
  for h:=0 to BMP.Height-1 do
  begin
    p1 := BMP.ScanLine[h];
    for w:=0 to BMP.Width-1 do
    begin
      if GetPixelColor(p1,w)= clBlack then
      begin
        Result := h;
        exit;
      end;
    end;
  end;

  if Direction = $FF then
  for h:=BMP.Height-1 downto 0 do
  begin
    p1 := BMP.ScanLine[h];
    for w:=0 to BMP.Width-1 do
    begin
      if GetPixelColor(p1,w)= clBlack then
      begin
        Result := h;
        exit;
      end;
    end;
  end;

  if Direction = $F0 then
  for w:=0 to BMP.Width-1 do
  begin
    for h:=0 to BMP.Height-1 do
    begin
      p1 := BMP.ScanLine[h];
      if GetPixelColor(p1,w)= clBlack then
      begin
        Result := w;
        exit;
      end;
    end;
  end;

  if Direction = $0F then
  for w:=BMP.Width-1 downto 0 do
  begin
    for h:=0 to BMP.Height-1 do
    begin
      p1 := BMP.ScanLine[h];
      if GetPixelColor(p1,w)= clBlack then
      begin
        Result := w;
        exit;
      end;
    end;
  end;
end;

function Tighten(BMP : TBitmap): TBitmap;
var
  up,down,left,right : Integer;
begin
  up := ScanXY(BMP,$00);
  down := ScanXY(BMP,$FF);
  left := ScanXY(BMP,$F0);
  right := ScanXY(BMP,$0F);
  Result := CropChr(BMP,up,down,left,right);
  Result.PixelFormat := pf24bit;
end;

function Loosen(BMP : TBitmap; Edge : Byte): TBitmap;
begin
  Result := TBitmap.Create;
  Result.Width := BMP.Width + Edge;
  Result.Height := BMP.Height + Edge;
  Result.PixelFormat := pf24bit;
  Result.Canvas.Draw(Edge div 2,Edge div 2,BMP);
end;

procedure PF1(BMP : TBitmap);
begin
  BMP.Palette := GetTwoColorPalette;
  BMP.PixelFormat := pf1bit;
end;


FUNCTION GetTwoColorPalette:  hPalette;
VAR
  Palette:  TMaxLogPalette;
BEGIN
  Palette.palVersion := $300;
  Palette.palNumEntries := 2;

  WITH Palette.palPalEntry[0] DO
  BEGIN
    peRed   := $ff;
    peGreen := $ff;
    peBlue  := $ff;
    peFlags := 0;
  END;

  WITH Palette.palPalEntry[1] DO
  BEGIN
    peRed   := $00;
    peGreen := $00;
    peBlue  := $00;
    peFlags := 0;
  END;

  RESULT := CreatePalette(pLogPalette(@Palette)^);
END;


procedure ReSample(BMP : TBitmap; NewWidth, NewHeight : Integer);
var
  RBMP : TBitmap;
  //s,d : TRect;
begin
  RBMP := TBitmap.Create;
  RBMP.PixelFormat := pf24bit;
  //s := Rect(0,0,BMP.Width,BMP.Height);
  //d := Rect(0,0,NewWidth ,NewHeight );
  with RBMP do
  begin
    Width  := NewWidth ;
    Height := NewHeight;
    Canvas.Lock;
    Canvas.StretchDraw(Rect(0,0,NewWidth ,NewHeight ),BMP);
    //Canvas.CopyRect(d,BMP.Canvas,s);
    Canvas.Unlock;
  end;
  BMP.Assign(RBMP);
  RBMP.Free;
end;


procedure ReSampleEx(BMP : TBitmap; Zoom : Double);
var
  NewWidth,NewHeight : Integer;
begin
  NewWidth := Round(BMP.Width * Zoom);
  NewHeight := Round(BMP.Height * Zoom);
  ReSample(BMP,NewWidth,NewHeight);
end;


function GetChars(BMP : TBitmap; var ChrBMPs: Array of TBitmap ; MinChrWidth, MinChrHeight : Integer; var MaxChrWidth,MaxChrHeight : Integer): Integer;
var
  h_low,h_high,w_start,w_end : Integer ;
  StartW : Integer;
  bHaveChar : boolean;
begin
  Result := 0;
  StartW := 0;
  MaxChrHeight := 0;
  MaxChrWidth := 0;
  Repeat
    bHaveChar := LockChr(BMP,StartW,h_low,h_high,w_start,w_end);
    StartW := w_end + 1;
    if bHaveChar then
    begin
      //modified to >= 2006-4-16
      if (h_high-h_low >= MinChrHeight) and (w_end-w_start >= MinChrWidth) then
      begin
        ChrBMPs[Result] := CropChr( BMP,h_low,h_high,w_start,w_end );
        //for debug
{$IFDEF imgdebug}
        ChrBMPs[Result].SaveToFile(ExtractFilePath(ParamStr(0))+'Char_'+IntToStr(Result)+'.BMP');
{$ENDIF}
        if ChrBMPs[Result].Width > MaxChrWidth then
        MaxChrWidth := ChrBMPs[Result].Width;
        if ChrBMPs[Result].Height > MaxChrHeight then
        MaxChrHeight := ChrBMPs[Result].Height;
        Inc(Result);

      end;
    end;
  Until not bHaveChar;
end;


function CountChars(BMP : TBitmap; MinChrWidth, MinChrHeight, AdjChrWidth : Integer): Integer;
var
  h_low,h_high,w_start,w_end : Integer ;
  StartW : Integer;
  bHaveChar : boolean;
begin
  Result := 0;
  StartW := 0;
  Repeat
    bHaveChar := LockChr(BMP,StartW,h_low,h_high,w_start,w_end);
    StartW := w_end + 1;
    if bHaveChar then
    begin
      if (h_high-h_low > MinChrHeight) and (w_end-w_start > MinChrWidth) then
      begin
        if w_end-w_start > AdjChrWidth then
        Inc(Result,2) else
        Inc(Result);
      end;
    end;
  Until not bHaveChar;
end;


procedure GetCharsPos(BMP : TBitmap; MinChrWidth, MinChrHeight : Integer; var Offsets : Array of Integer);
var
  h_low,h_high,w_start,w_end : Integer ;
  StartW, iChr: Integer;
  bHaveChar : boolean;
begin
  StartW := 0;
  iChr := 0;
  Repeat
    bHaveChar := LockChr(BMP,StartW,h_low,h_high,w_start,w_end);
    StartW := w_end + 1;
    if bHaveChar then
    begin
      if (h_high-h_low > MinChrHeight) and (w_end-w_start > MinChrWidth) then
      begin
        Offsets[iChr]:=(w_end+w_start) div 2;
        Inc(iChr);
      end;
    end;
  Until not bHaveChar;
end;


function Build_Sample(BMP : TBitmap; MinChrWidth, MinChrHeight : Integer; Resize : boolean = TRUE): TBitmap;
var
  //h_low,h_high,w_start,w_end : Integer ;
  i : Integer;
  //h,w : Integer;
  //bHaveChar : boolean;
  ChrCount : Integer;
  ChrBMPs : Array[0..9] of TBitmap;
  MaxChrHeight,MaxChrWidth : Integer;
begin
  ChrCount := GetChars(BMP,ChrBMPs,MinChrWidth,MinChrHeight,MaxChrWidth,MaxChrHeight);
  {
  StartW := 0;
  ChrCount := 0;
  MaxChrHeight := 0;
  MaxChrWidth := 0;
  Repeat
    bHaveChar := LockChr(BMP,StartW,h_low,h_high,w_start,w_end);
    StartW := w_end + 1;
    if bHaveChar then
    begin
      if (h_high-h_low > MinChrHeight) and (w_end-w_start > MinChrWidth) then
      begin
        ChrBMPs[ChrCount] := TBitmap.Create;
        ChrBMPs[ChrCount].Assign(CropChr( BMP,h_low,h_high,w_start,w_end ));
        //ChrBMPs[ChrCount].SaveToFile(ExtractFilePath(ParamStr(0))+'Char'+IntToStr(ChrCount+1)+'.bmp');
        if ChrBMPs[ChrCount].Width > MaxChrWidth then
        MaxChrWidth := ChrBMPs[ChrCount].Width;
        if ChrBMPs[ChrCount].Height > MaxChrHeight then
        MaxChrHeight := ChrBMPs[ChrCount].Height;
        Inc(ChrCount);
      end;
    end;
  Until not bHaveChar;
  }
  Result := TBitmap.Create;
  Result.Width := (MaxChrWidth+10)*ChrCount;
  Result.Height := MaxChrHeight+10;
  Result.PixelFormat := pf24bit;
  for i:=0 to ChrCount-1 do
  begin
    if Resize then
    ReSample(ChrBMPs[i],MaxChrWidth,MaxChrHeight);
    //BlurEx(ChrBMPs[i],1,128);
    //EdgeDetect(ChrBMPs[i]);
    //Dilate(ChrBMPs[i],false);
    //Erose(ChrBMPs[i],true);
    //Thin(ChrBMPs[i]);
    Result.Canvas.Draw(i*(MaxChrWidth+10)+5,5,ChrBMPs[i]);
    {
    for h:=0 to ChrBMPs[i].Height-1 do
    begin
      for w:=0 to ChrBMPs[i].Width-1 do
      begin
        if ChrBMPs[i].Canvas.Pixels[w,h] = clblack then
        Result.Canvas.Pixels[w+i*(MaxChrWidth+10)+5,h+5] := clblack;
      end;
    end;
    }
    ChrBMPs[i].Free;
  end;
end;

procedure To_Sample(BMP : TBitmap; MinChrWidth, MinChrHeight : Integer; Resize : boolean = TRUE);
var
  TmpBMP : TBitmap;
begin
  TmpBMP := Build_Sample(BMP,MinChrWidth,MinChrHeight,Resize);
  BMP.Assign(TmpBMP);
  TmpBMP.Free;
end;

function Conbine_Sample(var BMPs : Array of TBitmap; Count : Byte; Resize : boolean = TRUE): TBitmap;
var
  MaxChrWidth,MaxChrHeight,i : Integer;
begin
  MaxChrWidth := 0;
  MaxChrHeight := 0;
  for i:=0 to Count-1 do
  begin
    if BMPs[i].Width > MaxChrWidth then
    MaxChrWidth := BMPs[i].Width;
    if BMPs[i].Height > MaxChrHeight then
    MaxChrHeight := BMPs[i].Height;
  end;
  Result := TBitmap.Create;
  Result.Width := (MaxChrWidth+10)*Count;
  Result.Height := MaxChrHeight+10;
  Result.PixelFormat := pf24bit;
  for i:=0 to Count-1 do
  begin
    if Resize then
    ReSample(BMPs[i],MaxChrWidth,MaxChrHeight);
    Result.Canvas.Draw(i*(MaxChrWidth+10)+5,5,BMPs[i]);
  end;
end;


procedure Rotate(BMP,RBMP : TBitmap; Angle : Double);
var
  p : TPoint;
  w,h : Integer;
  CNBMPsrc,CNBMPdes : TCnBitMap;
begin
  CNBMPsrc := TCnBitmap.Create;
  CNBMPdes := TCnBitmap.Create;
  CNBMPsrc.Assign(BMP);
  w := cnBMPsrc.Width;
  h := cnBMPsrc.Height;
  cnBMPdes.Width := round(sqrt((w*w)+(h*h)));
  cnBMPdes.Height := cnBMPdes.Width;
  cnBMPdes.Fill(clWhite);
  p.X := cnBMPdes.Width div 2;
  p.Y := cnBMPdes.Height div 2;
  //modified 2006-4-2
  cnBMPdes.SmoothFilter := False;
  cnBMPdes.Rotate(p,cnBMPsrc,Angle);
  cnBMPsrc.Free;
  cnBMPdes.Assign(RBMP);
  //
  P2V(RBMP,128);
  //
  cnBMPdes.Free;
end;


function Build_RotateSample_All(BMP : TBitmap; var RotateSamples : Array of TBitmap; MinChrWidth, MinChrHeight, SampleCount,PickCount : Integer; SampleAngle : Double) : Integer;
var
  Max_w, Max_h, i : Integer;
  ChrBMPs : Array[0..9] of TBitmap;
begin
  Result := GetChars(BMP,ChrBMPs,MinChrWidth,MinChrHeight,Max_w,Max_h);
  for i:=0 to Result-1 do
  begin
    RotateSamples[i] := Build_RotateSample(ChrBMPs[i],SampleCount,PickCount,SampleAngle);
    //
    //Smooth(RotateSamples[i]);
    //
    ChrBMPs[i].free;
  end;
end;


procedure To_RotateSample(SrcBmp : TBitmap; SampleCount,PickCount : Integer; SampleAngle : Double);
var
  TmpBMP : TBitmap;
begin
  TmpBMP := Build_RotateSample(SrcBmp,SampleCount,PickCount,SampleAngle);
  SrcBmp.Assign(TmpBMP);
  TmpBMP.Free;
end;


function Build_RotateSample(SrcBmp : TBitmap; SampleCount,PickCount : Integer; SampleAngle : Double): TBitmap;
var
  RotateAngle,RealAngle : Double;
  i,RBMP_h,RBMP_w : Integer;
  RBMP,TBMP : TBitmap;
  WidthList : TStringList;
  SampleBmps : Array Of TBitmap;
begin
  RBMP_h := 0;
  RBMP_w := 0;
  RotateAngle := SampleAngle / SampleCount;
  SetLength(SampleBmps,SampleCount*2+1);
  WidthList := TStringList.Create;
  RBMP := TBitmap.Create;
  for i:=-SampleCount to SampleCount do
  begin
    RealAngle := i*RotateAngle;
    Rotate(SrcBmp,RBMP,RealAngle);
    RBMP_h := RBMP.Height;
    RBMP_w := RBMP.Width;
    //Resample(RBMP,20,20);
    SampleBmps[SampleCount+i] := TBitmap.Create;
    SampleBmps[SampleCount+i].Assign(RBMP);
    TBMP := Tighten(RBMP);
    WidthList.Add(IntToStr(SampleCount+i)+Sp+IntToStr(TBMP.Width));
    TBMP.Free;
    //SaveImage('Char'+IntToStr(CharIndex)+'Img\'+'onechar'+IntToStr(CharIndex)+'_sample'+IntToStr(i+SampleCount),TempBmp);
  end;
  RBMP.Free;

  SortPro(WidthList,0,WidthList.Count-1);

  Result := TBitmap.Create;
  with Result do
  begin
    PixelFormat := pf24bit;
    Width := (RBMP_w+10)* PickCount;//((SampleCount*2+1)-6 );
    Height := RBMP_h+10;
    Canvas.Lock;
    for i:=0 to PickCount-1 do//(SampleCount*2+1) - 1 do
    //Canvas.Draw(5+i*(RBMP_w+10),5,SampleBmps[i]);
    Canvas.Draw(5+i*(RBMP_w+10),5,SampleBmps[StrToInt(GetHead(WidthList[i]))]);
    Canvas.Unlock;
  end;
  WidthList.Free;

  for i:=low(SampleBmps) to high(SampleBmps) do
  SampleBmps[i].Free;

end;


function Thin(Bitmap: TBitmap): Boolean;
var
   bmp: TBitmap;
   X, Y: integer;
   O, T, C, B: pRGBArray;
   nb: array[1..3, 1..3] of integer;
   c1, c2, c3, c4: boolean;
   ncount: integer;
begin
   bmp := TBitmap.Create;
   // Create bmp
   bmp.Assign(bitmap);
   //  获取bitmap 赋给bmp
   for Y := 1 to bmp.Height - 2 do
   begin
      O := bmp.ScanLine[Y];
      T := bitmap.ScanLine[Y - 1];
      C := bitmap.ScanLine[Y];
      B := bitmap.ScanLine[Y + 1];
      for X := 1 to bmp.Width - 2 do
      begin
         c1 := false;
         c2 := false;
         c3 := false;
         c4 := false;
         // 设立四个条件的初始值
         nb[1, 1] := T[X - 1].rgbtRed div 255;
         nb[1, 2] := T[X].rgbtRed div 255;
         nb[1, 3] := T[X + 1].rgbtRed div 255;
         nb[2, 1] := C[X - 1].rgbtRed div 255;
         nb[2, 2] := C[X].rgbtRed div 255;
         nb[2, 3] := C[X + 1].rgbtRed div 255;
         nb[3, 1] := B[X - 1].rgbtRed div 255;
         nb[3, 2] := B[X].rgbtRed div 255;
         nb[3, 3] := B[X + 1].rgbtRed div 255;
         //将[x,y]周围的八个象素点和它自己0-1化
         nCount := nb[1, 1] + nb[1, 2] + nb[1, 3]
            + nb[2, 1] + nb[2, 3]
            + nb[3, 1] + nb[3, 2] + nb[3, 3];
         // 获得ncount的值
         if (ncount >= 2) and (ncount <= 6) then
            c1 := True;
         //condition1
         ncount := 0;
         if (nb[1, 1] = 0) and (nb[1, 2] = 1) then
            inc(ncount);
         if (nb[1, 2] = 0) and (nb[1, 3] = 1) then
            inc(ncount);
         if (nb[1, 3] = 0) and (nb[2, 3] = 1) then
            inc(ncount);
         if (nb[2, 3] = 0) and (nb[3, 3] = 1) then
            inc(ncount);
         if (nb[3, 3] = 0) and (nb[3, 2] = 1) then
            inc(ncount);
         if (nb[3, 2] = 0) and (nb[3, 1] = 1) then
            inc(ncount);
         if (nb[3, 1] = 0) and (nb[2, 1] = 1) then
            inc(ncount);
         if (nb[2, 1] = 0) and (nb[1, 1] = 1) then
            inc(ncount);
         if ncount = 1 then
            c2 := true;
         //condition2
         if (nb[1, 2] * nb[3, 2] * nb[2, 3] = 0) then
            c3 := true;
         // condition3
         if (nb[2, 1] * nb[2, 3] * nb[3, 2] = 0) then
            c4 := true;
         //condition4
         if (c1 and c2 and c3 and c4) then
         begin
            O[X].rgbtRed := 255;
            O[X].rgbtGreen := 255;
            O[X].rgbtBlue := 255;
            //设置O[X]为白色
         end;
      end;
   end;
   bitmap.Assign(bmp);
   bmp.Free;
   //释放bmp
   Result := True;
   // 返回值为boolean,True表示细化成功
end;


procedure BlurEx(BMP : TBitmap; Heavy,GrayV : Byte);
var
  BL_BMP : TCnBitmap;
  i : Byte;
  TP_BMP : TBitmap;
begin
  BL_BMP := TCnBitmap.Create;
  TP_BMP := TBitmap.Create;
  TP_BMP.Assign(BMP);
  for i:=0 to Heavy-1 do
  begin
    BL_BMP.Assign(TP_BMP);
    BL_BMP.Blur;
    BL_BMP.Assign(TP_BMP);
    P2V(TP_BMP,GrayV);
  end;
  BMP.Assign(TP_BMP);
  TP_BMP.Free;
  BL_BMP.Free;
end;


function Erose(Bitmap: TBitmap; Horic: Boolean): Boolean;
var
   X, Y: integer;
   newbmp: TBitmap;
   P, Q, R, O: pByteArray;
   { IWidth, IHeight: integer;
   BA: array of array of Boolean;
   procedure GetBAValue;
   var
      X, Y: integer;
      P: pByteArray;
   begin
      SetLength(BA, IWidth, IHeight);
      begin
         for Y := 0 to IHeight - 1 do
            begin
               P := bitmap.ScanLine[Y];
               for X := 0 to IWidth - 1 do
                  begin
                     BA[X][Y] := ((P[3 * X + 2]) < 128);
                  end;
            end;
      end;
   end; }
begin
   newbmp := TBitmap.Create;
   //动态创建位图
   newbmp.Assign(bitmap);
   // Horic标志是水平方向还是竖直方向腐蚀
   if (Horic) then
   begin
      for Y := 1 to newbmp.Height - 2 do
      begin
         O := bitmap.ScanLine[Y];
         P := newbmp.ScanLine[Y - 1];
         Q := newbmp.ScanLine[Y];
         R := newbmp.ScanLine[Y + 1];
         for X := 1 to newbmp.Width - 2 do
         begin
            if ((O[3 * X] = 0) and (O[3 * X + 1] = 0) and (O[3 * X + 2]
               = 0)) then
            begin
               // 判断黑点左右邻居是否有白色点,有则腐蚀,置该点为白色
               // 白色点则保持不变
               if (((Q[3 * (X - 1)] = 255) and (Q[3 * (X - 1) + 1] =
                  255) and (Q[3 * (X - 1) + 2] = 255)) or ((Q[3 * (X
                     +
                     1)] = 255) and (Q[3 * (X + 1) + 1] = 255) and
                  (Q[3 * (X + 1) + 2] = 255)) or ((P[3 * X] = 0) and
                  (P[3 * X + 1] = 255) and (P[3 * X + 2] = 255))
                  or ((R[3 * X] = 255) and (R[3 * X + 1] = 255) and
                  (R[3
                  * X + 2] = 255))) then
               begin
                  O[3 * X] := 255;
                  O[3 * X + 1] := 255;
                  O[3 * X + 2] := 255;
                  //// 将满足条件的黑色点置为白色
               end;
            end;
         end;
      end;
   end
   else
   begin
      for Y := 1 to newbmp.Height - 2 do
      begin
         O := bitmap.ScanLine[Y];
         // P := newbmp.ScanLine[Y - 1];
         Q := newbmp.ScanLine[Y];
         // R := newbmp.ScanLine[Y + 1];
         for X := 1 to newbmp.Width - 2 do
         begin
            //  判断一个黑点上下邻居是否有白点,有则腐蚀,置黑点为白色
            //  白色点就保持不变
            if ((O[3 * X] = 0) and (O[3 * X + 1] = 0) and (O[3 * X + 2]
               = 0)) then
            begin
               if (((Q[3 * (X - 1)] = 255) and (Q[3 * (X - 1) + 1] =
                  255) and (Q[3 * (X - 1) + 2] = 255)) or ((Q[3 * (X
                     +
                     1)] = 255) and (Q[3 * (X + 1) + 1] = 255) and
                  (Q[3 * (X + 1) + 2] = 255))) then
               begin
                  O[3 * X] := 255;
                  O[3 * X + 1] := 255;
                  O[3 * X + 2] := 255;
                  // 将满足条件的黑色点置为白色
               end;
            end;
         end;
      end;
   end;
   result := True;
end;


function Dilate(Bitmap: TBitmap; Hori: Boolean): Boolean;
var
   X, Y: integer;
   O, P, Q, R: pByteArray;
   newbmp: TBitmap;
begin
   newbmp := TBitmap.Create;
   newbmp.Assign(bitmap);
   Hori := True;
   if (Hori) then
   begin
      for Y := 1 to newbmp.Height - 2 do
      begin
         O := bitmap.ScanLine[Y];
         P := newbmp.ScanLine[Y - 1];
         Q := newbmp.ScanLine[Y];
         R := newbmp.ScanLine[Y + 1];
         for X := 1 to newbmp.Width - 2 do
         begin
            if ((O[3 * X] = 255) and (O[3 * X + 1] = 255) and (O[3 * X
               + 2] = 255)) then
            begin
               if (((Q[3 * (X - 1)] = 0) and (Q[3 * (X - 1) + 1] = 0)
                  and (Q[3 * (X - 1) + 2] = 0)) or ((Q[3 * (X + 1)]
                  = 0)
                  and (Q[3 * (X + 1) + 1] = 0) and
                  (Q[3 * (X + 1) + 2] = 0)) or ((P[3 * X] = 0) and
                  (P[3 * X + 1] = 0) and (P[3 * X + 2] = 0))
                  or ((R[3 * X] = 0) and (R[3 * X + 1] = 0) and
                  (R[3 * X + 2] = 0))) then
               begin
                  O[3 * X] := 0;
                  O[3 * X + 1] := 0;
                  O[3 * X + 2] := 0;
               end;

            end;
         end;
      end;
   end
   else
      for Y := 1 to newbmp.Height - 2 do
      begin
         O := bitmap.ScanLine[Y];
         Q := newbmp.ScanLine[Y];
         for X := 1 to newbmp.Width - 2 do
         begin
            if ((O[3 * X] = 255) and (O[3 * X + 1] = 255) and (O[3 * X
               + 2] = 255)) then
            begin
               if (((Q[3 * (X - 1)] = 0) and (Q[3 * (X - 1) + 1] = 0)
                  and (Q[3 * (X - 1) + 2] = 0)) or ((Q[3 * (X + 1)]
                  = 0)
                  and (Q[3 * (X + 1) + 1] = 0) and
                  (Q[3 * (X + 1) + 2] = 0))) then
                  O[3 * X] := 0;
               O[3 * X + 1] := 0;
               O[3 * X + 2] := 0;
            end;
         end;

      end;
   result := True;
end;

procedure EdgeDetect(BMP : TBitmap);
var
   b0, b1: Tbitmap;
   i, j: Integer;
   p1, p2, p3, p4: pbyteArray;
begin
   b0 := Tbitmap.Create;
   b1 := Tbitmap.Create;
   b0.Assign(BMP);
   b1.Assign(BMP);
   b0.PixelFormat := pf24bit;
   b1.PixelFormat := pf24bit;
   for i := 1 to b0.Height - 2 do
   begin
      p1 := b0.ScanLine[i - 1];
      p2 := b0.ScanLine[i];
      p3 := b0.ScanLine[i + 1];
      p4 := b1.ScanLine[i];
      for j := 1 to b0.Width - 2 do
      begin
         if (p2[3 * j + 2] = 0) and (p2[3 * j + 1] = 0) and (p2[3 * j] = 0) then
         begin

            if ((p2[3 * (j - 1) + 2] = 0) and (p2[3 * (j - 1) + 1] = 0) and
               (p2[3 * (j - 1)] = 0)) and
            ((p2[3 * (j + 1) + 2] = 0) and (p2[3 * (j + 1) + 1] = 0) and
               (p2[3 * (j + 1)] = 0)) and
            ((p1[3 * (j + 1) + 2] = 0) and (p1[3 * (j + 1) + 1] = 0) and
               (p1[3 * (j + 1)] = 0)) and
            ((p1[3 * (j) + 2] = 0) and (p1[3 * (j) + 1] = 0) and (p1[3 * (j)]
               = 0)) and
            ((p1[3 * (j - 1) + 2] = 0) and (p1[3 * (j - 1) + 1] = 0) and
               (p1[3 * (j - 1)] = 0)) and
            ((p3[3 * (j - 1) + 2] = 0) and (p3[3 * (j - 1) + 1] = 0) and
               (p3[3 * (j - 1)] = 0)) and
            ((p3[3 * (j) + 2] = 0) and (p3[3 * (j) + 1] = 0) and (p3[3 * (j)]
               = 0)) and
            ((p3[3 * (j + 1) + 2] = 0) and (p3[3 * (j + 1) + 1] = 0) and
               (p3[3 * (j + 1)] = 0)) then
            begin
               p4[3 * j + 2] := 255;
               p4[3 * j + 1] := 255;
               p4[3 * j] := 255;
            end;
         end;

      end;
      BMP.Assign(b1);
   end;
   b1.Free;
   b0.Free;
end;

procedure MidV_Filter(BMP : TBitmap);
var
  bmp1, bmp2: Tbitmap;
  p1, p2, p3, p4: pbytearray;
  i, j: integer;
  RvalueArray, GvalueArray, BvalueArray: array[0..8] of integer;
begin
  //设置双缓冲
  //self.DoubleBuffered := true;
  //创建两个位图实例
  bmp1 := Tbitmap.Create;
  bmp2 := Tbitmap.Create;
  //加在位图
  bmp1.Assign(BMP);
  //设置位图的象素格式
  bmp1.PixelFormat := pf24bit;
  //位图的大小
  bmp1.Width := BMP.Width;
  bmp1.Height := BMP.Height;
  //加载备份的位图
  bmp2.Assign(BMP);
  bmp2.PixelFormat := pf24bit;
  for j := 1 to bmp1.Height - 2 do
  begin
    //三条扫描线
    p1 := bmp1.ScanLine[j];
    p2 := bmp2.ScanLine[j - 1];
    p3 := bmp2.ScanLine[j];
    p4 := bmp2.ScanLine[j + 1];
    for i := 1 to bmp1.Width - 2 do
    begin
      //对存储9个R分量的数组进行赋值
      RvalueArray[0] := p2[3 * (i - 1) + 2];
      RvalueArray[1] := p2[3 * i + 2];
      RvalueArray[2] := p2[3 * (i + 1) + 2];
      RvalueArray[3] := p3[3 * (i - 1) + 2];
      RvalueArray[4] := p3[3 * i + 2];
      RvalueArray[5] := p3[3 * (i + 1) + 2];
      RvalueArray[6] := p4[3 * (i - 1) + 2];
      RvalueArray[7] := p4[3 * i + 2];
      RvalueArray[8] := p4[3 * (i + 1) + 2];
      //调用排序过程
      SelectionSort(RvalueArray);
      //获取R分量的中间值
      p1[3 * i + 2] := RvalueArray[4];
      //对存储9个G分量的数组进行赋值
      GvalueArray[0] := p2[3 * (i - 1) + 1];
      GvalueArray[1] := p2[3 * i + 1];
      GvalueArray[2] := p2[3 * (i + 1) + 1];
      GvalueArray[3] := p3[3 * (i - 1) + 1];
      GvalueArray[4] := p3[3 * i + 1];
      GvalueArray[5] := p3[3 * (i + 1) + 1];
      GvalueArray[6] := p4[3 * (i - 1) + 1];
      GvalueArray[7] := p4[3 * i + 1];
      GvalueArray[8] := p4[3 * (i + 1) + 1];
      //调用选择排序
      SelectionSort(RvalueArray);
      //获取G分量的中间值
      p1[3 * i + 1] := RvalueArray[4];
      //对存储9个B分量的数组进行赋值
      BvalueArray[0] := p2[3 * (i - 1)];
      BvalueArray[1] := p2[3 * i];
      BvalueArray[2] := p2[3 * (i + 1)];
      BvalueArray[3] := p3[3 * (i - 1)];
      BvalueArray[4] := p3[3 * i];
      BvalueArray[5] := p3[3 * (i + 1)];
      BvalueArray[6] := p4[3 * (i - 1)];
      BvalueArray[7] := p4[3 * i];
      BvalueArray[8] := p4[3 * (i + 1)];
      //调用选择排序过程
      SelectionSort(RvalueArray);
      //获取G分量的中间值
      p1[3 * i] := RvalueArray[4];
    end;
  end;
  BMP.Assign(Bmp1);
  Bmp1.Free;
  bmp2.Free;
end;

procedure Smooth(BMP : TBitmap);
var
   bmp1, bmp2: Tbitmap;
   p1, p2, p3, p4: pbytearray;
   i, j, z: integer;
   y: array[0..8] of integer;
begin
   y[0] := 1;
   y[1] := 2;
   y[2] := 1;
   y[3] := 2;
   y[4] := 4;
   y[5] := 2;
   y[6] := 1;
   y[7] := 2;
   y[8] := 1;
   z := 16;
   bmp1 := Tbitmap.Create;
   bmp2 := Tbitmap.Create;
   bmp1.Assign(BMP);
   bmp1.PixelFormat := pf24bit;
   bmp1.Width := BMP.Width;
   bmp1.Height := BMP.Height;
   bmp2.Assign(bmp1);
   bmp2.PixelFormat := pf24bit;
   for j := 1 to bmp1.Height - 2 do
      begin
         p1 := bmp1.ScanLine[j];
         p2 := bmp2.ScanLine[j - 1];
         p3 := bmp2.ScanLine[j];
         p4 := bmp2.ScanLine[j + 1];
         for i := 1 to bmp1.Width - 2 do
            begin
               p1[3 * i + 2] := min(255, max(0, ((y[0] * p2[3 * (i - 1) + 2]
                  +
                  y[1] * p2[3 * i + 2] + y[2] * p2[3 * (i + 1) + 2] + y[3]
                  * p3[3
                  * (i - 1)
                     + 2] + y[4] * p3[3 * i + 2] + y[5] * p3[3 * (i + 1) +
                     2] +
                     y[6]
                  * p4[3
                  * (i - 1) + 2] + y[7] * p4[3 * i + 2] + y[8] * p4[3 * (i
                     +
                     1) + 2]))
                     div
                  z));
               p1[3 * i + 1] := min(255, max(0, ((y[0] * p2[3 * (i - 1) + 1]
                  +
                  y[1] * p2[3 * i + 1] + y[2] * p2[3 * (i + 1) + 1] + y[3]
                  * p3[3
                  * (i - 1)
                     + 1] + y[4] * p3[3 * i + 1] + y[5] * p3[3 * (i + 1) +
                     1] +
                     y[6]
                  * p4[3
                  * (i - 1) + 1] + y[7] * p4[3 * i + 1] + y[8] * p4[3 * (i
                     +
                     1) + 1]))
                     div
                  z));
               p1[3 * i] := min(255, max(0, ((y[0] * p2[3 * (i - 1)] + y[1]
                  *
                  p2[3 * i] + y[2] * p2[3 * (i + 1)] + y[3] * p3[3 * (i -
                     1)] +
                  y[4] * p3[3
                  * i] + y[5] * p3[3 * (i + 1)] + y[6] * p4[3 * (i - 1)] +
                     y[7]
                  * p4[3 * i]
                  + y[8] * p4[3 * (i + 1)])) div z));
            end;
      end;
   BMP.Assign(Bmp1);
   Bmp1.Free;
   bmp2.Free;
end;

procedure Spilt(BMP,L_BMP,R_BMP : TBitmap);
var
  TmpBMP1,TmpBMP2 : TBitmap;
begin
  TmpBMP1 := CropChr(BMP,0,BMP.Height-1,0,BMP.Width div 2-1);
  TmpBMP2 := Tighten(TmpBMP1);
  TmpBMP1.Free;
  L_BMP.Assign(TmpBMP2);
  TmpBMP2.Free;
  //
  TmpBMP1 := CropChr(BMP,0,BMP.Height-1,BMP.Width div 2,BMP.Width-1);
  TmpBMP2 := Tighten(TmpBMP1);
  TmpBMP1.Free;
  R_BMP.Assign(TmpBMP2);
  TmpBMP2.Free;
end;


procedure SpiltEx(BMP : TBitmap; Count : Byte; var SpBMP : Array of TBitmap; bTighten : Boolean = True);
var
  TmpBMP1,TmpBMP2 : TBitmap;
  i : Byte;
  W_Start,W_End : Integer;
begin
  for i:=0 to Count-1 do
  begin
    W_Start := i * Round(BMP.Width / Count);
    if i = Count-1 then
    W_End := BMP.Width-1 else
    W_End := (i+1) * Round(BMP.Width / Count);
    TmpBMP1 := CropChr(BMP,0,BMP.Height-1,W_Start,W_End);
    if bTighten then
      TmpBMP2 := Tighten(TmpBMP1)
    else begin
      TmpBMP2 := TBitmap.Create;
      TmpBMP2.Assign(TmpBMP1);
    end;
    TmpBMP1.Free;
    SpBMP[i] := TBitmap.Create;
    SpBMP[i].Assign(TmpBMP2);
    TmpBMP2.Free;
  end;
end;

procedure SpiltEx2File(BMP : TBitmap; Count : Byte; Path, Prefix : string; bTighten : Boolean = True; bReSample : Boolean= True; NewWidth : Integer = 20; NewHeight : Integer = 20);
var
  SpBMPs : array of TBitmap;
  i : Byte;
begin
  SetLength(SpBMPs,Count);
  SpiltEx(BMP,Count,SpBMPs,bTighten);
  for i:= Low(SpBMPs) to High(SpBMPs) do
  begin
    if bReSample then
    ReSample(SpBMPs[i],NewWidth,NewHeight);
    SpBMPs[i].SaveToFile(Format('%s%s_SP%d.BMP',[Path,Prefix,i]));
  end;
end;

procedure GrayStatus(BMP : TBitmap; var AGray : Array of Integer);
var
  p: PByteArray;
  Gray, x, y: Integer;
begin
  for x:=low(AGray) to High(AGray) do
  AGray[x]:=0;
  Bmp.PixelFormat := pf24Bit;
  for y := 0 to Bmp.Height - 1 do
  begin
     p := Bmp.scanline[y];
     for x := 0 to Bmp.Width - 1 do
     begin
       Gray := Round(p[x * 3 + 2] * 0.299 + p[x * 3 + 1] * 0.587 + p[x * 3] * 0.114);
       Inc(AGray[Gray]);
     end;
  end;
end;

function GetBmpPixel(BMP : TBitmap; w,h : Integer): TColor;
var
  p : PByteArray;
begin
  p := BMP.ScanLine[h];
  Result := GetPixelColor(p,w);
end;

procedure SetBmpPixel(BMP : TBitmap; w,h : Integer; Color : TColor);
var
  p : PByteArray;
begin
  p := BMP.ScanLine[h];
  SetPixelColor(p,w,Color);
end;

procedure SetBmpPixels(BMP : TBitmap; SrcColor,DesColor : TColor; Condition : TCompareType);
var
  w,h : integer;
  p : pbytearray;
  b : boolean;
begin
  for h:=0 to BMP.Height-1 do
  begin
    p := BMP.ScanLine[h];
    for w:=0 to BMP.Width-1 do
    begin
      case Condition of
      ctEqual       : b := GetPixelColor(p,w) =  SrcColor;
      ctUnequal     : b := GetPixelColor(p,w) <> SrcColor;
      ctHigherThan  : b := GetPixelColor(p,w) >  SrcColor;
      ctLowerThan   : b := GetPixelColor(p,w) <  SrcColor;
      end;
      if b then SetPixelColor(p,w,DesColor);
    end;
  end;
end;


end.

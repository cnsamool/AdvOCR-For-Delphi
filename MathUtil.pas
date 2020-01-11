unit MathUtil;

interface

uses
  Forms, Classes, SysUtils, ShlObj;


  Function HexToInt(Hex :String):Int64;
  procedure AddSlPro(Sl : TStringList; str : String);
  function IndexOfPro(Sl : TStringList; Str : String): Integer;
  procedure UpDateSlItem(Sl : TStringList; idx : Integer);
  function GetTail(Str: String): Integer;
  function GetHead(Str: String): String;
  Procedure SortPro(SL :TStringList; iLo,iHi: Integer);
  procedure InvertSl(SL : TStringList);
  procedure SelectionSort(var a: array of integer);
  function CountSub(Sub : String; Str : String): Byte;
  function GetSpecialFolderDir(const folderid: integer): string;
  procedure RmEnter(var Str : String);
  procedure RmC(var Str : String; C : Char);

implementation

uses
  define;

Function HexToInt(Hex :String):Int64;
Var
    Sum : Int64;
    I,L : Integer;
Begin
  L := Length(Hex);
  Sum := 0;
  For I := 1 to L Do
   Begin
   Sum := Sum * 16;
   If ( Ord(Hex[I]) >= Ord('0')) and (Ord(Hex[I]) <= Ord('9')) then
      Sum := Sum + Ord(Hex[I]) - Ord('0')
   else If ( Ord(Hex[I]) >= Ord('A') ) and (Ord(Hex[I]) <= Ord('F')) then
      Sum := Sum + Ord(Hex[I]) - Ord('A') + 10
   else If ( Ord(Hex[I]) >= Ord('a') ) and ( Ord(Hex[I]) <= Ord('f')) then
      Sum := Sum + Ord(Hex[I]) - Ord('a') + 10
   else
      Begin
      Sum := -1;
      break;
      End;
   End;
  Result := Sum;
End;

procedure AddSlPro(Sl : TStringList; str : String);
var
  idx : Integer;
begin
  idx := IndexOfPro(Sl,str);
  if idx=-1 then
    Sl.Add(str+Sp+'1')
  else
    UpDateSlItem(Sl,idx);
end;

function IndexOfPro(Sl : TStringList; Str : String): Integer;
var
  TpSl : TStringList;
  i : Integer;
begin
  TpSl := TStringList.Create;
  for i:=0 to Sl.Count-1 do
  TpSl.Add(GetHead(Sl[i]));
  Result := TpSl.IndexOf(Str);
  TpSl.Free;
end;

procedure UpDateSlItem(Sl : TStringList; idx : Integer);
var
  Temp : String;
  tp : Integer;
begin
  tp := GetTail(Sl[idx]);
  Temp := GetHead(Sl[idx])+Sp+IntToStr(tp+1);
  Sl[idx] := Temp;
end;

function GetTail(Str: String): Integer;
var
  iPos : Integer;
  Temp : String;
begin
  Temp := Str;
  iPos := Pos(Sp,Str);
  if iPos>0 then
  Delete(Temp,1,iPos+Length(Sp)-1);
  result := StrToInt(Temp);
end;


function GetHead(Str: String) : String;
var
  iPos : Integer;
begin
  iPos := Pos(Sp,Str);
  if iPos>0 then
  result := copy(str,1,iPos-1);
end;

Procedure SortPro(SL :TStringList; iLo,iHi: Integer);
var
  Lo, Hi, Mid : Integer;
  T : String;
begin
  Lo := iLo;
  Hi := iHi;
  Mid := GetTail(SL[(Lo + Hi) div 2]);
  repeat
    while GetTail(SL[Lo]) < Mid do Inc(Lo);
    while GetTail(SL[Hi]) > Mid do Dec(Hi);
    if Lo <= Hi then
    begin
      T := SL[Lo];
      SL[Lo] := SL[Hi];
      SL[Hi] := T;
      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  if Hi > iLo then SortPro(SL, iLo, Hi);
  if Lo < iHi then SortPro(SL, Lo, iHi);
end;

procedure InvertSl(SL : TStringList);
var
  i,Ct : Integer;
  tp : String;
begin
  Ct := Sl.Count;
  for i:=0 to Ct-1 do
  begin
    tp := SL[0];
    SL.Delete(0);
    SL.Insert(Ct-1-i,tp);
  end;
end;

procedure SelectionSort(var a: array of integer);
var
  i, j, t: integer;
begin
  for i := low(a) to high(a) - 1 do
    for j := high(a) downto i + 1 do
      if a[i] > a[j] then
      begin
        //交换值(a[i], a[j], i, j);
        t := a[i];
        a[i] := a[j];
        a[j] := t;
      end;
end;


function CountSub(Sub : String; Str : String): Byte;
var
  iPos : Byte;
begin
  Result := 0;
  repeat
    iPos := Pos(Sub,Str);
    if iPos > 0 then
    begin
      Inc(Result);
      Delete(Str,1,iPos+Length(Sub)-1);
    end;
  Until iPos=0;
end;


procedure RmEnter(var Str : String);
var
  i : integer;
  DelOne : boolean;
begin
  Repeat
    DelOne := false;
    for i:=1 to Length(Str)-1 do
    if (Ord(Str[i]) = $0d) and (Ord(Str[i+1]) = $0a) then
    begin
      Delete(Str,i,2);
      DelOne := true;
      break;
    end;
  Until not DelOne;
end;

procedure RmC(var Str : String; C : Char);
var
  i : Integer;
  DelOne : boolean;
begin
  Repeat
    DelOne := false;
    for i:=1 to Length(Str)-1 do
    if Str[i]= C then
    begin
      Delete(Str,i,1);
      DelOne := true;
      break;
    end;
  Until not DelOne;
end;


function GetSpecialFolderDir(const folderid: integer): string;
var
  pidl: pItemIDList;
  buffer: array[0..255] of char;
begin
  {
  AddListItem('桌面', GetSpecialFolderDir(0));
  AddListItem('所有用户桌面', GetSpecialFolderDir(25));
  AddListItem('开始菜单程序', GetSpecialFolderDir(2));
  AddListItem('所有用户开始菜单程序', GetSpecialFolderDir(23));
  AddListItem('文档', GetSpecialFolderDir(5));
  AddListItem('收藏夹', GetSpecialFolderDir(6));
  AddListItem('所以用户收藏夹', GetSpecialFolderDir(31));
  AddListItem('启动文件夹', GetSpecialFolderDir(7));
  AddListItem('所有用户启动文件夹', GetSpecialFolderDir(24));
  AddListItem('Recent文件夹', GetSpecialFolderDir(8));
  AddListItem('发送到', GetSpecialFolderDir(9));
  AddListItem('登陆用户开始菜单', GetSpecialFolderDir(11));
  AddListItem('所有用户开始菜单', GetSpecialFolderDir(22));
  AddListItem('网上邻居', GetSpecialFolderDir(19));
  AddListItem('字体文件夹', GetSpecialFolderDir(20));
  AddListItem('Template文件夹', GetSpecialFolderDir(21));
  AddListItem('所有用户Template文件夹', GetSpecialFolderDir(45));
  AddListItem('ApplicaionData 文件夹', GetSpecialFolderDir(26));
  AddListItem('打印文件夹', GetSpecialFolderDir(27));
  AddListItem('当前用户本地应用程序设置文件夹', GetSpecialFolderDir(28));
  AddListItem('Internet临时文件夹', GetSpecialFolderDir(32));
  AddListItem('Internet缓存文件夹', GetSpecialFolderDir(33));
  AddListItem('当前用户历史文件夹', GetSpecialFolderDir(34));
  AddListItem('所有用户应用程序设置文件夹', GetSpecialFolderDir(35));
  AddListItem('Windows系统目录', GetSpecialFolderDir(36));
  AddListItem('程序文件夹', GetSpecialFolderDir(38));
  AddListItem('System32系统目录', GetSpecialFolderDir(37));
  AddListItem('当前用户图片收藏夹', GetSpecialFolderDir(39));
  AddListItem('当前用户文件夹', GetSpecialFolderDir(40));
  AddListItem('公共文件夹', GetSpecialFolderDir(43));
  AddListItem('管理工具', GetSpecialFolderDir(47));
  AddListItem('登陆用户管理工具', GetSpecialFolderDir(48));
  AddListItem('所有用户图片收藏夹', GetSpecialFolderDir(54));
  AddListItem('所有用户视频收藏夹', GetSpecialFolderDir(55));
  AddListItem('主题资源文件夹', GetSpecialFolderDir(56));
  AddListItem('CD Burning', GetSpecialFolderDir(59));
  }
  //取指定的文件夹项目表
  SHGetSpecialFolderLocation(Application.Handle, folderid, pidl);
  SHGetPathFromIDList(pidl, buffer); //转换成文件系统的路径
  Result := strpas(buffer);
end;



end.

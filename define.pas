unit define;

interface

uses
   Windows;

type
   TRGBArray = array[0..32767] of TRGBTriple;
   PRGBArray = ^TRGBArray;

   TOcrEngineType = (otTransym, otGOCR);

   TCompareType = (ctEqual, ctUnequal, ctHigherThan, ctLowerThan);

const
  UNKNOWN_FORMAT       =        'Unknow Format';
  SP                   =        ':';
  TOCR_REGISTRY        =        'Software\Transym\TOCR\1.1\Paths';
  SAMPLE_BMP           =        'sample.bmp';

  VERT_REGISTRY        =        'Software\Classes\Interface\{AB03917E-A77C-11d5-9FF5-00500438A35C}';
  HORZ_REGISTRY        =        'Software\Classes\Interface\{CC90B833-CD48-4729-B476-45EFBA9CC132}';
  IVAL_REGISTRY        =        'Software\Classes\Interface\{E257E9A4-C6F3-11d5-A013-00500438A35C}';
  SEED_REGISTRY        =        'Software\Microsoft\Cryptography\RNG';

  VERT_REG_VAL         =        #$37#$50#$79#$35#$47#$26#$C9#$81#$D7#$5D#$7D#$44#$1A#$AF#$48#$A6;
  HORZ_REG_VAL         =        #$37#$50#$79#$35#$47#$26#$C9#$81#$D7#$5D#$7D#$44#$1A#$AF#$48#$A6#$31#$53#$50#$C7#$F1#$23#$68#$EE#$D7#$5D#$7D#$44#$1A#$AF#$48#$A6;
  IVAL_REG_VAL         =        #$37#$50#$79#$35#$47#$26#$C9#$81#$D7#$5D#$7D#$44#$1A#$AF#$48#$A6#$31#$53#$50#$C7#$F1#$23#$68#$EE#$D7#$5D#$7D#$44#$1A#$AF#$48#$A6;
  SEED_REG_VAL         =        #$36#$87#$02#$1F#$C4#$32#$A6#$F6#$3A#$80#$95#$31#$41#$79#$88#$7D#$E5#$28#$B0#$03#$0A#$C2#$8B#$04#$B7#$E7#$BB#$7D#$2E#$6E#$03#$68#$8C#$72#$2F#$B9#$7A#$0D#$B6#$E2#$BB#$52#$BF#$A8#$EE#$38#$D9#$F6#$D5#$BD#$FA#$9D#$A5#$FC#$CB#$26#$70#$C5#$FE#$3D#$2A#$AA#$BC#$86#$C0#$3A#$1F#$68#$18#$FD#$D6#$1C#$19#$DB#$29#$A9#$C4#$06#$DC#$79 ;


var
  Init_Succ : boolean;
  OCR_Count : Integer;
  OCR_Proc_Lock  : boolean;
  ARetStr : Array[0..255] of Char;
  SRetStr : string;
  AppPath : string;

implementation

end.

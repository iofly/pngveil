unit PVUtils;

interface

uses PNGImage,
  Winapi.Windows, System.SysUtils, Vcl.Graphics, System.Classes, System.IOUtils,  Math, ZLib,
  IdHashSHA, ShlObj, FileCtrl, DCPcrypt2, DCPsha512, DCPblockciphers, DCPblowfish, DCPrc6,
  vcl.forms, Vcl.ComCtrls;

type
  TBoolArray = array [0..7] of boolean;
  TByteArr = array [0..3] of byte;
const
  cBit: Array[0..7] of Byte = ($01, $02, $04, $08, $10, $20, $40, $80);
  //cBit: Array[0..7] of Byte = ($80, $40, $20, $10, $08, $04, $02, $01);


procedure ByteArrayToStream(arr: TArray<System.Byte>; var stream: TMemoryStream);
procedure BurnMemoryStream(var ms: TMemoryStream);
procedure CompressStream(var ms: TMemoryStream);
procedure DecompressStream(var ms: TMemoryStream);
procedure ResetBoolArray(var ba: TBoolArray);
function WriteStringToPNG(s: string; pixelsFromEnd: Integer; var _bmp: TPngImage): string;
function ReadStringFromPNG(pixelsFromEnd: Integer; var _bmp: TPngImage): string;
function StringToBytes(const Value : UnicodeString): TBytes;
function BytesToString(const Value: TBytes): UnicodeString;
function DesktopFolder: string;
function EncryptStreamDCP(instream: TMemoryStream; var outstream: TMemoryStream; password: string): boolean;
function DecryptStreamDCP(instream: TMemoryStream; var outstream: TMemoryStream; password: string): boolean;
function DecryptStringDCP(s: string; password: string): string;
function EncryptStringDCP(s: string; password: string): string;
function HashString(text: AnsiString): string;
function String2Hex(const Buffer: Ansistring): string;
function GetHideSpace(_bmp: TPngImage): Integer;
function StreamToByteArray(Stream: TMemoryStream): TArray<System.Byte>;
function EnsureByteOdd(b: byte): byte;
function EnsureByteEven(b: byte): byte;
function ToBoolArray(b: byte): TBoolArray;
procedure ColRGB(col: TColor; var Red: byte; var Green: byte; var Blue: byte);
procedure GetPixelCoords(pixelNumber: Integer; imageWidth: Integer; imageHeight: Integer;
                                bmp: TPngImage; var x: Integer; var y: Integer);
procedure GetPixelCoordsReal(pixelNumber: Integer; imageWidth: Integer; imageHeight: Integer;
                                bmp: TPngImage; var x: Integer; var y: Integer);
function IntToBytes(i: Integer): TByteArr;
function EncodeBool(arr: TBoolArray): byte;
function GetBit(B:Byte; BitNr:Integer):Boolean;
function FileSize(const aFilename: String): Integer;
function BytesToInt(b: TByteArr): Integer;
procedure HideDataInRGB(var _bmp: TPngImage; PayloadFileName: string; OutputImage: string; var sb: TStatusBar; Password: string = '');
function ExtractPayload(var _bmp: TPngImage; ToDirName: string; var sb: TStatusBar; Password: string = ''): boolean;

implementation

function GetHideSpace(_bmp: TPngImage): Integer;
var
  totalStoragePixels: Integer;
begin
    totalStoragePixels:= (_bmp.Width * _bmp.Height) - 5000;
    result:=((totalStoragePixels div 8) *3);
end;

function StreamToByteArray(Stream: TMemoryStream): TArray<System.Byte>;
var
  arr: TArray<System.Byte>;
begin

  if Assigned(Stream) then
  begin
     Stream.Position:=0;
     SetLength(arr, Stream.Size);
     Stream.Read(arr[0], Stream.Size);
  end
  else
     SetLength(arr, 0);

  result:=arr;
end;

procedure ByteArrayToStream(arr: TArray<System.Byte>; var stream: TMemoryStream);
begin
  if Assigned(Stream) then
  begin
     Stream.Position:=0;
     stream.Clear;
     Stream.Write(arr[0], Length(arr));
  end;
end;

procedure BurnMemoryStream(var ms: TMemoryStream);
var
  i: Int64;
  arr: TArray<System.Byte>;
begin

  if(Assigned(ms)) then begin
     ms.Position:=0;
    SetLength(arr, 1);
    arr[0]:=0;

     for i := 0 to ms.Size-1 do
        ms.Write(arr, 1);
  end;
end;

function WriteStringToPNG(s: string; pixelsFromEnd: Integer; var _bmp: TPngImage): string;
var
  totalPixels: Integer;
  bits: TBoolArray;
	cz:	TColor;
	newr, newg, newb: byte;
	x, y: Integer;
  _r, _g, _b: byte;
  strBytes: TBytes;
  i: Integer;
  baseRead: Integer;
begin
      s:=s+'|';
			totalPixels := _bmp.Width * _bmp.Height;
      strBytes:=StringToBytes(s);

      for i := 0 to Length(strBytes)-1 do begin

            bits := ToBoolArray(strBytes[i]);
            baseRead:=totalPixels - 1 - pixelsFromEnd + (i*3);

            GetPixelCoordsReal((baseRead + 0), _bmp.Width, _bmp.Height, _bmp, x, y);
            cz := _bmp.Pixels[x, y];
            ColRGB(cz, _r, _g, _b);
            if (bits[0]) then newr := EnsureByteOdd(_r)
            else newr := EnsureByteEven(_r);
            if (bits[1]) then newg := EnsureByteOdd(_g)
            else newg := EnsureByteEven(_g);
            if (bits[2]) then newb := EnsureByteOdd(_b)
            else newb := EnsureByteEven(_b);
            _bmp.Pixels[x, y]:= RGB(newr, newg, newb);


            GetPixelCoordsReal((baseRead + 1), _bmp.Width, _bmp.Height, _bmp, x, y);
            cz := _bmp.Pixels[x, y];
            ColRGB(cz, _r, _g, _b);
            if (bits[3]) then newr := EnsureByteOdd(_r)
            else newr := EnsureByteEven(_r);
            if (bits[4]) then newg := EnsureByteOdd(_g)
            else newg := EnsureByteEven(_g);
            if (bits[5]) then newb := EnsureByteOdd(_b)
            else newb := EnsureByteEven(_b);
            _bmp.Pixels[x, y]:=RGB(newr, newg, newb);


            GetPixelCoordsReal((baseRead + 2), _bmp.Width, _bmp.Height, _bmp,  x, y);
            cz := _bmp.Pixels[x, y];
            ColRGB(cz, _r, _g, _b);
            if (bits[6]) then newr := EnsureByteOdd(_r)
            else newr := EnsureByteEven(_r);
            if (bits[7]) then newg := EnsureByteOdd(_g)
            else newg := EnsureByteEven(_g);

            _bmp.Pixels[x, y]:=RGB(newr, newg, _b);
      end;
end;

function ReadStringFromPNG(pixelsFromEnd: Integer; var _bmp: TPngImage): string;
var
  totalPixels: Integer;
	x, y: Integer;
	pixels: Array of TColor;
	bits: TBoolArray;
  _r, _g, _b: byte;
  bytes: TBytes;
  i: Integer;
  readLen: Integer;
  firstReadIndex: Integer;
  lastReadIndex: Integer;
  c: TColor;
  n: Integer;
  res: string;
begin
      readLen:=150;
      SetLength(bytes, readLen);
      for i := 0 to Length(bytes)-1 do bytes[i]:=0;

			totalPixels := _bmp.Width * _bmp.Height;
      SetLength(pixels, 400);

      firstReadIndex:=totalPixels - pixelsFromEnd - 1;
      lastReadIndex:=(totalPixels - pixelsFromEnd - 1 + 385 -1);
      n:=0;

      for i := firstReadIndex to lastReadIndex do begin
         GetPixelCoordsReal(i, _bmp.Width, _bmp.Height, _bmp, x,  y);
         c:=_bmp.Pixels[x, y];
         pixels[n] := c;
         n := n+1;
      end;


      for i := 0 to Length(pixels) do begin

        ColRGB(pixels[i*3 + 0], _r, _g, _b);
        bits[0] := _r mod 2 = 1;
        bits[1] := _g mod 2 = 1;
        bits[2] := _b mod 2 = 1;

        ColRGB(pixels[i*3 + 1], _r, _g, _b);
        bits[3] := _r mod 2 = 1;
        bits[4] := _g mod 2 = 1;
        bits[5] := _b mod 2 = 1;

        ColRGB(pixels[i*3 + 2], _r, _g, _b);
        bits[6] := _r mod 2 = 1;
        bits[7] := _g mod 2 = 1;

        bytes[i] := EncodeBool(bits);

      end;


			res:= Trim(BytesToString(bytes));

      if(Pos('|', res)>0) then begin
         res:=Copy(res,0, Pos('|', res));
      end;

      result:=res;
end;

function StringToBytes(const Value : UnicodeString): TBytes;
begin
  SetLength(Result, Length(Value)*SizeOf(Char));
  if Length(Result) > 0 then
    Move(Value[1], Result[0], Length(Result));
end;

function BytesToString(const Value: TBytes): UnicodeString;
var
  i: Integer;
  endb: Integer;
begin

  endb:=0;
  for i := 0 to Length(Value)-1 do begin
    if(Value[i]=124) then begin
      endb:=i+1;
      break;
    end;
  end;

  SetLength(Result, (endb+1) div SizeOf(Char));

  if Length(Result) > 0 then
    Move(Value[0], Result[1], (endb+1));
end;

function DesktopFolder: string;
var
  buf: array[0..MAX_PATH] of char;
  pidList: PItemIDList;
begin
  Result := '';
  SHGetSpecialFolderLocation(Application.Handle, CSIDL_DESKTOP, pidList);
  if pidList = nil then
    exit; // no Desktop? Want to see that computer...
  if SHGetPathFromIDList(pidList, buf) then
    Result := buf;
end;

function EncryptStreamDCP(instream: TMemoryStream; var outstream: TMemoryStream; password: string): boolean;
var
  Cipher: TDCP_cipher;         // the cipher to use
  CipherIV: array of byte;     // the initialisation vector (for chaining modes)
  Hash: TDCP_hash;             // the hash to use
  HashDigest: array of byte;   // the result of hashing the passphrase with the salt
  Salt: array[0..7] of byte;   // a random salt to help prevent precomputated attacks
  i: integer;
begin
  //CompressStream(instream);

    Randomize;
    Hash := TDCP_sha512.Create(nil);//
    Cipher := TDCP_blowfish.Create(nil);
  try
    try
      SetLength(HashDigest,Hash.HashSize div 8);
      for i := 0 to 7 do
        Salt[i] := Random(256);
      outstream.WriteBuffer(Salt,Sizeof(Salt));  // write out the salt so we can decrypt!
      Hash.Init;
      Hash.Update(Salt[0],Sizeof(Salt));   // hash the salt
      Hash.UpdateStr(password);  // and the passphrase
      Hash.Final(HashDigest[0]);           // store the output in HashDigest

      if (Cipher is TDCP_blockcipher) then begin     // if the cipher is a block cipher we need an initialisation vector
        SetLength(CipherIV,TDCP_blockcipher(Cipher).BlockSize div 8);

        for i := 0 to (Length(CipherIV) - 1) do begin
          CipherIV[i] := Random(256);           // again just random values for the IV
        end;

        outstream.WriteBuffer(CipherIV[0],Length(CipherIV));  // write out the IV so we can decrypt!
        Cipher.Init(HashDigest[0],Min(Cipher.MaxKeySize,Hash.HashSize),CipherIV);  // initialise the cipher with the hash as key
        TDCP_blockcipher(Cipher).CipherMode := cmCBC;   // use CBC chaining when encrypting
      end
      else begin
        Cipher.Init(HashDigest[0],Min(Cipher.MaxKeySize,Hash.HashSize),nil); // initialise the cipher with the hash as key
      end;

      Cipher.EncryptStream(instream,outstream,instream.Size); // encrypt the entire file
      Cipher.Burn;   // important! get rid of keying information
      result:=true;
    except
      result:=false;
    end;
  finally
    Hash.Free;
    Cipher.Free;
  end;
end;

function DecryptStreamDCP(instream: TMemoryStream; var outstream: TMemoryStream; password: string): boolean;
var
  Cipher: TDCP_cipher;         // the cipher to use
  CipherIV: array of byte;     // the initialisation vector (for chaining modes)
  Hash: TDCP_hash;             // the hash to use
  HashDigest: array of byte;   // the result of hashing the passphrase with the salt
  Salt: array[0..7] of byte;   // a random salt to help prevent precomputated attacks
begin
  instream.Position:=0;
  outstream.Position:=0;

  Hash := TDCP_sha512.Create(nil);
  Cipher := TDCP_blowfish.Create(nil);
try
  try
    SetLength(HashDigest,Hash.HashSize div 8);
    instream.ReadBuffer(Salt[0],Sizeof(Salt));  // read the salt in from the file
    Hash.Init;
    Hash.Update(Salt[0],Sizeof(Salt));   // hash the salt
    Hash.UpdateStr(password);  // and the passphrase
    Hash.Final(HashDigest[0]);           // store the hash in HashDigest

    if (Cipher is TDCP_blockcipher) then begin           // if it is a block cipher we need the IV
      SetLength(CipherIV,TDCP_blockcipher(Cipher).BlockSize div 8);
      instream.ReadBuffer(CipherIV[0],Length(CipherIV));       // read the initialisation vector from the file
      Cipher.Init(HashDigest[0],Min(Cipher.MaxKeySize,Hash.HashSize),CipherIV);  // initialise the cipher
      TDCP_blockcipher(Cipher).CipherMode := cmCBC;
    end
    else begin
      Cipher.Init(HashDigest[0],Min(Cipher.MaxKeySize,Hash.HashSize),nil);  // initialise the cipher
    end;

    Cipher.DecryptStream(instream,outstream,instream.Size - instream.Position); // decrypt!
    Cipher.Burn;
   // DecompressStream(outstream);
    result:=true;
  except
    result:=false;
  end;
finally
  Hash.Free;
  Cipher.Free;
end;
end;

///not used yet as doing the original hidespace check will give an answer
//that is too small. compressing the data to be hidden will allow more to be hidden
procedure CompressStream(var ms: TMemoryStream);
var
  LZip: TZCompressionStream;
  outs: TMemoryStream;
begin
  ms.Position:=0;
  outs:=TMemoryStream.Create;
  LZip := TZCompressionStream.Create(clMax, outs);
  LZip.CopyFrom(ms, ms.Size);

  BurnMemoryStream(ms);
  ms.SetSize(0);
  outs.Position:=0;

  ms.CopyFrom(outs, outs.Size);
  BurnMemoryStream(outs);
  outs.Free;
end;

///not used yet as doing the original hidespace check will give an answer
//that is too small. compressing the data to be hidden will allow more to be hidden
procedure DecompressStream(var ms: TMemoryStream);
var

  LUnZip: TZDecompressionStream;
  outs: TMemoryStream;
begin
  outs:=TMemoryStream.Create;
  LUnZip := TZDecompressionStream.Create(ms);
  outs.CopyFrom(LUnZip, 0);

  BurnMemoryStream(ms);
  ms.SetSize(0);
  outs.Position:=0;

  ms.CopyFrom(outs, outs.Size);
  BurnMemoryStream(outs);
  outs.Free;
end;

function DecryptStringDCP(s: string; password: string): string;
var
  Cipher: TDCP_rc6;
begin
      Cipher:= TDCP_rc6.Create(nil);
      try
        try
          Cipher.InitStr(password,TDCP_sha512);         // initialize the cipher with a hash of the passphrase
          s := Cipher.DecryptString(s);
          Cipher.Burn;
        except
          s:='';
        end;
      finally
         Cipher.Free;
      end;

      result:=s;
end;

function EncryptStringDCP(s: string; password: string): string;
var
    Cipher: TDCP_rc6;
begin
    Cipher:= TDCP_rc6.Create(nil);
    try
      Cipher.InitStr(password,TDCP_sha512);         // initialize the cipher with a hash of the passphrase
      s:= Cipher.EncryptString(s);
      Cipher.Burn;
    finally
      Cipher.Free;
    end;

    result:=s;
end;

function HashString(text: AnsiString): string;
var
  n: Integer;
begin
  with TIdHashSHA1.Create do
    try
      result:=String(text);
      for n := 0 to 5 do begin
         Result:=LowerCase(HashStringAsHex(Result));
      end;
    finally
      Free;
    end;
end;

function String2Hex(const Buffer: Ansistring): string;
begin
  SetLength(result, 2*Length(Buffer));
  BinToHex(@Buffer[1], PWideChar(@result[1]), Length(Buffer));
end;

function EnsureByteOdd(b: byte): byte;
begin
			if (b mod 2 = 1) then begin
        result:= b;
        exit;
      end
			else if (b > 0) then begin
         b := b - 1;
         result:= b;
         exit;
      end
			else begin
        b := 1;
        result := b;
        exit;
      end;
end;

function EnsureByteEven(b: byte): byte;
begin
			if (b mod 2 = 0) then begin
       result := b;
       exit;
      end
			else if (b > 0) then begin
         b := b - 1;
         result := b;
         exit;
      end
			else begin
        b := 0;
        result := b;
        exit;
      end;
end;

function ToBoolArray(b: byte): TBoolArray;
var
  ba: TBoolArray;
begin
  ResetBoolArray(ba);
  ba[7]:=GetBit(b, 0);
  ba[6]:=GetBit(b, 1);
  ba[5]:=GetBit(b, 2);
  ba[4]:=GetBit(b, 3);
  ba[3]:=GetBit(b, 4);
  ba[2]:=GetBit(b, 5);
  ba[1]:=GetBit(b, 6);
  ba[0]:=GetBit(b, 7);
  result:=ba;
end;

function GetBit(B:Byte; BitNr:Integer):Boolean;
var
  bo: boolean;
begin
   bo := (B and cBit[BitNr] > 0);
   result:=bo;
end;

procedure ResetBoolArray(var ba: TBoolArray);
begin
  ba[0]:=false;
  ba[1]:=false;
  ba[2]:=false;
  ba[3]:=false;
  ba[4]:=false;
  ba[5]:=false;
  ba[6]:=false;
  ba[7]:=false;
end;

procedure GetPixelCoords(pixelNumber: Integer; imageWidth: Integer; imageHeight: Integer;
                                bmp: TPngImage; var x: Integer; var y: Integer);
begin
   x:=pixelNumber mod imageWidth;
   y:=pixelNumber div imageWidth;
end;

procedure GetPixelCoordsReal(pixelNumber: Integer; imageWidth: Integer; imageHeight: Integer;
                                bmp: TPngImage; var x: Integer; var y: Integer);
begin
   x:=pixelNumber mod imageWidth;
   y:=pixelNumber div imageWidth;
end;

function EncodeBool(arr: TBoolArray): byte;
var
  b: byte;
begin
    b:=0;
      if(arr[7]) then b:=b+1;
      if(arr[6]) then b:=b+2;
      if(arr[5]) then b:=b+4;
      if(arr[4]) then b:=b+8;
      if(arr[3]) then b:=b+16;
      if(arr[2]) then b:=b+32;
      if(arr[1]) then b:=b+64;
      if(arr[0]) then b:=b+128;

      result:=b;
end;

function IntToBytes(i: Integer): TByteArr;
var
  ba: TByteArr;
begin
  ba[3] := byte(i);
  ba[2] := byte(i shr 8);
  ba[1] := byte(i shr 16);
  ba[0] := byte(i shr 24);

  result:=ba;
end;

procedure ColRGB(col: TColor; var Red: byte; var Green: byte; var Blue: byte);
var
   longColor : LongInt;
begin
       longColor := ColorToRGB(col);
       Red := GetRValue(longColor);
       Green := GetGValue(longColor);
       Blue := GetBValue(longColor);
end;

function FileSize(const aFilename: String): Integer;
var
  info: TWin32FileAttributeData;
begin
  result := -1;
  if NOT GetFileAttributesEx(PWideChar(aFileName), GetFileExInfoStandard, @info) then EXIT;
  result := Integer(info.nFileSizeLow);
end;

function BytesToInt(b: TByteArr): Integer;
begin
  result:= PInteger(@b[0])^;
end;

procedure HideDataInRGB(var _bmp: TPngImage; PayloadFileName: string; OutputImage: string; var sb: TStatusBar; Password: string = '');
var
  x, y: Integer;
  payload: TArray<System.Byte>;
  newr, newg, newb: byte;
  cz: TColor;
  i: Integer;
  plb: byte;
  rset, gset, bset: boolean;
  _r, _g, _b: byte;
  payloadsizeBytes: TByteArr;
  payloadsize: Integer;
  msPlain: TMemoryStream;
  msCrypt: TMemoryStream;
  outParamsEnc: string;
begin
     if assigned(sb) then sb.Panels[0].Text:='Hiding data in container image...';
     Application.ProcessMessages;

			payload := System.IOUtils.TFile.ReadAllBytes(PayloadFileName);


        PayloadFileName := ExtractFilename(PayloadFileName);

        PayloadFilename:=EncryptStringDCP(PayloadFilename, Password);
        WriteStringToPNG(PayloadFileName, 400, _bmp);

        outParamsEnc:=EncryptStringDCP('2/2', password);//file format version/algorithm ID
        WriteStringToPNG(outParamsEnc, 1200, _bmp);

        if assigned(sb) then sb.Panels[0].Text:='Encrypting payload data...';
        Application.ProcessMessages;

        msPlain:=TMemoryStream.Create;
        msCrypt:=TMemoryStream.Create;
        try
           ByteArrayToStream(payload, msPlain);
           msPlain.Position:=0;
           msCrypt.Position:=0;
           EncryptStreamDCP(msPlain, msCrypt, Password);
           BurnMemoryStream(msPlain);
           payload:=StreamToByteArray(msCrypt);
        finally
           msPlain.Free;
           msCrypt.Free;
        end;


      if assigned(sb) then sb.Panels[0].Text:='Hiding encrypted data in container image color space...';
      Application.ProcessMessages;
      for i :=0 to  Length(payload)-1 do begin
           if(i mod 10240 = 0) then begin
             Application.ProcessMessages;
           end;

           plb := payload[i];
           GetPixelCoords((i * 3), _bmp.Width, _bmp.Height, _bmp, x, y);
           cz := _bmp.Pixels[x, y];

            rset := GetBit(plb, 7);
				    gset := GetBit(plb, 6);
				    bset := GetBit(plb, 5);
            ColRGB(cz, _r, _g, _b);

            if rset then newr := EnsureByteOdd(_r)
            else newr := EnsureByteEven(_r);
            if gset then newg:= EnsureByteOdd(_g)
            else newg:= EnsureByteEven(_g);
            if bset then newb := EnsureByteOdd(_b)
            else newb := EnsureByteEven(_b);



            _bmp.Pixels[x, y]:=RGB(newr, newg, newb);

          GetPixelCoords((i * 3)+1, _bmp.Width, _bmp.Height, _bmp, x, y);
           cz := _bmp.Pixels[x, y];

            rset := GetBit(plb, 4);
				    gset := GetBit(plb, 3);
				    bset := GetBit(plb, 2);
            ColRGB(cz, _r, _g, _b);

            if rset then newr := EnsureByteOdd(_r)
            else newr := EnsureByteEven(_r);
            if gset then newg:= EnsureByteOdd(_g)
            else newg:= EnsureByteEven(_g);
            if bset then newb := EnsureByteOdd(_b)
            else newb := EnsureByteEven(_b);

            _bmp.Pixels[x, y]:=RGB(newr, newg, newb);


          GetPixelCoords((i * 3)+2, _bmp.Width, _bmp.Height,_bmp, x, y);
           cz := _bmp.Pixels[x, y];

            rset := GetBit(plb, 1);
				    gset := GetBit(plb, 0);
            ColRGB(cz, _r, _g, _b);

            if rset then newr := EnsureByteOdd(_r)
            else newr := EnsureByteEven(_r);
            if gset then newg:= EnsureByteOdd(_g)
            else newg:= EnsureByteEven(_g);

            _bmp.Pixels[x, y]:=RGB(newr, newg, newb);

      end;

      if assigned(sb) then sb.Panels[0].Text:='Hiding encrypted data in container image color space..x';
      Application.ProcessMessages;

      payloadsize := Length(payload);
			payloadsizeBytes := IntToBytes(payloadsize);

      WriteStringToPNG(IntToStr(payloadsize), 1500, _bmp);
      if assigned(sb) then sb.Panels[0].Text:='Saving PNG output file / Compression=9';
      Application.ProcessMessages;

      _bmp.CompressionLevel:=9;
			_bmp.SaveToFile(OutputImage);

      if assigned(sb) then sb.Panels[0].Text:='Idle';
      Application.ProcessMessages;
end;

function ExtractPayload(var _bmp: TPngImage; ToDirName: string; var sb: TStatusBar; Password: string = ''): boolean;
var
    rec_payloadsize: Integer;
    cz: TColor;
		x, y: Integer;
    ploadbytes: TArray<System.Byte>;// Array of Byte;
    b: byte;
    bits: TBoolArray;
    n: Integer;
    _r, _g, _b: byte;
    msPlain: TMemoryStream;
    msCrypt: TMemoryStream;
    Filename: string;
    PayloadFileName: string;
    rec_payloadsizestr: string;
    outParamsEnc: string;
begin

      if assigned(sb) then sb.Panels[0].Text:='Extracting encrypted payload...';
      Application.ProcessMessages;
      outParamsEnc:=ReadStringFromPNG(1200, _bmp);
      outParamsEnc:=DecryptStringDCP(outParamsEnc, password);

      if(outParamsEnc<>'2/2') then begin

          if(Length(outParamsEnc)>0) then
            MessageBox(0, PChar('Data was embedded with a different version of PNG Veil (v '+outParamsEnc+')'), '', MB_ICONSTOP or MB_OK)
          else
            MessageBox(0, PChar('Password is invalid'), '', MB_ICONSTOP or MB_OK);

          if assigned(sb) then sb.Panels[0].Text:='Idle';
          result:=false;
          exit;

      end;

      rec_payloadsizestr:=Trim(ReadStringFromPNG(1500, _bmp));
			if(rec_payloadsizestr[Length(rec_payloadsizestr)]='|') then begin
        rec_payloadsizestr:=Copy(rec_payloadsizestr, 0, Length(rec_payloadsizestr)-1);
      end;
      rec_payloadsize:=StrToIntDef(rec_payloadsizestr, 0);
      if(rec_payloadsize=0) then begin
        if assigned(sb) then sb.Panels[0].Text:='Idle';
        Application.ProcessMessages;
        result:=false;
        exit;
      end;

      SetLength(ploadbytes,  rec_payloadsize);

			for n := 0 to Length(ploadbytes)-1 do begin
          if n mod 10240 = 0 then begin
            Application.ProcessMessages;
          end;

          GetPixelCoords(n * 3, _bmp.Width, _bmp.Height,  _bmp, x, y);
          cz:= _bmp.Pixels[x,y];
          ColRGB(cz, _r, _g, _b);

          if(_r mod 2 = 1) then bits[0]:=true
          else bits[0]:=false;
          if(_g mod 2 = 1) then bits[1]:=true
          else bits[1]:=false;
          if(_b mod 2 = 1) then bits[2]:=true
          else bits[2]:=false;

          GetPixelCoords((n * 3)+1, _bmp.Width, _bmp.Height,  _bmp, x, y);
          cz:= _bmp.Pixels[x,y];
          ColRGB(cz, _r, _g, _b);

          if(_r mod 2 = 1) then bits[3]:=true
          else bits[3]:=false;
          if(_g mod 2 = 1) then bits[4]:=true
          else bits[4]:=false;
          if(_b mod 2 = 1) then bits[5]:=true
          else bits[5]:=false;


          GetPixelCoords((n * 3)+2, _bmp.Width, _bmp.Height,  _bmp, x, y);
          cz:= _bmp.Pixels[x,y];
          ColRGB(cz, _r, _g, _b);

          if(_r mod 2 = 1) then bits[6]:=true
          else bits[6]:=false;
          if(_g mod 2 = 1) then bits[7]:=true
          else bits[7]:=false;

          b := EncodeBool(bits);
				  ploadbytes[n] := b;
      end;

      FileName:=Trim(ReadStringFromPNG(400, _bmp));
      if assigned(sb) then sb.Panels[0].Text:='Decrypting payload...';
      Application.ProcessMessages;

      if(Length(Password)>0) then begin
        msPlain:=TMemoryStream.Create;
        msCrypt:=TMemoryStream.Create;
        try
           ByteArrayToStream(ploadbytes, msCrypt);
           if(not DecryptStreamDCP(msCrypt, msPlain, Password)) then begin
             result:=false;
              MessageBox(0, 'Payload data is corrupt.', '', MB_ICONSTOP or MB_OK);
             exit;
           end;
           //ploadbytes:=self.StreamToByteArray(msPlain);

            if(FileName[Length(FileName)]='|') then begin
               FileName:=Copy(FileName, 0, Length(FileName)-1);
            end;

            if(Length(password)>0) then begin
              PayloadFileName:=DecryptStringDCP(FileName, password);
            end
            else begin
              PayloadFileName:=FileName;
            end;

            if(ToDirName[Length(ToDirName)]<>'\') then begin
               ToDirName:=ToDirName+'\';
            end;

            msPlain.SaveToFile(ToDirName + PayloadFileName);
            BurnMemoryStream(msPlain);
        finally
           msPlain.Free;
           msCrypt.Free;
           if assigned(sb) then sb.Panels[0].Text:='Idle';
        end;
      end;

      Application.ProcessMessages;
      result:=true;
			//SaveBytesToFile(ploadbytes, ToDirName + PayloadFileName);
end;


end.

unit Unit1;

interface

uses
  Winapi.Windows, System.SysUtils,  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms,  Vcl.Menus, Vcl.ExtCtrls, PNGImage,
  System.IOUtils, Vcl.Buttons, Math, Vcl.StdCtrls,
  Registry, Vcl.ToolWin, Vcl.ComCtrls, Vcl.Dialogs, ShlObj, FileCtrl,
  System.ImageList, Vcl.ImgList, Vcl.AppEvnts, ShellAPI, PVUtils;

type

  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    file1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Help1: TMenuItem;
    Help2: TMenuItem;
    About1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    StatusBar1: TStatusBar;
    OpenDialogAny: TOpenDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog1: TSaveDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    txtPayloadFile: TEdit;
    txtPassEnc1: TEdit;
    txtPassEnc2: TEdit;
    btnOpenPayload: TButton;
    txtPNGFile: TEdit;
    btnPNG: TButton;
    txtOutFile: TEdit;
    btnSelOutputPNG: TButton;
    TabSheet2: TTabSheet;
    txtPassword: TEdit;
    txtDir: TEdit;
    btnSelDir: TButton;
    txtPNGExtract: TEdit;
    btnPNGExtract: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    btnRetrIV: TSpeedButton;
    btnEmbed2: TBitBtn;
    btnExtract2: TBitBtn;
    ImageList1: TImageList;
    ApplicationEvents1: TApplicationEvents;
    Button1: TButton;
    procedure btnHideCryptClick(Sender: TObject);
    procedure btnExtractClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelp3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnPNGClick(Sender: TObject);
    procedure btnSelOutputPNGClick(Sender: TObject);
    procedure btnSelDirClick(Sender: TObject);
    procedure btnPNGExtractClick(Sender: TObject);
    procedure btnOpenPayloadClick(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure PNGProgress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean;
      const R: TRect; const Msg: string);
  private
    procedure SaveSettings;
    procedure LoadSettings;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses frmAboutUnit;  {frmCryptUnit, frmDecryptUnit,}

procedure TfrmMain.btnSelOutputPNGClick(Sender: TObject);
begin
  if(self.SaveDialog1.Execute(self.Handle)) then begin
      txtOutFile.Text:=self.SaveDialog1.FileName;
  end;
end;

procedure TfrmMain.btnPNGExtractClick(Sender: TObject);
begin
  if(self.OpenDialog1.Execute(self.Handle)) then begin
    self.txtPNGExtract.Text:=self.OpenDialog1.FileName;
  end;
end;

procedure TfrmMain.About1Click(Sender: TObject);
var
  frm: TfrmAbout;
begin
  frm:=TfrmAbout.Create(self);
  try
     frm.ShowModal;
  finally
     frm.Free;
  end;
end;

procedure TfrmMain.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
var
  s1: string;
  s2: string;
begin
  s1:=self.txtPassEnc1.Text;
  s2:=self.txtPassEnc2.Text;

  btnEmbed2.Enabled:=(self.PageControl1.TabIndex=0) and ((Length(s1)>5) and (s1=s2)
  and (FileExists(self.txtPayloadFile.Text)) and  (FileExists(self.txtPNGFile.Text)));

  btnExtract2.Enabled:=(self.PageControl1.TabIndex=1)
                  and ((Length(self.txtPassword.Text)>5)
                  and (FileExists(txtPNGExtract.Text))
                  and (System.SysUtils.DirectoryExists(self.txtDir.Text)));
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnExtractClick(Sender: TObject);
var
  _bmp: TPngImage;
begin

   _bmp:=TPngImage.Create;
   try
     _bmp.LoadFromFile(txtPNGExtract.Text);

     if(not ExtractPayload(_bmp, txtDir.Text, self.StatusBar1, txtPassword.Text)) then begin
        //MessageBox(0, 'Password is invalid', '', MB_ICONSTOP or MB_OK);
     end;
   finally
     _bmp.Free;
   end;

end;

procedure TfrmMain.btnHelp3Click(Sender: TObject);
var
hres: HResult;
begin
  hres:=ShellExecute(handle,'open',PChar(ExtractFilePath(Application.ExeName) + 'help.pdf'), '','',SW_SHOWNORMAL);

  if (hres<33) then
      MessageBox(0, 'There was a problem opening the help file "help.pdf". Check that the file exists in this programs installation folder and that you have a PDF reader installed.', 'Problem opening help file :(', MB_ICONERROR or MB_OK);

end;

procedure TfrmMain.PNGProgress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean;
  const R: TRect; const Msg: string);
begin
  if(PercentDone mod 2)=0 then Application.ProcessMessages;
end;

procedure TfrmMain.btnHideCryptClick(Sender: TObject);
var
  freespace: Integer;
  payloadSize: Integer;
  _bmp: TPngImage;
begin

  if not FileExists(self.txtPNGFile.Text) then begin
       MessageBox(0, PChar('The original PNG file "'+self.txtPNGFile.Text+'" does not exist.'), 'File Error', MB_ICONSTOP or MB_OK or MB_DEFBUTTON2);
       exit;
  end;
  if not FileExists(self.txtPayloadFile.Text) then begin
       MessageBox(0, PChar('The payload file "'+self.txtPayloadFile.Text+'" does not exist.'), 'File Error', MB_ICONSTOP or MB_OK or MB_DEFBUTTON2);
       exit;
  end;

  _bmp:=TPngImage.Create;
  try
    _bmp.OnProgress := PNGProgress;
     _bmp.LoadFromFile(self.txtPNGFile.Text);
     freespace := GetHideSpace(_bmp);
     payloadSize := FileSize(txtPayloadFile.Text);

     if(payloadSize>freespace) then begin
       MessageBox(0, 'That payload file is larger than the available data hiding space in the container image.', 'File Size Error', MB_ICONSTOP or MB_OK or MB_DEFBUTTON2);
       exit;
     end;

     if(FileExists(txtOutFile.Text)) then DeleteFile(txtOutFile.Text);
     HideDataInRGB(_bmp, txtPayloadFile.Text, txtOutFile.Text, self.StatusBar1, txtPassEnc1.Text);
  finally
    _bmp.Free;
  end;
end;

procedure TfrmMain.btnOpenPayloadClick(Sender: TObject);
begin
    if(Length(self.txtPayloadFile.Text)>0) then
      self.OpenDialogAny.InitialDir:=ExtractFileDir(self.txtPayloadFile.Text);

    if(self.OpenDialogAny.Execute(self.Handle)) then begin
      self.txtPayloadFile.Text:=self.OpenDialogAny.FileName;
    end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettings;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  LoadSettings;
end;

procedure TfrmMain.SaveSettings;
var
  rk: TRegistry;
begin
  rk:=TRegistry.Create;
  try
    rk.OpenKey('SOFTWARE\Bernard Ford\PNG Veil', true);
    rk.WriteInteger('Left', self.Left);
    rk.WriteInteger('Top', self.Top);
    rk.CloseKey;
  finally
    rk.Free;
  end;
end;

procedure TfrmMain.LoadSettings;
var
  rk: TRegistry;
begin
  rk:=TRegistry.Create;
  try
    rk.OpenKey('SOFTWARE\Bernard Ford\PNG Veil', true);
    if rk.ValueExists('Left') then
      self.Left:=rk.ReadInteger('Left')
    else
      self.Left:=(screen.Width div 2) - (self.Width div 2);

    if rk.ValueExists('Top') then
      self.Top:=rk.ReadInteger('Top')
    else
      self.Top:=(screen.Height div 2) - (self.Height div 2);

    rk.CloseKey;
  finally
    rk.Free;
  end;
end;

procedure TfrmMain.btnPNGClick(Sender: TObject);
begin
  if(self.OpenDialog1.Execute(self.Handle)) then begin
    self.txtPNGFile.Text:=self.OpenDialog1.FileName;
  end;
end;

procedure TfrmMain.btnSelDirClick(Sender: TObject);
var
  startDir: WideString;
  b: boolean;
  dirs: TArray<string>;
begin

  if(System.SysUtils.DirectoryExists(self.txtDir.Text)) then
     startDir:=self.txtDir.Text
  else
      startDir:=DesktopFolder;

  b:=SelectDirectory(startDir, dirs, [ sdForceShowHidden ], 'Where would you like to extract the payload file to?', 'Folder name', 'Ok');

  if(b) then begin
    self.txtDir.Text:=dirs[0];
  end;

end;


end.

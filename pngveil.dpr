program pngveil;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles,
  frmAboutUnit in 'frmAboutUnit.pas' {frmAbout},
  PVUtils in 'PVUtils.pas';

{$R *.res}

begin

    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.Title := 'PNG Veil';
    Application.CreateForm(TfrmMain, frmMain);
    Application.Run;

end.

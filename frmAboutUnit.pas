unit frmAboutUnit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, ShellApi, Vcl.ComCtrls;

type
  TfrmAbout = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    btnOk: TButton;
    RichEdit1: TRichEdit;
    procedure Label2Click(Sender: TObject);
    procedure Label2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

procedure TfrmAbout.Label2Click(Sender: TObject);
begin
ShellExecute(handle,'open',PChar('http://nextrandom.com'), '','',SW_SHOWNORMAL);
end;

procedure TfrmAbout.Label2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Label2.Top:=Label2.Top+1;
  Label2.Left:=Label2.Left+1;
end;

procedure TfrmAbout.Label2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Label2.Top:=Label2.Top-1;
  Label2.Left:=Label2.Left-1;
end;

end.

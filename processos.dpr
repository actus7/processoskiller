program processos;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  WbemScripting_TLB in 'WbemScripting_TLB.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

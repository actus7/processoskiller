unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdSync, ActiveX, ComObj, WbemScripting_TLB,
  Vcl.ExtCtrls, Vcl.WinXCtrls, Vcl.Grids, Vcl.ComCtrls;

type
  TStringGridHack = class(TStringGrid)
  protected
    procedure DeleteRow(ARow: Longint); reintroduce;
    procedure InsertRow(ARow: Longint);
  end;

  TCarregaProcessos = class(TIdNotify)
  protected
    FFiltro: string;
    procedure DoNotify; override;
  public
    class procedure Processos(const aFiltro: String = '');
  end;

  TfrmMain = class(TForm)
    lbl1: TLabel;
    btnCarregar: TButton;
    btnMatar: TButton;
    mmLogs: TMemo;
    grdProcessos: TStringGrid;
    srchProcesso: TSearchBox;
    statProcess: TStatusBar;
    procedure btnCarregarClick(Sender: TObject);
    procedure btnMatarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure srchProcessoInvokeSearch(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TStringGridHack.DeleteRow(ARow: Longint);
var
  GemRow: Integer;
begin
  GemRow := Row;
  if RowCount > FixedRows + 1 then
    inherited DeleteRow(ARow)
  else
    Rows[ARow].Clear;
  if GemRow < RowCount then
    Row := GemRow;
end;

procedure TStringGridHack.InsertRow(ARow: Longint);
var
  GemRow: Integer;
begin
  GemRow := Row;
  while ARow < FixedRows do
    Inc(ARow);
  RowCount := RowCount + 1;
  MoveRow(RowCount - 1, ARow);
  Row := GemRow;
end;

procedure TfrmMain.srchProcessoInvokeSearch(Sender: TObject);
begin
  if Trim(srchProcesso.Text) <> '' then
    TCarregaProcessos.Processos(' where Name LIKE "%' + srchProcesso.Text + '%"')
  else
    TCarregaProcessos.Processos;
end;

{ TCarregaProcessos }

procedure TCarregaProcessos.DoNotify;
const
  WbemUser = '';
  WbemPassword = '';
  WbemComputer = 'localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject: OLEVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;
  vLinha: Integer;
begin
  try
    CoInitialize(nil);
    try
      FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
      FWMIService := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
      FWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM Win32_Process' + FFiltro, 'WQL', wbemFlagForwardOnly);
      oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumvariant;

      frmMain.grdProcessos.RowCount := 2;
      frmMain.grdProcessos.ColCount := 4;
      frmMain.grdProcessos.FixedRows := 1;
      frmMain.grdProcessos.Cells[0, 0] := 'Handle';
      frmMain.grdProcessos.Cells[1, 0] := 'Name';
      frmMain.grdProcessos.Cells[2, 0] := 'ThreadCount';
      frmMain.grdProcessos.Cells[3, 0] := 'Description';

      frmMain.grdProcessos.ColWidths[0] := 50;
      frmMain.grdProcessos.ColWidths[1] := 100;
      frmMain.grdProcessos.ColWidths[2] := 80;
      frmMain.grdProcessos.ColWidths[3] := 150;

      vLinha := 1;
      while oEnum.Next(1, FWbemObject, iValue) = 0 do
      begin
        frmMain.grdProcessos.RowCount := vLinha + 1;
        frmMain.grdProcessos.Cells[0, vLinha] := FWbemObject.Handle;
        frmMain.grdProcessos.Cells[1, vLinha] := FWbemObject.Name;
        frmMain.grdProcessos.Cells[2, vLinha] := FWbemObject.ThreadCount;
        frmMain.grdProcessos.Cells[3, vLinha] := FWbemObject.Description;
        Inc(vLinha);
        FWbemObject := Unassigned;
      end;
      frmMain.statProcess.Panels[0].Text := 'Total de Processos: ' + IntToStr(vLinha);
    finally
      CoUninitialize;
    end;
  except
    on E: EOleException do
      Writeln(Format('EOleException %s %x', [E.Message, E.ErrorCode]));
    on E: Exception do
      Writeln(E.Classname, ':', E.Message);
  end;
end;

class procedure TCarregaProcessos.Processos(const aFiltro: String = '');
begin
  with TCarregaProcessos.Create do
    try
      FFiltro := aFiltro;
      Notify;
    except
      Free;
      raise;
    end;
end;

procedure TfrmMain.btnCarregarClick(Sender: TObject);
begin
  TCarregaProcessos.Processos;
end;

procedure Invoke_Win32_Process_Terminate(const WmiPath: string);
const
  WbemUser = '';
  WbemPassword = '';
  WbemComputer = 'localhost';
var
  FSWbemLocator: ISWbemLocator;
  FWMIService: ISWbemServices;
  FWbemObject: ISWbemObject;
  FInParams: ISWbemObject;
  FOutParams: ISWbemObject;
  varValue: OLEVariant;
begin
  FSWbemLocator := CoSWbemLocator.Create;
  FWMIService := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword, '', '', 0, nil);
  FWbemObject := FWMIService.Get(WmiPath, 0, nil);
  FInParams := FWbemObject.Methods_.Item('Terminate', 0).InParameters.SpawnInstance_(0);
  varValue := 0;
  FInParams.Properties_.Item('Reason', 0).Set_Value(varValue);

  FOutParams := FWMIService.ExecMethod(WmiPath, 'Terminate', FInParams, 0, nil);

  case FOutParams.Properties_.Item('ReturnValue', 0).Get_Value of
    0:
      frmMain.mmLogs.Lines.Add('Conclusão bem-sucedida.');
    2:
      frmMain.mmLogs.Lines.Add('O usuário não tem acesso às informações solicitadas.');
    3:
      frmMain.mmLogs.Lines.Add('O usuário não tem privilégios suficientes.');
    8:
      frmMain.mmLogs.Lines.Add('Falha desconhecida.');
    9:
      frmMain.mmLogs.Lines.Add('O caminho especificado não existe.');
    21:
      frmMain.mmLogs.Lines.Add('O parâmetro especificado é inválido.');
  end;
end;

procedure TfrmMain.btnMatarClick(Sender: TObject);
var
  HandlePro: Integer;
begin
  HandlePro := StrToInt(grdProcessos.Cells[0, grdProcessos.Row]);
  try
    CoInitialize(nil);
    try
      Invoke_Win32_Process_Terminate('Win32_Process.Handle="' + IntToStr(HandlePro) + '"');
    finally
      CoUninitialize;
    end;
  except
    on E: EOleException do
      frmMain.mmLogs.Lines.Add(Format('EOleException %s %x', [E.Message, E.ErrorCode]));
    on E: Exception do
      frmMain.mmLogs.Lines.Add(E.Classname + ':' + E.Message);
  end;
  TCarregaProcessos.Processos;
end;

function VersaoExe(const Filename: String): String;
type
  TVersionInfo = packed record
    Dummy: array [0 .. 7] of Byte;
    V2, V1, V4, V3: Word;
  end;
var
  Zero, Size: Cardinal;
  Data: Pointer;
  VersionInfo: ^TVersionInfo;
begin
  Size := GetFileVersionInfoSize(Pointer(Filename), Zero);
  if Size = 0 then
    Result := ''
  else
  begin
    GetMem(Data, Size);
    try
      GetFileVersionInfo(Pointer(Filename), 0, Size, Data);
      VerQueryValue(Data, '\', Pointer(VersionInfo), Size);
      Result := Format('%d.%d.%d.%d', [VersionInfo.V1, VersionInfo.V2, VersionInfo.V3, VersionInfo.V4]);
    finally
      FreeMem(Data);
    end;
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  Caption := Caption + ' [' + VersaoExe(ExtractFilePath(ParamStr(0)) + ExtractFileName(ParamStr(0))) + ']';
  TCarregaProcessos.Processos;
end;

end.

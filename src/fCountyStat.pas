unit fCountyStat;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, IpHtml, Ipfilebroker, db, BufDataset,
  LazFileUtils;

type

  { TfrmCountyStat }

  TfrmCountyStat = class(TForm)
    btnSaveTo: TButton;
    btnRefresh: TButton;
    btnClose: TButton;
    chkQSL: TCheckBox;
    chkLoTW: TCheckBox;
    chkeQSL: TCheckBox;
    cmbBands: TComboBox;
    GroupBox1: TGroupBox;
    IpFileDataProvider1: TIpFileDataProvider;
    IpHtmlPanel1: TIpHtmlPanel;
    Label1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    dlgSave: TSaveDialog;
    procedure btnRefreshClick(Sender: TObject);
    procedure btnSaveToClick(Sender: TObject);
    procedure cmbBandsChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    TmpFile : String;
    f  : TextFile;
    procedure WriteHMTLHeader;
  public

  end; 

var
  frmCountyStat: TfrmCountyStat;

implementation
{$R *.lfm}

{ TfrmCountyStat }
uses dUtils,dData, uMyIni, uVersion;

procedure TfrmCountyStat.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  dmUtils.SaveForm(frmCountyStat);
  cqrini.WriteInteger('CountyStat','Band',cmbBands.ItemIndex);
  cqrini.WriteBool('CountyStat','QSL',chkQSL.Checked);
  cqrini.WriteBool('CountyStat','LoTW',chkLoTW.Checked);
  cqrini.WriteBool('CountyStat','eQSL',chkeQSL.Checked);
  DeleteFileUTF8(TmpFile);
  DeleteFileUTF8(ExtractFileNameWithoutExt(TmpFile)+'.html')
end;

procedure TfrmCountyStat.btnRefreshClick(Sender: TObject);
var
  tmp : String = '';
  grb : String = '';
  wkd : Word = 0;
  cfm : Word = 0;
  ll  : String = '';
  sum_wkd : Word = 0;
  sum_cfm : Word = 0;
  db : TBufDataset;
begin
  btnRefresh.Font.Color:=clDefault;
  btnRefresh.Font.Style:=[];
  try
    dmData.Q.Close;
    dmData.Q1.Close;
    if dmData.trQ.Active then dmData.trQ.Rollback;
    if dmData.trQ1.Active then dmData.trQ1.Rollback;
    if chkQSL.Checked then
    begin
      tmp := '(qsl_r = '+QuotedStr('Q')+') or';
      grb := ',qsl_r';
    end;
    if chkLoTW.Checked then
    begin
      tmp := tmp + ' (lotw_qslr = '+QuotedStr('L')+') or';
      grb := grb + ',lotw_qslr'
    end;
    if chkeQSL.Checked then
    begin
      tmp := tmp + ' (eqsl_qsl_rcvd = '+QuotedStr('E')+') or';
      grb := grb + ',eqsl_qsl_rcvd'
    end;
    tmp := copy(tmp,1,Length(tmp)-2); //remove "or"

    dmData.trQ.StartTransaction;
    dmData.trQ1.StartTransaction;
    try
      dmData.Q.SQL.Text := 'select upper(county) as ll FROM cqrlog_main where county <> '+QuotedStr('')+
                           ' and band='+QuotedStr(cmbBands.Text)+' group by ll';
      writeln( dmData.Q.SQL.Text);
      dmData.Q.Open;
      WriteHMTLHeader;
      writeln(f,'<table>');
      while not dmData.Q.Eof do
      begin
        ll := dmData.Q.Fields[0].AsString;
        writeln(f,'<tr>'+LineEnding+'<td valign="middle">'+LineEnding+'<font color="black"><b>'+ll+'</b></font>'+LineEnding+'</td>');
        writeln(f,'<td align="left">');
        writeln(f,'<font color="black">');
        dmData.Q1.Close;
        dmData.Q1.SQL.Text := 'select count(id_cqrlog_main) FROM cqrlog_main where upper(county)='+
                              QuotedStr(ll)+' and band = '+QuotedStr(cmbBands.Text);
        writeln( dmData.Q1.SQL.Text);
        dmData.Q1.Open;

      wkd := dmData.Q1.Fields[0].AsInteger;
      sum_wkd := sum_wkd + wkd;
      if tmp <> '' then
      begin
        dmData.Q1.Close;
        dmData.Q1.SQL.Text := 'select count(id_cqrlog_main) FROM cqrlog_main where upper(county)='+
                          QuotedStr(ll)+' and band = '+QuotedStr(cmbBands.Text)+
                              'and ('+tmp+')';
        writeln( dmData.Q1.SQL.Text);
        dmData.Q1.Open;
        cfm := dmData.Q1.Fields[0].AsInteger;
        sum_cfm := sum_cfm + cfm
      end;
      dmData.Q1.Close;

      Writeln(f,'</font>');
      Writeln(f,'</td>');
      Writeln(f,'<td valign="middle" align="left">');
      Writeln(f,'<font color="black">');
      Writeln(f,'<b>WKD: ',wkd,'</b><br>');
      if tmp<>'' then
        Writeln(f,'<font color="black"><b>CFM: ',cfm,'</font></b>');
      Writeln(f,'</font>');
      Writeln(f,'</td>');
      Writeln(f,'</tr>');
      dmData.Q.Next
      end;
      Writeln(f,'</table>');
      Writeln(f,'<hr>');
      Writeln(f,'<font color="black">'+LineEnding+'<b>Total:</b><br>');
      Writeln(f,'Worked:',sum_wkd,'<br>');
      Writeln(f,'Confirmed:',sum_cfm);
      Writeln(f,'</font>');
      Writeln(f,'</body>');
      Writeln(f,'</html>');
      CloseFile(f)
    finally
      dmData.trQ.Rollback;
      dmData.trQ1.Rollback
    end;
    CopyFile(TmpFile,ExtractFileNameWithoutExt(TmpFile)+'.html');
    IpHtmlPanel1.OpenURL(expandLocalHtmlFileName(ExtractFileNameWithoutExt(TmpFile)+'.html'))
  finally
  end
end;

procedure TfrmCountyStat.btnSaveToClick(Sender: TObject);
begin
  if dlgSave.Execute then
  begin
    cqrini.WriteString('CountyStat','Directory',ExtractFilePath(dlgSave.FileName));
    CopyFile(TmpFile,dlgSave.FileName)
  end
end;

procedure TfrmCountyStat.cmbBandsChange(Sender: TObject);
begin
  btnRefresh.Font.Color:=clFuchsia;
  btnRefresh.Font.Style:=[fsBold];
  btnRefresh.Repaint;
end;

procedure TfrmCountyStat.WriteHMTLHeader;
begin
  AssignFile(f,TmpFile);
  Rewrite(f);
  writeln(f,'<html>');
  Writeln(f,'<head>');
  writeln(f,'<meta http-equiv="content-type" content="text/html; charset=utf-8">');
  writeln(f,'<meta name="generator" content="CQRLOG '+cVERSION+', www.cqrlog.com">');
  writeln(f,'<title>County statistic ('+cqrini.ReadString('Station','Call','')+')</title>');
  writeln(f,'</head>');
  writeln(f,'<body>');
  Writeln(f,'<font color="black">');
  Writeln(f,'<h1>County statistic</h1><br>');
  Writeln(f,'Station:'+cqrini.ReadString('Station','Call','')+'; Band: '+cmbBands.Text);
  Writeln(f,'</font>');
  Writeln(f,'<br>')
end;

procedure TfrmCountyStat.FormShow(Sender: TObject);
begin
  TmpFile := GetTempFileNameUTF8(dmData.HomeDir,'square');
  dmUtils.LoadForm(frmCountyStat);
  dmUtils.FillBandCombo(cmbBands);
  if cqrini.ReadInteger('CountyStat','Band',0) > cmbBands.Items.Count-1 then
    cmbBands.ItemIndex := 0
  else
    cmbBands.ItemIndex := cqrini.ReadInteger('CountyStat','Band',0);

  chkQSL.Checked          := cqrini.ReadBool('CountyStat','QSL',False);
  chkLoTW.Checked         := cqrini.ReadBool('CountyStat','LoTW',False);
  chkeQSL.Checked         := cqrini.ReadBool('CountyStat','eQSL',False);
  dlgSave.InitialDir      := cqrini.ReadString('CountyStat','Directory',dmData.UsrHomeDir);

  IpHtmlPanel1.Font.Color := clBlack;
  btnRefresh.Click
end;

end.


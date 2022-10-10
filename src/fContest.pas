unit fContest;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, LCLType, Buttons, ComCtrls, ExtDlgs, Menus, uMyIni;

type

  { TfrmContest }

  TfrmContest = class(TForm)
    btClearAll: TButton;
    btSave: TButton;
    btClearQso : TButton;
    btDupChkStart: TButton;
    cdDupeDate: TCalendarDialog;
    chkMarkDupe: TCheckBox;
    chkSP: TCheckBox;
    chkTabAll: TCheckBox;
    chkQsp: TCheckBox;
    chkTrueRST: TCheckBox;
    chkNoNr: TCheckBox;
    chkSpace: TCheckBox;
    chkLoc: TCheckBox;
    chkNRInc: TCheckBox;
    cmbContestName: TComboBox;
    edtCall: TEdit;
    edtRSTs: TEdit;
    edtSTX: TEdit;
    edtSTXStr: TEdit;
    edtRSTr: TEdit;
    edtSRX: TEdit;
    edtSRXStr: TEdit;
    gbStatus: TGroupBox;
    lblSpeed: TLabel;
    lblContestName: TLabel;
    lblCall: TLabel;
    lblRSTs: TLabel;
    lblMSGs: TLabel;
    lblRSTr: TLabel;
    lblNRr: TLabel;
    lblMSGr: TLabel;
    lblNRs: TLabel;
    btnHelp : TSpeedButton;
    mnuReSetAll: TMenuItem;
    mnuExit: TMenuItem;
    mnuQSOcount: TMenuItem;
    mnuDXQSOCount: TMenuItem;
    mnuCountyrCountAll: TMenuItem;
    mnuDXCountryCount: TMenuItem;
    mnuDXCountryList: TMenuItem;
    mnuOwnCountryCount: TMenuItem;
    mnuOwnCountryList: TMenuItem;
    mnuMsgMultipCount: TMenuItem;
    mnuMsgMultipList: TMenuItem;
    mStatus: TMemo;
    mnuGrid: TMenuItem;
    mnyIOTA: TMenuItem;
    mnuState: TMenuItem;
    mnuCounty: TMenuItem;
    mnuAward: TMenuItem;
    mnuQSLvia: TMenuItem;
    mnuComment: TMenuItem;
    mnuName: TMenuItem;
    popSetMsg: TPopupMenu;
    popCommonStatus: TPopupMenu;
    rbDupeCheck: TRadioButton;
    rbNoMode4Dupe: TRadioButton;
    rbIgnoreDupes: TRadioButton;
    sbContest: TStatusBar;
    tmrESC2: TTimer;
    procedure btClearAllClick(Sender: TObject);
    procedure btDupChkStartClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure btClearQsoClick(Sender : TObject);
    procedure chkNoNrChange(Sender: TObject);
    procedure chkNRIncChange(Sender: TObject);
    procedure chkNRIncClick(Sender : TObject);
    procedure chkQspChange(Sender: TObject);
    procedure chkTrueRSTChange(Sender: TObject);
    procedure chkTabAllChange(Sender: TObject);
    procedure cmbContestNameExit(Sender: TObject);
    procedure mnuReSetAllClick(Sender: TObject);
    procedure mnuCountyrCountAllClick(Sender: TObject);
    procedure mnuDXCountryCountClick(Sender: TObject);
    procedure mnuDXCountryListClick(Sender: TObject);
    procedure mnuDXQSOCountClick(Sender: TObject);
    procedure edtCallChange(Sender: TObject);
    procedure edtCallExit(Sender: TObject);
    procedure edtCallKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure edtCallKeyPress(Sender: TObject; var Key: char);
    procedure edtSRXStrChange(Sender: TObject);
    procedure edtSRXExit(Sender: TObject);
    procedure edtSTXStrEnter(Sender: TObject);
    procedure edtSTXStrExit(Sender: TObject);
    procedure edtSTXExit(Sender: TObject);
    procedure edtSTXKeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnHelpClick(Sender : TObject);
    procedure gbStatusClick(Sender: TObject);
    procedure mnuMsgMultipCountClick(Sender: TObject);
    procedure mnuMsgMultipListClick(Sender: TObject);
    procedure mnuOwnCountryCountClick(Sender: TObject);
    procedure mnuOwnCountryListClick(Sender: TObject);
    procedure mnuQSOcountClick(Sender: TObject);
    procedure mnuGridClick(Sender: TObject);
    procedure mnyIOTAClick(Sender: TObject);
    procedure mnuStateClick(Sender: TObject);
    procedure mnuCountyClick(Sender: TObject);
    procedure mnuAwardClick(Sender: TObject);
    procedure mnuQSLviaClick(Sender: TObject);
    procedure mnuCommentClick(Sender: TObject);
    procedure mnuNameClick(Sender: TObject);
    procedure rbIgnoreDupesChange(Sender: TObject);
    procedure tmrESC2Timer(Sender: TObject);
  private
    { private declarations }
    procedure InitInput;
    procedure ChkSerialNrUpd(IncNr: boolean);
    procedure SetTabOrders;
    procedure TabStopAllOn;
    procedure QspMsg;
    procedure ClearStatusBar;
    procedure ShowStatusBarInfo;
    procedure MsgIsPopChk(nr:integer);
    procedure MWCStatus;
    procedure NACStatus;
    procedure CommonStatus;
    procedure SendCwFmacro(key:word);
    function CheckDupe(call:string):boolean;
  public
    { public declarations }
    procedure SaveSettings;
  end;

var
  frmContest: TfrmContest;
  RSTstx: string = ''; //contest mode serial numbers store
  RSTstxAdd: string = ''; //contest mode additional string store
  //RSTsrx         :string = '';
  EscFirstTime: boolean = False;
  DupeFromDate :string = '1900-01-01';
  MsgIs        :integer = 0;
  MWC40,MWC80  :integer;
  UseStatus    :integer;  //can be used for status procedure specific operations
                          //-1:no status, 0:common status, 1..x specific status procedures

  MyAdif   : word;        //These will be filled in FormShow
  Mypfx    : String = '';
  Mycont   : String = '';
  Mycountry: String = '';
  Mywaz    : String = '';
  Myposun  : String = '';
  Myitu    : String = '';
  Mylat    : String = '';
  Mylong   : String = '';


implementation

{$R *.lfm}

uses dData, dUtils, dDXCC, fNewQSO, fMain, fWorkedGrids, strutils, fscp, fTRXControl;

procedure TfrmContest.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  tmp: string;
  speed: integer = 0;
  i: integer = 0;

begin
  // enter anywhere
  if key = VK_RETURN then
  begin
    if (length(edtCall.Text) > 2) and (not edtCall.Focused) then   //must be some kind of call and cursor away from edtCall
      btSave.Click;
    key := 0;
  end;

  //esc and double esc
  if key = VK_ESCAPE then
  begin
    if EscFirstTime then
    begin
      //if edtCall.Text = '' then
         frmNewQSO.old_call:='';             //this is stupid hack but only way to reproduce
         frmNewQSO.edtName.Text :='';        //new seek from log (important to see if wkd before,
         frmNewQSO.edtQth.Text  :='';        //and qrz, if one wants)
         frmNewQSO.edtGrid.Text :='';        //otherwise we do not get cursor at the end of call
         edtCall.SetFocus;
         edtCall.SelStart:=length(edtCall.Text);
         edtCall.SelLength:=0;
      //else
      if Assigned(frmNewQSO.CWint) then
        frmNewQSO.CWint.StopSending;
      EscFirstTime := False;
      tmrESC2.Enabled := True;
    end
    else begin   // esc second time
      frmNewQSO.ClearAll;
      if dmData.DebugLevel >= 1 then
         writeln('Clear all done next focus');
      initInput;
      tmrESC2Timer(nil);
    end;
    key := 0;
  end;

  //memory keys
  if (Key >= VK_F1) and (Key <= VK_F10) and (Shift = []) then
  begin
    if (frmNewQSO.cmbMode.Text = 'SSB') or (frmNewQSO.cmbMode.Text = 'FM') or (frmNewQSO.cmbMode.Text = 'AM') then
      frmNewQSO.RunVK(dmUtils.GetDescKeyFromCode(Key))
    else
     SendCwFmacro(key);
     key := 0;
  end;

  if (key = 33) then//pgup
  begin
    if Assigned(frmNewQSO.CWint) then
    begin
      speed := frmNewQSO.CWint.GetSpeed + 2;
      frmNewQSO.CWint.SetSpeed(speed);
      frmNewQSO.sbNewQSO.Panels[4].Text := IntToStr(speed) + 'WPM';
      lblSpeed.Caption:= frmNewQSO.sbNewQSO.Panels[4].Text;
    end;
    key := 0;
  end;

  //S&P mode toggle
  if (key = VK_Tab) and (Shift = [ssShift]) then
    Begin
        chkSP.Checked:= not chkSP.Checked;
        key:=0;
    end;


  if (key = 34) then//pgup
  begin
    if Assigned(frmNewQSO.CWint) then
    begin
      speed := frmNewQSO.CWint.GetSpeed - 2;
      frmNewQSO.CWint.SetSpeed(speed);
      frmNewQSO.sbNewQSO.Panels[4].Text := IntToStr(speed) + 'WPM';
      lblSpeed.Caption:= frmNewQSO.sbNewQSO.Panels[4].Text;
    end;
    key := 0;
  end;

  if ((Shift = [ssCtrl]) and (key = VK_A)) then
  begin
    frmNewQSO.acAddToBandMap.Execute;
    key := 0
  end;

  //split keys
   if (Shift = [ssCTRL]) then
    if key in [VK_1..VK_9] then frmNewQSO.SetSplit(chr(key));
  if ((Shift = [ssCTRL]) and (key = VK_0)) then
    frmTRXControl.DisableSplit;
end;

procedure TfrmContest.edtCallExit(Sender: TObject);
var
  dupe : Integer;
begin
  // if frmNewQSO is in viewmode or editmode it overwrites old data or will not save
  // because saving is disabled in view mode. this if statement starts a fresh newqso form
  if frmNewQSO.ViewQSO or frmNewQSO.EditQSO then
  begin
    frmNewQSO.Caption := dmUtils.GetNewQSOCaption('New QSO');
    frmNewQSO.UnsetEditLabel;
    frmNewQSO.BringToFront;
    frmNewQSO.ClearAll;
    edtCallExit(nil);
  end;

  frmNewQSO.edtCall.Text := edtCall.Text;

  if CheckDupe(edtCall.Text) then
    Begin
     //send macro F3
     if ( (frmNewQSO.cmbMode.Text='CW') or (frmNewQSO.cmbMode.Text = 'SSB')
      or  (frmNewQSO.cmbMode.Text = 'FM') or (frmNewQSO.cmbMode.Text = 'AM') )
       and (not chkSP.Checked) and (length(edtCall.Text)>2) then
                                                                  SendCwFMacro(VK_F3);
    end
   else
    //send macro F2
    if ( (frmNewQSO.cmbMode.Text='CW') or (frmNewQSO.cmbMode.Text = 'SSB')
      or  (frmNewQSO.cmbMode.Text = 'FM') or (frmNewQSO.cmbMode.Text = 'AM') )
     and (not chkSP.Checked) and (length(edtCall.Text)>2) then
                                                                  SendCwFMacro(VK_F2);


  frmNewQSO.edtHisRST.Text := edtRSTs.Text;
  frmNewQSO.edtContestSerialSent.Text := edtSTX.Text;
  frmNewQSO.edtContestExchangeMessageSent.Text := edtSTXStr.Text;
  //so that CW macros work
  frmNewQSO.edtCallExit(nil);
  frmContest.ShowOnTop;
  frmContest.SetFocus;

  ShowStatusBarInfo;
end;

procedure TfrmContest.btSaveClick(Sender: TObject);
begin
  if chkLoc.Checked then
   begin
     case MsgIs of
     0:   frmNewQSO.edtName.Caption:=edtSRXStr.Text;             //Name
     1:   if dmUtils.isLocOK(edtSRXStr.Text) then
             frmNewQSO.edtGrid.Text := edtSRXStr.Text;           //Grid copied only if it is valid
     2:   frmNewQSO.cmbIOTA.Caption:= edtSRXStr.Text;            //IOTA
     3:   Begin
              if frmNewQSO.edtState.Visible then
                frmNewQSO.edtState.Caption:= edtSRXStr.Text       //State
               else
                frmNewQSO.edtDOK.Caption:=edtSRXStr.Text;         //DOK
          end;
     4:   frmNewQSO.edtCounty.Caption:= edtSRXStr.Text;          //County
     5:   frmNewQSO.edtAward.Caption:= edtSRXStr.Text;           //Award
     6:   frmNewQSO.edtQSL_VIA.Caption:= edtSRXStr.Text;         //QSL via
     7:   frmNewQSO.edtRemQSO.Caption:=edtSRXStr.Text;           //Comment.
    end;
   end;

  //NOTE! if mode is not in list program dies! In that case skip next
  if frmNewQSO.cmbMode.ItemIndex >=0 then
   begin
     case frmNewQSO.cmbMode.Items[frmNewQSO.cmbMode.ItemIndex] of
       'SSB','AM','FM' :   begin
                             edtRSTs.Text := copy(edtRSTs.Text,0,2);
                             edtRSTr.Text := copy(edtRSTr.Text,0,2);
                           end;
       else
                           begin
                             edtRSTs.Text := copy(edtRSTs.Text,0,3);
                             edtRSTr.Text := copy(edtRSTr.Text,0,3);
                           end;
     end;
   end;

  frmNewQSO.edtHisRST.Text := edtRSTs.Text;
  if chkMarkDupe.Checked and CheckDupe(edtCall.Text) then
        frmNewQSO.edtHisRST.Text:=frmNewQSO.edtHisRST.Text+'/D';
  frmNewQSO.edtMyRST.Text := edtRSTr.Text;
  frmNewQSO.edtContestSerialReceived.Text := edtSRX.Text;
  frmNewQSO.edtContestSerialSent.Text := edtSTX.Text;
  frmNewQSO.edtContestExchangeMessageReceived.Text := edtSRXStr.Text;
  frmNewQSO.edtContestExchangeMessageSent.Text := edtSTXStr.Text;
  frmNewQSO.edtContestName.Text := cmbContestName.Text;

  if ( (frmNewQSO.cmbMode.Text='CW') or (frmNewQSO.cmbMode.Text = 'SSB')
      or  (frmNewQSO.cmbMode.Text = 'FM') or (frmNewQSO.cmbMode.Text = 'AM') )
       and (not chkSP.Checked) then
                                    SendCwFMacro(VK_F4);
  frmNewQSO.btnSave.Click;
  if dmData.DebugLevel >= 1 then
    Writeln('input finale');
  ChkSerialNrUpd(chkNRInc.Checked);
  initInput;

end;

procedure TfrmContest.btClearAllClick(Sender: TObject);
var
   f:integer;
begin
  rbDupeCheck.Checked := True;
  rbNoMode4Dupe.Checked := False;
  rbIgnoreDupes.Checked := False;

  chkSpace.Checked :=  False;
  chkTrueRST.Checked := False;
  chkNRInc.Checked := False;
  chkQsp.Checked := False;
  chkSP.Checked:=True;       //this prevents automated release of Messages F2..F4 by accident
  chkNoNr.Checked := False;
  chkLoc.Checked := False;

  edtSTX.Text := '';
  edtSTXStr.Text := '';
  cmbContestName.Text:= '';

  for f:=0 to 8 do
     popCommonStatus.Items[f].Checked:=True;
end;

procedure TfrmContest.btDupChkStartClick(Sender: TObject);
begin
  cdDupeDate.Date := StrToDate(DupeFromDate,'-');
  if cdDupeDate.Execute then
    begin
      DupeFromDate:=FormatDateTime( 'yyyy-mm-dd',cdDupeDate.Date );
      cqrini.WriteString('frmContest', 'DupeFrom', DupeFromDate);
      btDupChkStart.Caption:='from '+DupeFromDate;
    end

end;

procedure TfrmContest.btClearQsoClick(Sender : TObject);
begin
  frmNewQSO.ClearAll;
  initInput
end;

procedure TfrmContest.chkNoNrChange(Sender: TObject);
Begin
  SetTabOrders;
end;

procedure TfrmContest.chkNRIncChange(Sender: TObject);
begin
  SetTabOrders;
end;

procedure TfrmContest.chkNRIncClick(Sender : TObject);
begin
  if chkNRInc.Checked and (edtSTX.Text = '') then
  begin
    edtSTX.Text := '001';
    edtCall.SetFocus
  end
end;

procedure TfrmContest.chkQspChange(Sender: TObject);
begin
  SetTabOrders;
end;

procedure TfrmContest.chkTrueRSTChange(Sender: TObject);
begin
  SetTabOrders;
end;

procedure TfrmContest.chkTabAllChange(Sender: TObject);
begin
  SetTabOrders;
end;

procedure TfrmContest.cmbContestNameExit(Sender: TObject);
begin
    cmbContestName.Text:= ExtractWord(1,cmbContestName.Text,['|']);

    if cmbContestName.Text='' then
       begin
         UseStatus:=-1; //no Contest name, noStatus
         mStatus.Clear;
         Exit;
       end;

    if ((pos('MWC',uppercase(cmbContestName.Text))>0)
    or (pos('OK1WC',uppercase(cmbContestName.Text))>0)) then
      Begin
        UseStatus:=1; //OK1WC memorial contest
        MWCStatus;
        Exit;
      end;

    if (pos('NAC',uppercase(cmbContestName.Text))>0) then
      Begin
        UseStatus:=2; //Nordic V,U,SHF activity contest
        NACStatus;
        Exit;
      end;

    {
    //if you create a Status procedure you can call it here
    if (pos('xxxx',uppercase(cmbContestName.Text))>0) then
      Begin
        UseStatus:=3; //Next ststus counting procedure
        xxxxStatus;
        Exit;
      end;
     }

     UseStatus:=0;  //Common status display for contests where name does not fit to any above
     CommonStatus;
end;

procedure TfrmContest.edtCallChange(Sender: TObject);
begin
  if frmSCP.Showing and (Length(edtCall.Text)>2) then
    frmSCP.mSCP.Text := dmData.GetSCPCalls(edtCall.Text)
  else
    frmSCP.mSCP.Clear;
  CheckDupe(edtCall.Text);
end;


procedure TfrmContest.edtCallKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if ((Key = VK_SPACE) and (chkSpace.Checked)) then
  begin
    Key := 0;
    SelectNext(Sender as TWinControl, True, True);
  end;
end;

procedure TfrmContest.edtCallKeyPress(Sender: TObject; var Key: char);
begin
  if not (key in ['a'..'z', 'A'..'Z', '0'..'9',
    '/', chr(VK_DELETE), chr(VK_BACK), chr(VK_RIGHT), chr(VK_LEFT)]) then
    key := #0;
end;

procedure TfrmContest.edtSRXStrChange(Sender: TObject);
begin
  if ((chkLoc.Checked) and (MsgIs=1 ))then
  begin
   edtSRXStr.Text := dmUtils.StdFormatLocator(edtSRXStr.Text);
   edtSRXStr.SelStart := Length(edtSRXStr.Text);
   if ( Length(edtSRXStr.Text) in [1,3,5] )then
       edtSRXStr.Font.Color:=clRed
      else
       edtSRXStr.Font.Color:=clDefault;
   if ( Length(edtSRXStr.Text) > 6 )then
          edtSRXStr.Text:=copy(edtSRXStr.Text,1,6); //accept only 6chr locator input here
  end;
end;
procedure TfrmContest.edtSRXExit(Sender: TObject);
begin
  ChkSerialNrUpd(False); //just save it
end;

procedure TfrmContest.edtSTXStrEnter(Sender: TObject);
begin
  if chkQsp.Checked then
   QspMsg;
end;

procedure TfrmContest.edtSTXStrExit(Sender: TObject);
begin
  ChkSerialNrUpd(False); //just save it
end;

procedure TfrmContest.edtSTXExit(Sender: TObject);
begin
  ChkSerialNrUpd(False); //just save it
end;

procedure TfrmContest.edtSTXKeyPress(Sender: TObject; var Key: char);
begin
  if not (key in ['0'..'9', chr(VK_SPACE), chr(VK_DELETE), chr(VK_BACK),
    chr(VK_RIGHT), chr(VK_LEFT)]) then
    key := #0;
end;

procedure TfrmContest.FormCreate(Sender: TObject);
begin
  frmContest.KeyPreview := True;
  dmUtils.InsertContests(cmbContestName);
end;
procedure TfrmContest.SaveSettings;
var
  f       :integer;
begin
  dmUtils.SaveWindowPos(frmContest);

  cqrini.WriteBool('frmContest', 'DupeCheck', rbDupeCheck.Checked);
  cqrini.WriteBool('frmContest', 'NoMode4Dupe', rbNoMode4Dupe.Checked);
  cqrini.WriteBool('frmContest', 'IgnoreDupes', rbIgnoreDupes.Checked);
  cqrini.WriteString('frmContest', 'DupeFrom', DupeFromDate);
  cqrini.WriteBool('frmContest', 'MarkDupe', chkMarkDupe.Checked);

  cqrini.WriteBool('frmContest', 'SpaceIsTab', chkSpace.Checked);
  cqrini.WriteBool('frmContest', 'TrueRST', chkTrueRST.Checked);
  cqrini.WriteBool('frmContest', 'NRInc', chkNRInc.Checked);
  cqrini.WriteBool('frmContest', 'QSP', chkQsp.Checked);
  cqrini.WriteBool('frmContest', 'NoNR', chkNoNr.Checked);
  cqrini.WriteBool('frmContest', 'Loc', chkLoc.Checked);
  cqrini.WriteString('frmContest','MsgIsStr',chkLoc.Caption);
  cqrini.WriteInteger('frmContest','MsgIs',MsgIs);

  cqrini.WriteString('frmContest', 'STX', edtSTX.Text);
  cqrini.WriteString('frmContest', 'STXStr', edtSTXStr.Text);
  cqrini.WriteString('frmContest', 'ContestName', cmbContestName.Text);
  cqrini.WriteBool('frmContest', 'SP', chkSP.Checked);

  for f:=0 to 8 do
     cqrini.WriteBool('frmContest', 'CommonStatus'+IntToStr(f),popCommonStatus.Items[f].Checked);

end;
procedure TfrmContest.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Begin
   SaveSettings;
end;

procedure TfrmContest.FormHide(Sender: TObject);
begin
  frmNewQSO.gbContest.Visible := false;
  dmUtils.SaveWindowPos(frmContest);
  frmContest.Hide;
end;

procedure TfrmContest.FormShow(Sender: TObject);
var
  f: integer;

begin
  frmNewQSO.gbContest.Visible := true;
  dmUtils.LoadWindowPos(frmContest);

  rbDupeCheck.Checked := cqrini.ReadBool('frmContest', 'DupeCheck', True);
  rbNoMode4Dupe.Checked := cqrini.ReadBool('frmContest', 'NoMode4Dupe', False);
  rbIgnoreDupes.Checked := cqrini.ReadBool('frmContest', 'IgnoreDupes', False);
  DupeFromDate:= cqrini.ReadString('frmContest', 'DupeFrom', '1900-01-01');
  chkMarkDupe.Checked:= cqrini.ReadBool('frmContest', 'MarkDupe', True);

  chkSpace.Checked := cqrini.ReadBool('frmContest', 'SpaceIsTab', False);
  chkTrueRST.Checked := cqrini.ReadBool('frmContest', 'TrueRST', False);
  chkNRInc.Checked := cqrini.ReadBool('frmContest', 'NRInc', False);
  chkQsp.Checked := cqrini.ReadBool('frmContest', 'QSP', False);
  chkNoNr.Checked := cqrini.ReadBool('frmContest', 'NoNR', False);
  chkLoc.Checked := cqrini.ReadBool('frmContest', 'Loc', False);
  chkLoc.Caption:=cqrini.ReadString('frmContest','MsgIsStr','MSG is Grid');
  MsgIs:=cqrini.ReadInteger('frmContest','MsgIs',1); //defaults to MSG is Grid
  chkSP.Checked := cqrini.ReadBool('frmContest', 'SP', False);

  edtSTX.Text := cqrini.ReadString('frmContest', 'STX', '');
  edtSTXStr.Text := cqrini.ReadString('frmContest', 'STXStr', '');

  popSetMsg.Items[MsgIs].Checked:=true;

  InitInput;

  sbContest.Panels[0].Width := 450;
  sbContest.Panels[1].Width := 65;
  sbContest.Panels[2].Width := 65;
  sbContest.Panels[3].Width := 65;
  sbContest.Panels[4].Width := 20;
  lblSpeed.Caption:= frmNewQSO.sbNewQSO.Panels[4].Text;
  cmbContestName.Text := cqrini.ReadString('frmContest', 'ContestName','');
  btDupChkStart.Caption := 'from '+DupeFromDate;
  btDupChkStart.Visible:=not(rbIgnoreDupes.Checked);
  MWC40:=0;
  MWC80:=0;

  for f:=0 to 8 do
       popCommonStatus.Items[f].Checked:=cqrini.ReadBool('frmContest', 'CommonStatus'+IntToStr(f), True);

  MyAdif:= dmDXCC.id_country(cqrini.ReadString('Station', 'Call', ''), Now(), Mypfx, Mycont,  Mycountry, MyWAZ, Myposun, MyITU, Mylat, Mylong);
  mnuOwnCountryCount.Caption:=Mycont+' country count';
  mnuOwnCountryList.Caption:=Mycont+' country list';
  cmbContestNameExit(nil);  //updates status view

end;

procedure TfrmContest.MsgIsPopChk(nr:integer);
var i:integer ;
begin
   for i:=0 to popSetMsg.Items.Count-1 do
       popSetMsg.Items[i].Checked:=false;
   popSetMsg.Items[nr].Checked:=true;
end;

procedure TfrmContest.btnHelpClick(Sender : TObject);
begin
  ShowHelp
end;

procedure TfrmContest.gbStatusClick(Sender: TObject);
begin
    popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuQSOcountClick(Sender: TObject);   //0
begin
    popCommonStatus.Items[0].Checked:= not popCommonStatus.Items[0].Checked;
    popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuDXQSOCountClick(Sender: TObject); //1
begin
    popCommonStatus.Items[1].Checked:= not popCommonStatus.Items[1].Checked;
    popCommonStatus.PopUp;
end;
procedure TfrmContest.mnuCountyrCountAllClick(Sender: TObject); //2
begin
    popCommonStatus.Items[2].Checked:= not popCommonStatus.Items[2].Checked;
    popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuDXCountryCountClick(Sender: TObject); //3
begin
    popCommonStatus.Items[3].Checked:= not popCommonStatus.Items[3].Checked;
    popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuDXCountryListClick(Sender: TObject); //4
begin
    popCommonStatus.Items[4].Checked:= not popCommonStatus.Items[4].Checked;
    popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuOwnCountryCountClick(Sender: TObject); //5
begin
   popCommonStatus.Items[5].Checked:= not popCommonStatus.Items[5].Checked;
   popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuOwnCountryListClick(Sender: TObject);  //6
begin
   popCommonStatus.Items[6].Checked:= not popCommonStatus.Items[6].Checked;
   popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuMsgMultipCountClick(Sender: TObject);  //7
begin
   popCommonStatus.Items[7].Checked:= not popCommonStatus.Items[7].Checked;
   popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuMsgMultipListClick(Sender: TObject);  //8
begin
    popCommonStatus.Items[8].Checked:= not popCommonStatus.Items[8].Checked;
    popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuReSetAllClick(Sender: TObject);
var
    f: integer;
    b: boolean;
begin
  b:= not popCommonStatus.Items[0].Checked;
  for f:=0 to 8 do
    popCommonStatus.Items[f].Checked:=b;
  popCommonStatus.PopUp;
end;

procedure TfrmContest.mnuNameClick(Sender: TObject);
begin
  MsgIs:=0;
  chkLoc.Caption:='MSG is Name';
  MsgIsPopChk(MsgIs);
end;


procedure TfrmContest.mnuGridClick(Sender: TObject);
begin
  MsgIs:=1;
  chkLoc.Caption:='MSG is Grid';
  MsgIsPopChk(MsgIs);
end;

procedure TfrmContest.mnyIOTAClick(Sender: TObject);
begin
  MsgIs:=2;
  chkLoc.Caption:='MSG is IOTA';
  MsgIsPopChk(MsgIs);
end;

procedure TfrmContest.mnuStateClick(Sender: TObject);
begin
  MsgIs:=3;
  chkLoc.Caption:='MSG is Stat';
  MsgIsPopChk(MsgIs);
end;

procedure TfrmContest.mnuCountyClick(Sender: TObject);
begin
    MsgIs:=4;
    chkLoc.Caption:='MSG is Cnty';
    MsgIsPopChk(MsgIs);
end;

procedure TfrmContest.mnuAwardClick(Sender: TObject);
begin
  MsgIs:=5;
  chkLoc.Caption:='MSG is Awrd';
  MsgIsPopChk(MsgIs);
end;

procedure TfrmContest.mnuQSLviaClick(Sender: TObject);
begin
  MsgIs:=6;
  chkLoc.Caption:='MSG is Qvia';
  MsgIsPopChk(MsgIs);
end;

procedure TfrmContest.mnuCommentClick(Sender: TObject);
begin
  MsgIs:=7;
  chkLoc.Caption:='MSG is Cmnt';
  MsgIsPopChk(MsgIs);
end;

procedure TfrmContest.rbIgnoreDupesChange(Sender: TObject);
begin
  btDupChkStart.Visible:=not(rbIgnoreDupes.Checked);
end;

procedure TfrmContest.tmrESC2Timer(Sender: TObject);
begin
  EscFirstTime := True; //time for double esc passed
  tmrESC2.Enabled := False;
end;

procedure TfrmContest.InitInput;

begin
  edtRSTs.Text := '599';
  edtRSTr.Text := '599';

  if  (frmNewQSO.cmbMode.ItemIndex >=0) then
   case frmNewQSO.cmbMode.Items[frmNewQSO.cmbMode.ItemIndex] of
    'SSB','AM','FM' :  begin
                         edtRSTs.Text := '59';
                         edtRSTr.Text := '59';
                       end;
   end;

  if not ((edtSTX.Text <> '') and (RSTstx = ''))  then
    edtSTX.Text := RSTstx;

  edtSTXStr.Text := RSTstxAdd;
  edtSRX.Text := '';
  edtSRXStr.Text := '';
  edtCall.Font.Color:=clDefault;
  edtCall.Font.Style:= [];
  edtCall.Clear;
  EscFirstTime := True;

  SetTabOrders;
  frmContest.ShowOnTop;
  frmContest.SetFocus;
  edtCall.SetFocus;

  cmbContestNameExit(nil);   //updates status view
  ClearStatusBar;
end;

procedure TfrmContest.ChkSerialNrUpd(IncNr: boolean);   // do we need serial nr inc
var                                                    //otherwise just update memos
  stxLen, stxInt: integer;
  lZero: boolean;
  stx: string;

begin
  stx := trim(edtSTX.Text);

  if IncNr then
  begin
    stxlen := length(stx);
    if chkNRInc.Checked then //inc of number requested
    begin
      lZero := stx[1] = '0'; //do we have leading zero(es)
      if dmData.DebugLevel >= 1 then
        Writeln('Need inc number:', stx, ' Has leading zero:', lZero, ' len:', stxlen);
      if TryStrToInt(stx, stxint) then
      begin
        if dmData.DebugLevel >= 1 then
          Writeln('Integer is:', stxInt);
        Inc(stxInt);
        stx := IntToStr(stxInt);
        if dmData.DebugLevel >= 1 then
          Writeln('New number is:', stx);
        if (length(stx) < stxLen) and lZero then //pad with zero(es)
        begin
          //AddChar('0',stx,stxLen); // why does this NOT work???
          while length(stx) < stxlen do
            stx := '0' + stx;
          if dmData.DebugLevel >= 1 then
            Writeln('After leading zero(es) added:', stx);
        end;
      end;
    end;
  end;

  RSTstx := stx;
  RSTstxAdd := edtSTXStr.Text;

  if dmData.DebugLevel >= 1 then
    Writeln(' Inc number is: ', IncNr);
end;
procedure  TfrmContest.SetTabOrders;
begin
  TabStopAllOn;
  if not chkTabAll.Checked then
    begin
      //NRs no need to touch
      edtSTX.TabStop      := False;
      //"Qsp" adds MSGs, else drops
      edtSTXStr.TabStop:= chkQsp.Checked;
      //"No" drops NRr
      edtSRX.TabStop   := not chkNoNr.Checked;
      //"Tru" checked adds RST fields, else drops
      edtRSTs.TabStop  := chkTrueRST.Checked;
      edtRSTr.TabStop  := chkTrueRST.Checked;
    end;
end;

procedure  TfrmContest.TabStopAllOn;
//set all tabstops
Begin
    edtCall.TabStop     := True;
    edtCall.TabOrder    := 0;
    edtRSTs.TabStop     := True;
    edtRSTs.TabOrder    := 1;
    edtSTX.TabStop      := True;
    edtSTX.TabOrder     := 2;
    edtSTXStr.TabStop   := True;
    edtSTXStr.TabOrder  := 3;

    edtRSTr.TabStop     := True;
    edtRSTr.TabOrder    := 4;
    edtSRX.TabStop      := True;
    edtSRX.TabOrder     := 5;
    edtSRXStr.TabStop   := True;
    edtSRXStr.TabOrder  := 6;

    btSave.TabStop      := True;
    btSave.TabOrder     := 7;
    btClearQso.TabStop  := True;
    btClearQso.TabOrder := 8;

    rbDupeCheck.TabStop:=false;
    rbNoMode4Dupe.TabStop:=false;
    rbIgnoreDupes.TabStop:=false;
    btClearAll.TabStop:=false;
    chkTabAll.TabStop:=false;
    cmbContestName.TabStop:=false;
    btDupChkStart.TabStop:=False;
end;
procedure TfrmContest.QspMsg;
Begin
   try
    dmData.Q.Close;
    if dmData.trQ.Active then dmData.trQ.Rollback;
    dmData.Q.SQL.Text := 'SELECT srx_string FROM cqrlog_main ORDER BY qsodate DESC, time_on DESC LIMIT 1';
    dmData.trQ.StartTransaction;
    if dmData.DebugLevel >=1 then
      Writeln(dmData.Q.SQL.Text);
    dmData.Q.Open();
    edtSTXStr.Text := dmData.Q.Fields[0].AsString;
    dmData.Q.Close();
    dmData.trQ.Rollback;
   finally
     edtSTXStr.SetFocus;
     edtSTXStr.SelStart:=length(edtSTXStr.Text);
     edtSTXStr.SelLength:=0;
   end;
end;

procedure TfrmContest.ClearStatusBar;
var
  i : Integer;
begin
  for i:=0 to sbContest.Panels.Count-1 do
    sbContest.Panels.Items[i].Text := '';

end;

procedure TfrmContest.ShowStatusBarInfo;
begin
      sbContest.Panels.Items[0].Text := ExtractWord(1,Trim(frmNewQSO.mCountry.Text),[#$0A]);
      sbContest.Panels.Items[1].Text := 'WAZ: ' + frmNewQSO.lblWAZ.Caption;
      sbContest.Panels.Items[2].Text := 'ITU: ' + frmNewQSO.lblITU.Caption;
      sbContest.Panels.Items[3].Text := 'AZ: ' + frmNewQSO.lblAzi.Caption;
      sbContest.Panels.Items[4].Text := frmNewQSO.lblCont.Caption;
end;

procedure TfrmContest.SendCwFmacro(key:word);
Begin
  if Assigned(frmNewQSO.CWint) then
      frmNewQSO.CWint.SendText(dmUtils.GetCWMessage(
        dmUtils.GetDescKeyFromCode(Key),edtCall.Text,
      edtRSTs.Text, edtSTX.Text,edtSTXStr.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''));
end;

function TfrmContest.CheckDupe(call:string):boolean;
var
   dupe:integer;
Begin
   Result:=false;
   if not (rbIgnoreDupes.Checked) then
   begin
     //dupe check
     dupe := frmWorkedGrids.WkdCall(edtCall.Text, dmUtils.GetBandFromFreq(frmNewQSO.cmbFreq.Text) ,frmNewQSO.cmbMode.Text);
     // 1= wkd this band and mode
     // 2= wkd this band but NOT this mode
     if  ( (rbNoMode4Dupe.Checked) and (dupe = 1) )
      or ( (not rbNoMode4Dupe.Checked) and ((dupe = 1) or (dupe=2)) )then
        Begin
          edtCall.Font.Color:=clRed;
          edtCall.Font.Style:= [fsBold];
          Result:=true;
        end
     else
         Begin
          edtCall.Font.Color:=clDefault;
          edtCall.Font.Style:= [];
         end;
    end;
end;

procedure  TfrmContest.MWCStatus;
var
   Mlist         : array [1..2] of string[40];
   Band          : integer;
   QSOc,MULc     : array [1..2] of integer;
   f,p           : integer;
   M             : char;
   bands         : array [1..2] of string=('80M','40M');
Begin
    mStatus.Clear;
    for band:=1 to 2 do
      begin
       try
         MULc[band]:=0;
          Mlist[band]:='....................................' ; //A-Z0-9
          dmData.CQ.Close;
          if dmData.trCQ.Active then dmData.trCQ.Rollback;
          dmData.CQ.SQL.Text :=
               'SELECT ASCII(MID(callsign,LENGTH(callsign),1)) AS SuffixEnd FROM cqrlog_main WHERE contestname='+
               QuotedStr(cmbContestName.Text)+' AND band='+QuotedStr(bands[band])+' AND mode='+QuotedStr('CW');

          if dmData.DebugLevel >=1 then
                                       Writeln(dmData.CQ.SQL.Text);
          dmData.CQ.Open();
          QSOc[band]:=0;
          while not dmData.CQ.EOF do
          Begin
            f:= dmData.CQ.FieldByName('SuffixEnd').AsInteger;
            if f>0 then
             Begin
               inc(QSOc[band]);
               case f of
                    65..90 : p:=0;
                    48..57 : p:=43;
                 else
                   p:=-1;
               end;
               if p>-1 then
                begin
                 if Mlist[band][f+p-64]='.' then
                  Begin
                    inc(MULc[band]);
                    Mlist[band][f+p-64]:=char(f);
                  end;
                end;
             end;
             dmData.CQ.Next;
            end;
          finally
           dmData.CQ.Close();
           dmData.trCQ.Rollback;
           case band of
            1 : MWC80:= (MULc[band]*QSOc[band]);
            2 : MWC40:= (MULc[band]*QSOc[band]);
           end;
           mStatus.Lines.Add(bands[band]+'    Multip: '+Mlist[band]+'   Count:'+IntToStr(MULc[band])+
           '   QSOs:' + IntToStr(QSOc[band])+ '   Score:' + IntToStr(MULc[band]*QSOc[band]));
          end;
      end;
    mStatus.Lines.Add('-----------------------------------------------------------');
    mStatus.Lines.Add(' Total score:' + IntToStr(MWC80+MWC40));
end;

procedure  TfrmContest.NACStatus;
var
    QSOs,
    LOCs,
    QRB,
    MaxQRB,
    Points,
    QSOPoints,
    LocPoints: integer;
    LOCList,
    distance: string;
Begin

    QSOs:=0;
    LOCs:=0;
    MaxQRB:=0;
    Points:=0;
    LocPoints:=0;
    LocList:='';
    mStatus.Clear;

    //QSO count  (28MHz and up)
    //--------------------------------------------------------------
    dmData.CQ.Close;
    if dmData.trCQ.Active then dmData.trCQ.Rollback;
    dmData.CQ.SQL.Text :=
        'SELECT  COUNT(callsign) AS Qcount FROM cqrlog_main WHERE contestname='+ QuotedStr(cmbContestName.Text)+
         ' AND freq > 27.99999';
    if dmData.DebugLevel >=1 then
                                     Writeln(dmData.CQ.SQL.Text);
    dmData.CQ.Open();
    QSOs:= dmData.CQ.FieldByName('Qcount').AsInteger;

    //Points count  (up to 47GHz)
    //--------------------------------------------------------------
    dmData.CQ.Close;
    if dmData.trCQ.Active then dmData.trCQ.Rollback;
    dmData.CQ.SQL.Text :=
        'SELECT  my_loc,loc,band FROM cqrlog_main WHERE contestname='+ QuotedStr(cmbContestName.Text)+
         ' AND freq > 27.99999';
    if dmData.DebugLevel >=1 then
                                     Writeln(dmData.CQ.SQL.Text);
    dmData.CQ.Open();
    dmData.CQ.First;
    while not dmData.CQ.EOF do
      begin
         distance:=frmMain.CalcQrb(dmData.CQ.FieldByName('my_loc').AsString,dmData.CQ.FieldByName('loc').AsString,False);
         if distance<>'' then
          Begin
            QRB:=StrToInt(distance);
            if QRB < 10 then
                     QSOPoints := 10
               else
                     QSOPoints := QRB;

            case dmData.CQ.FieldByName('band').AsString of
              '13CM'    :  QSOPoints:=QSOPoints*2;
              '9CM'     :  QSOPoints:=QSOPoints*3;
              '6CM'     :  QSOPoints:=QSOPoints*4;
              '3CM'     :  QSOPoints:=QSOPoints*5;
              '1.25CM'  :  QSOPoints:=QSOPoints*6;
              '6MM'     :  QSOPoints:=QSOPoints*7;
             end;

            if QRB > MaxQRB then
                     MaxQRB :=  QRB;

            Points:=Points+QSOPoints;
          end;
         dmData.CQ.Next;
      end;

    //list of different main locators (localtor multipliers)
    //--------------------------------------------------------------
    dmData.CQ.Close;
    if dmData.trCQ.Active then dmData.trCQ.Rollback;
    dmData.CQ.SQL.Text :=
        'SELECT DISTINCT(SUBSTRING(UPPER(loc),1,4)) AS MainLoc FROM cqrlog_main WHERE contestname='+ QuotedStr(cmbContestName.Text);
    if dmData.DebugLevel >=1 then
                                     Writeln(dmData.CQ.SQL.Text);
     dmData.CQ.Open();
     dmData.CQ.First;
     while not dmData.CQ.EOF do
      begin
       if dmData.CQ.FieldByName('MainLoc').AsString<>'' then
        Begin
         LocList:= LocList+dmData.CQ.FieldByName('Mainloc').AsString+',';
         LocPoints:= LocPoints + 500;
         inc(LOCs);
        end;
        dmData.CQ.Next;
      end;
     dmData.CQ.Close;

     mStatus.Lines.Add('QSO count: '+IntToStr(QSOs));
     mStatus.Lines.Add('QSO points: '+IntToStr(Points));
     mStatus.Lines.Add('-----------------------------------------------------------');
     mStatus.Lines.Add('Locator count: '+IntToStr(LOCs));
     mStatus.Lines.Add('Locator points: '+IntToStr(LocPoints));
     mStatus.Lines.Add('Locator list: '+LocList);
     mStatus.Lines.Add('-----------------------------------------------------------');
     mStatus.Lines.Add('Total points: '+ IntToStr(Points+LocPoints)+'          Max QRB: '+IntToStr(MaxQRB));
end;

procedure  TfrmContest.CommonStatus;
var
  DXList,
  SRXSList,
  MyCountList   : string;

Begin
    DXList:='';
    SRXSList:='';
    MyCountList:='';

    mStatus.Clear;

    if popCommonStatus.Items[0].Checked or popCommonStatus.Items[2].Checked  then
     Begin
        //total counts  of QSOs, countries and message multipliers
        //--------------------------------------------------------------
        dmData.CQ.Close;
        if dmData.trCQ.Active then dmData.trCQ.Rollback;
        dmData.CQ.SQL.Text :=
           'SELECT COUNT(callsign) AS QSOs, COUNT(DISTINCT(adif)) AS Countries,'+
           'COUNT(DISTINCT(UPPER(srx_string))) AS Msgs FROM cqrlog_main WHERE contestname='+
             QuotedStr(cmbContestName.Text);

        if dmData.DebugLevel >=1 then
                                     Writeln(dmData.CQ.SQL.Text);
        dmData.CQ.Open();
        if popCommonStatus.Items[0].Checked then
           mStatus.Lines.Add('QSO count: '+ dmData.CQ.FieldByName('QSOs').AsString);

        if popCommonStatus.Items[2].Checked then
           mStatus.Lines.Add('Country count (all): '+dmData.CQ.FieldByName('Countries').AsString);
      end;

    //DX QSO count
    //--------------------------------------------------------------
    if popCommonStatus.Items[1].Checked then
    Begin
      dmData.CQ.Close;
      if dmData.trCQ.Active then dmData.trCQ.Rollback;
      dmData.CQ.SQL.Text :=
          'SELECT COUNT(callsign) AS DXs  FROM cqrlog_main WHERE contestname='+
           QuotedStr(cmbContestName.Text)+' AND cont<>'+QuotedStr(mycont);
      if dmData.DebugLevel >=1 then
                                       Writeln(dmData.CQ.SQL.Text);
      dmData.CQ.Open();
      mStatus.Lines.Add('DX QSO count: '+ dmData.CQ.FieldByName('DXs').AsString);
    end;

    //DX country count
    //--------------------------------------------------------------
    if popCommonStatus.Items[3].Checked then
    Begin
      dmData.CQ.Close;
      if dmData.trCQ.Active then dmData.trCQ.Rollback;
      dmData.CQ.SQL.Text :=
          'SELECT COUNT(DISTINCT(adif)) AS DXCntrs  FROM cqrlog_main WHERE contestname='+
           QuotedStr(cmbContestName.Text)+' AND cont<>'+QuotedStr(mycont);
      if dmData.DebugLevel >=1 then
                                       Writeln(dmData.CQ.SQL.Text);
      dmData.CQ.Open();
      mStatus.Lines.Add('DX Country count : '+dmData.CQ.FieldByName('DXCntrs').AsString);
    end;

     //list of DX country prefixes
     //--------------------------------------------------------------
    if popCommonStatus.Items[4].Checked then
    begin
      dmData.CQ.Close;
      if dmData.trCQ.Active then dmData.trCQ.Rollback;
      dmData.CQ.SQL.Text :=
         'SELECT DISTINCT(pref) FROM cqrlog_common.dxcc_ref RIGHT JOIN cqrlog_main ON '+
         'cqrlog_common.dxcc_ref.adif = cqrlog_main.adif WHERE contestname='+
           QuotedStr(cmbContestName.Text)+' AND cqrlog_main.cont<>'+QuotedStr(mycont);
      if dmData.DebugLevel >=1 then
                                       Writeln(dmData.CQ.SQL.Text);
      dmData.CQ.Open();
       dmData.CQ.First;
       while not dmData.CQ.EOF do
        begin
         if dmData.CQ.FieldByName('pref').AsString<>'' then
           DXList:= DXList+dmData.CQ.FieldByName('pref').AsString+','
          else
           DXList:= DXList+'?,';
          dmData.CQ.Next;
        end;
        mStatus.Lines.Add('DX Country list : '+DXList);
     end;

    //Own continent country count
    //--------------------------------------------------------------
    if popCommonStatus.Items[5].Checked then
    begin
      dmData.CQ.Close;
      if dmData.trCQ.Active then dmData.trCQ.Rollback;
      dmData.CQ.SQL.Text :=
          'SELECT COUNT(DISTINCT(adif)) AS MYCntrs  FROM cqrlog_main WHERE contestname='+
           QuotedStr(cmbContestName.Text)+' AND cont='+QuotedStr(Mycont);
      if dmData.DebugLevel >=1 then
                                       Writeln(dmData.CQ.SQL.Text);
      dmData.CQ.Open();
      mStatus.Lines.Add(mycont+' Country count : '+dmData.CQ.FieldByName('MYCntrs').AsString);
    end;

     //list of own continent country prefixes
     //--------------------------------------------------------------
    if popCommonStatus.Items[6].Checked then
    begin
      dmData.CQ.Close;
      if dmData.trCQ.Active then dmData.trCQ.Rollback;
      dmData.CQ.SQL.Text :=
      'SELECT DISTINCT(pref) FROM cqrlog_common.dxcc_ref RIGHT JOIN cqrlog_main ON '+
      'cqrlog_common.dxcc_ref.adif = cqrlog_main.adif WHERE contestname='+
        QuotedStr(cmbContestName.Text)+' AND cqrlog_main.cont='+QuotedStr(Mycont);
       if dmData.DebugLevel >=1 then
                                        Writeln(dmData.CQ.SQL.Text);
       dmData.CQ.Open();
        dmData.CQ.First;
        while not dmData.CQ.EOF do
         begin
          if dmData.CQ.FieldByName('pref').AsString<>'' then
            MyCountList:= MyCountList+dmData.CQ.FieldByName('pref').AsString+','
           else
            MyCountList:= MyCountList+'?,';
           dmData.CQ.Next;
         end;
      mStatus.Lines.Add(mycont+' Country list : '+MyCountList);
     end;

    //Msg multiplier (srx_string) count
    //--------------------------------------------------------------
    if popCommonStatus.Items[7].Checked then
     begin
      dmData.CQ.Close;
        if dmData.trCQ.Active then dmData.trCQ.Rollback;
        dmData.CQ.SQL.Text :=
           'SELECT COUNT(DISTINCT(UPPER(srx_string))) AS Msgs FROM cqrlog_main WHERE contestname='+
             QuotedStr(cmbContestName.Text)+ ' AND srx_string<>""';

        if dmData.DebugLevel >=1 then
                                     Writeln(dmData.CQ.SQL.Text);
      dmData.CQ.Open();
      mStatus.Lines.Add('Msg multipliers: '+dmData.CQ.FieldByName('Msgs').AsString);
     end;


    //list of different srx_strings (msg multipliers)
    //--------------------------------------------------------------
    if popCommonStatus.Items[8].Checked then
    begin
      dmData.CQ.Close;
      if dmData.trCQ.Active then dmData.trCQ.Rollback;
      dmData.CQ.SQL.Text :=
          'SELECT DISTINCT(UPPER(srx_string)) AS srx_msg FROM cqrlog_main WHERE contestname='+
           QuotedStr(cmbContestName.Text);
      if dmData.DebugLevel >=1 then
                                       Writeln(dmData.CQ.SQL.Text);
       dmData.CQ.Open();
       dmData.CQ.First;
       while not dmData.CQ.EOF do
        begin
         if dmData.CQ.FieldByName('srx_msg').AsString<>'' then
           SRXSList:= SRXSList+dmData.CQ.FieldByName('srx_msg').AsString+',';
          dmData.CQ.Next;
        end;
       mStatus.Lines.Add('Msg multipliers list: '+SRXSList);
     end;

    dmData.CQ.Close;

end;

end.

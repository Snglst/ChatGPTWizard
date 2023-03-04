{****************************************************}
{                                                    }
{    This unit contains a frame that will be         }
{    used in dockable form.                          }
{    Auhtor: Ali Dehbansiahkarbon(adehban@gmail.com) }
{                                                    }
{****************************************************}
unit UChatGPTQFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Clipbrd,
  UChatGPTThread, UChatGPTSetting, UChatGPTLexer, System.Generics.Collections,
  XSuperObject, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons, Data.DB, System.DateUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, UHistory,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Phys, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLite, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, FireDAC.VCLUI.Wait, FireDAC.Comp.UI;

type
  TClassList = TObjectDictionary<string, TStringList>;

  TObDicHelper = class helper for TClassList
  public
    procedure FillTreeView(var ATree: TTreeView);
  end;

  TFram_Question = class(TFrame)
    pnlMain: TPanel;
    Lbl_Question: TLabel;
    Lbl_Answer: TLabel;
    pnlTop: TPanel;
    Btn_Clipboard: TButton;
    Btn_Ask: TButton;
    pmMemo: TPopupMenu;
    CopytoClipboard1: TMenuItem;
    Btn_Clear: TButton;
    chk_AutoCopy: TCheckBox;
    pnlQuestion: TPanel;
    pnlAnswer: TPanel;
    mmoQuestion: TMemo;
    pnlBottom: TPanel;
    mmoAnswer: TMemo;
    splitter: TSplitter;
    pnlCenter: TPanel;
    pgcMain: TPageControl;
    tsChatGPT: TTabSheet;
    tsClassView: TTabSheet;
    pmClassOperations: TPopupMenu;
    CreateTestUnit1: TMenuItem;
    ConverttoSingletone1: TMenuItem;
    Findpossibleproblems1: TMenuItem;
    ImproveNaming1: TMenuItem;
    Rewriteinmoderncodingstyle1: TMenuItem;
    CrreateInterface1: TMenuItem;
    ConverttoGenericType1: TMenuItem;
    CustomCommand1: TMenuItem;
    Convertto1: TMenuItem;
    C1: TMenuItem;
    Java1: TMenuItem;
    Python1: TMenuItem;
    Javascript1: TMenuItem;
    Go1: TMenuItem;
    C3: TMenuItem;
    C2: TMenuItem;
    Rust1: TMenuItem;
    pnlClasses: TPanel;
    pnlPredefinedCmdAnswer: TPanel;
    splClassView: TSplitter;
    mmoPredefinedCmdAnswer: TMemo;
    tsHistory: TTabSheet;
    pnlHistoryTop: TPanel;
    pnlHistoryBottom: TPanel;
    splHistory: TSplitter;
    mmoHistoryDetail: TMemo;
    FDConnection: TFDConnection;
    DSHistory: TDataSource;
    FDQryHistory: TFDQuery;
    FDQryHistoryHID: TFDAutoIncField;
    FDQryHistoryQuestion: TWideMemoField;
    FDQryHistoryAnswer: TWideMemoField;
    FDQryHistoryDate: TLargeintField;
    WriteXMLdoc1: TMenuItem;
    pmGrdHistory: TPopupMenu;
    ReloadHistory1: TMenuItem;
    procedure Btn_AskClick(Sender: TObject);
    procedure Btn_ClipboardClick(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure mmoQuestionKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Btn_ClearClick(Sender: TObject);
    procedure CreateTestUnit1Click(Sender: TObject);
    procedure tvOnChange(Sender: TObject; Node: TTreeNode);
    procedure pmClassOperationsPopup(Sender: TObject);
    procedure ConverttoSingletone1Click(Sender: TObject);
    procedure Findpossibleproblems1Click(Sender: TObject);
    procedure ImproveNaming1Click(Sender: TObject);
    procedure Rewriteinmoderncodingstyle1Click(Sender: TObject);
    procedure CrreateInterface1Click(Sender: TObject);
    procedure ConverttoGenericType1Click(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure Java1Click(Sender: TObject);
    procedure Python1Click(Sender: TObject);
    procedure Javascript1Click(Sender: TObject);
    procedure C2Click(Sender: TObject);
    procedure Go1Click(Sender: TObject);
    procedure Rust1Click(Sender: TObject);
    procedure CustomCommand1Click(Sender: TObject);
    procedure C3Click(Sender: TObject);
    procedure pgcMainChange(Sender: TObject);
    procedure FDQryHistoryQuestionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure FDQryHistoryAfterScroll(DataSet: TDataSet);
    procedure FDQryHistoryDateGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure GridResize(Sender: TObject);
    procedure DrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure CloseBtnClick(Sender: TObject);
    procedure WriteXMLdoc1Click(Sender: TObject);
    procedure ReloadHistory1Click(Sender: TObject);
  private
    FTrd: TExecutorTrd;
    FPrg: TProgressBar;
    FClassList: TClassList;
    FClassTreeView: TTreeView;
    FCellCloseBtn: TSpeedButton;
    FHistoryGrid: THistoryDBGrid;
    procedure CopyToClipBoard;
    procedure CreateProgressbar;
    procedure CallThread(APrompt: string);
  public
    procedure InitialFrame;
    procedure TerminateThred;
    procedure ReloadClassList(AClassList: TClassList);
    procedure LoadHistory;
    procedure AddToHistory(AQuestion, AAnswer: string);
    procedure OnUpdateMessage(var Msg: TMessage); message WM_UPDATE_MESSAGE;
    procedure OnProgressMessage(var Msg: TMessage); message WM_PROGRESS_MESSAGE;
  end;

implementation

{$R *.dfm}

procedure TFram_Question.AddToHistory(AQuestion, AAnswer: string);
begin
  if (TSingletonSettingObj.Instance.HistoryEnabled) and
     (FDConnection.Connected) and (FDQryHistory.Active) then
  begin
    FDQryHistory.Append;
    FDQryHistoryQuestion.AsString := AQuestion;
    FDQryHistoryAnswer.AsString := AAnswer;
    FDQryHistoryDate.AsLargeInt := DateTimeToUnix(Date);
    FDQryHistory.Post;
  end;
end;

procedure TFram_Question.Btn_AskClick(Sender: TObject);
begin
  if mmoQuestion.Lines.Text.Trim.IsEmpty then
  begin
    ShowMessage('Really?!' + #13 + 'You need to type a question first.');
    if mmoQuestion.CanFocus then
      mmoQuestion.SetFocus;

    Exit;
  end;
  CallThread(mmoQuestion.Lines.Text);
end;

procedure TFram_Question.Btn_ClearClick(Sender: TObject);
begin
  mmoQuestion.Lines.Clear;
  mmoAnswer.Lines.Clear;
end;

procedure TFram_Question.Btn_ClipboardClick(Sender: TObject);
begin
  CopyToClipBoard;
end;

procedure TFram_Question.C1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this Delphi Code to C#: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.C2Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this Delphi Code to C++: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.C3Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this Delphi Code to C: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.CallThread(APrompt: string);
var
  LvApiKey: string;
  LvUrl: string;
  LvModel: string;
  LvQuestion: string;
  LvMaxToken: Integer;
  LvTemperature: Integer;
  LvSetting: TSingletonSettingObj;
begin
  Cs.Enter;
  LvSetting := TSingletonSettingObj.Instance;
  LvApiKey := LvSetting.ApiKey;
  LvUrl := LvSetting.URL;
  LvModel := LvSetting.Model;
  LvMaxToken := LvSetting.MaxToken;
  LvTemperature := LvSetting.Temperature;
  LvQuestion := APrompt;
  FTrd := TExecutorTrd.Create(Self.Handle, LvApiKey, LvModel, LvQuestion, LvUrl,
    LvMaxToken, LvTemperature, LvSetting.ProxySetting.Active,
    LvSetting.ProxySetting.ProxyHost, LvSetting.ProxySetting.ProxyPort,
    LvSetting.ProxySetting.ProxyUsername, LvSetting.ProxySetting.ProxyPassword);
  FTrd.Start;
  Cs.Leave;

  if Assigned(pgcMain) then
    pgcMain.Enabled := False;
end;

procedure TFram_Question.CloseBtnClick(Sender: TObject);
begin
  FDQryHistory.Delete;
end;

procedure TFram_Question.ConverttoGenericType1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this class to generic class in Delphi: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.ConverttoSingletone1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this class to singleton in Delphi: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.CopyToClipBoard;
begin
  if Assigned(pgcMain) then
  begin
    if pgcMain.ActivePage = tsChatGPT then
      Clipboard.SetTextBuf(pwidechar(mmoAnswer.Lines.Text))
    else if pgcMain.ActivePage = tsClassView then
      Clipboard.SetTextBuf(pwidechar(mmoPredefinedCmdAnswer.Lines.Text))
    else if pgcMain.ActivePage = tsHistory then
      Clipboard.SetTextBuf(pwidechar(mmoHistoryDetail.Lines.Text));
  end
  else
    Clipboard.SetTextBuf(pwidechar(mmoAnswer.Lines.Text));
end;

procedure TFram_Question.CopytoClipboard1Click(Sender: TObject);
begin
  CopyToClipBoard;
end;

// progressbar is not working properly inside the docking form,
// had to create and destroy each time!
procedure TFram_Question.CreateProgressbar;
begin
  FPrg := TProgressBar.Create(Self);
  FPrg.Parent := pnlBottom;
  with FPrg do
  begin
    Left := 11;
    Top := 10;
    Width := 120;
    Height := 16;
    Anchors := [akLeft, akBottom];
    Style := pbstMarquee;
    TabOrder := 1;
    Visible := True;
  end;
end;

procedure TFram_Question.CreateTestUnit1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Create a Test Unit for the following class in Delphi: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.CrreateInterface1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Create necessary interfaces for this Class in Delphi: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.CustomCommand1Click(Sender: TObject);
var
  AQuestion: string;
begin
  FClassTreeView.HideSelection := False;
  InputQuery('Custom Command(use @Class to represent the selected class)', 'Write your command here', AQuestion);
  if AQuestion.Trim = '' then
    Exit;

  if AQuestion.ToLower.Trim.Contains('@class') then
  begin
    AQuestion := StringReplace(AQuestion, '@class', ' ' + FClassList.Items[FClassTreeView.Selected.Text].Text + ' ', [rfReplaceAll, rfIgnoreCase]);
  end
  else
    AQuestion := AQuestion + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text;

  CallThread(AQuestion);
end;

procedure TFram_Question.DrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
Var
  DataRect: TRect;
begin
  if (not FDQryHistoryHID.IsNull) and (Column.Title.Caption = '^_^') Then
  begin
    DataRect := FHistoryGrid.CellRect(Column.Index + 1, FHistoryGrid.Row);
    If FCellCloseBtn.Parent <> FHistoryGrid Then
      FCellCloseBtn.Parent := FHistoryGrid;

    FCellCloseBtn.Left := DataRect.Left +  (DataRect.Right - DataRect.Left - FCellCloseBtn.Width) div 2;

    If FCellCloseBtn.Top <> DataRect.Top Then
      FCellCloseBtn.Top := DataRect.Top;

    // Make sure the button's height fits in row.
    If FCellCloseBtn.Height <> (DataRect.Bottom - DataRect.Top) Then
      FCellCloseBtn.Height := DataRect.Bottom - DataRect.Top;
  end;
end;

procedure TFram_Question.FDQryHistoryAfterScroll(DataSet: TDataSet);
begin
  mmoHistoryDetail.Lines.Clear;
  mmoHistoryDetail.Lines.Add(FDQryHistoryAnswer.AsString);
end;

procedure TFram_Question.FDQryHistoryDateGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if not Sender.IsNull then
    Text := DateTimeToStr(UnixToDateTime(Sender.AsLargeInt));
end;

procedure TFram_Question.FDQryHistoryQuestionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if not Sender.IsNull then
    Text := Sender.AsString;
end;

procedure TFram_Question.Findpossibleproblems1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('What is wrong with this class in Delphi? : ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.Go1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this Delphi Code to the GO programming language: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.GridResize(Sender: TObject);
begin
  FHistoryGrid.FitGrid;
end;

procedure TFram_Question.ImproveNaming1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Improve naming of the members of this class in Delphi: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.InitialFrame;
begin
  Align := alClient;

  FCellCloseBtn := TSpeedButton.Create(Self);
  FCellCloseBtn.Glyph.LoadFromResourceName(HInstance, 'CLOSE');
  FCellCloseBtn.OnClick := CloseBtnClick;

  FHistoryGrid := THistoryDBGrid.Create(Self);
  with FHistoryGrid do
  begin
    Parent := pnlHistoryTop;
    Align := alClient;
    DataSource := DSHistory;
    Options := [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack];

    with Columns.Add do
    begin
      Alignment := taCenter;
      Expanded := False;
      FieldName := 'Question';
      Title.Alignment := taCenter;
      Visible := True;
    end;

    with Columns.Add do
    begin
      Alignment := taCenter;
      Expanded := False;
      FieldName := 'Date';
      Title.Alignment := taCenter;
      Width := 60;
      Visible := True;
    end;

    with Columns.Add do
    begin
      Title.Caption := '^_^';
      Alignment := taCenter;
      Title.Alignment := taCenter;
      Width := 25;
      Visible := True;
    end;

    OnResize := GridResize;
    OnDrawColumnCell := DrawColumnCell;
  end;
end;

procedure TFram_Question.Java1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this Delphi Code to Java: ' + #13 + FClassList.Items [FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.Javascript1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this Delphi Code to Javascript: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.mmoQuestionKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Ord(Key) = 13) then
    Btn_Ask.Click;
end;

procedure TFram_Question.OnProgressMessage(var Msg: TMessage);
begin
  if Msg.WParam <> 0 then
    CreateProgressbar
  else
    FPrg.Visible := False;

  Btn_Ask.Enabled := Msg.WParam = 0;
end;

procedure TFram_Question.OnUpdateMessage(var Msg: TMessage);
begin
  try
    if Assigned(pgcMain) then
    begin
      pgcMain.Enabled := True;

      if pgcMain.ActivePage = tsChatGPT then
      begin
        mmoAnswer.Lines.Clear;
        mmoAnswer.Lines.Add(string(Msg.WParam));

        AddToHistory(mmoQuestion.Lines.Text, mmoAnswer.Lines.Text);
      end
      else if pgcMain.ActivePage = tsClassView then
      begin
        mmoPredefinedCmdAnswer.Lines.Clear;
        mmoPredefinedCmdAnswer.Lines.Add(string(Msg.WParam));
      end;
    end
    else
    begin
      mmoAnswer.Lines.Clear;
      mmoAnswer.Lines.Add(string(Msg.WParam));
      AddToHistory(mmoQuestion.Lines.Text, mmoAnswer.Lines.Text);
    end;

    if chk_AutoCopy.Checked then
      CopyToClipBoard;
  finally
    FPrg.Free; // remove progressbar
  end;
end;

procedure TFram_Question.pgcMainChange(Sender: TObject);
begin
  if pgcMain.ActivePage = tsClassView then
    ReloadClassList(FClassList);

  if (pgcMain.ActivePage = tsHistory) and (TSingletonSettingObj.Instance.ShouldReloadHistory) then
  begin
    LoadHistory;
    TSingletonSettingObj.Instance.ShouldReloadHistory := False;
  end;
end;

procedure TFram_Question.pmClassOperationsPopup(Sender: TObject);
begin
  FClassTreeView.OnChange(FClassTreeView, FClassTreeView.Selected);
  if FClassTreeView.Selected = FClassTreeView.TopItem then
    keybd_event(VK_ESCAPE, Mapvirtualkey(VK_ESCAPE, 0), 0, 0);
end;

procedure TFram_Question.Python1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this Delphi Code to Pyhton: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.ReloadClassList(AClassList: TClassList);
var
  LvLexer: TcpLexer;
begin
  FClassList := AClassList;
  FClassTreeView := TTreeView.Create(tsClassView);
  with FClassTreeView do
  begin
    Parent := pnlClasses;
    Align := alClient;
    AlignWithMargins := True;
    Indent := 19;
    TabOrder := 0;
    RightClickSelect := True;
    PopupMenu := pmClassOperations;
    OnChange := tvOnChange;
  end;

  LvLexer := TcpLexer.Create(FClassList);
  try
    LvLexer.Reload;
    FClassList.FillTreeView(FClassTreeView);
    mmoPredefinedCmdAnswer.Lines.Clear;
  finally
    LvLexer.Free;
  end;
end;

procedure TFram_Question.ReloadHistory1Click(Sender: TObject);
begin
  LoadHistory;
end;

procedure TFram_Question.LoadHistory;
begin
  if FileExists(TSingletonSettingObj.Instance.GetHistoryFullPath) then
  begin
    try
      FDConnection.Close;
      FDConnection.Params.Clear;
      FDConnection.Params.Add('DriverID=SQLite');
      FDConnection.Params.Add('Database=' + TSingletonSettingObj.Instance.GetHistoryFullPath);
      FDConnection.Open;
      FDQryHistory.Open;
    except on E: Exception do
      ShowMessage('SQLite Connection didn''t established.' + #13 + 'Error: ' + E.Message);
    end;
  end;
end;

procedure TFram_Question.Rewriteinmoderncodingstyle1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Rewrite this class with modern coding style in Delphi: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.Rust1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Convert this Delphi Code to Rust programming language: ' + #13 + FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

procedure TFram_Question.TerminateThred;
begin
  if Assigned(FTrd) then
    FTrd.Terminate;
end;

procedure TFram_Question.tvOnChange(Sender: TObject; Node: TTreeNode);
begin
  mmoPredefinedCmdAnswer.Lines.Clear;
  mmoPredefinedCmdAnswer.ScrollBars := TScrollStyle.ssNone;
  if Node <> FClassTreeView.TopItem then
    mmoPredefinedCmdAnswer.Lines.Add(FClassList.Items[Node.Text].Text);
  mmoPredefinedCmdAnswer.ScrollBars := TScrollStyle.ssVertical;
end;

procedure TFram_Question.WriteXMLdoc1Click(Sender: TObject);
begin
  if FClassTreeView.Selected <> FClassTreeView.TopItem then
    CallThread('Write Documentation using inline XML based comments for this class in Delphi: ' + #13 +
                FClassList.Items[FClassTreeView.Selected.Text].Text);
end;

{ TObDicHelper }
procedure TObDicHelper.FillTreeView(var ATree: TTreeView);
var
  LvNode: TTreeNode;
  LvKey: string;
begin
  if Assigned(ATree) and (Self.Count > 0) then
  begin
    try
      LvNode := ATree.Items.Add(nil, 'Classes');
      for LvKey in Self.Keys do
        ATree.Items.AddChild(LvNode, LvKey);
    except
    end;

    ATree.AutoExpand := True;
    ATree.FullExpand;
  end;
end;

end.
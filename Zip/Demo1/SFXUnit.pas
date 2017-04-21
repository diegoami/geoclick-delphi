unit sfxunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ZipMstr, Buttons;

type
  TMakeSFX = class( TForm )
    Panel1:           TPanel;
    Panel2:           TPanel;
    CmdLineCB:        TCheckBox;
    FileListCB:       TCheckBox;
    HideOverWriteCB:  TCheckBox;
    DfltOverWriteGrp: TRadioGroup;
    CaptionEdit:      TEdit;
    DirectoryEdit:    TEdit;
    CommandEdit:      TEdit;
    Label1:           TLabel;
    Label2:           TLabel;
    Label3:           TLabel;
    Label4:           TLabel;
    Label5:           TLabel;
    Label6:           TLabel;
    Label7:           TLabel;
    Label8:           TLabel;
    ExecBut:          TButton;
    CancelBut:        TButton;
    BitBtn1:          TBitBtn;
    AutoRunCB: TCheckBox;

    procedure FormCreate( Sender: TObject );
    procedure ExecButClick( Sender: TObject );
    procedure BitBtn1Click( Sender: TObject );
    procedure CancelButClick( Sender: TObject );
  end;

var
  MakeSFX: TMakeSFX;

implementation

uses mainunit;

{$R *.DFM}

procedure TMakeSFX.ExecButClick( Sender: TObject );
begin
   with Mainform.ZipMaster1 do
   begin
      if CmdLineCB.Checked then
         SFXOptions := SFXOptions + [SFXAskCmdLine]
      else
         SFXOptions := SFXOptions - [SFXAskCmdLine];
      if FileListCB.Checked then
         SFXOptions := SFXOptions + [SFXAskFiles]
      else
         SFXOptions := SFXOptions - [SFXAskFiles];
      if HideOverWriteCB.Checked then
         SFXOptions := SFXOptions + [SFXHideOverWriteBox]
      else
         SFXOptions := SFXOptions - [SFXHideOverWriteBox];
      if AutoRunCB.Checked then
         SFXOptions := SFXOptions + [SFXAutoRun]
      else
         SFXOptions := SFXOptions - [SFXAutoRun];

      if DfltOverWriteGrp.ItemIndex = 0 then
         SFXOverWriteMode := ovrConfirm;
      if DfltOverWriteGrp.ItemIndex = 1 then
         SFXOverWriteMode := ovrAlways;
      if DfltOverWriteGrp.ItemIndex = 2 then
         SFXOverWriteMode := ovrNever;

      SFXCaption     := CaptionEdit.Text;
      SFXDefaultDir  := DirectoryEdit.Text;
      SFXCommandLine := CommandEdit.Text;
   end;
   Mainform.DoIt := True;
   Close;
end;

procedure TMakeSFX.CancelButClick( Sender: TObject );
begin
   Mainform.DoIt := False;
   Close;
end;

procedure TMakeSFX.FormCreate( Sender: TObject );
begin
   with MainForm.ZipMaster1 do
   begin
      CaptionEdit.Text   := SFXCaption;
      DirectoryEdit.Text := SFXDefaultDir;
      CommandEdit.Text   := SFXCommandLine;
   end;
end;

procedure TMakeSFX.BitBtn1Click( Sender: TObject );
var TempStr: String;
begin
   TempStr := DirectoryEdit.Text;
   MainForm.AskDirDialog( MakeSFX.Handle, TempStr );
   DirectoryEdit.Text := TempStr;
end;

end.
 
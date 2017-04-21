///////////////////////////////////////////////////////////////////////////////
//////////////////////////THyperImages Component V.2///////////////////////////
///////////////////Copyright © 1998-1999 Noatak Racing Team////////////////////
///////////////////////////////////////////////////////////////////////////////

unit RoundRectOpt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Buttons;

type
  TRoundRectOptionsForm = class(TForm)
    CornerWidthSpinEdit: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    CornerHeightSpinEdit: TSpinEdit;
    BtnUpdate: TBitBtn;
    procedure BtnUpdateClick(Sender: TObject);
    procedure CornerWidthSpinEditChange(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetUpdateState(Sender: TObject);
  end;

var
  RoundRectOptionsForm: TRoundRectOptionsForm;

implementation

uses HSEdit, CustomHImages;

{$R *.DFM}


procedure TRoundRectOptionsForm.BtnUpdateClick(Sender: TObject);
begin
  HSEditForm.UpdateRoundRectCorner;  
  SetUpdateState(Self);
end;

procedure TRoundRectOptionsForm.SetUpdateState(Sender: TObject);
begin
  with TheHotspot do
    BtnUpdate.Enabled := (FigureType = ftRoundRectangle) and
    (HSEditForm.SelectedIndex > -1) and
    (CornerWidthSpinEdit.Value < (Vertices[3].X - Vertices[1].X)) and
    (CornerHeightSpinEdit.Value < (Vertices[3].Y - Vertices[1].Y)) and
    ((CornerWidthSpinEdit.Value <> Vertices[5].X) or
    (CornerHeightSpinEdit.Value <> Vertices[5].Y));
end;

procedure TRoundRectOptionsForm.CornerWidthSpinEditChange(Sender: TObject);
begin
  SetUpdateState(Self);
end;

end.

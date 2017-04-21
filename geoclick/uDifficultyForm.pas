unit uDifficultyForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RXSpin, ExtCtrls, Buttons;

type
  TDifficultyForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    RxSpinEdit1: TRxSpinEdit;
    RxSpinEdit2: TRxSpinEdit;
    OkButton: TBitBtn;
    CancelButton: TBitBtn;
    Bevel1: TBevel;
    Bevel2: TBevel;
    ClearedmapsCheckBox: TCheckBox;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DifficultyForm: TDifficultyForm;

implementation

{$R *.DFM}

uses uGeoController;

procedure TDifficultyForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TDifficultyForm.FormShow(Sender: TObject);
begin
  RXSpinEdit1.Value := GeoController.spq;
  RXSpinEdit2.Value := GeoController.qpl;
  with AReg do begin
    Active := True;
    Left := RSInteger('Forms','DifficultyLeft',Left);
    Top := RSInteger('Forms','DifficultyTop',Top);
    Active := False;
  end;



  ClearedMapsCheckbox.Checked := Geocontroller.ClearedMaps;

end;

procedure TDifficultyForm.OkButtonClick(Sender: TObject);
begin
  GeoController.spq := RXSpinEdit1.AsInteger;
  GeoController.qpl := RXSpinEdit2.AsInteger;
  with AReg do begin
    Active := True;
    WSInteger('Forms','DifficultyLeft',Left);
    WSInteger('Forms','DifficultyTop',Top);
    Active := False;
  end;

  Geocontroller.ClearedMaps := ClearedMapsCheckbox.Checked;
  GeoController.WriteDiffOptions;
  Close;
end;

end.

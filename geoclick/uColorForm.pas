unit uColorForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,  uGeoController, StdCtrls, Mask, ToolEdit, RxCombos,
  RXCtrls, RXSpin,  OvalBtn, Buttons;

type

  TColorForm = class(TForm)
    Panel1: TPanel;
    RxSpinEdit1: TRxSpinEdit;
    RxLabel1: TRxLabel;
    Label1: TLabel;
    ColorComboBox1: TColorComboBox;
    ColorComboBox2: TColorComboBox;
    Panel2: TPanel;
    FilenameEdit1: TFilenameEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    OkButton: TBitBtn;
    CancelButton: TBitBtn;
    FontDialog1: TFontDialog;
    SoundCheckBox: TCheckBox;
    OvalButton1: TOvalButton;
    
    procedure FormShow(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure RxSpinEdit1Change(Sender: TObject);
    procedure ColorComboBox1Change(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure Label4Click(Sender: TObject);

  private
    HemiDragType : boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ColorForm: TColorForm;

implementation

{$R *.DFM}

procedure TColorForm.FormShow(Sender: TObject);
begin
  with AReg do begin
    Active := True;
    Left := RSInteger('Forms','ColorLeft',Left);
    Top := RSInteger('Forms','ColorTop',Top);
    Active := False;
  end;

  OvalButton1.Caption := GeoController.Username;
  OvalButton1.Color := GeoController.ButtonOptions.FaceColor;
  OvalButton1.Width := GeoController.ButtonOptions.Width;
  OvalButton1.Font := GeoController.ButtonOptions.Font;
  RxSpinEdit1.Value := OvalButton1.Width;
  ColorComboBox1.ColorValue := OvalButton1.Color;
  ColorComboBox2.ColorValue := GeoController.ButtonOptions.SelColor;
  Label4.Font.Assign(GeoController.ButtonOptions.Font);
  Label4.Font.Style := Label4.Font.Style+[fsUnderline];
  Label4.Font.Color := clBlue;

  HemiDragType := False;
  FileNameEdit1.FileName := GeoController.InterfaceOptions.MusicFileName;
  CheckBox1.Checked := GeoController.InterfaceOptions.Musicon;
  SoundCheckBox.Checked := GeoController.InterfaceOptions.Soundon;
  CheckBox2.Checked := GeoController.InterfaceOptions.NormalScroll;
  CheckBox3.Checked := GeoController.InterfaceOptions.NormalZoom;

end;


procedure TColorForm.OkButtonClick(Sender: TObject);
begin
  with AReg do begin
    Active := True;
    WSInteger('Forms','ColorLeft',Left);
    WSInteger('Forms','ColorTop',Top);
    Active := False;
  end;

  GeoController.ButtonOptions.Width := RxSpinEdit1.AsInteger;
  GeoController.ButtonOptions.FAceColor := OvalButton1.Color;
  GeoController.ButtonOptions.SelColor := ColorComboBox2.ColorValue;
  GeoController.ButtonOptions.Font := OvalButton1.Font;
  GeoController.InterfaceOptions.MusicFileName := FileNameEdit1.FileName;
  GeoController.InterfaceOptions.Musicon:= CheckBox1.Checked;
  GeoController.InterfaceOptions.Soundon:= SoundCheckBox.Checked;
  GeoController.InterfaceOptions.NormalScroll := CheckBox2.Checked;
  GeoController.InterfaceOptions.NormalZoom := CheckBox3.Checked;
  GeoController.WriteButtonOptions;
  GeoController.WriteInterfaceOptions;

  Close;

end;

procedure TColorForm.RxSpinEdit1Change(Sender: TObject);
begin
 OvalButton1.Width := RxSpinEdit1.AsInteger;
end;

procedure TColorForm.ColorComboBox1Change(Sender: TObject);
begin
  OvalButton1.Color := ColorComboBox1.ColorValue;

end;


procedure TColorForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TColorForm.Label4Click(Sender: TObject);
begin
  FontDialog1.Font := OvalButton1.Font; 
  if FOntDialog1.Execute then begin

    OvalButton1.Font := FontDialog1.Font;

    Label4.Font.Assign(FontDialog1.Font);
    Label4.Font.Style := Label4.Font.Style+[fsUnderline];
    Label4.Font.Color := clBlue;

  end;
  COlorCombobox1Change(Self);

end;

end.

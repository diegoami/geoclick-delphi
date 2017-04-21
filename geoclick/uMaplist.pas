unit uMaplist;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GetURL, HTMLParser, StdCtrls, Buttons, ComCtrls, ExtCtrls, ZipMstr, stringfns;

type
  TMaplistForm = class(TForm)
    ListView1: TListView;
    InstallBitBtn: TBitBtn;
    NavigateBitBtn: TBitBtn;
    CancelBitBtn: TBitBtn;
    HTMLParser1: THTMLParser;
    WIGetURL1: TWIGetURL;
    TopPanel: TPanel;
    ZipMaster1: TZipMaster;
    DownloadProgressBar: TProgressBar;
    Label1: TLabel;
    procedure HTMLParser1HTMLTag(Sender: TObject; ANode: TTagNode);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure InstallBitBtnClick(Sender: TObject);
    procedure NavigateBitBtnClick(Sender: TObject);
    procedure CancelBitBtnClick(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure WIGetURL1Idle(Sender: TObject);
    procedure WIGetURL1HeaderReceived(Sender: TObject;
      RequestHandle: Pointer; StatusCode: Integer;
      var RetrieveDoc: Boolean);
  private
    procedure FillListView;
    procedure DownloadAndExtract(ZipUrl : String);
  public
    Modified : Boolean;
  end;

var
  MaplistForm: TMaplistForm;

implementation

{$R *.DFM}
procedure TMaplistForm.FIllListView;

var
  Counter : integer;
  Href,
  Description : string;
  Node : TTagNode;
  Links : TTagNodeList;

begin
  ListView1.Items.Clear; 
  If WIGetURL1.GetURL = wiSuccess then
    begin
      Application.ProcessMessages;

      HTMLParser1.Parse(WIGetURL1.Text);
    end;
end;



procedure TMaplistForm.DownloadAndExtract(ZipUrl : String);
var LocalFile : String;
  OldUrl : String;
begin
   // Label1.Visible := True;
  LocalFile := '\temp.zip';
  OldUrl := WIGetUrl1.Url;
  WIGetUrl1.Url := ZipUrl;
  ZipMaster1.ExtrBaseDir := ExtractFilePath(Application.ExeName);

  WIGetUrl1.FetchToFile(LocalFile);
  ZipMaster1.ZipFileName := LocalFile;
  ZipMaster1.Extract;
  WIGetUrl1.Url := OldUrl;
  DeleteFile(LocalFile);
//  Label1.Visible := False;
  Modified := True;
  Close;
end;




procedure TMaplistForm.HTMLParser1HTMLTag(Sender: TObject;
  ANode: TTagNode);
var Url : String;
  UrlText : String;
  ListItem : TListItem;
begin

   If CompareText(Anode.Caption,'a') = 0 then begin
     URL := ANode.Params.Values['href'];
     if Pos('map',URL) = 0 then exit;
     UrlText := ANode.GetPCData;
     ListItem := ListView1.Items.Add;
     ListItem.Caption := UrlText;
     ListItem.SubItems.Add(Url);
   end;

end;

procedure TMaplistForm.FormCreate(Sender: TObject);
begin
  FIllListView;
  Label1.Caption := '';

end;

procedure TMaplistForm.FormShow(Sender: TObject);
begin
  Modified := False;
  FillListView;
end;

procedure TMaplistForm.ListView1DblClick(Sender: TObject);
var Location : String;
begin
  Location := ListView1.Selected.SubItems[0];
  DownloadAndExtract(Location);
  Label1.Caption := '';
end;

procedure TMaplistForm.InstallBitBtnClick(Sender: TObject);
var Location : String;
begin
  
  Location := ListView1.Selected.SubItems[0];
  DownloadAndExtract(Location);

end;

procedure TMaplistForm.NavigateBitBtnClick(Sender: TObject);
begin
  ShowWebPage(WIGetUrl1.Url);
end;

procedure TMaplistForm.CancelBitBtnClick(Sender: TObject);
begin
  CLose;
end;

procedure TMaplistForm.ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  InstallBitBtn.Enabled := True;
end;

procedure TMaplistForm.WIGetURL1Idle(Sender: TObject);
begin
  Application.ProcessMessages;
  if (DownloadProgressBar.Position > 0) then
    DownloadProgressBar.Position :=  WIGetURL1.BytesReceived;
end;

procedure TMaplistForm.WIGetURL1HeaderReceived(Sender: TObject;
  RequestHandle: Pointer; StatusCode: Integer; var RetrieveDoc: Boolean);
begin
  Label1.Caption := 'Downloading ...';
  DownloadProgressBar.Max := StrToInT(WIGetUrl1.TotalSize);
end;

end.

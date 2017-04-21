{*******************************************************}
{                                                       }
{  ReaderError Dialog                                   }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit RerrDlg;

interface

uses dcsystem, dclib, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
     Dialogs, ExtCtrls, StdCtrls,consts,dcconsts;

type
  TReaderErrorDlg = class(TForm)
    Bevel1: TBevel;
    LerrMess: TLabel;
    IgnoreButton: TButton;
    CancelButton: TButton;
    IgnoreAllButton: TButton;
    procedure FormCreate(Sender: TObject);
  private
  protected
  public
  end;

var
  ReaderErrorDlg: TReaderErrorDlg;

implementation
uses
  dccommon;
{$R *.DFM}

{--------------------------------------------}

procedure TReaderErrorDlg.FormCreate(Sender: TObject);
begin
  SetFormFont(self);
  Caption := SErrDlg;
  LerrMess.Caption := SErrMess;
  IgnoreButton.Caption := ResStr(SIgnoreButton);
  CancelButton.Caption := ResStr(consts.SCancelButton);
  IgnoreAllButton.Caption := SIgnoreAll;
end;

{--------------------------------------------}

procedure DefaultReaderErrorHandler(const Message : string ; Var Handled, HandledAll : boolean);
begin
  With TReaderErrorDlg.Create(Application) do
  try
    LerrMess.Caption:=Format(LerrMess.Caption,[Message]);
    Case ShowModal of
      mrOk:
        Handled:=True;
      mrCancel:
        Handled:=False;
      mrIgnore:
        begin
          Handled:=True;
          HandledAll:=True;
        end;
    end;
  finally
    Free;
  end;
end;

{--------------------------------------------}

initialization
  dccommon.ReaderErrorHandler := DefaultReaderErrorHandler;

end.

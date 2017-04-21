///////////////////////////////////////////////////////////////////////////////
//////////////////////////THyperImages Component V.2///////////////////////////
///////////////////Copyright © 1998-1999 Noatak Racing Team////////////////////
///////////////////////////////////////////////////////////////////////////////

unit HImages;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, CustomHImages;

type
  THyperImages = class(TCustomHyperImages)
  public
    property HotspotsCount;
    property Pictures;
  published
    property AutoScaleImage;
    property AutoScalePanel;
    property HotCursor;
    property HotspotsDef;
    property HotspotsPen;
    property IncrementalDisplay;
    property InvertOnHot;
    property HintOnHot;
    property ImageHint;
    property Picture;
    property PictureFilename;
    property PicturesDir;
    property Scale;
    property ShowHotspots;
    property Align;
    property Alignment;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderWidth;
    property BorderStyle;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FullRepaint;
    property Caption;
    property Color;
    property Ctl3D;
    property Font;
    property Locked;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnImageClick;
    property OnImageDblClick;
    property OnImageMouseDown;
    property OnImageMouseMove;
    property OnImageMouseUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDrag;
  end;


procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('Additional', [THyperImages]);
end;

end.

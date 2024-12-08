unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls, ComCtrls,
  ActnList, Grids, ogDefObjGraf, frameEditor, ogShape, ogConnector;

type
  { TForm1 }
  TForm1 = class(TForm)
    acModSelect: TAction;
    acModRotat: TAction;
    ActionList1: TActionList;
    ImageList_32: TImageList;
    Label1: TLabel;
    panShapes: TPanel;
    panProperties: TPanel;
    panLeft: TPanel;
    shpRoundRect: TShape;
    shpRectangle: TShape;
    shpDiamond: TShape;
    shpRoundRect1: TShape;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure acModRotatExecute(Sender: TObject);
    procedure acModSelectExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
var
  fraEdit: TfraEditor;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  og: TOgShape;
  oc: TOgConnector;
  i: Integer;
begin
  //Crea Frame del editor
  fraEdit := TfraEditor.Create(self);
  fraEdit.Parent := self;
  fraEdit.Visible := true;
  fraEdit.Align := alClient;
  //Inicia colores
  colObjMarked := clNavy;
  colCnxPoints := clNavy;

  //Agrega objetos
  og := fraEdit.AddShapeRectangle(200, 100, 100, 80);
  og.Name := 'Obj1';

  //Agrega objetos
  og := fraEdit.AddShapeRectangle(150,250, 100, 80);
  og.Name := 'Obj2';

//  for i:=1 to 1000 do begin
//    og := fraEdit.AddShapeRectangle(50 + i*2,50+i*2);
//  end;
  //Objeto de tipo conector
  oc := fraEdit.AddConector;
  oc.Name := 'Conn1';


end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
end;

//////////////////// Acciones ////////////////////
procedure TForm1.acModSelectExecute(Sender: TObject);
begin
  fraEdit.ModeSelect;
  ToolButton2.Down := false;
end;
procedure TForm1.acModRotatExecute(Sender: TObject);
begin
  fraEdit.ModeRotate;
  ToolButton1.Down := false;
end;

end.


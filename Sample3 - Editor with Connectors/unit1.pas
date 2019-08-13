unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, Graphics, ExtCtrls, ogEditionMot, ogDefObjGraf;

type
  { TMyObject }
  //Define objeto 2D
  TMyObject = class(TObjGraf)
    procedure Draw; override;
  end;

  { TMyConnector }

  TMyConnector = class(TObjGraf)
    function IsSelectedBy(xr, yr: Integer): Boolean; override;
    procedure Draw; override;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    PaintBox1: TPaintBox;   //donde se dibujará
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    motEdi: TEditionMot;  //motor de edición
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}

procedure TMyObject.Draw;
begin
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, 'Objeto');
  v2d.SetPen(psSolid, 1, clBlack);
  v2d.SetBrush(TColor($D5D5D5));
  v2d.RectangR(x, y, x+width, y+height);
  inherited;
end;

{ TMyConnector }

function TMyConnector.IsSelectedBy(xr, yr: Integer): Boolean;
var
  x0, y0, x1, y1: Integer;
begin
  v2d.XYpant(pcBEGIN.x, pcBEGIN.y,  x0, y0);
  v2d.XYpant(pcEND.x, pcEND.y, x1, y1);
  Result := PointSelectSegment(xr, yr, x0, y0, x1, y1 );
end;

procedure TMyConnector.Draw;
begin
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, 'Conector');
  v2d.SetPen(psSolid, 1, clBlack);
  //v2d.SetBrush(TColor($D5D5D5));
  //v2d.RectangR(x, y, x+width, y+height);
  v2d.Line(pcBEGIN.x, pcBEGIN.y, pcEND.x, pcEND.y);
  inherited Draw;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  og: TMyObject;
  oc: TMyConnector;
begin
  //crea motor de edición
  motEdi := TEditionMot.Create(PaintBox1);
  //Agrega objetos
  og := TMyObject.Create(motEdi.v2d);
  //og.Highlight:=false;
  og.ReLocate(50,50);
  motEdi.AddGraphObject(og);
  //Agrega punto de conexión
  og.AddPtoConex(0,50);
  og.ShowPtosConex:=true;

  //Agrega objetos
  og := TMyObject.Create(motEdi.v2d);
  og.ReLocate(250,50);
  motEdi.AddGraphObject(og);
  og.AddPtoConex(100,50);
  og.ShowPtosConex:=true;
  og.pcTOP_CEN.Visible := false;

  //Objeto de tipo conector
  oc := TMyConnector.Create(motEdi.v2d);
  oc.behav:=behav1D;
  motEdi.AddGraphObject(oc);


end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  motEdi.free;
end;

end.


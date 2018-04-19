unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, Graphics, ExtCtrls, ogMotEdicion, ogDefObjGraf;

type
  { TMiObjeto }
  //Define objeto 2D
  TMiObjeto = class(TObjGraf)
    procedure Draw; override;
  end;

  { TMiConector }

  TMiConector = class(TObjGraf)
    function LoSelecciona(xr, yr: Integer): Boolean; override;
    procedure Draw; override;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    PaintBox1: TPaintBox;   //donde se dibujará
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    motEdi: TModEdicion;  //motor de edición
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}

procedure TMiObjeto.Draw;
begin
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, 'Objeto');
  v2d.FijaLapiz(psSolid, 1, clBlack);
  v2d.SetBrush(TColor($D5D5D5));
  v2d.RectangR(x, y, x+width, y+height);
  inherited;
end;

{ TMiConector }

function TMiConector.LoSelecciona(xr, yr: Integer): Boolean;
var
  x0, y0, x1, y1: Integer;
begin
  v2d.XYpant(pcBEGIN.x, pcBEGIN.y,  x0, y0);
  v2d.XYpant(pcEND.x, pcEND.y, x1, y1);
  Result := PointSelectSegment(xr, yr, x0, y0, x1, y1 );
end;

procedure TMiConector.Draw;
begin
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, 'Conector');
  v2d.FijaLapiz(psSolid, 1, clBlack);
  //v2d.SetBrush(TColor($D5D5D5));
  //v2d.RectangR(x, y, x+width, y+height);
  v2d.Linea(pcBEGIN.x, pcBEGIN.y, pcEND.x, pcEND.y);
  inherited Draw;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  og: TMiObjeto;
  oc: TMiConector;
begin
  //crea motor de edición
  motEdi := TModEdicion.Create(PaintBox1);
  //agrega objetos
  og := TMiObjeto.Create(motEdi.v2d);
  //og.Highlight:=false;
  og.ReLocate(50,50);
  motEdi.AddGraphObject(og);

  og.AddPtoConex(0,50);
  og.AddPtoConex(100,50);  //Agrega punto de conexión
  og.ShowPtosConex:=true;

  //Otro objeto
  oc := TMiConector.Create(motEdi.v2d);
  oc.behav:=behav1D;
  //oc.Highlight:=false;
  motEdi.AddGraphObject(oc);

  //Aún no se han definido los objetos de tipo conector, en esta verisón.
  //Solo se han implementado los puntos de control
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  motEdi.free;
end;

end.


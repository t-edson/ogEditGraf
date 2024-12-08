{Aquí se deben definir los objetos gráficos con los que trabajará nuestra aplicación.
 Todos ellos deben descender de TObjGraf, para que puedadn ser tratados por el motor
 de edición "ogMotEdicion".}

unit ogShape;
{$mode objfpc}{$H+}
interface
uses
  Controls, Classes, SysUtils, fgl, Graphics, GraphType, LCLIntf, Dialogs,
  ogMotGraf2D, ogDefObjGraf;

type
  //TShapePoint

  { TOgShape }
  {Define objeto principal que no es un conector}
  TOgShape = class(TObjGraf)
  public
    procedure Draw; override;
  end;

implementation
{ TOgShape }
procedure TOgShape.Draw;
var
  xp1, yp1: Integer;
begin
  v2d.SetBrush(TColor($D5D5D5));
  v2d.SetText(clBlack, 11,'', true);
  //v2d.TextOut(AxisX + 2, AxisY -20, 'Objeto');
  v2d.SetPen(psSolid, 1, clBlack);
//  v2d.RectangR(AxisX, AxisY, AxisX+width, AxisY+height);
//  v2d.XYpant(AxisX-locAxisX, AxisY-locAxisY+Height, xp1, yp1);
//  v2d.Canvas.TextOut(xp1, yp1, 'locAxisX=' + locAxisX.ToString);
  //Dibuja arreglo de puntos
  if geometry.Count = 0 then begin //No hay puntos
  end else if geometry.Count = 1 then begin //Un solo punto
  end else if geometry.Count = 2 then begin //Dos puntos
    v2d.Canvas.Line(points[0], points[1]);
  end else begin       //Varios puntos
    v2d.Canvas.Polygon(points);
  end;
  inherited;
end;

end.


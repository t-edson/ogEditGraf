{Unidad que define a la clase TObjConnector}
unit ogConnector;
{$mode ObjFPC}{$H+}
interface
uses
  Classes, SysUtils, fgl, ogDefObjGraf, ogMotGraf2D, Graphics, Controls;
const
  MAX_POINTS = 10;   //Máximo número de puntos que puede tener un conector

type
  TConnPoint = record
    x, y: Single;
  end;

  TOgSegment = class
    x1, y1: Single;   //Punto inicial
    x2, y2: Single;   //Punto final
  end;

  TOgSegments = specialize TFPGObjectList<TOgSegment>;  //Lista para gestionar los puntos de control

  TOgConnStyle = (cnsLine  //Línea recta
               , cnsOrtog  //Línea ortogonal
               );
  { TOgConnector }

  TOgConnector = class(TObjGraf)
  public
    caption: string;
    style: TOgConnStyle;
    segments: TOgSegments;
  public //Propiedades del texto
    pen  : TPen;
    brush: TBrush;
    font : TFont;
  protected
    rpText: TRect;  //Ubicación física del texto
    procedure DrawLabel;
    procedure RebuildGeometry;
  public
    function IsSelectedBy(xr, yr: Integer): Boolean; override;
    procedure Draw; override;
    constructor Create(mGraf: TMotGraf); override;
    destructor Destroy; override;
  end;

implementation
var  //Manejo de puntos.
  {Se define el contenedor de puntos como arreglo para mejorar la velocidad de los
  cálculos.}
  points : array[0..MAX_POINTS-1] of TConnPoint;
  nPoints: integer;           //Cantidad de puntos

procedure TOgConnector.DrawLabel();
{Dibuja la etiqueta del conector, en la posición indicada por "rpText", que ya debe haber
sido actualizado. El fondo se dibuja de acuerdo al atributo "Brush".}
var
  Sty: TTextStyle;
begin
  v2d.SetText(font.Color, font.Size, font.Name, font.Bold, font.Italic, font.Underline);
  v2d.Canvas.Frame(rpText);     //Fondo
  Sty.Alignment := taLeftJustify;
  Sty.SystemFont := false;   //Para que use la letra del Canvas
  v2d.Canvas.TextRect(rpText, rpText.Left, rpText.Top, caption, Sty);
end;

procedure TOgConnector.RebuildGeometry;
{Reconstruye la geometría del conector que equivale a dibujar el conector creando la
cantidad de segmentos que sean necesario para lograr la conexión del origen al destino.}
var
  nSegNeeded, i, xpCent, ypCent, txtWidth, txtHeigth, xpText, ypText: Integer;
  seg   : TOgSegment;
begin
  //Determina la cantidad de segmentos necesarios
//  dirBegin := cndRight;        //Dirección del origen
//  dirEnd   := cndDown;          //Dirección del destinos
//  nPoints  := 2;
//
  nSegNeeded := 2;  //Fijo por ahora
  //Verifica si se necesita crear o eliminar segmentos
  if segments.Count>nSegNeeded then begin
    segments.Delete(0);
  end else if segments.Count<nSegNeeded then begin
    //Se necesita agregar segmentos
    for i:= segments.Count to nSegNeeded-1 do begin
      seg := TOgSegment.Create;
      segments.Add(seg);
    end;
  end;
  //Configura los segmentos para la conexión

  //Calcula ubicación de la etiqueta
  v2d.XYpant(XCent, YCent, xpCent, ypCent);   //Partimos del centro
  v2d.SetText(font.Color, font.Size,  //Actualiza para calcular gemoemtría
              font.Name, font.Bold, font.Italic, font.Underline);
  txtWidth := v2d.Canvas.TextWidth(caption);  //En coord. de pantalla
  txtHeigth := v2d.Canvas.TextHeight(caption);
  xpText := xpCent - txtWidth div 2;
  ypText := ypCent - txtHeigth div 2;
  //Actualiza el área de la etqueta
  rpText := Rect(xpText, ypText, xpText + txtWidth, ypText + txtHeigth);

end;

function TOgConnector.IsSelectedBy(xr, yr: Integer): Boolean;
var
  x0, y0, x1, y1: Integer;
begin
  v2d.XYpant(pcBEGIN.AxisX, pcBEGIN.AxisY,  x0, y0);
  v2d.XYpant(pcEND.AxisX, pcEND.AxisY, x1, y1);
  Result := PointSelectSegment(xr, yr, x0, y0, x1, y1 );
end;
procedure TOgConnector.Draw;
var
  pct : TPtoCtrl;
  pcn : TPtoConx;
  xp1, yp1, xp2, yp2: Integer;
begin
  caption := 'Conector';
  //Cambia puntero del mouse cuando pasa por encima
  if Marked and Highlight then begin
    v2d.SetPen(psSolid, 1, colObjMarked);
    //if OnReqMouCur<>nil then OnReqMouCur(crHandPoint);
  end else begin
    v2d.SetPen(psSolid, 1, pen.Color);
  end;
  v2d.SetBrush(brush.Style, brush.Color);
  //v2d.RectangR(AxisX, AxisY, AxisX+width, AxisY+height);
  case style of
    cnsLine : begin
      //Dibuja línea
      v2d.XYpant(pcBEGIN.AxisX, pcBEGIN.AxisY, xp1, yp1);
      v2d.XYpant(pcEND.AxisX, pcEND.AxisY, xp2, yp2);
      v2d.Canvas.Line(xp1, yp1, xp2, yp2);
      //Dibuja etiqueta
      DrawLabel();
    end;
    cnsOrtog: begin
      v2d.XYpant(pcBEGIN.AxisX, pcBEGIN.AxisY, xp1, yp1);
      v2d.XYpant(pcEND.AxisX, pcEND.AxisY, xp2, yp2);
      v2d.Canvas.Line(xp1, yp1, xp2, yp2);
      //Dibuja etiqueta
      DrawLabel();
    end;
  end;
//  inherited Draw;
  //--------------- Draw selection state--------------
  if Selected Then begin
     for pct in PtosTerminal do pct.Draw;   //Dibuja puntos de control
  end;
  //Draw Connection Points
  if ShowPtosConex then begin
     for pcn in PtosConex do pcn.Draw;
  end;
  //if MarkConnectPoints then begin
    for pcn in PtosConex do if pcn.Marked then pcn.Mark;
  //end

end;

{ TOgConnector }
constructor TOgConnector.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  behav:=behav1D;
  segments := TOgSegments.Create(true);
  pen  := TPen.Create;
  brush := TBrush.Create;
  font := TFont.Create;
  font.Size := 9;
  //font.Bold := true;
  style := cnsOrtog;
end;

destructor TOgConnector.Destroy;
begin
  font.Destroy;
  brush.Destroy;
  pen.Destroy;
  segments.Destroy;
  inherited Destroy;
end;

initialization

end.


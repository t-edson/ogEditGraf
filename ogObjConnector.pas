{Unidad que define a la clase TObjConnector}
unit ogObjConnector;
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
  { TObjConnector }

  TObjConnector = class(TObjGraf)
  public
    caption: string;
    style: TOgConnStyle;
    segments: TOgSegments;
  public //Propiedades del texto
    pen  : TPen;
    brush: TBrush;
    font : TFont;
  protected
    procedure DrawLabel(xc, yc: Single);
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

procedure TObjConnector.DrawLabel(xc, yc: Single);
{Dibuja la etiqueta del conector, en la posición indicada. El fondo se dibuja de
acuerdo al atributo "Brush".
"xc" e "yc" definen la posición central en donde se ubicará el texto.}
var
  txtWidth, txtHeigth: Single;
  xt, yt: Single;
  Sty: TTextStyle;
begin
  v2d.SetText(font.Color, font.Size, font.Name, font.Bold, font.Italic, font.Underline);
  ///Calcula posición inicial del fondo
  txtWidth := v2d.TextWidth(caption);
  txtHeigth := v2d.TextHeight(caption);
  xt := Xcent - txtWidth/2;
  yt := YCent - txtHeigth/2;
  //Dibuja texto
  v2d.Rectang(xt, yt, xt + txtWidth, yt + txtHeigth);     //Fondo
  Sty.Alignment := taLeftJustify;
  Sty.SystemFont := false;   //Para que use la letra del Canvas
//      v2d.TextOut(xt, yt, caption);
  v2d.TextRect(xt, yt, xt + txtWidth, yt + txtHeigth, xt, yt, caption, Sty);
end;

procedure TObjConnector.RebuildGeometry;
{Reconstruye la geometría del conector que equivale a dibujar el conector creando la
cantidad de segmentos que sean necesario para lograr la conexión del origen al destino.}
var
  nSegNeeded, i: Integer;
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

end;

function TObjConnector.IsSelectedBy(xr, yr: Integer): Boolean;
var
  x0, y0, x1, y1: Integer;
begin
  v2d.XYpant(pcBEGIN.x, pcBEGIN.y,  x0, y0);
  v2d.XYpant(pcEND.x, pcEND.y, x1, y1);
  Result := PointSelectSegment(xr, yr, x0, y0, x1, y1 );
end;

procedure TObjConnector.Draw;
var
  pct : TPtoCtrl;
  pcn : TPtoConx;
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
  //v2d.RectangR(x, y, x+width, y+height);
  case style of
    cnsLine : begin
      //Dibuja línea
      v2d.Line(pcBEGIN.x, pcBEGIN.y, pcEND.x, pcEND.y);
      //Dibuja etiqueta
      DrawLabel(Xcent, YCent);
    end;
    cnsOrtog: begin
      v2d.Line(pcBEGIN.x, pcBEGIN.y, pcEND.x, pcEND.y);
      //Dibuja etiqueta
      DrawLabel(Xcent, YCent);
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

{ TObjConnector }
constructor TObjConnector.Create(mGraf: TMotGraf);
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

destructor TObjConnector.Destroy;
begin
  font.Destroy;
  brush.Destroy;
  pen.Destroy;
  segments.Destroy;
  inherited Destroy;
end;

initialization

end.


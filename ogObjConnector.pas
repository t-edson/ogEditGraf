{Unidad que define a la clase TObjConnector}
unit ogObjConnector;
{$mode ObjFPC}{$H+}
interface
uses
  Classes, SysUtils, fgl, ogDefObjGraf, ogMotGraf2D, Graphics, Controls;
type
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
  public
    function IsSelectedBy(xr, yr: Integer): Boolean; override;
    procedure Draw; override;
    constructor Create(mGraf: TMotGraf); override;
    destructor Destroy; override;
  end;

implementation

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
var
  xt, yt, txtWidth, txtHeigth: Single;
  Sty: TTextStyle;
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
    cnsOrtog: begin
      v2d.Line(pcBEGIN.x, pcBEGIN.y, pcEND.x, pcEND.y);
      //Dibuja etiqueta
      v2d.TextOut(X + 2, Y -20, caption);
    end;
  end;
//  inherited Draw;
  //--------------- Draw selection state--------------
  if Selected Then begin
     for pct in PtosControl1 do pct.Draw;   //Dibuja puntos de control
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

end.


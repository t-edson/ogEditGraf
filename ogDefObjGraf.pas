{Unidad ogDefObjGraf
====================
Por Tito Hinostroza 24/09/2014

Descripcion
===========
Define a los objetos gráficos primarios que serán usados por los objetos de mayor nivel
a usar en un editor de objetos gráficos.
El objeto TObjGraf, es el objeto base del que deben derivarse los objetos más específicos
que se dibujarán en pantalla.
Se incluyen también la definición de puntos de control, que permiten redimensionar al
objeto; y de botones que pueden incluirse en los objetos graficos.
En esta unidad solo deben estar definidos los objetos básicos, los que se pueden usar en
muchas aplicaciones. Los más específicos se deben poner en otra unidad.
No se recomienda modificar esta unidad para adecuar los objetos gráficos a la aplicación.
Si se desea manjar otra clase de objetos generales, es mejor crear otra clase general a
partir de TObjGraf.
La jerarquía de clases es:

TObjVisible ----------------------------------------> TObjGraf ---> Derivar objetos aquí
              |                                          |
               --> TPtoCtrl --(Se incluyen en)-----------
              |                                          |
               --> TogButton --(Se pueden incluir en)----
              |                                          |
               --> TogScrollBar -(Se pueden incluir en)--

}
unit ogDefObjGraf;
{$mode objfpc}{$H+}
interface
uses
  Classes, Controls, SysUtils, Fgl, Graphics, GraphType, Types, ExtCtrls,
  LCLProc, ogMotGraf2D;

const
  ANCHO_MIN = 0;    //Ancho mínimo de objetos gráficos en pixels (Coord Virtuales)
  ALTO_MIN = 20;     //Alto mínimo de objetos gráficos en Twips (Coord Virtuales)

type
  TBehave = (
    behav1D,  //De una dimensión (línea)
    behav2D   //De dos dimensiones
  );
  { TObjVsible }
  //Clase base para todos los objetos visibles
  TObjVsible = class
  private
    procedure Setx(AValue: Single);
    procedure Sety(AValue: Single);
  protected
    fx,fy     : Single;    //coordenadas virtuales
    v2d       : TMotGraf;  //motor gráfico
    Xant,Yant : Integer;   //coordenadas anteriores
  public  //Contenedor de la forma (Cuadro de selección)
    //Puntos de Inicio y Fin
    {Estos puntos definen la geometría cuando se trata de una forma: behav1D}
    startX, startY, endX, endY: Single;
    //Cuadro de selección
    Width     : Single;    //ancho
    Height    : Single;    //alto
  public
    Id        : Integer;   //Identificador del Objeto. No usado por la clase. Se deja para facilidad de identificación.
    Selected  : Boolean;   //indica si el objeto está seleccionado
    Visible   : boolean;   //indica si el objeto es visible
    procedure Crear(mGraf: TMotGraf; ancho0, alto0: Integer);  //no es constructor
    procedure Locate(x0, y0: Single);  //Fija posición  ¿Realmente es útil?
    function LoSelec(xr, yr: Integer): Boolean;
    function StartMove(xr, yr: Integer): Boolean;
    property x: Single read fx write Setx;
    property y: Single read fy write Sety;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TPosicPCtrol = (   //tipo de desplazamiento de punto de control
    TD_SIN_POS,  //sin posición. No se reubicará automáticamente
    //Puntos de dimensionamiento en 2D
    TD_SUP_IZQ,  //superior izquierda, desplaza ancho (por izquierda) y alto (por arriba)
    TD_SUP_CEN,  //superior central, desplaza alto por arriba
    TD_SUP_DER,  //superior derecha, desplaza ancho (por derecha) y alto (por arriba)

    TD_CEN_IZQ,  //central izquierda, desplaza ancho (por izquierda)
    TD_CEN_DER,  //central derecha, desplaza ancho (por derecha)

    TD_INF_IZQ,  //inferior izquierda
    TD_INF_CEN,  //inferior central
    TD_INF_DER,  //inferior izquierda
    //Puntos de dimensionamiento en 1D
    TD_BEGIN,    //Punto de inicio
    TD_END       //Punto de fin
   );

  TPtoCtrl = class;
  //Eventos para dimensionar forma
  TEvReqDimen2D = procedure(newX, newY, newWidth, newHeight: Single) of object;
  TEvReqDimen1D = procedure(target: TPtoCtrl; dx, dy: Single) of object;

  TObjGraf = class;

  { TPtoCtrl }
  {Define al objeto Punto de Control.}
  TPtoCtrl = class(TObjVsible)
  private
    fTipDesplaz: TPosicPCtrol;
    procedure SetTipDesplaz(AValue: TPosicPCtrol);
  public
    posicion  : TPosicPCtrol;  //solo hay 8 posicionnes para un punto de control
    Parent    : TObjGraf;      //Referencia al objeto contenedor
    //El tipo de desplazamiento, por lo general debe depender únicamente de la posicion
    property tipDesplaz: TPosicPCtrol read fTipDesplaz write SetTipDesplaz;
    procedure Draw();
    procedure StartMove(xr, yr: Integer; xIni, yIni, widthIni, heighIni: Single);
    procedure Mover(xr, yr: Integer);  //Dimensiona las variables indicadas
    function LoSelec(xp, yp: Integer):boolean;
    procedure LocateInParent;
  private
    tipPuntero : Integer;  //Tipo de puntero
    OnReqDimens1D: TEvReqDimen1D;  //Requiere dimensionamiento en modo 1D
    OnReqDimens2D: TEvReqDimen2D;  //manejador de Evento
  public //Inicialización
    x0, y0  : Single;      //Posición inicial de la forma al iniciar el control
    width0, height0: Single; //DImensiones iniciales de la forma al iniciar el control
    constructor Create(Parent0: TObjGraf; PosicPCtrol, tipDesplaz0: TPosicPCtrol;
      ReqDimens2D: TEvReqDimen2D; ReqDimens1D: TEvReqDimen1D); reintroduce;
  end;
  TPtosControl = specialize TFPGObjectList<TPtoCtrl>;  //Lista para gestionar los puntos de control

  { TPtoConx }
  {Define al objeto Punto de Conexión.}
  TPtoConx = class(TObjVsible)
  public
//    xOff, yOff: Single;  //Posición con respecto al onjeto contenedor
    xFac, yFac: Single;  //Posición con respecto al objeto contenedor (procentaje de ancho y alto)
    procedure Draw();
    procedure StartMove(xr, yr: Integer; x0, y0, ancho0, alto0: Single);
    procedure Mover(xr, yr: Integer);  //Dimensiona las variables indicadas
    function LoSelec(xp, yp: Integer):boolean;
  private
    tipPuntero : Integer;  //Tipo de puntero
    x1, y1, ancho1, alto1: Single;  //valores objetivo para las dimensiones
  public //Inicialización
    constructor Create(mGraf: TMotGraf; EvenPCdim0: TEvReqDimen2D);
  end;
  TPtosConex = specialize TFPGObjectList<TPtoConx>;  //Lista para gestionar los puntos de control

  TEventSelec = procedure(obj: TObjGraf) of object; //Procedimiento-evento para seleccionar
  TEventCPunt = procedure(TipPunt: Integer) of object; //Procedimiento-evento para cambiar puntero

  { TObjGraf }
  {Este es el Objeto padre de todos los objetos gráficos visibles que son administrados por
   el motor de edición.}
  TObjGraf = class(TObjVsible)
  protected
    function GetXCent: Single;  //Coordenada X central del objeto.
    procedure SetXcent(AValue: Single);
    function GetYCent: Single;  //Coordenada Ycentral del objeto
    procedure SetYCent(AValue: Single);
  private
    pCtl        : TPtoCtrl;      //variable para Punto de Control
    procedure ProcPCnxMov(x0, y0, ancho0, alto0: Single);
    procedure ReqDimen1D(target: TPtoCtrl; dx, dy: Single);
  public
    behav : TBehave;  //Indica si la forma es de 1D o 2D.
    Name        : String;    //Identificación del objeto
    Marcado     : Boolean;   //Indica que está marcado, porque el ratón pasa por encima
    DibSimplif  : Boolean;   //indica que se está en modo de dibujo simplificado
    Highlight   : Boolean;   //indica si permite el resaltado del objeto
    SizeLocked  : boolean;   //protege al objeto de redimensionado
    PosLocked   : Boolean;   //Indica si el objeto está bloqueado para movimiento
    SelLocked   : Boolean;   //Indica si el objeto está bloqueado para selección
    Tipo        : Integer;   //Tipo de objeto. No usado por la librería. Queda para el usuario.
    Data        : string;    //Dato adicional. No usado por la librería. Queda para el usuario.
    Obj         : pointer;   //Dato adicional. No usado por la librería. Queda para el usuario.
    Relleno     : TColor;    //Color de relleno
    Proceso     : Boolean;   //Bandera
    Resizing    : boolean;  //indica que el objeto está dimensionándose
    Erased      : boolean;   //bandera para eliminar al objeto
    property Xcent: Single read GetXCent write SetXcent;
    property YCent: Single read GetYCent write SetYCent;
    procedure Selec;         //Método único para seleccionar al objeto
    procedure Deselec;       //Método único para quitar la selección del objeto
    procedure Delete;        //Método para eliminar el objeto
    procedure Mover(xr, yr : Integer; nobjetos : Integer); virtual;
    function LoSelecciona(xr, yr:integer): Boolean;
    procedure Draw; virtual;  //Dibuja el objeto gráfico
    procedure StartMove(xr, yr : Integer);
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
       xp, yp: Integer); virtual;  //Metodo que funciona como evento mouse_down
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
       xp, yp: Integer; solto_objeto: Boolean); virtual;
    procedure MouseMove(Sender: TObject; Shift: TShiftState; xp, yp: Integer); virtual;
    procedure MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
                 MousePos: TPoint; var Handled: Boolean); virtual;
  public //Posición y Tamaño
    procedure ReLocate(newX, newY: Single); virtual;
    procedure Resize(newWidth, newHeight: Single); virtual; //Reconstruye la geometría del objeto
    procedure ReLocateSize(newX, newY, newWidth, newHeight: Single);
  public //Eventos de la clase
    OnRelocate: procedure of object;
    OnResize  : procedure of object;
    OnSelec   : TEventSelec;
    OnDeselec : TEventSelec;
    OnCamPunt : TEventCPunt;
  protected //Puntos de Control
    {Los puntos de control son los que se pueden mover independientemente y tienen
    efecto sobre la posición y/o el tamaño de la forma.}
    //Puntos de control por defecto
    pcTOPLEFT: TPtoCtrl;
    pc_SUP_CEN: TPtoCtrl;
    pc_SUP_DER: TPtoCtrl;
    pc_CEN_IZQ: TPtoCtrl;
    pc_CEN_DER: TPtoCtrl;
    pc_INF_IZQ: TPtoCtrl;
    pc_INF_CEN: TPtoCtrl;
    pc_INF_DER: TPtoCtrl;
    pcBEGIN  : TPtoCtrl;
    pcEND    : TPtoCtrl;
    PtosControl1: TPtosControl;  //Lista de puntos de control en modo 1D
    PtosControl2: TPtosControl;  //Lista de puntos de control
    function SelecPtoControl(xp, yp: integer): TPtoCtrl;
    function AddPtoControl1D(PosicPCtrol, tipDesplaz0: TPosicPCtrol): TPtoCtrl;
    function AddPtoControl2D(PosicPCtrol, tipDesplaz0: TPosicPCtrol): TPtoCtrl;
  public //Puntos de conexión
    ShowPtosConex: boolean;   //Indica si se mostrarán los puntos de conexión
    PtosConex  : TPtosConex;  //Lista de puntos de conexión
    function AddPtoConex(xOff, yOff: Single): TPtoConx;
  public //Inicialización
    constructor Create(mGraf: TMotGraf); virtual;
    destructor Destroy; override;
  end;

implementation

const
  ANC_PCT2 = 5;       //mitad del ancho de punto de control
  ANC_PCN2 = 4;

{ TObjVsible }
procedure TObjVsible.Crear(mGraf: TMotGraf; ancho0, alto0: Integer);
begin
  v2d := mGraf;
  width:=ancho0;
  height :=alto0;
  visible := true;
end;
procedure TObjVsible.Setx(AValue: Single);
begin
  if fx=AValue then Exit;
  fx:=AValue;
end;
procedure TObjVsible.Sety(AValue: Single);
begin
  if fy=AValue then Exit;
  fy:=AValue;
end;
procedure TObjVsible.Locate(x0, y0: Single);
begin
  fx := x0;
  fy := y0;
end;
function TObjVsible.LoSelec(xr, yr: Integer): Boolean;
//Indica si las coordenadas de ratón seleccionan al botón en su posición actual
var xv, yv: Single;    //coordenadas virtuales
begin
    v2d.XYvirt(xr, yr, xv, yv);
    LoSelec := False;    //valor por defecto
    If (xv > fx - 2) And (xv < fx + width + 2) And
       (yv > fy - 2) And (yv < fy + height + 2) Then
        LoSelec := True;
end;
function TObjVsible.StartMove(xr, yr: Integer): Boolean;
begin
  Result := false;  //por el momento, no devuelve valor
  if not visible then exit;    //validación
  //captura posición actual, para calcular los desplazamientos
  Xant := xr;
  Yant := yr;
end;
constructor TObjVsible.Create;
begin
  inherited Create;
end;
destructor TObjVsible.Destroy;
begin
  inherited Destroy;
end;

//////////////////////////////  TPtoCtrl //////////////////////////////
procedure TPtoCtrl.SetTipDesplaz(AValue: TPosicPCtrol);
//CAmbiando el tipo de desplazamiento se define el tipo de puntero
begin
  if fTipDesplaz=AValue then Exit;
  fTipDesplaz:=AValue;
  //actualiza tipo de puntero
  case tipDesplaz of
  TD_SUP_IZQ: tipPuntero := crSizeNW;
  TD_SUP_CEN: tipPuntero := crSizeNS;
  TD_SUP_DER: tipPuntero := crSizeNE;

  TD_CEN_IZQ: tipPuntero := crSizeWE;
  TD_CEN_DER: tipPuntero := crSizeWE;

  TD_INF_IZQ: tipPuntero := crSizeNE;
  TD_INF_CEN: tipPuntero := crSizeNS;
  TD_INF_DER: tipPuntero := crSizeNW;

  TD_BEGIN, TD_END:
    tipPuntero := crSize;
  else
    tipPuntero := crDefault;
  end;
end;
procedure TPtoCtrl.Draw();
//Dibuja el Punto de control en la posición definida
var xp, yp: Integer;
begin
   if not visible then exit;    //validación
   if  tipDesplaz in [TD_BEGIN, TD_END] then begin
      v2d.XYpant(fx, fy, xp, yp);      //obtiene coordenadas de pantalla
      v2d.SetBrush(clNavy);
      v2d.Canvas.Ellipse(xp - ANC_PCT2, yp - ANC_PCT2,
                         xp + ANC_PCT2, yp + ANC_PCT2);
   end else begin
     v2d.XYpant(fx, fy, xp, yp);      //obtiene coordenadas de pantalla
     v2d.Barra0(xp - ANC_PCT2, yp - ANC_PCT2,
                xp + ANC_PCT2, yp + ANC_PCT2, clNavy);  //siempre de tamaño fijo
   end;
end;
procedure TPtoCtrl.StartMove(xr, yr: Integer; xIni, yIni, widthIni, heighIni: Single);
//Procedimiento para procesar el evento StartMove del punto de control
begin
   if not visible then exit;    //validación
   inherited StartMove(xr,yr);
   {Captura los valores iniciales de la geometría, apra poder operar sobre esas
   dimensiones cuando se intente hacer los dimensionamientos.}
   x0 := xIni;
   y0 := yIni;
   width0 := widthIni;
   height0 := heighIni;
end;
procedure TPtoCtrl.Mover(xr, yr: Integer);
//Realiza el cambio de las variables indicadas de acuerdo al tipo de control y a
//las variaciones indicadas (dx, dy)
var dx, dy: Single;
begin
   if not visible then exit;    //validación
   dx := (xr - Xant) / v2d.Zoom;     //obtiene desplazamiento absoluto
   dy := (yr - Yant) / v2d.Zoom;     //obtiene desplazamiento absoluto
   if OnReqDimens2D=NIL then exit;    //protección
   case tipDesplaz of
   TD_SUP_IZQ: OnReqDimens2D(x0+dx, y0+dy, width0-dx, height0-dy);
   TD_SUP_CEN: OnReqDimens2D(x0   , y0+dy, width0   , height0-dy);
   TD_SUP_DER: OnReqDimens2D(x0   , y0+dy, width0+dx, height0-dy);

   TD_CEN_IZQ: OnReqDimens2D(x0+dx, y0, width0-dx, height0);
   TD_CEN_DER: OnReqDimens2D(x0   , y0, width0+dx, height0);

   TD_INF_IZQ: OnReqDimens2D(x0+dx, y0, width0-dx, height0+dy);
   TD_INF_CEN: OnReqDimens2D(x0   , y0, width0   , height0+dy);
   TD_INF_DER: OnReqDimens2D(x0   , y0, width0+dx, height0+dy);

   TD_BEGIN, TD_END: begin
     //Se está moviendo un punto de cpntrol
     OnReqDimens1D(Self, dx, dy);
   end;
   end;
//  Xant := xr; Yant := yr;   //actualiza coordenadas
end;
function TPtoCtrl.LoSelec(xp, yp: Integer): boolean;
//Indica si las coordenadas lo selecciona
var xp0, yp0 : Integer; //corodenadas virtuales
begin
   LoSelec := False;
   if not visible then exit;    //validación
   v2d.XYpant(fx, fy, xp0, yp0);   //obtiene sus coordenadas en pantalla
   //compara en coordenadas de pantalla
   If (xp >= xp0 - ANC_PCT2) And (xp <= xp0 + ANC_PCT2) And
      (yp >= yp0 - ANC_PCT2) And (yp <= yp0 + ANC_PCT2) Then
        LoSelec := True;
End;
procedure TPtoCtrl.LocateInParent;
{Ubica al Punto de control en su posición respectiva con respecto al objeto padre}
begin
 case posicion of
 TD_SUP_IZQ:  //superior izquierda, desplaza ancho (por izquierda) y height (por arriba)
   Locate(Parent.x, Parent.y);
 TD_SUP_CEN:  //superior central, desplaza Parent.height por arriba
   Locate(Parent.x+Parent.width/2,Parent.y);
 TD_SUP_DER:  //superior derecha, desplaza ancho (por derecha) y Parent.height (por arriba)
   Locate(Parent.x+Parent.width,Parent.y);

 TD_CEN_IZQ:  //central izquierda, desplaza ancho (por izquierda)
   Locate(Parent.x,Parent.y+Parent.height/2);
 TD_CEN_DER:  //central derecha, desplaza ancho (por derecha)
   Locate(Parent.x+Parent.width,Parent.y+Parent.height/2);

 TD_INF_IZQ:  //inferior izquierda
   Locate(Parent.x,Parent.y+Parent.height);
 TD_INF_CEN:  //inferior central
   Locate(Parent.x+Parent.width/2,Parent.y+Parent.height);
 TD_INF_DER:   //inferior izquierda
   Locate(Parent.x+Parent.width,Parent.y+Parent.height);

 TD_BEGIN:
   Locate(Parent.x, Parent.y);
 TD_END:
   Locate(Parent.x + Parent.width, Parent.Y + Parent.Height);
 else
   //otra ubicación no lo reubica
 end;
end;
constructor TPtoCtrl.Create(Parent0: TObjGraf; PosicPCtrol,
  tipDesplaz0: TPosicPCtrol; ReqDimens2D: TEvReqDimen2D; ReqDimens1D: TEvReqDimen1D);
begin
  inherited Crear(Parent0.v2d, 2*ANC_PCT2, 2*ANC_PCT2);    //crea
  Parent := Parent0;
  posicion := PosicPCtrol;  //donde aparecerá en el objeto
  tipDesplaz := tipDesplaz0;  //actualiza propiedad
  OnReqDimens2D := ReqDimens2D;     //Asigna evento para cambiar dimensiones
  OnReqDimens1D := ReqDimens1D;
  visible := true;             //lo hace visible
  fx :=0;
  fy :=0;
end;
//////////////////////////////  TPtoConx //////////////////////////////
procedure TPtoConx.Draw();
//Dibuja el Punto de control en la posición definida
var xp, yp: Integer;
begin
  if not visible then exit;    //validación
  v2d.XYpant(fx, fy, xp, yp);      //obtiene coordenadas de pantalla
  v2d.SetLine(clBlue);
  v2d.Linea(xp - ANC_PCN2, yp - ANC_PCN2, xp + ANC_PCN2, yp + ANC_PCN2);
  v2d.Linea(xp - ANC_PCN2, yp + ANC_PCN2, xp + ANC_PCN2, yp - ANC_PCN2);
  //v2d.Barra0(xp - ANC_PCT2, yp - ANC_PCT2,
  //           xp + ANC_PCT2, yp + ANC_PCT2, clNavy);  //siempre de tamaño fijo
end;
procedure TPtoConx.StartMove(xr, yr: Integer; x0, y0, ancho0, alto0: Single);
//Procedimiento para procesar el evento StartMove del punto de control
begin
  if not visible then exit;    //validación
  inherited StartMove(xr,yr);
  //captura los valores iniciales de las dimensiones
  x1 := x0;
  y1 := y0;
  ancho1 := ancho0;
  alto1 := alto0;
end;
procedure TPtoConx.Mover(xr, yr: Integer);
//Realiza el cambio de las variables indicadas de acuerdo al tipo de control y a
//las variaciones indicadas (dx, dy)
var
 dx, dy: Single;
begin
 if not visible then exit;    //validación
 dx := (xr - Xant) / v2d.Zoom;     //obtiene desplazamiento absoluto
 dy := (yr - Yant) / v2d.Zoom;     //obtiene desplazamiento absoluto

//  Xant := xr; Yant := yr;   //actualiza coordenadas
end;
function TPtoConx.LoSelec(xp, yp: Integer): boolean;
//Indica si las coordenadas lo selecciona
var xp0, yp0 : Integer; //corodenadas virtuales
begin
  LoSelec := False;
  if not visible then exit;    //validación
  v2d.XYpant(fx, fy, xp0, yp0);   //obtiene sus coordenadas en pantalla
  //compara en coordenadas de pantalla
  if (xp >= xp0 - ANC_PCT2) And (xp <= xp0 + ANC_PCT2) And
     (yp >= yp0 - ANC_PCT2) And (yp <= yp0 + ANC_PCT2) then
       LoSelec := True;
end;
constructor TPtoConx.Create(mGraf: TMotGraf; EvenPCdim0: TEvReqDimen2D);
begin
 inherited Crear(mGraf, 2*ANC_PCT2, 2*ANC_PCT2);    //crea
 visible := true;             //lo hace visible
 fx :=0;
 fy :=0;
 tipPuntero := crSizeNW;  //No se usa
end;
{ TObjGraf }
function TObjGraf.SelecPtoControl(xp, yp:integer): TPtoCtrl;
//Indica si selecciona a algún punto de control y devuelve la referencia.
var pdc: TPtoCtrl;
begin
  SelecPtoControl := NIL;      //valor por defecto
  if behav = behav1D then begin
     for pdc in PtosControl1 do begin
         if pdc.LoSelec(xp,yp) then begin SelecPtoControl := pdc; exit; end;
     end;
  end else if behav = behav2D then begin
    for pdc in PtosControl2 do begin
        if pdc.LoSelec(xp,yp) then begin SelecPtoControl := pdc; exit; end;
    end;
  end;
end;
function TObjGraf.GetXCent: Single;
begin
   Result := fx + width / 2;
end;
procedure TObjGraf.SetXcent(AValue: Single);
begin
  Locate(AValue-width/2, y);
end;
function TObjGraf.GetYCent: Single;
begin
   Result := fy + height / 2;
end;
procedure TObjGraf.SetYCent(AValue: Single);
begin
  Locate(x, AValue-height/2);
end;
procedure TObjGraf.Selec;
begin
   if Selected then exit;    //ya está Selected
   Selected := true; //se marca como Selected
   //Llama al evento que selecciona el objeto. El editor debe responder
   if Assigned(OnSelec) then OnSelec(self);   //llama al evento
   { TODO : Aquí se debe activar los controles para dimensionar el objeto }
end;
procedure TObjGraf.Deselec;
begin
   if not Selected then exit;    //ya está Selected
   Selected := false; //se marca como selccionado
   //Llama al evento que selecciona el objeto. El editor debe responder
   if Assigned(OnDeselec) then OnDeselec(self);  //llama al evento
   { TODO : Aquí se debe desactivar los controles para dimensionar el objeto }
end;
procedure TObjGraf.Delete;
begin
  //Marca para eliminarse
  Erased := true;
end;
procedure TObjGraf.Mover(xr, yr: Integer; nobjetos: Integer);
{Metodo que funciona como evento movimiento al objeto
"nobjetos" es la cantidad de objetos que se mueven. Ususalmente es sólo uno}
var dx , dy: Single;
begin
//     If ArrastBoton Then Exit;       //Arrastrando botón  { TODO : Revisar }
//     If ArrastFila Then Exit;        //Arrastrando botón  { TODO : Revisar }
     If Selected Then begin
        v2d.ObtenerDesplaz2( xr, yr, Xant, Yant, dx, dy);
        if Proceso then   //algún elemento del objeto ha procesado el evento de movimiento
           begin
              if pCtl <> NIL then begin
                 //hay un punto de control procesando el evento MouseMove
                 if not SizeLocked then
                   pCtl.Mover(xr, yr);   //permite dimensionar el objeto
              end;
//              Proceso := True;  'ya alguien ha capturado el evento
           end
        else  //ningún elemento del objeto lo ha procesado, pasamos a mover todo el objeto
           begin
              ReLocate(fx + dx, fy + dy);  //reubica los elementos
              Proceso := False;
           End;
        Xant := xr; Yant := yr;
     End;
end;
function TObjGraf.LoSelecciona(xr, yr:integer): Boolean;
//Devuelve verdad si la coordenada de pantalla xr,yr cae en un punto tal
//que "lograria" la seleccion de la forma.
var xv , yv : Single; //corodenadas virtuales
begin
    v2d.XYvirt(xr, yr, xv, yv);
    LoSelecciona := False; //valor por defecto
    //verifica área de selección
    If (xv > fx - 1) And (xv < fx + width + 1) And (yv > fy - 1) And (yv < fy + height + 1) Then
      LoSelecciona := True;
    if Selected then begin   //Selected, tiene un área mayor de selección
      if SelecPtoControl(xr,yr) <> NIL then LoSelecciona := True;
    end;
End;
procedure TObjGraf.Draw;
const tm = 3;
var
  pct  : TPtoCtrl;
  pcn : TPtoConx;
begin
  //---------------dibuja remarcado --------------
  if Marcado and Highlight then begin
    v2d.FijaLapiz(psSolid, 2, clBlue);   //RGB(128, 128, 255)
    v2d.rectang(fx - tm, fy - tm, fx + width + tm, fy + height + tm);
  End;
  //---------------dibuja marca de seleccion--------------
  if Selected Then begin
    if behav = behav1D then begin
       for pct in PtosControl1 do pct.Draw;   //Dibuja puntos de control
    end else if behav = behav2D then begin
       for pct in PtosControl2 do pct.Draw;   //Dibuja puntos de control
    end;
  end;
  //Dibuja Puntos de conexión
  if ShowPtosConex then begin
     for pcn in PtosConex do pcn.Draw;
  end;
end;
procedure TObjGraf.StartMove(xr, yr: Integer);
//Procedimiento para procesar el evento StartMove de los objetos gráficos
//Se ejecuta al inicio de movimiento al objeto
begin
  Xant := xr; Yant := yr;
  Proceso := False;
  if not Selected then exit;   //para evitar que responda antes de seleccionarse
  //Busca si algún punto de control lo procesa
  pCtl := SelecPtoControl(xr,yr);
  if pCtl <> NIL  then begin
      pCtl.StartMove(xr, yr, fx, fy,width,height);     //prepara para movimiento fy dimensionamiento
      Proceso := True;      //Marcar para indicar al editor fy a Mover() que este objeto procesará
                            //el evento fy no se lo pasé a los demás que pueden estar seleccionados.
      Resizing := True; //Marca bandera
   end;
  { TODO : Verificar por qué, a veces se puede iniciar el movimiento del objeto cuando el puntero está en modo de dimensionamiento. }
end;
procedure TObjGraf.MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
//Metodo que funciona como evento "MouseDown"
begin
//  CapturoEvento := NIL;
  Proceso := False;
  If LoSelecciona(xp, yp) Then begin  //sólo responde instantáneamente al caso de selección
    If Not Selected Then Selec;
    Proceso := True;{ TODO : Verificar si es útil la bandera "Proceso" }
  End;
End;
procedure TObjGraf.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; xp, yp: Integer; solto_objeto: Boolean);
//Metodo que funciona como evento MouseUp
//la bandera "solto_objeto" indica que se ha soltado el objeto despues de estarlo arrastrando
begin
    Proceso := False;
    //verifica si cae de un arrastre
    If solto_objeto And Selected Then begin
        Proceso := True; Exit;    //no quita la selección
    end;
    //Se soltó el ratón
    If Button = mbLeft Then  begin          //soltó izquierdo
    end else If Button = mbRight Then begin //soltó derecho
        If LoSelecciona(xp, yp) Then
            Proceso := True;
    end;
    //Restaura puntero si estaba dimensionándose por si acaso
    if Resizing then begin
       if not pCtl.LoSelec(xp,yp) then //se salio del foco
          if Assigned(OnCamPunt) then OnCamPunt(crDefault);  //pide retomar el puntero
       Resizing := False;    //quita bandera, por si estaba Resizing
       exit;
    end;
end;
procedure TObjGraf.MouseMove(Sender: TObject; Shift: TShiftState; xp, yp: Integer);
//Respuesta al evento MouseMove. Se debe recibir cuando el Mouse pasa por encima del objeto
var pc: TPtoCtrl;
begin
    if not Selected then Exit;
    //Aquí se supone que tomamos el control porque está Selected
    //Procesa el cambio de puntero.
    if Assigned(OnCamPunt) then begin
        pc := SelecPtoControl(xp,yp);
        if pc<> NIL then
           OnCamPunt(pc.tipPuntero)  //cambia a supuntero
        else
           OnCamPunt(crDefault);
    end;
end;
procedure TObjGraf.MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin

end;
//Posición y Tamaño
procedure TObjGraf.ReLocate(newX, newY: Single);
{Se usa para cambiar SOLAMENTE la ubicación del objeto}
var
  pcn: TPtoConx;
begin
  fx := newX;
  fy := newY;
  //Reubica todos los puntos de control
  pcTOPLEFT.LocateInParent;
  pc_SUP_CEN.LocateInParent;
  pc_SUP_DER.LocateInParent;
  pc_CEN_IZQ.LocateInParent;
  pc_CEN_DER.LocateInParent;
  pc_INF_IZQ.LocateInParent;
  pc_INF_CEN.LocateInParent;
  pc_INF_DER.LocateInParent;
  pcBEGIN.LocateInParent;
  pcEND.LocateInParent;

  //Reubica todos los puntos de conexión
  for pcn in PtosConex do begin
    pcn.x := x + width * pcn.xFac;
    pcn.y := y + height * pcn.yFac;
  end;
  if OnRelocate<>nil then OnRelocate;
end;
procedure TObjGraf.Resize(newWidth, newHeight: Single);
{Se usa para cambiar SOLAMENTE el tamaño del objeto}
var
  pcn: TPtoConx;
begin
  //Protección
  if newWidth < ANCHO_MIN then begin
     newWidth := ANCHO_MIN;
  end;
  if newHeight < ALTO_MIN then begin
     newHeight := ALTO_MIN;
  end;
  //Actualiza por casos
  if (newWidth<>Width) and (newHeight<>Height) then begin
    //Cambian ancho y alto
    Width := newWidth;
    Height := newHeight;
  end else if newWidth<>Width then begin
    //Solo cambia el ancho
    Width := newWidth;
  end else if newHeight<>Height then begin
    //Solo cambia el alto
    Height := newHeight;
  end else begin
    //No cambia nada
    exit;
  end;
  //Reubica todos los puntos de control
  //pcTOPLEFT.LocateInParent;  //Este es el único punto que no cambia su posición al redimensionar la forma
  pc_SUP_CEN.LocateInParent;
  pc_SUP_DER.LocateInParent;
  pc_CEN_IZQ.LocateInParent;
  pc_CEN_DER.LocateInParent;
  pc_INF_IZQ.LocateInParent;
  pc_INF_CEN.LocateInParent;
  pc_INF_DER.LocateInParent;
  pcBEGIN.LocateInParent;
  pcEND.LocateInParent;
  //Posiciona proporcionalmente a los puntos de conexión
  //debugln('fdx=%f fdy=%f', [fdx, fdy]);
  for pcn in PtosConex do begin
    pcn.x := x + width * pcn.xFac;
    pcn.y := y + height * pcn.yFac;
  end;
  if OnResize<>nil then OnResize;
end;
procedure TObjGraf.ReLocateSize(newX, newY, newWidth, newHeight: Single);
//Se usa para atender los requerimientos de los puntos de control cuando quieren
//cambiar el tamaño y/o la posición del objeto.
var
  changeLocation, changeSize: Boolean;
begin
  //Protección
  if newWidth < ANCHO_MIN then begin
     newWidth := ANCHO_MIN;
     newX := fx;  //Mantiene X, por si acaso
  end;
  if newHeight < ALTO_MIN then begin
     newHeight := ALTO_MIN;
     newY := fy;  //Mantiene Y, por si acaso
  end;
  changeLocation := (newX<>fx) or (newY<>fy);
  changeSize := (newWidth<>width) or (newHeight<>Height);

  if changeLocation then begin
     ReLocate(newX, newY);       //Reubica
     if OnRelocate<>nil then OnRelocate;
  end;
  if changeSize then begin
     Resize(newWidth, newHeight);       //Reubica
     if OnResize<>nil then OnResize;
  end;
end;
procedure TObjGraf.ReqDimen1D(target: TPtoCtrl; dx, dy: Single);
{Un punto de control está solicitando reposicionamiento, lo que se suponse afecta
a la posición o el dimensionameinto de la forma.}
var
  newX, newY, newWidth, newHeight: Single;
begin
 case target.tipDesplaz of
 TD_BEGIN: begin
   debugln('Dimen1D: width0=%f dx=%f', [pcBEGIN.width0, dx]);
   if pcBEGIN.x < pcEND.x then begin
     //El punto BEGIN está a la izquierda de END. Esto es lo normal
     newX := pcBEGIN.x0 + dx;
     newY := pcBEGIN.y0 + dy;
     newWidth := pcBEGIN.width0 - dx;
     newHeight := pcBEGIN.height0 - dy;
     Relocate(newX, newY);
     Resize(newWidth, newHeight);
   end else begin
//     debugln('Dimen1D: pcBEGIN.x >= pcEND.x');
     //El punto BEGIN está a la derecha de END. Está invertido
     //newX := pcEND.x0 + dx;
     //newY := pcEND.y0 + dy;
     newWidth := pcBEGIN.width0 - dx;
     newHeight := pcBEGIN.height0 - dy;
     Relocate(pcEND.X, Y);
     Resize(abs(newWidth), newHeight);
   end;
 end;
 TD_END: begin
   if pcBEGIN.x < pcEND.x then begin
      //El punto END está a la derecha de BEGIN. Esto es lo normal.
      //newX := pcEND.x0 + dx;
      //newY := pcEND.y0 + dy;
      newWidth := pcEND.width0 + dx;
      newHeight := pcEND.height0 + dy;
      //Relocate(newX, newY);
      Resize(newWidth, newHeight);
   end else begin

   end;
 end;
 end;
end;
function TObjGraf.AddPtoControl1D(PosicPCtrol, tipDesplaz0: TPosicPCtrol): TPtoCtrl;
//Agrega un punto de control, que trabajará en formas 1D
begin
  Result := TPtoCtrl.Create(self, PosicPCtrol, tipDesplaz0, @ReLocateSize, @ReqDimen1D);
  PtosControl1.Add(Result);
end;
function TObjGraf.AddPtoControl2D(PosicPCtrol, tipDesplaz0: TPosicPCtrol): TPtoCtrl;
//Agrega un punto de control, que trabajará en formas 2D
begin
  Result := TPtoCtrl.Create(self, PosicPCtrol, tipDesplaz0, @ReLocateSize, @ReqDimen1D);
  PtosControl2.Add(Result);
end;
function TObjGraf.AddPtoConex(xOff, yOff: Single): TPtoConx;
begin
  Result := TPtoConx.Create(v2d, @ProcPCnxMov);
  Result.xFac := xOff/Width;
  Result.yFac := yOff/Height;
  //Actualiza coordenadas absolutas
  Result.x := x + xOff;
  Result.y := x + yOff;
  PtosConex.Add(Result);
end;
procedure TObjGraf.ProcPCnxMov(x0, y0, ancho0, alto0: Single);
begin

end;
//Inicialización
constructor TObjGraf.Create(mGraf: TMotGraf);
begin
  inherited Create;
  erased := false;
  v2d := mGraf;   //asigna motor gráfico
  visible := true;
  width := 100;   //width por defecto
  height := 100;    //height por defecto
  fx := 100;
  fy := 100;
  PtosControl1:= TPtosControl.Create(True);   //Crea lista con administración de objetos
  PtosControl2:= TPtosControl.Create(True);   //Crea lista con administración de objetos
  PtosConex  := TPtosConex.Create(true);
  Selected   := False;
  Marcado    := False;
  Proceso    := false;
  DibSimplif := false;
  Highlight  := true;
  //Crea puntos de control estándar. Luego se pueden eliminar fy crear nuevos o modificar
  //estos puntos de control.
  pcTOPLEFT := AddPtoControl2D(TD_SUP_IZQ, TD_SUP_IZQ);
  pc_SUP_CEN := AddPtoControl2D(TD_SUP_CEN, TD_SUP_CEN);
  pc_SUP_DER := AddPtoControl2D(TD_SUP_DER, TD_SUP_DER);
  pc_CEN_IZQ := AddPtoControl2D(TD_CEN_IZQ, TD_CEN_IZQ);
  pc_CEN_DER := AddPtoControl2D(TD_CEN_DER, TD_CEN_DER);
  pc_INF_IZQ := AddPtoControl2D(TD_INF_IZQ, TD_INF_IZQ);
  pc_INF_CEN := AddPtoControl2D(TD_INF_CEN, TD_INF_CEN);
  pc_INF_DER := AddPtoControl2D(TD_INF_DER, TD_INF_DER);
  //Crea puntos de control para formas 1D
  pcBEGIN   := AddPtoControl1D(TD_BEGIN, TD_BEGIN);
  pcEND     := AddPtoControl1D(TD_END, TD_END);
  //Comportamiento por defecto
  behav := behav2D;
end;
destructor TObjGraf.Destroy;
begin
  PtosControl1.Free;
  PtosControl2.Free;
  PtosConex.Free;
  inherited Destroy;
end;

end.


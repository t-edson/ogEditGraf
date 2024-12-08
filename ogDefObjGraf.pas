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
               --> TPtoTerm --(Se incluyen en)-----------
              |                                          |
               --> TogButton --(Se pueden incluir en)----
              |                                          |
               --> TogScrollBar -(Se pueden incluir en)--

}
unit ogDefObjGraf;
{$mode objfpc}{$H+}
//{$DEFINE debugmode}
interface
uses
  Classes, Controls, SysUtils, Fgl, Graphics, GraphType, LazUtilities, Types,
  math, ExtCtrls, LCLProc, ogMotGraf2D, ogBasic;

const
  ANCHO_MIN = 0;    //Ancho mínimo de objetos gráficos en pixels (Coord Virtuales)
  ALTO_MIN = 0;     //Alto mínimo de objetos gráficos en Twips (Coord Virtuales)

type
  TBehave = (
    behav1D,  //De una dimensión (línea)
    behav2D   //De dos dimensiones
  );
  { TObjVisible }
  //Clase base para todos los objetos visibles
  TObjVisible = class
  private
    procedure SetAxisX(AValue: Single);
    procedure SetAxisY(AValue: Single);
  protected
    v2d       : TMotGraf;  //motor gráfico
    fAxisX, fAxisY: Single;  //Coordenadas virtuales del Eje
    Xant  ,Yant : Integer;   //coordenadas anteriores
    baseAngle: Single;      //Ángulo al iniciar una rotación
  public  //Contenedor de la forma (Cuadro de selección)
    //Cuadro de selección
    Width     : Single;    //Ancho
    Height    : Single;    //Alto
    property AxisX: Single read fAxisX write SetAxisX;
    property AxisY: Single read fAxisY write SetAxisY;
  public
    //Id        : Integer;   //Identificador del Objeto. No usado por la clase. Se deja para facilidad de identificación.
    Selected  : Boolean;   //Indica si el objeto está seleccionado
    Visible   : boolean;   //Indica si el objeto es visible
    procedure Locate(x0, y0: Single); virtual; //Fija posición  ¿Realmente es útil?
    function StartMove(xr, yr: Integer): Boolean;
    constructor Create(mGraf: TMotGraf); virtual;
    destructor Destroy; override;
  end;

  TPosicPCtrol = (   //Tipo de desplazamiento de punto de control
    TD_SIN_POS,  //sin posición. No se reubicará automáticamente
    //Puntos de dimensionamiento en 2D
    TD_TOP_IZQ,  //superior izquierda, desplaza ancho (por izquierda) y alto (por arriba)
    TD_TOP_CEN,  //superior central, desplaza alto por arriba
    TD_TOP_DER,  //superior derecha, desplaza ancho (por derecha) y alto (por arriba)

    TD_CEN_IZQ,  //central izquierda, desplaza ancho (por izquierda)
    TD_CEN_DER,  //central derecha, desplaza ancho (por derecha)

    TD_BOT_IZQ,  //inferior izquierda
    TD_BOT_CEN,  //inferior central
    TD_BOT_DER,  //inferior izquierda

    //Punto de rotación
    TD_ROTATE    //POr defecto en la esuina superior derecha
    );

  TPtoCtrl = class;
  TPtoConx = class;
  //Eventos para dimensionar forma
  TEvReqDimen2D = procedure(newX, newY, newWidth, newHeight: Single) of object;
  TEvPCReqPosition = procedure(target: TPtoCtrl; dx, dy: Single; wishX, wishY: Single) of object;
  TEvPCconnect = procedure(pCtl: TPtoCtrl; pCnx: TPtoConx) of object;
  //Ícono de punto de control
  TPtoCtrlIco = (pciSquare,   //Cuadrado
                 pciCircle,   //Círculo
                 pciIcon0     //Ícono 0 de la propiedad ImageList de v2d.
                 );
  TObjGraf = class;

  { TPtoCtrl }
  {Define al objeto Punto de Control.}
  TPtoCtrl = class(TObjVisible)
  private
    function GetQuadrant: byte;
    procedure SetQuadrant(AValue: byte);
  public //Identificación
    id_pCtrl   : (PTO_CTRL, PTO_TERM);  //Identifica a las clases
    idIcon     : TPtoCtrlIco;   {Forma gráfica del punto de control.}
    function isTerminal: Boolean; inline; //Indica si es un punto terminal
  public  //Atributos generales
    pAxisX     : Integer;      //Ubicación física en pantalla
    pAxisY     : Integer;      //Ubicación física en pantalla
    relPosition: TPosicPCtrol;  {Posición del Punto de Control con respecto a su objeto
                                contenedor.}
    mousePtr   : TCursor;       //Tipo de puntero del mouse
    Parent     : TObjGraf;      //Referencia al objeto contenedor
    OnChangePosition: TEvPCReqPosition;  //Requiere dimensionamiento en modo 1D
    property Quadrant: byte read GetQuadrant write SetQuadrant;
    procedure Draw();
    procedure StartMove(xr, yr: Integer; xIni, yIni, angIni, widthIni,
      heighIni: Single);
    procedure MouseMove(xr, yr: Integer);  //Dimensiona las variables indicadas
    function IsSelectedBy(xp, yp: Integer):boolean;
    procedure Locate(x0, y0: Single);
    procedure LocateP(x0, y0: Integer); //Fija ubicación en pantalla
    procedure LocateInParent;
  public //Inicialización
    {Valores iniciales de la forma padre (Parent), al iniciar el redimensionado o rotación
    con el punto de control}
    x0, y0  : Single;
    angle0  : Single;
    {Dimensiones iniciales de la forma padre (Parent), al iniciar el dimensionado con el
    punto de control}
    width0, height0: Single;
    constructor Create(Parent0: TObjGraf; PosicPCtrol: TPosicPCtrol;
      mousePtr0: TCursor; ChangePosition: TEvPCReqPosition); reintroduce; virtual;
  end;
  TPtosControl = specialize TFPGObjectList<TPtoCtrl>;  //Lista para gestionar los puntos de control

  { TPtoTerm }
  {Define al objeto Punto terminal, como una especialización de TPtoCtrl.}
  TPtoTerm = class(TPtoCtrl)
  public  //Propiedades de conexión
    OnConnect   : TEvPCconnect; //Se conecta a un punto de conexión
    OnDisconnect: TEvPCconnect; //Se desconecta de un punto de conexión
    ConnectedTo : TPtoConx;     //Punto de conexión al cual se encuentra conectado
    procedure Disconnect;
    constructor Create(Parent0: TObjGraf; PosicPCtrol: TPosicPCtrol;
      mousePtr0: TCursor; ChangePosition: TEvPCReqPosition); override;
  end;
  TPtosTerminal = specialize TFPGObjectList<TPtoTerm>;  //Lista para gestionar los puntos de control

  { TPtoConx }
  {Define al objeto Punto de Conexión.}
  TPtoConx = class(TObjVisible)
  public
    pAxisX     : Integer;      //Ubicación física en pantalla
    pAxisY     : Integer;      //Ubicación física en pantalla
    procedure Draw;
    procedure Mark;
    procedure StartMove(xr, yr: Integer; xIni, yIni, widthIni, heightIni: Single);
    procedure Mover(xr, yr: Integer);  //Dimensiona las variables indicadas
    function IsSelectedBy(xp, yp: Integer; accuracy: integer=0): boolean;
    procedure Locate(x0, y0: Single);
    procedure Relocate();
  public  //Parámetros de la fórmula de ubicación
    locX: TLocExp;     //Expresión que define la ubicación horizontal
    locY: TLocExp;     //Expresión que define la ubicación horizontal
    {Las fórmulas de ubicación definen cómo debe actualizarse esa ubicación cuando
    cambia el ancho o el alto, del objeto padre.
    Las fórmulas soportadas actualmente, son las que soporta "TLocExp".}
  private
    pointerTyp : Integer;  //Tipo de puntero
  public
    Marked     : boolean;  //Indica que el punto debe marcarse porque el ratón pasó por encima
    ptosTermin : TPtosTerminal; //Puntos terminal a los que se encuentra enganchado.
    Parent     : TObjGraf;     //Reference to object container
    data       : TObject;      //Unused field. Can be used for the user.
    procedure ConnectTo(pTerm: TPtoTerm);
    procedure DisconnectFrom(pTer: TPtoTerm);
    procedure Disconnect;
  public //Inicialización
    x0, y0, width0, height0: Single;  //valores objetivo para las dimensiones
    constructor Create(mGraf: TMotGraf); override;
    destructor Destroy; override;
  end;
  TPtosConex = specialize TFPGObjectList<TPtoConx>;  //Lista para gestionar los puntos de control

  TEventSelec = procedure(obj: TObjGraf) of object; //Procedimiento-evento para seleccionar
  TEventReqMouCur = procedure(TipPunt: Integer) of object; //Procedimiento-evento para cambiar puntero

  { TObjGraf }
  {Este es el Objeto padre de todos los objetos gráficos visibles que son administrados por
   el motor de edición.}
  TObjGraf = class(TObjVisible)
  private
    Fangle: Single;
    FlocAxisX: Single;
    FlocAxisY: Single;
    function GetXCent: Single;  //Coordenada AxisX central del objeto.
    function GetYCent: Single;  //Coordenada Ycentral del objeto
    procedure PtoCtl_ChangePosition(target: TPtoCtrl; dx, dy: Single; wishX,
      wishY: Single);
    procedure Setangle(AValue: Single);
    procedure SetlocAxisX(AValue: Single);
    procedure SetlocAxisY(AValue: Single);
  public //Manejo de la geometría
    {Contenedor principal que almacena los puntos que definen la geometría de la forma.
    Los puntos aquí definidos, se expresan en coordenadas virtuales (xv, yv) que pueden
    ser decimales.
    La geometría (los puntos de "geometry")se expresa con respecto al cuadro de selección.
    }
    geometry: TOgPoints;
    //Agrega un punto a la geometría
    function AddPoint(x0, y0: Single): TOgPoint;
  public //Propiedades geométricas de la forma
    {Contenedor con las coordenadas físicas o de pantalla (obtenidas a partir de
    "geometry") que pueden dibujarse directamente en el Canvas. Se calculan, después
    de llamar a Transform()}
    points  : array of TPoint;  //Puntos
    //Propiedades heredadas
    //Width     : Single;    //Ancho
    //Height    : Single;    //Alto
    {Las propiedades AxisX e AxisY definen el eje de giro de la forma que normalmente
    cae en el centro de la forma, pero su posición exacta con respecto a la forma, está
    definida por las propiedades locAxisX y locAxisY}
    //property AxisX: Single read fAxisX write SetAxisX;
    //property AxisY: Single read fAxisY write SetAxisY;
    {Desplazamiento relativo al cuadro de selección del centro de giro.
    El cuadro de selección de la forma está definido por las coordenadas
    (AxisX-locAxisX, AxisY-locAxisY)-(AxisX-locAxisX + Width, AxisY-locAxisY + Height)
    Este cuadro de selección se verá afectado si el ángulo de giro es diferente de cero}
    property locAxisX: Single read FlocAxisX write SetlocAxisX;
    property locAxisY: Single read FlocAxisY write SetlocAxisY;
    {Ángulo de giro de la forma}
    property angle: Single read Fangle write Setangle;
  public  //Posición y Tamaño
    property XCent: Single read GetXCent;
    property YCent: Single read GetYCent;
    procedure Transform(UpdatePCtrls: Boolean);
    procedure ReLocate(newX, newY: Single; UpdatePCtrls: boolean=true); virtual;
    procedure ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean=true);
      virtual; //Reconstruye la geometría del objeto
    procedure Rotate(newAngle: Single; UpdatePCtrls: boolean = true); virtual;
    procedure ReLocateSize(newX, newY, newWidth, newHeight: Single;
      UpdatePCtrls: boolean=true);
    procedure Draw; virtual;  //Dibuja el objeto gráfico
  public
    behav      : TBehave;   //Indica si la forma es de 1D o 2D.
    Name       : String;    //Identificación del objeto
    SizeLocked : boolean;   //Protege al objeto de redimensionado
    PosLocked  : Boolean;   //Indica si el objeto está bloqueado para movimiento
    SelLocked  : Boolean;   //Indica si el objeto está bloqueado para selección
    FillColor  : TColor;    //Color de relleno
    Proceso    : Boolean;   //Bandera
    Resizing   : boolean;   //Indica que el objeto está dimensionándose
    Erased     : boolean;   //Bandera para eliminar al objeto
    procedure Selec;        //Método único para seleccionar al objeto
    procedure Deselec;      //Método único para quitar la selección del objeto
    procedure Delete;       //Método para eliminar el objeto
    function IsSelectedBy(xr, yr:integer): Boolean; virtual;
  public      //Eventos del ratón
    procedure StartMove(xr, yr : Integer);
    procedure MouseMove(xr, yr : Integer; nobjetos : Integer); virtual;
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
       xp, yp: Integer); virtual;  //Metodo que funciona como evento mouse_down
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
       xp, yp: Integer; solto_objeto: Boolean); virtual;
    procedure MouseOver(Sender: TObject; Shift: TShiftState; xp, yp: Integer); virtual;
    procedure MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
                 MousePos: TPoint; var Handled: Boolean); virtual;
  public  //Marcado y Selección
    Highlight  : Boolean;   //Indica si permite el resaltado del objeto
    Marked     : Boolean;   //Indica que está marcado, porque el ratón pasa por encima
    DibSimplif : Boolean;   //Indica que se está en modo de dibujo simplificado
    pMarkRect  : TRect;     {Rectángulo de marcado. Similar al rectángulo de
                            selección pero siempre se dibuja en horizontal}
    selRectan  : array of TPoint; //Rectángulo de selección
    state      : (ogsNormal, ogsResizing);  //Estado del objeto
    lblResize  : String;    //Etiqueta de diemnsionado
  public  //Tipos disponibles para el usuario
    Tipo        : Integer;   //Tipo de objeto. No usado por la librería. Queda para el usuario.
    Data        : string;    //Dato adicional. No usado por la librería. Queda para el usuario.
    Obj         : pointer;   //Dato adicional. No usado por la librería. Queda para el usuario.
  public //Eventos de la clase
    OnRelocate : procedure of object;
    OnResize   : procedure of object;
    OnRotate   : procedure of object;
    OnSelec    : TEventSelec;
    OnDeselec  : TEventSelec;
    OnReqMouCur: TEventReqMouCur;  //Requerimiento para cambiar el puntero del ratón
  public //Puntos de Control
    curPntCtl   : TPtoCtrl;  //Punto de Control actual
    {Los puntos de control son los que se pueden mover independientemente AxisY tienen
    efecto sobre la posición AxisY/o el tamaño de la forma.}
    //Puntos de control por defecto
    pcTOP_LEF: TPtoCtrl;
    pcTOP_CEN: TPtoCtrl;
    pcTOP_RIG: TPtoCtrl;
    pcCEN_LEF: TPtoCtrl;
    pcCEN_RIG: TPtoCtrl;
    pcBOT_LEF: TPtoCtrl;
    pcBOT_CEN: TPtoCtrl;
    pcBOT_RIG: TPtoCtrl;
    //Puntos de rotación
    pcROTATE : TPtoCtrl;
    //Puntos terminales. Usado para formas 1D
    pcBEGIN  : TPtoTerm;
    pcEND    : TPtoTerm;
    //Contenedores de puntos
    PtosTerminal: TPtosTerminal;  //Lista de puntos de control en modo 1D
    PtosControl : TPtosControl;  //Lista de puntos de control en modo 2D
    function SelecPtoControl(xp, yp: integer): TPtoCtrl;
    function AddPtoTerminal(PosicPCtrol: TPosicPCtrol; mousePtr: TCursor
      ): TPtoTerm;
    function AddPtoControl(PosicPCtrol: TPosicPCtrol; mousePtr: TCursor): TPtoCtrl;
  public //Puntos de conexión
    ShowPtosConex: boolean;   //Indica si se mostrarán los puntos de conexión
    PtosConex  : TPtosConex;  //Lista de puntos de conexión
    function AddPtoConex(xOff, yOff: Single): TPtoConx; virtual;
    function SelectConnectionPoint(xp, yp: integer; accuracy: integer=0): TPtoConx;
    function MarkConnectionPoint(xp, yp: integer; accuracy: integer = 0): TPtoConx;
    procedure ClearMarkConnectionPoints;
    function ConnectionPointMarked: TPtoConx;
  public //Inicialización
    constructor Create(mGraf: TMotGraf); override;
    destructor Destroy; override;
  end;

  function PointSelectSegment(xp, yp, x0, y0, x1, y1: integer): Boolean;

var   //Colores a usar para los elementos
  colObjMarked: TColor;     //Color de la marca de los objetos
  colSelRectan: TColor;     //Color del rectángulo de selección
  colBckToolTip: TColor;    //Color del fondo del "ToolTip" de los objetos.
  colCtlPoints: TColor;     //Color de los puntos de control
  colCnxPoints: TColor;     //Color de los puntos de conexión
  {$IFDEF debugmode} dProf: integer; {$ENDIF}

implementation
const
  ANC_PCT2 = 5;       //mitad del ancho de punto de control
  ANC_PCN2 = 4;

function PointSelectSegment(xp, yp, x0, y0, x1, y1: integer): Boolean;
{Indica si el punto (xp, yp) selecciona un segmento de recta con una tolerancia
de 5 pixeles.
El segmento se define con los puntos (x0, y0) y (x1, y1).
Las coordenadas son de pantalla.}
const   //Tolerancia en pixeles
  DSEL = 5;
var
  dx, dy: Int16;
begin
  {No debería ser necesario actualizar las coordenadas de pantalla de P0 y P1, ya que
  si esta recta se mostró en pantalla, es porque se actualizaron sus coordenadas de
  pantalla:
  v2d.XYpant(P0);
  v2d.XYpant(P1);
  }
  if x0 = x1 then begin  //Caso recta vertical
     if abs(x0 - xp)>DSEL then exit(false);  //excede distancia horizontal
     if y0 = y1 then begin  //Caso de un punto
       Result := (abs(y0 - yp) < DSEL);
     end else begin //Caso de recta vertical común
       if y0 > y1 then begin  //P0 arriba
          Result := (yp<y0+DSEL) and (yp>y1-DSEL);
       end else begin               //P1 arriba
          Result := (yp<y1+DSEL) and (yp>y0-DSEL);
       end;
     end;
  end else if x0 < x1 then begin  //P0 a la izquierda
     if xp<x0-DSEL then exit(false);  //escapa de límite
     if xp>x1+DSEL then exit(false);  //escapa de límite
     //Simplifica la comparación, viendo solo una distancia vertical
//     a := (y1 - y0)/(x1 - x0);  //pendiente
//     b := y0 - a*x0;  //Define ecuación de la recta y=ax+b
//     Result := abs(a*xp + b - yp) < DSEL;
     //Forma alternativa, sin divisiones
     dx := x1 - x0;   //siempre positivo
     dy := y1 - y0;   //positivo o negativo
     if (yp<y1) and (yp<y0) then exit(false);  //Muy arriba
     if (yp>y1) and (yp>y0) then exit(false);  //Muy abajo
     if abs(dy)<dx then begin
       Result := abs( (xp - x0)*dy - (yp-y0)*dx ) < DSEL * dx;
     end else begin //abs(dy), es mayor a dx
       Result := abs( (xp - x0)*dy - (yp-y0)*dx ) < DSEL * abs(dy);
     end;
  end else begin                        //P1 a la izquierda
     if xp<x1-DSEL then exit(false);  //escapa de límite
     if xp>x0+DSEL then exit(false);  //escapa de límite
     //Define ecuación de la recta y=ax+b
//     a := (y0 - y1)/(x0 - x1);  //pendiente
//     b := y1 - a*x1;
//     Result := abs(a*xp + b - yp) < DSEL;
      dx := x0 - x1;   //siempre positivo
      dy := y0 - y1;   //positivo o negativo
      if (yp<y1) and (yp<y0) then exit(false);  //Muy arriba
      if (yp>y1) and (yp>y0) then exit(false);  //Muy abajo
      if abs(dy)<dx then begin
        Result := abs( (xp - x1)*dy - (yp-y1)*dx ) < DSEL * dx;
      end else begin //abs(dy), es mayor a dx
        Result := abs( (xp - x1)*dy - (yp-y1)*dx ) < DSEL * abs(dy);
      end;
  end;
end;

{ TPtoTerm }
procedure TPtoTerm.Disconnect;
{Desconecta la el punto de control al punto de conexión que pudiera estar ligado.}
begin
  if ConnectedTo<>nil then begin
     ConnectedTo.DisconnectFrom(self);
     ConnectedTo := nil;
  end;
end;
constructor TPtoTerm.Create(Parent0: TObjGraf; PosicPCtrol: TPosicPCtrol;
  mousePtr0: TCursor; ChangePosition: TEvPCReqPosition);
begin
  inherited Create(Parent0, PosicPCtrol, mousePtr0, ChangePosition);
  id_pCtrl := PTO_TERM;
end;

{ TObjVisible }
procedure TObjVisible.SetAxisX(AValue: Single);
begin
  if fAxisX=AValue then Exit;
  fAxisX:=AValue;
end;
procedure TObjVisible.SetAxisY(AValue: Single);
begin
  if fAxisY=AValue then Exit;
  fAxisY:=AValue;
end;
procedure TObjVisible.Locate(x0, y0: Single);
begin
  fAxisX := x0;
  fAxisY := y0;
end;
function TObjVisible.StartMove(xr, yr: Integer): Boolean;
begin
  Result := false;  //Por el momento, no devuelve valor
  if not visible then exit;    //validación
  //captura posición actual, para calcular los desplazamientos
  Xant := xr;
  Yant := yr;
end;
constructor TObjVisible.Create(mGraf: TMotGraf);
begin
  v2d := mGraf;
  visible := true;
end;
destructor TObjVisible.Destroy;
begin
  inherited Destroy;
end;
// TPtoCtrl
function TPtoCtrl.GetQuadrant: byte;
{Devuelve el cuadrante, en el sentido geométrico, de la posición del Putno de Control con respecto al centro de
su objeto contenedor :
             |
       2     |     1
             |
   <-------------------->
             |
       3     |     4
             |
   }
begin
  case relPosition of
  TD_TOP_IZQ: exit(2);
  TD_TOP_CEN: exit(1);
  TD_TOP_DER: exit(1);

  TD_CEN_IZQ: exit(2);
  TD_CEN_DER: exit(4);

  TD_BOT_IZQ: exit(3);
  TD_BOT_CEN: exit(3);
  TD_BOT_DER: exit(4);
  else
    exit(1);
  end;
end;
procedure TPtoCtrl.SetQuadrant(AValue: byte);
begin
  case AValue of
  1: relPosition := TD_TOP_DER;
  2: relPosition := TD_TOP_IZQ;
  3: relPosition := TD_BOT_IZQ;
  4: relPosition := TD_BOT_DER;
  end
end;
function TPtoCtrl.isTerminal: Boolean;
begin
  exit(id_pCtrl = PTO_TERM);
end;
procedure TPtoCtrl.Draw();
{Dibuja el Punto de control en la posición definida. Se supone que el punto de control
debe tener actualizadas sus campos pAxisX y pAxisY.}
var
  xp, yp: Integer;
begin
   if not visible then exit;    //validación
   xp := pAxisX;
   yp := pAxisY;
   If          idIcon = pciSquare then begin
     v2d.SetBrush(colCtlPoints);
     v2d.Canvas.FillRect(xp - ANC_PCT2, yp - ANC_PCT2,
                xp + ANC_PCT2, yp + ANC_PCT2);  //siempre de tamaño fijo
   end else if idIcon = pciCircle  then begin
     v2d.SetBrush(colCtlPoints);
     v2d.Canvas.Ellipse(xp - ANC_PCT2, yp - ANC_PCT2,
                        xp + ANC_PCT2, yp + ANC_PCT2);
   end else If idIcon = pciIcon0 then begin
     //El ícono debe ser de 16 bits de ancho
     v2d.DrawIcon(xp-8, yp-8, 0);
   end;
end;
procedure TPtoCtrl.StartMove(xr, yr: Integer; xIni, yIni, angIni, widthIni, heighIni: Single);
//Procedimiento para procesar el evento StartMove del punto de control
begin
   if not visible then exit;    //validación
   inherited StartMove(xr,yr);
   {Captura los valores iniciales de la geometría, apra poder operar sobre esas
   dimensiones cuando se intente hacer los dimensionamientos.}
   x0 := xIni;
   y0 := yIni;
   angle0 := angIni;
   width0 := widthIni;
   height0 := heighIni;
end;
procedure TPtoCtrl.MouseMove(xr, yr: Integer);
//Realiza el cambio de las variables indicadas de acuerdo al tipo de control y a
//las variaciones indicadas (dx, dy)
var
  dx, dy, wishX, wishY: Single;
begin
  if not visible then exit;    //validación
  dx := (xr - Xant) / v2d.Zoom;     //obtiene desplazamiento absoluto
  dy := (yr - Yant) / v2d.Zoom;     //obtiene desplazamiento absoluto
  {Comunica que se requiere cambiar la posición del punto de control, para que el
  objeto gráfico padre tome la decisión sobre el cambio}
  v2d.XYvirt(xr, yr, wishX, wishY);
  OnChangePosition(Self, dx, dy, wishX, wishY);
end;
function TPtoCtrl.IsSelectedBy(xp, yp: Integer): boolean;
//Indica si las coordenadas de pantalla seleccionan al punto de control
begin
   Result := False;
   if not visible then exit;    //validación
   //compara en coordenadas de pantalla
   if (xp >= pAxisX - ANC_PCT2) and (xp <= pAxisX + ANC_PCT2) and
      (yp >= pAxisY - ANC_PCT2) and (yp <= pAxisY + ANC_PCT2) then
        Result := True;
end;
procedure TPtoCtrl.Locate(x0, y0: Single);
{Ubica coordenadas virtualmente al punto de control. También actualiza coordenadas físicas}
begin
  fAxisX := x0;
  fAxisY := y0;
  v2d.XYpant(x0, y0, pAxisX, pAxisY);
end;
procedure TPtoCtrl.LocateP(x0, y0: Integer);
{Define las coordenadas en pantalla, que es donde se dibujará el control. No actuliza las
coordenadas virtuales.}
begin
  pAxisX := x0;
  pAxisY := y0;
end;
procedure TPtoCtrl.LocateInParent;
{Ubica al Punto de control en su posición respectiva con respecto al objeto padre.
La ubicación final del punto de control depende de:
- El atributo "relPosition".
- El cuadro de selección del objeto padre.}
var
  xp0, yp0, xp2, yp2: Integer;
  xp1, yp1, xp3, yp3: Integer;
begin
 xp0 := Parent.selRectan[0].X;
 yp0 := Parent.selRectan[0].Y;
 xp1 := Parent.selRectan[1].X;
 yp1 := Parent.selRectan[1].Y;
 xp2 := Parent.selRectan[2].X;
 yp2 := Parent.selRectan[2].Y;
 xp3 := Parent.selRectan[3].X;
 yp3 := Parent.selRectan[3].Y;
 case relPosition of
 TD_TOP_IZQ:  //superior izquierda, desplaza ancho (por izquierda) AxisY height (por arriba)
   LocateP(xp0, yp0);
 TD_TOP_CEN:  //superior central, desplaza Parent.height por arriba
   LocateP((xp0+xp1) div 2, (yp0+yp1) div 2);
 TD_TOP_DER:  //superior derecha, desplaza ancho (por derecha) AxisY Parent.height (por arriba)
   LocateP(xp1, yp1);

 TD_CEN_IZQ:  //central izquierda, desplaza ancho (por izquierda)
   LocateP((xp0+xp3) div 2, (yp0+yp3) div 2);
 TD_CEN_DER:  //central derecha, desplaza ancho (por derecha)
   LocateP((xp1+xp2) div 2, (yp1+yp2) div 2);

 TD_BOT_IZQ:  //inferior izquierda
   LocateP(xp3, yp3);
 TD_BOT_CEN:  //inferior central
   LocateP((xp2+xp3) div 2, (yp2+yp3) div 2);
 TD_BOT_DER:   //inferior izquierda
   LocateP(xp2, yp2);

 TD_ROTATE:   //Esquina superior derecha
   LocateP(xp1+16, yp1-16);
 else
   //Otra ubicación, no lo reubica.
 end;
end;
constructor TPtoCtrl.Create(Parent0: TObjGraf; PosicPCtrol: TPosicPCtrol;
  mousePtr0: TCursor; ChangePosition: TEvPCReqPosition);
begin
  inherited Create(Parent0.v2d);
  Width  := 2*ANC_PCT2;
  Height := 2*ANC_PCT2;
  id_pCtrl := PTO_CTRL;
  Parent    := Parent0;
  relPosition := PosicPCtrol;  //Dónde aparecerá en el objeto
  mousePtr  := mousePtr0;    //El puntero del mouse
  OnChangePosition := ChangePosition;
  fAxisX :=0;
  fAxisY :=0;
end;
//////////////////////////////  TPtoConx //////////////////////////////
procedure TPtoConx.Draw;
//Draw the Connection point.
begin
  if not visible then exit;    //validación
  v2d.SetLine(colCnxPoints);
  v2d.Canvas.Line(pAxisX - ANC_PCN2+1, pAxisY - ANC_PCN2+1,
                  pAxisX + ANC_PCN2  , pAxisY + ANC_PCN2);
  v2d.Canvas.Line(pAxisX - ANC_PCN2+1, pAxisY + ANC_PCN2-1,
                  pAxisX + ANC_PCN2  , pAxisY - ANC_PCN2);
end;
procedure TPtoConx.Mark;
{Draw a Connection point highlighted.}
begin
  if not visible then exit;    //validación
  v2d.SetLine(colObjMarked, 2);
  v2d.Canvas.Frame(pAxisX - ANC_PCN2-1, pAxisY - ANC_PCN2-1,
                   pAxisX + ANC_PCN2+2, pAxisY + ANC_PCN2+2);
end;
procedure TPtoConx.StartMove(xr, yr: Integer; xIni, yIni, widthIni, heightIni: Single);
//Procedimiento para procesar el evento StartMove del punto de control
begin
  if not visible then exit;    //validación
  inherited StartMove(xr,yr);
  //captura los valores iniciales de las dimensiones
  x0 := xIni;
  y0 := yIni;
  width0 := widthIni;
  height0 := heightIni;
end;
procedure TPtoConx.Mover(xr, yr: Integer);
//Realiza el cambio de las variables indicadas de acuerdo al tipo de control y a
//las variaciones indicadas (dx, dy)
begin
  if not visible then exit;    //validación
//  dx := (xr - Xant) / v2d.Zoom;     //obtiene desplazamiento absoluto
//  dy := (yr - Yant) / v2d.Zoom;     //obtiene desplazamiento absoluto
//  Xant := xr; Yant := yr;   //actualiza coordenadas
end;
function TPtoConx.IsSelectedBy(xp, yp: Integer; accuracy: integer = 0): boolean;
//Indica si las coordenadas lo selecciona.
begin
  IsSelectedBy := False;
  if not visible then exit;    //validación
  //Compara en coordenadas de pantalla
  if (xp >= pAxisX - ANC_PCN2-accuracy) and (xp <= pAxisX + ANC_PCN2+accuracy) and
     (yp >= pAxisY - ANC_PCN2-accuracy) and (yp <= pAxisY + ANC_PCN2+accuracy) then
       IsSelectedBy := True;
end;
procedure TPtoConx.Locate(x0, y0: Single);
var
  pctl: TPtoCtrl;
begin
  fAxisX := x0;  //Ubicaicón sin giro
  fAxisY := y0;
  //Actualiza sus coordenadas de pantalla, y aplica giro a fAxisX y fAxisX.
  //v2d.XYpantR(x0, y0, Parent.AxisX, Parent.AxisY, Parent.angle, pAxisX, pAxisY);
  v2d.XYpantR2(fAxisX, fAxisY, Parent.AxisX, Parent.AxisY, Parent.angle, pAxisX, pAxisY);
  //Mueve puntos de control enganchados
  for pctl in ptosTermin do begin
     {Se llama al evento simulando un movimiento por Ratón. Esto solo funcionará en
     Puntos de Control 1D.
     Se pudo haber hecho solo: pctl.AxisX := AxisX; pctl.AxisY := AxisY;
     Pero esto no actualizaría la geometría de la forma}
     pctl.OnChangePosition(pctl, 0, 0, AxisX, AxisY);
  end;
end;
procedure TPtoConx.Relocate;
{Reubica el punto de conexión de acuerdo a los cambios que se hayan producido en la
ubicación o dimensionado del elemento padre.}
begin
  Locate(parent.AxisX - parent.locAxisX + locX.newVal(parent.width, parent.Height),
         parent.AxisY - Parent.locAxisY + locY.newVal(parent.width, parent.Height));
end;
procedure TPtoConx.ConnectTo(pTerm: TPtoTerm);
{Conecta a un punto de control.}
begin
  if pTerm.Parent = Self.Parent then begin
     {No debemos permitir que un punto de conexión se pueda conectar a su propio punto
     de control, porque produciría resultdaos inesperados.}
     exit;
  end;
  ptosTermin.Add(pTerm);
  pTerm.ConnectedTo := self;
  if pTerm.OnConnect<>nil then pTerm.OnConnect(pTerm, self);
end;
procedure TPtoConx.DisconnectFrom(pTer: TPtoTerm);
{Se desconecta de un punto de control.}
begin
  pTer.ConnectedTo := nil;
  ptosTermin.Remove(pTer);
  if pTer.OnDisconnect<>nil then pTer.OnDisconnect(pTer, self);
end;
procedure TPtoConx.Disconnect;
{Se desconecta de todos los puntos de control a los que se encuentra conectado.}
var
  pTerm: TPtoTerm;
begin
  //Usa while porque va a eliminar elementor
  while ptosTermin.Count>0 do begin
    pTerm := ptosTermin[0];
    DisconnectFrom(pTerm)
  end;
end;
constructor TPtoConx.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  Width := 2*ANC_PCT2;
  Height := 2*ANC_PCT2;
  fAxisX :=0;
  fAxisY :=0;
  pointerTyp := crSizeNW;  //No se usa
  {Crea lista para los puntos de control 1D que engancha. Pero solo gaurdará referencias
   no eliminará los objetos.}
  ptosTermin:= TPtosTerminal.Create(false);
end;
destructor TPtoConx.Destroy;
var
  pTer: TPtoTerm;
begin
  //Se desconecta de todos los puntos de control que pudieran estar conectados a
  //este punto de conexión.
  for pTer in ptosTermin do begin
    pTer.ConnectedTo := nil;
    //Hacer DisconnectFrom(pTer) no es necesario AxisY generará error por la forma como se explora a la lista
  end;
  ptosTermin.Destroy;
  inherited Destroy;
end;
{ TObjGraf }
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
procedure TObjGraf.StartMove(xr, yr: Integer);
//Procedimiento para procesar el evento StartMove de los objetos gráficos
//Se ejecuta al inicio de movimiento al objeto
var
  baseXp, baseYp: Single;
begin
  Xant := xr;
  Yant := yr;
  v2d.XYvirt(xr, yr, baseXp, baseYp);  //*** Mejor sería tener "baseXp, baseYp" como atributos TObjGraf
  baseAngle := -ArcTan2(baseYp- AxisY, baseXp - AxisX);
  Proceso := False;
  if not Selected then exit;   //para evitar que responda antes de seleccionarse
  //Busca si algún punto de control lo procesa
  curPntCtl := SelecPtoControl(xr,yr);
  if curPntCtl <> nil  then begin
      curPntCtl.StartMove(xr, yr, fAxisX, fAxisY, angle, width, height);     //prepara para movimiento fAxisY dimensionamiento
      if curPntCtl.isTerminal then TPtoTerm(curPntCtl).Disconnect;
      Proceso := True;      //Marcar para indicar al editor fAxisY a Mover() que este objeto procesará
                            //el evento fAxisY no se lo pasé a los demás que pueden estar seleccionados.
      Resizing := True; //Marca bandera
  end else begin
     //No se mueve ningún punto de control
     //Desconecta Puntos de Control 1D, por si estaban ligados.
     pcBEGIN.Disconnect;
     pcEND.Disconnect;
  end;
  { TODO : Verificar por qué, a veces se puede iniciar el movimiento del objeto cuando el puntero está en modo de dimensionamiento. }
end;
procedure TObjGraf.MouseMove(xr, yr: Integer; nobjetos: Integer);
{Metodo que funciona como evento MouseMove al objeto.
"nobjetos" es la cantidad de objetos que se mueven. Ususalmente es sólo uno}
var dx , dy: Single;
begin
    {$IFDEF debugmode} DebugLn(LineEnding + 'TObjGraf.MouseMove'); {$ENDIF}
//     If ArrastBoton Then Exit;       //Arrastrando botón  { TODO : Revisar }
//     If ArrastFila Then Exit;        //Arrastrando botón  { TODO : Revisar }
     If Selected Then begin
        v2d.ObtenerDesplaz2(xr, yr, Xant, Yant, dx, dy);
        if Proceso then begin
            //Algún elemento del objeto ha procesado el evento de movimiento
            if curPntCtl <> nil then begin
               //Hay un punto de control procesando el evento MouseMove
               if not SizeLocked then
                 curPntCtl.MouseMove(xr, yr);   //permite dimensionar el objeto
            end;
            {$IFDEF debugmode} DebugLn('  Algún elemento lo procesó'); {$ENDIF}
        end else begin //ningún elemento del objeto lo ha procesado, pasamos a mover todo el objeto
           {$IFDEF debugmode} DebugLn('  Relocate dx='+dx.ToString); {$ENDIF}
            ReLocate(fAxisX + dx, fAxisY + dy);  //reubica los elementos
            Proceso := False;
        end;
        Xant := xr; Yant := yr;
     End;
end;
function TObjGraf.IsSelectedBy(xr, yr:integer): Boolean;
//Devuelve verdad si la coordenada de pantalla (xr,yr) cae en un punto tal
//que "lograria" la seleccion de la forma.
var
  xv , yv , x1, y1: Single; //corodenadas virtuales
begin
    v2d.XYvirt(xr, yr, xv, yv);
    IsSelectedBy := False; //valor por defecto
    //verifica área de selección
    x1 := fAxisX-locAxisX;
    y1 := fAxisY-locAxisY;
    if (xv > x1 - 1) And (xv < x1 + width + 1) And
       (yv > y1 - 1) And (yv < y1 + height + 1) then begin
      IsSelectedBy := True;
    end;
    if Selected then begin   //Ub objeto seleccionado, tiene un área mayor de selección
      if SelecPtoControl(xr,yr) <> NIL then IsSelectedBy := True;
    end;
End;
procedure TObjGraf.MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
//Metodo que funciona como evento "MouseDown"
begin
//  CapturoEvento := NIL;
  Proceso := False;
  If IsSelectedBy(xp, yp) Then begin  //sólo responde instantáneamente al caso de selección
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
        If IsSelectedBy(xp, yp) Then
            Proceso := True;
    end;
    //Restaura puntero si estaba dimensionándose por si acaso
    if Resizing then begin
       if not curPntCtl.IsSelectedBy(xp,yp) then //se salio del foco
          if Assigned(OnReqMouCur) then OnReqMouCur(crDefault);  //pide retomar el puntero
       Resizing := False;    //quita bandera, por si estaba Resizing
       exit;
    end;
end;
procedure TObjGraf.MouseOver(Sender: TObject; Shift: TShiftState; xp, yp: Integer);
//Respuesta al evento MouseMove. Se debe recibir cuando el Mouse pasa por encima del objeto
var pc: TPtoCtrl;
begin
    if not Selected then Exit;
    //Aquí se supone que tomamos el control porque está Selected
    //Procesa el cambio de puntero.
    if Assigned(OnReqMouCur) then begin
        pc := SelecPtoControl(xp,yp);
        if pc<> NIL then
           OnReqMouCur(pc.mousePtr)  //cambia a supuntero
        else
           OnReqMouCur(crDefault);
    end;
end;
procedure TObjGraf.MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin

end;
//Posición y Tamaño
function TObjGraf.GetXCent: Single;
begin
   Result := fAxisX + width / 2;
end;
function TObjGraf.GetYCent: Single;
begin
   Result := fAxisY + height / 2;
end;
procedure TObjGraf.Transform(UpdatePCtrls: Boolean);
{Calcula la parte visual de un objeto gráfico, a partir del arreglo "geometry".
Las coordenadas calculadas se almacenan en points[] y corresponden a coordenadas
físicas o de pantalla, que pueden dibujarse directamente.
También se actualizan las áreas "pMarkRect" y "selRectan".}
var
  i: Integer;
  x1, y1: Single;
  xp, yp, xmin, xmax, ymin, ymax: Integer;
begin
  SetLength(points, geometry.Count);   //dimensiona
  x1 := AxisX - locAxisX;
  y1 := AxisY - locAxisY;
  //Transforma puntos y calcula máximos y mínimos
  if geometry.Count = 0 then begin
    xmin := 0; ymin := 0;
    xmax := 0; ymax := 0;
  end else begin
    xmin :=  100000; ymin :=  100000;
    xmax := -100000; ymax := -100000;
  end;
  for i:= 0 to geometry.Count-1 do begin
    //xp := v2d.XPant(geometry[i].x + x1);
    //yp := v2d.YPant(geometry[i].y + y1);
    v2d.XYpantR(geometry[i].x + x1, geometry[i].y + y1, AxisX, AxisY, angle, xp, yp);
    points[i].x := xp;
    points[i].y := yp;
    if xp<xmin then xmin := xp;
    if yp<ymin then ymin := yp;
    if xp>xmax then xmax := xp;
    if yp>ymax then ymax := yp;
  end;
  //Aprovecha para obtener área de resaltado
  pMarkRect.Left := xmin;
  pMarkRect.Top := ymin;
  pMarkRect.Right := xmax;
  pMarkRect.Bottom := ymax;
  //Actualiza área de selección
  //selRectan[0].X := v2d.XPant(x1);
  //selRectan[0].Y := v2d.XPant(y1);
  v2d.XYpantR(x1, y1, AxisX, AxisY, angle, selRectan[0].X, selRectan[0].Y);
  //selRectan[1].X := v2d.XPant(x1 + Width);
  //selRectan[1].Y := v2d.XPant(y1);
  v2d.XYpantR(x1+Width, y1, AxisX, AxisY, angle, selRectan[1].X, selRectan[1].Y);
  //selRectan[2].X := v2d.XPant(x1 + Width);
  //selRectan[2].Y := v2d.XPant(y1 + Height);
  v2d.XYpantR(x1+Width, y1+Height, AxisX, AxisY, angle, selRectan[2].X, selRectan[2].Y);
  //selRectan[3].X := v2d.XPant(x1);
  //selRectan[3].Y := v2d.XPant(y1 + Height);
  v2d.XYpantR(x1, y1+Height, AxisX, AxisY, angle, selRectan[3].X, selRectan[3].Y);

  //Reubica todos los puntos de control
  if UpdatePCtrls then begin
    pcTOP_LEF.LocateInParent;
    pcTOP_CEN.LocateInParent;
    pcTOP_RIG.LocateInParent;
    pcCEN_LEF.LocateInParent;
    pcCEN_RIG.LocateInParent;
    pcBOT_LEF.LocateInParent;
    pcBOT_CEN.LocateInParent;
    pcBOT_RIG.LocateInParent;
    pcROTATE.LocateInParent;
    pcBEGIN.LocateInParent;
    pcEND.LocateInParent;
    //Actualiza coordenadas virtuales de los puntos terminales, porque LocateInParent()
    //no lo hace. Solo cambia pAxisY y pAxisX.
    pcBEGIN.AxisX := v2d.Xvirt(pcBEGIN.pAxisX, pcBEGIN.pAxisY);
    pcBEGIN.AxisY := v2d.Yvirt(pcBEGIN.pAxisX, pcBEGIN.pAxisY);
    pcEND.AxisX := v2d.Xvirt(pcEND.pAxisX, pcEND.pAxisY);
    pcEND.AxisY := v2d.Yvirt(pcEND.pAxisX, pcEND.pAxisY);
  end;
end;
procedure TObjGraf.ReLocate(newX, newY: Single; UpdatePCtrls: boolean = true);
{Se usa para cambiar SOLAMENTE la ubicación del objeto}
var
  pCnx: TPtoConx;
begin
  {$IFDEF debugmode} Inc(dProf); DebugLn(Space(dProf) + 'TObjGraf.Relocate: '+ Self.Name+' at ' + fx.toString); {$ENDIF}
  fAxisX := newX;
  fAxisY := newY;
  //Reubica todos los puntos de conexión
  for pCnx in PtosConex do begin
    pCnx.Relocate();
  end;
  //Reubica los puntos geométricos de la forma. NO ES NECESARIO
  //for pGeo in geometry do begin
  //  pGeo.Relocate(newWidth, newheight);
  //end;

  Transform(UpdatePCtrls);  //Actualiza coordenadas de pantalla, y cuadro de selección

  if OnRelocate<>nil then OnRelocate;
  {$IFDEF debugmode} DebugLn(Space(dProf)+'TObjGraf.Relocate end'); Dec(dProf); {$ENDIF}
end;
procedure TObjGraf.ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean = true);
{Se usa para cambiar SOLAMENTE el tamaño del objeto}
var
  pCnx: TPtoConx;
  pGeo: TOgPoint;
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
  //Posiciona proporcionalmente a los puntos de conexión
  //debugln('fdx=%f fdy=%f', [fdx, fdy]);
  for pCnx in PtosConex do begin
    pCnx.Relocate();
  end;
  //Reubica los puntos geométricos de la forma
  for pGeo in geometry do begin
    pGeo.Relocate(newWidth, newheight);
  end;
  //Actualiza la posición del eje
  locAxisX := Width/2;     //Por ahora es fijo, pero se espera que se defina por fórmula más adelante
  locAxisY := Height/2;    //Por ahora es fijo

  Transform(UpdatePCtrls);  //Actualiza coordenadas de pantalla
  if OnResize<>nil then OnResize;
end;
procedure TObjGraf.Rotate(newAngle: Single; UpdatePCtrls: boolean = true);
var
  pCnx: TPtoConx;
begin
  if angle = newAngle then Exit;
  angle := newAngle;  //En radianes
  //Posiciona a los puntos de conexión rotados
  for pCnx in PtosConex do begin
    pCnx.Relocate();
  end;

  Transform(UpdatePCtrls);  //Actualiza coordenadas de pantalla
  if OnRotate<>nil then OnRotate;
end;
procedure TObjGraf.ReLocateSize(newX, newY, newWidth, newHeight: Single;
                                UpdatePCtrls: boolean = true);
{Se usa para atender los requerimientos de los puntos de control cuando quieren
cambiar el tamaño y/o la posición del objeto.}
var
  changeLocation, changeSize: Boolean;
begin
  {$IFDEF debugmode} Inc(dProf); DebugLn(Space(dProf)+'TObjGraf.ReLocateSize: '+ Self.Name); {$ENDIF}
  //Protección
  if newWidth < ANCHO_MIN then begin
     newWidth := ANCHO_MIN;
     newX := fAxisX;  //Mantiene AxisX, por si acaso
  end;
  if newHeight < ALTO_MIN then begin
     newHeight := ALTO_MIN;
     newY := fAxisY;  //Mantiene AxisY, por si acaso
  end;
  changeLocation := (newX<>fAxisX) or (newY<>fAxisY);
  changeSize := (newWidth<>width) or (newHeight<>Height);

  if changeLocation then begin
     ReLocate(newX, newY, UpdatePCtrls);       //Reubica
  end;
  if changeSize then begin
     ReSize(newWidth, newHeight, UpdatePCtrls);       //Reubica
  end;
  {$IFDEF debugmode} DebugLn(Space(dProf)+'TObjGraf.RelocateSize end'); Dec(dProf); {$ENDIF}
end;
procedure TObjGraf.Draw;
const tm = 3;
var
  pct : TPtoCtrl;
  pcn : TPtoConx;
  xt, yt: Integer;
begin
  //---------------Draw mark --------------
  if Marked and Highlight then begin
    v2d.SetPen(psSolid, 2, colObjMarked);   //RGB(128, 128, 255)
    v2d.Canvas.Frame(pMarkRect);
  end;
  //--------------- Draw control points--------------
  if Selected Then begin
    v2d.SetPen(psDot, 1, colSelRectan);   //RGB(128, 128, 255)
    v2d.Canvas.Polyline(selRectan);
    if behav = behav1D then begin
       for pct in PtosTerminal do pct.Draw;   //Dibuja puntos de control
    end else if behav = behav2D then begin
       for pct in PtosControl do pct.Draw;   //Dibuja puntos de control
    end;
  end;
  //Draw Connection Points
  if ShowPtosConex then begin
     for pcn in PtosConex do pcn.Draw;
  end;
  //if MarkConnectPoints then begin
    for pcn in PtosConex do if pcn.Marked then pcn.Mark;
  //end
  //Dibuja etiqueta informativa
  if state = ogsResizing then begin
    xt := pcBOT_CEN.pAxisX;
    yt := pcBOT_CEN.pAxisY + 10;
    v2d.Canvas.Font.Size := 10;
    v2d.Canvas.Font.Bold := false;
    v2d.SetBrush(colBckToolTip);
    v2d.Canvas.TextOut(xt, yt, lblResize);
  end;
end;
procedure TObjGraf.PtoCtl_ChangePosition(target: TPtoCtrl; dx, dy: Single;
                                wishX, wishY: Single);
{Un punto de control está solicitando reposicionamiento, lo que se supone, afecta
a la posición y/o el dimensionamiento de la forma.}
  procedure ReadQuadrant;
  begin
    if          (pcBEGIN.AxisX < pcEND.AxisX) and (pcBEGIN.AxisY < pcEND.AxisY) then begin
      pcBEGIN.Quadrant := 2;
      pcEND.Quadrant := 4;
    end else if (pcBEGIN.AxisX > pcEND.AxisX) and (pcBEGIN.AxisY < pcEND.AxisY) then begin
      pcBEGIN.Quadrant := 1;
      pcEND.Quadrant := 3;
    end else if (pcBEGIN.AxisX < pcEND.AxisX) and (pcBEGIN.AxisY > pcEND.AxisY) then begin
      pcBEGIN.Quadrant := 3;
      pcEND.Quadrant := 1;
    end else if (pcBEGIN.AxisX > pcEND.AxisX) and (pcBEGIN.AxisY > pcEND.AxisY) then begin
      pcBEGIN.Quadrant := 4;
      pcEND.Quadrant := 2;
    end;
  end;
var
  newX, newY, newWidth, newHeight: Single;
  dimSize: Boolean;
  newAngle, dAngle, finalAngle: Single;
begin
  case behav of
  behav1D: begin
    //Desplazamiento en una dimensión
    //Ubica el cuadrante del punto de control
    if target = pcBEGIN then begin
      //Se mueve el punto de inicio
      pcBEGIN.Locate(wishX, wishY);  //Mueve el punto de control
    end else if target = pcEND then begin
      //Se mueve el punto final
      pcEND.Locate(wishX, wishY);  //Mueve el punto de control
    end;
    ReadQuadrant;  //Reubica cuandrantes de pcBEGIN AxisY pcEND
    newX := min(pcBEGIN.AxisX, pcEND.AxisX);
    newY := min(pcBEGIN.AxisY, pcEND.AxisY);
    newWidth := abs(pcBEGIN.AxisX - pcEND.AxisX);
    newHeight := abs(pcBEGIN.AxisY - pcEND.AxisY);
    ReLocateSize(newX, newY, newWidth, newHeight, false);
    lblResize := '';
  end;
  behav2D: begin
    //Desplazamiento en dos dimensiones
    {Cambia posición y tamaño, de acuerdo al tipo de desplazamiento (deducido de la
     posición) del punto de control.}
    dimSize := true;
    case target.relPosition of
    TD_TOP_IZQ: ReLocateSize(target.x0+dx/2, target.y0+dy/2, target.width0-dx, target.height0-dy);
    TD_TOP_CEN: ReLocateSize(target.x0     , target.y0+dy/2, target.width0   , target.height0-dy);
    TD_TOP_DER: ReLocateSize(target.x0+dx/2, target.y0+dy/2, target.width0+dx, target.height0-dy);

    TD_CEN_IZQ: ReLocateSize(target.x0+dx/2, target.y0     , target.width0-dx, target.height0);
    TD_CEN_DER: ReLocateSize(target.x0+dx/2, target.y0     , target.width0+dx, target.height0);

    TD_BOT_IZQ: ReLocateSize(target.x0+dx/2, target.y0+dy/2, target.width0-dx, target.height0+dy);
    TD_BOT_CEN: ReLocateSize(target.x0     , target.y0+dy/2, target.width0   , target.height0+dy);
    TD_BOT_DER: ReLocateSize(target.x0+dx/2, target.y0+dy/2, target.width0+dx, target.height0+dy);

    TD_ROTATE: begin
        dimSize := False;  //Estamos dimensionando ángulo
        //lblResize := angle.ToString + 'º';
        newAngle := -ArcTan2(wishY- AxisY, wishX - AxisX);
        dAngle := (newAngle - baseAngle);
        finalAngle := target.angle0 + dAngle;   //En radianes
        finalAngle := Round(finalAngle*180/PI) * Pi/180;  //Ajusta a grados, pero sigue en radianes
        Rotate(finalAngle);
      end;
    end;
    if dimSize then begin
      lblResize := Width.ToString() + 'x' + Height.ToString();
    end else begin
      lblResize := FormatFloat('0.0', angle * 180 / 3.14159) + 'º';
    end;
  end;
  end;
end;
procedure TObjGraf.Setangle(AValue: Single);
begin
  if Fangle = AValue then Exit;
  Fangle := AValue;
end;
procedure TObjGraf.SetlocAxisX(AValue: Single);
begin
  if FlocAxisX = AValue then Exit;
  FlocAxisX := AValue;
end;
procedure TObjGraf.SetlocAxisY(AValue: Single);
begin
  if FlocAxisY = AValue then Exit;
  FlocAxisY := AValue;
end;

function TObjGraf.AddPoint(x0, y0: Single): TOgPoint;
{Agrega un punto geométrico a la forma}
begin
  Result := TOgPoint.Create(x0, y0);
  geometry.Add(Result);

  //Configura las fórmulas de ubicación
  Result.locX.expType := letFactW;
  Result.locX.valFac := x0/Width;
  Result.locY.expType := letFactH;
  Result.locY.valFac := y0/Height;
    //Primera ubicación
  Result.Relocate(Width, Height);
end;
function TObjGraf.AddPtoTerminal(PosicPCtrol: TPosicPCtrol; mousePtr: TCursor): TPtoTerm;
//Agrega un punto de control, que trabajará en formas 1D
begin
  Result := TPtoTerm.Create(self, PosicPCtrol, mousePtr, @PtoCtl_ChangePosition);
  PtosTerminal.Add(Result);
end;
function TObjGraf.AddPtoControl(PosicPCtrol: TPosicPCtrol; mousePtr: TCursor): TPtoCtrl;
//Agrega un punto de control, que trabajará en formas 2D
begin
  Result := TPtoCtrl.Create(self, PosicPCtrol, mousePtr, @PtoCtl_ChangePosition);
  Result.idIcon := pciCircle;
  PtosControl.Add(Result);
end;
function TObjGraf.SelecPtoControl(xp, yp:integer): TPtoCtrl;
//Indica si selecciona a algún punto de control y devuelve la referencia.
var pdc: TPtoCtrl;
begin
  Result := Nil;      //valor por defecto
  if behav = behav1D then begin
     for pdc in PtosTerminal do begin
         if pdc.IsSelectedBy(xp,yp) then begin
             Result := pdc;
             exit;
         end;
     end;
  end else if behav = behav2D then begin
    for pdc in PtosControl do begin
        if pdc.IsSelectedBy(xp,yp) then begin
            Result := pdc;
            exit;
        end;
    end;
  end;
end;
//Puntos de conexión
function TObjGraf.AddPtoConex(xOff, yOff: Single): TPtoConx;
begin
  //Configura las fórmulas de ubicación
  Result := TPtoConx.Create(v2d);
  Result.locX.expType := letFactW;
  Result.locX.valFac := xOff/Width;
  Result.locY.expType := letFactH;
  Result.locY.valFac := yOff/Height;
  //Actualiza coordenadas absolutas
  Result.Parent := self;
  Result.Relocate();  //Primera ubicación
  //Result.AxisX := AxisX-locAxisX + xOff;
  //Result.AxisY := AxisY-locAxisY + yOff;
  PtosConex.Add(Result);
end;
function TObjGraf.SelectConnectionPoint(xp, yp: integer; accuracy: integer = 0): TPtoConx;
{Indica si las coordenadas de pantalla, seleccionan a un Punto de conexión. De ser así
devuelve la referencia al punto de COnexión, de otra forma devuevlve NIL.}
var
  pcnx: TPtoConx;
begin
  Result := Nil;      //valor por defecto
  for pcnx in PtosConex do begin
     if pcnx.IsSelectedBy(xp, yp, accuracy) then begin
        Result := pcnx;
        exit;
     end;
  end;
end;
function TObjGraf.MarkConnectionPoint(xp, yp: integer; accuracy: integer = 0): TPtoConx;
{Explore the object and mark (set flag .Mark) the Connection point selected.
Only one Connection point can be marked. Return the Connection point selected.}
var
  pcnx: TPtoConx;
  found: Boolean;
begin
  Result := nil;      //valor por defecto
  found := false;
  for pcnx in PtosConex do begin
     if found then begin
       //Already found. Clear because only one point can be selected.
       pcnx.Marked := false;
     end else begin
       //Find
       if pcnx.IsSelectedBy(xp, yp, accuracy) then begin
         pcnx.Marked := true;
         Result := pcnx;
         found := true;
       end else begin
         //Clear flag in case it was set before
         pcnx.Marked := false;
       end;
     end;
  end;
end;
procedure TObjGraf.ClearMarkConnectionPoints;
{Clear the mark for all the Connection points of the object}
var
  pcnx: TPtoConx;
begin
  for pcnx in PtosConex do begin
    pcnx.Marked := false;
  end;
end;
function TObjGraf.ConnectionPointMarked: TPtoConx;
{Return the Connection point marked is one exists, otherwise return NIL.}
var
  pcnx: TPtoConx;
begin
  for pcnx in PtosConex do begin
    if pcnx.Marked then exit(pcnx);
  end;
  exit(nil);
end;
//Inicialización
constructor TObjGraf.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  erased := false;
  visible := true;
  //Propiedades geométricas
  fAxisX := 100;
  fAxisY := 100;
  width := 100;   //width por defecto
  height := 100;    //height por defecto
  locAxisX := 50;
  locAxisY := 50;
  //Puntos de control
  PtosTerminal:= TPtosTerminal.Create(True);   //Crea lista con administración de objetos
  PtosControl:= TPtosControl.Create(True);   //Crea lista con administración de objetos
  PtosConex  := TPtosConex.Create(true);
  Selected   := False;
  Marked     := False;
  Proceso    := false;
  DibSimplif := false;
  Highlight  := true;
  //Crea puntos de control estándar. Luego se pueden eliminar fAxisY crear nuevos o modificar
  //estos puntos de control.
  pcTOP_LEF  := AddPtoControl(TD_TOP_IZQ, crSizeNW);
  pcTOP_CEN := AddPtoControl(TD_TOP_CEN, crSizeNS);
  pcTOP_RIG := AddPtoControl(TD_TOP_DER, crSizeNE);

  pcCEN_LEF := AddPtoControl(TD_CEN_IZQ, crSizeWE);
  pcCEN_RIG := AddPtoControl(TD_CEN_DER, crSizeWE);

  pcBOT_LEF := AddPtoControl(TD_BOT_IZQ, crSizeNE);
  pcBOT_CEN := AddPtoControl(TD_BOT_CEN, crSizeNS);
  pcBOT_RIG := AddPtoControl(TD_BOT_DER, crSizeNW);

  //Punto de control de rotación
  pcROTATE := AddPtoControl(TD_ROTATE, crSizeNW);
  pcROTATE.idIcon := pciIcon0;

  //Crea puntos de control para formas 1D
  pcBEGIN   := AddPtoTerminal(TD_TOP_IZQ, crSize);
  pcEND     := AddPtoTerminal(TD_BOT_DER, crSize);
  //pcBEGIN.idIcon := pciCircle;
  //pcEND.idIcon := pciCircle;

  //Rectángulo de selección
  setlength(selRectan, 4);
  //Geometría
  geometry := TOgPoints.Create(true);
  //Comportamiento por defecto
  behav := behav2D;
end;
destructor TObjGraf.Destroy;
begin
  geometry.Destroy;
  //Se desconecta los Ptos de Control 1D.
  pcBEGIN.Disconnect;
  pcEND.Disconnect;
  //Elimina Puntos de control
  PtosTerminal.Free;
  PtosControl.Free;
  PtosConex.Free;
  inherited Destroy;
end;

initialization
  //Inicializa colores
  colObjMarked := clBlue;
  colSelRectan := RGBToColor(49, 128, 57);  //Se usa el color del ícono de rotación
//  colBckToolTip := RGBToColor(171, 196, 176);  //Versión clara de "colSelRectan"
  colBckToolTip := RGBToColor(191, 210, 196);  //Versión más clara de "colSelRectan"
  colCtlPoints := RGBToColor(49, 128, 57);
  colCnxPoints := clBlue;
end.
//1282

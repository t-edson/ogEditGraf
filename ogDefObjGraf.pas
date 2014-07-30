{Unidad ogDefObjGraf
======================
Por Tito Hinostroza 25/07/2014
Define a los objetos gráficos primarios que serán usados por los objetos de mayor nivel
a usar en un editor de objetos gráficos.
El objeto TObjGraf, es el objeto base del que deben derivarse los objetos más específicos
que se dibujarán en pantalla.
Se incluyen también la definición de puntos de control, que permiten redimensionar al
objeto; y de botones que pueden incluirse en los objetos graficos.
En esta unidad solo deben estar definidos los objetos básicos, los que se pueden usar en
muchas aplicaciones. Los más específicos se deben poner en otra uniadad.
No se recomienda modificar esta unidad para adecuar los objetos gráficos a la aplicación.
Si se desea manjar otra clase de objetos generañes, es emjor crear otra clase general a
partir de TObjGraf.
La jerarquía de clases es:

TObjVisible --------------------------------> TObjGraf ---> Derivar objetos aquí
              |                                   |
               --> TPtoCtrl --(Se incluyen en)----
              |                                   |
               --> Tbot --(Se pueden incluir en)--
}
unit ogDefObjGraf;
{$mode objfpc}{$H+}
interface
uses  Classes, Controls, SysUtils, Fgl, Graphics, GraphType, Types,
  ogMotGraf2D;

const
  ANCHO_MIN = 20;    //Ancho mínimo de objetos gráficos en pixels (Coord Virtuales)
  ALTO_MIN = 20;     //Alto mínimo de objetos gráficos en Twips (Coord Virtuales)

type
  { TObjVsible }
  //Clase base para todos los objetos visibles
  TObjVsible = class
  public
    Id         : Integer;     //identificador del objeto
    ancho, alto: Single;
    Seleccionado: Boolean;
    NombreObj   : String;     //Nombre de Objeto, usado para identificarlo
                              //dentro de una colección.
    visible    : boolean;  //indica si el objeto es visible
    procedure Crear(mGraf: TMotGraf; ancho0, alto0: Integer);  //no es constructor
    procedure Ubicar(x0, y0: Single);  //Fija posición
    function LoSelec(xr, yr: Integer): Boolean;
    function InicMover(xr, yr: Integer): Boolean;
    constructor Create; virtual;
    destructor Destroy; override;
  protected
    x,y        : Single;    //coordenadas virtuales
    v2d        : TMotGraf;   //motor gráfico
    Xant,Yant  : Integer;    //coordenadas anteriores
  end;

  TPosicPCtrol = (   //tipo de desplazamiento de punto de control
    TD_SIN_POS,  //sin posición. No se reubicará automáticamente
    TD_SUP_IZQ,  //superior izquierda, desplaza ancho (por izquierda) y alto (por arriba)
    TD_SUP_CEN,  //superior central, desplaza alto por arriba
    TD_SUP_DER,  //superior derecha, desplaza ancho (por derecha) y alto (por arriba)

    TD_CEN_IZQ,  //central izquierda, desplaza ancho (por izquierda)
    TD_CEN_DER,  //central derecha, desplaza ancho (por derecha)

    TD_INF_IZQ,  //inferior izquierda
    TD_INF_CEN,  //inferior central
    TD_INF_DER   //inferior izquierda
   );

  //Procedimiento-evento para dimensionar forma
  TEvenPCdim = procedure(x,y,ancho,alto: Single) of object;

  { TPtoCtrl }
  TPtoCtrl = class(TObjVsible)
  private
    fTipDesplaz: TPosicPCtrol;
    procedure SetTipDesplaz(AValue: TPosicPCtrol);
  public
    posicion   : TPosicPCtrol;  //solo hay 8 posicionnes para un punto de control
    //El tipo de desplazamiento, por lo general debe depender  nicamente de la posicion
    property tipDesplaz: TPosicPCtrol read fTipDesplaz write SetTipDesplaz;
    constructor Crear(mGraf: TMotGraf; PosicPCtrol, tipDesplaz0: TPosicPCtrol;
      EvenPCdim0: TEvenPCdim);
    procedure Dibujar();
    procedure InicMover(xr, yr: Integer; x0, y0, ancho0, alto0: Single);
    procedure Mover(xr, yr: Integer);  //Dimensiona las variables indicadas
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
    function LoSelec(xp, yp: Integer):boolean;
  private
    tipPuntero : Integer;  //Tipo de puntero
    EvenPCdim: TEvenPCdim;  //manejador de Evento
    x1, y1, ancho1, alto1: Single;  //valores objetivo para las dimensiones
  end;
  TPtosControl = specialize TFPGObjectList<TPtoCtrl>;  //Lista para gestionar los puntos de control

  { Objeto Tbot - Permite gestionar los botones}

//Procedimiento-evento para evento Click en Botón
  TEvenBTclk = procedure(estado: Boolean) of object;

  TipTBot =
   (BOT_CERRAR,   //botón cerrar
    BOT_EXPAND,   //botón expandir/contraer
    BOT_CHECK,    //check
    BOT_REPROD);   //reproducir/detener

  Tbot = class(TObjVsible)
    estado     : Boolean;   //Permite ver el estado del botón o el check
    constructor Crear(mGraf: TMotGraf; ancho0,alto0: Integer; tipo0: TipTBot; EvenBTclk0: TEvenBTclk);
    procedure Dibujar;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
  private
    tipo       : TipTBot;
    OnClick: TEvenBTclk
  end;
  TBotones = specialize TFPGObjectList<Tbot>;  //Lista para gestionar los botones

  TObjGraf = class;
  TEventSelec = procedure(obj: TObjGraf) of object; //Procedimiento-evento para seleccionar
  TEventCPunt = procedure(TipPunt: Integer) of object; //Procedimiento-evento para cambiar puntero

  { TObjGraf }
  {Este es el Objeto padre de todos los objetos gráficos visibles que son administrados por el
   motor de edición}
  TObjGraf = class(TObjVsible)
  private
    procedure ProcPCdim(x0, y0, ancho0, alto0: Single);
  protected
    pcx: TPtoCtrl;            //variable para Punto de Control
    PtosControl: TPtosControl; //Lista de puntos de control
    Botones  : TBotones;      //Lista para contener botones
    //puntos de control por defecto
    pc_SUP_IZQ: TPtoCtrl;
    pc_SUP_CEN: TPtoCtrl;
    pc_SUP_DER: TPtoCtrl;
    pc_CEN_IZQ: TPtoCtrl;
    pc_CEN_DER: TPtoCtrl;
    pc_INF_IZQ: TPtoCtrl;
    pc_INF_CEN: TPtoCtrl;
    pc_INF_DER: TPtoCtrl;
    procedure ReubicElemen; virtual;
    procedure ReConstGeom; virtual; //Reconstruye la geometría del objeto
    function SelecPtoControl(xp, yp: integer): TPtoCtrl;
  public
    nombre      : String;    //Identificación del objeto
    Marcado     : Boolean;   //Indica que está marcado, porque el ratón pasa por encima
    DibSimplif  : Boolean;   //indica que se está en modo de dibujo simplificado
    TamBloqueado: boolean;   //protege al objeto de redimensionado
//  Bloqueado   : Boolean;   //Indica si el objeto está bloqueado
    tipo        : Integer;   //Tipo de objeto
//    etiq         As New CFLetra  //Etiqueta
    Relleno     : TColor;    //Color de relleno
    Proceso     : Boolean;   //Bandera
    Dimensionando: boolean;  //indica que el objeto está dimensionándose
    //Eventos de la clase
    OnSelec: TEventSelec;
    OnDeselec: TEventSelec;
    OnCamPunt: TEventCPunt;
    function XCent: Single;  //Coordenada Xcentral del objeto
    function YCent: Single;  //Coordenada Ycentral del objeto
    procedure Ubicar(x0, y0: Single);
    procedure Selec;         //Método único para seleccionar al objeto
    procedure Deselec;       //Método único para quitar la selección del objeto
    procedure Mover(xr, yr : Integer; nobjetos : Integer); virtual;
    function LoSelecciona(xr, yr:integer): Boolean;
    procedure Dibujar; virtual;  //Dibuja el objeto gráfico
    procedure LeePropiedades(cad: string; grabar_ini: boolean=true); virtual; abstract;
    procedure InicMover(xr, yr : Integer);
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
       xp, yp: Integer);   //Metodo que funciona como evento mouse_down
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
       xp, yp: Integer; solto_objeto: Boolean); virtual;
    procedure MouseMove(Sender: TObject; Shift: TShiftState; xp, yp: Integer); virtual;
    function AgregarBoton(ancho0, alto0: Integer; tipo0: TipTBot;
      EvenBTclk0: TEvenBTclk): TBot;
    function AgregarPtoControl(PosicPCtrol, tipDesplaz0: TPosicPCtrol): TPtoCtrl;
    constructor Create(mGraf: TMotGraf); virtual;
    destructor Destroy; override;
  end;

implementation

const ANC_PCT2 = 5;       //mitad del ancho de punto de control

{ TObjVsible }
procedure TObjVsible.Crear(mGraf: TMotGraf; ancho0, alto0: Integer);
begin
  v2d := mGraf;
  ancho:=ancho0;
  alto :=alto0;
  visible := true;
end;
procedure TObjVsible.Ubicar(x0, y0: Single);
begin
  x := x0;
  y := y0;
end;
function TObjVsible.LoSelec(xr, yr: Integer): Boolean;
//Indica si las coordenadas de ratón seleccionan al botón en su posición actual
var xv, yv: Single;    //coordenadas virtuales
begin
    v2d.XYvirt(xr, yr, xv, yv);
    LoSelec := False;    //valor por defecto
    If (xv > x - 2) And (xv < x + ancho + 2) And
       (yv > y - 2) And (yv < y + alto + 2) Then
        LoSelec := True;
end;

function TObjVsible.InicMover(xr, yr: Integer): Boolean;
begin
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

{ TObjGraf }

function TObjGraf.SelecPtoControl(xp, yp:integer): TPtoCtrl;
//Indica si selecciona a algún punto de control y devuelve la referencia.
var pdc: TPtoCtrl;
begin
  SelecPtoControl := NIL;      //valor por defecto
  for pdc in PtosControl do
      if pdc.LoSelec(xp,yp) then begin SelecPtoControl := pdc; Exit; end;
end;
function TObjGraf.XCent: Single;
begin
   Result := X + Ancho / 2;
end;
function TObjGraf.YCent: Single;
begin
   Result := Y + Alto / 2;
end;
procedure TObjGraf.Selec;
begin
   if Seleccionado then exit;    //ya está seleccionado
   Seleccionado := true; //se marca como seleccionado
   //Llama al evento que selecciona el objeto. El editor debe responder
   if Assigned(OnSelec) then OnSelec(self);   //llama al evento
   { TODO : Aquí se debe activar los controles para dimensionar el objeto }
end;
procedure TObjGraf.Deselec;
begin
   if not Seleccionado then exit;    //ya está seleccionado
   Seleccionado := false; //se marca como selccionado
   //Llama al evento que selecciona el objeto. El editor debe responder
   if Assigned(OnDeselec) then OnDeselec(self);  //llama al evento
   { TODO : Aquí se debe desactivar los controles para dimensionar el objeto }
end;
procedure TObjGraf.Mover(xr, yr: Integer; nobjetos: Integer);
{Metodo que funciona como evento movimiento al objeto
"nobjetos" es la cantidad de objetos que se mueven. Ususalmente es sólo uno}
var dx , dy: Single;
begin
//     If ArrastBoton Then Exit;       //Arrastrando botón  { TODO : Revisar }
//     If ArrastFila Then Exit;        //Arrastrando botón  { TODO : Revisar }
     If Seleccionado Then begin
        v2d.ObtenerDesplaz2( xr, yr, Xant, Yant, dx, dy);
        if Proceso then   //algún elemento del objeto ha procesado el evento de movimiento
           begin
              if pcx <> NIL then begin
                 //hay un punto de control procesando el evento MouseMove
                 if not TamBloqueado then
                   pcx.Mover(xr, yr);   //permite dimensionar el objeto
              end;
//              Proceso := True;  'ya alguien ha capturado el evento
           end
        else  //ningún elemento del objeto lo ha procesado, pasamos a mover todo el objeto
           begin
              X := X + dx; Y := Y + dy;
              ReubicElemen;  //reubica los elementos
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
    If (xv > x - 1) And (xv < x + Ancho + 1) And (yv > y - 1) And (yv < y + Alto + 1) Then
      LoSelecciona := True;
    if Seleccionado then begin   //seleccionado, tiene un área mayor de selección
      if SelecPtoControl(xr,yr) <> NIL then LoSelecciona := True;
    end;
End;
procedure TObjGraf.Dibujar;
const tm = 3;
var
  pdc: TPtoCtrl;
  bot: TBot;
begin
  //dibuja botones
  for bot in Botones do bot.Dibujar;     //Dibuja botones
  //---------------dibuja remarcado --------------
  If Marcado Then begin
    v2d.FijaLapiz(psSolid, 2, clBlue);   //RGB(128, 128, 255)
    v2d.rectang(X - tm, Y - tm, X + ancho + tm, Y + alto + tm);
  End;
  //---------------dibuja marca de seleccion--------------
  If Seleccionado Then begin
//    v2d.FijaLapiz(psSolid, 1, clGreen);
//    v2d.rectang(X, Y, X + ancho, Y + alto);
     for pdc in PtosControl do pdc.Dibujar;   //Dibuja puntos de control
  End;
end;
procedure TObjGraf.InicMover(xr, yr: Integer);
//Procedimiento para procesar el evento InicMover de los objetos gráficos
//Se ejecuta al inicio de movimiento al objeto
begin
  Xant := xr; Yant := yr;
  Proceso := False;
  if not seleccionado then exit;   //para evitar que responda antes de seleccionarse
  //Busca si algún punto de control lo procesa
  pcx := SelecPtoControl(xr,yr);
  if pcx <> NIL  then begin
      pcx.InicMover(xr, yr, x, y,ancho,alto);     //prepara para movimiento y dimensionamiento
      Proceso := True;      //Marcar para indicar al editor y a Mover() que este objeto procesará
                            //el evento y no se lo pasé a los demás que pueden estar seleccionados.
      Dimensionando := True; //Marca bandera
   end;
  { TODO : Verificar por qué, a veces se puede iniciar el movimiento del objeto cuando el puntero está en modo de dimensionamiento. }
end;
procedure TObjGraf.MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
//Metodo que funciona como evento "MouseDown"
begin
//  CapturoEvento := NIL;
  Proceso := False;
  If LoSelecciona(xp, yp) Then begin  //sólo responde instantáneamente al caso de selección
    If Not Seleccionado Then Selec;
    Proceso := True;{ TODO : Verificar si es útil la bandera "Proceso" }
  End;
End;
procedure TObjGraf.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; xp, yp: Integer; solto_objeto: Boolean);
//Metodo que funciona como evento MouseUp
//la bandera "solto_objeto" indica que se ha soltado el objeto despues de estarlo arrastrando
var bot: Tbot;
begin
    Proceso := False;
    //verifica si cae de un arrastre
    If solto_objeto And Seleccionado Then begin
        Proceso := True; Exit;    //no quita la selección
    end;
    //Se soltó el ratón
    If Button = mbLeft Then  begin          //soltó izquierdo
       //pasa evento a los botones
       for bot in Botones do bot.MouseUp(Button, Shift, xp, yp);
    end else If Button = mbRight Then begin //soltó derecho
        If LoSelecciona(xp, yp) Then
            Proceso := True;
    end;
    //Restaura puntero si estaba dimensionándose por si acaso
    if Dimensionando then begin
       if not pcx.LoSelec(xp,yp) then //se salio del foco
          if Assigned(OnCamPunt) then OnCamPunt(crDefault);  //pide retomar el puntero
       Dimensionando := False;    //quita bandera, por si estaba dimensionando
       exit;
    end;
end;
procedure TObjGraf.MouseMove(Sender: TObject; Shift: TShiftState; xp, yp: Integer);
//Respuesta al evento MouseMove. Se debe recibir cuando el Mouse pasa por encima del objeto
var pc: TPtoCtrl;
begin
    if not Seleccionado then Exit;
    //Aquí se supone que tomamos el control porque está seleccionado
    //Procesa el cambio de puntero.
    if Assigned(OnCamPunt) then begin
        pc := SelecPtoControl(xp,yp);
        if pc<> NIL then
           OnCamPunt(pc.tipPuntero)  //cambia a supuntero
        else
           OnCamPunt(crDefault);
    end;
end;

constructor TObjGraf.Create(mGraf: TMotGraf);
begin
  inherited Create;
  v2d := mGraf;   //asigna motor gráfico
  ancho := 100;   //ancho por defecto
  alto := 100;    //alto por defecto
  x := 100;
  y := 100;
  Botones := TBotones.Create(True);      //Crea lista con administración de objetos
  PtosControl := TPtosControl.Create(True);   //Crea lista con administración de objetos
  Seleccionado := False;
  Marcado := False;
  Proceso := false;
  DibSimplif := false;
  //Crea puntos de control estándar. Luego se pueden eliminar y crear nuevos o modificar
  //estos puntos de control.
  pc_SUP_IZQ:=AgregarPtoControl(TD_SUP_IZQ, TD_SUP_IZQ);
  pc_SUP_CEN:=AgregarPtoControl(TD_SUP_CEN, TD_SUP_CEN);
  pc_SUP_DER:=AgregarPtoControl(TD_SUP_DER, TD_SUP_DER);
  pc_CEN_IZQ:=AgregarPtoControl(TD_CEN_IZQ, TD_CEN_IZQ);
  pc_CEN_DER:=AgregarPtoControl(TD_CEN_DER, TD_CEN_DER);
  pc_INF_IZQ:=AgregarPtoControl(TD_INF_IZQ, TD_INF_IZQ);
  pc_INF_CEN:=AgregarPtoControl(TD_INF_CEN, TD_INF_CEN);
  pc_INF_DER:=AgregarPtoControl(TD_INF_DER, TD_INF_DER);
end;
procedure TObjGraf.ReubicElemen;
var pc: TPtoCtrl;
begin
  //ubica puntos de control
  for pc in PtosControl do begin
    case pc.posicion of
    TD_SUP_IZQ:  //superior izquierda, desplaza ancho (por izquierda) y alto (por arriba)
      pc.Ubicar(x,y);
    TD_SUP_CEN:  //superior central, desplaza alto por arriba
      pc.Ubicar(x+ancho/2,y);
    TD_SUP_DER:  //superior derecha, desplaza ancho (por derecha) y alto (por arriba)
      pc.Ubicar(x+ancho,y);

    TD_CEN_IZQ:  //central izquierda, desplaza ancho (por izquierda)
      pc.Ubicar(x,y+alto/2);
    TD_CEN_DER:  //central derecha, desplaza ancho (por derecha)
      pc.Ubicar(x+ancho,y+alto/2);

    TD_INF_IZQ:  //inferior izquierda
      pc.Ubicar(x,y+alto);
    TD_INF_CEN:  //inferior central
      pc.Ubicar(x+ancho/2,y+alto);
    TD_INF_DER:   //inferior izquierda
      pc.Ubicar(x+ancho,y+alto);
    else  //otra ubicación no lo reubica
    end;
  end;
end;
procedure TObjGraf.ReConstGeom;
begin
  ReubicElemen;   //Reubicación de elementos
end;
destructor TObjGraf.Destroy;
begin
  PtosControl.Free;    //Libera Puntos de Control y lista
  Botones.Free;        //Libera Botones y Lista
  inherited Destroy;
end;
procedure TObjGraf.Ubicar(x0, y0: Single);
//Ubica al objeto en unas coordenadas específicas
begin
  x := x0;
  y := y0;
  ReubicElemen;   //reubica sus elementos
end;
function TObjGraf.AgregarBoton(ancho0, alto0: Integer; tipo0: TipTBot;
  EvenBTclk0: TEvenBTclk): TBot;
//Agrega un botón al objeto.
begin
  Result := TBot.Crear(v2d, ancho0, alto0, tipo0, EvenBTclk0);
  Botones.Add(Result);
end;
function TObjGraf.AgregarPtoControl(PosicPCtrol, tipDesplaz0: TPosicPCtrol): TPtoCtrl;
//Agrega un punto de control
begin
  Result := TPtoCtrl.Crear(v2d, PosicPCtrol, tipDesplaz0, @ProcPCdim);
  PtosControl.Add(Result);
end;
procedure TObjGraf.ProcPCdim(x0, y0, ancho0, alto0: Single);
//Se usa para atender los requerimientos de los puntos de control cuando quieren
//cambiar el tamaño del objeto.
begin
  //verifica validez de cambio de ancho
  if ancho0 >= ANCHO_MIN then begin
     ancho := ancho0;
     x := x0;  //solo si cambió el ancho, se permite modificar la posición
//     fil.ancho:= ancho0-6;  //actualiza tabla de campos
  end;
  //verifica validez de cambio de alto
  if alto0 >= ALTO_MIN then begin
     alto := alto0;
     y := y0; //solo si cambió el alto, se permite modificar la posición
  end;
  ReConstGeom;       //reconstruye la geometría
end;

 //////////////////////////////  TPtoCtrl  //////////////////////////////
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
  else        tipPuntero := crDefault ;
  end;
end;
constructor TPtoCtrl.Crear(mGraf: TMotGraf; PosicPCtrol, tipDesplaz0: TPosicPCtrol;
  EvenPCdim0: TEvenPCdim);
begin
  inherited Crear(mGraf, 2*ANC_PCT2, 2*ANC_PCT2);    //crea
  posicion := PosicPCtrol;  //donde aparecerá en el objeto
  tipDesplaz := tipDesplaz0;  //actualiza propiedad
  EvenPCdim := EvenPCdim0;     //Asigna evento para cambiar dimensiones
  visible := true;             //lo hace visible
  x :=0;
  y :=0;
end;
procedure TPtoCtrl.Dibujar();
//Dibuja el Punto de control en la posición definida
var xp, yp: Integer;
begin
    if not visible then exit;    //validación
    v2d.XYpant(x, y, xp, yp);      //obtiene coordenadas de pantalla
    v2d.Barra0(xp - ANC_PCT2, yp - ANC_PCT2,
               xp + ANC_PCT2, yp + ANC_PCT2, clNavy);  //siempre de tamaño fijo
end;
procedure TPtoCtrl.InicMover(xr, yr: Integer; x0, y0, ancho0, alto0: Single);
//Procedimiento para procesar el evento InicMover del punto de control
begin
    if not visible then exit;    //validación
    inherited InicMover(xr,yr);
    //captura los valores iniciales de las dimensiones
    x1 := x0;
    y1 := y0;
    ancho1 := ancho0;
    alto1 := alto0;
end;
procedure TPtoCtrl.Mover(xr, yr: Integer);
//Realiza el cambio de las variables indicadas de acuerdo al tipo de control y a
//las variaciones indicadas (dx, dy)
var dx, dy: Single;
begin
    if not visible then exit;    //validación
    dx := (xr - Xant) / v2d.Zoom;     //obtiene desplazamiento absoluto
    dy := (yr - Yant) / v2d.Zoom;     //obtiene desplazamiento absoluto
    if EvenPCdim=NIL then exit;    //protección
    case tipDesplaz of
    TD_SUP_IZQ: EvenPCdim(x1+dx, y1+dy, ancho1-dx, alto1-dy);
    TD_SUP_CEN: EvenPCdim(x1, y1+dy, ancho1, alto1-dy);
    TD_SUP_DER: EvenPCdim(x1, y1+dy, ancho1+dx, alto1-dy);

    TD_CEN_IZQ: EvenPCdim(x1+dx, y1, ancho1-dx, alto1);
    TD_CEN_DER: EvenPCdim(x1, y1, ancho1+dx, alto1);

    TD_INF_IZQ: EvenPCdim(x1+dx, y1, ancho1-dx, alto1+dy);
    TD_INF_CEN: EvenPCdim(x1, y1, ancho1, alto1+dy);
    TD_INF_DER: EvenPCdim(x1, y1, ancho1+dx, alto1+dy);
  end;
//  Xant := xr; Yant := yr;   //actualiza coordenadas
end;
procedure TPtoCtrl.MouseUp(Button: TMouseButton; Shift: TShiftState; xp,  yp: Integer);
//Procesa el evento MouseUp del "mouse".
begin
end;
function TPtoCtrl.LoSelec(xp, yp: Integer): boolean;
//Indica si las coordenadas lo selecciona
var xp0, yp0 : Integer; //corodenadas virtuales
begin
    LoSelec := False;
    if not visible then exit;    //validación
    v2d.XYpant(x, y, xp0, yp0);   //obtiene sus coordenadas en pantalla
    //compara en coordenadas de pantalla
    If (xp >= xp0 - ANC_PCT2) And (xp <= xp0 + ANC_PCT2) And
       (yp >= yp0 - ANC_PCT2) And (yp <= yp0 + ANC_PCT2) Then
         LoSelec := True;
End;

//////////////////////////////  Tbot  //////////////////////////////
constructor Tbot.Crear(mGraf: TMotGraf; ancho0, alto0: Integer; tipo0: TipTBot;
  EvenBTclk0: TEvenBTclk);
begin
   inherited Crear(mGraf, ancho0, alto0);    //crea
   tipo := tipo0;
   OnClick := EvenBTclk0;
   estado := FALSE;   //inicia en 0 (check no marcado, o botón por contraer)
end;
procedure Tbot.Dibujar;
//Dibuja el botón de acuerdo a su tipo y estado
begin
  case tipo of
  BOT_CERRAR: begin
       v2d.DibFonBoton(x,y,15,15);
       v2d.DibVnormal(x+2,y+2,10,5);
       v2d.DibVnormal(x+2,y+12,10,-5);
     end;
  BOT_EXPAND:
      if estado then begin
         v2d.DibFonBoton(x,y,15,15);
         v2d.DibVnormal(x+2,y+7,10,-5);
         v2d.DibVnormal(x+2,y+11,10,-5);
      end else begin
         v2d.DibFonBoton(x,y,15,15);
         v2d.DibVnormal(x+2,y+2,10,5);
         v2d.DibVnormal(x+2,y+6,10,5);
      end;
  BOT_CHECK: begin  //botón check
     if estado then begin   //dibuja solo borde
        v2d.DibFonBoton(x,y,15,15);
     end else begin         //dibuja con check
        v2d.DibFonBoton(x,y,15,15);
        v2d.DibCheck(x+2,y+2,10,8);
     end;
    end;
  BOT_REPROD: begin  //botón reproducir
     if estado then begin   //dibuja solo borde
       v2d.FijaColor(clBlack, TColor($E5E5E5), 1);
       v2d.RectRedonR(x,y,x+ancho, y+alto);
       v2d.FijaColor(clBlack, clBlack, 1);
       v2d.RectangR(x+6,y+6,x+ancho-6, y+alto-6);
     end else begin         //dibuja con check
       v2d.FijaColor(clBlack, TColor($E5E5E5), 1);
       v2d.RectRedonR(x,y,x+ancho, y+alto);
       v2d.FijaColor(clBlack, clBlack, 1);
       v2d.poligono(x+6, y+3,
                    x+18, y + alto/2,
                    x+6, y + alto - 4);
     end;
    end;
  end;
end;
procedure Tbot.MouseUp(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
begin
     if LoSelec(xp,yp) then begin    //se soltó en el botón
        //cambia el estado, si aplica
        if tipo in [BOT_EXPAND, BOT_CHECK, BOT_REPROD] then estado := not estado;
        if Assigned(OnClick) then
           OnClick(estado);    //ejecuta evento
     end;
end;

end.


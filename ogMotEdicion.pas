{Unidad ogMotEdicion 1.3b
=========================
Por Tito Hinostroza 16/09/2014
* Se modifica método MouseUp(), para que verifique la bandera "Erased", de los objetos
gráficos y aliminarlos de ser el caso.
* Se cambia de nombre a diversas rutinas.
* Se agrega el evento para procesar la rueda del ratón

Descripción
============
Define la clase TModEdicion para la implementación de una interfaz de objetos gráficos
en un Editor.
Los objetos a manejar deben derivarse de la clase TObjGraf.
Se debe indicar el control TPaint que se usará como salida gráfica.
Trabaja en pixels para acelerar los gráficos.
Basado en la clase equivalente en el proyecto SQLGraf en Visual Basic.
}
unit ogMotEdicion;
{$mode objfpc}{$H+}
INTERFACE
uses
  Classes, Forms, Controls, ExtCtrls, SysUtils, Graphics, Fgl, LCLIntf,
  LCLType, GraphType, Dialogs, ogMotGraf2D, ogDefObjGraf;

const
  CUR_DEFEC = crDefault;          //cursor por defecto

  ZOOM_MAX_CONSULT = 5  ;  //Define el zoom máximo que se permite en un diagrama
  ZOOM_MIN_CONSULT = 0.1;  //Define el zoom mínimo que se permite en un diagrama

  FACTOR_AMPLIA_ZOOM = 1.15;  //Factor de ampliación del zoom

type
  EstadosPuntero = (
      EP_NORMAL,      //No se está realizando ninguna operación
      EP_SELECMULT,   //Esta en modo de selección múltiple
      EP_MOV_OBJS,    //Indica que se esta moviendo una o mas objetos
      EP_DESP_PANT,   //Indica desplazamiento con ratón + <Shift> + <Ctrl>
      EP_DIMEN_OBJ,   //Indica que se está dimensionando un objeto
      EP_RAT_ZOOM);   //Indica que se está en un proceso de Zoom

  TlistObjGraf = specialize TFPGObjectList<TObjGraf>;   //Lista de "TObjTabla"

  TOnClickDer = procedure(x,y:integer) of object;

  { TModEdicion }

  TModEdicion = class
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
    procedure MouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; xp, yp: Integer);
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer);
    procedure Paint(Sender: TObject);
    procedure PBMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  public
    EstPuntero   : EstadosPuntero; //Estado del puntero
    ParaMover    : Boolean; //bandera de control para el inicio del movimiento
    CapturoEvento: TObjGraf;     //referencia a objeto que capturo el movimiento
    ultMarcado   : TObjGraf;     //nombre del objeto marcado
    objetos  : TlistObjGraf;
    seleccion: TlistObjGraf;
//  Public tablas: New Collection
//  Public botones: New Collection    ;  //Botones
  //------------------ Eventos ------------------
//  Public Event ClickDerDiag()         ;  //Evento cuando se pulsa Click Derecho en el diagrama
  //Public Event ObjSelec(o: og)      ;  //Evento cuando se selecciona un objeto
//  Public Event ClickDerSel()          ;  //Evento cuando se pulsa Click Derecho en seleción
//  Public Event DblClickObj(o: TObjGraf)   ;  //Doble Click en objeto
//  Public Event ActualizarConsulta()   ;  //Indica que se debe actualizar la consulta
//  Public Event InicArrastreFil(dat: String) ;  //Inicio del arrastre de una fila.
  //-----------------------------------------------------------
    Modif: Boolean;  //bandera para indicar Diagrama Modificado
//  Public MostrarEtiquetas: Boolean     ;  //bandera que indica si se deben mostrar las etiquetas de los símbolos

    ColorRelleno: TGraphicsColor;

    PB: TPaintBox;    //Control de Salida
    v2d: TMotGraf;    //salida gráfica
    OnClickDer: TOnClickDer;

    procedure AgregarObjGrafico(og: TObjGraf; AutoPos: boolean=true);
    procedure EliminarTodosObj;
    procedure EliminarObjGrafico(obj: TObjGraf);
    function Seleccionado: TObjGraf;
    function ObjPorNombre(nom: string): TObjGraf;
    procedure Refrescar;
    procedure SeleccionarTodos;
    procedure DeseleccionarTodos();
  private
    x1Sel        : integer;
    y1Sel        : integer;
    x2Sel        : integer;
    y2Sel        : integer;
    x1Sel_a: integer;
    y1Sel_a: integer;
    x2Sel_a: integer;
    y2Sel_a: integer;
    //coordenadas del raton
    x_pulso: integer;
    y_pulso: integer;
    //perspectivas
    PFinal: TPerspectiva;  //almacena la perspectiva a la que se quiere llegar
    PAnter: TPerspectiva;  //perspectiva temporal
    (*
      ;  //Variables para el control de la búsqueda
      Private CadBus: String    ;  //Cadena de búsqueda
      Private CajBus: Boolean   ;  //Bandera de caja para búsqueda
      Private PalCBus: Boolean  ;  //Bandera de palabra completa para búsqueda
      Private DirBus: Integer   ;  //Dirección de búsqueda
      Private PosEnc: Integer   ;  //Posición del objeto encontrado. Usado para búsquedas
    *)

    x_cam_a: Single;  //coordenadas anteriores de x_cam
    y_cam_a: Single;

    procedure AmpliarClick(factor: real=FACTOR_AMPLIA_ZOOM; xr: integer=0;
      yr: integer=0);
    procedure BorraRecSeleccion;
    procedure DibujRecSeleccion;

    function enRecSeleccion(X, Y: Single): Boolean;
    procedure InicMover;
    procedure InicRecSeleccion(X, Y: Integer);
    procedure MoverDesp(dx, dy: integer);
    function RecSeleccionNulo: Boolean;
    procedure ReducirClick(factor: Real=FACTOR_AMPLIA_ZOOM; x_zoom: Real=0;
      y_zoom: Real=0);
    function SeleccionaAlguno(xp, yp: Integer): TObjGraf;
    function VerificarMovimientoRaton(X, Y: Integer): TObjGraf;
    procedure VerificarParaMover(xp, yp: Integer);
  public
    procedure ObjGraf_Select(obj: TObjGraf);    //Respuesta a Evento
    procedure ObjGraf_Unselec(obj: TObjGraf);    //Respuesta a Evento
    procedure ObjGraf_SetPointer(Punt: integer);      //Respuesta a Evento
    constructor Create(PB0: TPaintBox);
    destructor Destroy; override;
  end;

implementation

procedure  TModEdicion.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; xp, yp: Integer);
var o: TObjGraf;
begin
    //Verifica si la selección es NULA
    If (EstPuntero = EP_SELECMULT) And RecSeleccionNulo Then EstPuntero := EP_NORMAL;
    //Procesa de acuerdo al estado
    Case EstPuntero of
    EP_RAT_ZOOM:    //------ Zoom con el Ratón ------
      begin
        If Button = mbLeft Then AmpliarClick(1.2, xp, yp) ;  //<Shift> + <Ctrl> + click izquierdo
        If Button = mbRight Then ReducirClick(1.2, xp, yp) ;  //<Shift> + <Ctrl> + click derecho
//        EstPuntero = EP_NORMAL   //Legalmente debería ponerse a normal. Pero si se
                                  //hace, es posible que un click consecutivo muy
                                  //rápido, no dispare el evento MouseDown (dispara
                                  //el DblClick en su lugar), y se desactivaría el
                                  //modo ZOOM lo que es molesto.
      end;
    EP_DESP_PANT:     //------ Desplazamiento de Pantalla ------
        EstPuntero := EP_NORMAL;
    EP_MOV_OBJS:     //------ Moviendo Objetos ------
      begin
//Debug.Print "Esatado EP_MOV_OBJS"
        For o In seleccion do  //Pasa el evento a la selección
            o.MouseUp(Sender, Button, Shift, xp, yp, EstPuntero = EP_MOV_OBJS);
        EstPuntero := EP_NORMAL;  //fin de movimiento
        Refrescar;
      end;
    EP_SELECMULT :  //------ En selección múltiple, Botón izquierdo o derecho
      begin
        If objetos.Count > 100 Then  begin  //Necesita actualizar porque la selección múltiple es diferente
            For o In objetos do
                If enRecSeleccion(o.XCent, o.YCent) And Not o.Seleccionado Then o.Selec;
        End;
        BorraRecSeleccion;                 //borra marca
        EstPuntero := EP_NORMAL;
      end;
    EP_NORMAL:  //------ En modo normal
      begin
        o := SeleccionaAlguno(xp, yp);  //verifica si selecciona a un objeto
        If Button = mbRight Then //----- solto derecho -------------------
          begin
(*            If o = NIL Then  //Ninguno seleccionado
                RaiseEvent ClickDerDiag    //Genera evento
            Else    ;  //Hay uno que lo selecciona, o más???
                If Not o.Seleccionado Then Call o.SoltoRaton(Button, Shift, xr, yr)    ;  //Pasa el evento
                RaiseEvent ClickDerSel     //Genera evento
            End If*)
          end
        else If Button = mbLeft Then begin //----- solto izquierdo -----------
            If o = NIL Then    //No selecciona a ninguno
//                Call DeseleccionarTodos
            else begin         //Selecciona a alguno
                If Shift = [] Then DeseleccionarTodos;
                o.Selec;   //selecciona
                o.MouseUp(Sender, Button, Shift, xp, yp, false);
                Refrescar;
                //verifica si el objeto está piddiendo que lo eliminen
                if o.Erased then begin
                  EliminarObjGrafico(o);
                  Refrescar;
                end;
            End;
            CapturoEvento := NIL;      //inicia bandera de captura de evento
            ParaMover := False;        //por si aca
        end;
      end;
    EP_DIMEN_OBJ:  //Se soltó mientras se estaba dimensionado un objeto
      begin
        //pasa evento a objeto que se estaba dimensionando
        CapturoEvento.MouseUp(Sender, Button, Shift, xp, yp, false);
        //termina estado
        EstPuntero := EP_NORMAL;
        CapturoEvento := NIL;      //inicia bandera de captura de evento
        ParaMover := False;        //por si aca
      end;
    End;
    if Button = mbRight then
      if OnClickDer<> nil then OnClickDer(xp,yp);  //evento
End;
procedure TModEdicion.MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
var ogs: TObjGraf;  //objeto seleccionado
begin
    x_pulso := xp;
    y_pulso := yp;
    InicMover;   //por si acaso, para iniciar movimiento
    If Shift >= [ssCtrl, ssShift]  Then begin   //Contiene Shift+Ctrl
        //Inicia estado de ZOOM. Puede convertirse en EP_DESP_PANT
        //si luego se genera el evento Move()
        EstPuntero := EP_RAT_ZOOM;
        Exit;  //Ya no se necesita procesar
    End;
    ogs := SeleccionaAlguno(xp, yp);  //verifica si selecciona a un objeto
    If Button = mbRight Then
      begin  //pulso derecho-------------------
        If ogs = NIL Then begin  //Ninguno seleccionado
            DeseleccionarTodos;
            Refrescar;
            EstPuntero := EP_SELECMULT;  //inicia seleccion multiple
            InicRecSeleccion(x_pulso, y_pulso);
        end else begin //Selecciona a uno, pueden haber otros seleccionados
//msgbox('Lo selecciona');
            If ogs.Seleccionado Then  begin  //Se marcó sobre un seleccionado
 //                If ogs.TieneBoleta Then ;  //Verifica, No se pueden seleccionar múltiples boletas
 //                    If ogs.Boleta.LoSelecciona(xr, yr) Then Call DeseleccionarTodos
 //                End If
                ogs.MouseDown(Sender, Button, Shift, xp, yp);  //Pasa el evento

                Exit;
            End;
            //Se selecciona a uno que no tenía selección
            If Shift = []  Then  begin
                DeseleccionarTodos;
            end;
 //            If ogs.TieneBoleta Then ;  //Verifica, No se pueden seleccionar múltiples boletas
 //                If ogs.Boleta.LoSelecciona(xr, yr) Then Call DeseleccionarTodos
 //            End If
            ogs.MouseDown(Sender, Button, Shift, xp, yp);  //Pasa el evento
            Refrescar;
             //ParaMover = True       ;  //listo para mover
        End;
      end
    Else If Button = mbLeft Then begin   //pulso izquierdo-----------------
        If ogs = NIL Then  begin  //No selecciona a ninguno
            DeseleccionarTodos;
            Refrescar;
            EstPuntero := EP_SELECMULT;  //inicia seleccion multiple
            InicRecSeleccion(x_pulso, y_pulso);
        end Else begin     //selecciona a uno, pueden haber otros seleccionados
            If ogs.Seleccionado Then begin //Se marcó sobre un seleccionado
                //No se quita la selección porque puede que se quiera mover
                //varios objetos seleccionados. Si no se mueve, se quitará la
                //selección en MouseUp
                //If Shift = 0 Then Call DeseleccionarTodos
                ogs.MouseDown(Sender, Button, Shift, xp, yp);  //Pasa el evento
                ParaMover := True;  //listo para mover
                Exit;               //Se sale sin desmarcar
            End;
            //Se selecciona a uno que no tenía selección
            If Shift = [ssLeft] Then  //Sin Control ni Shift
               DeseleccionarTodos;
            ogs.MouseDown(Sender, Button, Shift, xp, yp);  //Pasa el evento
            ParaMover := True;            //listo para mover
        End;
    End;
End;
procedure TModEdicion.MouseMove(Sender: TObject; Shift: TShiftState;
  X,  Y: Integer);
var s: TObjGraf;
    si_refrescar: Boolean;
begin
    If Shift = [ssCtrl, ssShift, ssRight] Then  //<Shift>+<Ctrl> + <Botón derecho>
       begin
        EstPuntero := EP_DESP_PANT;
        MoverDesp(x_pulso - X, y_pulso - Y);
        Refrescar;
        Exit;
       End;
    If ParaMover = True Then VerificarParaMover(X, Y);
    If EstPuntero = EP_SELECMULT Then begin  //modo seleccionando multiples formas
        x2Sel := X;
        y2Sel := Y;
        si_refrescar := False;
        //verifica los que se encuentran seleccionados
        If objetos.Count < 100 Then begin//sólo anima para pocos objetos
            For s In objetos do begin
                If enRecSeleccion(s.XCent, s.YCent) And Not s.Seleccionado Then begin
                  s.Selec;
                  si_refrescar := True;  //para indicar que luego debe refrescar pantalla
                End;
                If Not enRecSeleccion(s.XCent, s.YCent) And s.Seleccionado Then begin
                  s.Deselec;
                  si_refrescar := True;  //para indicar que luego debe refrescar pantalla
                End;
            end;
        End;
        If si_refrescar Then   //redibuja para mostrar elementos seleccionados, cuidando la marca de seleccion
            Refrescar
        Else begin
            BorraRecSeleccion;
            DibujRecSeleccion;
        End;
    end Else If EstPuntero = EP_MOV_OBJS Then begin  //mueve la selección
//        If perfil = PER_OPER Then Exit;  //No permite mover
        Modif := True;
        for s in seleccion do
            s.Mover(x,y, seleccion.Count);
        Refrescar;
    end Else If EstPuntero = EP_DIMEN_OBJ Then begin
        //se está dimensionando un objeto
        CapturoEvento.Mover(X, Y, seleccion.Count);
        Refrescar;
    end Else
        If CapturoEvento <> NIL Then begin
           CapturoEvento.Mover(X, Y, seleccion.Count);
           Refrescar;
        end Else begin  //Movimiento simple
            s := VerificarMovimientoRaton(X, Y);
            if s <> NIL then s.MouseMove(Sender, Shift, X, Y);  //pasa el evento
        end;
End;

procedure TModEdicion.Paint(Sender: TObject);
begin
  Refrescar;
end;

procedure TModEdicion.PBMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  ogs: TObjGraf;
begin
  ogs := SeleccionaAlguno(MousePos.x, MousePos.y);  //verifica si selecciona a un objeto
  if ogs=nil then begin
    //debe desplazar la pantalla
  end else begin
    //lo selecciona, pero debe ver si está seleccionado
    if ogs.Seleccionado then begin
       ogs.MouseWheel(Sender, Shift, WheelDelta, MousePos, Handled);
    end else begin

    end;
  end;
end;







constructor TModEdicion.Create(PB0: TPaintBox);
//Metodo de inicialización de la clase Editor. Debe indicarse el
//PaintBox de salida donde se controlarán los objetos gráficos.
begin
  PB := PB0;  //asigna control de salida
  //intercepta eventos
  PB.OnMouseUp:=@MouseUp;
  PB.OnMouseDown:=@MouseDown;
  PB.OnMouseMove:=@MouseMove;
  PB.OnMouseWheel:=@PBMouseWheel;
  PB.OnPaint:=@Paint;
  //inicia motor
  ColorRelleno := clWhite  ;  //Color por defecto
  v2d := TMotGraf.IniMotGraf(PB.Canvas);   //Inicia motor gráfico
  v2d.FijaLetra('MS Sans Serif');   //define tipo de letra
  objetos := TlistObjGraf.Create(TRUE);   //crea lista con "posesión" de objetos
  seleccion := TlistObjGraf.Create(FALSE);   //crea lista sin posesión", porque la
                                        //administración la hará "objetos".
  EstPuntero := EP_NORMAL;
  ParaMover := false;
  CapturoEvento := NIL;
  ultMarcado := NIL;
  Modif := False;   //Inicialmente no modificado

  PB.Cursor := CUR_DEFEC;        //define cursor
end;
destructor TModEdicion.Destroy;
begin
  seleccion.Free;
  objetos.Free;  //limpia lista y libera objetos apuntados
  v2d.Free;      //Libera
  //resatura eventos
  PB.OnMouseUp:=nil;
  PB.OnMouseDown:=nil;
  PB.OnMouseMove:=nil;
  PB.OnPaint:=nil;
  inherited;     //llama al destructor
end;
procedure TModEdicion.Refrescar();  //   Optional s: TObjGraf = Nothing
var o:TObjGraf;
begin
  If EstPuntero = EP_SELECMULT Then BorraRecSeleccion;
//  If s = NIL Then

    PB.canvas.Brush.Color := clWhite; //rgb(255,255,255);
    PB.canvas.FillRect(PB.ClientRect); //fondo
      //Dibuja objetos
      For o In objetos do
          o.Dibujar;

//  Else
//      s.Dibujar
//  End If
  If EstPuntero = EP_SELECMULT Then DibujRecSeleccion;
//pb.Canvas.TextOut(0,0,'x_cam=' + FloatToStr(v2d.x_cam) + '  ');
//pb.Canvas.TextOut(0,15,'x_des=' + FloatToStr(v2d.x_des) + '  ');
end;
procedure TModEdicion.InicMover;
//Procedimiento que inicia un desplazamiento de la pantalla. Se debe llamar cada vez que se puede
//iniciar el proceso de desplazamiento
begin
    x_cam_a := v2d.x_cam;
    y_cam_a := v2d.y_cam;
end;
procedure TModEdicion.MoverDesp(dx, dy: integer);
//Desplazamiento de la pantalla
begin
pb.Canvas.TextOut(0,30,'dx=' + FloatToStr(dx) + '  ');
//    v2d.x_cam := round(x_cam_a + dx / v2d.zoom);
//    v2d.y_cam := round(y_cam_a + dy / v2d.zoom);
    v2d.x_cam := x_cam_a + dx ;
    v2d.y_cam := y_cam_a + dy ;
    //v2d.z_cam = z_cam_a + dz
    v2d.GuardarPerspectivaEn(Pfinal);  //para que no se regrese al valor inicial
End;

function TModEdicion.SeleccionaAlguno(xp, yp: Integer): TObjGraf;
//Rutina principal para determinar la selección de objetos. Si (xp,yp)
//selecciona a algún objeto, devuelve la referencia, sino devuelve "NIL"
var
i: Integer;
s: TObjGraf;
begin
  //Verifica primero entre los que están seleccionados
  Result := NIL; //valor por defecto
  //Explora objetos priorizando los que están encima
  For i := seleccion.Count-1 downTo 0 do begin
    s := seleccion[i];
    If s.LoSelecciona(xp, yp) Then begin
        Result:= s;
        Exit;
    End;
  end;
  //Explora objetos priorizando los que están encima
  For i := objetos.Count-1 downTo 0 do begin
    s := objetos[i];
    If s.LoSelecciona(xp, yp) Then begin
        Result := s;
        Exit;
    End;
  end;
End;
procedure TModEdicion.VerificarParaMover(xp, yp: Integer);
//Si se empieza el movimiento, selecciona primero algun elemento que
//pudiera estar debajo del puntero y actualiza "EstPuntero".
//Solo se debe ejecutar una vez al inicio del movimiento, para ello se
//usa la bandera ParaMover, que debe ponerse a FALSE aquí.
var s: TObjGraf;
begin
    For s In seleccion  do begin  //da prioridad a los elementos seleccionados
        s.InicMover(xp, yp);      //llama al evento inic_mover para cada objeto
        If s.Proceso Then  begin  //este objeto proceso el evento
            CapturoEvento := s;
            if s.Dimensionando then EstPuntero := EP_DIMEN_OBJ else EstPuntero := EP_NORMAL;
            ParaMover := False;    //para que ya no se llame otra vez
            Exit;
        End;
    end;
    For s In objetos do begin
        s.InicMover(xp, yp);    //llama al evento inic_mover para cada objeto
        If s.Proceso Then begin   //este objeto proceso el evento
            CapturoEvento := s;
            if s.Dimensionando then EstPuntero := EP_DIMEN_OBJ else EstPuntero := EP_NORMAL;
            EstPuntero := EP_NORMAL;
            ParaMover := False;   //para que ya no se llame otra vez
            Exit;
        End;
    end;
    //Ningún objeto ha capturado, el evento, asumimos que se debe realizar
    //el desplazamiento simple de los objetos seleccionados
//Debug.Print "   VerifParaMover: EP_MOV_OBJS"
    EstPuntero := EP_MOV_OBJS;
    CapturoEvento := NIL;      //ningún objeto capturo el evento
    ParaMover := False;        //para que ya no se llame otra vez
End;
function TModEdicion.VerificarMovimientoRaton(X, Y: Integer): TObjGraf;
//Anima la marcación de los objetos cuando el ratón pasa encima de ellos
//Devuelve referencia al objeto por el que pasa el cirsor
var s: TObjGraf;
begin

    s := SeleccionaAlguno(X, Y);    //verifica si selecciona a un objeto
    Result := s;  //devuelve referencia
//    If Not s = NIL Then
//        If s.Id = ID_CONECTOR Then  ;  //Or s.Seleccionado
//            Set s = Nothing  ;  //no válido para conectores
//        End If
//    End If
    //Se refresca la pantalla optimizando
    If s = NIL Then begin  //No hay ninguno por marcar
      If ultMarcado <> NIL Then begin
            //Si ya había uno marcado, se actualiza el dibujo y la bandera
            ultMarcado.Marcado := False;  //se desmarca
            ultMarcado := NIL;
            Refrescar;
        End;
      PB.Cursor := CUR_DEFEC;   //restaura cursor
    end
    Else begin   //Hay uno por marcar
      If ultMarcado = NIL Then begin
         //No había ninguno marcado
         ultMarcado := s;      //guarda
         s.Marcado := True;    //lo marca
         Refrescar;            //y se dibuja
      end Else begin  //ya había uno marcado
           If ultMarcado = s Then  //es el mismo
               //no se hace nada
           Else begin    //había otro marcado
               ultMarcado.Marcado := False;  //se desmarca
               ultMarcado := s ;   //actualiza
               s.Marcado := True;
               Refrescar;          //y se dibuja
           End;
        End;
    End;

End;
(*
//Respuesta al evento doble click
Public Sub DblClick()
Dim s: TObjGraf
    Set s = SeleccionaAlguno(x_pulso, y_pulso)
    If s = NIL Then    ;  //En diagrama
        Exit Sub
    Else                    ;  //En objeto
        RaiseEvent DblClickObj(s)
    End If
End Sub

;  //***********Funciones para administrar los elementos visibles y seleccion por teclado**********
Public Function NumeroVisibles(): Integer
;  //devuelve el número de objetos visibles
Dim v: TObjGraf
Dim tmp: Integer
    tmp = 0
    For Each v In objetos
        tmp = tmp + 1
    Next
    NumeroVisibles = tmp
End Function

Private Function PrimerVisible(): TObjGraf
;  //devuelve el primer objeto visible
Dim i: Integer
2Dim v: TObjGraf
    For i = 1 To objetos.Count
        Set v = objetos(i)
        Set PrimerVisible = v: Exit Function
    Next
End Function

Private Function UltimoVisible(): TObjGraf
;  //devuelve el último objeto visible
Dim i: Integer
Dim v: TObjGraf
    For i = objetos.Count To 1 Step -1
        Set v = objetos(i)
        Set UltimoVisible = v: Exit Function
    Next
End Function

Public Function SiguienteVisible(c: TObjGraf): TObjGraf
;  //devuelve el siguiente objeto visible en el orden de creación
Dim i: Integer
Dim o: TObjGraf
        ;  //busca su orden dentro de los objetos
        For i = 1 To objetos.Count
            If objetos(i) Is c Then Exit For
        Next
        ;  //calcula el siguiente elemento
        Do
            i = i + 1
            If i > objetos.Count Then   ;  //se ha llegado al final del conjunto
                Set SiguienteVisible = PrimerVisible()
                Exit Function
            End If
            Set o = objetos(i)
        Loop While False
        ;  //selecciona el siguiente visible
        Set SiguienteVisible = objetos(i)
End Function

Public Function AnteriorVisible(c: TObjGraf): TObjGraf
;  //devuelve el anterior objeto visible en el orden de creación
Dim i: Integer
Dim o: TObjGraf
        ;  //busca su orden dentro de los objetos
        For i = 1 To objetos.Count
            If objetos(i) Is c Then Exit For
        Next
        ;  //calcula el elemento anterior
        Do
            i = i - 1
            If i < 1 Then  ;  //se ha llegado al inicio
                Set AnteriorVisible = UltimoVisible()
                Exit Function
            End If
            Set o = objetos(i)
        Loop While False
        ;  //selecciona el siguiente visible
        Set AnteriorVisible = objetos(i)
End Function

Public Sub SeleccionarSiguiente()
;  //Selecciona el siguiente elemento visible en el orden de creación.
;  //Si no hay ninguno seleccionado, selecciona el primero
Dim s: TObjGraf
Dim i: Integer
    If NumeroVisibles() = 0 Then Exit Sub
    If seleccion.Count = 1 Then     ;  //hay uno seleccionado
        Set s = seleccion(1)    ;  //toma el seleccionado
        Set s = SiguienteVisible(s)
        Call DeseleccionarTodos
        Seleccionar s
    Else               ;  //hay cero o más de uno seleccionado
        Set s = PrimerVisible          ;  //selecciona el primero
        Call DeseleccionarTodos
        Seleccionar s
    End If
    Call Refrescar
End Sub

Public Sub SeleccionarAnterior()
;  //Selecciona el anterior elemento visible en el orden de creación.
;  //Si no hay ninguno seleccionado, selecciona el ultimo
Dim s: TObjGraf
Dim i: Integer
    If NumeroVisibles() = 0 Then Exit Sub
    If seleccion.Count = 1 Then     ;  //hay uno seleccionado
        Set s = seleccion(1)    ;  //toma el seleccionado
        Set s = AnteriorVisible(s)
        Call DeseleccionarTodos
        Seleccionar s
    Else               ;  //hay cero o más de uno seleccionado
        Set s = UltimoVisible()          ;  //selecciona el ultimo
        Call DeseleccionarTodos
        Seleccionar s
    End If
    Call Refrescar
End Sub

Sub KeyDown(tec: Integer, Shift: Integer)
;  //Procesa el evento KeyDown()
Dim v: TObjGraf
    If Shift = 0 Then   ;  //********************* Teclas normales ***********************
        ;  //If tec = 13 Then PropiedSeleccion ;  //Debe procesarlo el diagrama
        If tec = 46 Then ElimSeleccion      ;  //DELETE
        If tec = 9 Then Call SeleccionarSiguiente                 ;  //TAB
        If tec = 27 Then Call DeseleccionarTodos: Call Refrescar  ;  //ESCAPE
        If seleccion.Count = 0 Then     ;  //si no hay objetos seleccionados
            If tec = 37 Then Call moverDerecha(DESPLAZ_MENOR)        ;  //derecha
            If tec = 39 Then Call moverIzquierda(DESPLAZ_MENOR)      ;  //izquierda
            If tec = 40 Then Call moverArriba(DESPLAZ_MENOR)         ;  //arriba
            If tec = 38 Then Call moverAbajo(DESPLAZ_MENOR)          ;  //abajo
        Else        ;  //hay seleccionados
            If tec = 37 Then ;  //derecha
                For Each v In seleccion
                    If Not v.Bloqueado Then v.X = v.X - DESPLAZ_MENOR
                Next
                Call Refrescar
            End If
            If tec = 39 Then ;  //izquierda
                For Each v In seleccion
                    If Not v.Bloqueado Then v.X = v.X + DESPLAZ_MENOR
                Next
                Call Refrescar
            End If
            If tec = 40 Then ;  //arriba
                For Each v In seleccion
                    If Not v.Bloqueado Then v.Y = v.Y + DESPLAZ_MENOR
                Next
                Call Refrescar
            End If
            If tec = 38 Then ;  //abajo
                For Each v In seleccion
                    If Not v.Bloqueado Then v.Y = v.Y - DESPLAZ_MENOR
                Next
                Call Refrescar
            End If
        End If
    ElseIf Shift = 1 Then   ;  //**********************Shift + ************************
        If tec = 9 Then Call SeleccionarAnterior              ;  //TAB
    ElseIf Shift = 2 Then   ;  //**********************Ctrl + ************************
        If tec = 107 Then Call AmpliarClick      ;  //+
        If tec = 109 Then Call ReducirClick      ;  //-
        If tec = 37 Then Call moverDerecha(DESPLAZ_MAYOR)   ;  //derecha
        If tec = 39 Then Call moverIzquierda(DESPLAZ_MAYOR) ;  //izquierda
        If tec = 40 Then Call moverArriba(DESPLAZ_MAYOR)    ;  //arriba
        If tec = 38 Then Call moverAbajo(DESPLAZ_MAYOR)     ;  //abajo
    ElseIf Shift = 3 Then       ;  //******************Shift + Ctrl*************************
        picSal.MousePointer = vbSizeAll     ;  //indica modo Zoom + desplazamiento
    End If
End Sub

Sub KeyUp(tec: Integer, Shift: Integer)
;  //Procesa el evento KeyUp()
    picSal.MousePointer = vbDefault
    If Shift = 0 Then           ;  //****************** Teclas normales ********************
    ElseIf Shift = 3 Then       ;  //******************Shift + Ctrl*************************
    End If
End Sub
*)
procedure TModEdicion.AgregarObjGrafico(og: TObjGraf; AutoPos: boolean = true);
//Agrega un objeto grafico al editor. El objeto gráfico debe haberse creado previamente,
//y ser de tipo TObjGraf o un descendiente. "AutoPos", permite posiciionar automáticamente
//al objeto en pantalla, de modo que se evite ponerlo siempre en la misma posición.
var
  x: single;
  y: single;
begin
  Modif := True;        //Marca el editor como modificado
  //Posiciona tratando de que siempre aparezca en pantalla
  if AutoPos Then begin  //Se calcula posición
    x := v2d.Xvirt(100, 100) + 30 * objetos.Count Mod 400;
    y := v2d.Yvirt(100, 100) + 30 * objetos.Count Mod 400;
    og.Ubicar(x,y);
  end;
  //configura eventos para ser controlado por este editor
  og.OnSelec   := @ObjGraf_Select;    //referencia a procedimiento de selección
  og.OnDeselec := @ObjGraf_Unselec;  //referencia a procedimiento de "de-selección"
  og.OnCamPunt := @ObjGraf_SetPointer;    //procedimiento para cambiar el puntero
//  Refrescar(s)   ;                //Refresca objeto
  objetos.Add(og);                //agrega elemento
end;
procedure TModEdicion.EliminarObjGrafico(obj: TObjGraf);  //elimina un objeto grafico
begin
    Modif := True;  //Marca documento como modificado
    obj.Deselec;  //por si acaso
    objetos.Remove(obj);
//    Case obj.Id
//    Case ID_SIMBOLO
//        If obj.Seleccionado Then obj.Deselec;
//        objetos.Remove(obj.NombreObj)  ;  //quita elemento
//    Case ID_TEXTO
//        If obj.Seleccionado Then Deseleccionar obj
//        Call frm.objetos.Remove(obj.NombreObj)  ;  //quita elemento
//    Case ID_CONECTOR
//        Call EliminarConec(frm, obj)
//    Case IOQ_ORDEN
//        If obj.Seleccionado Then Deseleccionar obj
//        Set od = obj
//        If od.TienePadre Then od.TablaPad.DesconectarOrden
//        Set od = Nothing
//        objetos.Remove(obj.NombreObj)  ;  //quita elemento
//    End;
    obj := nil;
End;
procedure TModEdicion.EliminarTodosObj;
//Elimina todos los objetos gráficos existentes
//var o: TMiObjeto;
begin
  if objetos.Count=0 then exit;  //no hay qué eliminar
  //elimina
  DeseleccionarTodos;  //por si acaso hay algun simbolo seleccionado
  objetos.Clear;    //limpia la lista de objetos
  EstPuntero := EP_NORMAL;
  ParaMover := false;
  CapturoEvento := nil;
  ultMarcado := nil;     //por si había alguno marcado
  Modif := true;    //indica que se modificó
//    EliminarObjGrafico(o);
  PB.Cursor := CUR_DEFEC;        //define cursor
End;
//******************* Funciones de visualización **********************
procedure TModEdicion.AmpliarClick(factor: real = FACTOR_AMPLIA_ZOOM;
                        xr: integer = 0; yr: integer = 0);
var anc_p: Real ;  //ancho de pantalla
    alt_p: Real ;  //alto de pantalla
    x_zoom, y_zoom: Single;
begin
    If v2d.zoom < ZOOM_MAX_CONSULT Then
        v2d.zoom := v2d.zoom * factor;
    If (xr <> 0) Or (yr <> 0) Then begin  //se ha especificado una coordenada central
        anc_p := PB.width / v2d.zoom;
        alt_p := PB.Height / v2d.zoom;
        v2d.XYvirt(xr, yr, x_zoom, y_zoom);     //convierte
        v2d.FijarVentana(PB.Width, PB.Height,
                x_zoom - anc_p / 2, x_zoom + anc_p / 2, y_zoom - alt_p / 2, y_zoom + alt_p / 2);
    End;
    v2d.GuardarPerspectivaEn(Pfinal);  //para que no se regrese al ángulo inicial
    Refrescar;
End;
procedure TModEdicion.ReducirClick(factor: Real = FACTOR_AMPLIA_ZOOM;
                        x_zoom: Real = 0; y_zoom: Real = 0);
begin
    If v2d.zoom > ZOOM_MIN_CONSULT Then
        v2d.zoom := v2d.zoom / factor;
    v2d.GuardarPerspectivaEn(Pfinal)  ;  //para que no se regrese al ángulo inicial
    Refrescar;
End;
/////////////////////////  Funciones de selección /////////////////////////////
procedure TModEdicion.SeleccionarTodos;
var s: TObjGraf;
begin
    For s In objetos do s.Selec; //selecciona todos
End;
procedure TModEdicion.DeseleccionarTodos();
var s: TObjGraf;
begin
  For s In objetos do //no se explora "seleccion" porque se modifica con "s.Deselec"
    if s.Seleccionado then s.Deselec;
//  seleccion.Clear; //No se puede limpiar simplemente la lista. Se debe llamar a s.Deselec
End;
function  TModEdicion.Seleccionado: TObjGraf;
//Devuelve el objeto seleccionado. Si no hay ninguno seleccionado, devuelve NIL.
begin
  Result := nil;   //valor por defecto
  if seleccion.Count = 0 then exit;  //no hay
  //hay al menos uno
  Result := seleccion[seleccion.Count-1];  //devuelve el único o último
End;
function  TModEdicion.ObjPorNombre(nom: string): TObjGraf;
//Devuelve la referecnia a un objeto, dado el nombre. Si no encuentra, devuelve NIL.
var s: TObjGraf;
begin
  Result := nil;   //valor por defecto
  if nom = '' then exit;
  For s In objetos do
    if s.nombre = nom then begin
       Result := s;
       break;
    end;
End;
(*
Public Function ElimSeleccion(): Long
;  //Elimina la selección. Devuelve número de objetos eliminados.
Dim v: TObjGraf
    ElimSeleccion = seleccion.Count
    For Each v In seleccion ;  //explora todos
        Call EliminarObjGrafico(v)
    Next
    Call Refrescar
End Function

Public Sub moverAbajo(Optional desp: Single = DESPLAZ_MENOR) ;  //abajo
;  //Genera un desplazamiento en la pantalla haciendolo independiente del
;  //factor de ampliación actual
Dim z: Single ;  //zoom
    z = v2d.zoom
    Call Desplazar(0, desp / z)
    Call Refrescar
End Sub

Public Sub moverArriba(Optional desp: Single = DESPLAZ_MENOR) ;  //arriba
;  //Genera un desplazamiento en la pantalla haciendolo independiente del
;  //factor de ampliación actual
Dim z: Single ;  //zoom
    z = v2d.zoom
    Call Desplazar(0, -desp / z)
    Call Refrescar
End Sub

Public Sub moverDerecha(Optional desp: Single = DESPLAZ_MENOR) ;  //derecha
;  //Genera un desplazamiento en la pantalla haciendolo independiente del
;  //factor de ampliación actual
Dim z: Single ;  //zoom
    z = v2d.zoom
    Call Desplazar(desp / z, 0)
    Call Refrescar
End Sub

Public Sub moverIzquierda(Optional desp: Single = DESPLAZ_MENOR) ;  //izquierda
;  //Genera un desplazamiento en la pantalla haciendolo independiente del
;  //factor de ampliación actual
Dim z: Single ;  //zoom
    z = v2d.zoom
    Call Desplazar(-desp / z, 0)
    Call Refrescar
End Sub

Private Sub Desplazar(dx: Single, dy: Single)
;  //Procedimiento "estandar" para hacer un desplazamiento de la pantalla
;  //Varía los parámetros de la perspectiva "x_cam" e "y_cam"
    Call v2d.Desplazar(dx, dy)
    Call v2d.GuardarPerspectivaEn(Pfinal)  ;  //para que no se regrese al valor inicial
End Sub
*)
/////////////////////////   Funciones del Rectángulo de Selección /////////////////////////
procedure TModEdicion.BorraRecSeleccion();
//BORRA por métodos gráficos el rectángulo de selección en pantalla
begin
    v2d.FijaLapiz(psDot, 1, clGreen);
    v2d.FijaModoEscrit(pmNOTXOR);
    v2d.rectang0(x1Sel_a, y1Sel_a, x2Sel_a, y2Sel_a);
    v2d.FijaModoEscrit(pmCopy);
//    If USAR_BMP Then CopiarBMP;
End;
procedure TModEdicion.DibujRecSeleccion();
//Dibuja por métodos gráficos el rectángulo de selección en pantalla
begin
    v2d.FijaLapiz(psDot, 1, clGreen);
    v2d.FijaModoEscrit(pmNOTXOR);
    v2d.rectang0(x1Sel, y1Sel, x2Sel, y2Sel);
    v2d.FijaModoEscrit(pmCopy);
//    If USAR_BMP Then CopiarBMP;

    x1Sel_a := x1Sel; y1Sel_a := y1Sel;
    x2Sel_a := x2Sel; y2Sel_a := y2Sel;
End;
procedure TModEdicion.InicRecSeleccion(X, Y: Integer);
//Inicia el rectángulo de selección, con las coordenadas
begin
    x1Sel:= X; y1Sel := Y;
    x2Sel := X; y2Sel := Y;
    x1Sel_a := x1Sel;
    y1Sel_a := y1Sel;
    x2Sel_a := x2Sel;
    y2Sel_a := y2Sel;
    //Realiza el primer dibujo
    DibujRecSeleccion;
End;
function TModEdicion.RecSeleccionNulo: Boolean;
 //Indica si el rectángulo de selección es de tamaño NULO o despreciable
begin
    If (x1Sel = x2Sel) And (y1Sel = y2Sel) Then
        RecSeleccionNulo := True
    Else
        RecSeleccionNulo := False;
End;
function TModEdicion.enRecSeleccion(X, Y: Single): Boolean;
//Devuelve verdad si (x,y) esta dentro del rectangulo de seleccion.
var xMin, xMax: Integer;   //coordenadas mínimas y máximas del recuadro
    yMin, yMax: Integer;
    xx1, yy1: Single;
    xx2, yy2: Single;
begin
    //guarda coordenadas mínimas y máximas
    If x1Sel < x2Sel Then begin
        xMin := x1Sel;
        xMax := x2Sel;
    end Else begin
        xMin := x2Sel;
        xMax := x1Sel;
    End;
    If y1Sel < y2Sel Then begin
        yMin := y1Sel;
        yMax := y2Sel;
    end Else begin
        yMin := y2Sel;
        yMax := y1Sel;
    End;

    v2d.XYvirt(xMin, yMin, xx1, yy1);
    v2d.XYvirt(xMax, yMax, xx2, yy2);

    //verifica si está en región
    If (X >= xx1) And (X <= xx2) And (Y >= yy1) And (Y <= yy2) Then
        enRecSeleccion := True
    Else
        enRecSeleccion := False;
End;
(*
Public Sub CopiarAPortapapeles()
;  //Copia la selección en un archivo temporal y en el portapapeles.
Dim s: TObjGraf
Dim nar: Integer
    If seleccion.Count = 0 Then Exit Sub
    ;  //Generar archivo con contenido de copia
    nar = FreeFile
    Open CarpetaTmp & "\bolsa.txt" For Output: #nar
    For Each s In seleccion  ;  //explora todos
        Call s.EscCadenaObjeto(nar)
    Next s
    Close #nar
    ;  //copia al portapapeles
    Clipboard.Clear
    Clipboard.SetText LeeArchivo(CarpetaTmp & "\bolsa.txt")
    Call Refrescar
End Sub

Public Sub PegarDePortapapeles()
;  //Pega la selección en el reporte indicado
Dim nar: Integer
Dim Linea: String
Dim v: TObjGraf
Dim IDog: Integer         ;  //identificador de objeto gráfico
Dim error: String
    ;  //empieza a leer archivo
    nar = FreeFile
    If Dir(CarpetaTmp & "\bolsa.txt") = "" Then Exit Sub
    Open CarpetaTmp & "\bolsa.txt" For Input: #nar
    Call DeseleccionarTodos
    While Not EOF(nar)
        Line Input #nar, Linea
        If Linea Like "<OG??>" Then     ;  //Objeto gráfico
            IDog = Val(Mid$(Linea, 4, 2))
            Set v = AgregarObjGrafico(IDog, 1)
            If v = NIL Then Exit Sub   ;  //Hubo error
            error = v.LeeCadenaObjeto(nar)    ;  //lee los datos del objeto
            If error <> "" Then MsgBox error
            Seleccionar v
        End If
    Wend
    Close #nar
    Call Refrescar
End Sub

Public Sub GuardarPerspectiva(nar: Integer)
;  //Escribe datos de perspectiva en disco
    Print #nar, "<PERS>"   ;  //Marcador
    ;  //guarda parámetro de visualización
    Print #nar, N2f(v2d.zoom) & w & w & w & _
                N2f(v2d.x_cam) & w & N2f(v2d.y_cam) & ",,,,,"
    Print #nar, "</PERS>"   ;  //Marcador final
End Sub

Public Sub LeePerspectiva(nar: Integer)
;  //lee datos de perspectiva. No lee marcador inicial
Dim a(): String
Dim tmp: String
    ;  //lee perspectiva inicial
    Line Input #nar, tmp   ;  //lee parámetros
    a = Split(tmp, w)
    v2d.zoom = f2N(a(0))
    v2d.x_cam = f2N(a(3)): v2d.y_cam = f2N(a(4))
    Line Input #nar, tmp   ;  //lee marcador de fin
    Call v2d.GuardarPerspectivaEn(Pfinal)   ;  //para que no se regrese
End Sub

;  //--------------- Funciones de Arrastre---------------
Public Sub InicArrastre(dat: String)
;  //Inicia un arrastre en el pictureBox asociado.
    RaiseEvent InicArrastreFil(dat)
End Sub

;  //--------------- Funciones de Búsqueda---------------
Public Sub InicBuscar(bus: String, _
                      Optional ambito: Integer = AMB_TODO, _
                      Optional ignCaja: Boolean = True, _
                      Optional palComp: Boolean = False)
;  //Inicia una búsqueda definiendo sus parámetros.
;  //La cadena "bus" debe ser de una sola línea.
;  //El parámetro "ambito" no se usa. Se mantiene por compatibilidad.
    PosEnc = 1    ;  //Fija posición inicial para buscar
    CadBus = bus        ;  //Guarda cadena de búsqueda
    CajBus = ignCaja    ;  //Guarda parámetro de caja
    PalCBus = palComp
End Sub

Public Function BuscarSig(): String
;  //Realiza una búsqueda iniciada con "InicBuscar"
;  //La búsqueda se hace a partir de la posición donde se dejó en la última búsqueda.
;  //Devuelve la cadena de búsqueda.
    ;  //Protecciones
    If objetos.Count = 0 Then Exit Function
    ;  //búsqueda
    If PalCBus Then ;  //Debe ser palabra completa
;  //        p = BuscarCadPos(CadBus, PosEnc, PosBus2, CajBus)
;  //        Do While p.xt <> 0
;  //            p2 = PosSigPos(p, Len(CadBus))
;  //            If EsPalabraCompleta(p, p2) Then Exit Do
;  //            PosEnc = p2
;  //            p = BuscarCadPos(CadBus, PosEnc, PosBus2, CajBus)
;  //        Loop
    Else    ;  //Búsqueda normal
;  //        p = BuscarCadPos(CadBus, PosEnc, PosBus2, CajBus)
;  //        If p.xt <> 0 Then p2 = PosSigPos(p, Len(CadBus))
    End If
    ;  //verifica si encontró
;  //    If p.xt <> 0 Then
;  //        Redibujar = True       ;  //para no complicarnos, dibuja todo
;  //        If haysel Then Call LimpSelec
;  //        ;  //Selecciona cadena
;  //        posCursorA p
;  //        Call FijarSel0      ;  //Fija punto base
;  //        posCursorA2 p2
;  //        Call ExtenderSel ;  //Extiende selección
;  //        BuscarSig = CadBus  ;  //devuelve cadena
;  //    Else
;  //        BuscarSig = CadBus  ;  //devuelve cadena
;  //        MsgBox "No se encuentra el texto: ;  //" & CadBus & ";  //", vbExclamation
;  //    End If
End Function
*)
////////////////// Eventos para atender requerimientos de objetos "TObjGraf" ///////////////////////
procedure TModEdicion.ObjGraf_Select(obj: TObjGraf);
//Agrega un objeto gráfico a la lista "selección". Este método no debe ser llamado directamente.
//Si se quiere seleccionar un objeto se debe usar la forma objeto.Selec.
begin
//    If obj.Seleccionado Then Exit;  //Ya está seleccionado. No debe ser necesario
    seleccion.Add(obj);      { TODO : Verificar si se puede manejar bien el programa sin usar la propiedad "NombreObj"}
End;
procedure TModEdicion.ObjGraf_Unselec(obj: TObjGraf);
//Quita un objeto gráfico de la lista "selección". Este método no debe ser llamado directamente.
//Si se quiere quitar la seleccion a un objeto se debe usar la forma objeto.Deselec.
begin
//    If not obj.Seleccionado Then Exit;
    seleccion.Remove(obj);
End;
procedure TModEdicion.ObjGraf_SetPointer(Punt: integer);
//procedimiento que cambia el puntero del mouse. Es usado para proporcionar la los objetos "TObjGraf"
//la posibilidad de cambiar el puntero.
begin
    PB.Cursor := Punt;        //define cursor
end;

end.


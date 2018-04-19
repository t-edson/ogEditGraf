{Aquí se deben definir los objetos gráficos con los que trabajará nuestra aplicación.
 Todos ellos deben descender de TObjGraf, para que puedadn ser tratados por el motor
 de edición "ogMotEdicion".}

unit ObjGraficos;
{$mode objfpc}{$H+}
interface
uses
  Controls, Classes, SysUtils, Graphics, GraphType, LCLIntf, Dialogs,
  ogMotGraf2D, ogDefObjGraf, ogControls;

type

{ TMiObjeto }
TMiObjeto = class(TObjGrafCtrls)  //objeto gráfico que dibujaremos
  procedure Draw; override;  //Dibuja el objeto gráfico
  procedure ProcDesac(estado0: Boolean);   //Para responder a evento del botón
  constructor Create(mGraf: TMotGraf); override;
private
  Bot1   : TogButton;          //Botón
  procedure ReLocate(newX, newY: Single; UpdatePCtrls: boolean=true); virtual;
end;

implementation

constructor TMiObjeto.Create(mGraf: TMotGraf);
begin
  inherited;
  Bot1 := AddButton(24,24,BOT_REPROD, @ProcDesac);
  pcTOP_LEF.posicion := TD_CEN_IZQ;
//  Resize;             //Se debe llamar después de crear los puntos de control para poder ubicarlos
  ProcDesac(False);   //Desactivado := False
  name := 'Objeto';
end;

procedure TMiObjeto.Draw;
var s: String;
begin
  //Dibuja etiqueta
  v2d.FijaLapiz(psSolid, 1, COL_GRIS);
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, name);
  //muestra un rectángulo
  v2d.FijaLapiz(psSolid, 1, clBlack);
  v2d.SetBrush(TColor($D5D5D5));
  v2d.RectangR(x, y+10, x+width, y+height);
  Bot1.estado:= false;
  inherited;
end;

procedure TMiObjeto.ReLocate(newX, newY: Single; UpdatePCtrls: boolean);
//Reubica elementos, del objeto. Es llamado cuando se cambia la posición del objeto, con
//o sin cambio de las dimensiones.
var x2: Single;
begin
  inherited;
  x2 := x + width;
  Buttons[0].Locate(x2 - 24, y + 1);
end;

procedure TMiObjeto.ProcDesac(estado0: Boolean);
begin
   showmessage('Pulsado');
end;
end.


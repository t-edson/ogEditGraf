{                                frameVisCplex
Este Frame será usado para colocar nuestro editor gráfico. Requiere un objeto TPaintBox,
como salida gráfica. Para que funcione como editor de objetos gráficos, debe crearse una
instancia de "TEditionMot" y darle la referencia del PaintBox.
Aquí también se deben poner las rutinas que permiten agregar los diversos objetos
gráficos con los que trabajará nuestra aplicación.

                                              Por Tito Hinostroza  11/05/2014
}
unit frameEditor;
{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Graphics, GraphType, lclType,
  dialogs, lclProc, ogEditionMot, ogShape, ogConnector;

type

  { TfraEditor }

  TfraEditor = class(TFrame)
  published
    ImageList1: TImageList;
    PaintBox1: TPaintBox;
  private
    motEdi: TEditionMot;  //motor de edición
  public
    function AddShapeRectangle(x0, y0, shpW, shpH: Single): TOgShape;
    function AddConector: TOgConnector;
  public     //Inicialización
    procedure ModeSelect;
    procedure ModeRotate;
    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;
  end;


implementation
{$R *.lfm}

function TfraEditor.AddShapeRectangle(x0, y0, shpW, shpH: Single): TOgShape;
//Agrega un objeto de tipo TOgShape al editor.
var
  og: TOgShape;
begin
  //Crea objeto y define tamaño inicial
  og := TOgShape.Create(motEdi.v2d);
  motEdi.AddGraphObject(og);
  og.ReSize(shpW, shpH);  //Se define antes para poder ubicar correctamente los punto de conexión y de la geometría

  //Define geometría
  og.AddPoint(0   , 0);
  og.AddPoint(shpW, 0);
  og.AddPoint(shpW, shpH);
  og.AddPoint(0   , shpH);

  //Crea puntos de conexión
  og.AddPtoConex(0     , 0);
  og.AddPtoConex(shpW/2, 0);
  og.AddPtoConex(shpW  , 0);

  og.AddPtoConex(0     , shpH/2);
  og.AddPtoConex(shpW  , shpH/2);

  og.AddPtoConex(0     , shpH);
  og.AddPtoConex(shpW/2, shpH);
  og.AddPtoConex(shpW  , shpH);

  //Configuración
  og.ShowPtosConex:=true;
  //og.Highlight:=false;
  //og.pcTOP_CEN.Visible := false;
  og.ReLocate(x0, y0);
  Result := og;
end;

function TfraEditor.AddConector: TOgConnector;
var
  o: TOgConnector;
begin
  o := TOgConnector.Create(motEdi.v2d);
  motEdi.AddGraphObject(o);
  Result := o;
end;
//Inicialización
procedure TfraEditor.ModeSelect;
{Pone al editor en modo "Seleccionar"}
begin
  motEdi.editorMode:= edmSelect;
end;
procedure TfraEditor.ModeRotate;
{Pone al editor en modo "Seleccionar"}
begin
  motEdi.editorMode:= edmRotat;
end;
constructor TfraEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  motEdi := TEditionMot.Create(PaintBox1);
  motEdi.v2d.ImageList := ImageList1;
end;
destructor TfraEditor.Destroy;
begin
  motEdi.Destroy;
  inherited;
end;

end.


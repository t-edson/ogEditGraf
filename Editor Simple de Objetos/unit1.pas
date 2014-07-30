unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, Graphics, ExtCtrls, ogMotEdicion, ogDefObjGraf;

type
  //define el tipo de objeto a dibujar
  TMiObjeto = class(TObjGraf)
    procedure Dibujar; override;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    PaintBox1: TPaintBox;   //donde se dibujará
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    motEdi: TModEdicion;  //motor de edición
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}

procedure TMiObjeto.Dibujar();
begin
  v2d.FijaTexto(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, 'Objeto');
  v2d.FijaLapiz(psSolid, 1, clBlack);
  v2d.FijaRelleno(TColor($D5D5D5));
  v2d.RectangR(x, y, x+ancho, y+alto);
  inherited;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var og: TMiObjeto;
begin
  //crea motor de edición
  motEdi := TModEdicion.Create(PaintBox1);
  //agrega objetos
  og := TMiObjeto.Create(motEdi.v2d);
  motEdi.AgregarObjGrafico(og);
  og := TMiObjeto.Create(motEdi.v2d);
  motEdi.AgregarObjGrafico(og);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  motEdi.free;
end;

end.


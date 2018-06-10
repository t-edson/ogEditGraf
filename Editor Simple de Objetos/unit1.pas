unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, Graphics, ExtCtrls, ogMotEdicion, ogDefObjGraf;

type

  { TMiObjeto }
  //define el tipo de objeto a dibujar
  TMiObjeto = class(TObjGraf)
    procedure Draw; override;
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

procedure TMiObjeto.Draw;
begin
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, 'Objeto');
  v2d.SetPen(psSolid, 1, clBlack);
  v2d.SetBrush(TColor($D5D5D5));
  v2d.RectangR(x, y, x+width, y+height);
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
  motEdi.AddGraphObject(og);
  og := TMiObjeto.Create(motEdi.v2d);
  motEdi.AddGraphObject(og);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  motEdi.free;
end;

end.


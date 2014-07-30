unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  frameEditor;

type

  { TForm1 }

  TForm1 = class(TForm)
    fraMotEdicion1: TfraEditor;
    procedure FormCreate(Sender: TObject);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  fraMotEdicion1.AgregaObjeto;
  fraMotEdicion1.AgregaObjeto;
end;

end.


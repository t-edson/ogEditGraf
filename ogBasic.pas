{Unidad con las declaraciones globales básicas que aplican a toda la librería
Por Tito Hinostroza 4/12/2024
}
unit ogBasic;
{$mode ObjFPC}{$H+}
interface
uses
  Classes, SysUtils, LazUtilities;
type
//Define el Tipo de dato perspectiva
Tperspectiva = record
  zoom  : Real;        //zoom de la perspectiva
  x_cam : Single;     //parámetro de desplazamiento x_cam
  y_cam : Single;     //parámetro de desplazamiento y_cam
end;

type    //Expresiones de ubicación
  TlocExpType = (letAbsol,    //Valor absoluto con respecto al cuadro de selección.
              {La fórmula es un literal numérico simple: = <número>. Por ejemplo:
                  = 5
                  = 2.150
              }
                 letFactW,    //Factor a multiplicar por el ancho.
              {La fórmula es el producto de un factor por el ancho: = <factor>*Width
                   Por ejemplo:
                   = 2*width
                   = 0.5*width
              }
                 letFactH     //Factor a multiplicar por el alto.
              {La fórmula es el producto de un factor por el alto: = <factor>*Height
                   Por ejemplo:
                   = 2*height
                   = 0.5*height
              }
                 );

  { TlocExpType }
  {Objeto que define la fórmula o expresión de ubicación.}
  TLocExp = object
    expType: TlocExpType; //Tipo de expresión
    valAbs : Single;      //Valor a usar cuando expType es "letAbsol"
    valFac : Single;      //Factor a usar cuando expType es "letFactW" o "letFactH".
    procedure SetFromText(expTxt: String);
    function newVal(Width, Height: Single): Single;
  end;


implementation

{ TLocExp }
procedure TLocExp.SetFromText(expTxt: String);
{Define la fórmula mediante una cadena.
De momento la fórmula solo puede ser de las formas:
<valor>
<valor>*width
<valor>*height
}
var
  p: SizeInt;
  v: String;
begin
  p := Pos('*', expTxt);
  if p = 0 then begin   //Es de la forma <valor>
    expType := letAbsol;
    valAbs     := LazUtilities.StrToDouble(expTxt);
  end else begin //Es de la forma <valor>*<Width> o <valor>*<Hight>
    v := LowerCase(Copy(expTxt, p + 1, 1000));
    if trim(v) = 'width' then begin
      expType := letFactW;
      valFac :=  LazUtilities.StrToDouble(Copy(expTxt, 1 ,p-1));
    end else begin
      expType := letFactH;
      valFac :=  LazUtilities.StrToDouble(Copy(expTxt, 1 ,p-1));
    end;
  end;
end;
function TLocExp.newVal(Width, Height: Single): Single;
{Obtiene un nuveo valor de la expresión, a partir de su fórmula y de las variables "Width"
y "Height".}
begin
  case expType of
    letAbsol: exit(valAbs);
    letFactW: exit(valFac * Width);
    letFactH: exit(valFac * Height);
  end;
end;


end.


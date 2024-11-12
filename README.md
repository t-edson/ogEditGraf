ogEditGraf 2.8
==============

Librería en Lazarus, para la creación de editores simples de objetos gráficos.

![SynFacilCompletion](http://blog.pucp.edu.pe/blog/tito/wp-content/uploads/sites/610/2018/04/Sin-título-12.png "Título de la imagen")

Esta librería permite implementar fácilmente un editor de objetos gráficos en dos dimensiones. Los objetos gráficos se crean a partir de una clase base, que incluye las funciones básicas para poder ser manipulados por un editor, con opciones de seleccionar, mover, y redimensionar los objetos. 

Se compone de las unidades:

* ogMotGraf2d.pas -> Es el motor gráfico, en donde se encuentran las rutinas de dibujo. Usa métodos comunes del lienzo (Canvas), pero puede ser cambiado para usar alguna otra librería gráfica.
* ogDefObjGraf.pas -> Es donde se define la clase TObjGraf, que es la clase que se usa para crear a todos los objetos gráficos de nuestra aplicación. También se definen algunos objetos accesorios.
* ogEditionMot.pas -> Es el motor de edición de objetos gráficos. Esta diseñado para trabajar con los objetos TObjGraf o descendientes. Incluye las rutinas para seleccionar, mover y redimensionar objetos con el ratón.
* ogControls.pas -> Unidad que define objetos gráficos que funcionan al estilo de los controles de una GUI típica. También define a la clase TObjGrafCtrls, descendiente de TObjGraf que puede incluir controles.

Para implementar un sencillo editor de objetos gráficos, se puede incluir el siguiente código en el formulario principal:

```
unit Unit1;
{$mode objfpc}{$H+}
interface
uses
  Classes, Forms, Controls, Graphics, ExtCtrls, ogEditionMot, ogDefObjGraf;

type
  //define el tipo de objeto a dibujar
  TMiObjeto = class(TObjGraf)
    procedure Draw; override;
  end;

  TForm1 = class(TForm)
    PaintBox1: TPaintBox;   //donde se dibujará
    procedure FormCreate(Sender: TObject);
  private
    motEdi: TEditionMot;  //motor de edición
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}

procedure TMiObjeto.Draw();
begin
  v2d.SetPen(psSolid, 1, clBlack);
  v2d.RectangR(x, y, x+width, y+height);
  inherited;
end;

procedure TForm1.FormCreate(Sender: TObject);
var og: TMiObjeto;
begin
  //Crea motor de edición
  motEdi := TEditionMot.Create(PaintBox1);
  //Agrega objeto
  og := TMiObjeto.Create(motEdi.v2d);
  motEdi.AddGraphObject(og);
end;

end.
```

Este ejemplo mostrará un objeto rectangular en pantalla, con posibilidad de desplazarlo y dimensionarlo.

Las rutinas de dibujo, se dirigen siempre, a un control PaintBox, que debe ser indicado al momento de crear el motor de edición.

Este sencillo ejemplo solo requiere incluir un control TPaintBox en el formulario principal. Sin embargo, para modularizar mejor la aplicación, se sugiere usar una unidad especial para definir los objetos gráficos de nuestra aplicación, y un frame para incluir el PaintBox y las rutinas de trabajo del motor de edición.

## Arquitectura de la librería

Las unidades que componen  la librería siguen una organización particular, que determina también la arquitectura de la aplicación.

Esta librería se basa en los siguientes principios:

* Toda aplicación debe tener un Motor Gráfico.
* Toda aplicación debe tener un Motor de Edición.
* Los objetos a mostrar deben ser descendientes de la clase TObjGraf.


Un proyecto sencillo, requiere solo incluir a la unidad ogEditionMot y a la unidad ogDefObjGraf:

```
        +-------------------------+
        |        Programa         |
        +-------------------------+
             |                |
             |                |
     +------------------+     |
     |   ogEditionMot   |     |       <-------- MOTOR DE EDICIÓN
     +------------------+     |  
       |             |        |
       |       +------------------+
       |       |   ogDefObjGraf   |   <------- Definición de TObjGraf
       |       +------------------+
       |            |
   +-------------------+
   |    ogMotGraf2D    |              <-------- MOTOR GRÁFICO
   +-------------------+
```

La unidad ogMotGraf2D es la que contiene los métodos gráficos que dibujan en pantalla. Es por eso que es accedidad por ogDefObjGraf y ogEditGraf. El programa principal no suele acceder a ogMotGraf2D, porque para dibujar puede acceder al motor gráfico mediante la clase TObjGraf que está definida en ogDefObjGraf.

Un ejemplo de esta forma de trabajo, se encuentra en el proyecto ejemplo "Sample1 - Object Editor" en donde se ve que se ha definido una sola clase de objeto gráfico llamada TMyGraphObject, en la unidad del formulario principal.

En la práctica, sin embargo, se tendrán diversas clases de objetos gráficos, por lo que resulta conveniente agruparlas en una unidad a la que podríamos llamar "ObjGraficos". 

También se suele poner al motor de edición en una Frame en lugar de la propia aplicación. De modo que el programa tendría la siguiente forma:

```
        +-------------------------+
        |        Programa         |
        +-------------------------+
                      |              
        +-------------------------+
        |         Frame           |
        +-------------------------+
             |               |
             |       +-------------+
             |       | ObjGraficos |  <------ Definición de mis objetos gráficos
             |       +-------------+      
             |               |            
     +------------------+    |            
     |   ogEditionMot   |    |        <------ MOTOR DE EDICIÓN
     +------------------+    |            
       |             |       |            
       |       +------------------+       
       |       |   ogDefObjGraf   |   <------ Definición de TObjGraf
       |       +------------------+       
       |            |                     
   +-------------------+                  
   |    ogMotGraf2D    |              <------ MOTOR GRÁFICO
   +-------------------+
```
   
Esta es la forma recomendada por modularidad y tiene además la ventaja de poder crear diversas vistas, creando simplemente diversas instancias del Frame.

Un ejemplo de este diseño, se puede observar en el proyecto ejemplo "Sample2 - Object Editor Frame".

## Objetos gráficos 

Los objetos graficos son los elementos visibles que aparecen en el editor y que pueden ser manipulados por eventos del teclado o del ratón. 

Visualmente, se componen de:

* Un área de selección, en donde se espera que se dibuje la figura completa del objeto. Esta área de selección es la que permite mover el 
* Ocho puntos de control que permiten cambiar las dimensiones del objeto, tanto horizontal como verticalmente.
* Dos puntos de control (inicial y final) para habilitar la conexión del objeto gráfico a puntos de conexión.
* Cero o más puntos de conexiones. Los puntos de conexión son los puntos de anclaje a los que otros objetos gráficos pueden conectarse.

A nivel de código, son instancias de una clase derivada de la clase base "TObjGraf".



## La clase TObjGraf

Este es la clase que define a todos los objetos gráficos que pueden aparecer en la pantalla del motor de edición.

Es una clase virtual, por lo que no se puede instanciar. Para agregar un objeto gráfico al editor, debe crearse primero una clase descendiente:

```
  TMiObjeto = class(TObjGraf)

  end;
```

Con esta clase, es posible luego crear objetos que se pueden agregar a un editor gráfico "TEditionMot":

```
var
  og: TMyObject;
  motEdi: TEditionMot;  //Motor de edición

  ...

  og := TMyObject.Create(motEdi.v2d);

  motEdi.AddGraphObject(og);

  end;
```

Un objeto derivado de "TObjGraf" es invisible por defecto (excepto por los puntos de control y el resaltado), porque no se le ha definido una figura en el método de dibujo. Es por ello que cuando se crea una clase derivada, se debe implementar el método Draw():

```
  //define el tipo de objeto a dibujar
  TMiObjeto = class(TObjGraf)
    procedure Draw; override;
  end;

procedure TMiObjeto.Draw();
begin
  v2d.SetPen(psSolid, 1, clBlack);
  v2d.RectangR(x, y, x+width, y+height);
  inherited;
end;
```

El objeto "v2d" es lo que se llama, el motor gráfico y pertenece a la clase "TMotGraf".

Hay libertad para dibujar el objeto en la forma que se desee, con las siguientes consideraciones:

- Debe dibujarse usando métodos del motor gráfico "TMotGraf" que se esté usando. Esta clase dibuja directamente en el Canvas del control "TPaintBox" que se le haya asignado.
- Debe llamarse al método heredado "inherited" para dibujar los puntos de control y puntos de conexión, además de implementar el resaltado de la forma.
- El área de selección del objeto está definido por sus coordenadas (x,y) y por sus dimensiones (width, height).

Para más información, revisar los ejemplos.

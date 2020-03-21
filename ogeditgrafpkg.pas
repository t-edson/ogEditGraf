{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ogEditGrafPkg;

{$warn 5023 off : no warning about unused units}
interface

uses
  ogControls, ogDefObjGraf, ogEditionMot, ogMotGraf2D, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('ogEditGrafPkg', @Register);
end.

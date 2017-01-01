{
Unidad con declaraciones globales del proyecto
}
unit Globales;
{$mode objfpc}{$H+}
interface
uses  Classes, SysUtils, Forms, SynEdit, SynEditKeyCmds, MisUtils,
      SynEditTypes, StrUtils, lclType, FileUtil,
      types, LazLogger, Menus ;

const
  NOM_PROG = 'Minimat';   //nombre de programa
  {$I ../version.txt}   //versión del programa

var
   //Variables globales
   MsjError    : String;    //Bandera - Mensaje de error

   rutApp     : string;      //ruta de la aplicación
   rutSamples : string;      //ruta de la carpeta de scripts
   rutMacros  : string;      //ruta de la carpeta de macros
   rutLenguajes: string;     //ruta para guardar las sintaxis

   archivoEnt  : string;    //archivo de entrada
   MostrarError: Boolean;   //Bandera para mostrar mensajesde error.
   ActConsSeg  : Boolean;   //Activa consultas en segundo plano

function LeerParametros: boolean;
function NombDifArc(nomBase: String): String;

implementation

function  LeerParametros: boolean;
{lee la linea de comandos
 Si hay error devuelve TRUE}
var
   par : String;
   i   : Integer;
begin
   Result := false;    //valor por defecto
   //valores por defecto
   archivoEnt := '';
   MostrarError := True;
   ActConsSeg := False;
   //Lee parámetros de entrada
   par := ParamStr(1);
   if par = '' then begin
     MsgErr('Nombre de archivo vacío.');
     Result := true;
     exit;  //sale con error
   end;
   if par[1] = '/' then begin  //es parámetro
      i := 1;  //para que explore desde el principio
   end else begin  //es archivo
      archivoEnt := par;  //el primer elemento es el archivo de entrada
      i := 2;  //explora siguientes
   end;
   while i <= ParamCount do begin
      par := ParamStr(i);
      If par[1] = '/' Then begin
         Case UpCase(par) of
            '/NOERROR': MostrarError := False;
            '/ERROR': MostrarError := True;
            '/CONSEG': ActConsSeg := True;
            '/NOCONSEG': ActConsSeg := False;
         Else begin
                MsgErr('Error. Parámetro desconocido: ' + par);
                Result := true;
                exit;  //sale con error
              End
         End
      end Else begin
//         archivoSal := par;
      End;
      inc(i);  //pasa al siguiente
   end;
End;
function NombDifArc(nomBase: String): String;
{Genera un nombre diferente de archivo, tomando el nombre dado como raiz.}
const MAX_ARCH = 10;
var i : Integer;    //Número de intentos con el nombre de archivo de salida
    cadBase : String;   //Cadena base del nombre base
    extArc: string;    //extensión

  function NombArchivo(i: integer): string;
  begin
    Result := cadBase + '-' + IntToStr(i) + extArc;
  end;

begin
   Result := nomBase;  //nombre por defecto
   extArc := ExtractFileExt(nomBase);
   if ExtractFilePath(nomBase) = '' then exit;  //protección
   //quita ruta y cambia extensión
   cadBase := ChangeFileExt(nomBase,'');
   //busca archivo libre
   for i := 0 to MAX_ARCH-1 do begin
      If not FileExists(NombArchivo(i)) then begin
        //Se encontró nombre libre
        Exit(NombArchivo(i));  //Sale con nombre
      end;
   end;
   //todos los nombres estaban ocupados. Sale con el mismo nombre
End;

initialization
  //inicia directorios de la aplicación
  rutApp :=  ExtractFilePath(Application.ExeName);  //incluye el '\' final
  rutSamples := rutApp + 'samples';
//  rutMacros := rutApp + 'macros';
//  rutLenguajes := rutApp + 'lenguajes';
  archivoEnt := '';    //archivo de entrada
  //verifica existencia de carpetas de trabajo
  try
    if not DirectoryExists(rutSamples) then begin
      msgexc('No se encuentra carpeta /samples. Se creará.');
      CreateDir(rutSamples);
    end;
{    if not DirectoryExists(rutMacros) then begin
      msgexc('No se encuentra carpeta /macros. Se creará.');
      CreateDir(rutMacros);
    end;
    if not DirectoryExists(rutLenguajes) then begin
      msgexc('No se encuentra carpeta /lenguajes. Se creará.');
      CreateDir(rutLenguajes);
    end;
    if not FileExists(rutApp+'plink.exe') then begin
      msgErr('No se encuentra archivo plink.exe');
    end;}
  except
    msgErr('Error. No se puede leer o crear directorios.');
  end;

finalization
  //Por algún motivo, la unidad HeapTrc indica que hay gotera de memoria si no se liberan
  //estas cadenas:
  rutApp :=  '';
  rutMacros := '';
  rutSamples := '';
  rutLenguajes := '';
end.


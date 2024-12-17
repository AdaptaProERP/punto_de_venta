// Programa   : DPPOSBANCARIO
// Fecha/Hora : 30/11/2006 16:03:52
// Propósito  : Incluir/Modificar DPPOSBANCARIO
// Creado Por : DpXbase
// Llamado por: DPPOSBANCARIO.LBX
// Aplicación : Ventas y Cuentas Por Cobrar             
// Tabla      : DPPOSBANCARIO

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPPOSBANCARIO(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Puntos  de Venta Bancarios"

  cExcluye:="PVB_CODIGO,;
             PVB_DESCRI,;
             PVB_CODBCO,;
             PVB_SERIAL,;
             PVB_ACTIVO"

  DEFAULT cCodigo:="1234"

  DEFAULT nOption:=1

   nOption:=IIF(nOption=2,0,nOption) 

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM DPPOSBANCARIO WHERE ]+BuildConcat("PVB_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=" Incluir {oDp:DPPOSBANCARIO}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM DPPOSBANCARIO WHERE ]+BuildConcat("PVB_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Puntos  de Venta Bancarios              "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:DPPOSBANCARIO}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPPOSBANCARIO]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="PVB_CODIGO" // Clave de Validación de Registro

  oPOSBANCARIO:=DPEDIT():New(cTitle,"DPPOSBANCARIO.edt","oPOSBANCARIO" , .F. )

  oPOSBANCARIO:nOption  :=nOption
  oPOSBANCARIO:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oPOSBANCARIO
  oPOSBANCARIO:SetScript()        // Asigna Funciones DpXbase como Metodos de oPOSBANCARIO
  oPOSBANCARIO:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oPOSBANCARIO:nClrPane:=oDp:nGris

  IF oPOSBANCARIO:nOption=1 // Incluir en caso de ser Incremental
     // oPOSBANCARIO:RepeatGet(NIL,"PVB_CODIGO") // Repetir Valores
     oPOSBANCARIO:PVB_ACTIVO:=.T.
     oPOSBANCARIO:PVB_CODIGO:=oPOSBANCARIO:Incremental("PVB_CODIGO",.T.)

     // Turno de Cierre
//   oPOSBANCARIO:PVB_TURNO1:="00:00"
//   oPOSBANCARIO:PVB_TURNO2:="00:00"
//   oPOSBANCARIO:PVB_TURNO3:="00:00 "
//   oPOSBANCARIO:PVB_TURNO4:="00:00 "

  ENDIF

  oPOSBANCARIO:PVB_TURNO1:=IF(Empty(oPOSBANCARIO:PVB_TURNO1),"00:00",oPOSBANCARIO:PVB_TURNO1)
  oPOSBANCARIO:PVB_TURNO2:=IF(Empty(oPOSBANCARIO:PVB_TURNO2),"00:00",oPOSBANCARIO:PVB_TURNO2)
  oPOSBANCARIO:PVB_TURNO3:=IF(Empty(oPOSBANCARIO:PVB_TURNO3),"00:00",oPOSBANCARIO:PVB_TURNO3)
  oPOSBANCARIO:PVB_TURNO4:=IF(Empty(oPOSBANCARIO:PVB_TURNO4),"24:00",oPOSBANCARIO:PVB_TURNO4)
  
  //Tablas Relacionadas con los Controles del Formulario

  oPOSBANCARIO:CreateWindow()       // Presenta la Ventana

  
  oPOSBANCARIO:ViewTable("DPBANCOS","BAN_NOMBRE","BAN_CODIGO","PVB_CODBCO")

  
  //
  // Campo : PVB_CODIGO
  // Uso   : Código                                  
  //
  @ 1.0, 1.0 GET oPOSBANCARIO:oPVB_CODIGO  VAR oPOSBANCARIO:PVB_CODIGO  VALID CERO(oPOSBANCARIO:PVB_CODIGO) .AND.; 
                 oPOSBANCARIO:ValUnique(oPOSBANCARIO:PVB_CODIGO);
                    WHEN (AccessField("DPPOSBANCARIO","PVB_CODIGO",oPOSBANCARIO:nOption);
                    .AND. oPOSBANCARIO:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10

    oPOSBANCARIO:oPVB_CODIGO:cMsg    :="Código"
    oPOSBANCARIO:oPVB_CODIGO:cToolTip:="Código"

  @ oPOSBANCARIO:oPVB_CODIGO:nTop-08,oPOSBANCARIO:oPVB_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : PVB_ACTIVO
  // Uso   : Activo                                  
  //
  @ 8.2, 1.0 CHECKBOX oPOSBANCARIO:oPVB_ACTIVO  VAR oPOSBANCARIO:PVB_ACTIVO  PROMPT ANSITOOEM("Activo");
                    WHEN (AccessField("DPPOSBANCARIO","PVB_ACTIVO",oPOSBANCARIO:nOption);
                    .AND. oPOSBANCARIO:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10

    oPOSBANCARIO:oPVB_ACTIVO:cMsg    :="Activo"
    oPOSBANCARIO:oPVB_ACTIVO:cToolTip:="Activo"



  //
  // Campo : PVB_DESCRI
  // Uso   : Descripción                             
  //
  @ 2.8, 1.0 GET oPOSBANCARIO:oPVB_DESCRI  VAR oPOSBANCARIO:PVB_DESCRI ;
                    WHEN (AccessField("DPPOSBANCARIO","PVB_DESCRI",oPOSBANCARIO:nOption);
                    .AND. oPOSBANCARIO:nOption!=0);
                    FONT oFontG;
                    SIZE 120,10

    oPOSBANCARIO:oPVB_DESCRI:cMsg    :="Descripción"
    oPOSBANCARIO:oPVB_DESCRI:cToolTip:="Descripción"

  @ oPOSBANCARIO:oPVB_DESCRI:nTop-08,oPOSBANCARIO:oPVB_DESCRI:nLeft SAY "Descripción" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : PVB_CODBCO
  // Uso   : Banco                                   
  //
  @ 4.6, 1.0 BMPGET oPOSBANCARIO:oPVB_CODBCO  VAR oPOSBANCARIO:PVB_CODBCO  VALID CERO(oPOSBANCARIO:PVB_CODBCO);
                   .AND. !VACIO(oPOSBANCARIO:PVB_CODBCO,NIL);
                   .AND. oPOSBANCARIO:oDPBANCOS:SeekTable("BAN_CODIGO",oPOSBANCARIO:oPVB_CODBCO,NIL,oPOSBANCARIO:oBAN_NOMBRE);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPBANCOS"), oDpLbx:GetValue("BAN_CODIGO",oPOSBANCARIO:oPVB_CODBCO)); 
                    WHEN (AccessField("DPPOSBANCARIO","PVB_CODBCO",oPOSBANCARIO:nOption);
                    .AND. oPOSBANCARIO:nOption!=0);
                    FONT oFontG;
                    SIZE 24,10

    oPOSBANCARIO:oPVB_CODBCO:cMsg    :="Banco"
    oPOSBANCARIO:oPVB_CODBCO:cToolTip:="Banco"

  @ oPOSBANCARIO:oPVB_CODBCO:nTop-08,oPOSBANCARIO:oPVB_CODBCO:nLeft SAY GetFromVar("{oDp:xDPBANCOS}") PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//GetFromVar("{oDp:xDPBANCOS}")
  @ oPOSBANCARIO:oPVB_CODBCO:nTop,oPOSBANCARIO:oPVB_CODBCO:nRight+5 SAY oPOSBANCARIO:oBAN_NOMBRE;
                            PROMPT oPOSBANCARIO:oDPBANCOS:BAN_NOMBRE PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  


  @ 10,3 SAY "Cuenta Bancaria";
         PIXEL SIZE NIL,12 FONT oFont COLOR 0,oDp:nGris2 

  //
  // Campo : PVB_CTABCO
  // Uso   : Código de Moneda                        
  //
  @ 14,15.0 BMPGET oPOSBANCARIO:oPVB_CTABCO  VAR oPOSBANCARIO:PVB_CTABCO;
                    VALID oPOSBANCARIO:VALCTABCO();
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPCTABANCO",NIL,NIL,NIL,NIL,oPOSBANCARIO:PVB_CTABCO,NIL,NIL,NIL,oPOSBANCARIO:oPVB_CTABCO),;
                             oDpLbx:GetValue("BCO_CTABAN",oPOSBANCARIO:oPVB_CTABCO)); 
                    WHEN (AccessField("DPPOSBANCARIO","PVB_CTABCO",oPOSBANCARIO:nOption);
                    .AND. oPOSBANCARIO:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10

    oPOSBANCARIO:oPVB_CTABCO:cMsg    :="Cuenta Bancaria"
    oPOSBANCARIO:oPVB_CTABCO:cToolTip:="Cuenta Bancaria"


   @ 14,3 SAY oPOSBANCARIO:oCTABANCO;
          PROMPT SQLGET("DPCTABANCO",[CONCAT(BCO_CODIGO," ",BAN_NOMBRE)],"INNER JOIN DPBANCOS ON BCO_CODIGO=BAN_CODIGO WHERE BCO_CTABAN"+GetWhere("=",oPOSBANCARIO:PVB_CTABCO));
          PIXEL SIZE NIL,12 FONT oFont COLOR 0,oDp:nGris2 



 //
  // Campo : PVB_SERIAL
  // Uso   : Serial                                  
  //
  @ 6.4, 1.0 GET oPOSBANCARIO:oPVB_SERIAL  VAR oPOSBANCARIO:PVB_SERIAL ;
                    WHEN (AccessField("DPPOSBANCARIO","PVB_SERIAL",oPOSBANCARIO:nOption);
                    .AND. oPOSBANCARIO:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oPOSBANCARIO:oPVB_SERIAL:cMsg    :="Serial"
    oPOSBANCARIO:oPVB_SERIAL:cToolTip:="Serial"

  @ oPOSBANCARIO:oPVB_SERIAL:nTop-08,oPOSBANCARIO:oPVB_SERIAL:nLeft SAY "Serial" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

   @ 2,1 GROUP oBtn TO 4, 21.5 PROMPT " Cierres "

   @ 06,20 SAY "1:"
   @ 07,20 SAY "2:"
   @ 08,20 SAY "3:"
   @ 09,20 SAY "4:"

   @ 07,24 GET oPOSBANCARIO:PVB_TURNO1 PICTURE "99:99"
   @ 08,24 GET oPOSBANCARIO:PVB_TURNO2 PICTURE "99:99"
   @ 09,24 GET oPOSBANCARIO:PVB_TURNO3 PICTURE "99:99"
   @ 10,24 GET oPOSBANCARIO:PVB_TURNO4 PICTURE "99:99"




   oPOSBANCARIO:PVB_TURNO1:="00:00 "

/*
  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oPOSBANCARIO:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oPOSBANCARIO:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oPOSBANCARIO:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF
*/


  oPOSBANCARIO:Activate({||oPOSBANCARIO:INICIO()})

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oPOSBANCARIO

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oPOSBANCARIO:nOption=1 // Incluir en caso de ser Incremental
     
     oPOSBANCARIO:PVB_CODIGO:=oPOSBANCARIO:Incremental("PVB_CODIGO",.T.)
  ENDIF

RETURN .T.

FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oPOSBANCARIO:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 55,55 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD


   IF oPOSBANCARIO:nOption!=2

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
            TOP PROMPT "Grabar"; 
            ACTION (oPOSBANCARIO:Save())

     oBtn:cToolTip:="Guardar"

     oPOSBANCARIO:oBtnSave:=oBtn


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XCANCEL.BMP";
            TOP PROMPT "Cancela"; 
            ACTION (oPOSBANCARIO:Cancel()) CANCEL


   
   ELSE


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
            ACTION (oPOSBANCARIO:Cancel()) CANCEL

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })

 
RETURN .T.



/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

/*
// Ejecución PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.

  lResp:=oPOSBANCARIO:ValUnique(oPOSBANCARIO:PVB_CODIGO)
  IF !lResp
        MsgAlert("Registro "+CTOO(oPOSBANCARIO:PVB_CODIGO),"Ya Existe")
  ENDIF

  IF EMPTY(oPOSBANCARIO:PVB_CODIGO)
     MensajeErr("Código no Puede estar Vacio")
     RETURN .F.

  ENDIF

  IF !Empty(oPOSBANCARIO:PVB_CTABCO)
     oPOSBANCARIO:PVB_CODBCO:=SQLGET("DPCTABANCO","BCO_CODIGO","BCO_CTABAN"+GetWhere("=",oPOSBANCARIO:PVB_CTABCO))
  ENDIF

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
RETURN .T.


FUNCTION VALCTABCO()

  IF !Empty(oPOSBANCARIO:PVB_CTABCO) .AND. !ISSQLFIND("DPCTABANCO","BCO_CTABAN"+GetWhere("=",oPOSBANCARIO:PVB_CTABCO))
     EVAL(oPOSBANCARIO:oPVB_CTABCO:bAction)
     RETURN .T.
  ENDIF

  oPOSBANCARIO:oCTABANCO:Refresh(.T.)

RETURN .T.



/*
<LISTA:PVB_CODIGO:Y:GET:Y:N:Y:Código,PVB_DESCRI:N:GET:N:N:Y:Descripción,PVB_CODBCO:N:BMPGETL:N:N:N:Banco,PVB_SERIAL:N:GET:N:N:Y:Serial
,PVB_ACTIVO:N:CHECKBOX:N:N:Y:Activo>
*/


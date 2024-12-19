// Programa   : DPCAJAINST
// Fecha/Hora : 26/07/2005 11:32:56
// Propósito  : Incluir/Modificar DPCAJAINST
// Creado Por : DpXbase
// Llamado por: DPCAJAINST.LBX
// Aplicación : Bancos y Caja                           
// Tabla      : DPCAJAINST

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPCAJAINST(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Instrumentos de Caja"

  cExcluye:="ICJ_CODIGO,;
             ICJ_NOMBRE,;
             ICJ_CUENTA,;
             ICJ_MONEDA,;
             ICJ_EGRESO,;
             ICJ_DEPOSI,;
             ICJ_INGRES,;
             ICJ_CODMON,;
             ICJ_COMEN1,;
             ICJ_COMEN2"

  DEFAULT cCodigo:="1234"

  DEFAULT nOption:=1

  nOption:=IIF(nOption=2,0,nOption)

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM DPCAJAINST WHERE ]+BuildConcat("ICJ_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=" Incluir {oDp:DPCAJAINST}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM DPCAJAINST WHERE ]+BuildConcat("ICJ_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Instrumentos de Caja                    "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:DPCAJAINST}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPCAJAINST]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="ICJ_CODIGO" // Clave de Validación de Registro

  oCAJAINST:=DPEDIT():New(cTitle,"DPCAJAINST.edt","oCAJAINST" , .F. )

  oCAJAINST:nOption  :=nOption
  oCAJAINST:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oCAJAINST
  oCAJAINST:SetScript()        // Asigna Funciones DpXbase como Metodos de oCAJAINST
  oCAJAINST:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oCAJAINST:nClrPane:=oDp:nGris

  IF oCAJAINST:nOption=1 // Incluir en caso de ser Incremental
     oCAJAINST:ICJ_MONEDA:=oTable:ICJ_MONEDA           // Moneda
     oCAJAINST:ICJ_CODMON:=oTable:ICJ_CODMON           // Código de Moneda
     oCAJAINST:ICJ_CODIGO:=oCAJAINST:Incremental("ICJ_CODIGO",.T.)
  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oCAJAINST:CreateWindow()       // Presenta la Ventana

  IF oDp:nVersion>=6
    oCAJAINST:ICJ_CUENTA:=EJECUTAR("DPGETCTAMOD","DPCAJAINST",oCAJAINST:ICJ_CODIGO)
  ENDIF

  oCAJAINST:ViewTable("DPCTA","CTA_DESCRI","CTA_CODIGO","ICJ_CUENTA")
  oCAJAINST:ViewTable("DPTABMON","MON_DESCRI","MON_CODIGO","ICJ_CODMON")

  
  //
  // Campo : ICJ_CODIGO
  // Uso   : Código                                  
  //
  @ 1.0, 1.0 GET oCAJAINST:oICJ_CODIGO  VAR oCAJAINST:ICJ_CODIGO  VALID CERO(oCAJAINST:ICJ_CODIGO) .AND.; 
                 oCAJAINST:ValUnique(oCAJAINST:ICJ_CODIGO);
                   .AND. !VACIO(oCAJAINST:ICJ_CODIGO,NIL);
                    WHEN (AccessField("DPCAJAINST","ICJ_CODIGO",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10

    oCAJAINST:oICJ_CODIGO:cMsg    :="Código"
    oCAJAINST:oICJ_CODIGO:cToolTip:="Código"

  @ oCAJAINST:oICJ_CODIGO:nTop-08,oCAJAINST:oICJ_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ICJ_NOMBRE
  // Uso   : Comentario                              
  //
  @ 2.8, 1.0 GET oCAJAINST:oICJ_NOMBRE  VAR oCAJAINST:ICJ_NOMBRE  VALID  !VACIO(oCAJAINST:ICJ_NOMBRE,NIL);
                    WHEN (AccessField("DPCAJAINST","ICJ_NOMBRE",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oCAJAINST:oICJ_NOMBRE:cMsg    :="Comentario"
    oCAJAINST:oICJ_NOMBRE:cToolTip:="Comentario"

  @ oCAJAINST:oICJ_NOMBRE:nTop-08,oCAJAINST:oICJ_NOMBRE:nLeft SAY "Comentario" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  //
  // Campo : ICJ_CUENTA
  // Uso   : Cuenta Contable (Activo)                
  //
  @ 4.6, 1.0 BMPGET oCAJAINST:oICJ_CUENTA  VAR oCAJAINST:ICJ_CUENTA ;
             VALID oCAJAINST:oDPCTA:SeekTable("CTA_CODIGO",oCAJAINST:oICJ_CUENTA,NIL,oCAJAINST:oCTA_DESCRI);
                   NAME "BITMAPS\FIND.BMP"; 
                   ACTION (oDpLbx:=DpLbx("DPCTAACT"), oDpLbx:GetValue("CTA_CODIGO",oCAJAINST:oICJ_CUENTA)); 
                   WHEN (AccessField("DPCAJAINST","ICJ_CUENTA",oCAJAINST:nOption);
                   .AND. oCAJAINST:nOption!=0);
                   FONT oFontG;
                   SIZE 80,10

  oCAJAINST:oICJ_CUENTA:cMsg    :="Cuenta Contable (Activo)"
  oCAJAINST:oICJ_CUENTA:cToolTip:="Cuenta Contable (Activo)"

  @ 0,0 SAY GetFromVar("{oDp:xDPCTA}")

  @ oCAJAINST:oICJ_CUENTA:nTop,oCAJAINST:oICJ_CUENTA:nRight+5 SAY oCAJAINST:oCTA_DESCRI;
                            PROMPT oCAJAINST:oDPCTA:CTA_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  //
  // Campo : ICJ_PORITF
  // Uso   : Retención de IGTF
  //

  @ 2.0,15.0 GET oCAJAINST:oICJ_PORITF  VAR oCAJAINST:ICJ_PORITF  PICTURE "99.99";
                    WHEN (AccessField("DPCAJAINST","ICJ_PORITF",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10 RIGHT

  oCAJAINST:oICJ_PORITF:cMsg    :="Retención IGTF"
  oCAJAINST:oICJ_PORITF:cToolTip:="Retención IGTF"


  //
  // Uso   : Retención de ISLR
  //

  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_ACTIVO  VAR oCAJAINST:ICJ_ACTIVO  PROMPT ANSITOOEM("Activo");
                    WHEN (AccessField("DPCAJAINST","ICJ_ACTIVO",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

  oCAJAINST:oICJ_ACTIVO:cMsg    :="Registro Activo"
  oCAJAINST:oICJ_ACTIVO:cToolTip:="Registro Activo"

  //
  // Campo : ICJ_MONEDA
  // Uso   : Moneda                                  
  //
  @ 6.4, 1.0 CHECKBOX oCAJAINST:oICJ_MONEDA  VAR oCAJAINST:ICJ_MONEDA  PROMPT ANSITOOEM("Moneda");
                    WHEN (AccessField("DPCAJAINST","ICJ_MONEDA",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10

    oCAJAINST:oICJ_MONEDA:cMsg    :="Moneda"
    oCAJAINST:oICJ_MONEDA:cToolTip:="Moneda"


  //
  // Campo : ICJ_EGRESO
  // Uso   : Realiza Pagos                           
  //
  @ 8.2, 1.0 CHECKBOX oCAJAINST:oICJ_EGRESO  VAR oCAJAINST:ICJ_EGRESO  PROMPT ANSITOOEM("Realiza Pagos");
                    WHEN (AccessField("DPCAJAINST","ICJ_EGRESO",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 118,10;
                    SIZE 4,10

    oCAJAINST:oICJ_EGRESO:cMsg    :="Realiza Pagos"
    oCAJAINST:oICJ_EGRESO:cToolTip:="Realiza Pagos"


  //
  // Campo : ICJ_DEPOSI
  // Uso   : Se deposita                             
  //
  @ 10.0, 1.0 CHECKBOX oCAJAINST:oICJ_DEPOSI  VAR oCAJAINST:ICJ_DEPOSI  PROMPT ANSITOOEM("Se deposita");
                    WHEN (AccessField("DPCAJAINST","ICJ_DEPOSI",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 106,10;
                    SIZE 4,10

    oCAJAINST:oICJ_DEPOSI:cMsg    :="Se deposita"
    oCAJAINST:oICJ_DEPOSI:cToolTip:="Se deposita"


  //
  // Campo : ICJ_INGRES
  // Uso   : Recibos de Ingreso
  //
  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_INGRES  VAR oCAJAINST:ICJ_INGRES  PROMPT ANSITOOEM("Recibos de Ingreso");
                    WHEN (AccessField("DPCAJAINST","ICJ_INGRES",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

    oCAJAINST:oICJ_INGRES:cMsg    :="Recibos de Ingreso"
    oCAJAINST:oICJ_INGRES:cToolTip:="Recibos de Ingreso"

  //
  // Campo : ICJ_INGCOM
  // Uso   : Ingreso desde Compras                    
  //
  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_INGCOM  VAR oCAJAINST:ICJ_INGCOM  PROMPT ANSITOOEM("Ingreso desde Compras");
                    WHEN (AccessField("DPCAJAINST","ICJ_INGCOM",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

    oCAJAINST:oICJ_INGCOM:cMsg    :="Ingreso desde Compras"
    oCAJAINST:oICJ_INGCOM:cToolTip:="Ingreso desde Compras"


  //
  // Campo : ICJ_REQNUM
  // Uso   : Requiere Número
  //
  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_REQNUM  VAR oCAJAINST:ICJ_REQNUM  PROMPT ANSITOOEM("Requiere Número");
                    WHEN (AccessField("DPCAJAINST","ICJ_REQNUM",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

    oCAJAINST:oICJ_REQNUM:cMsg    :="Requiere Número"
    oCAJAINST:oICJ_REQNUM:cToolTip:="Requiere Número"


  //
  // Campo : ICJ_DIRBCO
  // Uso   : Requiere Directorio Bancario
  //
  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_DIRBCO  VAR oCAJAINST:ICJ_DIRBCO  PROMPT ANSITOOEM("Requiere Directorio Bancario");
                    WHEN (AccessField("DPCAJAINST","ICJ_DIRBCO",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0 .AND. oCAJAINST:ICJ_INGRES);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

    oCAJAINST:oICJ_DIRBCO:cMsg    :="Requiere Directorio Bancario"
    oCAJAINST:oICJ_DIRBCO:cToolTip:="Requiere Directorio Bancario"




  //
  // Campo : ICJ_TRAING
  // Uso   : Transacción de Ingreso
  //

  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_TRAING  VAR oCAJAINST:ICJ_TRAING  PROMPT ANSITOOEM("Transacción Ingreso");
                    WHEN (AccessField("DPCAJAINST","ICJ_TRAING",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0 );
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

    oCAJAINST:oICJ_TRAING:cMsg    :="Acepta Transacción de Ingreso"
    oCAJAINST:oICJ_TRAING:cToolTip:="Acepta Transacción de Ingreso"

  //
  // Campo : ICJ_TRAEGR
  // Uso   : Transacción de Egreso
  //

  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_TRAEGR  VAR oCAJAINST:ICJ_TRAEGR  PROMPT ANSITOOEM("Transacción Egreso");
                    WHEN (AccessField("DPCAJAINST","ICJ_TRAEGR",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0 );
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

  oCAJAINST:oICJ_TRAEGR:cMsg    :="Acepta Transacción de Egreso"
  oCAJAINST:oICJ_TRAEGR:cToolTip:="Acepta Transacción de Egreso"

  //
  // Campo : ICJ_RETIMP
  // Uso   : Retención de ISLR
  //

  @ 2.0,15.0 CHECKBOX oCAJAINST:oICJ_RETIMP  VAR oCAJAINST:ICJ_RETIMP  PROMPT ANSITOOEM("Retención ISLR");
                    WHEN (AccessField("DPCAJAINST","ICJ_RETIMP",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0 .AND. oCAJAINST:ICJ_INGRES);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

  oCAJAINST:oICJ_RETIMP:cMsg    :="Retención de ISLR para Depositar"
  oCAJAINST:oICJ_RETIMP:cToolTip:="Retención de ISLR para Depositar"


  //
  // Campo : ICJ_COMBCO
  // Uso   : Retención de ISLR
  //

  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_COMBCO  VAR oCAJAINST:ICJ_COMBCO  PROMPT ANSITOOEM("Comisión Bancaria");
                    WHEN (AccessField("DPCAJAINST","ICJ_COMBCO",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0 .AND. oCAJAINST:ICJ_INGRES);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

  oCAJAINST:oICJ_COMBCO:cMsg    :="Comisión Bancaria para Depositar"
  oCAJAINST:oICJ_COMBCO:cToolTip:="Comisión Bancaria para Depositar"


  //
  // Campo : ICJ_CALITF
  // Uso   : Calcular ITF
  //

  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_CALITF  VAR oCAJAINST:ICJ_CALITF  PROMPT ANSITOOEM("Calcular IGTF");
                    WHEN (AccessField("DPCAJAINST","ICJ_CALITF",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

  oCAJAINST:oICJ_CALITF:cMsg    :="Calcular I.T.F"
  oCAJAINST:oICJ_CALITF:cToolTip:="Comisión I.T.F"


  //
  // Campo : ICJ_PAGELE
  // Uso   : Calcular ITF
  //

  @ 1.0,15.0 CHECKBOX oCAJAINST:oICJ_PAGELE  VAR oCAJAINST:ICJ_PAGELE  PROMPT ANSITOOEM("Pago Elétrónico");
                    WHEN (AccessField("DPCAJAINST","ICJ_PAGELE",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

  oCAJAINST:oICJ_PAGELE:cMsg    :="Pago Elétrónico"
  oCAJAINST:oICJ_PAGELE:cToolTip:="Pago Elétrónico"


  //
  // Campo : ICJ_CODMON
  // Uso   : Código de Moneda                        
  //
  @ 2.8,15.0 BMPGET oCAJAINST:oICJ_CODMON  VAR oCAJAINST:ICJ_CODMON  VALID  !VACIO(oCAJAINST:ICJ_CODMON,NIL);
                   .AND. oCAJAINST:oDPTABMON:SeekTable("MON_CODIGO",oCAJAINST:oICJ_CODMON,NIL,oCAJAINST:oMON_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPTABMON"), oDpLbx:GetValue("MON_CODIGO",oCAJAINST:oICJ_CODMON)); 
                    WHEN (AccessField("DPCAJAINST","ICJ_CODMON",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10

    oCAJAINST:oICJ_CODMON:cMsg    :="Código de Moneda"
    oCAJAINST:oICJ_CODMON:cToolTip:="Código de Moneda"




  @ 0,0 SAY GetFromVar("{oDp:xDPTABMON}")

// +" ADASDASDADASDSSA " 

  @ 0,0 SAY oCAJAINST:oMON_DESCRI;
        PROMPT oCAJAINST:oDPTABMON:MON_DESCRI PIXEL;
        SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  oCAJAINST:ICJ_MEMO:=ALLTRIM(oCAJAINST:ICJ_MEMO)  
  // Campo : ICJ_MEMO  
  // Uso   : Comentario                              
  //
  @ 1.0,15.0 GET oCAJAINST:oICJ_MEMO    VAR oCAJAINST:ICJ_MEMO  ;
             MEMO SIZE 80,80; 
             ON CHANGE 1=1;
             WHEN (AccessField("DPBANCODIR","ICJ_MEMO",oCAJAINST:nOption);
                   .AND. oCAJAINST:nOption!=0);
             FONT oFontG;
             SIZE 40,10

  oCAJAINST:oICJ_MEMO  :cMsg    :="Comentario"
  oCAJAINST:oICJ_MEMO  :cToolTip:="Comentario"

  @ oCAJAINST:oICJ_MEMO  :nTop-08,oCAJAINST:oICJ_MEMO  :nLeft SAY "Comentarios" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris
  //
  // Campo : ICJ_BMP   
  // Uso   : Archivo Bmp                             
  //
  @ 6.4,15.0 BMPGET oCAJAINST:oICJ_BMP     VAR oCAJAINST:ICJ_BMP    ;
                    NAME "BITMAPS\FOLDER5.BMP"; 
                    ACTION (cFile:=cGetFile32("Bmp File (*.bmp) |*.bmp|Archivos BitMaps (*.bmp) |*.bmp",;
                    "Seleccionar Archivo BITMAP (BMP)",1,cFilePath(oCAJAINST:ICJ_BMP),.f.,.t.),;
                    cFile:=STRTRAN(cFile,"\","/"),;
                    oCAJAINST:ICJ_BMP:=IIF(!EMPTY(cFile),cFile,oCAJAINST:ICJ_BMP),;
                    oCAJAINST:oICJ_BMP   :Refresh(),;
                    oCAJAINST:oImage1:LoadBmp(cFile));
                    WHEN .T.;
                    FONT oFontG

    oCAJAINST:oICJ_BMP   :cMsg    :="Archivo Bmp"
    oCAJAINST:oICJ_BMP   :cToolTip:="Archivo Bmp"

  @ 0,0 SAY "Fichero de Imagen BMP"
  @ oCAJAINST:oICJ_BMP:nBottom+1,oCAJAINST:oICJ_BMP:nLeft BITMAP oCAJAINST:oImage1 FILENAME oCAJAINST:ICJ_BMP PIXEL;
                            SIZE 30,30

  @ 05,10 SAY "% IGTF" RIGHT 


  //
  @ 4.8, 40 GET oCAJAINST:oICJ_TRAMA  VAR oCAJAINST:ICJ_TRAMA  VALID  .T.;
                    WHEN (AccessField("DPCAJAINST","ICJ_TRAMA",oCAJAINST:nOption);
                    .AND. oCAJAINST:nOption!=0);
                    FONT oFontG;
                    SIZE 40,10

    oCAJAINST:oICJ_TRAMA:cMsg    :="Trama para Impresora TheFactory"
    oCAJAINST:oICJ_TRAMA:cToolTip:=oCAJAINST:oICJ_TRAMA:cMsg

  @ oCAJAINST:oICJ_TRAMA:nTop-08,oCAJAINST:oICJ_TRAMA:nLeft SAY "Trama IF"+CRLF+"Thefactory" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  oCAJAINST:Activate({||oCAJAINST:INICIO()})

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oCAJAINST


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oCAJAINST:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 BOLD


   IF oCAJAINST:nOption!=2

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
            ACTION (oCAJAINST:Save())

     oBtn:cToolTip:="Guardar"

     oCAJAINST:oBtnSave:=oBtn


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XCANCEL.BMP";
            ACTION (oCAJAINST:Cancel()) CANCEL


   
   ELSE


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            ACTION (oCAJAINST:Cancel()) CANCEL

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })


 
RETURN .T.

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oCAJAINST:nOption=1 // Incluir en caso de ser Incremental
           // Repetir Valores
      oCAJAINST:ICJ_MONEDA:=oTable:ICJ_MONEDA           // Moneda
      oCAJAINST:ICJ_CODMON:=oTable:ICJ_CODMON           // Código de Moneda
     oCAJAINST:ICJ_CODIGO:=oCAJAINST:Incremental("ICJ_CODIGO",.T.)
  ENDIF

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

  lResp:=oCAJAINST:ValUnique(oCAJAINST:ICJ_CODIGO)
  IF !lResp
     MsgAlert("Registro "+CTOO(oCAJAINST:ICJ_CODIGO),"Ya Existe")
  ENDIF

  IF !oCAJAINST:ICJ_INGRES
     oCAJAINST:ICJ_DIRBCO:=.F.
  ENDIF

  IF EMPTY(oCAJAINST:ICJ_CODIGO)
     MensajeErr("Código no Puede estar Vacio")
     RETURN .F.
  ENDIF

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
  oDp:aCajaInst:={}

  IF oDp:nVersion>=6
    EJECUTAR("SETCTAINTMOD","DPCAJAINST",oCAJAINST:ICJ_CODIGO,NIL,"CUENTA",oCAJAINST:ICJ_CUENTA,.T.)
  ENDIF

RETURN .T.

/*
<LISTA:ICJ_CODIGO:Y:GET:Y:N:N:Código,ICJ_NOMBRE:N:GET:N:N:N:Comentario,ICJ_CUENTA:N:BMPGETL:N:N:Y:Cuenta Contable (Activo),ICJ_MONEDA:N:CHECKBOX:N:Y:Y:Moneda
,ICJ_EGRESO:N:CHECKBOX:N:N:Y:Realiza Pagos,ICJ_DEPOSI:N:CHECKBOX:N:N:Y:Se deposita,ICJ_INGRES:N:CHECKBOX:N:N:Y:Ingreso desde Ventas,ICJ_CODMON:N:BMPGETL:N:Y:N:Código de Moneda
,ICJ_COMEN1:N:GET:N:N:Y:Comentarios,ICJ_COMEN2:N:GET:N:N:Y:>
*/

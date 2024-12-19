// Programa   : DPSERIEFISCAL
// Fecha/Hora : 10/11/2005 17:43:41
// Propósito  : Incluir/Modificar DPSERIEFISCAL
// Creado Por : DpXbase
// Llamado por: DPSERIEFISCAL.LBX
// Aplicación : Ventas y Cuentas Por Cobrar             
// Tabla      : DPSERIEFISCAL

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPSERIEFISCAL(nOption,cLetra)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Series Fiscales"
  LOCAL aItems1:=GETOPTIONS("DPSERIEFISCAL","SFI_IMPFIS",.T.)
  LOCAL aItems2:=GETOPTIONS("DPSERIEFISCAL","SFI_PUERTO",.T.)
  LOCAL aCom   :=EJECUTAR("AMODE")

  AEVAL(aCom,{|a,n| aCom[n]:=a[1]+","+a[2]})

  
  AADD(aCom,"Ninguno")


  cExcluye:="SFI_MODELO,;
             SFI_LETRA,;
             SFI_NUMERO,;
             SFI_TICKET,;
             SFI_ITEMXP,;
             SFI_TEXTO,;
             SFI_AUTOMA,;
             SFI_EDITAB,;
             SFI_MEMO"

  IF EMPTY(aItems1) // .OR. ASCAN(aItems1,,"Ninguna")=0
     AADD(aItems1,"Ninguna")
  ENDIF

  DEFAULT cLetra:="A"

  DEFAULT nOption:=1

   nOption:=IIF(nOption=2,0,nOption) 

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM DPSERIEFISCAL WHERE ]+BuildConcat("SFI_LETRA")+GetWhere("=",cLetra)+[]
    cTitle   :=" Incluir {oDp:DPSERIEFISCAL}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM DPSERIEFISCAL WHERE ]+BuildConcat("SFI_LETRA")+GetWhere("=",cLetra)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Series Fiscales                         "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:DPSERIEFISCAL}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPSERIEFISCAL]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="SFI_MODELO" // Clave de Validación de Registro

  oSERIEFISCAL:=DPEDIT():New(cTitle,"DPSERIEFISCAL.edt","oSERIEFISCAL" , .F. )

  oSERIEFISCAL:nOption  :=nOption
  oSERIEFISCAL:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oSERIEFISCAL
  oSERIEFISCAL:SetScript()        // Asigna Funciones DpXbase como Metodos de oSERIEFISCAL
  oSERIEFISCAL:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oSERIEFISCAL:nClrPane:=oDp:nGris
  oSERIEFISCAL:cModelo :=oSERIEFISCAL:SFI_MODELO
  oSERIEFISCAL:bPostRun:={||.T.}
  oSERIEFISCAL:aCom   :=aCom
  oSERIEFISCAL:aItems2:=aItems2
  oSERIEFISCAL:lImpFis:=.F.
  oSERIEFISCAL:cLetra :=oSERIEFISCAL:SFI_LETRA


  IF oSERIEFISCAL:nOption=1 // Incluir en caso de ser Incremental

     // oSERIEFISCAL:RepeatGet(NIL,"SFI_MODELO") // Repetir Valores
     oSERIEFISCAL:SFI_LETRA :=SQLGET("DPSERIEFISCAL","SFI_LETRA"," WHERE 1=1 ORDER BY SFI_LETRA DESC LIMIT 1")
     oSERIEFISCAL:SFI_LETRA :=IF( Empty(oSERIEFISCAL:SFI_LETRA), oSERIEFISCAL:SFI_LETRA, CHR(ASC(oSERIEFISCAL:SFI_LETRA)+1))
     oSERIEFISCAL:SFI_ACTIVO:=.T.
     // AutoIncremental 

  ENDIF

//oSERIEFISCAL:SFI_LETRA,"oSERIEFISCAL:SFI_LETRA"

//  oSERIEFISCAL:SFI_CUENTA:=EJECUTAR("DPGETCTAMOD","DPCTAEGRESO_CTA",oCTAEGRESO:CEG_CODIGO,NIL,"CUENTA")
  oSERIEFISCAL:SFI_CUENTA:=EJECUTAR("DPGETCTAMOD","DPSERIEFISCAL_CTA",oSERIEFISCAL:SFI_LETRA,NIL,"CUENTA")

  oSERIEFISCAL:ViewTable("DPCTA"     ,"CTA_DESCRI","CTA_CODIGO","SFI_CUENTA")
  oSERIEFISCAL:ViewTable("DPPCLOG"   ,"PC_NOMBRE" ,"PC_NOMBRE" ,"SFI_PCNAME")
  oSERIEFISCAL:ViewTable("DPSUCURSAL","SUC_DESCRI","SUC_CODIGO","SFI_CODSUC")


  //Tablas Relacionadas con los Controles del Formulario
  oSERIEFISCAL:SFI_IMPFIS:=IIF(Empty(oSERIEFISCAL:SFI_IMPFIS),PADR("Ninguna",LEN(oSERIEFISCAL:SFI_IMPFIS)),oSERIEFISCAL:SFI_IMPFIS)

  oSERIEFISCAL:CreateWindow()       // Presenta la Ventana

  // oSERIEFISCAL:ViewTable("DPCTA"     ,"CTA_DESCRI","CTA_CODIGO","BCO_CUENTA")
  // Opciones del Formulario

  
  //
  // Campo : SFI_MODELO
  // Uso   : Modelo                                  
  //
  @ 1.0, 1.0 GET oSERIEFISCAL:oSFI_MODELO  VAR oSERIEFISCAL:SFI_MODELO;
                    VALID oSERIEFISCAL:ValUnique(oSERIEFISCAL:SFI_MODELO,"SFI_MODELO");
                   .AND. !VACIO(oSERIEFISCAL:SFI_MODELO,NIL);
                    WHEN (AccessField("DPSERIEFISCAL","SFI_MODELO",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                    FONT oFontG;
                    SIZE 120,10

    oSERIEFISCAL:oSFI_MODELO:cMsg    :="Modelo"
    oSERIEFISCAL:oSFI_MODELO:cToolTip:="Modelo"

  @ oSERIEFISCAL:oSFI_MODELO:nTop-08,oSERIEFISCAL:oSFI_MODELO:nLeft SAY "Modelo" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SFI_LETRA 
  // Uso   : Letra                                   
  //
  @ 2.8, 1.0 GET oSERIEFISCAL:oSFI_LETRA   VAR oSERIEFISCAL:SFI_LETRA;
                   VALID  (!VACIO(oSERIEFISCAL:SFI_LETRA,NIL) .AND. oSERIEFISCAL:ValUnique( oSERIEFISCAL:SFI_LETRA , "SFI_LETRA"));
                   WHEN (AccessField("DPSERIEFISCAL","SFI_LETRA",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                    FONT oFontG;
                    SIZE 4,10

    oSERIEFISCAL:oSFI_LETRA :cMsg    :="Letra"
    oSERIEFISCAL:oSFI_LETRA :cToolTip:="Letra"

  @ oSERIEFISCAL:oSFI_LETRA :nTop-08,oSERIEFISCAL:oSFI_LETRA :nLeft SAY "Letra" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SFI_NUMERO
  // Uso   : Número                                  
  //
  @ 4.6, 1.0 GET oSERIEFISCAL:oSFI_NUMERO  VAR oSERIEFISCAL:SFI_NUMERO  VALID CERO(oSERIEFISCAL:SFI_NUMERO);
                    WHEN (AccessField("DPSERIEFISCAL","SFI_NUMERO",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                    FONT oFontG;
                    SIZE 40,10

    oSERIEFISCAL:oSFI_NUMERO:cMsg    :="Número"
    oSERIEFISCAL:oSFI_NUMERO:cToolTip:="Número"

  @ oSERIEFISCAL:oSFI_NUMERO:nTop-08,oSERIEFISCAL:oSFI_NUMERO:nLeft SAY "Número" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  //
  // Campo : SFI_TICKET
  // Uso   : Ticket                                  
  //
  @ 6.4, 1.0 CHECKBOX oSERIEFISCAL:oSFI_TICKET  VAR oSERIEFISCAL:SFI_TICKET  PROMPT ANSITOOEM("Ticket");
                    WHEN (AccessField("DPSERIEFISCAL","SFI_TICKET",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10

    oSERIEFISCAL:oSFI_TICKET:cMsg    :="Ticket"
    oSERIEFISCAL:oSFI_TICKET:cToolTip:="Ticket"


  //
  // Campo : SFI_ITEMXP
  // Uso   : Items por Página                        
  //
  @ 8.2, 1.0 GET oSERIEFISCAL:oSFI_ITEMXP  VAR oSERIEFISCAL:SFI_ITEMXP  PICTURE "999";
                    WHEN oSERIEFISCAL:SFI_TICKET .AND. (AccessField("DPSERIEFISCAL","SFI_ITEMXP",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10;
                    RIGHT


    oSERIEFISCAL:oSFI_ITEMXP:cMsg    :="Items por Página"
    oSERIEFISCAL:oSFI_ITEMXP:cToolTip:="Items por Página"

  @ oSERIEFISCAL:oSFI_ITEMXP:nTop-08,oSERIEFISCAL:oSFI_ITEMXP:nLeft SAY "Items por Página" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SFI_TEXTO 
  // Uso   : Incluye Textos                          
  //
  @ 10.0, 1.0 CHECKBOX oSERIEFISCAL:oSFI_TEXTO   VAR oSERIEFISCAL:SFI_TEXTO   PROMPT ANSITOOEM("Incluye Textos");
                    WHEN oSERIEFISCAL:SFI_TICKET .AND. (AccessField("DPSERIEFISCAL","SFI_TEXTO",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oSERIEFISCAL:oSFI_TEXTO :cMsg    :="Incluye Textos"
    oSERIEFISCAL:oSFI_TEXTO :cToolTip:="Incluye Textos"


  //
  // Campo : SFI_AUTOMA
  // Uso   : Automático                              
  //
  @ 1.0,15.0 CHECKBOX oSERIEFISCAL:oSFI_AUTOMA  VAR oSERIEFISCAL:SFI_AUTOMA  PROMPT ANSITOOEM("Automático");
                      WHEN oSERIEFISCAL:SFI_TICKET .AND. (AccessField("DPSERIEFISCAL","SFI_AUTOMA",oSERIEFISCAL:nOption);
                           .AND. oSERIEFISCAL:nOption!=0);
                           FONT oFont COLOR nClrText,NIL SIZE 100,10;
                           SIZE 4,10

    oSERIEFISCAL:oSFI_AUTOMA:cMsg    :="Automático"
    oSERIEFISCAL:oSFI_AUTOMA:cToolTip:="Automático"


  //
  // Campo : SFI_EDITAB
  // Uso   : Editable                                
  //
  @ 2.8,15.0 CHECKBOX oSERIEFISCAL:oSFI_EDITAB  VAR oSERIEFISCAL:SFI_EDITAB  PROMPT ANSITOOEM("Editable");
                    WHEN oSERIEFISCAL:SFI_TICKET .AND. (AccessField("DPSERIEFISCAL","SFI_EDITAB",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 88,10;
                    SIZE 4,10

    oSERIEFISCAL:oSFI_EDITAB:cMsg    :="Editable"
    oSERIEFISCAL:oSFI_EDITAB:cToolTip:="Editable"

  //
  // Campo : SFI_SELECT
  // Uso   : Editable                                
  //
  @ 2.8,15.0 CHECKBOX oSERIEFISCAL:oSFI_SELECT  VAR oSERIEFISCAL:SFI_SELECT  PROMPT ANSITOOEM("Selectiva");
                       WHEN oSERIEFISCAL:SFI_TICKET .AND. (AccessField("DPSERIEFISCAL","SFI_SELECT",oSERIEFISCAL:nOption);
                      .AND. oSERIEFISCAL:nOption!=0);
                      FONT oFont COLOR nClrText,NIL SIZE 88,10;
                     SIZE 4,10

  oSERIEFISCAL:oSFI_SELECT:cMsg    :="Selectivo por el Usuario"
  oSERIEFISCAL:oSFI_SELECT:cToolTip:="Selectivo por el Usuario"

  oSERIEFISCAL:SFI_MEMO:=IF(ValType(oSERIEFISCAL:SFI_MEMO)<>"C","",oSERIEFISCAL:SFI_MEMO)
  oSERIEFISCAL:SFI_MEMO:=ALLTRIM(oSERIEFISCAL:SFI_MEMO) 


 


  //
  // Campo : SFI_MEMO  
  // Uso   : Comentarios                             
  //
  @ 4.6,15.0 GET oSERIEFISCAL:oSFI_MEMO    VAR oSERIEFISCAL:SFI_MEMO  ;
           MEMO SIZE 80,80; 
           ON CHANGE 1=1;
                    WHEN (AccessField("DPSERIEFISCAL","SFI_MEMO",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                    FONT oFontG;
                    SIZE 40,10

    oSERIEFISCAL:oSFI_MEMO  :cMsg    :="Comentarios"
    oSERIEFISCAL:oSFI_MEMO  :cToolTip:="Comentarios"

  @ oSERIEFISCAL:oSFI_MEMO  :nTop-08,oSERIEFISCAL:oSFI_MEMO  :nLeft SAY "Comentarios para la Impresión" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  @ 10,1 SAY "Impresora Fiscal/Digital" ;
         SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SFI_IMPFIS
  // Uso   : Impresora Fiscal
  //

  @ 11, 1.0 COMBOBOX oSERIEFISCAL:oSFI_IMPFIS VAR oSERIEFISCAL:SFI_IMPFIS ITEMS aItems1;
                     WHEN LEN(oSERIEFISCAL:oSFI_IMPFIS:aItems)>1 .AND.;
                             (AccessField("DPSERIEFISCAL","SFI_IMPFIS",oSERIEFISCAL:nOption);
                              .AND. oSERIEFISCAL:nOption!=0);
                     FONT oFontG;
                     ON CHANGE oSERIEFISCAL:GETIMPFISCAL()

  ComboIni(oSERIEFISCAL:oSFI_SERFIS)

  //
  // Campo : SFI_ACTIVO
  // Uso   : ACTIVO                                  
  //
  @ 1, 10 CHECKBOX oSERIEFISCAL:oSFI_ACTIVO  VAR oSERIEFISCAL:SFI_ACTIVO  PROMPT ANSITOOEM("Activo");
                   WHEN (AccessField("DPSERIEFISCAL","SFI_ACTIVO",oSERIEFISCAL:nOption);
                         .AND. oSERIEFISCAL:nOption!=0);
                         FONT oFont COLOR nClrText,NIL SIZE 76,10;
                        SIZE 4,10 ON CHANGE (oSERIEFISCAL:oSFI_PCNAME:ForWhen(.T.),;
                                             oSERIEFISCAL:oSFI_SERIMP:ForWhen(.T.))

   oSERIEFISCAL:oSFI_ACTIVO:cMsg    :="Activo"
   oSERIEFISCAL:oSFI_ACTIVO:cToolTip:="Activo"

  // Campo : SFI_PCNAME    
  // Uso   : Nombre del PC, donde sera utilizada la forma fiscal, solo en caso de impresora fiscal
  //

// (oDpLbx:=DpLbx("DPVENDEDOR",NIL,"LEFT(VEN_SITUAC,1)='A'",NIL,NIL,NIL,NIL,NIL,NIL,oDocCli:oDOC_CODVEN,oDocCli:oWnd)

  @ 7, 1.0 BMPGET oSERIEFISCAL:oSFI_PCNAME      VAR oSERIEFISCAL:SFI_PCNAME     ;
                  VALID oSERIEFISCAL:oDPPCLOG:SeekTable("PC_NOMBRE",oSERIEFISCAL:oSFI_PCNAME,NIL,oSERIEFISCAL:oPC_NOMBRE);
                  NAME "BITMAPS\FIND.BMP"; 
                  ACTION (oDpLbx:=DpLbx("DPPCLOG",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oSERIEFISCAL:oSFI_PCNAME),;
                          oDpLbx:GetValue("PC_NOMBRE",oSERIEFISCAL:oSFI_PCNAME)); 
                  WHEN (AccessField("DPSERIEFISCAL","SFI_PCNAME",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                  FONT oFontG;
                  SIZE 40,10
//
// Caso de Punto de Venta, Requiere la asignación del PC
//WHEN (AccessField("DPSERIEFISCAL","SFI_PCNAME",oSERIEFISCAL:nOption);
//                    .AND. oSERIEFISCAL:nOption!=0 .AND. !"Ningu"$oSERIEFISCAL:SFI_IMPFIS);


  oSERIEFISCAL:oSFI_PCNAME:cMsg    :="Nombre del PC donde sera utilizada la forma fiscal"
  oSERIEFISCAL:oSFI_PCNAME:cToolTip:="Nombre del PC donde sera utilizada la forma fiscal"

  @ oSERIEFISCAL:oSFI_PCNAME:nTop-08,oSERIEFISCAL:oSFI_PCNAME:nLeft SAY GetFromVar("{oDp:xDPPCLOG}")+" Asignado" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  //
  // Campo : SFI_SERIMP
  // Uso   : Serial Impresora                             
  //
  @ 14, 1.0 GET oSERIEFISCAL:oSFI_SERIMP  VAR oSERIEFISCAL:SFI_SERIMP;
            VALID oSERIEFISCAL:VALSFISERIMP(oSERIEFISCAL:SFI_SERIMP);
                 .AND. !VACIO(oSERIEFISCAL:SFI_SERIMP,NIL);
                    WHEN (AccessField("DPSERIEFISCAL","SFI_SERIMP",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0 .AND. !"Ningu"$oSERIEFISCAL:SFI_IMPFIS);
                    FONT oFontG;
                    SIZE 120,10

    oSERIEFISCAL:oSFI_SERIMP:cMsg    :="Serial de la Impresora"
    oSERIEFISCAL:oSFI_SERIMP:cToolTip:="Serial de la Impresora"

  @ oSERIEFISCAL:oSFI_SERIMP:nTop-08,oSERIEFISCAL:oSFI_SERIMP:nLeft SAY "Serial Impresora" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  @ 0,0 SAY oSERIEFISCAL:oPC_NOMBRE PROMPT ""



  //
  // Campo : SFI_CUENTA
  // Uso   : Cuenta Contable                         
  //
  @ 6.0, 0.0 BMPGET oSERIEFISCAL:oSFI_CUENTA  VAR oSERIEFISCAL:SFI_CUENTA;
             VALID oSERIEFISCAL:oDPCTA:SeekTable("CTA_CODIGO",oSERIEFISCAL:oSFI_CUENTA,NIL,oSERIEFISCAL:oCTA_DESCRI);
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oDpLbx:=DpLbx("DPCTAACT"), oDpLbx:GetValue("CTA_CODIGO",oSERIEFISCAL:oSFI_CUENTA)); 
             WHEN (AccessField("DPSERIEFISCAL","SFI_CUENTA",oSERIEFISCAL:nOption);
                  .AND. oSERIEFISCAL:nOption!=0);
             FONT oFontG;
             SIZE 80,10

  oSERIEFISCAL:oSFI_CUENTA:cMsg    :="Cuenta Contable"
  oSERIEFISCAL:oSFI_CUENTA:cToolTip:="Cuenta Contable"


  @ 0,0 SAY GETFROMVAR("{oDp:xDPCTA}")

  @ 0,0 SAY oSERIEFISCAL:oCTA_DESCRI;
        PROMPT oSERIEFISCAL:oDPCTA:CTA_DESCRI PIXEL;
        SIZE NIL,12 FONT oFont COLOR 16777215,16711680 

 
  @ 2,1 GROUP oBtn TO 4, 21.5 PROMPT " TheFactory "

  @ 2,1 GROUP oBtn TO 4, 21.5 PROMPT " Impresora Fiscal "


  @ 0,0 SAY "Puerto"+CRLF+"Serial"

  //
  // Campo : SFI_PUERTO
  // Uso   : Puerto Serial                           
  //

  @ 11, 1.0 COMBOBOX oSERIEFISCAL:oSFI_PUERTO VAR oSERIEFISCAL:SFI_PUERTO ITEMS aItems2;
                     WHEN oSERIEFISCAL:lImpFis .AND. LEN(oSERIEFISCAL:oSFI_PUERTO:aItems)>1 .AND.;
                             (AccessField("DPSERIEFISCAL","SFI_IMPFIS",oSERIEFISCAL:nOption);
                              .AND. oSERIEFISCAL:nOption!=0);
                     FONT oFontG

  ComboIni(oSERIEFISCAL:oSFI_PUERTO)

  //
  // Campo : SFI_AUTDET 
  // Uso   : Incluye Textos                          
  //
  @ 10.0, 1.0 CHECKBOX oSERIEFISCAL:oSFI_AUTDET   VAR oSERIEFISCAL:SFI_AUTDET   PROMPT ANSITOOEM("Auto-Detectar COM");
                    WHEN oSERIEFISCAL:lImpFis .AND. (AccessField("DPSERIEFISCAL","SFI_AUTDET",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10 ON CHANGE oSERIEFISCAL:SETPUERTO()

  oSERIEFISCAL:oSFI_AUTDET :cMsg    :="Auto-Detectar Puerto"
  oSERIEFISCAL:oSFI_AUTDET :cToolTip:="Auto-Detectar Puerto"


// Campo : SFI_MODVAL 
  // Uso   : Modo de Evaluación para Impresora Fiscal                       
  //
  @ 10.0, 1.0 CHECKBOX oSERIEFISCAL:oSFI_MODVAL   VAR oSERIEFISCAL:SFI_MODVAL   PROMPT ANSITOOEM("Modo Validación");
                    WHEN oSERIEFISCAL:lImpFis .AND. (AccessField("DPSERIEFISCAL","SFI_MODVAL",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10 ON CHANGE .T.

  oSERIEFISCAL:oSFI_MODVAL :cMsg    :="Modo de Evaluación para Impresora Fiscal"
  oSERIEFISCAL:oSFI_MODVAL :cToolTip:="Modo de Evaluación para Impresora Fiscal"


  //
  // Campo : SFI_REGAUD 
  // Uso   : Guardar Registro de Auditoria                      
  //
  @ 10.0, 10 CHECKBOX oSERIEFISCAL:oSFI_REGAUD   VAR oSERIEFISCAL:SFI_REGAUD   PROMPT ANSITOOEM("Grabar Auditoría");
                    WHEN oSERIEFISCAL:lImpFis .AND. (AccessField("DPSERIEFISCAL","SFI_REGAUD",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10 ON CHANGE .T.

  oSERIEFISCAL:oSFI_REGAUD :cMsg    :=[Guardar registro de Auditoria del Archivo LOG (TRAZA) de impresión]
  oSERIEFISCAL:oSFI_REGAUD :cToolTip:=oSERIEFISCAL:oSFI_REGAUD :cMsg
 

  //
  // Campo : SFI_ANCHO
  // Uso   : Ancho Impresora
  //
  @ 10, 21 GET oSERIEFISCAL:oSFI_ANCHO  VAR oSERIEFISCAL:SFI_ANCHO PICTURE "99" SPINNER ;
            VALID oSERIEFISCAL:VALSFISERIMP(oSERIEFISCAL:SFI_ANCHO);
                 .AND. !VACIO(oSERIEFISCAL:SFI_ANCHO,NIL);
                    WHEN (AccessField("DPSERIEFISCAL","SFI_ANCHO",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0 .AND. !"Ningu"$oSERIEFISCAL:SFI_IMPFIS);
                    FONT oFontG;
                    SIZE 15,10 RIGHT

    oSERIEFISCAL:oSFI_ANCHO:cMsg    :="Ancho Impresora"
    oSERIEFISCAL:oSFI_ANCHO:cToolTip:="Ancho Impresora"

  @ oSERIEFISCAL:oSFI_ANCHO:nTop-08,oSERIEFISCAL:oSFI_ANCHO:nLeft SAY "Columnas" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


 //
  // Campo : SFI_PREENT
  // Uso   : Ancho Precio
  //
  @ 10, 21 GET oSERIEFISCAL:oSFI_PREENT  VAR oSERIEFISCAL:SFI_PREENT PICTURE "99" SPINNER ;
            VALID oSERIEFISCAL:VALSFISERIMP(oSERIEFISCAL:SFI_PREENT);
                 .AND. !VACIO(oSERIEFISCAL:SFI_PREENT,NIL);
                    WHEN (AccessField("DPSERIEFISCAL","SFI_PREENT",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0 .AND. !"Ningu"$oSERIEFISCAL:SFI_IMPFIS);
                    FONT oFontG;
                    SIZE 15,10 RIGHT

    oSERIEFISCAL:oSFI_PREENT:cMsg    :="Ancho Precio"
    oSERIEFISCAL:oSFI_PREENT:cToolTip:="Ancho Precio"

  @ oSERIEFISCAL:oSFI_PREENT:nTop-08,oSERIEFISCAL:oSFI_PREENT:nLeft SAY "Ancho"+CRLF+"Precio" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  //
  // Campo : SFI_PREDEC
  // Uso   : Decimales
  //
  @ 10, 21 GET oSERIEFISCAL:oSFI_PREDEC  VAR oSERIEFISCAL:SFI_PREDEC PICTURE "99" SPINNER ;
            VALID oSERIEFISCAL:VALSFISERIMP(oSERIEFISCAL:SFI_PREDEC);
                 .AND. !VACIO(oSERIEFISCAL:SFI_PREDEC,NIL);
                    WHEN (AccessField("DPSERIEFISCAL","SFI_PREDEC",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0 .AND. !"Ningu"$oSERIEFISCAL:SFI_IMPFIS);
                    FONT oFontG;
                    SIZE 15,10 RIGHT

    oSERIEFISCAL:oSFI_PREDEC:cMsg    :="Decimales en Precio"
    oSERIEFISCAL:oSFI_PREDEC:cToolTip:="Decimales en Precio"

  @ oSERIEFISCAL:oSFI_PREDEC:nTop-08,oSERIEFISCAL:oSFI_PREDEC:nLeft SAY "Dec."+CRLF+"Precio" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  //
  // Campo : SFI_CANENT
  // Uso   : Ancho Cantidad
  //
  @ 05, 31 GET oSERIEFISCAL:oSFI_CANENT  VAR oSERIEFISCAL:SFI_CANENT PICTURE "99" SPINNER ;
            VALID oSERIEFISCAL:VALSFISERIMP(oSERIEFISCAL:SFI_CANENT);
                 .AND. !VACIO(oSERIEFISCAL:SFI_CANENT,NIL);
                    WHEN (AccessField("DPSERIEFISCAL","SFI_CANENT",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0 .AND. !"Ningu"$oSERIEFISCAL:SFI_IMPFIS);
                    FONT oFontG;
                    SIZE 15,10 RIGHT

    oSERIEFISCAL:oSFI_CANENT:cMsg    :="Ancho Cantidad"
    oSERIEFISCAL:oSFI_CANENT:cToolTip:="Ancho Cantidad"

  @ oSERIEFISCAL:oSFI_CANENT:nTop-08,oSERIEFISCAL:oSFI_CANENT:nLeft SAY "Ancho"+CRLF+"Cantidad" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  //
  // Campo : SFI_CANDEC
  // Uso   : Decimales
  //
  @ 06, 31 GET oSERIEFISCAL:oSFI_CANDEC  VAR oSERIEFISCAL:SFI_CANDEC PICTURE "99" SPINNER ;
            VALID oSERIEFISCAL:VALSFISERIMP(oSERIEFISCAL:SFI_CANDEC);
                 .AND. !VACIO(oSERIEFISCAL:SFI_CANDEC,NIL);
                    WHEN (AccessField("DPSERIEFISCAL","SFI_CANDEC",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0 .AND. !"Ningu"$oSERIEFISCAL:SFI_IMPFIS);
                    FONT oFontG;
                    SIZE 15,10 RIGHT

    oSERIEFISCAL:oSFI_CANDEC:cMsg    :="Decimales en Cantidad"
    oSERIEFISCAL:oSFI_CANDEC:cToolTip:="Decimales en Cantidad"


  @ oSERIEFISCAL:oSFI_CANDEC:nTop-08,oSERIEFISCAL:oSFI_CANDEC:nLeft SAY "Dec."+CRLF+"Cantidad" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : SFI_FCHMAN
  // Uso   : Fecha de Mantenimiento
  //
  @ 06, 31 BMPGET oSERIEFISCAL:oSFI_FCHMAN;
                  VAR oSERIEFISCAL:SFI_FCHMAN;
                  PICTURE "99/99/9999";
                  NAME "BITMAPS\Calendar.bmp";
                  WHEN (AccessField("DPSERIEFISCAL","SFI_FCHMAN",oSERIEFISCAL:nOption);
                        .AND. oSERIEFISCAL:nOption!=0 .AND. !"Ningu"$oSERIEFISCAL:SFI_IMPFIS);
                  FONT oFontG;
                  ACTION LbxDate(oSERIEFISCAL:oSFI_FCHMAN,oSERIEFISCAL:SFI_FCHMAN);
                  SIZE 15,10 

    oSERIEFISCAL:oSFI_FCHMAN:cMsg    :="Fecha de Mantenimiento"
    oSERIEFISCAL:oSFI_FCHMAN:cToolTip:="Fecha de Mantenimiento"

  @ oSERIEFISCAL:oSFI_FCHMAN:nTop-08,oSERIEFISCAL:oSFI_FCHMAN:nLeft SAY "Fecha"+CRLF+"Mant." PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


 //
  // Campo : SFI_MAXZET
  // Uso   : Maximo ZETA
  //
  @ 10, 21 GET oSERIEFISCAL:oSFI_MAXZET  VAR oSERIEFISCAL:SFI_MAXZET PICTURE "9999" SPINNER ;
            VALID oSERIEFISCAL:VALSFISERIMP(oSERIEFISCAL:SFI_MAXZET);
                 .AND. !VACIO(oSERIEFISCAL:SFI_MAXZET,NIL);
                    WHEN (AccessField("DPSERIEFISCAL","SFI_MAXZET",oSERIEFISCAL:nOption);
                    .AND. oSERIEFISCAL:nOption!=0 .AND. !"Ningu"$oSERIEFISCAL:SFI_IMPFIS);
                    FONT oFontG;
                    SIZE 15,10 RIGHT

    oSERIEFISCAL:oSFI_MAXZET:cMsg    :="Cantidad de Registros Zeta"
    oSERIEFISCAL:oSFI_MAXZET:cToolTip:="Cantidad de Registros Zeta"

  @ oSERIEFISCAL:oSFI_MAXZET:nTop-08,oSERIEFISCAL:oSFI_MAXZET:nLeft SAY "Cant."+CRLF+"Zeta" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris




  //
  // Campo : SFI_PAGADO
  // Uso   : Automático                              
  //
  @ 1.0,15.0 CHECKBOX oSERIEFISCAL:oSFI_PAGADO  VAR oSERIEFISCAL:SFI_PAGADO  PROMPT ANSITOOEM("Imprimir Pagada");
                      WHEN (AccessField("DPSERIEFISCAL","SFI_PAGADO",oSERIEFISCAL:nOption);
                           .AND. oSERIEFISCAL:nOption!=0);
                           FONT oFont COLOR nClrText,NIL SIZE 100,10;
                           SIZE 4,10

   oSERIEFISCAL:oSFI_PAGADO:cMsg    :="Imprimir si está Pagada"
   oSERIEFISCAL:oSFI_PAGADO:cToolTip:="Imprimir si está Pagada"



 //
  // Campo : SFI_CODSUC
  // Uso   : Cuenta Contable                         
  //
  @ 6.0, 0.0 BMPGET oSERIEFISCAL:oSFI_CODSUC  VAR oSERIEFISCAL:SFI_CODSUC;
             VALID oSERIEFISCAL:oDPSUCURSAL:SeekTable("SUC_CODIGO",oSERIEFISCAL:oSFI_CODSUC,NIL,oSERIEFISCAL:oSUC_DESCRI);
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oDpLbx:=DpLbx("DPSUCURSAL"), oDpLbx:GetValue("SUC_CODIGO",oSERIEFISCAL:oSFI_CODSUC)); 
             WHEN (AccessField("DPSERIEFISCAL","SFI_CODSUC",oSERIEFISCAL:nOption);
                  .AND. oSERIEFISCAL:nOption!=0);
             FONT oFontG;
             SIZE 80,10

  oSERIEFISCAL:oSFI_CODSUC:cMsg    :="Código de Sucursal"
  oSERIEFISCAL:oSFI_CODSUC:cToolTip:="Código de Sucursal"


  @ 10,0 SAY GETFROMVAR("{oDp:xDPSUCURSAL}")

  @ 11,0 SAY oSERIEFISCAL:oSUC_DESCRI;
         PROMPT oSERIEFISCAL:oDPSUCURSAL:SUC_DESCRI PIXEL;
         SIZE NIL,12 FONT oFont COLOR 16777215,16711680 



  oSERIEFISCAL:Activate({||oSERIEFISCAL:SERINICIO()})

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oSERIEFISCAL

FUNCTION SERINICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oSERIEFISCAL:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52,60 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   IF oSERIEFISCAL:nOption<>2

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP";
            TOP PROMPT "Grabar";
            ACTION oSERIEFISCAL:Save()

     oBtn:cToolTip:="Grabar Registro"
     oBtn:cMsg    :=oBtn:cToolTip

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Ejecutar";
            FILENAME "BITMAPS\RUN.BMP";
            ACTION EJECUTAR("MODE",.T.)

     oBtn:cToolTip:="Ejecutar comando MODE.EXE"
     oBtn:cMsg    :=oBtn:cToolTip


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XCANCEL.BMP";
            TOP PROMPT "Cancela";
            ACTION oSERIEFISCAL:Cancel()

     oBtn:lCancel:=.T.
     oBtn:cToolTip:="Cerrar Formulario"
     oBtn:cMsg    :=oBtn:cToolTip

   ELSE


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar";
            ACTION oSERIEFISCAL:Close()

   ENDIF


  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oSERIEFISCAL:oBar:=oBar

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

  oSERIEFISCAL:GETIMPFISCAL()

//  oSERIEFISCAL:oScroll:oBrw:SetColor(NIL,14612478)

RETURN NIL
/*
// Valida que no se Repita el numero de la Impresora Fiscal
*/
FUNCTION VALSFISERIMP()
   LOCAL cWhere :="SFI_MODELO"+GetWhere("<>",oSERIEFISCAL:SFI_MODELO)+" AND SFI_SERIMP"+GetWhere("=",oSERIEFISCAL:SFI_SERIMP)
   LOCAL cSerial:=SQLGET("DPSERIEFISCAL","SFI_SERIMP,SFI_MODELO,SFI_ACTIVO",cWhere)
   LOCAL lActivo:=DPSQLROW(3,.F.)
   LOCAL cModelo:=DPSQLROW(2)

//? cSerial,cModelo,CLPCOPY(oDp:cSql)

   IF Empty(oSERIEFISCAL:SFI_SERIMP)
      oSERIEFISCAL:oSFI_SERIMP:MsgErr("Serial no puede estar Vacio","Serial de la Impresora")
      RETURN .F.
   ENDIF

   IF !Empty(cSerial) .AND. lActivo
      oSERIEFISCAL:oSFI_SERIMP:MsgErr("Serial esta registrado en Registro "+cModelo,"Serial de la Impresora, está Activo")
   ENDIF

   // Permite copiar en una nueva Caja Registradoa/Impresora Fiscal el Serial de Otra impresora (Inactiva)
   IF !lActivo
      cSerial:=""
   ENDIF

  
RETURN Empty(cSerial)

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oSERIEFISCAL:nOption=1 // Incluir en caso de ser Incremental
     
     oSERIEFISCAL:SFI_LETRA:=SQLINCREMENTAL("DPSERIEFISCAL","SFI_LETRA")
     // AutoIncremental 
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

  lResp:=oSERIEFISCAL:ValUnique(oSERIEFISCAL:SFI_MODELO)

  IF !lResp
        MsgAlert("Registro "+CTOO(oSERIEFISCAL:SFI_MODELO),"Ya Existe")
  ENDIF

  IF !"DIGI"$oSERIEFISCAL:SFI_IMPFIS

    IF EMPTY(oSERIEFISCAL:SFI_MODELO)
       MensajeErr("Modelo no Puede estar Vacio")
       RETURN .F.
    ENDIF

    IF Empty(oSERIEFISCAL:SFI_SERIMP) .AND. EVAL(oSERIEFISCAL:oSFI_SERIMP:bWhen)
      oSERIEFISCAL:oSFI_SERIMP:MsgErr("Serial no puede estar Vacio","Serial de la Impresora")
      RETURN .F.
    ENDIF

    IF Empty(oSERIEFISCAL:SFI_CODSUC)
      oSERIEFISCAL:SFI_CODSUC:=oDp:cSucursal
    ENDIF
 
    IF ("Ningu"$oSERIEFISCAL:SFI_IMPFIS)
      oSERIEFISCAL:SFI_PUERTO:="Ning"
    ELSE
      oSERIEFISCAL:SFI_PUERTO:=LEFT(oSERIEFISCAL:SFI_PUERTO,4)
    ENDIF

  ENDIF

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()

  IF oSERIEFISCAL:SFI_MODELO<>oSERIEFISCAL:cModelo
     SQLUPDATE("DPDOCCLI","DOC_MODFIS",oSERIEFISCAL:SFI_MODELO,"DOC_MODFIS"+GetWhere("=",oSERIEFISCAL:cModelo))
  ENDIF

  IF oSERIEFISCAL:SFI_LETRA<>oSERIEFISCAL:cLetra .AND. oSERIEFISCAL:nOption=3
     SQLUPDATE("DPDOCCLI","DOC_MODFIS",oSERIEFISCAL:SFI_LETRA,"DOC_SERFIS"+GetWhere("=",oSERIEFISCAL:cLetra))
  ENDIF

  EJECUTAR("SETCTAINTMOD","DPSERIEFISCAL",oSERIEFISCAL:SFI_LETRA,NIL,"CUENTA",oSERIEFISCAL:SFI_CUENTA,.T.)

  EJECUTAR("DPSERIEFISCALLOAD",NIL,.F.)

  EJECUTAR("CREADPEQUIPOSPOS")

  IF "DIGI"$oSERIEFISCAL:SFI_IMPFIS
     EJECUTAR("DPSERIEFISCALMNU",oSERIEFISCAL:SFI_MODELO)
  ENDIF

  EVAL(oSERIEFISCAL:bPostRun) 

RETURN .T.

FUNCTION GETIMPFISCAL()

  oSERIEFISCAL:lImpFis:=.T.

  IF "Ning"$oSERIEFISCAL:SFI_IMPFIS .OR. "Caja"$oSERIEFISCAL:SFI_IMPFIS
    oSERIEFISCAL:lImpFis:=.F.
  ENDIF

//  ? oSERIEFISCAL:SFI_IMPFIS,"oSERIEFISCAL:SFI_IMPFIS",oSERIEFISCAL:lImpFis,"oSERIEFISCAL:lImpFis"

  oSERIEFISCAL:oSFI_AUTDET:ForWhen(.T.)
  oSERIEFISCAL:oSFI_PUERTO:ForWhen(.T.)

RETURN .T.

FUNCTION SETPUERTO()
  LOCAL cPuerto:=oSERIEFISCAL:SFI_PUERTO

  IF oSERIEFISCAL:SFI_AUTDET
    oSERIEFISCAL:oSFI_PUERTO:SetItems(oSERIEFISCAL:aCom)
  ELSE
    oSERIEFISCAL:oSFI_PUERTO:SetItems(oSERIEFISCAL:aItems2)
  ENDIF
 
  oSERIEFISCAL:oSFI_PUERTO:VarPut(oSERIEFISCAL:oSFI_PUERTO:aItems[1])

  ComboIni(oSERIEFISCAL:oSFI_SERFIS)

  oSERIEFISCAL:oSFI_SERFIS:Refresh(.T.)
/*
  cPuerto:=EVAL(oSERIEFISCAL:oSFI_PUERTO:bSetGet)

?  oSERIEFISCAL:SFI_PUERTO,cPuerto

  IF Empty(cPuerto)
     cPuerto:=oSERIEFISCAL:oSFI_PUERTO:aItems[1]
     oSERIEFISCAL:oSFI_PUERTO:VarPut(cPuerto)
     ComboIni(oSERIEFISCAL:oSFI_SERFIS)
  ENDIF

  oSERIEFISCAL:oSFI_SERFIS:Refresh(.T.)

*/
//  ? "SETPUERTO()"
RETURN .T.

/*
<LISTA:SFI_MODELO:Y:GET:N:N:N:Modelo,SFI_LETRA:N:GET:N:N:N:Letra,SFI_NUMERO:N:GET:N:N:Y:Número,SFI_TICKET:N:CHECKBOX:N:N:Y:Ticket
,SFI_ITEMXP:N:GET:N:N:Y:Items por Página,SFI_TEXTO:N:CHECKBOX:N:N:Y:Incluye Textos,SFI_AUTOMA:N:CHECKBOX:N:N:Y:Automático,SFI_EDITAB:N:CHECKBOX:N:N:Y:Editable
,SFI_MEMO:N:GET:N:N:Y:Comentarios>
*/

// Programa   : DPPOSCOMANDAOLD
// Fecha/Hora : 20/05/2006 08:44:54
// Propósito  : Incluir/Modificar DPPOSCOMANDA
// Creado Por : DpXbase
// Llamado por: DPPOSCOMANDA.LBX
// Aplicación : Ventas y Cuentas Por Cobrar             
// Tabla      : DPPOSCOMANDA

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION MAIN(lDely,cPedido)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG,oScript
  LOCAL cTitle,cSql,cFile,cExcluye:="",cMesa:="",cMesero:="",cWhere:="",cZona:=""
  LOCAL nClrText
  LOCAL cTitle:="Comandas del Punto de Venta",cMesa:="  1"
  LOCAL oCol,aData:={},oFont,oFontB,I,oData
  LOCAL oCliZero,aCliZero:={},aZona:={},aTarifa:={},aDataPed:={},aMuni:={},aParro:={}
  LOCAL aDataZona:={}

  cExcluye:="COM_CODIGO,;
             COM_MESERO,;
             COM_MESA,;
             COM_CANTID"

  DEFAULT lDely:=.T.

  IF !EJECUTAR("DPPOSSERV")
     RETURN .F.
  ENDIF

  IF lDely

    // aMuni:=ASQL("SELECT MUNICIPIO FROM DPMUNICIPIOS WHERE MUNICIPIO<>'' ORDER BY PARROQUIA ")
    // AEVAL(aZona,{|a,n|AADD(aTarifa,a[2]),aZona[n]:=a[1]})
  
     aZona    :=ASQL("SELECT PARROQUIA,TARIFA,MUNICIPIO FROM DPPARROQUIAS WHERE PARROQUIA<>'' ORDER BY PARROQUIA ")
     aDataZona:=ACLONE(aZona)

     AEVAL(aZona,{|a,n| AADD(aTarifa,a[2]) , aZona[n]:=a[1] , IIF( ASCAN(aMuni,a[3] ) =0 , AADD( aMuni , a[3] ), NIL) })

     cWhere:=" COM_LLEVAR=1 AND COM_TIPO='P' "+;
              IIF(Empty(cPedido)," AND 1=0 ","")+;
              IIF(Empty(cPedido),""," AND COM_PEDIDO"+GetWhere("=",cPedido))

  ELSE

     cWhere:=" COM_LLEVAR=0 AND COM_TIPO='P' "

  ENDIF

  IF Empty(oDp:cModeVideo)

     DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD
     DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD 
     DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  ELSE

     DEFINE FONT oFont  NAME "Verdana" SIZE 0, -12 BOLD
     DEFINE FONT oFontB NAME "Arial"   SIZE 0, -14 BOLD 
     DEFINE FONT oFontG NAME "Arial"   SIZE 0, -13

  ENDIF

  aData:=ASQL(" SELECT COM_CODIGO,COM_DESCRI,COM_MESA,COM_MESERO,"+;
              " VEN_NOMBRE,COM_CANTID,COM_ITEM,COM_UNDMED,COM_PRECIO FROM "+;
              " DPPOSCOMANDA "+;
              " INNER JOIN DPINV      ON COM_CODIGO=INV_CODIGO "+;
              " INNER JOIN DPVENDEDOR ON COM_MESERO=VEN_CODIGO "+;
              " WHERE "+cWhere )

  IF !Empty(aData)
     cMesa  :=ATAIL(aData)[3] // [1,3]
     cMesero:=ATAIL(aData)[4] // aData[1,4]
  ENDIF

  IF Empty(cMesero)
     cMesero:=MYSQLGET("DPVENDEDOR","VEN_CODIGO","1=1 LIMIT 1")
  ENDIF

  nClrText:=10485760 // Color del texto

  cSql     :=[SELECT * FROM DPPOSCOMANDA WHERE COM_CODIGO]+GetWhere("=",cCodigo)
  cTitle   :=" Incluir {oDp:DPPOSCOMANDA}"
  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPPOSCOMANDA]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="COM_ITEM" // Clave de Validación de Registro

  IF lDely
    cTitle:=cTitle+" [Delivery] " 
  ENDIF

  oPOSCOMANDA:=DPEDIT():New(cTitle,"DPPOSCOMANDA"+IIF(lDely,"D","")+oDp:cModeVideo+".edt","oPOSCOMANDA" , .F. )

  oData:=DATASET("POSREST","USER",,,oDp:cUsuario)

  oPOSCOMANDA:lMESASUS  :=oData:Get("LMESASUS"   , .T. )
  oPOSCOMANDA:lPEDIDOSUS:=oData:Get("LPEDIDOSUS" , .T. )
  oData:End(.F.)

// ? oPOSCOMANDA:lMESASUS ,oPOSCOMANDA:lPEDIDOSUS

  oPOSCOMANDA:nOption  :=nOption
  oPOSCOMANDA:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oPOSCOMANDA

  cMesa   :=IIF(Empty(cMesa  ),oPOSCOMANDA:COM_MESA  ,cMesa  )
  cMesero :=IIF(Empty(cMesero),oPOSCOMANDA:COM_MESERO,cMesero)

  oPOSCOMANDA:SetScript()        // Asigna Funciones DpXbase como Metodos de oPOSCOMANDA
  oPOSCOMANDA:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oScript:=oPOSCOMANDA:oScript

  // oPOSCOMANDA:oScript:cProgram:="DPPOSCOMANDA"
  // ? oPOSCOMANDA:oScript:cProgram

  oPOSCOMANDA:nClrPane   :=oDp:nGris
  oPOSCOMANDA:cMesa      :=cMesa
  oPOSCOMANDA:cMesero    :=cMesero
  oPOSCOMANDA:cOldMesa   :=cMesa
  oPOSCOMANDA:aComponente:={}
  oPOSCOMANDA:aZona      :=ACLONE(aZona)
  oPOSCOMANDA:cZona      :=cZona
  oPOSCOMANDA:aTarifa    :=ACLONE(aTarifa)
  oPOSCOMANDA:aMuni      :=ACLONE(aMuni  )
  oPOSCOMANDA:cMunici    :=""
  oPOSCOMANDA:cIVA       :="GN"
  oPOSCOMANDA:aDataZona  :=ACLONE(aDataZona)

  oPOSCOMANDA:cEditar :=""
  oPOSCOMANDA:cHora   :=TIME()
  oPOSCOMANDA:cOldRif :=""

  oPOSCOMANDA:lMsgBar :=.F.
  oPOSCOMANDA:lLlevar :=.F.
  oPOSCOMANDA:lDely   :=lDely
  oPOSCOMANDA:nArrayAt:=0
  oPOSCOMANDA:lComanda:=.F. // Debe Imprimir Encabezado de Comanda
  oPOSCOMANDA:aCliZero:=ACLONE(aCliZero)
  oPOSCOMANDA:COM_UNDMED:=oDp:cUndMedPos
  oPOSCOMANDA:CLIZERO()
  oPOSCOMANDA:cCodCli   :=SPACE(10)
  oPOSCOMANDA:cRif      :=SPACE(10)
  oPOSCOMANDA:cNombre   :=SPACE(40)
  oPOSCOMANDA:cDir1     :=SPACE(40)
  oPOSCOMANDA:cDir2     :=SPACE(40)
  oPOSCOMANDA:cDir3     :=SPACE(40)
  oPOSCOMANDA:cDirE1    :=SPACE(40)
  oPOSCOMANDA:cDirE2    :=SPACE(40)
  oPOSCOMANDA:cDirE3    :=SPACE(40)
  oPOSCOMANDA:nTarifa   :=0 // Tarifa del Transporte
  oPOSCOMANDA:cPedido   :=STRZERO(0,10)

  oPOSCOMANDA:cTel1     :=SPACE(12)
  oPOSCOMANDA:cTel2     :=SPACE(12)
  oPOSCOMANDA:cMunici   :=aMuni[1] // SPACE(40)
  oPOSCOMANDA:cZona     :=aZona[1] // SPACE(40)
  oPOSCOMANDA:cCodTra   :=SPACE(10) // Transporte
  oPOSCOMANDA:aDirE     :={}

  IF oPOSCOMANDA:nOption=1 // Incluir en caso de ser Incremental
     oPOSCOMANDA:COM_CANTID:=1
     oPOSCOMANDA:RepeatGet(NIL,"COM_MESA") // Repetir Valores
     oPOSCOMANDA:COM_MESA:=cMesa
     // AutoIncremental 
  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oPOSCOMANDA:CreateWindow()       // Presenta la Ventana
  
  oPOSCOMANDA:ViewTable("DPINV","INV_DESCRI","INV_CODIGO","COM_CODIGO")
  oPOSCOMANDA:ViewTable("DPVENDEDOR","VEN_NOMBRE","VEN_CODIGO","COM_MESERO")

  IF oPOSCOMANDA:lDely

     @ 6.4, 1.0 GROUP oPOSCOMANDA:oGroup TO 11.4,6 PROMPT " Datos del Cliente "

     //
     // Campo : ccRif
     // Uso   : Código del Cliente
     //

     @ 1,1 SAY " Cliente:"
     @ 1,1 SAY " Nombre o Razón Social"
     @ 1,1 SAY " Dirección Fiscal:"
     @ 1,1 SAY " Dirección de Entrega:"

     @ 1,1 SAY " Teléfono:"

     @ 1.0, 1.0 BMPGET oPOSCOMANDA:oRif  VAR oPOSCOMANDA:cRif ;
                VALID oPOSCOMANDA:VALCODCLI();
                    NAME "BITMAPS\FIND.BMP"; 
                    ACTION EJECUTAR("DPCLIZEROBUSCAR",oPOSCOMANDA:oRif);
                    WHEN (.T. ;
                          .AND. oPOSCOMANDA:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

     @ 1,1 GET oPOSCOMANDA:oNombre  VAR oPOSCOMANDA:cNombre ;
           WHEN ALLTRIM(oPOSCOMANDA:cRif )<>"0"

     oPOSCOMANDA:oNombre:bKeyDown:={|nKey| IIF( (nKey=VK_F6 .OR. nKey=13) .AND. !Empty(oPOSCOMANDA:cNombre) .AND. Empty(oPOSCOMANDA:cRif) ,;
                                           EJECUTAR("DPCLIZEROBUSCAR",oPOSCOMANDA:oRif,oPOSCOMANDA:cNombre ) , NIL )}

     @ 1,1 GET oPOSCOMANDA:oDir1 VAR oPOSCOMANDA:cDir1 WHEN ALLTRIM(oPOSCOMANDA:cRif )<>"0"
     @ 1,1 GET oPOSCOMANDA:oDir2 VAR oPOSCOMANDA:cDir2 WHEN ALLTRIM(oPOSCOMANDA:cRif )<>"0"
     @ 1,1 GET oPOSCOMANDA:oDir3 VAR oPOSCOMANDA:cDir3 WHEN ALLTRIM(oPOSCOMANDA:cRif )<>"0"

//     @ 1,1 GET oPOSCOMANDA:oDirE1 VAR oPOSCOMANDA:cDirE1 WHEN oPOSCOMANDA:oZona:nAt>1 .AND. ALLTRIM(oPOSCOMANDA:cRif )<>"0"
//     @ 1,1 GET oPOSCOMANDA:oDirE2 VAR oPOSCOMANDA:cDirE2 WHEN oPOSCOMANDA:oZona:nAt>1 .AND. ALLTRIM(oPOSCOMANDA:cRif )<>"0"
//     @ 1,1 GET oPOSCOMANDA:oDirE3 VAR oPOSCOMANDA:cDirE3 WHEN oPOSCOMANDA:oZona:nAt>1 .AND. ALLTRIM(oPOSCOMANDA:cRif )<>"0"


     @ 1,1 GET oPOSCOMANDA:oDirE1 VAR oPOSCOMANDA:cDirE1 WHEN ALLTRIM(oPOSCOMANDA:cRif )<>"0"
     @ 1,1 GET oPOSCOMANDA:oDirE2 VAR oPOSCOMANDA:cDirE2 WHEN ALLTRIM(oPOSCOMANDA:cRif )<>"0"
     @ 1,1 GET oPOSCOMANDA:oDirE3 VAR oPOSCOMANDA:cDirE3 WHEN ALLTRIM(oPOSCOMANDA:cRif )<>"0"


     @ 1,1 COMBOBOX oPOSCOMANDA:oMuni VAR oPOSCOMANDA:cMunici;
                    ITEMS oPOSCOMANDA:aMuni;
                    WHEN !Empty(oPOSCOMANDA:cRif) .AND. ALLTRIM(oPOSCOMANDA:cRif )<>"0";
                    ON CHANGE (oPOSCOMANDA:BUILDMUNI())

//  ON CHANGE (oPOSCOMANDA:nTarifa:=oPOSCOMANDA:aTarifa[oPOSCOMANDA:oZona:nAt],;


     @ 1,1 COMBOBOX oPOSCOMANDA:oZona VAR oPOSCOMANDA:cZona;
                    ITEMS oPOSCOMANDA:aZona;
                    WHEN !Empty(oPOSCOMANDA:cRif) .AND. LEN(oPOSCOMANDA:oZona:aItems)>1;
                    ON CHANGE (oPOSCOMANDA:CALTARIFA())

     @ 1,1 GET oPOSCOMANDA:oTel1 VAR oPOSCOMANDA:cTel1 
     @ 1,1 GET oPOSCOMANDA:oTel2 VAR oPOSCOMANDA:cTel2

     @ 3,10 BUTTON oPOSCOMANDA:oBtnNext PROMPT " > " ACTION oPOSCOMANDA:NEXTDIR(1);
                  WHEN LEN(oPOSCOMANDA:aDirE)>1

     @ 3,20 BUTTON oPOSCOMANDA:oBtnPrev PROMPT " < " ACTION oPOSCOMANDA:NEXTDIR(-1);
                  WHEN LEN(oPOSCOMANDA:aDirE)>1

  ENDIF

  @ 6.4, 1.0 GROUP oPOSCOMANDA:oGroup TO 11.4,6 PROMPT " Pedidos "
  
  //
  // Campo : COM_CODIGO
  // Uso   : Producto  
  //  .OR. oPOSCOMANDA:oDPINV:SeekTable("INV_CODIGO",oPOSCOMANDA:oCOM_CODIGO,NIL,oPOSCOMANDA:oINV_DESCRI);
  //
  @ 1.0, 1.0 BMPGET oPOSCOMANDA:oCOM_CODIGO  VAR oPOSCOMANDA:COM_CODIGO ;
             VALID oPOSCOMANDA:COMCODIGO();
                    NAME "BITMAPS\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("DPINV",NIL,"INV_UTILIZ='V'"), oDpLbx:GetValue("INV_CODIGO",oPOSCOMANDA:oCOM_CODIGO)); 
                    WHEN (IIF(oPOSCOMANDA:lDely,!Empty(oPOSCOMANDA:cRif),.T.) .AND.;
                          (AccessField("DPPOSCOMANDA","COM_CODIGO",oPOSCOMANDA:nOption));
                    .AND. oPOSCOMANDA:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oPOSCOMANDA:oCOM_CODIGO:cMsg    :="Producto"
    oPOSCOMANDA:oCOM_CODIGO:cToolTip:="Producto"

  @ 0,0 SAY oDp:xDPINV PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,15724527

  @ 0,0 SAY oPOSCOMANDA:oINV_DESCRI;
        PROMPT oPOSCOMANDA:COM_DESCRI PIXEL;
        SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 

 IF  !oPOSCOMANDA:lDely

  //
  // Campo : COM_MESA  
  // Uso   : Mesa                                    
  //
  @ 4.6, 1.0 GET oPOSCOMANDA:oCOM_MESA    VAR oPOSCOMANDA:COM_MESA;
                 VALID CERO(oPOSCOMANDA:COM_MESA  ) .AND. oPOSCOMANDA:VALMESA();
                 WHEN (AccessField("DPPOSCOMANDA","COM_MESA",oPOSCOMANDA:nOption);
                    .AND. oPOSCOMANDA:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10

    oPOSCOMANDA:oCOM_MESA  :cMsg    :="Mesa"
    oPOSCOMANDA:oCOM_MESA  :cToolTip:="Mesa"

  @ oPOSCOMANDA:oCOM_MESA  :nTop-08,oPOSCOMANDA:oCOM_MESA  :nLeft SAY "Mesa" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527

  //
  // Campo : COM_MESERO
  // Uso   : Mesero                                  
  //
  @ 2.8, 1.0 BMPGET oPOSCOMANDA:oCOM_MESERO  VAR oPOSCOMANDA:COM_MESERO  VALID CERO(oPOSCOMANDA:COM_MESERO);
                   .AND. oPOSCOMANDA:oDPVENDEDOR:SeekTable("VEN_CODIGO",oPOSCOMANDA:oCOM_MESERO,NIL,oPOSCOMANDA:oVEN_NOMBRE);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPVENDEDOR","Meseros","VEN_SITUAC='A'"), oDpLbx:GetValue("VEN_CODIGO",oPOSCOMANDA:oCOM_MESERO)); 
                    WHEN !Empty(oPOSCOMANDA:COM_CODIGO) .AND. (AccessField("DPPOSCOMANDA","COM_MESERO",oPOSCOMANDA:nOption);
                    .AND. oPOSCOMANDA:nOption!=0);
                    FONT oFontG;
                    SIZE 24,10

    oPOSCOMANDA:oCOM_MESERO:cMsg    :="Mesero"
    oPOSCOMANDA:oCOM_MESERO:cToolTip:="Mesero"

  @ 0,0 SAY "Mesero" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,15724527

  @ 0,0 SAY oPOSCOMANDA:oVEN_NOMBRE;
        PROMPT oPOSCOMANDA:oDPVENDEDOR:VEN_NOMBRE PIXEL;
        SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 

 ENDIF

  //
  // Campo : COM_CANTID
  // Uso   : Cantidad                                
  //
  @ 6.4, 1.0 GET oPOSCOMANDA:oCOM_CANTID  VAR oPOSCOMANDA:COM_CANTID  PICTURE "99999.99";
                 VALID oPOSCOMANDA:COMCANTID();
                 WHEN !Empty(oPOSCOMANDA:COM_CODIGO) .AND. (AccessField("DPPOSCOMANDA","COM_CANTID",oPOSCOMANDA:nOption);
                     .AND. oPOSCOMANDA:nOption!=0);
                 FONT oFontG;
                 SIZE 32,10;
                 RIGHT

  oPOSCOMANDA:oCOM_CANTID:cMsg    :="Cantidad"
  oPOSCOMANDA:oCOM_CANTID:cToolTip:="Cantidad"

   @ 0,0 SAY "Cantidad" PIXEL;
         SIZE NIL,7 FONT oFont COLOR nClrText,15724527

  //
  // Campo : COM_COMENT
  // Uso   : Cantidad                                
  //
  @ 6.4, 1.0 GET oPOSCOMANDA:oCOM_COMENT  VAR oPOSCOMANDA:COM_COMENT;
                 VALID oPOSCOMANDA:COMCOMENT();
                 WHEN !Empty(oPOSCOMANDA:COM_CODIGO) .AND. (AccessField("DPPOSCOMANDA","COM_COMENT",oPOSCOMANDA:nOption);
                     .AND. oPOSCOMANDA:cEditar="S";
                     .AND. oPOSCOMANDA:nOption!=0);
                 FONT oFontG;
                 SIZE 32,10


  oPOSCOMANDA:oCOM_COMENT:bKeyDown:={|nkey| IIF( nKey=VK_F6 , oPOSCOMANDA:Abrevia(), NIL )}

  oPOSCOMANDA:oCOM_CANTID:cMsg    :="Comentarios"
  oPOSCOMANDA:oCOM_CANTID:cToolTip:="Comentarios"

  @ 0,0 SAY "Comentarios" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,15724527

   IF Empty(aData)
     AADD(aData,{"","","","","",0,"","",0})
   ENDIF

   oPOSCOMANDA:oBrw:=TXBrowse():New( oPOSCOMANDA:oDlg )
   oPOSCOMANDA:oBrw:SetArray( aData, .F. )
   oPOSCOMANDA:oBrw:SetFont(oFont)
   oPOSCOMANDA:oBrw:lFooter     := lDely
   oPOSCOMANDA:oBrw:lHScroll    := .F.
   oPOSCOMANDA:oBrw:nHeaderLines:= 1
//  oPOSCOMANDA:oBrw:lFooter     := .F.

   oPOSCOMANDA:aData    :=ACLONE(aData)

   AEVAL(oPOSCOMANDA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oPOSCOMANDA:oBrw:aCols[1]   
   oCol:cHeader      :="Código"
   oCol:nWidth       :=080

   oCol:=oPOSCOMANDA:oBrw:aCols[2]
   oCol:cHeader      :="Descripción"
   oCol:nWidth       :=180+4+iif(Empty(oDp:cModeVideo),0,80)


   oCol:=oPOSCOMANDA:oBrw:aCols[3]
   oCol:cHeader      :="Mesa"
   oCol:nWidth       :=34+2+iif(Empty(oDp:cModeVideo),0,40)


   oCol:=oPOSCOMANDA:oBrw:aCols[4]
   oCol:cHeader      :="Mesero"
   oCol:nWidth       :=60+iif(Empty(oDp:cModeVideo),0,40)

   oCol:=oPOSCOMANDA:oBrw:aCols[5]
   oCol:cHeader      :="Nombre del Mesero"
   oCol:nWidth       :=156-50+iif(Empty(oDp:cModeVideo),0,30)

   oCol:=oPOSCOMANDA:oBrw:aCols[6]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Cantidad"
   oCol:nWidth       :=100+iif(Empty(oDp:cModeVideo),0,15)

   oCol:bStrData     :={|nMonto|nMonto:=oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,6],;
                                TRAN(nMonto,"999,999.99")}

   oPOSCOMANDA:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oPOSCOMANDA:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16773862, 16771538 ) } }

   oPOSCOMANDA:oBrw:bClrHeader            := {|| {0,14671839 }}
   oPOSCOMANDA:oBrw:bClrFooter            := {|| {0,14671839 }}



   oCol:=oPOSCOMANDA:oBrw:aCols[7]
   oCol:cHeader      :="Unidad"
   oCol:nWidth       :=44+iif(Empty(oDp:cModeVideo),0,50)
   oCol:bStrData     :={||oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,8]}

   IF lDely 

      oCol:=oPOSCOMANDA:oBrw:aCols[5]
      oCol:cHeader      :="Precio"
      oCol:nDataStrAlign:= AL_RIGHT
      oCol:nHeadStrAlign:= AL_RIGHT
      oCol:nFootStrAlign:= AL_RIGHT
      oCol:nWidth       :=100
      oCol:bStrData     :={|nMonto|nMonto:=oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,9],;
                                   TRAN(nMonto,"999,999.99")}

      oCol:cFooter      :=TRAN(0,"99,999,999,999.99")

      oPOSCOMANDA:oBrw:DelCol(3)
      oPOSCOMANDA:oBrw:DelCol(3)
    // oPOSCOMANDA:oBrw:DelCol(3)

     @ 1,1 SAY oPOSCOMANDA:oZonaSay PROMPT " Zona:"+TRAN(oPOSCOMANDA:nTarifa,"99,999,999,999.99")

     @ 1,1  SAY "Pedido #"
     @ 1,40 SAY oPOSCOMANDA:oPedido PROMPT oPOSCOMANDA:cPedido


     @ 1,1 SAY oDp:xDPMUNICIPIOS 

  ELSE

     oPOSCOMANDA:oBrw:DelCol(8)
     oPOSCOMANDA:oBrw:DelCol(LEN(oPOSCOMANDA:oBrw:aCols))

   ENDIF

   FOR I=1 TO LEN(oPOSCOMANDA:oBrw:aCols)
       oPOSCOMANDA:oBrw:aCols[I]:bLClickFooter:=oCol:bLClickFooter
   NEXT I

   oPOSCOMANDA:oBrw:bLDblClick:={||oPOSCOMANDA:Modificar()}

   oPOSCOMANDA:oBrw:bChange:={||oPOSCOMANDA:oCOM_CODIGO:VarPut(SPACE(20),.T.)}
   oPOSCOMANDA:oBrw:CreateFromCode()

   @09, 33  SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\XSAVE.BMP" NOBORDER;
            LEFT PROMPT "Grabar"+CRLF+" F10";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oPOSCOMANDA:Save())

   oBtn:cToolTip:="Grabar Registro"
   oBtn:cMsg    :=oBtn:cToolTip

   oPOSCOMANDA:oBtnSave:=oBtn
   oPOSCOMANDA:SetKey(VK_F10,oBtn:bAction)

   @09, 43 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\XDELETE.BMP","BITMAPS\XDELETE.BMP","BITMAPS\XDELETEG.BMP";
           NOBORDER;
           LEFT PROMPT "Quitar";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           WHEN ISTABELI("DPPOSCOMANDA");
           ACTION (oPOSCOMANDA:Quitar()) CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Quitar Registro "
   oBtn:cMsg    :=oBtn:cToolTip


   @09, 73 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\XEDIT.BMP","BITMAPS\XEDIT.BMP","BITMAPS\XEDITG.BMP" NOBORDER;
           LEFT PROMPT "Modificar";
           WHEN ISTABMOD("DPPOSCOMANDA");
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oPOSCOMANDA:Modificar()) CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Modificar Registro "
   oBtn:cMsg    :=oBtn:cToolTip

  IF !oPOSCOMANDA:lDely
   
    @09, 73 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\MESAS.BMP" NOBORDER;
            LEFT PROMPT "Mesas";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oPOSCOMANDA:SELMESA()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Seleccionar Mesa "
    oBtn:cMsg    :=oBtn:cToolTip
   
  ELSE

    @09, 73 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\pedidoventa.BMP" NOBORDER;
            LEFT PROMPT "Pedidos";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oPOSCOMANDA:SELMESA()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Seleccionar Mesa "
    oBtn:cMsg    :=oBtn:cToolTip
   
  ENDIF

   @09, 73 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\POS.BMP" NOBORDER;
           LEFT PROMPT "Ventas";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (EJECUTAR("DPPOS01")) CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Hacer Ventas "
   oBtn:cMsg    :=oBtn:cToolTip

   IF oPOSCOMANDA:lDely

     @09, 73 SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\guiacargadelivery.BMP" NOBORDER;
             LEFT PROMPT "Despacho"+CRLF+"Ruta";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION EJECUTAR("DPPOSCMDENVIA") CANCEL

     oBtn:lCancel :=.T.
     oBtn:cToolTip:="Imprimir Ruta de Despacho "
     oBtn:cMsg    :=oBtn:cToolTip




   ELSE
   
     @09, 73 SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XPRINTCTA.BMP" NOBORDER;
             LEFT PROMPT "Imprimir"+CRLF+"Cuenta";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oPOSCOMANDA:ImprimeCta()) CANCEL

     oBtn:lCancel :=.T.
     oBtn:cToolTip:="Imprimir Cuenta "
     oBtn:cMsg    :=oBtn:cToolTip

   ENDIF

   @09, 73 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\GRUPOS.BMP" NOBORDER;
           LEFT PROMPT "Grupos";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("GRIDGRUPOS",oPOSCOMANDA:oCOM_CODIGO) CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Grupos de Productos "
   oBtn:cMsg    :=oBtn:cToolTip

   @09, 73 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\XPRINTCMD.BMP" NOBORDER;
           LEFT PROMPT "Imprimir"+CRLF+"Comanda";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION oPOSCOMANDA:PRINTCMD() CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Imprimir Comanda "
   oBtn:cMsg    :=oBtn:cToolTip

   @09, 73 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\XSALIR.BMP" NOBORDER;
           LEFT PROMPT "Salir";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oPOSCOMANDA:Cancel()) CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Cancelar y Cerrar Formulario "
   oBtn:cMsg    :=oBtn:cToolTip


   // BOTONES INFERIORES

   @09, 43 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\COMPONENTE.BMP","BITMAPS\COMPONENTE.BMP","BITMAPS\COMPONENTEG.BMP";
           NOBORDER;
           LEFT PROMPT GetFromVar("{oDp:xDPCOMPONENTES}");
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           WHEN .T.;
           ACTION (oPOSCOMANDA:Componentes(.T.)) CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Quitar Registro "
   oBtn:cMsg    :=oBtn:cToolTip

   @15, 43 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\GAVETA.BMP","BITMAPS\GAVETA.BMP","BITMAPS\GAVETAG.BMP";
           NOBORDER;
           LEFT PROMPT "Gaveta";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           WHEN (LEFT(UPPE(oDp:cComGav),3)="COM" .OR. oDp:cDisp_lGaveta);
           ACTION EJECUTAR("A_GAV",.T.) CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Abrir Gaveta "
   oBtn:cMsg    :=oBtn:cToolTip

   @15, 43 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\delivery.BMP",NIL,"BITMAPS\deliveryG.BMP";
           NOBORDER;
           LEFT PROMPT "Delivery";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           WHEN oDp:lDelivery;
           ACTION EJECUTAR("DPPOSCOMANDA",.T.) CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Abrir Gaveta "
   oBtn:cMsg    :=oBtn:cToolTip


   IF oPOSCOMANDA:lDely

   @15, 43 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\xprint.bmp";
           NOBORDER;
           LEFT PROMPT "Reimprime";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           WHEN oDp:lDelivery;
           ACTION EJECUTAR("DPPOSGUIACARPRN") CANCEL

   ENDIF

   oPOSCOMANDA:Activate({||oPOSCOMANDA:INICIO()})

   STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oPOSCOMANDA

FUNCTION INICIO()

//  oPOSCOMANDA:oScript:=oScript
  oPOSCOMANDA:oBrw:SetColor(0,16773862)

RETURN .T.
/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oPOSCOMANDA:nOption=1 // Incluir en caso de ser Incremental

     oPOSCOMANDA:COM_CANTID:=1
     oPOSCOMANDA:aComponente:={}
//   oPOSCOMANDA:COM_MESA  :=oPOSCOMANDA:cMesa  
//   oPOSCOMANDA:COM_MESERO:=oPOSCOMANDA:cMesero

  ENDIF

  oPOSCOMANDA:COM_MESA  :=oPOSCOMANDA:cMesa  
  oPOSCOMANDA:COM_MESERO:=oPOSCOMANDA:cMesero
 
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
  LOCAL cItem:=IIF(oPOSCOMANDA:nOption=1,SQLINCREMENTAL("DPPOSCOMANDA","COM_ITEM"),oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,7])
  LOCAL nTotal:=0,nPorIva:=0

  oPOSCOMANDA:NUMPEDIDO()

  nTotal:=oPOSCOMANDA:COM_CANTID*oPOSCOMANDA:COM_PRECIO
  
  nPorIva:=EJECUTAR("IVACAL",oPOSCOMANDA:cIVA,2,oDp:dFecha) // IVA (Nacional o Zona Libre
  oPOSCOMANDA:COM_MTOIVA:=PORCEN(nTotal,nPorIva)

  oPOSCOMANDA:COM_ITEM  :=cItem
  oPOSCOMANDA:COM_USUARI:=oDp:cUsuario
  oPOSCOMANDA:COM_LLEVAR:=oPOSCOMANDA:lDely
  oPOSCOMANDA:COM_TIPO  :="P" // Todos son Platos
  oPOSCOMANDA:cItemCom  :=cItem
  oPOSCOMANDA:COM_IMPRES:=.F.
  oPOSCOMANDA:COM_HORA  :=IIF(oPOSCOMANDA:lDely,oPOSCOMANDA:cHora,TIME())

  IF oPOSCOMANDA:lDely

    oPOSCOMANDA:COM_MESERO:=oPOSCOMANDA:cMesero
    oPOSCOMANDA:cCodVenCom:=oPOSCOMANDA:cMesero

  ELSE

    IF ISDIGIT(oPOSCOMANDA:COM_MESERO)
      oPOSCOMANDA:COM_MESERO:=STRZERO( VAL(oPOSCOMANDA:COM_MESERO) , LEN(oPOSCOMANDA:COM_MESERO))
    ENDIF

    IF ISDIGIT(oPOSCOMANDA:COM_MESA)
       oPOSCOMANDA:COM_MESA  :=STRZERO( VAL(oPOSCOMANDA:COM_MESA  ) , LEN(oPOSCOMANDA:COM_MESA))
    ENDIF

    IF !ISSQLGET("DPVENDEDOR","VEN_CODIGO",oPOSCOMANDA:COM_MESERO)
       MensajeErr(oDp:xDPVENDEDOR+" "+oPOSCOMANDA:COM_MESERO+" No Existe")
       DPFOCUS(oPOSCOMANDA:oCOM_MESERO)
       RETURN .F.
    ENDIF

  ENDIF

  IF Empty(oPOSCOMANDA:COM_CODIGO) .OR. !ISSQLGET("DPINV","INV_CODIGO",oPOSCOMANDA:COM_CODIGO)
     oDp:DPFOCUS(oPOSCOMANDA:COM_CODIGO)
     RETURN .F.
  ENDIF

  IF oPOSCOMANDA:COM_CODIGO=oDp:cCodTrans
     oPOSCOMANDA:COM_LPT:="Ning"
  ENDIF

  EJECUTAR("DPPOSSAVECLI",oPOSCOMANDA)
  oPOSCOMANDA:COM_RIF   :=oPOSCOMANDA:cRif

  IF !Empty(oPOSCOMANDA:cOldRif) .AND. !(oPOSCOMANDA:cRif==oPOSCOMANDA:cOldRif) .AND. !Empty(oPOSCOMANDA:cPedido)
     SQLUPDATE("DPPOSCOMANDA","COM_RIF",oPOSCOMANDA:cRif,"COM_PEDIDO"+GetWhere("=",oPOSCOMANDA:cPedido))
  ENDIF

  oPOSCOMANDA:cOldRif:=oPOSCOMANDA:cRif

 // Condiciones para no Repetir el Registro

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
 LOCAL cItem:=IIF(oPOSCOMANDA:nOption=1,SQLINCREMENTAL("DPPOSCOMANDA","COM_ITEM"),oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,7])
 LOCAL aLine:={oPOSCOMANDA:COM_CODIGO,;
               oPOSCOMANDA:COM_DESCRI,;
               oPOSCOMANDA:COM_MESA  ,;
               oPOSCOMANDA:COM_MESERO,;
               MYSQLGET("DPVENDEDOR","VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",oPOSCOMANDA:COM_MESERO)),;
               oPOSCOMANDA:COM_CANTID,;
               oPOSCOMANDA:COM_ITEM,;
               oPOSCOMANDA:COM_UNDMED,;
               oPOSCOMANDA:COM_PRECIO}

  
  aline[8]:=oPOSCOMANDA:COM_UNDMED
  aLine[9]:=oPOSCOMANDA:COM_PRECIO

  IF oPOSCOMANDA:lDely
    aline[5]:=oPOSCOMANDA:COM_PEDIDO
  ENDIF

//  ViewArray({aLine})
// oPOSCOMANDA:PRINTCMD()

  oPOSCOMANDA:cMesa   :=oPOSCOMANDA:COM_MESA

  IF (!oPOSCOMANDA:cOldMesa=oPOSCOMANDA:cMesa) .AND. !Empty(oPOSCOMANDA:cOldMesa);
        .AND. MYCOUNT("DPPOSCOMANDA","COM_IMPRES=0 AND COM_LLEVAR=0 AND COM_USUARI"+GetWhere("=",oDp:cUsuario)+;
                      "AND COM_MESA"+GetWhere("=",oPOSCOMANDA:cOldMesa))>0

     oPOSCOMANDA:PRINTCMD(oPOSCOMANDA:cOldMesa)
     // EJECUTAR("DPPOSCOMMPRN",oPOSCOMANDA:cOldMesa,oDp:cUsuario)
     // oPOSCOMANDA:cOldMesa:=oPOSCOMANDA:cMesa

  ENDIF

  oPOSCOMANDA:cOldMesa:=oPOSCOMANDA:cMesa

  IF ALLDIGIT(oPOSCOMANDA:cMesa)
    oPOSCOMANDA:cMesa:=PADR(LSTR(VAL(oPOSCOMANDA:cMesa)),LEN(oPOSCOMANDA:cMesa))
  ENDIF

  oPOSCOMANDA:cMesero :=oPOSCOMANDA:COM_MESERO
 
  IF ALLDIGIT(oPOSCOMANDA:cMesero) .AND. !oPOSCOMANDA:lDely
    oPOSCOMANDA:cMesero:=PADR(LSTR(VAL(oPOSCOMANDA:cMesero)),LEN(oPOSCOMANDA:cMesero))
  ENDIF

  IF LEN(oPOSCOMANDA:oBrw:aArrayData)=1 .AND. Empty(oPOSCOMANDA:oBrw:aArrayData[1,1])
    oPOSCOMANDA:oBrw:aArrayData[1]:=aLine
  ELSE
    IF oPOSCOMANDA:nOption=1 
      AADD(oPOSCOMANDA:oBrw:aArrayData , aLine )
      oPOSCOMANDA:oBrw:GoBottom(.T.)
    ELSE
      oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:nArrayAt]:=aLine 
      oPOSCOMANDA:oBrw:DrawLine(.T.)
    ENDIF
  ENDIF

  oPOSCOMANDA:oCOM_CODIGO:nLastKey:=0
  oPOSCOMANDA:nOption:=1
  oPOSCOMANDA:cWhere :=""
  oPOSCOMANDA:SaveComp()
  oPOSCOMANDA:aComponente:={}
  oPOSCOMANDA:CALTOTAL()

  DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)

RETURN .T.

FUNCTION COMCANTID()

  IF oPOSCOMANDA:COM_CANTID<=0
     RETURN .F.
  ENDIF

  // Carga de Componentes
  oPOSCOMANDA:Componentes(.F.)
 
  // Busca si el Producto Requiere Comentarios
  IF oPOSCOMANDA:cEditar="S"
     DPFOCUS(oPOSCOMANDA:oCOM_COMENT)
     RETURN .T.
  ENDIF

  IF oPOSCOMANDA:oCOM_CANTID:nLastKey=13
    EVAL(oPOSCOMANDA:oBtnSave:bAction)
  ENDIF

RETURN .T.

/*
// Valida el Producto
*/
FUNCTION COMCODIGO()
   LOCAL cDescri:="",lFound:=.F.,cEquiv:=""
   LOCAL nPrecio:=0,cLpt:=""

   IF EMPTY(oPOSCOMANDA:COM_CODIGO) .AND. oPOSCOMANDA:oCOM_CODIGO:nLastKey=13
      oPOSCOMANDA:oCOM_CODIGO:KeyBoard(VK_F6)
      RETURN .T.
   ENDIF

   IF EMPTY(oPOSCOMANDA:COM_CODIGO) 
      RETURN .T.
   ENDIF

   lFound:=ISSQLGET("DPINV","INV_CODIGO",oPOSCOMANDA:COM_CODIGO)

   oPOSCOMANDA:COM_CODEQU:=oPOSCOMANDA:COM_CODIGO
   oPOSCOMANDA:COM_UNDMED:=oDp:cUndMedPos

   IF !oPOSCOMANDA:lDely
     oPOSCOMANDA:oCOM_MESERO:VarPut(oPOSCOMANDA:cMesero,.T.)
     oPOSCOMANDA:COM_MESERO:=oPOSCOMANDA:cMesero
   ENDIF

   IF !lFound

      // BUSCA EL EQUIVALENTE
      cEquiv:=SQLGET("DPEQUIV","EQUI_CODIG,EQUI_MED,EQUI_DESCR,EQUI_LPT","EQUI_BARRA"+GetWhere("=",oPOSCOMANDA:COM_CODIGO))

      IF !Empty(cEquiv)

         oPOSCOMANDA:COM_CODEQU:=oPOSCOMANDA:COM_CODIGO
         oPOSCOMANDA:oCOM_CODIGO:VarPut(cEquiv,.T.)
         oPOSCOMANDA:COM_UNDMED:=oDp:aRow[2]
         cLpt   :=IIF(LEFT(oDp:aRow[4],1)="L",oDp:aRow[4],cLpt)
         cDescri:=IIF(Empty(oDp:aRow[3]),cDescri,oDp:aRow[3])
         lFound:=.T.

      ENDIF

   ENDIF

   IF !lFound 
     // ISSQLGET("DPINV","INV_CODIGO",oPOSCOMANDA:COM_CODIGO)
     oPOSCOMANDA:oCOM_CODIGO:KEYBOARD(VK_F6) 
     oPOSCOMANDA:oCOM_CODIGO:nLastKey:=0
     oPOSCOMANDA:oDlg       :nLastKey:=0
     DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)
     RETURN .F.
   ENDIF

   oPOSCOMANDA:COM_DESCRI:=SQLGET("DPINV","INV_DESCRI,INV_EDITAR,INV_LPT,INV_IVA","INV_CODIGO"+GetWhere("=",oPOSCOMANDA:COM_CODIGO))
   oPOSCOMANDA:cIVA      :=oDp:aRow[4]
   oPOSCOMANDA:COM_DESCRI:=IIF(!Empty(cDescri),cDescri,oPOSCOMANDA:COM_DESCRI)
   oPOSCOMANDA:COM_LPT   :=IIF(!Empty(cLpt   ),cLpt   ,oDp:aRow[3])
   oPOSCOMANDA:COM_LPT   :=IIF(Empty(oPOSCOMANDA:COM_LPT), oDp:cImpCmd   , oPOSCOMANDA:COM_LPT )

//? cLpt,oDp:aRow[3]
// oPOSCOMANDA:COM_DESCRI:=cDescri

   // Unidad de Medida para la Comanda 

   IF !Empty(oDp:aRow)
     oPOSCOMANDA:cEditar:=oDp:aRow[2]
   ENDIF

   oPOSCOMANDA:oDPINV:SeekTable("INV_CODIGO",oPOSCOMANDA:oCOM_CODIGO,NIL,oPOSCOMANDA:oINV_DESCRI)
   // Aqui Busca el Precio
   nPrecio:=MYSQLGET("DPPRECIOS","PRE_PRECIO","PRE_CODIGO"+GetWhere("=",oPOSCOMANDA:COM_CODIGO)+" AND "+;
                                              "PRE_UNDMED"+GetWhere("=",oPOSCOMANDA:COM_UNDMED)+" AND "+;
                                              "PRE_LISTA "+GetWhere("=",oDp:cPrecioPos        )+" AND "+;
                                              "PRE_CODMON"+GetWhere("=",oDp:cCodMonPos        ))

// ? CLPCOPY(oDp:cSql)

   IF nPrecio=0 .AND. oDp:cCodTrans=oPOSCOMANDA:COM_CODIGO
      nPrecio:=oPOSCOMANDA:nTarifa
      IF nPrecio=0
         RETURN .T.
      ENDIF
   ENDIF

   IF nPrecio<=0 

      MensajeErr(GetFromVar("{oDp:DPINV}")+" no posee Precio"+CRLF+;
                 "Tipo de Precio:"+oDp:cPrecioPos+CRLF+;
                 "Unidad :"+oPOSCOMANDA:COM_UNDMED,"Precio Requerido")
      DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)
      RETURN .F.

   ENDIF

   oPOSCOMANDA:COM_PRECIO:=nPrecio
//   DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)
//   ? "AQUI ES"

RETURN .T.

FUNCTION COMCOMENT()
   LOCAL nAt,cData:=ALLTRIM(oPOSCOMANDA:COM_COMENT)

   IF Empty(oDp:aAbrevia) .AND. !Empty(oPOSCOMANDA:COM_COMENT)
     oDp:aAbrevia:=ASQL("SELECT ABR_CODIGO,ABR_TEXTO FROM DPABREVIATURAS ")
   ENDIF

   nAt  :=IIF( Empty(cData) , 0 , ASCAN(oDp:aAbrevia,{|a,n|ALLTRIM(a[1])=cData}) )

   IF nAt>0

     cData:=oDp:aAbrevia[nAt,2]
     oPOSCOMANDA:oCOM_COMENT:VarPut(cData,.T.)
     oPOSCOMANDA:COM_COMENT:=cData

   ENDIF

   IF oPOSCOMANDA:oCOM_COMENT:nLastKey=13
     EVAL(oPOSCOMANDA:oBtnSave:bAction)
   ENDIF

RETURN .T.


FUNCTION QUITAR()
  LOCAL nAt    :=oPOSCOMANDA:oBrw:nArrayAt
  LOCAL nRowSel:=oPOSCOMANDA:oBrw:nRowSel
  LOCAL aData  :=oPOSCOMANDA:oBrw:aArrayData[nAt]
  LOCAL cWhere :="COM_MESA"+GetWhere("=",aData[4])+" AND "

  IF oPOSCOMANDA:lDely
     cWhere:="COM_PEDIDO"+GetWhere("=",aData[5])+" AND "
  ENDIF

// ? cWhere
// ViewArray(oPOSCOMANDA:oBrw:aArrayData)
// RETURN .T.

  IF MsgNoYes("Desea Borrar Comanda "+aData[7],"Seleccione Opción")

      ARREDUCE(oPOSCOMANDA:oBrw:aArrayData,oPOSCOMANDA:oBrw:nArrayAt)

     IF Empty(oPOSCOMANDA:oBrw:aArrayData)

       AADD(oPOSCOMANDA:oBrw:aArrayData,{"","","","","",0,"","",0,""})
       oPOSCOMANDA:oBrw:Gotop(.T.)
       oPOSCOMANDA:oBrw:Refresh(.T.)
       DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)

     ELSE

       oPOSCOMANDA:oBrw:Refresh(.F.)
       oPOSCOMANDA:oBrw:nArrayAt:=MIN(nAt     , LEN(oPOSCOMANDA:oBrw:aArrayData))
       oPOSCOMANDA:oBrw:nRowSel :=MIN(nRowSel , oPOSCOMANDA:oBrw:RowCount())

     ENDIF


     SQLDELETE("DPPOSCOMANDA",cWhere+"COM_ITEM"+GetWhere("=",aData[7]))

     SQLDELETE("DPPOSCOMANDA",cWhere+"COM_ITEM_A"+GetWhere("=",aData[7])+" AND "+;
                              "COM_TIPO='C'")


     oPOSCOMANDA:COM_PEDIDO:=oPOSCOMANDA:cPedido
     oPOSCOMANDA:CALTOTAL()

  ENDIF

RETURN .T.

FUNCTION MODIFICAR(lEdit)

  LOCAL aLine:=oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt],cWhere

  oPOSCOMANDA:oCOM_CODIGO:VarPut(aLine[1],.T.)

  IF !oPOSCOMANDA:lDely
    oPOSCOMANDA:oCOM_MESA  :VarPut(aLine[3],.T.)
    oPOSCOMANDA:oCOM_MESERO:VarPut(aLine[4],.T.)
    oPOSCOMANDA:oCOM_CANTID:VarPut(aLine[6],.T.)

    oPOSCOMANDA:oVEN_NOMBRE:SetText(SQLGET("DPVENDEDOR","VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",aLine[4])))
    oPOSCOMANDA:oINV_DESCRI:SetText(SQLGET("DPINV"     ,"INV_DESCRI","INV_CODIGO"+GetWhere("=",aLine[1])))

  ELSE

    cWhere:="COM_PEDIDO"+GetWhere("=",oPOSCOMANDA:COM_PEDIDO)

  ENDIF

  DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)

  oPOSCOMANDA:nOption    :=3
  oPOSCOMANDA:nArrayAt   :=oPOSCOMANDA:oBrw:nArrayAt
  oPOSCOMANDA:cWhere     :="COM_ITEM"+GetWhere("=",aLine[7])+;
                           IIF(Empty(cWhere), "" ," AND "+cWhere)

RETURN .T.

FUNCTION SELMESA()
  LOCAL cWhereMesa:=IIF(!oPOSCOMANDA:lMESASUS  ,"COM_USUARI"+GetWhere("=",oDp:cUsuario),"")
  LOCAL cWherePed :=IIF(!oPOSCOMANDA:lPEDIDOSUS,"COM_USUARI"+GetWhere("=",oDp:cUsuario),"")

  LOCAL cMesa:=EJECUTAR(IIF(oPosComanda:lDely,"DPPOSPEDIDO","DPPOSMESA"),oPOSCOMANDA,oPOSCOMANDA:cPedido,;
                        IIF(oPosComanda:lDely,cWherePed    ,cWhereMesa))

 IF !Empty(cMesa) .AND. oPosComanda:lDely

   EJECUTAR("DPPOSSAVECLI",oPOSCOMANDA)
   EJECUTAR("DPPOSPEDEDIT",oPosComanda,cMesa)

 ENDIF

RETURN .T.

FUNCTION VALMESA()

  IF oPOSCOMANDA:oCOM_MESA:nLastKey=13 .AND. !Empty(oPOSCOMANDA:COM_MESA) .AND. Empty(oPOSCOMANDA:COM_CODIGO)
     EJECUTAR("DPPOSMESACTA",oPOSCOMANDA,oPOSCOMANDA:COM_MESA)
  ENDIF

RETURN .T.

/*
// Imprime la Cuenta
*/
FUNCTION ImprimeCta()
   LOCAL cWhere:="COM_MESA"+GetWhere("=",oPOSCOMANDA:COM_MESA)

// EJECUTAR("DPPOSMESAPRN",oPOSCOMANDA:COM_MESA)

   EJECUTAR("FMTRUN","DEMOSTRATIVODECUENTA","DEMOSTRATIVODECUENTA","Demostrativo de Cuenta"+oPOSCOMANDA:COM_MESA,cWhere)

RETURN .T.

/*
// Borrar Mesa
*/
FUNCTION BorrarMesa(cMesa)
  LOCAL nAt,aData    
  LOCAL nRowSel:=oPOSCOMANDA:oBrw:nRowSel

  WHILE .T.

     nAt:=ASCAN(oPOSCOMANDA:oBrw:aArrayData , {|a,n| a[3]=cMesa })

     IF nAt=0
        EXIT
     ENDIF

     ARREDUCE(oPOSCOMANDA:oBrw:aArrayData , nAt)

  ENDDO

  nAt:=oPOSCOMANDA:oBrw:nArrayAt

  IF Empty(oPOSCOMANDA:oBrw:aArrayData)
    oPOSCOMANDA:oBrw:aArrayData:={}
    oPOSCOMANDA:oBrw:nArrayAt:=1
    oPOSCOMANDA:oBrw:nRowSel :=1

    AADD(oPOSCOMANDA:oBrw:aArrayData,{"","","","","",0,"",""})
    oPOSCOMANDA:oBrw:Gotop(.T.)
    oPOSCOMANDA:oBrw:Refresh(.T.)

    DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)

  ELSE

    oPOSCOMANDA:oBrw:Refresh(.F.)
    oPOSCOMANDA:oBrw:nArrayAt:=MIN(nAt     , LEN(oPOSCOMANDA:oBrw:aArrayData))
    oPOSCOMANDA:oBrw:nRowSel :=MIN(nRowSel , oPOSCOMANDA:oBrw:RowCount())

  ENDIF

RETURN .T.

/*
// Asigna los Valores del Cliente Zerpo
*/
FUNCTION CLIZERO()
  
  AEVAL(oPOSCOMANDA:aCliZero,{|a,n|oPOSCOMANDA:ADD(a[1],a[2]),oPOSCOMANDA:SET(a[1],a[2])})

RETURN .T.


FUNCTION Componentes(lEdit)
   LOCAL cCodInv:=oPOSCOMANDA:COM_CODIGO
   LOCAL nCantid:=oPOSCOMANDA:COM_CANTID
   LOCAL cCodVen:=oPOSCOMANDA:COM_MESERO
   LOCAL cMesa  :=oPOSCOMANDA:COM_MESA
   LOCAL cCodEqu:="",lNew:=.T.,cItem:=""
   

   IF Empty(cCodInv)
      cCodInv:=oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,1]
      nCantid:=oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,6]
      cCodVen:=oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,4]
      cMesa  :=oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,3]
      cItem  :=oPOSCOMANDA:oBrw:aArrayData[oPOSCOMANDA:oBrw:nArrayAt,7]
      lNew:=.F.
   ENDIF

   oPOSCOMANDA:cCodInvCom:=cCodInv
   oPOSCOMANDA:cCodVenCom:=cCodVen
   oPOSCOMANDA:cMesaCom  :=cMesa  

   oPOSCOMANDA:aComponente:=EJECUTAR("DPPOSINVCOMP",cCodInv,cCodEqu,nCantid,lEdit,oPOSCOMANDA:aComponente,cItem)

   IF !Empty(cItem)
      oPOSCOMANDA:cItemCom:=cItem
      oPOSCOMANDA:SAVECOMP(3)
      oPOSCOMANDA:cItemCom:=""
   ENDIF

   // Aqui debe Grabar los Componentes

RETURN .T.

FUNCTION SAVECOMP(nOption)
  LOCAL oTable,aData,I,cLpt,cDescri,cItem

  DEFAULT nOption:=oPOSCOMANDA:nOption

  IF nOption<>1 // Modificar

    SQLDELETE("DPPOSCOMANDA","COM_ITEM_A"+GetWhere("=",oPOSCOMANDA:cItemCom)+" AND "+;
                             "COM_TIPO='C'")

  ENDIF

  oTable:=OpenTable("SELECT * FROM DPPOSCOMANDA" , .F.)  
  aData:=ACLONE(oPOSCOMANDA:aComponente)

  FOR I=1 TO LEN(aData)

    cItem:=SQLINCREMENTAL("DPPOSCOMANDA","COM_ITEM")
    oTable:Append()

    cLpt   :=MYSQLGET("DPINV","INV_LPT","INV_CODIGO"+GetWhere("=",aData[I,1]))
    cLpt   :=IIF(Empty(cLpt),oDp:cImpCmd,cLpt)

    cLpt   :=oPOSCOMANDA:COM_LPT  // AQUI TOMA EL LPT DEL PADRE

    oTable:Replace("COM_MESA"  ,oPOSCOMANDA:cMesaCom  )
    oTable:Replace("COM_MESERO",oPOSCOMANDA:cCodVenCom)
    oTable:Replace("COM_CODIGO",aData[I,1])
    oTable:Replace("COM_DESCRI",aData[I,2])
    oTable:Replace("COM_UNDMED",aData[I,3])
    oTable:Replace("COM_CANTID",aData[I,4])
    oTable:Replace("COM_COMENT",aData[I,5])
    oTable:Replace("COM_PRECIO",0         )
    oTable:Replace("COM_USUARI",oDp:cUsuario)
    oTable:Replace("COM_TIPO"  ,"C"       )
    oTable:Replace("COM_LLEVAR",oPOSCOMANDA:lDely   )
    oTable:Replace("COM_ITEM"  ,cItem     )
    oTable:Replace("COM_ITEM_A",oPOSCOMANDA:cItemCom) // Item Asociado
    oTable:Replace("COM_LPT"   ,cLpt      )
    oTable:Replace("COM_IMPRES",.F.       )
    oTable:Replace("COM_RIF"   ,oPOSCOMANDA:cRif   )
    oTable:Replace("COM_PEDIDO",oPOSCOMANDA:cPedido)
    oTable:Replace("COM_MTOIVA",0                  )

    oTable:Commit()

  NEXT I

  oTable:End()

RETURN .T.

FUNCTION PRINTCMD(cMesa)
   LOCAL cWhere,cText

   DEFAULT cMesa:=oPOSCOMANDA:COM_MESA

   cWhere:="COM_MESA"+GetWhere("=",cMesa)

   IF oPOSCOMANDA:lDely
    cText:=" Pedido: "+oPOSCOMANDA:cPedido
   ELSE
     cText:="Mesa : "+cMesa
   ENDIF


   IF !MsgYesNo("Desea Imprimir "+cText,"Seleccione una Opción")

      cWhere:=IIF(oPOSCOMANDA:lDely ,"COM_PEDIDO"+GetWhere("=",oPOSCOMANDA:cPedido),cWhere)
      SQLUPDATE("DPPOSCOMANDA","COM_IMPRES",.T.,cWhere)
      RETURN .T.
   ENDIF

   IF !Empty(cMesa) .AND. ISDIGIT(cMesa)
      cMesa:=STRZERO(VAL(cMesa),LEN(cMesa))
   ENDIF

   IF oPOSCOMANDA:lDely

     EJECUTAR("DPPOSDELYTRA",oPOSCOMANDA) 
     EJECUTAR("DPPOSDELYPRN",oPOSCOMANDA:cPedido) 
     EJECUTAR("DPPOSDELINEW",oPOSCOMANDA) // Nueva Sección

   ELSE

//     ? "DEBE IMPRIMIR ESTA MESA",cMesa

     EJECUTAR("DPPOSCOMMPRN",cMesa) 

   ENDIF

RETURN .T.

FUNCTION VALCODCLI()
  LOCAL lResp:=.T.

  IF ALLTRIM(oPOSCOMANDA:cRif )="0"


     oPOSCOMANDA:oCOM_CODIGO:ForWhen()

     DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)
     oPOSCOMANDA:cMunici:="Barra"

     ComboIni(oPOSCOMANDA:oMuni)
     oPOSCOMANDA:BUILDMUNI()

     RETURN .T.

  ENDIF

  lResp:=EJECUTAR("DPPOSCOMVALCLI")

  IF lResp .AND. !Empty(oPOSCOMANDA:cNombre)

     oPOSCOMANDA:oCOM_CODIGO:ForWhen()
     DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)

  ENDIF

RETURN lResp

FUNCTION NUMPEDIDO()
  LOCAL oData,cPedido

  oPOSCOMANDA:COM_PEDIDO:=oPOSCOMANDA:cPedido

  IF !VAL(oPOSCOMANDA:cPedido)=0 .OR. !oPOSCOMANDA:lDely
     RETURN .T.
  ENDIF

  oPOSCOMANDA:cPedido:=SQLINCREMENTAL("DPPOSCOMANDA","COM_PEDIDO","COM_LLEVAR=1")

//? oPOSCOMANDA:cPedido,VALTYPE(oPOSCOMANDA:cPedido)

  oData:=DATASET("POSDELI"+DTOS(oDp:dFecha),"USER",,,oDp:cUsuario)

  cPedido:=oData:Get("PEDIDO"   , oPOSCOMANDA:cPedido )

//? cPedido,VALTYPE(cPedido),"cPedido"
//  IF Val(oPOSCOMANDA:cPedido)=1
//
//    oPOSCOMANDA:cPedido:=SQLINCREMENTAL("DPDOCCLI","DOC_FACAFE","DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
//                                                                "DOC_DOCORG='P' AND "+;
//                                                                "DOC_FECHA "+GetWhere("=",oDp:dFecha))
//  ENDIF

  oPOSCOMANDA:cPedido   :=IIF(cPedido>oPOSCOMANDA:cPedido,cPedido,oPOSCOMANDA:cPedido)
  oPOSCOMANDA:COM_PEDIDO:=oPOSCOMANDA:cPedido

  oData:Set("PEDIDO" , STRZERO( VAL(oPOSCOMANDA:cPedido)+1,LEN(oPOSCOMANDA:cPedido)))

  oData:End(.T.)
  oPOSCOMANDA:oPedido:Refresh(.T.)

RETURN .T.

FUNCTION CALTOTAL(lIni)
   LOCAL nTotal:=0

   DEFAULT lIni:=.F.

   IF !oPOSCOMANDA:lDely 
      RETURN .F.
   ENDIF

   IF Empty(oPOSCOMANDA:COM_PEDIDO)
      oPOSCOMANDA:oBrw:aCols[3]:cFooter      :=TRAN(nTotal,"99,999,999,999.99")
      oPOSCOMANDA:oBrw:Refresh(.F.)
      RETURN .T.
   ENDIF

   nTotal:=MYSQLGET("DPPOSCOMANDA","SUM((COM_PRECIO*COM_CANTID)+COM_MTOIVA)",;
                    "COM_PEDIDO"+GetWhere("=",oPOSCOMANDA:COM_PEDIDO))+;
           oPOSCOMANDA:nTarifa

   oPOSCOMANDA:oBrw:aCols[3]:cFooter      :=TRAN(nTotal,"99,999,999,999.99")
   oPOSCOMANDA:oBrw:Refresh(.F.)

  IF oPOSCOMANDA:oZona:nAt=1 .AND. lIni
     oPOSCOMANDA:oDirE1:VarPut(SPACE(40),.T.)
     oPOSCOMANDA:oDirE2:VarPut(SPACE(40),.T.)
     oPOSCOMANDA:oDirE3:VarPut(SPACE(40),.T.)
  ENDIF

RETURN .T.

FUNCTION NEXTDIR(nStep)

   oPOSCOMANDA:nDir:=oPOSCOMANDA:nDir+nStep

   IF oPOSCOMANDA:nDir>LEN(oPOSCOMANDA:aDirE)
      oPOSCOMANDA:nDir:=1
   ENDIF

   IF oPOSCOMANDA:nDir<1
     oPOSCOMANDA:nDir:=LEN(oPOSCOMANDA:aDirE)
   ENDIF

   oPOSCOMANDA:oDirE1:VarPut(oPOSCOMANDA:aDirE[oPOSCOMANDA:nDir,1],.T.)
   oPOSCOMANDA:oDirE2:VarPut(oPOSCOMANDA:aDirE[oPOSCOMANDA:nDir,2],.T.)
   oPOSCOMANDA:oDirE3:VarPut(oPOSCOMANDA:aDirE[oPOSCOMANDA:nDir,3],.T.)

   // Teléfono del Pedido
   oPOSCOMANDA:oTel2:VarPut(oPOSCOMANDA:aDirE[oPOSCOMANDA:nDir,6],.T.)

RETURN .T.

/*
// Construye Zonas
*/
FUNCTION BUILDMUNI()

  LOCAL aZona:={}

  AEVAL(oPOSCOMANDA:aDataZona,{ |a,n| IIF( a[3]==oPOSCOMANDA:cMunici , AADD(aZona,a[1]) , NIL )})

  oPOSCOMANDA:oZona:SetItems(aZona)

  COMBOINI(oPOSCOMANDA:oZona)

  oPOSCOMANDA:CALTARIFA()
  oPOSCOMANDA:oZona:ForWhen(.T.)

RETURN .T.

FUNCTION CALTARIFA()

  LOCAL nAt:=ASCAN(oPOSCOMANDA:aDataZona,{ |a,n| a[3]==oPOSCOMANDA:cMunici .AND. a[1]==oPOSCOMANDA:cZona })

  oPOSCOMANDA:nTarifa:=iif(nAt=0 , 0, oPOSCOMANDA:aDataZona[nAt,2] )
  oPOSCOMANDA:CALTOTAL()
  oPOSCOMANDA:oZonaSay:Refresh(.T.)

RETURN .T.

FUNCTION Abrevia()

  LOCAL oDpLbx

  oDpLbx:=DpLbx("DPABREVIATURAS",)
  oDpLbx:GetValue("ABR_TEXTO",oPOSCOMANDA:oCOM_COMENT)

RETURN .T.
  


/*
<LISTA:COM_CODIGO:N:BMPGETL:N:N:Y:Producto,COM_MESERO:N:BMPGETL:N:N:Y:Mesero,COM_MESA:N:GET:N:N:Y:Mesa,COM_CANTID:N:GET:N:N:Y:Cantidad
>
*/


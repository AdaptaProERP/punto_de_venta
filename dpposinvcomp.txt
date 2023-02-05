// Programa   : DPPOSINVCOMP
// Fecha/Hora : 26/01/2005 23:10:42
// Propósito  : Productos Compuestos en Facturacion
// Creado Por : Juan Navas
// Llamado por: VENTAS
// Aplicación : Ventas
// Tabla      : DPINVMED

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodInv,cCodEqui,nCantid,lEdit,aData,cItem)
  LOCAL I,cSql,cTitle:=GETFROMVAR("{oDp:DPCOMPONENTES}"),cWhere,aOrg:={},aEnviar:={}
  LOCAL oFontBrw,oFontB,oBrush,oDlg,oCol,oBtn,oBrw
  LOCAL cFileBmp,cGrupo:="",cCodigo:=""
  LOCAL nTop:=180,nLeft:=1,nWidth:=485+290,nHeight:=358,I
  LOCAL nClrPane1:=16774636
  LOCAL lSelect:=.F.,nBtnAlto:=50
  LOCAL aMarcados:={},nCapTotal:=0
  LOCAL nNuevos  :=0 // Cantidad Ingresada por Sustitutos

  DEFAULT cCodInv:="153",cCodEqui:="",nCantid:=1,lEdit:=.T.

  cWhere:="CPT_CODIGO"+GetWhere("=",cCodInv)

  IF !Empty(cItem) // Modificamos el Item

    cSql :=" SELECT COM_CODIGO,COM_DESCRI,COM_UNDMED,COM_CANTID,COM_COMENT, 0 AS FIJO,0 AS ALTERNA,0 AS SUSTIT "+;
           " FROM DPPOSCOMANDA "+;
           " INNER JOIN DPINV ON INV_CODIGO=COM_CODIGO "+;
           " WHERE COM_ITEM_A"+GetWhere("=",cItem)+" AND "+;
           " COM_TIPO='C'"

    aData:=ASQL(cSql)

    AEVAL(aData,{|a,n|aData[n,6]:=.T.,;
                      aData[n,7]:=.T.,;
                      aData[n,8]:=.F. })

  ENDIF

  IF !Empty(cCodEqui)
     cWhere:=cWhere+" AND "+"CPT_CODEQU"+GetWhere("=",cCodEqui)
     cTitle:=cTitle+" / "+cCodEqui
  ENDIF

  IF !lEdit
     cWhere:=cWhere+" AND CPT_FIJO=1"
  ENDIF

// DEFINE FONT oFontB NAME "Times New Roman"   SIZE 0, -12 BOLD
// DEFINE FONT oFont  NAME "Times New Roman"   SIZE 0, -12 

  IF Empty(aData)

    cSql :=" SELECT CPT_COMPON,INV_DESCRI,CPT_UNDMED,CPT_CANTID"+;
           +GetWhere("*",nCantid)+" AS CPT_CANTID "+;
           ",CPT_CODEQU,CPT_FIJO,CPT_ALTERN,0 AS SUSTIT "+;
           " FROM DPCOMPONENTES "+;
           " INNER JOIN DPINV ON INV_CODIGO=CPT_COMPON "+;
           " WHERE "+cWhere

// ? CLPCOPY(cSql)

    aData:=ASQL(cSql)

    IF Empty(aData)
       RETURN {}
    ENDIF

    AEVAL(aData,{|a,n|aData[n,5]:=SPACE(40),;
                      aData[n,7]:=IIF(!aData[n,6] , .T. , aData[n,7]),;
                      aData[n,8]:=.F. })

  ENDIF

  IF !lEdit

    // ? "AQUI SOLO LEE"
    RETURN aData

    // Aqui Devuelve los Componentes
  ENDIF

  aOrg :=ACLONE(aData)
  AEVAL(aData,{|a,n|nCapTotal:=nCapTotal+a[4]})

  DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0, -12 BOLD
  DEFINE FONT oFontB   NAME "MS Sans Serif" SIZE 0, -10 BOLD

  DEFINE DIALOG oDlg TITLE cTitle

  oDlg:lHelpIcon:=.F.

  oBrw:=TXBrowse():New(oDlg )
  oBrw:SetArray( aData ,.F.)
  oBrw:lHScroll  := .F.
  oBrw:lVScroll  := .T.
  oBrw:nFreeze   := 1
  oBrw:oFont     := oFontBrw
  oBrw:nDataLines:= 1
  oBrw:lFooter   := .T.
  oBrw:lHeader   := .T.

  oCol:=oBrw:aCols[1]
  oCol:cHeader:="Código"
  oCol:nWidth :=90

  oCol:=oBrw:aCols[2]
  oCol:cHeader:="Descripción"
  oCol:nWidth :=260

  oCol:=oBrw:aCols[3]
  oCol:cHeader:="Unidad"
  oCol:nWidth :=55

//  oCol:nDataStrAlign:= AL_RIGHT
//  oCol:nHeadStrAlign:= AL_RIGHT
//  oCol:nFootStrAlign:= AL_RIGHT


  oCol:=oBrw:aCols[4]  
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:cHeader      :="Cantidad"
  oCol:nWidth       :=70
  oCol:bStrData     :={|nMonto|nMonto:=oBrw:aArrayData[oBrw:nArrayAt,4],;
                                TRAN(nMonto,oDp:cPictCanUnd)}

  oCol:bOnPostEdit :={|oCol,uValue|PUTCANTID(oCol,uValue)}
  oCol:nEditType   :=0 // 1
  oCol:cEditPicture:=oDp:cPictCanUnd
  oCol:cFooter     :=TRAN(nCapTotal,oDp:cPictCanUnd)

  oCol:=oBrw:aCols[5]
  oCol:cHeader    :="Comentarios"
  oCol:nWidth     :=195
  oCol:bOnPostEdit:={|oCol,uValue|PUTDESCRI(oCol,uValue)}
  oCol:nEditType  :=1

  oCol:=oBrw:aCols[6]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||IIF(oBrw:aArrayData[oBrw:nArrayAt,6],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||InvMarcar()}

  oCol:=oBrw:aCols[7]
  oCol:cHeader      := "Alt"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||IIF(oBrw:aArrayData[oBrw:nArrayAt,7],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)

//  oCol:bLDClickData:={||InvMarcar()}
//  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oFrmSelPrg:ChangeAllImp(oFrmSelPrg,nRow,nCol,nKey,oCol,.T.)}

  oBrw:bClrStd      := {|nClrPane1|{IIF(oBrw:aArrayData[oBrw:nArrayAt,6],CLR_HBLUE,CLR_GRAY),;
                                   nClrPane1:=IIF(!oBrw:aArrayData[oBrw:nArrayAt,7],65535,16770764),;
                           IIF( oBrw:nArrayAt%2=0,nClrPane1,16774636 ) } }

  oBrw:bClrHeader   := {||{CLR_YELLOW,16764315}}

// oBrw:bLDblClick   := {||lSelect:=.T.,oDlg:End()}
// oBrw:bLDblClick   := {||SelProducto()}
// oBrw:bKeyDown     := {|nKey| oBrw:nLastKey:=nKey,;
//                              IIF( nKey=13,oDlg:End(),NIL) }

  oBrw:bLDblClick   := {||SUSTITUTOS()}

  oBrw:CreateFromCode()

  ACTIVATE DIALOG oDlg ON INIT (oDlg:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                oBrw:Move(nBtnAlto,0,nWidth-5,nHeight-084,.T.),;
                                ViewDatBar(),;
                                oBrw:SetColor(NIL,nClrPane1))
 

//   oCol:=oBrw:aCols[2]
//   oCol:End()

//  ViewArray(aMarcados)

RETURN aMarcados


/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
//   LOCAL oDlg:=oInvSld:oDlg

   oBrw:Gotop(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 45,50 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP";
          ACTION ACEPTARCOMP()

   oBtn:cToolTip:="Grabar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SUSTITUTOS.BMP";
          ACTION SUSTITUTOS()

   oBtn:cToolTip:="Sustitutos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oBrw:GoTop(),oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oBrw:PageDown(),oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oBrw:PageUp(),oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oBrw:GoBottom(),oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDlg:End()

  oBrw:SetColor(0,16773862)

  @ 0.1,66 SAY " "+cCodInv+" "+MYSQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",cCodInv)) OF oBar BORDER SIZE 345,18
  @ 1.4,66 SAY " Cantidad "+LSTR(nCapTotal)+" Componente(s)" OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.



/*
// Busca la Foto
*/
FUNCTION FindPosBmp()
  LOCAL nAt:=oBrw:nArrayAt
RETURN nAt

FUNCTION SELPRODUCTO()
/*
   LOCAL cGrupo:=oBrw:aArrayData[oBrw:nArrayAt,1],cTitle:="",oCol

   CursorWait()

   cTitle:=GetFromVar("{oDp:xDPGRU}")+" "+cGrupo+" "+;
           ALLTRIM(SQLGET("DPGRU","GRU_DESCRI","GRU_CODIGO"+GetWhere("=",cGrupo)))

   cCodigo:=EJECUTAR("GRIDSELINV","WHERE INV_GRUPO"+GetWhere("=",cGrupo),cGrupo,cTitle)

   IF ValType(oGrid)="O" .AND. "GET"$oGrid:ClassName() .AND. !Empty(cCodigo)
     oGrid:VarPut(cCodigo,.T.)
     oDlg:End()
     DPFOCUS(oGrid)
     RETURN .T.
   ENDIF

   IF ValType(oGrid)="O" .AND. !Empty(cCodigo)
     oCol:=oGrid:GetCol("MOV_CODIGO")
     oCol:VarPut(cCodigo)
     oDlg:End()
     DPFOCUS(oGrid:oBrw)
   ENDIF
*/
  INVMARCAR()
RETURN .T.

/*
//
*/
FUNCTION ACEPTARCOMP()
  LOCAL I,aData:=oBrw:aArrayData,nAt
  LOCAL aFijos:=ACLONE(aOrg),I,aNuevos:={},aQuitar:={},nSobra:=0
  LOCAL cSql,cWhere:=""
  LOCAL aTotal:=ATOTALES(aData)

  IF aTotal[4]>nCapTotal .AND. .F.

     MensajeErr("Capacidad "+LSTR(nCapTotal)+" del Producto ha sido Excedida"+CRLF+;
                "en "+LSTR(aTotal[4]-nCapTotal)+" Cantidad(es) ")

     RETURN .F.

  ENDIF

  FOR I=1 TO LEN(aFijos)

     IF !aFijos[I,6]
       ARREDUCE(aFijos,I)
       I:=1
     ENDIF

  NEXT I

  // Obtiene los Nuevos
  FOR I=1 TO LEN(aData)

     // Busca los Nuevos
     nAt:=ASCAN(aFijos,{|a,n|a[1]=aData[I,1]})
     IF nAt=0 .AND. aData[I,6]
       AADD(aNuevos,aData[I])
     ENDIF

     // Busca los Eliminados
     nAt:=ASCAN(aFijos ,{|a,n|a[1]=aData[I,1]})
     IF nAt>0 .AND. !aData[I,6]
       AADD(aQuitar,aData[I])
     ENDIF

     IF aData[I,6]
       AADD(aMarcados,aData[I])
     ENDIF

  NEXT I

  nSobra:=LEN(aNuevos)-LEN(aQuitar)

  FOR I=1 TO LEN(aNuevos)
     cWhere:=cWhere+ IIF(Empty(cWhere),""," OR ")+;
             " (PRE_CODIGO"+GetWhere("=",aNuevos[I,1])+" AND PRE_UNDMED"+GetWhere("=",aNuevos[I,3])+")"
  NEXT I

  cWhere:="PRE_LISTA "+GetWhere("=",oDp:cPrecioPos        )+" AND "+;
          "PRE_CODMON"+GetWhere("=",oDp:cCodMonPos        )+" AND ("+cWhere+")"

//? cWhere
//  ? "FIJOS",LEN(aFijos),"NUEVOS",LEN(aNuevos),"REMOVIDOS",LEN(aQuitar),nSobra

  // Los productos Sobrados deben ser los Más Costosos
  // y deben ser facturados en forma Separada
  // Buscamos los precios de los Nuevos 

  cSql:="SELECT PRE_CODIGO,PRE_PRECIO FROM DPPRECIOS WHERE "+cWhere

//  ? CLPCOPY(cSql)

  aEnviar:={aFijos,aNuevos,aQuitar}

/*
   nPrecio:=SQLGET("DPPRECIOS","PRE_PRECIO","PRE_CODIGO"+GetWhere("=",oPOSCOMANDA:COM_CODIGO)+" AND "+;
                                            "PRE_UNDMED"+GetWhere("=",oPOSCOMANDA:COM_UNDMED)+" AND "+;
                                            "PRE_LISTA "+GetWhere("=",oDp:cPrecioPos        )+" AND "+;
                                            "PRE_CODMON"+GetWhere("=",oDp:cCodMonPos        ))


*/


 oDlg:End()

RETURN .T.

/*
// Marcar Productos
*/
FUNCTION INVMARCAR()

   LOCAL nTotal:=0,nAt:=oBrw:nArrayAt

   IF !oBrw:aArrayData[oBrw:nArrayAt,7]
      RETURN .F.
   ENDIF

   oBrw:aArrayData[oBrw:nArrayAt,6]:=!oBrw:aArrayData[oBrw:nArrayAt,6]

   CALTOTAL()

RETURN .T.

/*
// Carga de Sustitutos
*/
FUNCTION SUSTITUTOS()
   LOCAL cCodInv:=oBrw:aArrayData[oBrw:nArrayAt,1]
   LOCAL nCantid:=oBrw:aArrayData[oBrw:nArrayAt,4]
   LOCAL nTotal :=0
   LOCAL nAt    :=oBrw:nArrayAt

   LOCAL aData:={}

   EJECUTAR("DPPOSEQUIV",cCodInv,nCantid,oBrw)

   CALTOTAL()

RETURN .T.

FUNCTION PUTDESCRI(oCol,cDescri)

  oBrw:aArrayData[oBrw:nArrayAt,5]:=cDescri
  oBrw:DrawLine(.T.)

RETURN .T.

FUNCTION PUTCANTID(oCol,nCantid)

  LOCAL aTotal:={},nAt:=oBrw:nArrayAt
  LOCAL nTotal:=0

  IF nCantid=0
     oBrw:aArrayData[oBrw:nArrayAt,6]:=.F.
  ELSE
     oBrw:aArrayData[oBrw:nArrayAt,6]:=.T.
  ENDIF
  
  oBrw:aArrayData[oBrw:nArrayAt,4]:=nCantid

  CALTOTAL()

RETURN .T.

FUNCTION CALTOTAL()

   LOCAL nTotal:=0
   LOCAL nAt   :=oBrw:nArrayAt

   AEVAL(oBrw:aArrayData,{|a,n| nTotal:=nTotal + IIF( a[6], a[4], 0 ) })
  
   oBrw:aCols[4]:cFooter:=TRAN(nTotal,oDp:cPictCanUnd)
   oBrw:nArrayAt:=nAt
   oBrw:Refresh(.F.)
   oBrw:nArrayAt:=nAt

RETURN .T.
// EOF


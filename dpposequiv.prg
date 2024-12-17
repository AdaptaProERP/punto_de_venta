// Programa   : DPPOSEQUIV
// Fecha/Hora : 21/09/2006 12:11:02
// Propósito  : Lectura de Equivalentes para Cambio de Contornos
// Creado Por : Juan Navas
// Llamado por: DPPOSINVCOMP
// Aplicación : Ventas
// Tabla      : DPINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN( cCodInv , nCantid , oBrw)

  LOCAL I,cSql,cTitle:=GETFROMVAR("{oDp:DPSUSTITUTOS}"),cWhere
  LOCAL oFontBrw,oFontB,oBrush,oDlgS,oCol,oBtn,oBrwS
  LOCAL cFileBmp
  LOCAL nTop:=180,nLeft:=1,nWidth:=485+40+30,nHeight:=358,I
  LOCAL nClrPane1:=14613246
  LOCAL lSelect:=.F.,nBtnAlto:=50,nTotal:=0,nItems:=0
  LOCAL nCapTotal:=0,aDatas:={}
  LOCAL nCantGet,oCantid,oFontGet

  DEFAULT cCodInv:="BM",;
          nCantid:=2

  nCantGet:=nCantid
  cCodInv :=ALLTRIM(cCodInv)
  cWhere  :="SUS_CODIGO"+GetWhere("=",cCodInv)

  cSql :=" SELECT SUS_SUSTIT,INV_DESCRI,SUS_UNDMED,SUS_CANTID,0 AS CERO "+;
         " FROM DPSUSTITUTOS "+;
         " INNER JOIN DPINV ON INV_CODIGO=SUS_SUSTIT "+;
         " WHERE "+cWhere

  aDataS:=ASQL(cSql)

  IF Empty(aDataS)
     RETURN {}
  ENDIF

  AEVAL(aDataS,{|a,n|aDataS[n,5]:=.F.})

  cTitle:=cTitle+": "+cCodInv+" / "+MYSQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",cCodInv))

  DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0, -12 BOLD
  DEFINE FONT oFontB   NAME "MS Sans Serif" SIZE 0, -10 BOLD
  DEFINE FONT oFontGet NAME "MS Sans Serif" SIZE 0, -14 BOLD

  DEFINE DIALOG oDlgS TITLE cTitle

  oDlgS:lHelpIcon:=.F.

  oBrwS:=TXBrowse():New(oDlgS )
  oBrwS:SetArray( aDataS ,.F.)
  oBrwS:lHScroll  := .F.
  oBrwS:lVScroll  := .T.
  oBrwS:nFreeze   := 1
  oBrwS:oFont     := oFontBrw
  oBrwS:nDataLines:= 1
  oBrwS:lFooter   := .T.
  oBrwS:lHeader   := .T.

  oCol:=oBrwS:aCols[1]
  oCol:cHeader:="Código"
  oCol:nWidth :=90

  oCol:=oBrwS:aCols[2]
  oCol:cHeader:="Descripción"
  oCol:nWidth :=260+IIF(nCantid=1,30,0)

  oCol:=oBrwS:aCols[3]
  oCol:cHeader:="Unidad"
  oCol:nWidth :=55

  oCol:=oBrwS:aCols[4]  
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:cHeader      :="Cantidad"
  oCol:nWidth       :=70
  oCol:bStrData     :={|nMonto|nMonto:=oBrwS:aArrayData[oBrwS:nArrayAt,4],;
                                TRAN(nMonto,oDp:cPictCanUnd)}

  oCol:cFooter:=TRAN(0,oDp:cPictCanUnd)


  oCol:bOnPostEdit :={|oCol,uValue|PUTCANTID(oCol,uValue)}
  oCol:nEditType   :=0 
  oCol:cEditPicture:=oDp:cPictCanUnd

  IF nCantid!=1

    oCol:=oBrwS:aCols[5]
    oCol:cHeader      := "Ok"
    oCol:nWidth       := 25
    oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
    oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
    oCol:bBmpData    := { ||IIF(oBrwS:aArrayData[oBrwS:nArrayAt,5],1,2) }
    oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
    oCol:bLDClickData:={||InvMarcar()}

//    oBrwS:DelCol(5)

  ENDIF

  oBrwS:bClrStd      := {|nClrPane|nClrPane:= IIF(oBrwS:aArrayData[oBrwS:nArrayAt,5],CLR_BLACK,CLR_GRAY) , { nClrPane ,;
                                     IIF( oBrwS:nArrayAt%2=0 , 11595007 , 14613246 ) } }

  oBrwS:bClrHeader   := {||{20736,2213114}}

  oBrwS:bLDblClick   := {||InvMarcar()}

  oBrwS:CreateFromCode()

  ACTIVATE DIALOG oDlgS ON INIT (oDlgS:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                oBrwS:Move(nBtnAlto,0,nWidth-5,nHeight-084,.T.),;
                                ViewDatBar(),;
                                oCantid:SetColor(0,CLR_WHITE),;
                                oBrwS:SetColor(NIL,nClrPane1))
 
RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas

   oBrwS:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 45,50 OF oDlgS 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP";
          ACTION ACEPTARSUST()

   oBtn:cToolTip:="Grabar"

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SUSTITUTOS.BMP";
          ACTION SUSTITUTOS()

   oBtn:cToolTip:="Sustitutos"

*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oBrwS)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oBrwS:GoTop(),oBrwS:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oBrwS:PageDown(),oBrwS:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oBrwS:PageUp(),oBrwS:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oBrwS:GoBottom(),oBrwS:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDlgS:End()

  oBrwS:SetColor(0,4252415)

  @ 0.5,52 GET oCantid VAR nCantGet OF oBar;
           PICTURE oDp:cPictCanUnd;
           SIZE 70,24 RIGHT;
           SPINNER FONT oFontGet;
           VALID nCantGet>0 .AND. nCantGet<=nCantid

  IF nCantGet=1
    oCantid:Disable()
  ENDIF

  @ .5,58 SAY "Cantidad:" OF oBar;
           SIZE 64,24 RIGHT

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  CALTOTAL()

RETURN .T.

/*
// Busca la Foto
*/
FUNCTION FindPosBmp()
  LOCAL nAt:=oBrwS:nArrayAt
RETURN nAt

FUNCTION SELPRODUCTO()
RETURN .T.

/*
// Aceptar Sustitutos
*/
FUNCTION ACEPTARSUST()

  LOCAL nMenos:=nCantid-nCantGet,nAt,cCod,lDel:=.F.,I
  LOCAL lDelete:=.F.

  CALTOTAL()

  IF nItems>nCantGet
     MensajeErr("Cantidad de Items Seleccionados Supera la Cantidad para Reemplazar")
     RETURN .T.
  ENDIF

  IF ValType(oBrw)!="O"
     RETURN .F.
  ENDIF

  IF !(nMenos>0)

    // Aqui Quita el Producto
    ARREDUCE(oBrw:aArrayData,oBrw:nArrayAt)
    oBrw:nArrayAt:=1
    oBrw:Refresh(.T.)

  ELSE

    oBrw:aArrayData[oBrw:nArrayAt,4]:=oBrw:aArrayData[oBrw:nArrayAt,4]-nMenos

  ENDIF

  FOR I=1 TO LEN(oBrwS:aArrayData)

    IF oBrwS:aArrayData[I,5]
       PREPARAR(I)
    ENDIF

  NEXT I

  oDlgS:End()

RETURN .T.

/*
// Prepara los Componentes
*/
FUNCTION PREPARAR(nAtBrw)

//LOCAL nSust:=nCantid*oBrwS:aArrayData[nAtBrw,4]
  LOCAL nSust:=oBrwS:aArrayData[nAtBrw,4]
  LOCAL cCod :=oBrwS:aArrayData[nAtBrw,1]
  LOCAL nAtxBrw

  IF nItems=1 .AND. nCantGet>1
     nSust:=nSust*nCantGet
  ENDIF

  nAt:=ASCAN(oBrw:aArrayData,{|a,n|a[1]=cCod} )

  IF nAt=0

    // Sera Agregado el Nuevo Componente
    nAtxBrw:=oBrw:nArrayAt

    AADD(oBrw:aArrayData,{cCod,oBrwS:aArrayData[nAtBrw,2],oBrwS:aArrayData[nAtBrw,3],nSust,SPACE(40),.T.,.F.,.T.})

    oBrw:nArrayAt:=nAtxBrw
    oBrw:Refresh(.T.)

  ELSE

    oBrw:aArrayData[nAt,4]:=oBrw:aArrayData[nAt,4]+nSust
    oBrw:DrawLine(.T.)

  ENDIF

RETURN .T.

/*
// Marcar Productos
*/
FUNCTION INVMARCAR()
RETURN .T.

/*
// Carga de Sustitutos
*/
FUNCTION SUSTITUTOS()
   LOCAL cCodInv:=oBrwS:aArrayData[oBrwS:nArrayAt,1]
   LOCAL nCantid:=oBrwS:aArrayData[oBrwS:nArrayAt,4]

   LOCAL aDataS:={}

   EJECUTAR("DPPOSEQUIV",cCodInv,nCantid,oBrwS)

//   ? "AQUI LEE LOS SUSTITUTOS",cCodInv

RETURN .T.

FUNCTION PUTDESCRI(oCol,cDescri)

  oBrwS:aArrayData[oBrwS:nArrayAt,5]:=cDescri
  oBrwS:DrawLine(.T.)

RETURN .T.

/*
// Marcar Productos
*/
FUNCTION INVMARCAR()

   LOCAL nTotal:=0,nAt:=oBrwS:nArrayAt

   oBrwS:aArrayData[oBrwS:nArrayAt,5]:=!oBrwS:aArrayData[oBrwS:nArrayAt,5]

   CALTOTAL()

RETURN .T.

FUNCTION CALTOTAL()

   LOCAL nAt   :=oBrwS:nArrayAt

   nTotal:=0
   nItems:=0

   AEVAL(oBrwS:aArrayData,{|a,n| nTotal:=nTotal + IIF( a[5] , a[4], 0 ) ,;
                                 nItems:=nItems + IIF( a[5] , 1   , 0 ) })
  
   oBrwS:aCols[4]:cFooter:=TRAN(nTotal,oDp:cPictCanUnd)
   oBrwS:nArrayAt:=nAt
   oBrwS:Refresh(.F.)
   oBrwS:nArrayAt:=nAt

RETURN .T.
// EOF



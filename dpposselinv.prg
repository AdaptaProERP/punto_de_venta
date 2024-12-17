// Programa   : DPPOSSELINV	
// Fecha/Hora : 05/11/2005 09:12:14
// Propósito  : Seleccionar Productos
// Creado Por : Juan Navas
// Llamado por: DPPOSSELGRU
// Aplicación : Ventas
// Tabla      : DPGRU/DPMARCAS

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cGrupo,cTitle)
  LOCAL oBrw,oDlg,aBancos:={},oFontBrw,oCol,oFontB,oBtn,oBrush,cFileBmp,cCodigo
  LOCAL nTop:=180,nLeft:=1,nWidth:=485,nHeight:=358,I
  LOCAL nClrPane1:=16774636
  LOCAL lSelect:=.F.,cBanco:="",aData,nBtnAlto:=25

  DEFAULT cGrupo:=STRZERO(1,6),;
          cWhere:="WHERE INV_GRUPO"+GetWhere("=",cGrupo),;
          cTitle:="PRODUCTOS POR GRUPO"

  aData:=ASQL("SELECT INV_DESCRI,INV_FILBMP,INV_CODIGO FROM DPINV "+cWhere+;
              "ORDER BY INV_CODIGO")

  IF EMPTY(aData)
     aData:={}
     AADD(aData,{"Ninguno","BITMAPS\PRODUCTO.BMP","Producto"})
  ENDIF

  AEVAL(aData,{|a,n|aData[n,1]:=a[1]+CRLF+a[3]})

  DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0, -12 BOLD
  DEFINE FONT oFontB   NAME "MS Sans Serif" SIZE 0, -10 BOLD

//  DEFINE DIALOG oDlg TITLE "Grupos de Productos";
//         COLOR NIL,oDp:nGris

  DEFINE BRUSH oBrush;
               FILE "BITMAPS\posselproductos.bmp"

  DEFINE DIALOG oDlg TITLE "Recibido";
         STYLE nOr( WS_POPUP, WS_VISIBLE );
         BRUSH oBrush

  @ 2.3,1 STSAY cTitle;
          SIZE 190,10;
          COLORS CLR_HRED FONT oFontB

  oDlg:lHelpIcon:=.F.

  oBrw:=TXBrowse():New(oDlg )
  oBrw:SetArray( aData ,.F.)
  oBrw:lHScroll  := .F.
  oBrw:lVScroll  := .T.
  oBrw:nFreeze   := 1
  oBrw:oFont     := oFontBrw
  oBrw:nDataLines:= 2
  oBrw:lFooter   := .F.
  oBrw:lHeader   := .T.

  oCol:=oBrw:aCols[1]
  oCol:cHeader:="Nombre"
  oCol:nWidth :=370

  oCol:=oBrw:aCols[2]
  oCol:cHeader:="Imagen"
  oCol:nWidth :=64

  FOR I=1 TO LEN(aData)
     cFileBmp:=ALLTRIM(aData[I,2])
     cFileBmp:=IF(Empty(cFileBmp),"BITMAPS\GRUPOS.BMP",cFileBmp)
     oCol:AddBmpFile(cFileBmp)
  NEXT I

  oCol:bBmpData    :={||FindPosBmp(oBrw)}
//  oCol:nDataStyle  := oCol:DefStyle( AL_BOTTOM, .F.)
  oCol:bStrData    := {||""} 
  oCol:nWidth :=64


  oBrw:bClrStd      := {||{CLR_BLUE, iif( oBrw:nArrayAt%2=0,16770764,16774636 ) } }
  oBrw:bClrHeader   := {||{CLR_YELLOW,16764315}}
  oBrw:bLDblClick   := {||lSelect:=.T.,oDlg:End()}
  oBrw:bKeyDown     := {|nKey| oBrw:nLastKey:=nKey,;
                               IIF( nKey=13,oDlg:End(),NIL) }

  oBrw:CreateFromCode()

   @ 06, 161 SBUTTON oBtn PIXEL;
            SIZE nBtnAlto,nBtnAlto FONT oFontB;
            NOBORDER;
            FILE "BITMAPS\BOTONUP.BMP";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION oBrw:GoUp()

    oBtn:cToolTip:="Subir"

   @ 06, 187 SBUTTON oBtn PIXEL;
            SIZE nBtnAlto,nBtnAlto FONT oFontB;
            NOBORDER;
            FILE "BITMAPS\BOTONDOWN.BMP";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION oBrw:GoDown()

   oBtn:cToolTip:="Bajar"


   @ 06, 213  SBUTTON oBtn PIXEL;
             SIZE nBtnAlto,nBtnAlto FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oDlg:End()

   oBtn:cToolTip:="Salir"


   ACTIVATE DIALOG oDlg ON INIT (oDlg:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                 oBrw:Move(20+(nBtnAlto*2),05,nWidth-10,nHeight-084,.T.),;
                                 oBrw:SetColor(NIL,nClrPane1))
 

   oCol:=oBrw:aCols[2]
   oCol:End()

   IF lSelect .OR. oBrw:nLastKey=13
     cCodigo:=oBrw:aArrayData[oBrw:nArrayAt,3]
   ENDIF

RETURN cCodigo

/*
// Busca la Foto
*/
FUNCTION FindPosBmp()
  LOCAL nAt:=oBrw:nArrayAt
RETURN nAt
// EOF




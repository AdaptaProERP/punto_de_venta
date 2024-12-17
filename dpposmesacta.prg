// Programa   : DPPOSMESACTA
// Fecha/Hora : 25/05/2006 05:46:51
// Propósito  : Cuenta por Mesa
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cMesa,oComanda)
  LOCAL oBrwC,oDlgC,aBancos:={},oFontBrw,oCol,oFontB,oBtn,oBrush,cFileBmp,cGrupo:="",cCodigo:=""
  LOCAL nTop:=90,nLeft:=1,nWidth:=685,nHeight:=418,I
  LOCAL nClrPane1:=16774636
  LOCAL lSelect:=.F.,cBanco:="",aDataC:={},nBtnAlto:=25
  LOCAL aTotal :={}
  LOCAL lRet   :=.F.

  DEFAULT cMesa:=STRZERO(1,3)

  aDataC:=ASQL(" SELECT COM_CODIGO,COM_DESCRI,COM_CANTID,COM_PRECIO,COM_PRECIO*COM_CANTID "+;
              " FROM DPPOSCOMANDA "+;
              " INNER JOIN DPINV ON COM_CODIGO=INV_CODIGO "+;
              " WHERE COM_MESA "+GetWhere("=",cMesa)+" AND COM_TIPO='P' "+;
              " ORDER BY COM_ITEM ")

//? CLPCOPY(oDp:cSql)

  IF Empty(aDataC)
     MensajeErr("No hay Cuentas por Mesa")
     RETURN ""
  ENDIF

  aTotal:=ATOTALES(aDataC)

  DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0, -12 BOLD
  DEFINE FONT oFontB   NAME "MS Sans Serif" SIZE 0, -10 BOLD

  DEFINE BRUSH oBrush;
               FILE "BITMAPS\dpposmesacta.bmp"

  DEFINE DIALOG oDlgC TITLE "Grupos";
         STYLE nOr( WS_POPUP, WS_VISIBLE );
         BRUSH oBrush

  oDlgC:lHelpIcon:=.F.

  oBrwC:=TXBrowse():New(oDlgC )
  oBrwC:SetArray( aDataC ,.T.)
  oBrwC:lHScroll  := .F.
  oBrwC:lVScroll  := .T.
  oBrwC:nFreeze   := 1
  oBrwC:oFont     := oFontBrw
  oBrwC:nDataLines:= 1
  oBrwC:lFooter   := .T.
  oBrwC:lHeader   := .T.

  oCol:=oBrwC:aCols[1]
  oCol:cHeader:="Código"
  oCol:nWidth :=70

  oCol:=oBrwC:aCols[2]
  oCol:cHeader:="Descripción"
  oCol:nWidth :=250

  oCol:=oBrwC:aCols[3]
  oCol:cHeader :="Cantidad"
  oCol:nWidth  :=090
  oCol:bStrData:={||TRAN(aDataC[oBrwC:nArrayAt,3],"99,999.99")}
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT

  oCol:=oBrwC:aCols[4]
  oCol:cHeader:="Precio"
  oCol:nWidth :=100
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:bStrData:={||TRAN(aDataC[oBrwC:nArrayAt,4],"99,999,999.99")}

  oCol:=oBrwC:aCols[5]
  oCol:cHeader:="Total"
  oCol:nWidth :=105
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:bStrData:={||TRAN(aDataC[oBrwC:nArrayAt,5],"9,999,999,999.99")}

  oCol:cFooter    :=TRAN(aTotal[5],"9,999,999,999.99")



  oBrwC:bClrStd      := {||{CLR_BLUE, iif( oBrwC:nArrayAt%2=0,16770764,16774636 ) } }
  oBrwC:bClrHeader   := {||{CLR_YELLOW,16764315}}
//oBrwC:bLDblClick   := {||lSelect:=.T.,oDlgC:End()}
  oBrwC:bLDblClick   := {||SelMesa()}
  oBrwC:bKeyDown     := {|nKey| oBrwC:nLastKey:=nKey,;
                               IIF( nKey=13,oDlgC:End(),NIL) }

  oBrwC:CreateFromCode()


  @ 06, 261-36 SBUTTON oBtn PIXEL;
               SIZE nBtnAlto,nBtnAlto FONT oFontB;
               NOBORDER;
               FILE "BITMAPS\RECIBIRDINERO.BMP";
               COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
               ACTION PAGAR()

   oBtn:cToolTip:="Recibir Pago"


  @ 06,287-36 SBUTTON oBtn PIXEL;
            SIZE nBtnAlto,nBtnAlto FONT oFontB;
            NOBORDER;
            FILE "BITMAPS\XPRINT.BMP";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION IMPRIMECTA()

    oBtn:cToolTip:="Cuenta"

   @ 06, 313-36  SBUTTON oBtn PIXEL;
             SIZE nBtnAlto,nBtnAlto FONT oFontB;
             FILE "BITMAPS\XFIND.BMP";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION EJECUTAR("BRWSETFIND",oBrwC)


   oBtn:cToolTip:="Buscar"


   @ 06, 313-10 SBUTTON oBtn PIXEL;
             SIZE nBtnAlto,nBtnAlto FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oDlgC:End()

   oBtn:cToolTip:="Salir"


   ACTIVATE DIALOG oDlgC ON INIT (oDlgC:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                 oBrwC:Move(20+(nBtnAlto*2),15,nWidth-30,nHeight-084,.T.),;
                                 oBrwC:SetColor(NIL,nClrPane1))
 

//   oCol:=oBrwC:aCols[2]
//   oCol:End()

RETURN lRet

/*
// Busca la Foto
*/
FUNCTION FindPosBmp()
  LOCAL nAt:=oBrwC:nArrayAt
RETURN nAt

FUNCTION SELMESA()
   LOCAL cMesa:=oBrwC:aArrayData[oBrwC:nArrayAt,1],cTitle:="",oCol

   CursorWait()

RETURN .T.

FUNCTION PAGAR()

   IF EJECUTAR("DPPOSMESAPAGO",cMesa,oComanda,.F.)
      lRet:=.T.
      oDlgC:End()
   ENDIF

RETURN 

FUNCTION IMPRIMECTA()
   LOCAL cWhere
   oDlgC:End()

  cWhere:="COM_MESA"+GetWhere("=",cMesa)

  //EJECUTAR("FMTRUN","COMANDAS","DEMOSTRATIVODECUENTA","Demostrativo de Cuenta Mesa "+cMesa,cWhere)
  EJECUTAR("FMTRUN","DEMOSTRATIVODECUENTA","DEMOSTRATIVODECUENTA","Demostrativo de Cuenta Mesa "+cMesa,cWhere)

// EJECUTAR(" DPPOSMESAPRN",cMesa)
RETURN .T.

// EOF





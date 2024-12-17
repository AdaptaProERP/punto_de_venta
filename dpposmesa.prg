// Programa   : DPPOSMESA
// Fecha/Hora : 25/05/2006 05:13:35
// Propósito  : Cuentas por Mesas
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : Ventas
// Tabla      : 

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oComanda,cPedido,cWhereUs)
  LOCAL oBrwM,oDlgM,aBancos:={},oFontBrw,oCol,oFontB,oBtn,oBrush,oBtnPago
  LOCAL cFileBmp,cGrupo:="",cCodigo:="",cRif:=""
  LOCAL nTop:=180,nLeft:=1,nWidth:=485,nHeight:=358,I
  LOCAL nClrPane1:=16774636
  LOCAL lSelect:=.F.,cBanco:="",aDataM:={},nBtnAlto:=25
  LOCAL lPagEle:=.F. 

  LOCAL nCesta  :=0,nEfectivo:=0,nCheque:=0,nTarDB:=0,nTarCR:=0,nTarCT:=0,nTotal:=0
  LOCAL cCheque :=SPACE(10),cBcoChq:=SPACE(20)
  LOCAL cTarCR  :=SPACE(10),cBcoTCR:=SPACE(20)
  LOCAL cTarDB  :=SPACE(10),cBcoTDB:=SPACE(20)
  LOCAL cRIF    :=SPACE(10),cNombre:=SPACE(30),cDir1:=SPACE(40),cDir2:=SPACE(40),cTel:=SPACE(14)

//  aDataM:=ASQL(" SELECT COM_MESA,SUM(COM_CANTID),COUNT(*),SUM(COM_PRECIO*COM_CANTID) "+;
//              " FROM DPPOSCOMANDA WHERE COM_TIPO='P' AND COM_LLEVAR=0 "+;
//              " GROUP BY COM_MESA "+;
//              " ORDER BY COM_MESA ")

  DPKILLTIMER("MESAS") // Elimina el Timer de las Mesas

  aDataM:=EJECUTAR("MESAGETDATA",NIL,cWhereUs)

  IF Empty(aDataM)
     MensajeErr("No hay Cuentas por Mesa")
     RETURN ""
  ENDIF

  DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0, -16 BOLD
  DEFINE FONT oFontB   NAME "MS Sans Serif" SIZE 0, -10 BOLD

  DEFINE BRUSH oBrush;
               FILE "BITMAPS\dpposmesa.bmp"

  DEFINE DIALOG oDlgM TITLE "Grupos";
         STYLE nOr( WS_POPUP, WS_VISIBLE );
         BRUSH oBrush

  oDlgM:lHelpIcon:=.F.

  oBrwM:=TXBrowse():New(oDlgM )
  oBrwM:SetArray( aDataM ,.T.)
  oBrwM:lHScroll  := .F.
  oBrwM:lVScroll  := .T.
  oBrwM:nFreeze   := 1
  oBrwM:oFont     := oFontBrw
  oBrwM:nDataLines:= 1
  oBrwM:lFooter   := .F.
  oBrwM:lHeader   := .T.

  oCol:=oBrwM:aCols[1]
  oCol:cHeader:="Mesa"
  oCol:nWidth :=80

  oCol:=oBrwM:aCols[2]
  oCol:cHeader :="Cantidad"
  oCol:nWidth  :=110+10
  oCol:bStrData:={||TRAN(aDataM[oBrwM:nArrayAt,2],"99,999.99")}
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT

  oCol:=oBrwM:aCols[3]
  oCol:cHeader :="Items"
  oCol:nWidth  :=70
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:bStrData:={||TRAN(aDataM[oBrwM:nArrayAt,2],"999")}

  oCol:=oBrwM:aCols[4]
  oCol:cHeader:="Monto"
  oCol:nWidth :=150
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:bStrData:={||TRAN(aDataM[oBrwM:nArrayAt,4],"9,999,999,999.99")}

  oBrwM:bClrStd      := {||{CLR_BLUE, iif( oBrwM:nArrayAt%2=0,16770764,16774636 ) } }
  oBrwM:bClrHeader   := {||{CLR_YELLOW,16764315}}
//oBrwM:bLDblClick   := {||lSelect:=.T.,oDlgM:End()}
  oBrwM:bLDblClick   := {||SelMesa()}

//  oBrwM:bKeyDown     := {|nKey| oBrwM:nLastKey:=nKey,;
//                               IIF( nKey=13,EJECUTAR("DPPOSMESAPAGO",oBrwM:aArrayData[oBrwM:nArrayAt,1],oComanda),NIL) }


 oBrwM:bKeyDown     := {|nKey| oBrwM:nLastKey:=nKey,;
                               IIF( nKey=13, PAGAR() ,NIL) }

  oBrwM:CreateFromCode()


   @ 06, 161-78-3 SBUTTON oBtnPago PIXEL;
                SIZE nBtnAlto,nBtnAlto FONT oFontB;
                NOBORDER;
                FILE "BITMAPS\RECIBIRDINERO.BMP";
                COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
                ACTION PAGAR()

   oBtnPago:cToolTip:="Recibir Pago"

   @ 06, 161-52-3 SBUTTON oBtn PIXEL;
                SIZE nBtnAlto,nBtnAlto FONT oFontB;
                NOBORDER;
                FILE "BITMAPS\XPRINT.BMP";
                COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
                ACTION IMPRIMECTA()


   @ 06, 161-26-3 SBUTTON oBtn PIXEL;
                SIZE nBtnAlto,nBtnAlto FONT oFontB;
                NOBORDER;
                FILE "BITMAPS\CONFIG.BMP";
                COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
                ACTION (SetTimerOff(),;
                        EJECUTAR("DPPOSMESACAMBIA",oBrwM:aArrayData[oBrwM:nArrayAt,1]),;
                        SetTimerON())

   oBtn:cToolTip:="Intercambiar Mesa"

/*
   @ 06, 161-26-3 SBUTTON oBtn PIXEL;
            SIZE nBtnAlto,nBtnAlto FONT oFontB;
            NOBORDER;
            FILE "BITMAPS\BOTONUP.BMP";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION oBrwM:GoUp()

    oBtn:cToolTip:="Subir"

   @ 06, 187-26-3 SBUTTON oBtn PIXEL;
            SIZE nBtnAlto,nBtnAlto FONT oFontB;
            NOBORDER;
            FILE "BITMAPS\BOTONDOWN.BMP";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION oBrwM:GoDown()

   oBtn:cToolTip:="Bajar"
*/

   @ 06, 187-26-3  SBUTTON oBtn PIXEL;
             SIZE nBtnAlto,nBtnAlto FONT oFontB;
             FILE "BITMAPS\XFIND.BMP";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION EJECUTAR("BRWSETFIND",oBrwM)


   oBtn:cToolTip:="Buscar"


   @ 06, 213-26-3  SBUTTON oBtn PIXEL;
             SIZE nBtnAlto,nBtnAlto FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oDlgM:End()

   oBtn:cToolTip:="Salir"
  
// oDp:lSayTimer:=.T.

   ACTIVATE DIALOG oDlgM ON INIT (oDlgM:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                  oBrwM:Move(20+(nBtnAlto*2),10,nWidth-20,nHeight-084,.T.),;
                                  oBrwM:SetColor(NIL,nClrPane1),;
                                  oBrwM:GoBottom(.T.),;
                                  DPSETTIMER({||EJECUTAR("MESAGETDATA",oBrwM,cWhereUs)},"MESAS",4));
                                  VALID  (DPKILLTIMER("MESAS"),.T.) 
    // Elimina el Timer de las Mesas
 
    DPKILLTIMER("MESAS") // Elimina el Timer de las Mesas

    oDlgM:=NIL

RETURN cCodigo

/*
// Busca la Foto
*/
FUNCTION FindPosBmp()
  LOCAL nAt:=oBrwM:nArrayAt
RETURN nAt

/*
// Seleccionar Mesa
*/
FUNCTION SELMESA()
   LOCAL cMesa:=oBrwM:aArrayData[oBrwM:nArrayAt,1],cTitle:="",oCol
   LOCAL nAt  :=oBrwM:nArrayAt,nRowSel:=oBrwM:nRowSel

   SetTimerOff()

   CursorWait()

   IF EJECUTAR("DPPOSMESACTA",cMesa,oComanda)

     IF LEN(oBrwM:aArrayData)=1
        oDlgM:End()
        DPKILLTIMER("MESAS") // Elimina el Timer de las Mesas
        RETURN .T.
     ENDIF

     ARREDUCE(oBrwM:aArrayData,nAt)

     IF Empty(oBrwM:aArrayData)
        oBrwB:aArrayData:=ACLONE(aDataM)
        DPKILLTIMER("MESAS") // Elimina el Timer de las Mesas
        oDlgM:End()
        RETURN .T.
     ENDIF

     oBrwM:Refresh(.F.)
     oBrwM:nArrayAt:=MIN(nAt     , LEN(oBrwM:aArrayData))
     oBrwM:nRowSel :=MIN(nRowSel , oBrwM:RowCount())

   ENDIF

   oBrwM:DrawLine()

   SetTimerOn()


RETURN .T.

FUNCTION PAGAR()
   LOCAL cMesa:=oBrwM:aArrayData[oBrwM:nArrayAt,1]
   LOCAL nAt  :=oBrwM:nArrayAt,nRowSel:=oBrwM:nRowSel

   SetTimerOff()

   IF EJECUTAR("DPPOSMESAPAGO",cMesa,oComanda,.F.)

     IF LEN(oBrwM:aArrayData)=1
        oDlgM:End()
        DPKILLTIMER("MESAS") // Elimina el Timer de las Mesas
        RETURN .T.
     ENDIF

     ARREDUCE(oBrwM:aArrayData,nAt)

     IF Empty(oBrwM:aArrayData)
        oBrwB:aArrayData:=ACLONE(aDataM)
        oDlgM:End()
        RETURN .T.
     ENDIF

     oBrwM:Refresh(.F.)
     oBrwM:nArrayAt:=MIN(nAt     , LEN(oBrwM:aArrayData))
     oBrwM:nRowSel :=MIN(nRowSel , oBrwM:RowCount())

   ENDIF

   SetTimerOn()

RETURN .T.

FUNCTION IMPRIMECTA()
   LOCAL cWhere
   LOCAL cMesa:=oBrwM:aArrayData[oBrwM:nArrayAt,1]

   oDlgM:End()

   DPKILLTIMER("MESAS") // Elimina el Timer de las Mesas

   cWhere:="COM_MESA"+GetWhere("=",cMesa)

   //EJECUTAR("FMTRUN","COMANDAS","DEMOSTRATIVODECUENTA","Demostrativo de Cuenta Mesa "+cMesa,cWhere)
   EJECUTAR("FMTRUN","DEMOSTRATIVODECUENTA","DEMOSTRATIVODECUENTA","Demostrativo de Cuenta"+cMesa,cWhere)


RETURN .T.

/*
FUNCTION GETDATAMESA(oBrw)

  LOCAL aDataX,aLine,nAt,nRowSel,nLen,nOrder:=1,cOrder

  aDataX:=ASQL(" SELECT COM_MESA,SUM(COM_CANTID),COUNT(*),SUM(COM_PRECIO*COM_CANTID) "+;
              " FROM DPPOSCOMANDA WHERE COM_TIPO='P' AND COM_LLEVAR=0 "+;
              " GROUP BY COM_MESA "+;
              " ORDER BY COM_MESA ")

  IF !oBrw=NIL

     SetTimerOff()

     nOrder:=MAX(1,ASCAN(oBrw:aCols,{|oCol,n| !Empty(oCol:cOrder ) }))
     cOrder:=oBrw:aCols[nOrder]:cOrder
     
     IF cOrder="D"
       aDataX:=ASORT(aDataX,,, { |x, y| x[nOrder] > y[nOrder] })
     ELSE
       aDataX:=ASORT(aDataX,,, { |x, y| x[nOrder] < y[nOrder] })
     ENDIF

//   oDp:oFrameDp:SetText("Orden"+LSTR(nOrder)+" "+cOrder)

     nLen:=LEN(aDataM)

     IF Empty(aDataX) 
        DPKILLTIMER("MESAS")
        SetTimerOff()
        MensajeErr("No Hay Mesas con Comandas")
        oDlgM:End()
        SetTimerOn()
        RETURN .T.
     ENDIF

     nAt    :=MIN(oBrw:nArrayAt,LEN(aDataX))
     nRowSel:=MIN(oBrw:nRowSel,nAt)

//   aLine  :=aDataX[1]
//   AADD(aDataX,aLine)

     oBrw:aArrayData:=ACLONE(aDataX)
     aDataM         :=ACLONE(aDataX)

     IF LEN(aDataX)!=nLen  .OR. .T.
       oBrw:GoBottom(.T.)
     ENDIF

//     oBrw:nArrayAt  :=nAt  
//     oBrw:nRowSel   :=nRowSel

     oBrw:Refresh(.T.)
     oBrw:nArrayAt  :=nAt  
     oBrw:nRowSel   :=nRowSel


//   ? "LISTO",ErrorSys(.T.)
     SetTimerOn()
     DpFocus(oBrw)

  ENDIF

RETURN aDataX
*/

// EOF




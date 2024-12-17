// Programa   : DPPOSPEDIDO
// Fecha/Hora : 25/05/2006 05:13:35
// Propósito  : Cuentas por Mesas
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : Ventas
// Tabla      : 

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oComanda,cPedido)
  LOCAL oBrwM,oDlgM,aBancos:={},oFontBrw,oCol,oFontB,oBtn,oBrush,oBtnPago
  LOCAL cFileBmp,cGrupo:="",cCodigo:="",cRif:="",cWhere
  LOCAL nTop:=180,nLeft:=1,nWidth:=735+20,nHeight:=358,I
  LOCAL nClrPane1:=16774636
  LOCAL lSelect:=.F.,cBanco:="",aDataM:={},nBtnAlto:=25,lUpdate:=.F.,lPrint:=.F.

  LOCAL nCesta  :=0,nEfectivo:=0,nCheque:=0,nTarDB:=0,nTarCR:=0
  LOCAL cCheque :=SPACE(10),cBcoChq:=SPACE(20)
  LOCAL cTarCR  :=SPACE(10),cBcoTCR:=SPACE(20)
  LOCAL cTarDB  :=SPACE(10),cBcoTDB:=SPACE(20)
  LOCAL cRIF    :=SPACE(10),cNombre:=SPACE(30),cDir1:=SPACE(40),cDir2:=SPACE(40),cTel:=SPACE(14)

  oDp:cDirWhere:=""

  IF !Empty(cPedido)
     cWhere:=" AND COM_PEDIDO "+GetWhere("<>",cPedido)
  ENDIF

  aDataM:=EJECUTAR("DPPEDIDOGET")
// DPPEDIDOGETGETDATAPEDIDO()

/*
  aDataM:=ASQL(" SELECT COM_PEDIDO,CDL_NOMBRE,COM_HORA,COM_RIF,SUM(COM_CANTID),COUNT(*),SUM((COM_PRECIO*COM_CANTID)+COM_MTOIVA) "+;
               " FROM DPPOSCOMANDA "+;
               " INNER JOIN DPCLIENTESDELY ON COM_RIF=CDL_RIF "+;
               " WHERE COM_TIPO='P' AND COM_LLEVAR=1 "+cWhere+;
               " GROUP BY COM_PEDIDO,CDL_NOMBRE,COM_HORA,COM_HORA "+;
               " ORDER BY COM_PEDIDO ")

// ? CLPCOPY(oDp:cSql)

  AEVAL(aDataM,{|a,n| aDataM[n,2]:=IIF( ALLTRIM(a[4]) = "0" , "Llevar" , a[2] ),;     
                      aDataM[n,4]:=ELAPTIME(a[3],TIME()) } )

*/
  IF Empty(aDataM)
     MensajeErr("No hay Pedidos")
     RETURN ""
  ENDIF

  DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0, -16 BOLD
  DEFINE FONT oFontB   NAME "MS Sans Serif" SIZE 0, -10 BOLD

  DEFINE BRUSH oBrush;
               FILE "BITMAPS\dppospedidos.bmp"

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
  oCol:cHeader:="#Ped."
  oCol:bStrData:={||RIGHT(aDataM[oBrwM:nArrayAt,1],4)}
  oCol:nWidth :=70

  oCol:=oBrwM:aCols[2]
  oCol:cHeader:="Cliente"
  oCol:nWidth :=184

  oCol:=oBrwM:aCols[3]
  oCol:cHeader:="Hora"
  oCol:bStrData:={||LEFT(aDataM[oBrwM:nArrayAt,3],5)}
  oCol:nWidth :=54

  oCol:=oBrwM:aCols[4]
  oCol:cHeader:="Tiempo"
  oCol:nWidth :=54
  oCol:bStrData:={||LEFT(aDataM[oBrwM:nArrayAt,4],5)}

  oCol:=oBrwM:aCols[5]
  oCol:cHeader :="Cantidad"
  oCol:nWidth  :=110
  oCol:bStrData:={||TRAN(aDataM[oBrwM:nArrayAt,5],"99,999.99")}
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT

  oCol:=oBrwM:aCols[6]
  oCol:cHeader :="Items"
  oCol:nWidth  :=50
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:bStrData:={||TRAN(aDataM[oBrwM:nArrayAt,6],"999")}

  oCol:=oBrwM:aCols[7]
  oCol:cHeader:="Monto"
  oCol:nWidth :=150
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:bStrData:={||TRAN(aDataM[oBrwM:nArrayAt,7],"9,999,999,999.99")}

  oBrwM:bClrStd      := {||{CLR_BLUE, iif( oBrwM:nArrayAt%2=0,16770764,16774636 ) } }
  oBrwM:bClrHeader   := {||{CLR_YELLOW,16764315}}
//oBrwM:bLDblClick   := {||lSelect:=.T.,oDlgM:End()}
  oBrwM:bLDblClick   := {||PEDPRINT()}

//  oBrwM:bKeyDown     := {|nKey| oBrwM:nLastKey:=nKey,;
//                               IIF( nKey=13, ( SetTimerOff(),  EJECUTAR("DPPOSMESAPAGO",oBrwM:aArrayData[oBrwM:nArrayAt,1],oComanda), SetTimerOn()),NIL) }

  oBrwM:bKeyDown     := {|nKey| oBrwM:nLastKey:=nKey,;
                               IIF( nKey=13, PAGAR() ,NIL ) }


  oBrwM:CreateFromCode()

  @ 06, 180 SBUTTON oBtnPago PIXEL;
                SIZE nBtnAlto,nBtnAlto FONT oFontB;
                NOBORDER;
                FILE "BITMAPS\RECIBIRDINERO.BMP";
                COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
                ACTION PAGAR()

   oBtnPago:cToolTip:="Recibir Pago"


  @ 06, 180+(1+(1*nBtnAlto));
                SBUTTON oBtnPago PIXEL;
                SIZE nBtnAlto,nBtnAlto FONT oFontB;
                NOBORDER;
                FILE "BITMAPS\XEDIT.BMP";
                COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
                ACTION (lUpdate:=.T.,;
                        cCodigo:=oBrwM:aArrayData[oBrwM:nArrayAt,1],;
                        DPKILLTIMER("PEDIDOS"),;
                        oDlgM:End())

   oBtnPago:cToolTip:="Modificar"


   @ 06, 180+(1+(2*nBtnAlto));
                SBUTTON oBtn PIXEL;
                SIZE nBtnAlto,nBtnAlto FONT oFontB;
                NOBORDER;
                FILE "BITMAPS\XPRINT.BMP";
                COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
                ACTION PEDPRINT()

// EJECUTAR("DPPOSMESAPRN",oBrwM:aArrayData[oBrwM:nArrayAt,1])

   oBtn:cToolTip:="Imprimir Cuenta"

   @ 06, 180+(1+(3*nBtnAlto));
             SBUTTON oBtn PIXEL;
             SIZE nBtnAlto,nBtnAlto FONT oFontB;
             NOBORDER;
             FILE "BITMAPS\BOTONUP.BMP";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oBrwM:GoUp()

    oBtn:cToolTip:="Subir"

   @ 06, 180+(1+(4*nBtnAlto));
             SBUTTON oBtn PIXEL;
             SIZE nBtnAlto,nBtnAlto FONT oFontB;
             NOBORDER;
             FILE "BITMAPS\BOTONDOWN.BMP";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oBrwM:GoDown()

   oBtn:cToolTip:="Bajar"

   @ 06, 180+(1+(5*nBtnAlto));
             SBUTTON oBtn PIXEL;
             SIZE nBtnAlto,nBtnAlto FONT oFontB;
             FILE "BITMAPS\XFIND.BMP";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION EJECUTAR("BRWSETFIND",oBrwM)

   oBtn:cToolTip:="Buscar"

   @ 06, 180+(1+(6*nBtnAlto));
              SBUTTON oBtn PIXEL;
              SIZE nBtnAlto,nBtnAlto FONT oFontB;
              FILE "BITMAPS\XSALIR.BMP";
              NOBORDER;
              COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
              ACTION (cCodigo:="",oDp:cPedWhere:="",oDlgM:End())

   oBtn:cToolTip:="Salir"


   ACTIVATE DIALOG oDlgM ON INIT (oDlgM:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                  oBrwM:Move(20+(nBtnAlto*2),17,nWidth-30,nHeight-084,.T.),;
                                  oBrwM:SetColor(NIL,nClrPane1),;
                                  DPSETTIMER({||EJECUTAR("DPPEDIDOGET",oBrwM)},"PEDIDOS",4));
                                  VALID (DPKILLTIMER("PEDIDOS"),.T.)
 

   DPKILLTIMER("PEDIDOS") // Elimina el Timer de las Mesas

   IF !Empty(oDp:cPedWhere)

      // No Hay Dirección de Entrega es para Llevar

// ? oDp:cPedWhere

      IF UPPE(SQLGET("DPCLIENTESCERO","CCG_DIR3",oDp:cCliWhere))="BARRA"

         EJECUTAR("FMTRUN","COMPROBANTEDEBARRA ","COMPROBANTEPAGOBARRA","Imprimir Corte de Cuenta, Barra "+cPedido,;
                           oDp:cPedWhere)

      ELSE

          EJECUTAR("FMTRUN","NOTEENTREGADELI","NOTAENTREGADELI","Imprimir Corte de Cuenta, Pedido "+cPedido,;
                            oDp:cPedWhere)
      ENDIF

   ENDIF

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
FUNCTION PEDPRINT()
   LOCAL cPedido:=oBrwM:aArrayData[oBrwM:nArrayAt,1],cTitle:="",oCol
   LOCAL nAt    :=oBrwM:nArrayAt,nRowSel:=oBrwM:nRowSel

   CursorWait()

   SetTimerOff()

   EJECUTAR("DPPOSPEDPRN",cPedido,oComanda)

   SetTimerOn()

RETURN .T.

FUNCTION PAGAR()
   LOCAL cPedido:=oBrwM:aArrayData[oBrwM:nArrayAt,1]
   LOCAL nAt  :=oBrwM:nArrayAt,nRowSel:=oBrwM:nRowSel

   oDp:cPedWhere:=""

   SetTimerOff()

   IF EJECUTAR("DPPOSMESAPAGO",cPedido,oComanda,.T.)

     IF LEN(oBrwM:aArrayData)=1
        oDlgM:End()
        DPKILLTIMER("PEDIDOS")
        RETURN .T.
     ENDIF

     ARREDUCE(oBrwM:aArrayData,nAt)

     IF Empty(oBrwM:aArrayData) .OR. !Empty(oDp:cPedWhere)
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
/*
FUNCTION GETDATAPEDIDO(oBrw)

  LOCAL aDataX,aLine,nAt,nRowSel,nLen,nOrder,cOrder

  oDp:lSayTimer:=.F.

  aDataX:=ASQL(" SELECT COM_PEDIDO,CDL_NOMBRE,COM_HORA,COM_RIF,SUM(COM_CANTID),COUNT(*),SUM((COM_PRECIO*COM_CANTID)+COM_MTOIVA) "+;
               " FROM DPPOSCOMANDA "+;
               " INNER JOIN DPCLIENTESDELY ON COM_RIF=CDL_RIF "+;
               " WHERE COM_TIPO='P' AND COM_LLEVAR=1 "+cWhere+;
               " GROUP BY COM_PEDIDO,CDL_NOMBRE,COM_HORA,COM_HORA "+;
               " ORDER BY COM_PEDIDO ")

  AEVAL(aDataX,{|a,n| aDataX[n,2]:=IIF( ALLTRIM(a[4]) = "0" , "Llevar" , a[2] ),;     
                      aDataX[n,4]:=ELAPTIME(a[3],TIME()) } )

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





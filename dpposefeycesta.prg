// Programa   : DPPOSEFEYCESTA
// Fecha/Hora : 27/10/2005 16:24:21
// Prop¢sito  : Pagar con Efectivo y Cesta Ticket
// Creado Por : Juan Navas
// Modificado : Marlon Ramos 05-08-2008 (No cerraba la ventana cuando la impresora es:"EPSON TMU220AF")
// Llamado por: DPPOS01
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPos)
  LOCAL nMonto :=12003,lResp:=.F.,oBrw,oCol,oWnd,oGrp,oLetra,oBrush,oRecibe,oCesta,nCesta:=0
  LOCAL nRecibe:=0,oDlg,oFont,oBtn,oFontB,oFont2,oFont3,oFont4
  LOCAL nTop:=206,nLeft:=05,nWidth:=540,nHeight:=310,cEnletras:=""
  LOCAL nClrPane  :=13366014
  LOCAL oVuelto,nVuelto:=0
  LOCAL cPicture  := "999,999,999.99"
  LOCAL nClrBlink := 32768   // blinking color
  LOCAL nInterval := 500-100      // blinking interval in milliseconds
  LOCAL nStop     := 0            // blinking limit to stop in milliseconds
  LOCAL aDesglose := {}
  LOCAL nClrPane1 := 16770764
  LOCAL nClrPane2 := 16566954
  
// 16770764,16566954

  aDesglose:={}
  AADD(aDesglose,{0,"X",0,"=",0})

  IF ValType(oPos)!="O"
     nMonto:=10000
  ELSE
     oWnd  :=oPos:oWnd
     nMonto:=oPos:nNeto
  ENDIF

  DEFINE FONT oFont  NAME "MS Sans Serif" SIZE 0, -16 BOLD
  DEFINE FONT oFontB NAME "MS Sans Serif" SIZE 0, -18 BOLD  
  DEFINE FONT oFont2 NAME "MS Sans Serif" SIZE 0, -12 BOLD 
  DEFINE FONT oFont3 NAME "MS Sans Serif" SIZE 0, -08 
  DEFINE FONT oFont4 NAME "MS Sans Serif" SIZE 0, -08 BOLD

  DEFINE BRUSH oBrush;
               FILE "BITMAPS\cestayefectivo.BMP"

//  oBrush=nil

  IF oBrush!=NIL

  DEFINE DIALOG oDlg TITLE "Recibido";
         STYLE nOr( WS_POPUP, WS_VISIBLE );
         BRUSH oBrush

  ELSE

  DEFINE DIALOG oDlg TITLE "Recibido"


  ENDIF

  oDlg:lHelpIcon:=.F.

  @ 4.1,3 STSAY "Total a Pagar";
         RIGHT SIZE 90,10;
         COLORS CLR_BLUE FONT oFont

  @ 5.7,3 STSAY "Vuelto";
          RIGHT;
          SIZE 90,10;
          COLORS CLR_BLUE FONT oFont

  @ 5.0,1.5 SAY TRAN(nMonto,"999,999,999.99");
        RIGHT;
        SIZE 100,14;
        COLOR CLR_HBLUE,CLR_YELLOW;
        FONT oFontB RIGHT BORDER


  IF oBrush=NIL
    @ 0.2,.4 SAY "Cesta Ticket" FONT oFontB
    @ 2.2,.4 SAY "Efectivo"     FONT oFontB
  ENDIF

  @5.6,1.5 STSAY oVuelto  PROMPT TRAN(nVuelto,"999,999,999.99");
           OF oDlg;
           COLORS CLR_HRED;
           SIZE 100,13;
           FONT oFontB ;
           SHADED;
           RIGHT;
           BLINK nClrBlink, nInterval, nStop  

 @17.8,1.0 STSAY oLetra  PROMPT cEnLetras;
           COLORS CLR_BLACK;
           SIZE 200,13;
           FONT oFont4

 @ 1.5,1.5 GET oCesta VAR nCesta PICTURE "999,999,999,999.99";
           SIZE 100,13.7 FONT oFontB;
           VALID CESTA();
           RIGHT
           

//           VALID nCesta<=nMonto
// VUELTO(.t.)
// ;
//           WHEN !nRecibe>=nMonto

 // Efectivo

 @ 3.8,1.5 GET oRecibe VAR nRecibe PICTURE "999,999,999,999.99";
           SIZE 100,13.7 FONT oFontB;
           RIGHT;
           WHEN nCesta<nMonto;
           VALID VUELTO(.T.)
    
//01-09-2008 Marlon Ramos IF "EPSON TMU220AF"$UPPE(oDp:cImpFiscal)
IF ASCAN(oDp:aImprFiscEps,{|c,n| IIF( ValType(c)="C", (oDp:cImpFiscal $ c) , .F.) }) > 0
  @09.2, 1  SBUTTON oBtn ;
          SIZE 50, 23 FONT oFont2;
          FILE "BITMAPS\OK2.BMP" ;
          LEFT PROMPT "Aceptar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (SaveTicket(.T.),oDlg:End())
          // 05-08-2008 Marlon Ramos (Cerrar ventana)

          //ACTION (SaveTicket(.T.))
ELSE
  @09.2, 1  SBUTTON oBtn ;
          SIZE 50, 23 FONT oFont2;
          FILE "BITMAPS\OK2.BMP" ;
          LEFT PROMPT "Aceptar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (lResp:=.T.,oDlg:End())
ENDIF

  @09.2, 11 SBUTTON oBtn ;
          SIZE 50, 23 FONT oFont2;
          FILE "BITMAPS\XCANCEL.BMP" ;
          LEFT PROMPT "Regresar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (lResp:=.F.,oDlg:End())

  @ 2.8,13.5 SBUTTON oBtn ;
          SIZE 40,10 FONT oFont2;
          LEFT PROMPT "Calcular";
          NOBORDER;
          COLORS CLR_BLACK, {CLR_HGRAY , CLR_WHITE, 1 };
          ACTION EJECUTAR("CALCESTATICKET",nMonto,oCesta,oRecibe)

  oBtn:cToolTip:="Cancelar Pago"
  oBtn:cMsg    :=oBtn:cToolTip

  oBrw:=TXBrowse():New(oDlg )
  oBrw:SetArray( aDesglose ,.F.)
  oBrw:lHScroll       := .F.
  oBrw:lVScroll       := .F.
  oBrw:nFreeze        := 1
  oBrw:oFont          := oFont4
  oBrw:lFooter        := .F.
  oBrw:lRecordSelector:= .F.

  oCol:=oBrw:aCols[1]
  oCol:cHeader      := "Moneda"
  oCol:nWidth       := 080
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,1],cPicture)}
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrw:aCols[2]
  oCol:cHeader      := "X"
  oCol:nWidth       := 15
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrw:aCols[3]
  oCol:cHeader      := "Cant."
  oCol:nWidth       := 45
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrw:aCols[4]
  oCol:cHeader      := "="
  oCol:nWidth       := 15
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrw:aCols[5]
  oCol:cHeader      := "Total"
  oCol:nWidth       := 120
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],cPicture)}
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  AEVAL(oBrw:aCols,{|oCol,n|oCol:oHeaderFont:=oFont4})

  oBrw:bClrStd   := {||{0, iif( oBrw:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }
  oBrw:bClrHeader:= {||{CLR_BLACK,14671839 }}

  oBrw:CreateFromCode()

  ACTIVATE DIALOG oDlg ON INIT (oDlg:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                oBrw:SetColor(NIL,16770764),;
                                oBrw:Move(15,240,290,nHeight-038,.T.),;
                                oVuelto:HIDE())

  IF ValType(oPos)="O" .AND. lResp
     oPos:nEfectivo:=(nRecibe-nVuelto)
     oPos:nCesta   :=nCesta
     oPos:nRecibe  :=nRecibe
     oPos:nVuelto  :=nVuelto
  ENDIF

RETURN lResp

FUNCTION SaveTicket(lPrint)
     oPos:nVuelto  :=nVuelto
     oPos:nRecibe  :=nRecibe
     oPos:nCesta   :=nCesta
RETURN EJECUTAR("DPPOSSAVE",lPrint)

FUNCTION VUELTO(lValida)
  LOCAL lResp:=.T.

  IF oRecibe:nLastKey=38 // Subir
     RETURN .T.
  ENDIF

  IF Empty(nRecibe) .AND. (oRecibe:nLastKey=13 .OR. oRecibe:nLastKey=9)
     oRecibe:VarPut(nMonto,.T.)
     oRecibe:KeyBoard(13)
     RETURN .F.
  ENDIF

  IF nRecibe>=nMonto
     // nCesta:=0
     // oCesta:VarPut(nCesta,.T.)
  ENDIF
   
  IF (nRecibe+nCesta)-nMonto<0 .AND. lValida
     RETURN .F.
  ENDIF
    
  nVuelto  :=(nRecibe+nCesta)-nMonto


  IF !lValida .AND. nVuelto<0
//     nCesta:=nVuelto*-1
//     nVuelto:=0
//     oCesta:VarPut(nCesta,.T.)
  ENDIF

//  IF !lValida
//
//  ENDIF

  cEnletras:=Lower(ENLETRAS(nVuelto))
  cEnletras:=UPPE(LEFT(cEnLetras,1))+SUBS(cEnletras,2,len(cEnletras))
  cEnletras:=STRTRAN(cEnletras,"con 00/100")

  oLetra:Hide()
  oLetra:Refresh(.T.)
  oLetra:Show()

  aDesglose:=EJECUTAR("DESGLOSE",nVuelto)
  oBrw:aArrayData:=ACLONE(aDesglose)
  oBrw:Gotop(.T.)
  oBrw:Refresh(.T.)

  oVuelto:Hide()
  oVuelto:Refresh(.T.)
  oVuelto:Show()

  // AQUI DEBE ABRIR LA GAVETA
  SysRefresh(.T.)
  EJECUTAR("A_GAV")
  DISPVUELTO()

RETURN lResp

FUNCTION DISPVUELTO()
  LOCAL cLine1,cLine2:="VUELTO",nLen,cTotal
//  LOCAL nVuelto  :=nRecibe-nMonto

  cLine1:="EFECTIVO"

  cTotal:=FDP(nRecibe,"999,999,999.99",NIL,.T.)
  nLen  :=20-LEN(cLine1)
  cLine1:=cLine1+PADL(cTotal,nLen)
  
  IF nVuelto<>0
     cTotal:=FDP(nVuelto,"999,999,999.99",NIL,.T.)

     IF "LPT"$oDp:cDisp_Com
       nLen  :=19-LEN(cLine2)
     ELSE
       nLen  :=20-LEN(cLine2)
     ENDIF

     cLine2:=cLine2+PADL(cTotal,nLen)
  ELSE
     cLine2:=cLine1
     cLine1:="Muchas Gracias"
  ENDIF

  EJECUTAR("DISPRUN",cLine1,cLine2)

RETURN .T.

FUNCTION CESTA()

  nRecibe:=MAX(nMonto-nCesta,0)
  oRecibe:VarPut(nRecibe,.T.)

RETURN .T.

// EOF



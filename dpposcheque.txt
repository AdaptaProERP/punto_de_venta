// Programa   : DPPOSCHEQUE
// Fecha/Hora : 27/10/2005 16:24:21
// Prop¢sito  : Generar el Pago con Efectivo
// Creado Por : Juan Navas
// Llamado por: DPPOS01
// Aplicaci¢n : VENTAS 
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPos)
  LOCAL nMonto :=12003,lResp:=.F.,oBrw,oCol,oWnd,oGrp,oLetra,oBrush,oRecibe
  LOCAL nRecibe:=0,oDlg,oFont,oBtn,oFontB,oFont2,oFont3,oFont4,oFont5
  LOCAL nTop:=206,nLeft:=05,nWidth:=567,nHeight:=323,cEnletras:=""
  LOCAL nClrPane  :=13366014
  LOCAL oVuelto,nVuelto:=0,oCheque,oBanco
  LOCAL cCheque   := SPACE(12)
  LOCAL cBanco    := SPACE(40) // Banco
  LOCAL cPicture  := "999,999,999.99"
  LOCAL nClrBlink := 32768   // blinking color
  LOCAL nInterval := 500-100      // blinking interval in milliseconds
  LOCAL nStop     := 0            // blinking limit to stop in milliseconds
  LOCAL aDesglose := {}
  LOCAL nClrPane1 := 16770764
  LOCAL nClrPane2 := 16566954
  LOCAL cCheque   := SPACE(12)
  LOCAL cBanco    := SPACE(40)

  DEFAULT oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE")
  
// 16770764,16566954
  oDp:aBancoDir:={}

  aDesglose:={}
  AADD(aDesglose,{0,"X",0,"=",0})

  IF ValType(oPos)!="O"
     nMonto:=12212
  ELSE
     oWnd  :=oPos:oWnd
     nMonto:=oPos:nNeto
//     EJECUTAR("DISPRUN","TOTAL A PAGAR "+oDp:cMoneda+"<"+LSTR(nMonto)+">","IVA:"+LSTR(oPos:nIva)+">",;
//              "PRODUCTOS"+LSTR(oPos:nCanTot))
  ENDIF

  nRecibe:=nMonto

  DEFINE FONT oFont  NAME "MS Sans Serif" SIZE 0, -16 BOLD
  DEFINE FONT oFontB NAME "MS Sans Serif" SIZE 0, -16 BOLD  
  DEFINE FONT oFont2 NAME "MS Sans Serif" SIZE 0, -12 BOLD 
  DEFINE FONT oFont3 NAME "MS Sans Serif" SIZE 0, -08 
  DEFINE FONT oFont4 NAME "MS Sans Serif" SIZE 0, -08 BOLD
  DEFINE FONT oFont5 NAME "MS Sans Serif" SIZE 0, -06 BOLD

  DEFINE BRUSH oBrush;
               FILE "BITMAPS\PAGOCHEQUE.BMP"

  DEFINE DIALOG oDlg TITLE "Recibido";
         STYLE nOr( WS_POPUP, WS_VISIBLE );
         BRUSH oBrush

  oDlg:lHelpIcon:=.F.


  @ 0.5,3 STSAY "Monto";
          RIGHT SIZE 90,10;
          COLORS CLR_BLUE FONT oFont

  @ 2.1,3 STSAY "Monto a Pagar";
          RIGHT SIZE 90,10;
          COLORS CLR_BLUE FONT oFont

  @ 10.0,05 STSAY "Cheque";
            SIZE 35,10;
            COLORS CLR_BLUE FONT oFont5

  @ 13.2,05 STSAY "Banco";
            SIZE 35,10;
            COLORS CLR_BLUE FONT oFont5

  @ 16,3 STSAY "Vuelto";
          RIGHT;
          SIZE 90,10;
          COLORS CLR_BLUE FONT oFont5

  @ 2.9,1.5 SAY TRAN(nMonto,"999,999,999.99");
            RIGHT;
            SIZE 100,13;
            COLOR CLR_HBLUE,CLR_YELLOW;
            FONT oFontB RIGHT BORDER

  @6.5,1.0 STSAY oVuelto  PROMPT TRAN(nVuelto,"999,999,999.99");
           OF oDlg;
           COLORS CLR_HRED;
           SIZE 100,14;
           FONT oFontB ;
           SHADED;
           RIGHT;
           BLINK nClrBlink, nInterval, nStop  

 @17.8,1.0 STSAY oLetra  PROMPT cEnLetras;
           COLORS CLR_BLACK;
           SIZE 200,14;
           FONT oFont4

 @ 1.6,1.5 GET oRecibe VAR nRecibe PICTURE "999,999,999,999.99";
           SIZE 100,12 FONT oFontB;
           RIGHT;
           VALID VUELTO() ;
           WHEN .F.   
           // 18-09-2008 Marlon Ramos (No pedir monto)

 @ 5.35,1.5 GET oCheque VAR cCheque;
           SIZE 60,10 FONT oFont4

  // Uso   : Archivo de la BaLanza
  //
  @ 6.8, 1.5 BMPGET oBanco  VAR cBanco;
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (SELBANCO());
             VALID VALBANCO();
             SIZE 100,10 FONT oFont4

  oBanco:bKeyDown:={|nKey|KeyBanco(nKey)}

     
  @09.2+.5, 1  SBUTTON oBtn ;
          SIZE 50, 20 FONT oFont2;
          FILE "BITMAPS\OK2.BMP" ;
          LEFT PROMPT "Aceptar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (VALCHEQUE())

          //Marlon Ramos 18-07-2008 ACTION (lResp:=.T.,oDlg:End())

  @09.2+.5, 11 SBUTTON oBtn ;
          SIZE 50, 20 FONT oFont2;
          FILE "BITMAPS\XCANCEL.BMP" ;
          LEFT PROMPT "Regresar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (lResp:=.F.,oDlg:End())

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

     oPos:nCheque  :=nMonto
     oPos:nRecibe  :=nRecibe
     oPos:nVuelto  :=nVuelto
     oPos:cBanco   :=cBanco
     oPos:cCheque  :=cCheque

  ENDIF

  IF lResp

//    IF nVuelto>0
//       EJECUTAR("DISPRUN","EFECTIVO "+oDp:cMoneda+"<"+LSTR(nRecibe)+">","Su Vuelto <"+LSTR(nVuelto)+">")
//    ELSE
//       EJECUTAR("DISPRUN","EFECTIVO "+LSTR(nRecibo),"Gracias por su Compra")
//    ENDIF

  ENDIF

RETURN lResp

FUNCTION VUELTO()
  LOCAL lResp:=.T.

  IF Empty(nRecibe) .AND. (oRecibe:nLastKey=13 .OR. oRecibe:nLastKey=9)
     oRecibe:VarPut(nMonto,.T.)
     oRecibe:KeyBoard(13)
     RETURN .F.
  ENDIF
   
  IF nRecibe-nMonto<0
     RETURN .F.
  ENDIF
    
  nVuelto  :=nRecibe-nMonto
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

RETURN lResp

/*
// Seleccionar Banco
*/
FUNCTION SELBANCO()
   LOCAL cNombre:="",nLen:=40

   cNombre:=EJECUTAR("DPPOSSELBANCO")


   IF !EMPTY(cNombre)

     cBanco:=PADR(cNombre,nLen)
     oBanco:VarPut(cNombre,.T.)
     oBanco:KeyBoard(13)

   ENDIF

   oBanco:Refresh(.T.)
   SysRefresh(.T.)

RETURN .T.

FUNCTION KeyBanco(nKey)
  LOCAL cBanco:=oBanco:VarGet(),nAt,cFind,nLen:=Len(cBanco),cGet,nLenOrg:=LEN(ALLTRIM(cBanco))

  cBanco:=ALLTRIM(cBanco)+CHR(nKey)

  nAt:=ASCAN(oDp:aBancos,{|a,n|UPPE(cBanco)=LEFT(UPPE(a[1]),LEN(cBanco))})

  IF nAt>0 //.AND. LEN(cBanco)>1

    cGet:=ALLTRIM(oBanco:VarGet())
    cGet:=cGet+SUBS(oDp:aBancos[nAt,1],nLenOrg+2,nLen)
    cGet:=PADR(cGet,nLen)
    Eval(oBanco:bSetGet,cGet)
    oBanco:Refresh(.F.)
    oBanco:oGet:Pos:=nLenOrg+1

  ENDIF

RETURN .F.

FUNCTION VALBANCO()

  LOCAL cTel:=SQLGET("BAN_TELEF1,BAN_TELEF2,BAN_TELEF3 FROM DPBANCODIR WHERE BAN_NOMBRE"+GetWhere("=",cBanco))
  // Valida el banco

//   ? cTel,cBanco
//oDp:aRow[1],oDp:aRow[2]
   DISPVUELTO()
  
RETURN .T.

FUNCTION DISPVUELTO()
  LOCAL cLine1,cLine2:="VUELTO",nLen,cTotal
//  LOCAL nVuelto  :=nRecibe-nMonto

  cLine1:="CHEQUE"

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


FUNCTION VALCHEQUE()
IF !EMPTY(cCheque) .And. !EMPTY(cBanco)
   lResp:=.T.
   oDlg:End()    
ELSE
   MensajeErr("Ingrese Nº de Cheque y Banco, por favor.")
ENDIF
RETURN lResp

// EOF


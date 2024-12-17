// Programa   : DPPOSDEBITO
// Fecha/Hora : 27/10/2005 16:24:21
// Propósito  : Generar el Pago con Efectivo
// Creado Por : Juan Navas
// Llamado por: DPPOS01
// Aplicación : VENTAS 
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPos)
  LOCAL nMonto :=12003,lResp:=.F.,oBrw,oCol,oWnd,oGrp,oLetra,oBrush,oRecibe
  LOCAL nRecibe:=0,oDlg,oFont,oBtn,oFontB,oFont2,oFont3,oFont4,oFont5
  LOCAL nTop:=206,nLeft:=05,nWidth:=290,nHeight:=305,cEnletras:=""
  LOCAL nClrPane  :=13366014
  LOCAL oVuelto,nVuelto:=0,oCheque,oBanco
  LOCAL cDebito   := SPACE(12)
  LOCAL cBanco    := SPACE(40) // Banco
  LOCAL cPicture  := "999,999,999.99"
  LOCAL nClrBlink := 32768   // blinking color
  LOCAL nInterval := 500-100      // blinking interval in milliseconds
  LOCAL nStop     := 0            // blinking limit to stop in milliseconds
  LOCAL aDesglose := {}
  LOCAL nClrPane1 := 16770764
  LOCAL nClrPane2 := 16566954
  LOCAL cDebito   := SPACE(12)
  LOCAL cBanco    := SPACE(40)
  LOCAL aBancos   := {}

  //29-05-2008 Marlon Ramos (Evitar Registros duplicados) LOCAL aMarcaFin :=ATABLE(" SELECT CXI_MARCA FROM DPBANCODIRPOR WHERE CXI_CODINS='TDB' AND CXI_MARCA<>'<Todas>'")
  LOCAL aMarcaFin :=ATABLE(" SELECT DISTINCT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='TDB'")
  LOCAL cSql      :=CLPCOPY(oDp:cSql)

  LOCAL cMarcaFin 
  LOCAL aPosBco   :=ATABLE(" SELECT PVB_CODIGO FROM DPPOSBANCARIO WHERE PVB_ACTIVO=1 ")
  LOCAL cPosTD   ,oPosTD

  IIF( Empty(aPosBco ) , AADD(aPosBco ,"Ninguno") , NIL)   

  cPosTD:=aPosBco[1]

  DEFAULT oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE")

  IF Empty(aMarcaFin)
    //29-05-2008 Marlon Ramos (Evitar Registros duplicados) aMarcaFin :=ATABLE(" SELECT MFN_NOMBRE FROM DPMARCASFINANC WHERE MFN_NOMBRE<>'<Todas>'")
    aMarcaFin :=ATABLE(" SELECT DISTINCT MFN_NOMBRE FROM DPMARCASFINANC WHERE MFN_NOMBRE<>'<Todas>'")
  ENDIF

  IF Empty(aMarcaFin)
    AADD(aMarcaFin,"Indefinida")
  ENDIF

  cMarcaFin:= aMarcaFin[1] 

//DEFAULT oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE")

  aBancos:=ACLONE(oDp:aBancos)

  IF EMPTY(aBancos)
     AADD(aBancos,{"Ninguno","Telefono"})
  ENDIF

  oDp:aBancoDir:={}

  AEVAL(aBancos,{|a,n|aBancos[n,1]:=a[1]+CRLF+a[2]})

  aDesglose:={}
  AADD(aDesglose,{0,"X",0,"=",0})

  IF ValType(oPos)!="O"
     nMonto:=12212
  ELSE
     oWnd  :=oPos:oWnd
     nMonto:=oPos:nNeto
  ENDIF

  nRecibe  :=nMonto
  cEnletras:=Lower(ENLETRAS(nMonto))

  DEFINE FONT oFont  NAME "MS Sans Serif" SIZE 0, -16 BOLD
  DEFINE FONT oFontB NAME "MS Sans Serif" SIZE 0, -16 BOLD  
  DEFINE FONT oFont2 NAME "MS Sans Serif" SIZE 0, -12 BOLD 
  DEFINE FONT oFont3 NAME "MS Sans Serif" SIZE 0, -08 
  DEFINE FONT oFont4 NAME "MS Sans Serif" SIZE 0, -08 BOLD
  DEFINE FONT oFont5 NAME "MS Sans Serif" SIZE 0, -06 BOLD

  DEFINE BRUSH oBrush;
               FILE "BITMAPS\PAGODEBITO.BMP"

  DEFINE DIALOG oDlg TITLE "Recibido";
         STYLE nOr( WS_POPUP, WS_VISIBLE );
         BRUSH oBrush

  oDlg:lHelpIcon:=.F.

  @ 1.1,3 STSAY "Monto a Pagar";
          RIGHT SIZE 90,10;
          COLORS CLR_BLUE FONT oFont

  @ 06.2,05 STSAY "Comprobante:";
            SIZE 45,10;
            COLORS CLR_BLUE FONT oFont5

  @ 13.5,05 STSAY "Banco";
            SIZE 35,10;
            COLORS CLR_BLUE FONT oFont5

  @ 09.7,05 STSAY oDp:xDPMARCASFINANC;
            SIZE 60,10;
            COLORS CLR_BLUE FONT oFont5

  @ 17,05 STSAY oDp:xDPPOSBANCARIO;
           SIZE 60,10;
           COLORS CLR_BLUE FONT oFont5

  @ 1.9,1.5 STSAY TRAN(nMonto,"999,999,999.99");
            RIGHT;
            SIZE 100,13;
            COLORS CLR_HBLUE;
            FONT oFontB


  @ 3.60,1.5 GET oCheque VAR cDebito;
             SIZE 60,10 FONT oFont4



  @ 4.8,1.5 COMBOBOX oMarca VAR cMarcaFin ITEMS aMarcaFin;
            SIZE 100,NIL;
            FONT oFont5;
            WHEN LEN(aMarcaFin)>1

/*
  @18.4,1.5  STSAY oLetra  PROMPT cEnLetras;
             COLORS CLR_BLACK;
             SIZE 200,14;
             FONT oFont4
*/

  @ 6.9, 1.5 BMPGET oBanco  VAR cBanco;
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (SELBANCO());
             VALID VALBANCO(oBanco);
             SIZE 100,10 FONT oFont4


  @ 8.0,1.5 COMBOBOX oPosTD VAR cPosTD ITEMS aPosBco;
            SIZE 64,NIL;
            FONT oFont5;
            WHEN LEN(aPosBco)>1


  oBanco:bKeyDown:={|nKey|KeyBanco(nKey,oBanco)}
     
  @09.2+.5, 1  SBUTTON oBtn ;
          SIZE 50, 20 FONT oFont2;
          FILE "BITMAPS\OK2.BMP" ;
          LEFT PROMPT "Aceptar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (VALDEBITO())

          //Marlon Ramos 29-07-2008 ACTION (lResp:=.T.,oDlg:End())

  @09.2+.5, 11 SBUTTON oBtn ;
          SIZE 50, 20 FONT oFont2;
          FILE "BITMAPS\XCANCEL.BMP" ;
          LEFT PROMPT "Regresar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (lResp:=.F.,oDlg:End())

  oBtn:cToolTip:="Cancelar Pago"
  oBtn:cMsg    :=oBtn:cToolTip

/* 29-05-2008 Marlon Ramos *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
  oBrw:=TXBrowse():New(oDlg )
  oBrw:SetArray( aBancos ,.T.)
  oBrw:lHScroll       := .F.
  oBrw:lVScroll       := .T.
  oBrw:nFreeze        := 1
  oBrw:oFont          := oFont4
  oBrw:lFooter        := .F.
  oBrw:lHeader        := .F.
  oBrw:lRecordSelector:= .F.
  oBrw:nDataLines     := 2

  oCol:=oBrw:aCols[1]
//  oCol:cHeader      := "Banco"
  oCol:nWidth       := 250
//  oCol:nHeadStrAlign:= AL_RIGHT
//  oCol:nFootStrAlign:= AL_RIGHT
//  oCol:nDataStrAlign:= AL_RIGHT
//  oCol:bStrData     := {||TRAN(oBrw:aArrayData[oBrw:nArrayAt,1],cPicture)}
//  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  AEVAL(oBrw:aCols,{|oCol,n|oCol:oHeaderFont:=oFont4})

  oBrw:bClrStd   := {||{0, iif( oBrw:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }
  oBrw:bClrHeader:= {||{CLR_BLACK,14671839 }}
  oBrw:bLDblClick:= {||oBanco:VarPut(oDp:aBancos[oBrw:nArrayAt,1],.T.)}


  @ 10, 228 SBUTTON oBtn PIXEL;
            SIZE 25,18 FONT oFontB;
            NOBORDER;
            FILE "BITMAPS\BOTONUP.BMP";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION oBrw:GoUp()

  oBtn:cToolTip:="Subir"

  @ 10, 254 SBUTTON oBtn PIXEL;
            SIZE 25,18 FONT oFontB;
            NOBORDER;
            FILE "BITMAPS\BOTONDOWN.BMP";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION oBrw:GoDown()

   oBtn:cToolTip:="Bajar"


//  oBrw:bKeyDown     := {|nKey| oBrw:nLastKey:=nKey,;
//                               IIF( nKey=13,oDlg:End(),NIL) }
//


  oBrw:CreateFromCode()

  ACTIVATE DIALOG oDlg ON INIT (oDlg:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                oBrw:SetColor(NIL,16770764),;
                                oBrw:Move(60,260,299,nHeight-075-10,.T.),;
                                ,.F.)
*/
  ACTIVATE DIALOG oDlg ON INIT oDlg:Move(nTop,nLeft,nWidth,nHeight,.T.)
// Fin 29-05-2008 Marlon Ramos *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


  IF ValType(oPos)="O" .AND. lResp

     cBanco:=EVAL(oBanco:bSetGet)

     oPos:nDebito  :=nMonto
     oPos:nRecibe  :=nRecibe
     oPos:nVuelto  :=nVuelto
     oPos:cBcoDeb  :=cBanco
     oPos:cDebito  :=cDebito

     oPos:cMarcaTD   :=cMarcaFin
     oPos:cPosTD     :=cPosTD
  
     oPos:SaveTicket(.T.)


  ENDIF
   oPos:nDebito:=0
  IF lResp

//    IF nVuelto>0
//       EJECUTAR("DISPRUN","EFECTIVO "+oDp:cMoneda+"<"+LSTR(nRecibe)+">","Su Vuelto <"+LSTR(nVuelto)+">")
//    ELSE
//       EJECUTAR("DISPRUN","EFECTIVO "+LSTR(nRecibo),"Gracias por su Compra")
//    ENDIF

  ENDIF

RETURN lResp

FUNCTION VUELTO()
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
/*
FUNCTION KeyBanco(nKey)
  LOCAL cBanco:=oBanco:VarGet(),nAt:=0,cFind,nLen:=Len(cBanco),cGet,nLenOrg:=LEN(ALLTRIM(cBanco))

  cBanco:=ALLTRIM(cBanco)+CHR(nKey)

//  WHILE LEN(cBanco)>1 .AND. nAt=0
    nAt:=ASCAN(oDp:aBancos,{|a,n|UPPE(cBanco)=LEFT(UPPE(a[1]),LEN(cBanco))})
    cBanco:=LEFT(cBanco,LEN(cBanco)-1)
//  ENDDO

//  cBanco:=ALLTRIM(cBanco)+CHR(nKey)
//  nLenOrg:=LEN(ALLTRIM(cBanco))-1

//  cBanco:=ALLTRIM(cBanco)+CHR(nKey)
//  nLen:=Len(cBanco)

  IF nAt>0 //.AND. LEN(cBanco)>1

    cGet:=ALLTRIM(oBanco:VarGet())
    cGet:=cGet+SUBS(oDp:aBancos[nAt,1],nLenOrg+2,nLen)
    cGet:=PADR(cGet,nLen)
    Eval(oBanco:bSetGet,cGet)
    oBanco:Refresh(.F.)
    oBanco:oGet:Pos:=nLenOrg+1
  ENDIF

  cBanco:=ALLTRIM(cBanco)
  WHILE LEN(cBanco)>1 .AND. nAt=0
    nAt:=ASCAN(oDp:aBancos,{|a,n|UPPE(cBanco)=LEFT(UPPE(a[1]),LEN(cBanco))})
    cBanco:=LEFT(cBanco,LEN(cBanco)-1)
  ENDDO

  IF nAt>0

    oBrw:GoTop(.T.)
    oBrw:nArrayAt:=nAt
//    oDp:oFrameDp:SetText(oBrw:aArrayData[nAt,1])

  ENDIF


RETURN .F.
*/
/*
FUNCTION VALBANCO()

  LOCAL cTel:=SQLGET("BAN_TELEF1,BAN_TELEF2,BAN_TELEF3 FROM DPBANCODIR WHERE BAN_NOMBRE"+GetWhere("=",cBanco))
  DISPVUELTO()
  
RETURN .T.
*/
FUNCTION DISPVUELTO()
RETURN .T.



FUNCTION KeyBanco(nKey,oBanco)
  LOCAL cBanco:=oBanco:VarGet(),nAt,cFind,nLenOrg:=Len(cBanco),cGet,nLenOrg:=LEN(ALLTRIM(cBanco))
  LOCAL nPos  :=oBanco:oGet:Pos,nLen

  IF nKey<30
     RETURN .F.
  ENDIF

  cBanco:=UPPE(LEFT(cBanco,nPos-1)+CHR(nKey))
  nLen  :=Len(cBanco)

  DEFAULT oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE ")

  nAt:=ASCAN(oDp:aBancos,{|a,n|cBanco=UPPE(LEFT(UPPE(a[1]),nLen))})

  IF nAt>0 

    cGet:=LEFT(oBanco:VarGet(),nPos)
//  cGet:=cGet+SUBS(oDp:aBancos[nAt,1],nPos,nLenOrg)
    cGet:=cGet+SUBS(oDp:aBancos[nAt,1],nPos+1,nLenOrg)
    cGet:=LEFT(cGet,nPos)+SUBS(cGet,nPos+1,LEN(cGet))
    cGet:=PADR(cGet,nLenOrg)
    oBanco:VarPut(cGet,.T.) // Eval(oBanco:bSetGet,cGet)
   //  oBanco:Refresh(.F.)
    oBanco:oGet:Pos:=nPos // nLenOrg+1

  ENDIF

  nAt:=ASCAN(oBrw:aArrayData,{|a,n|cBanco=UPPE(LEFT(UPPE(a[1]),nLen))})

  IF nAt>0

    oBrw:GoTop(.T.)
    oBrw:nArrayAt:=nAt
//    oDp:oFrameDp:SetText(oBrw:aArrayData[nAt,1])

  ENDIF


RETURN .F.

/*
// Buscar si el Banco Existe
*/
FUNCTION VALBANCO(oBcoChq)
   
   LOCAL cBcoGet:=oBcoChq:Varget(),nAt,nLen:=LEN(ALLTRIM(cBcoGet)),cBcoGetOrg:=cBcoGet
   LOCAL oTable

   IF oBcoChq:nLastKey=VK_UP
      RETURN .T.
   ENDIF

   IF Empty(cBcoGet)
     RETURN .F.
   ENDIF

   IF Empty(oDp:aBancos)
     oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE ")
   ENDIF

   cBcoGet:=UPPE(cBcoGet)

   nAt:=ASCAN(oDp:aBancos,{|a,n|cBcoGet=LEFT(UPPE(a[1]),nLen)})

   IF nAt>0
     oBcoChq:VarPut(oDp:aBancos[nAt,1],.T.)
     RETURN .T.
   ENDIF

   IF !MsgYesNo("Banco "+ALLTRIM(cBcoGetOrg)+" no Existe","Desea Agregarlo")
      oBcoChq:KeyBoard(VK_F6)
      RETURN .T.
   ENDIF

   oTable:=OpenTable("SELECT * FROM DPBANCODIR WHERE BAN_NOMBRE"+GetWhere("=",cBcoGetOrg),.T.)

   IF oTable:RecCount()=0
      oTable:Append()
      oTable:Replace("BAN_NOMBRE",cBcoGetOrg)
      oTable:Commit()
   ENDIF

   oTable:End()

   oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE ")

RETURN .T.


FUNCTION VALDEBITO()
IF !EMPTY(cDebito) .And. !EMPTY(cMarcaFin) .And. !EMPTY(cBanco) .And. !EMPTY(cPosTD)
   lResp:=.T.
   oDlg:End()    
ELSE
   MensajeErr("Ingrese Nº de Tarjeta, Marca y Banco, por favor.")
ENDIF
RETURN lResp

// EOF

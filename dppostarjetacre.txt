// Programa   : DPPOSTARJETACRE
// Fecha/Hora : 27/10/2005 16:24:21
// Prop¢sito  : Generar el Pago con Tarjeta de Crédito
// Creado Por : Juan Navas
// Modificado : Marlon Ramos (28-05-2008) Repetía el pago en los siguientes tickets
// Llamado por: DPPOS01
// Aplicaci¢n : VENTAS 
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPos)
  LOCAL nMonto :=12003,lResp:=.F.,oBrw,oCol,oWnd,oGrp,oLetra,oBrush,oRecibe
  LOCAL nRecibe:=0,oDlg,oFont,oBtn,oFontB,oFont2,oFont3,oFont4,oFont5
  LOCAL nTop:=206,nLeft:=05,nWidth:=567-275,nHeight:=303,cEnletras:=""
  LOCAL nClrPane  :=13366014

  // Marlon Ramos (28-05-2008) LOCAL oVuelto,nVuelto:=0,oCheque,oBanco
  LOCAL oVuelto,nVuelto:=0,oCredito,oBanco

  LOCAL cCredito   := SPACE(12)
  LOCAL cBancoCre    := SPACE(40) // Banco
  LOCAL cPicture  := "999,999,999.99"
  LOCAL nClrBlink := 32768   // blinking color
  LOCAL nInterval := 500-100      // blinking interval in milliseconds
  LOCAL nStop     := 0            // blinking limit to stop in milliseconds
  LOCAL aDesglose := {}
  LOCAL nClrPane1 := 16770764
  LOCAL nClrPane2 := 16566954
  LOCAL cCredito  := SPACE(12)
  LOCAL cBancoCre := SPACE(40)

  /* 03-06-2008 Marlon Ramos (Evitar que duplique las marcas financieras)
   LOCAL aMarcaFin :=ATABLE(" SELECT CXI_MARCA FROM DPBANCODIRPOR WHERE CXI_CODINS='TAR' AND CXI_MARCA<>'<Todas>'")
  */
  LOCAL aMarcaFin :=ATABLE(" SELECT DISTINCT CXI_MARCA FROM DPBANCODIRPOR WHERE CXI_CODINS='TAR' AND CXI_MARCA<>'<Todas>'")
  // Fin 03-06-2008 Marlon Ramos 

  LOCAL cSql      :=CLPCOPY(oDp:cSql)

  LOCAL cMarcaFin 
  LOCAL aPosBco   :=ATABLE(" SELECT PVB_CODIGO FROM DPPOSBANCARIO WHERE PVB_ACTIVO=1 ")
  LOCAL cPosTC   ,oPosTC

  IIF( Empty(aPosBco ) , AADD(aPosBco ,"Ninguno") , NIL)   

  cPosTC:=aPosBco[1]

  DEFAULT oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE")

  IF Empty(aMarcaFin)
    /* 03-06-2008 Marlon Ramos (Evitar que duplique las marcas financieras)
    aMarcaFin :=ATABLE(" SELECT MFN_NOMBRE FROM DPMARCASFINANC WHERE MFN_NOMBRE<>'<Todas>'")
    */
    aMarcaFin :=ATABLE(" SELECT DISTINCT MFN_NOMBRE FROM DPMARCASFINANC WHERE MFN_NOMBRE<>'<Todas>'")
  // Fin 03-06-2008 Marlon Ramos 
  ENDIF

  IF Empty(aMarcaFin)
    AADD(aMarcaFin,"Indefinida")
  ENDIF

  cMarcaFin:= aMarcaFin[1] 

  oDp:aBancoDir:={}

  aDesglose:={}
  AADD(aDesglose,{0,"X",0,"=",0})

  IF ValType(oPos)!="O"
     nMonto:=12212
  ELSE
     oWnd  :=oPos:oWnd
     nMonto:=oPos:nNeto
  ENDIF

  nRecibe:=nMonto

  // ? nRecibe
  DEFINE FONT oFont  NAME "MS Sans Serif" SIZE 0, -16 BOLD
  DEFINE FONT oFontB NAME "MS Sans Serif" SIZE 0, -16 BOLD  
  DEFINE FONT oFont2 NAME "MS Sans Serif" SIZE 0, -12 BOLD 
  DEFINE FONT oFont3 NAME "MS Sans Serif" SIZE 0, -08 
  DEFINE FONT oFont4 NAME "MS Sans Serif" SIZE 0, -08 BOLD
  DEFINE FONT oFont5 NAME "MS Sans Serif" SIZE 0, -06 BOLD

  DEFINE BRUSH oBrush;
               FILE "BITMAPS\PAGOCREDITO1.BMP"

  DEFINE DIALOG oDlg TITLE "Recibido";
         STYLE nOr( WS_POPUP, WS_VISIBLE );
         BRUSH oBrush

  oDlg:lHelpIcon:=.F.


  @ 1.0,3 STSAY "Monto";
          RIGHT SIZE 90,10;
          COLORS CLR_BLUE FONT oFont

  @ 11.6,05 STSAY "Número";
            SIZE 35,10;
            COLORS CLR_BLUE FONT oFont5

  @ 11.6,29 STSAY oDp:xDPPOSBANCARIO;
            SIZE 85,10;
            COLORS CLR_BLUE FONT oFont5

  @ 15.3,05 STSAY "Banco";
            SIZE 35,10;
            COLORS CLR_BLUE FONT oFont5

  @ 07.7,05 STSAY oDp:xDPMARCASFINANC;
            SIZE 60,10;
            COLORS CLR_BLUE FONT oFont5

  @ 1.9,2 SAY TRAN(nMonto,"999,999,999.99");
            RIGHT;
            SIZE 100,13;
            COLOR CLR_HBLUE,CLR_YELLOW;
            FONT oFontB RIGHT BORDER


  @ 4.0,1.5 COMBOBOX oMarca VAR cMarcaFin ITEMS aMarcaFin;
            SIZE 100,NIL;
            FONT oFont5;
            WHEN LEN(aMarcaFin)>1

  // 28=05=2008 Marlon Ramos @ 6.0,1.5 GET oCheque VAR cCredito
  @ 6.0,1.5 GET oCredito VAR cCredito;
             SIZE 60,10 FONT oFont4

  @ 5.6,09.5 COMBOBOX oPosTC VAR cPosTC ITEMS aPosBco;
            SIZE 64,NIL;
            FONT oFont5;
            WHEN LEN(aPosBco)>1


  // Uso   : Archivo de la BaLanza
  //
  @ 7.8, 1.5 BMPGET oBanco  VAR cBancoCre;
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (SELBANCO());
             VALID VALBANCO(oBanco);
             SIZE 100,10 FONT oFont4

  oBanco:bKeyDown:={|nKey|KeyBanco(nKey,oBanco)}

     
  @09.2+.5, 1  SBUTTON oBtn ;
          SIZE 50, 20 FONT oFont2;
          FILE "BITMAPS\OK2.BMP" ;
          LEFT PROMPT "Aceptar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (VALCREDITO())

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

  ACTIVATE DIALOG oDlg ON INIT oDlg:Move(nTop,nLeft,nWidth,nHeight,.T.)

  IF ValType(oPos)="O" .AND. lResp

    oPos:nCredito   :=nMonto
    oPos:cCredito   :=cCredito
    oPos:cBcoCre    :=cBancoCre
    oPos:cMarcaTC   :=cMarcaFin
    oPos:cPosTC     :=cPosTC

    oPos:SaveTicket(.T.)
// ? nMonto
  ENDIF
oPos:nCredito:=0
RETURN lResp

FUNCTION VUELTO()
  LOCAL lResp:=.T.
RETURN lResp

/*
// Seleccionar Banco
*/
FUNCTION SELBANCO()
   LOCAL cNombre:="",nLen:=40

   cNombre:=EJECUTAR("DPPOSSELBANCO")


   IF !EMPTY(cNombre)

     cBancoCre:=PADR(cNombre,nLen)
     oBanco:VarPut(cNombre,.T.)
     oBanco:KeyBoard(13)

   ENDIF

   oBanco:Refresh(.T.)
   SysRefresh(.T.)

RETURN .T.

/*
FUNCTION KeyBanco(nKey)
  LOCAL cBancoCre:=oBanco:VarGet(),nAt,cFind,nLen:=Len(cBancoCre),cGet,nLenOrg:=LEN(ALLTRIM(cBancoCre))

  cBancoCre:=ALLTRIM(cBancoCre)+CHR(nKey)

  nAt:=ASCAN(oDp:aBancos,{|a,n|UPPE(cBancoCre)=LEFT(UPPE(a[1]),LEN(cBancoCre))})

  IF nAt>0 //.AND. LEN(cBancoCre)>1

    cGet:=ALLTRIM(oBanco:VarGet())
    cGet:=cGet+SUBS(oDp:aBancos[nAt,1],nLenOrg+2,nLen)
    cGet:=PADR(cGet,nLen)
    Eval(oBanco:bSetGet,cGet)
    oBanco:Refresh(.F.)
    oBanco:oGet:Pos:=nLenOrg+1

  ENDIF

RETURN .F.

FUNCTION VALBANCO()

  LOCAL cTel:=SQLGET("BAN_TELEF1,BAN_TELEF2,BAN_TELEF3 FROM DPBANCODIR WHERE BAN_NOMBRE"+GetWhere("=",cBancoCre))
  // Valida el banco

//   ? cTel,cBancoCre
//oDp:aRow[1],oDp:aRow[2]
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

//ViewArray(oDp:aBancos,,,.F.)

   nAt:=ASCAN(oDp:aBancos,{|a,n|cBcoGet=LEFT(UPPE(a[1]),nLen)})

   IF nAt>0
     oBcoChq:VarPut(oDp:aBancos[nAt,1],.T.)
     RETUN .T.
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


FUNCTION VALCREDITO()
IF !EMPTY(cCredito) .And. !EMPTY(aPosBco) .And. !EMPTY(aMarcaFin) .And. !EMPTY(cBancoCre)
   lResp:=.T.
   oDlg:End()    
ELSE
   MensajeErr("Ingrese Nº de Cheque y Banco, por favor.")
ENDIF
RETURN lResp

// EOF

// Programa   : DPPOSMESAPAGO
// Fecha/Hora : 26/05/2006 06:17:14
// Propósito  : Realizar Pago por Mesa
// Creado Por : Juan Navas
// Llamado por: DPPOSMESACTA
// Aplicación : Ventas
// Tabla      : DPPOSCOMANDA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cMesa,oComanda,lPedido)
  LOCAL aData:={},I,aTotal:={},nTotal:=0,aTexto:={},nColor,aLine:={},oGet,lRet:=.F.,lGrabar:=.F.
  LOCAL aDesglose:={}
  LOCAL oDlgP,oFontB,oCesta,oEfectivo,oBtn,oFont,oBtnSave,oBrwMp,oCol,oFont4
  LOCAL oCheque,oBcoChq,oTable
  LOCAL nWidth:=220,nHeight:=200
  LOCAL lPagEle:=.F.


  LOCAL oTarDB,oBcoTDB,oNumTDB
  LOCAL oTarCR,oBcoTCR,oNumTCR
  LOCAL oTarCT,oBcoTCT,oNumTCT
  LOCAL oRif,oNombre,oDir1,oDir2,oTel,oVuelto

  LOCAL nCesta  :=0,nEfectivo:=0,nCheque:=0,nTarDB:=0,nTarCR:=0,nVuelto:=0,nTarCT:=0,cPedido
  LOCAL cCheque :=SPACE(10),cBcoChq:=SPACE(40)
  LOCAL cTarCR  :=SPACE(10),cBcoTCR:=SPACE(40),cTCRMar:=SPACE(25),cTCPos:=SPACE(4)
  LOCAL cTarDB  :=SPACE(10),cBcoTDB:=SPACE(40),cTDBMar:=SPACE(25),cTDPos:=SPACE(4)
  LOCAL cTarCT  :=SPACE(10),cBcoTCT:=SPACE(40),cTCTMar:=SPACE(25),cCTPos:=SPACE(4)

  LOCAL cRIF      :=SPACE(10),cNombre:=SPACE(30)
  LOCAL cDir1     :=SPACE(40),cDir2:=SPACE(40),cTel:=SPACE(14)
  LOCAL cCodVen   :=STRZERO(1,6),cPicture:="99,999,999.99",cTitulo,cTipDoc:="TIK",cNumDoc
  LOCAL nClrPane1 := 16770764
  LOCAL nClrPane2 := 16566954
  LOCAL cDirE1    :="",cDirE2:="",cDirE3:="",cZona:="",cMuni:="" 

  LOCAL aMarcaTC  :=ATABLE(" SELECT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='TAR'")
  LOCAL aMarcaTD  :=ATABLE(" SELECT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='TDB'")
  LOCAL aMarcaCT  :=ATABLE(" SELECT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='CTKE'")
  LOCAL aPosBco   :=ATABLE(" SELECT PVB_CODIGO FROM DPPOSBANCARIO WHERE PVB_ACTIVO=1 ")

  LOCAL cMarcaTC , cMarcaTD , cMarcaCT
  LOCAL oMarcaTC , oMarcaTD , oMarcaCT
  LOCAL cPosTC   , cPosTD   , cPosCT
  LOCAL oPosTC   , oPosTD   , oPosCT
  LOCAL oBtnIva10 // 17/02/2017
  LOCAL oTotal    // 17/02/2017


  oDp:lPagEle:=lPagEle

  IIF( Empty(aPosBco ) , AADD(aPosBco ,"Ninguno") , NIL)   
  IIF( Empty(aMarcaTC) , AADD(aMarcaTC,"Ninguno") , NIL)
  IIF( Empty(aMarcaTD) , AADD(aMarcaTD,"Ninguno") , NIL)
  IIF( Empty(aMarcaCT) , AADD(aMarcaCT,"Ninguno") , NIL)

  cMarcaTC:=aMarcaTC[1]
  cMarcaTD:=aMarcaTD[1]
  cMarcaCT:=aMarcaCT[1]

  cPosTC  :=aPosBco[1]
  cPosTD  :=aPosBco[1]
  cPosTC  :=aPosBco[1]

  IF ValType(oComanda)="O"
    cCodVen:=oComanda:COM_MESERO
    cZona  :=oComanda:cZona
    cMuni  :=oComanda:cMunici
  ENDIF

  DEFAULT cMesa  :=STRZERO(10,10),;
          lPedido:=.T.

  // JN 15/05/2018

  DEFAULT oComanda:cRif:="" 


  DEFAULT oDp:lIVA10:=!(oDp:dFecha<CTOD("24/12/2016") .AND. oDp:dFecha>CTOD("24/12/2016")+90)
 

  AADD(aDesglose,{0,"X",0,"=",0})

  IF ALLDIGIT(cMesa)
    cMesa:=STRZERO(VAL(cMesa),LEN(cMesa))
  ENDIF

  cCodVen:=MYSQLGET("DPPOSCOMANDA","COM_MESERO","COM_MESA"+GetWhere("=",cMesa))

  // Obtiene el Monto de la Cuenta
  oDp:nServicio:=0
  oDp:nIva     :=0

  IF !lPedido

    nTotal:=EJECUTAR("DPPOSMESAPRN",cMesa,oComanda,.T.) 
    cTitulo:="Recibir Pago de la Mesa "

  ELSE

    cPedido:=cMesa
    nTotal:=EJECUTAR("DPPOSPEDPRN",cMesa,oComanda,.T.)
    cTitulo:="Indicar Pago del Pedido "+cMesa
    cCodVen:=MYSQLGET("DPVENDEDOR","VEN_CODIGO","1=1 LIMIT 1")

    // Buscamos los Datos del Cliente
    cRif  :=MYSQLGET("DPPOSCOMANDA","COM_RIF","COM_PEDIDO"+GetWhere("=",cMesa)+" LIMIT 1")
    oTable:=OpenTable("SELECT * FROM DPCLIENTESDELY WHERE CDL_RIF"+GetWhere("=",cRif),.T.)

    IF oTable:RecCount()>0
      cRif   :=oTable:CDL_RIF
      cNombre:=oTable:CDL_NOMBRE
      cDir1  :=oTable:CDL_DIR1
      cDir2  :=oTable:CDL_DIR2
      cDir3  :=oTable:CDL_DIR3
      cTel   :=oTable:CDL_TEL1

      cDirE1:=oTable:CDL_DIREN1
      cDirE2:=oTable:CDL_DIREN2
      cDirE3:=oTable:CDL_DIREN3

    ENDIF

    oTable:End()

  ENDIF

  nTotal:=IIF( nTotal=0 , 172504 , nTotal )

  AADD(aTexto , "Monto a Pagar")
  AADD(aTexto , "Cesta Ticket Billete")
  AADD(aTexto , "Cheque")
  AADD(aTexto , "Tarjeta de Crédito")
  AADD(aTexto , "Tarjeta de Débito")
  AADD(aTexto , "C.Ticket Tarjeta")
  AADD(aTexto , "Efectivo")

  DEFINE FONT oFontB NAME "MS Sans Serif" SIZE 0, -13 BOLD
  DEFINE FONT oFont  NAME "MS Sans Serif" SIZE 0, -10 BOLD
  DEFINE FONT oFont4 NAME "MS Sans Serif" SIZE 0, -08 BOLD

  DEFINE DIALOG oDlgP TITLE cTitulo+" con oDp:lPagEle";
         SIZE 790,400;
         COLOR NIL,oDp:nGris

  oDlgP:lHelpIcon:=.F.

  FOR I=1 TO LEN(aTexto)

    nColor:=iif( I%2=0, 16773862, 16771538 )
    
    @ .5.0 + ((I-1)*.8),.5 SAY aTexto[I]+":" RIGHT;
                          SIZE 70,10.5;
                          FONT oFontB;
                          COLOR CLR_BLACK,nColor

    AADD(aLine,ATAIL(oDlgP:aControls):nTop)

  NEXT I

  @ aLine[1],075 SAY oTotal;
                 PROMPT TRAN(nTotal,"999,999,999.99") RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 COLOR CLR_WHITE,9408399

  @ aLine[2],075 GET oCesta VAR nCesta;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nCesta+nEfectivo,oCheque,oCesta);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL

  @ aLine[2]+2.5,146 SAY " Referencia " PIXEL ;
                 SIZE 60,08.5 FONT oFontB;
                 COLOR CLR_WHITE,4144959

  @ aLine[3]+2.5,207 SAY " "+oDp:xDPMARCASFINANC PIXEL ;
                 SIZE 76,08.5 FONT oFontB;
                 COLOR CLR_WHITE,4144959

  @ aLine[2]+2.5,284 SAY " "+oDp:xDPBANCODIR PIXEL ;
                 SIZE 80,08.5 FONT oFontB;
                 COLOR CLR_WHITE,4144959

  @ aLine[3]+2.5,365 SAY oDp:xDPPOSBANCARIO   PIXEL ;
                 SIZE 30,08.5 FONT oFontB;
                 COLOR CLR_WHITE,4144959

     
/*
// PAGO CON CHEQUE
*/

  @ aLine[3],075 GET oCheque VAR nCheque;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nCheque+nCesta+nEfectivo,oTarCR,oCheque);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL

  @ aLine[3],146 GET oNumChq VAR cCheque;
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN nCheque>0

  @ aLine[3],284 BMPGET oBcoChq VAR cBcoChq;
                 SIZE 80,10.5;
                 FONT oFontB PIXEL;
                 WHEN nCheque>0;
                 NAME "BITMAPS\FIND.BMP";
                 ACTION FINDBANCO(oBcoChq);
                 VALID VALBANCO(oBcoChq)

  oBcoChq:bKeyDown:={|nKey|KeyBanco(nKey,oBcoChq)}

/*
// TARJETA DE CREDITO
*/

  @ aLine[4],075 GET oTarCR VAR nTarCR;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nCesta+nCheque+nTarCR+nEfectivo,oTarDB,oTarCR);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL

  @ aLine[4],146 GET oNumTCR VAR cTarCR;
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCR>0

  @ aLine[4],207 COMBOBOX oMarcaTC VAR cMarcaTC ITEMS aMarcaTC;
                 VALID PUTBANCO(cMarcaTC,oBcoTCR,"TAR");
                 ON CHANGE PUTBANCO(cMarcaTC,oBcoTCR,"TAR");
                 SIZE 76,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCR>0 .AND. LEN(aMarcaTC)>1

  @ aLine[4],284 BMPGET oBcoTCR VAR cBcoTCR;
                 SIZE 80,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCR>0;
                 NAME "BITMAPS\FIND.BMP";
                 ACTION FINDBANCO(oBcoTCR);
                 VALID VALBANCO(oBcoTCR)

  oBcoTCR:bKeyDown:={|nKey|KeyBanco(nKey,oBcoTCR)}


  @ aLine[4],365 COMBOBOX oPosTC VAR cPosTC ITEMS aPosBco;
                 VALID 1=1;
                 SIZE 30,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCR>0 .AND. LEN(aPosBco)>1


/*
// Tarjeta de Débito
*/

  @ aLine[5],075 GET oTarDB VAR nTarDB;
                 PICTURE "999,999,999.99";
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL

  @ aLine[5],146 GET oNumTDB VAR cTarDB;
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarDB>0

  @ aLine[5],207 COMBOBOX oMarcaTD VAR cMarcaTD ITEMS aMarcaTD;
                 VALID PUTBANCO(cMarcaTD,oBcoTDB,"TDB");
                 ON CHANGE PUTBANCO(cMarcaTD,oBcoTDB,"TDB");
                 SIZE 76,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarDB>0 .AND. LEN(aMarcaTD)>1

  @ aLine[5],284 BMPGET oBcoTDB VAR cBcoTDB;
                 SIZE 80,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarDB>0;
                 NAME "BITMAPS\FIND.BMP";
                 ACTION FINDBANCO(oBcoTDB);
                 VALID VALBANCO(oBcoTDB)

  oBcoTDB:bKeyDown:={|nKey|KeyBanco(nKey,oBcoTDB)}


  @ aLine[5],365 COMBOBOX oPosDB VAR cPosTC ITEMS aPosBco;
                 VALID 1=1;
                 SIZE 30,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarDB>0 .AND. LEN(aPosBco)>1


  /*
  // CESTA TICKET TARJETA
  */

  @ aLine[6],075 GET oTarCT VAR nTarCT;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nCesta+nCheque+nTarCT+nEfectivo,oTarDB,oTarCT);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL

  @ aLine[6],146 GET oNumTCT VAR cTarCT;
                 SIZE 60,10.5;
                 VALID VALNUMDOC(cTarCT,oMarcaCT);
                 FONT oFontB PIXEL;
                 WHEN nTarCT>0

  @ aLine[6],207 COMBOBOX oMarcaCT VAR cMarcaCT ITEMS aMarcaCT;
                 VALID PUTBANCO(cMarcaCT,oBcoTCT,"CTKE");
                 ON CHANGE PUTBANCO(cMarcaCT,oBcoTCT,"CTKE");
                 SIZE 76,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCT>0 .AND. LEN(aMarcaCT)>1

  @ aLine[6],284 BMPGET oBcoTCT VAR cBcoTCT;
                 SIZE 80,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCT>0;
                 NAME "BITMAPS\FIND.BMP";
                 ACTION FINDBANCO(oBcoTCT);
                 VALID VALBANCO(oBcoTCT)

  oBcoTCT:bKeyDown:={|nKey|KeyBanco(nKey,oBcoTCT)}



  @ aLine[6],365 COMBOBOX oPosCT VAR cPosCT ITEMS aPosBco;
                 VALID 1=1;
                 SIZE 30,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCT>0 .AND. LEN(aPosBco)>1


  @ aLine[7],075 GET oEfectivo VAR nEfectivo;
                 PICTURE "999,999,999.99";
                 VALID VALEFECTIVO(nEfectivo);
                 WHEN !oDp:lPagEle;
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL


  @ aLine[1]+100,042 GET oRif VAR cRif;
                     VALID VALRIF();
                     SIZE 40,10;
                     FONT oFontB PIXEL

  @ oRif:nTop,.5 SAY oDp:cNit+":";
                     RIGHT;   
                     SIZE 40,10;
                     FONT oFontB PIXEL;
                     COLOR NIL,oDp:nGris

  @ aLine[1]+111,042 GET oNombre VAR cNombre;
                     SIZE 130,10;
                     FONT oFontB PIXEL;
                     WHEN !Empty(cRif)

  @ oNombre:nTop,.5 SAY "Nombre:";
                    RIGHT;   
                    SIZE 40,10;
                    FONT oFontB PIXEL;
                    COLOR NIL,oDp:nGris

  @ aLine[1]+122,042 GET oDir1   VAR cDir1;
                     SIZE 130,10;
                     FONT oFontB PIXEL;
                     WHEN !Empty(cRif)

  @ oDir1:nTop,.5 SAY "Dirección:";
                    RIGHT;   
                    SIZE 40,10;
                    FONT oFontB PIXEL;
                    COLOR NIL,oDp:nGris

  @ aLine[1]+133,042 GET oDir2   VAR cDir2;
                     SIZE 130,10;
                     FONT oFontB PIXEL;
                     WHEN !Empty(cRif)

  @ aLine[1]+144,042 GET oTel  VAR cTel;
                     SIZE 070,10;
                     VALID (DPFOCUS(oBtnSave),.T.);
                     FONT oFontB PIXEL;
                     WHEN !Empty(cRif)

  @ oTel:nTop,.5 SAY "Teléfono:";
                      RIGHT;   
                      SIZE 40,10;
                      FONT oFontB PIXEL;
                      COLOR NIL,oDp:nGris
  
  @ aLine[2],135 BUTTON "=";
                 ACTION (SETTOTAL(oCesta),EJECUTAR("CALCESTATICKET",nTotal,oCesta,oEfectivo));
                 SIZE 10,oEfectivo:nHeight PIXEL FONT oFontB

  @ aLine[3],135 BUTTON "=";
                 ACTION SETTOTAL(oCheque);
                 SIZE 10,oEfectivo:nHeight PIXEL FONT oFontB

  @ aLine[4],135 BUTTON "=";
                 ACTION SETTOTAL(oTarCR);
                 SIZE 10,oEfectivo:nHeight PIXEL FONT oFontB

  @ aLine[5],135 BUTTON "=";
                 ACTION (SETTOTAL(oTarDB),;
                         VALNUMDOC(NIL,oMarcaTD));
                 SIZE 10,oEfectivo:nHeight PIXEL FONT oFontB

  @ aLine[6],135 BUTTON "=";
                 ACTION (SETTOTAL(oTarCT),;
                         VALNUMDOC(NIL,oMarcaCT));
                 SIZE 10,oEfectivo:nHeight PIXEL FONT oFontB

  @ aLine[7],135 BUTTON "=";
                 ACTION SETTOTAL(oEfectivo);
                 SIZE 10,oEfectivo:nHeight PIXEL FONT oFontB



IF oDp:lIVA10 .AND. Year(oDp:dFecha)=2017

  @13.5,03 SBUTTON oBtnIva10;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\IVA10%.BMP" NOBORDER;
           LEFT PROMPT "";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION SETIVA10() CANCEL

  oBtnIva10:lCancel :=.T.
  oBtnIva10:cToolTip:="IVA Pago Electrónico"
  oBtnIva10:cMsg    :=oBtnIva10:cToolTip

ENDIF


  @13.5,13+4 SBUTTON oBtnSave;
         SIZE 45, 20 FONT oFont;
         FILE "BITMAPS\XSAVE.BMP","BITMAPS\XSAVE2.BMP","BITMAPS\XSAVEG.BMP" NOBORDER;
         LEFT PROMPT "Grabar";
         COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
         ACTION (lGrabar:=VALTICKET()) CANCEL;
         WHEN (nCesta+nCheque+nTarCR+nTarDB+nTarCT+nEfectivo)>=nTotal

  oBtnSave:lCancel :=.T.
  oBtnSave:cToolTip:="Grabar "
  oBtnSave:cMsg    :=oBtnSave:cToolTip


  @13.5,23+5 SBUTTON oBtn ;
         SIZE 45, 20 FONT oFont;
         FILE "BITMAPS\XSALIR.BMP" NOBORDER;
         LEFT PROMPT "Cerrar";
         COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
         ACTION (lGrabar:=.F.,lRet:=.F.,oDlgP:End()) CANCEL

  oBtn:lCancel :=.T.
  oBtn:cToolTip:="Cerrar "
  oBtn:cMsg    :=oBtn:cToolTip

  oBrwMp:=TXBrowse():New(oDlgP )
  oBrwMp:SetArray( aDesglose ,.F.)
  oBrwMp:lHScroll       := .F.
  oBrwMp:lVScroll       := .F.
  oBrwMp:nFreeze        := 1
  oBrwMp:oFont          := oFont4
  oBrwMp:lFooter        := .F.
  oBrwMp:lRecordSelector:= .F.
  oBrwMp:lFooter        := .T.

  oCol:=oBrwMp:aCols[1]
  oCol:cHeader      := "Moneda"
  oCol:nWidth       := 080
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrwMp:aArrayData[oBrwMp:nArrayAt,1],cPicture)}
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrwMp:aCols[2]
  oCol:cHeader      := "X"
  oCol:nWidth       := 15
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrwMp:aCols[3]
  oCol:cHeader      := "Cant."
  oCol:nWidth       := 45
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrwMp:aCols[4]
  oCol:cHeader      := "="
  oCol:nWidth       := 15
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrwMp:aCols[5]
  oCol:cHeader      := "Total"
  oCol:nWidth       := 120+20
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrwMp:aArrayData[oBrwMp:nArrayAt,5],cPicture)}
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}
  oCol:cFooter      := "0.00"   

  AEVAL(oBrwMp:aCols,{|oCol,n|oCol:oHeaderFont:=oFont4})

  oBrwMp:bClrStd   := {||{0, iif( oBrwMp:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }
  oBrwMp:bClrHeader:= {||{CLR_BLACK,14671839 }}

  oBrwMp:CreateFromCode()
  
  ACTIVATE DIALOG oDlgP CENTERED ON INIT (oBrwMp:Move(170,352+062,292+20,220,.T.),;
                                          oBrwMp:SetColor(nClrPane2,nClrPane1),;
                                          DpFocus(oEfectivo),.F.)

  IF lGrabar

     oDp:cPedWhere:=""
     oDp:cDocWhere:=""

     GRABARTICKET() 

     IF lPedido

        oDp:cPedWhere:=" DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                       " DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                       " DOC_NUMERO"+GetWhere("=",cNumDoc)

     ENDIF

  ENDIF

  AEVAL(oDlgP:aControls,{ |o,n| IIF( "GET"$o:ClassName() , o:bValid:=BloqueCod(".T."),NIL)})
                                
 // DESTROY(oDlgP,.T.)

RETURN lRet

FUNCTION VALCESTA(nMonto,oGetNext,oGet)
  LOCAL nResiduo:=0
  LOCAL nPagado :=0

  IF ValType(oGet)!="O"
     RETURN .T.
  ENDIF

  IF !oGet:nLastKey=13
     RETURN .T.
  ENDIF

  nPagado:=INT((nCesta+nEfectivo+nCheque+nTarDB+nTarCR)*100)/100

  IF nMonto=0 
     RETURN .T.
  ENDIF
  
  nResiduo:=nTotal-nMonto

  IF nResiduo>0
     oGetNext:VarPut(nResiduo,.T.)
     nVuelto:=0
  ELSE
     nVuelto:=nResiduo
  ENDIF

RETURN .T.

FUNCTION SETTOTAL(oGet)
   LOCAL aControl:={oCesta,oEfectivo,oCheque,oTarCR,oTarDB,oTarCT}

   AEVAL(aControl,{|O,n| o:VarPut(0,.T.) })

   oGet:VarPut(nTotal,.T.)
   oGet:KeyBoard(13)
   
RETURN .T.

FUNCTION FINDBANCO(oBco)

  LOCAL cBanco

  cBanco:=EJECUTAR("REPBDLIST","DPBANCODIR","BAN_NOMBRE")

  IF !Empty(cBanco)
    oBco:VarPut(cBanco,.T.)
    oBco:KeyBoard(13)
  ENDIF

RETURN .T.

/*
// RIF
*/
FUNCTION VALRIF()
  
  LOCAL oTable

  IF Empty(cRif)
    DPFOCUS(oBtnSave)
  ENDIF

  oTable:=OpenTable("SELECT CCG_RIF,CCG_NOMBRE,CCG_DIR1,CCG_DIR2,CCG_TEL1 "+;
                    "FROM DPCLIENTESCERO WHERE CCG_RIF"+GetWhere("=",cRif))

  IF oTable:Recno()>0

    oNombre:VarPut(oTable:CCG_NOMBRE,.T.)
    oDir1:VarPut(oTable:CCG_DIR1,.T.)
    oDir2:VarPut(oTable:CCG_DIR2,.T.)
    oTel:VarPut(oTable:CCG_TEL1,.T.)

  ENDIF

  oTable:End()

RETURN .T.

/*
// Validar Ticket
*/
FUNCTION VALTICKET()
   LOCAL cWhere,oTable,nPagado:=0,oMovi,aData
   LOCAL cCodCli:=STRZERO(0,10),nItem:=0,nPorIva,nCosto

   IF !ISSQLGET("DPCLIENTES","CLI_CODIGO",cCodCli)
      MensajeErr("Cliente "+cCodCli+" No Existe ")
      RETURN .F.
   ENDIF   

   nPagado:=INT((nCesta+nEfectivo+nCheque+nTarDB+nTarCR+nTarCT)*100)/100

   IF nPagado<nTotal
      MensajeErr("Falta "+ALLTRIM(oDp:cMoneda)+" "+ALLTRIM(TRAN(nTotal-nPagado,"99,999,999,999.99")),"Pago Incorrecto")
      RETURN .F.
   ENDIF

   IF ValType(oComanda)="O"
      oComanda:BorrarMesa(cMesa)
   ENDIF

   oDlgP:End()

RETURN .T.
/*
// Validar Efectivo
*/
FUNCTION VALEFECTIVO()

   LOCAL nResiduo:=nTotal-(nCesta+nCheque+nTarCR+nTarDB)

   IF ValType(oEfectivo)!="O"
     RETURN .F.
   ENDIF

   IF oEfectivo:nLastKey=13 .AND. Empty(nEfectivo)
      oEfectivo:VarPut(nResiduo,.T.)
      nEfectivo:=nResiduo
   ENDIF

   nVuelto:=(nTotal-(nCesta+nCheque+nTarCR+nTarDB+nEfectivo))*-1

   IF nVuelto>0
     oCol:cFooter      := TRAN(nVuelto,"999,999,999.99")
     aDesglose:=EJECUTAR("DESGLOSE",nVuelto)
     oBrwMp:aArrayData:=ACLONE(aDesglose)
     oBrwMp:Gotop(.T.)
     oBrwMp:Refresh(.T.)
   ELSE
     nVuelto:=0
   ENDIF

   IF !Empty(cRif)
      oBtnSave:ForWhen()
      oBtnSave:Refresh(.T.)
      DpFocus(oBtnSave)
   ENDIF

RETURN .T.

/*
// Save
*/
FUNCTION GRABARTICKET()
   LOCAL cWhere,cTipDoc:="TIK",oTable,nPagado:=0,oMovi,aData,oDirE,nIva:=0
   LOCAL cCodCli:=STRZERO(0,10),nItem:=0,nPorIva,nCosto,cCodCaja:="",cUnd

   LOCAL cNumero,nLen:=LEN(ALLTRIM(oDp:cTkSerie))

   cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
           "DOC_TIPTRA='D'"

   cNumero:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO",cWhere)

//+" AND LEFT(DOC_NUMERO,1)"+GetWhere("=",oDp:cTkSerie))
/*
   cNumero:=SQLGETMAX("DPDOCCLI","DOC_NUMERO",cWhere+" AND LEFT(DOC_NUMERO,1)"+GetWhere("=",oDp:cTkSerie))

   IF Empty(cNumero)
     cNumero:=oDp:cTkNumero
   ENDIF

   nLen   :=10-LEN(ALLTRIM(oDp:cTkSerie))
   cNumero:=RIGHT(cNumero,nLen)
   cNumero:=ALLTRIM(oDp:cTkSerie)+STRZERO(VAL(cNumero)+1,nLen)
*/

   DpSqlBegin(NIL,NIL,"DPDOCCLI")

   oTable:=OpenTable("SELECT * FROM DPDOCCLI",.F.)
   oTable:AppendBlank()

   oTable:Replace("DOC_CODIGO",cCodCli        )
   oTable:Replace("DOC_CODVEN",cCodVen        )
   oTable:Replace("DOC_CENCOS",oDp:cCenCos    )
   oTable:Replace("DOC_CODMON",oDp:cMoneda    )
   oTable:Replace("DOC_CODSUC",oDp:cSucursal  )
   oTable:Replace("DOC_TIPDOC",cTipDoc        )
   oTable:Replace("DOC_TIPTRA","D"            )
   oTable:Replace("DOC_ESTADO","PA"           )
   oTable:Replace("DOC_FECHA" ,oDp:dFecha     )
   oTable:Replace("DOC_FCHVEN",oDp:dFecha     )
   oTable:Replace("DOC_HORA"  ,TIME()         )
   oTable:Replace("DOC_DESTIN","N"            )
   oTable:Replace("DOC_NETO"  ,nTotal         )
   oTable:Replace("DOC_BASNET",nTotal-oDp:nIva)
   oTable:Replace("DOC_CONDIC",NetName()      )
   oTable:Replace("DOC_USUARI",oDp:cUsuario   )
   oTable:Replace("DOC_MODFIS",oDp:cTkSerie   )
// oTable:Replace("DOC_MODFIS",oDp:cDenFiscal )
   oTable:Replace("DOC_FACAFE",cMesa          )
   oTable:Replace("DOC_DOCORG",IIF(lPedido,"P","M"))
   oTable:Replace("DOC_FACAFE",cMesa          )
   oTable:Replace("DOC_MTOCOM",nVuelto        )

   oTable:Replace("DOC_NUMERO",cNumero        )
//SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO",cWhere))
   cNumDoc:=oTable:DOC_NUMERO

   oDp:cDocWhere:="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                  "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                  "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)


   oDp:cCliWhere:="CCG_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                  "CCG_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                  "CCG_NUMDOC"+GetWhere("=",oTable:DOC_NUMERO)



   oTable:Commit()

   cCodCaja:=IIF( lPedido , oDp:cCajaDeli , oDp:cCaja )

   IF !Empty(cRif)
     SAVECLIZERO(oTable:DOC_CODSUC,oTable:DOC_TIPDOC,oTable:DOC_NUMERO)
   ENDIF

   IF nEfectivo>0
     SAVECAJAMOV("EFE",cCodCaja,"",oTable:DOC_NUMERO,oDp:dFecha,nEfectivo-nVuelto,NIL,"")
   ENDIF

   IF nCesta>0
     SAVECAJAMOV("CTK",cCodCaja,"",oTable:DOC_NUMERO,oDp:dFecha,nCesta,NIL,"")
   ENDIF

   IF nCheque>0
     SAVECAJAMOV("CHQ",cCodCaja,cBcoChq,cCheque,oDp:dFecha,nCheque,NIL,"")
   ENDIF

   IF nTarCR>0
     SAVECAJAMOV("TAR",cCodCaja,cBcoTCR,cTarCR,oDp:dFecha,nTarCR,NIL,"", cMarcaTC, cPosTC)
   ENDIF

   IF nTarDB>0
     SAVECAJAMOV("TDB",cCodCaja,cBcoTDB,cTarDB,oDp:dFecha,nTarDB,NIL,"" , cMarcaTD, cPosTD )
   ENDIF

   IF nTarCT>0
     SAVECAJAMOV("CTKE",cCodCaja,cBcoTCT,cTarCT,oDp:dFecha,nTarCT,NIL,"", cMarcaCT, cPosCT)
   ENDIF

   oTable:End()

   oMovi:=OpenTable("SELECT * FROM DPMOVINV",.F.)

   aData:=ASQL(" SELECT COM_CODIGO,COM_CANTID,COM_MESERO,INV_IVA,COM_PRECIO,COM_TIPO,COM_ITEM,COM_ITEM_A,COM_IVA,COM_UNDMED FROM DPPOSCOMANDA "+;
               " INNER JOIN DPINV ON COM_CODIGO= INV_CODIGO "+;
               " WHERE  "+iif(lPedido,"COM_PEDIDO"+GetWhere("=",cMesa),"COM_MESA"+GetWhere("=",cMesa)))

   // Agregar Servicio
   IF !Empty(oDp:nServicio)
      AADD(aData,{oDp:cCodSer,1,aData[1,3],"EX",oDp:nServicio,"P","","",0})
   ENDIF

   // Grabar el Cuerpo de la venta
   //ViewArray(aData)

   FOR I=1 TO LEN(aData)

     cUnd   :=aData[I,10]

     IF !ISSQLFIND("DPINVMED","IME_CODIGO"+GetWhere("=",aData[I,1])+" AND IME_UNDMED"+GetWhere("=",cUnd))
       EJECUTAR("DPINVCREAUND",aData[I,1],cUnd)
     ENDIF 

     nItem++
     nCosto :=EJECUTAR("INVCOSPRO" , aData[1,1], cUnd ,  oDp:cSucursal , oDp:dFecha,TIME())

     IF lPedido
        nPorIva:=EJECUTAR("IVACAL",aData[I,4],2,oDp:dFecha) // IVA (Nacional o Zona Libre
     ELSE
        nPorIva:= aData[I,9]
     ENDIF   
 
     oMovi:Append()

     oMovi:Replace("MOV_CODIGO", aData[I,1]   )
     oMovi:Replace("MOV_TIPIVA", aData[I,4]   )
     oMovi:Replace("MOV_CODTRA", "S000"       ) 
     oMovi:Replace("MOV_CODALM", oDp:cAlmacen ) 
     oMovi:Replace("MOV_FISICO", -1 ) 
     oMovi:Replace("MOV_LOGICO", -1 ) 
     oMovi:Replace("MOV_CONTAB", -1 ) 
     oMovi:Replace("MOV_INVACT",  1 ) 
     oMovi:Replace("MOV_APLORG", "V") 
     oMovi:Replace("MOV_CODCTA", cCodCli      )
     oMovi:Replace("MOV_FECHA" , oDp:dFecha       )
     oMovi:Replace("MOV_HORA"  , TIME()           )
     oMovi:Replace("MOV_DESCUE", 0                )
     oMovi:Replace("MOV_CODCOM", ""               )
     oMovi:Replace("MOV_DOCUME", oTable:DOC_NUMERO )
     oMovi:Replace("MOV_CODSUC", oTable:DOC_CODSUC )
     oMovi:Replace("MOV_TIPDOC", oTable:DOC_TIPDOC )
     oMovi:Replace("MOV_TIPO"  , IIF(aData[I,6]="P","I","C")) // Individual
     oMovi:Replace("MOV_ITEM"  , aData[I,7]        ) // STRZERO(nItem,LEN(oMovi:MOV_ITEM)))
     oMovi:Replace("MOV_ITEM_C", aData[I,8]        ) // STRZERO(nItem,LEN(oMovi:MOV_ITEM)))
     oMovi:Replace("MOV_ITEM_A", ""                ) // STRZERO(nItem,LEN(oMovi:MOV_ITEM)))
     oMovi:Replace("MOV_LISTA" , oDp:cPrecioPos    )
     oMovi:Replace("MOV_CENCOS", oDp:cCenCos       )
     oMovi:Replace("MOV_IVA"   , nPorIva           )
     oMovi:Replace("MOV_TOTAL" , aData[I,02]*aData[I,5])
     oMovi:Replace("MOV_CANTID", aData[I,02]       )
     oMovi:Replace("MOV_PRECIO", aData[I,05]       )
     oMovi:Replace("MOV_UNDMED", cUnd              )
     oMovi:Replace("MOV_CXUND" , 1                 )
     oMovi:Replace("MOV_COSTO" , nCosto            )
     oMovi:Replace("MOV_USUARI", oDp:cUsuario      )
     oMovi:Replace("MOV_CODVEN", aData[I,03]       )

     oMovi:Commit()

   NEXT I

   oMovi:End()   

   // Agregar Dirección de Entrega
   oDp:cDirWhere:=""

   IF !Empty(cDirE1+cDirE2+cDirE3)

      oDirE:=OpenTable("SELECT * FROM DPDOCCLIDIR",.F.)
      oDirE:Replace("DIR_TIPDOC",oTable:DOC_TIPDOC)
      oDirE:Replace("DIR_NUMDOC",oTable:DOC_NUMERO)
      oDirE:Replace("DIR_CODSUC",oTable:DOC_CODSUC)
      oDirE:Replace("DIR_CODIGO",oTable:DOC_CODIGO)
      oDirE:Replace("DIR_TIPTRA","D"              )
      oDirE:Replace("DIR_DIR1"  ,cDirE1           )
      oDirE:Replace("DIR_DIR2"  ,cDirE2           )
      oDirE:Replace("DIR_DIR3"  ,cDirE3           )
      oDirE:Replace("DIR_DIRIGI",cRif             )
      oDirE:Replace("DIR_TELEFO",cTel             )
      oDirE:Replace("DIR_ORDCOM",cPedido          )
      oDirE:Replace("DIR_COMEN1",cZona            )
      oDirE:Replace("DIR_COMEN2",cMuni            )

      oDirE:Commit()
      oDirE:End()

      oDp:cDirWhere:="DIR_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                     "DIR_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                     "DIR_NUMDOC"+GetWhere("=",oTable:DOC_NUMERO)

   ENDIF

   IF !lPedido

     SQLDELETE("DPPOSCOMANDA"," WHERE  COM_MESA"+GetWhere("=",cMesa))

   ELSE

     SQLDELETE("DPPOSCOMANDA"," WHERE  COM_PEDIDO"+GetWhere("=",cPedido))

   ENDIF
 
   DpSqlCommit()

   PUBLICO("oPos",oComanda)

   oPos:cCodSuc   :=oTable:DOC_CODSUC
   oPos:cTipDoc   :=oTable:DOC_TIPDOC
   oPos:DOC_NUMERO:=oTable:DOC_NUMERO


   oPos:lImpFis:=.F.

   // Verifica si el Cliente tiene Más Pedidos
   // ? MYCOUNT("DPPOSCOMANDA","COM_RIF"+GetWhere("=",cRif)),"CUANTOS QUEDAN"

   IF lPedido .AND. MYCOUNT("DPPOSCOMANDA","COM_RIF"+GetWhere("=",cRif))=0
     SQLDELETE("DPCLIENTESDELY","CDL_RIF"+GetWhere("=",cRif))
   ENDIF

   IF "LPT"$oDp:cImpFiscal

     MsgRun("Imprimiendo en "+oDp:cImpFiscal," Por favor Espere ",;
             {||EJECUTAR("TICKETLPT",NIL,oDp:cImpFiscal,oTable:DOC_NUMERO)})

   ENDIF

   IF "BEMATECH"$UPPE(oDp:cImpFiscal)
      oPos:lImpFis:=.T.
      EJECUTAR("BEMATECH",cTipDoc,oTable:DOC_NUMERO)
   ENDIF

   IF "EPSON"$UPPE(oDp:cImpFiscal)
      oPos:lImpFis:=.T.
      EJECUTAR("EPSONTMU200",oTable:DOC_NUMERO)
   ENDIF

   IF "BMC"$UPPE(oDp:cImpFiscal)
      oPos:lImpFis:=.T.
      EJECUTAR("BMC",oTable:DOC_NUMERO,cTipDoc)
   ENDIF

   lRet:=.T.
 
RETURN .T.

FUNCTION SAVECAJAMOV(cTipDoc,cCtaCaja,cBanco,cNumero,dFecha,nMonto,cWhere,cCuenta,cMarcaF,cPosBco)

   LOCAL oCajMov,cCodBco:=""

   DEFAULT cWhere :="",;
           cMarcaF:="",;
           cPosBco:=""

   IF !Empty(cPosBco)
      cCodBco:=MYSQLGET("DPPOSBANCARIO","PVB_CODBCO","PVB_CODIGO"+GetWhere("=",cPosBco))
   ENDIF

   IF !Empty(cWhere)
      cWhere:=" WHERE "+cWhere
   ENDIF
 
   oCajMov:=OpenTable("SELECT * FROM DPCAJAMOV "+cWhere," WHERE "$cWhere)

   IF oCajMov:RecCount()=0
     oCajMov:Append()
     oCajMov:Replace("CAJ_NUMTRA",SQLINCREMENTAL("DPCAJAMOV","CAJ_NUMTRA","CAJ_CODCAJ"+GetWhere("=",cCtaCaja)))
   ENDIF

   oCajMov:Replace("CAJ_DOCASO",oTable:DOC_NUMERO)
   oCajMov:Replace("CAJ_CODSUC",oDp:cSucursal     )
   oCajMov:Replace("CAJ_CODCAJ",cCtaCaja          )
   oCajMov:Replace("CAJ_ORIGEN",oTable:DOC_TIPDOC ) // Recibos de Pago
   oCajMov:Replace("CAJ_FECHA" ,oTable:DOC_FECHA  ) // Fecha de la Transacción
   oCajMov:Replace("CAJ_FCHCON",oTable:DOC_FECHA    )    // Fecha para Contabilizar
   oCajMov:Replace("CAJ_HORA"  ,oTable:DOC_HORA     )
   oCajMov:Replace("CAJ_DESCRI","Ticket: "+oTable:DOC_NUMERO  )

   oCajMov:Replace("CAJ_MONTO" ,nMonto         )
   oCajMov:Replace("CAJ_DEBCRE",1              )            // Todo Ingresa
   oCajMov:Replace("CAJ_TIPO"  ,cTipDoc        )
   oCajMov:Replace("CAJ_DESCRI",cNombre        )
   oCajMov:Replace("CAJ_CODMAE",oTable:DOC_CODIGO)
   oCajMov:Replace("CAJ_NUMCAJ",oDp:cIpLocal   )
   oCajMov:Replace("CAJ_USUARI",oDp:cUsuario   )
   oCajMov:Replace("CAJ_NUMERO",cNumero        )
   oCajMov:Replace("CAJ_CHQCTA",cCuenta        )
   oCajMov:Replace("CAJ_CONTAB","N"            )
   oCajMov:Replace("CAJ_ACT"   ,1  ) 
   oCajMov:Replace("CAJ_CENCOS",oTable:DOC_CENCOS)

   // Requiere Directorio Bancario
   oCajMov:Replace("CAJ_BCODIR",cBanco)
   // Requiere Directorio Bancario
   oCajMov:Replace("CAJ_POSBCO" ,cPosBco)
   oCajMov:Replace("CAJ_MARCAF" ,cMarcaF)
   oCajMov:Replace("CAJ_CODBCO" ,cCodBco)


   IF !oCajMov:Commit(cWhere)
      oCajMov:End()
      RETURN .F.
   ENDIF

   oCajMov:End()

RETURN .T.

/*
// RIF
*/
FUNCTION SAVECLIZERO(cCodSuc,cTipDoc,cNumero)
  LOCAL cWhere
  LOCAL oTable

// ? cCodSuc,cTipDoc,cNumero,"cCodSuc,cTipDoc,cNumero"
/*
  IF ISSQLFIND("DPCLIENTESCERO","CCG_RIF"+GetWhere("=",cRif)+" AND "CCG_CODCLA"+GetWhere("=","MESA"))
     // Actualizamos los Datos de la Factura para que muestre en la Impresora
     SQLUPDATE("DPCLIENTESCERO","CCG_CODSUC"+
  ENDIF
*/

  oComanda:cRif:=cRif // Rif del Cliente

  cWhere :="CCG_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "CCG_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "CCG_NUMDOC"+GetWhere("=",cNumero)

  oTable:=OpenTable("SELECT * "+;
                    "FROM DPCLIENTESCERO WHERE "+cWhere,.T.)


  IF oTable:RecCount()=0
     oTable:cWhere:=""
     oTable:Append()
  ENDIF

  oTable:Replace("CCG_CODSUC",cCodSuc)
  oTable:Replace("CCG_TIPDOC",cTipDoc)
  oTable:Replace("CCG_NUMDOC",cNumero)
  oTable:Replace("CCG_RIF"   ,cRif   )
  oTable:Replace("CCG_NOMBRE",cNombre)
  oTable:Replace("CCG_DIR1"  ,cDir1  )
  oTable:Replace("CCG_DIR2"  ,cDir2  )
  oTable:Replace("CCG_DIR3"  ,cDir3  )
  oTable:Replace("CCG_DIR4"  ,cMuni  )
  oTable:Replace("CCG_DIR5"  ,cZona  )
  oTable:Replace("CCG_TEL1"  ,cTel   )
  oTable:Replace("CCG_TIPTRA","D"    )
  oTable:Replace("CCG_CODCLA","MESA" ) // Datos de las mesas
  oTable:Commit(oTable:cWhere)

  oTable:End()

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
   
   LOCAL cBanco:=oBcoChq:Varget(),nAt,nLen:=LEN(ALLTRIM(cBanco)),cBancoOrg:=cBanco
   LOCAL oTable

   IF oBcoChq:nLastKey=VK_UP
      RETURN .T.
   ENDIF

   IF Empty(cBanco)
     RETURN .F.
   ENDIF

   IF Empty(oDp:aBancos)
     oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE ")
   ENDIF

   cBanco:=UPPE(cBanco)

//ViewArray(oDp:aBancos,,,.F.)

   nAt:=ASCAN(oDp:aBancos,{|a,n|cBanco=LEFT(UPPE(a[1]),nLen)})

   IF nAt>0
     oBcoChq:VarPut(oDp:aBancos[nAt,1],.T.)
     RETUN .T.
   ENDIF

   IF !MsgYesNo("Banco "+ALLTRIM(cBancoOrg)+" no Existe","Desea Agregarlo")
      oBcoChq:KeyBoard(VK_F6)
      RETURN .T.
   ENDIF


   oTable:=OpenTable("SELECT * FROM DPBANCODIR WHERE BAN_NOMBRE"+GetWhere("=",cBancoOrg),.T.)

   IF oTable:RecCount()=0
      oTable:Append()
      oTable:Replace("BAN_NOMBRE",cBancoOrg)
      oTable:Commit()
   ENDIF

   oTable:End()

   oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE ")

RETURN .T.

FUNCTION PUTBANCO(cMarca,oBanco,cInsBco)
   LOCAL aBancos:={}

   aBancos:=ATABLE("SELECT CXI_BANCO FROM DPBANCODIRPOR "+;
                   " WHERE CXI_CODINS"+GetWhere("=",cInsBco)+;
                   "   AND CXI_MARCA "+GetWhere("=",cMarca ))

   IF LEN(aBancos)=1 
     oBanco:VarPut(aBancos[1],.T.)
   ENDIF

RETURN .T.

FUNCTION VALNUMDOC(cNumDoc,oCombo)

  IF LEN(oCombo:aItems)=1
     EVAL(oCombo:bChange)
  ENDIF

RETURN .T.

FUNCTION SETIVA10()

   oDp:lPagEle:=!oDp:lPagEle

   nTotal:=EJECUTAR("DPPOSMESAPRN",cMesa,oComanda,.T.,oDp:lPagEle) 

   IF oDp:lPagEle
     oEfectivo:VarPut(0,.T.)
   ENDIF

   oTotal:Refresh(.T.)

RETURN .T.


// EOf


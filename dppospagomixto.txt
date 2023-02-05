// Programa   : DPPOSPAGOMIXTO
// Fecha/Hora : 26/05/2006 06:17:14
// Propósito  : Realizar Pago por Mesa
// Creado Por : Juan Navas
// Llamado por: DPPOSMESACTA
// Aplicación : Ventas
// Tabla      : DPPOSCOMANDA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPos)
  LOCAL aData:={},I,aTotal:={},nTotal:=0,aTexto:={},nColor,aLine:={},oGet,lRet:=.F.,lGrabar:=.F.
  LOCAL aDesglose:={}
  LOCAL oDlgP,oFontB,oDolar,oEfectivo,oBtn,oFont,oBtnSave,oBrwMp,oCol,oFont4
  LOCAL oCheque,oBcoChq,oTable,oResiduo
  LOCAL nWidth:=220,nHeight:=200

  LOCAL oTarDB,oBcoTDB,oNumTDB
  LOCAL oTarCR,oBcoTCR,oNumTCR
  LOCAL oTarCT,oBcoTCT,oNumTCT
  LOCAL oRif,oNombre,oDir1,oDir2,oTel,oVuelto,oTotal,oTotalD,oMontoBs,oZelle,oPagoMovil,oMontoBsZ,nBsDZ,nTotalO,oMontoDBs

  LOCAL nEfectivo:=0,nCheque:=0,nTarDB:=0,nTarCR:=0,nVuelto:=0,nTarCT:=0,cPedido
  LOCAL nDolar  :=0,nBsD     :=0,nZelle:=0,nPagoMovil:=0,nResiduo:=0,nPagado:=0
  LOCAL cCheque :=SPACE(10),cBcoChq:=SPACE(40)
  LOCAL cTarCR  :=SPACE(10),cBcoTCR:=SPACE(40),cTCRMar:=SPACE(25),cTCPos:=SPACE(4)
  LOCAL cTarDB  :=SPACE(10),cBcoTDB:=SPACE(40),cTDBMar:=SPACE(25),cTDPos:=SPACE(4)
  LOCAL cTarCT  :=SPACE(10),cBcoTCT:=SPACE(40),cTCTMar:=SPACE(25),cCTPos:=SPACE(4)

  LOCAL cRIF      :=SPACE(10),cNombre:=SPACE(30)
  LOCAL cDir1     :=SPACE(40),cDir2:=SPACE(40),cTel:=SPACE(14)
  LOCAL cCodVen   :=STRZERO(1,6),cPicture:="99,999,999.99",cTitulo:="RECIBIR PAGO MIXTO",cTipDoc:="TIK",cNumDoc
  LOCAL nClrPane1 := 16770764
  LOCAL nClrPane2 := 16566954
  LOCAL cDirE1    :="",cDirE2:="",cDirE3:="",cZona:="",cMuni:="" 

  /* 03-06-2008 Marlon Ramos (Evitar que duplique las marcas financieras)
  LOCAL aMarcaTC  :=ATABLE(" SELECT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='TAR'")
  LOCAL aMarcaTD  :=ATABLE(" SELECT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='TDB'")
  LOCAL aMarcaCT  :=ATABLE(" SELECT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='CTKE'")
  */
  LOCAL aMarcaTC  :=ATABLE(" SELECT DISTINCT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='TAR'")
  LOCAL aMarcaTD  :=ATABLE(" SELECT DISTINCT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='TDB'")
  LOCAL aMarcaCT  :=ATABLE(" SELECT DISTINCT IXM_MARCA FROM DPCAJAINSTXMARCA WHERE IXM_CODINS='CTKE'")
  // Fin 03-06-2008 Marlon Ramos 


  LOCAL aPosBco   :=ATABLE(" SELECT PVB_CODIGO FROM DPPOSBANCARIO WHERE PVB_ACTIVO=1 ")

  LOCAL cMarcaTC , cMarcaTD , cMarcaCT
  LOCAL oMarcaTC , oMarcaTD , oMarcaCT
  LOCAL cPosTC   , cPosTD   , cPosCT
  LOCAL oPosTC   , oPosTD   , oPosCT

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

  AADD(aDesglose,{0,"X",0,"=",0})

  nTotal:=0 // EJECUTAR("DPPOSMESAPRN",cMesa,oComanda,.T.)
 
  DEFAULT oPos:=oDp:oPos
 

  IF ValType(oPos)="O"

    IF oPos:nNeto<=0

       oPos:SetMsgErr("No hay Venta")

       RETURN .F.

    ENDIF

    nTotal:=nMonto:=oPos:nNeto

    cRif    :=oPos:CCG_RIF 
    cNombre :=oPos:CCG_NOMBRE
    cDir1   :=oPos:CCG_DIR1  
    cDir2   :=oPos:CCG_DIR2 
    cDir3   :=oPos:CCG_DIR3
    cDir4   :=oPos:CCG_DIR4
    cArea   :=oPos:CCG_AREA
    cTel    :=oPos:CCG_TEL1 

//    cTel2   :=oPos:CCG_TEL2  
//    cTel3   :=oPos:CCG_TEL3  
//    cCelular:=oPos:CCG_CELUL1
//    cEmail  :=oPos:CCG_EMAIL

    oPos:DISPTOTAL()

  ENDIF

  oPos:nIGTF      :=0

  nTotal:=IIF( nTotal=0 , 172504 , nTotal )

  nTotalO:=nTotal

  AADD(aTexto , "Monto a Pagar")
  AADD(aTexto , "Dolar Efectivo ")
  AADD(aTexto , "Zelle")
  AADD(aTexto , "Efectivo "+oDp:cMoneda)
  AADD(aTexto , "Pago Móvil")
  AADD(aTexto , "Cheque")
  AADD(aTexto , "Tarjeta de Crédito")
  AADD(aTexto , "Tarjeta de Débito")
  
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -13 BOLD
  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFont4 NAME "Tahoma" SIZE 0, -12 BOLD

  DEFINE DIALOG oDlgP TITLE cTitulo;
         SIZE 790+40,400;
         COLOR NIL,oDp:nGris

  oDlgP:lHelpIcon:=.F.

  FOR I=1 TO LEN(aTexto)

    nColor:=iif( I%2=0, oDp:nClrPane1, oDp:nClrPane2 )
    
    @ .5.0 + ((I-1)*.8),.5 SAY aTexto[I]+":" RIGHT;
                          SIZE 70,10.5;
                          FONT oFontB;
                          COLOR CLR_BLACK,nColor

    AADD(aLine,ATAIL(oDlgP:aControls):nTop)

  NEXT I

  @ aLine[1],075 SAY oTotal PROMPT TRAN(nTotal+oPos:nIGTF,"999,999,999.99") RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 COLOR oDp:nClrYellowText,oDp:nClrYellow

  @ aLine[1],075+065 SAY oTotalD PROMPT TRAN(ROUND((nTotal+oPos:nIGTF)/oPos:nValCam,2),"999,999,999.99")+oDp:cMonedaExt RIGHT;   
                     SIZE 60,10.5;
                     FONT oFontB PIXEL;
                     COLOR oDp:nClrYellowText,oDp:nClrYellow

  @ aLine[2],075+120 SAY oMontoBs PROMPT LSTR(nDolar)+oDp:cMonedaExt+"*"+ALLTRIM(TRAN(oPos:nValCam,"999,999,999.99"))+"="+ALLTRIM(TRAN(ROUND((nDolar)*oPos:nValCam,2),"999,999,999.99"))+oDp:cMoneda RIGHT;   
                     SIZE 110,10.5;
                     FONT oFontB PIXEL;
                     COLOR oDp:nClrYellowText,oDp:nClrYellow

  @ aLine[3],075+120 SAY oMontoBsZ PROMPT LSTR(nZelle)+oDp:cMonedaExt+"*"+ALLTRIM(TRAN(oPos:nValCam,"999,999,999.99"))+"="+ALLTRIM(TRAN(ROUND((nZelle)*oPos:nValCam,2),"999,999,999.99"))+oDp:cMoneda RIGHT;   
                     SIZE 110,10.5;
                     FONT oFontB PIXEL;
                     COLOR oDp:nClrYellowText,oDp:nClrYellow

  @ aLine[4],075+120 SAY oMontoDBs PROMPT LSTR(nZelle+nDolar)+oDp:cMonedaExt+"*"+ALLTRIM(TRAN(oPos:nValCam,"999,999,999.99"))+"="+ALLTRIM(TRAN(ROUND((nZelle+nDolar)*oPos:nValCam,2),"999,999,999.99"))+oDp:cMoneda RIGHT;   
                     SIZE 110,10.5;
                     FONT oFontB PIXEL;
                     COLOR oDp:nClrYellowText,oDp:nClrYellow


  @ aLine[2],075 GET oDolar VAR nDolar;
                 PICTURE "999,999,999.99";
                 VALID CALDOLAR(oZelle,.T.) .AND. CALZELLE();
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN !oPos:lPagEle

//               VALID CALDOLAR(oZelle,.T.) .AND. VALCESTA(nBsD+nPagoMovil+nEfectivo,oEfectivo,oDolar);


 @ aLine[3],075 GET oZelle VAR nZelle;
                 PICTURE "999,999,999.99";
                 VALID CALDOLAR(oEfectivo) .AND. VALCESTA(nBsD+nPagoMovil+nEfectivo,oEfectivo,oZelle);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN !oPos:lPagEle

  /*
  // EFECTIVO
  */
  @ aLine[4],075 GET oEfectivo VAR nEfectivo;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nBsD+nPagoMovil+nCheque+nTarCR+nEfectivo+nTarDB+nTarCT,oPagoMovil,oEfectivo);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN !oPos:lPagEle


  @ aLine[5],075 GET oPagoMovil VAR nPagoMovil;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nBsD+nPagoMovil+nCheque+nTarCR+nEfectivo+nTarDB+nTarCT,oCheque,oEfectivo);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN !oPos:lPagEle


  @ aLine[5]+2.5,146 SAY " Referencia " PIXEL ;
                 SIZE 60,08.5 FONT oFontB;
                 COLOR oDp:nClrLabelText,oDp:nClrLabelPane


  @ aLine[5]+2.5,207 SAY " "+oDp:xDPMARCASFINANC PIXEL ;
                 SIZE 76,08.5 FONT oFontB;
                 COLOR oDp:nClrLabelText,oDp:nClrLabelPane


  @ aLine[5]+2.5,284 SAY " "+oDp:xDPBANCODIR PIXEL ;
                 SIZE 80,08.5 FONT oFontB;
                 COLOR oDp:nClrLabelText,oDp:nClrLabelPane


  @ aLine[5]+2.5,365 SAY oDp:xDPPOSBANCARIO   PIXEL ;
                 SIZE 30,08.5 FONT oFontB;
                 COLOR oDp:nClrLabelText,oDp:nClrLabelPane


  @ aLine[1],300 SAY oResiduo PROMPT TRAN(nResiduo,"999,999,999.99") RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 COLOR oDp:nClrYellowText,oDp:nClrYellow
     
/*
// PAGO CON CHEQUE
*/

  @ aLine[6],075 GET oCheque VAR nCheque;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nCheque+nBsD+nPagoMovil+nEfectivo,oTarCR,oCheque);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN !oPos:lPagEle

  @ aLine[6],146 GET oNumChq VAR cCheque;
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN nCheque>0

  @ aLine[6],284 BMPGET oBcoChq VAR cBcoChq;
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
// ? nTarCR
  @ aLine[7],075 GET oTarCR VAR nTarCR;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nBsD+nPagoMovil+nCheque+nTarCR+nEfectivo,oTarDB,oTarCR);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL

  @ aLine[7],146 GET oNumTCR VAR cTarCR;
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCR>0

  @ aLine[7],207 COMBOBOX oMarcaTC VAR cMarcaTC ITEMS aMarcaTC;
                 VALID PUTBANCO(cMarcaTC,oBcoTCR,"TAR");
                 ON CHANGE PUTBANCO(cMarcaTC,oBcoTCR,"TAR");
                 SIZE 76,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCR>0 .AND. LEN(aMarcaTC)>1

  @ aLine[7],284 BMPGET oBcoTCR VAR cBcoTCR;
                 SIZE 80,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCR>0;
                 NAME "BITMAPS\FIND.BMP";
                 ACTION FINDBANCO(oBcoTCR);
                 VALID VALBANCO(oBcoTCR)

  oBcoTCR:bKeyDown:={|nKey|KeyBanco(nKey,oBcoTCR)}


  @ aLine[7],365 COMBOBOX oPosTC VAR cPosTC ITEMS aPosBco;
                 VALID 1=1;
                 SIZE 30,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarCR>0 .AND. LEN(aPosBco)>1


/*
// Tarjeta de Débito
*/

  @ aLine[8],075 GET oTarDB VAR nTarDB;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nBsD+nPagoMovil+nCheque+nTarCR+nEfectivo+nTarDB,oTarCT,oTarDB);
                 RIGHT;   
                 SIZE 60,10.5;
                 FONT oFontB PIXEL

  @ aLine[8],146 GET oNumTDB VAR cTarDB;
                 SIZE 60,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarDB>0

  @ aLine[8],207 COMBOBOX oMarcaTD VAR cMarcaTD ITEMS aMarcaTD;
                 VALID PUTBANCO(cMarcaTD,oBcoTDB,"TDB");
                 ON CHANGE PUTBANCO(cMarcaTD,oBcoTDB,"TDB");
                 SIZE 76,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarDB>0 .AND. LEN(aMarcaTD)>1

  @ aLine[8],284 BMPGET oBcoTDB VAR cBcoTDB;
                 SIZE 80,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarDB>0;
                 NAME "BITMAPS\FIND.BMP";
                 ACTION FINDBANCO(oBcoTDB);
                 VALID VALBANCO(oBcoTDB)

  oBcoTDB:bKeyDown:={|nKey|KeyBanco(nKey,oBcoTDB)}


  @ aLine[8],365 COMBOBOX oPosDB VAR cPosTC ITEMS aPosBco;
                 VALID 1=1;
                 SIZE 30,10.5;
                 FONT oFontB PIXEL;
                 WHEN nTarDB>0 .AND. LEN(aPosBco)>1


  /*
  // CESTA TICKET TARJETA
  */

  @ aLine[6],075 GET oTarCT VAR nTarCT ;
                 PICTURE "999,999,999.99";
                 VALID VALCESTA(nBsD+nPagoMovil+nCheque+nTarCR+nEfectivo+nTarDB+nTarCT,oEfectivo,oTarCT);
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

  @ aLine[1]+100,042 GET oRif VAR cRif;
                     VALID VALRIF();
                     SIZE 40,10;
                     FONT oFontB PIXEL

  @ oRif:nTop,.5 SAY "CI o RIF:";
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
                 ACTION (SETTOTAL(oDolar),EJECUTAR("CALCESTATICKET",nTotal,oDolar,oEfectivo));
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

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD

  @13.5+1.0,13+4-15 SBUTTON oBtnSave;
             SIZE 45, 20+5 FONT oFont;
             FILE "BITMAPS\XSAVE.BMP","BITMAPS\XSAVE2.BMP","BITMAPS\XSAVEG.BMP" NOBORDER;
             PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris, 1 };
             ACTION (lGrabar:=VALTICKET()) CANCEL;
             WHEN nResiduo=0

  // JN 03/08/2022 nBsD+nPagoMovil+nCheque+nTarCR+nTarDB+nTarCT+nEfectivo)=(nTotal+oPos:nIGTF)
  /* 28-05-2008 Marlon Ramos
         WHEN (nPagoMovil+nCheque+nTarCR+nTarDB+nTarCT+nEfectivo)>=nTotal
  */


  

  oBtnSave:lCancel :=.T.
  oBtnSave:cToolTip:="Grabar "
  oBtnSave:cMsg    :=oBtnSave:cToolTip

  @13.5+1.0,23+5-15 SBUTTON oBtn ;
         SIZE 45, 20+5 FONT oFont;
         FILE "BITMAPS\XSALIR.BMP" NOBORDER;
         PROMPT "Cerrar";
         COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris, 1 };
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
//oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrwMp:aCols[5]
  oCol:cHeader      := "Total"
  oCol:nWidth       := 120+20
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrwMp:aArrayData[oBrwMp:nArrayAt,5],cPicture)}
//oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}
  oCol:cFooter      := "0.00"   

  AEVAL(oBrwMp:aCols,{|oCol,n|oCol:oHeaderFont:=oFont4})

  oBrwMp:bClrStd   := {||{0, iif( oBrwMp:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }
  oBrwMp:bClrHeader:= {||{oDp:nGrid_ClrTextH,oDp:nGrid_ClrPaneH }}

  oBrwMp:CreateFromCode()
  
  ACTIVATE DIALOG oDlgP CENTERED ON INIT (oBrwMp:Move(170+40,352+062,292+20,220-40,.T.),;
                                          oBrwMp:SetColor(nClrPane2,nClrPane1),;
                                          DpFocus(oEfectivo),.F.)


  IF lGrabar .AND. ValType(oPos)="O"

    // Efectivo
    oPos:nEfectivo  :=nEfectivo
    oPos:nEfectivoUs:=nDolar // JN 11/07/2022

    // Cheque
    oPos:nCheque  :=nCheque
    oPos:cBanco   :=cBcoChq
    oPos:cCheque  :=cCheque

    // Cesta Ticket
    oPos:nPagoMovil   :=nPagoMovil

    // Tarjeta de Crédito
    oPos:nCredito   :=nTarCr
    oPos:cCredito   :=cTarCR
    oPos:cBcoCre    :=cBcoTCR
    oPos:cMarcaTC   :=cMarcaTC
    oPos:cPosTC     :=cPosTC


    // Tarjeta de Débito
    oPos:nDebito  :=nTarDB
    oPos:cBanDeb  :=cBcoTDB
    oPos:cDebito  :=cTarDB
    oPos:cMarcaTD :=cMarcaTD
    oPos:cPosTD   :=cPosTD

    // Tarjeta de CestaTicket
    oPos:nTarCT   	:=nTarCT
    oPos:cBcoTCT  	:=cBcoTCT
    oPos:cTarCT   	:=cTarCT
    oPos:cMarcaCT 	:=cMarcaCT
    oPos:cPosCT    :=cPosCT

    cRif    :=oPos:CCG_RIF   :=cRif
    cNombre :=oPos:CCG_NOMBRE:=cNombre
    cDir1   :=oPos:CCG_DIR1  :=cDir1 
    cDir2   :=oPos:CCG_DIR2  :=cDir2
    cDir3   :=oPos:CCG_DIR3  :=cDir3
//  cDir4   :=oPos:CCG_DIR4  :=cDir4
//  cArea   :=oPos:CCG_AREA  :=cArea
    cTel    :=oPos:CCG_TEL1  :=cTel

    oPos:SaveTicket(.t.)

  ENDIF
 
  // COLOCO LAS VARIABLES NUEVAMENTE EN CERO

  oPos:nCredito:=0
  oPos:nDebito :=0

  // 03-06-2008 Marlon Ramos (EVITAR REPETIR MONTOS EN TICKETS POSTERIORES (TABLA: DPCAJAMOV)*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
  oPos:nEfectivo  :=0
  oPos:nCheque    :=0
  oPos:nPagoMovil     :=0
  oPos:nTarCT     :=0
  oPos:nEfectivoUs:=0 // 11/07/2022

  // Fin 03-06-2008 *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


  AEVAL(oDlgP:aControls,{ |o,n| IIF( "GET"$o:ClassName() , o:bValid:=BloqueCod(".T."),NIL)})
                                
 // DESTROY(oDlgP,.T.)

RETURN lRet

FUNCTION VALCESTA(nMonto,oGetNext,oGet)
// LOCAL nResiduo:=0
// LOCAL nPagado :=0

  IF oGet:nLastKey=38
     RETURN .T.
  ENDIF

  IF !oGet:nLastKey=13
     RETURN .T.
  ENDIF

  VERDETALLES()
  // nPagado:=INT((nBsD+nPagoMovil+nEfectivo+nCheque+nTarDB+nTarCR+nTarCT)*100)/100

  IF nMonto=0 
     RETURN .T.
  ENDIF
  
  // JN 11/07/2022 Suma el IGTF
  // nResiduo:=(nTotal+oPos:nIGTF)-nMonto

  IF(nResiduo>0,oGetNext:VarPut(nResiduo,.T.))
  oPos:nResiduo:=nResiduo

  VERDETALLES()

RETURN .T.

FUNCTION SETTOTAL(oGet)
   LOCAL aControl:={oDolar,oEfectivo,oCheque,oTarCR,oTarDB,oTarCT}

   AEVAL(aControl,{|O,n| o:VarPut(0,.T.) })

   oGet:VarPut(nTotal,.T.)
   oGet:KeyBoard(13)
   
RETURN .T.

FUNCTION FINDBANCO(oBco)
  LOCAL cBanco

  cBanco:=EJECUTAR("REPBDLIST","DPBANCODIR","BAN_NOMBRE", NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oBco)

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
   LOCAL cWhere,cTipDoc:="TIK",oTable,nPagado:=0,oMovi,aData
   LOCAL cCodCli:=STRZERO(0,10),nItem:=0,nPorIva,nCosto

   IF !ISSQLGET("DPCLIENTES","CLI_CODIGO",cCodCli)
      MensajeErr("Cliente "+cCodCli+" No Existe ")
      RETURN .F.
   ENDIF   


  // 28-05-2008 Marlon Ramos nPagado:=(nPagoMovil+nEfectivo+nCheque+nTarDB+nTarCR)
   nPagado:=(nBsD+nPagoMovil+nEfectivo+nCheque+nTarDB+nTarCR+nTarCT)

   oPos:nPagado:=nPagado

   IF ROUND(nPagado,2)<ROUND(nTotal,2)
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

   // LOCAL nResiduo:=nTotal-(nBsD+nPagoMovil+nCheque+nTarCR+nTarDB)

   IF ValType(oEfectivo)!="O"
     RETURN .F.
   ENDIF

   IF oEfectivo:nLastKey=13 .AND. Empty(nEfectivo)
      oEfectivo:VarPut(nResiduo,.T.)
      nEfectivo:=nResiduo
   ENDIF

// nVuelto:=(nTotal-(nBsD+nPagoMovil+nCheque+nTarCR+nTarDB+nEfectivo))*-1
   nVuelto:=(nTotal-nRecibo)*-1

   IF nVuelto>0
     oCol:cFooter      := TRAN(nVuelto,"999,999,999.99")
     aDesglose:=EJECUTAR("DESGLOSE",nVuelto)
     oBrwMp:aArrayData:=ACLONE(aDesglose)
     oBrwMp:Gotop(.T.)
     oBrwMp:Refresh(.T.)
   ELSE
     nVuelto:=0
   ENDIF
//JHON NOVOA
nEfectivo:=nEfectivo-nVuelto
//
   IF !Empty(cRif)
      oBtnSave:ForWhen()
      oBtnSave:Refresh(.T.)
      DpFocus(oBtnSave)
   ENDIF


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

/*
// Calcula Zelle
*/
FUNCTION CALZELLE()


RETURN .T.

// 11/07/2022
FUNCTION CALDOLAR(oFocus,lZelle)

  // nBsD    :=ROUND((nDolar)*oPos:nValCam,2)
  // nBsDZ   :=ROUND((nZelle)*oPos:nValCam,2)
  // nResiduo:=nTotal-(nBsD+nEfectivo+nPagoMovil+nCheque+nTarCR+nTarDB)
  // VERDETALLES()
  // nBsD    :=ROUND((nZelle+nDolar)*oPos:nValCam,2)

  DEFAULT lZelle:=.T.

/*
  IF nDolar>0 .OR. nZelle>0
    nEfectivo:=0
    oEfectivo:Refresh(.T.)
  ENDIF

*/

  oPos:nIGTF:=0

  VERDETALLES()

  EJECUTAR("DPPOSCALIGTF","DOL",oPos:nEfePorIGtf,nBsD)

  

  IF nBsD>(nTotal+oPos:nIGTF)
     oDolar:MsgErr("Monto Equivalente "+oDp:cMoneda+" "+LSTR(nDolar)+"*"+LSTR(oPos:nValCam)+"="+ALLTRIM(FDP(nBsD,"999,999,999,999.99")),"Supera Monto")
     RETURN .F.
  ENDIF
	

  IF ValType(oFocus)="O"
    // DPFOCUS(oFocus)
  ENDIF

  oTotal:Refresh(.T.)
  oTotalD:Refresh(.T.)

  oMontoBs:Refresh(.T.)
  oMontoBsZ:Refresh(.T.)
  oMontoDBs:Refresh(.T.)

  VERDETALLES()

RETURN .T.

FUNCTION CALZELLE()

  IF nZelle=0 .AND. nDolar>0
    nZelle:=(nTotalO/oPos:nValCam)-nDolar
    oZelle:VarPut(nZelle,.T.)
    oZelle:Refresh(.T.)
  ENDIF

  VERDETALLES()

RETURN .T.

FUNCTION VERDETALLES()
  nBsD     :=ROUND((nZelle+nDolar)*oPos:nValCam,2)
  nPagado  :=nBsD+nPagoMovil+nEfectivo+nCheque+nTarDB+nTarCR+nTarCT

  EJECUTAR("DPPOSCALIGTF","DOL",oPos:nEfePorIGtf,nBsD)

  nTotal   :=nTotalO+oPos:nIGTF

  nResiduo :=nTotal-nPagado
  nResiduo :=VAL(STR(nResiduo,19,2))

  oResiduo:Refresh(.T.)

//  ? "nPagado->",nPagado,"nTotal->",nTotal,"nTotalO",nTotalO,"nResiduo->",nResiduo,"oPos:nIGTF->",oPos:nIGTF

RETURN .T.
// EOf


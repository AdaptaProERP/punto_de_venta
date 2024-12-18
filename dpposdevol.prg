// Programa   : DPPOSDEVOL
// Fecha/Hora : 09/02/2007 16:15:12
// Prop�sito  : Solicita los datos del ticket Punto de venta para su devoluci�n.
// Creado Por : Juan Navas
// Modificado : Marlon Ramos 17-06-2008 (Permite traer los datos del cliente, el pago y descuentos)
//                           07-07-2008 (Se agrega validaci�n de ticket devuelto al salir del formulario
//                                       evitando generar devoluci�n sobre un ticket m�s de una vez)
//                           05-08-2008 (Traer los datos de numero y hora para evitar tickets kilom�tricos)
//                           11-08-2008 (Asignar los valores de fecha y hora a variables de oPos: para imprimir
//                                       Fecha, hora y ticket asociado TICKETEPSON)
//                           12-09-2008 (Asignar los valores de fecha, hora y ticket asociado DPPOSPRINT)
// Llamado por: DPOS01
// Aplicaci�n : Ventas
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPos)

   LOCAL oDlg,oFontB,oFont,oBtn,oMonto
   LOCAL oTicket,cTicket:=SPACE(10),aData,aLine
   LOCAL oFecha ,dFecha :=oDp:dFecha,cTipDoc:="TIK",cTipDev:="DEV"
   LOCAL cRif   :=SPACE(12),oRif
   LOCAL cCodSuc:=oDp:cSucursal
   LOCAL cNombre:=SPACE(120),oNombre
   LOCAL nMonto :=0,i,nEmpty
   LOCAL nWidth :=400
   LOCAL nHeight:=300
   LOCAL lFound :=.F.,lOk:=.F.
   LOCAL cAsoTipDoc:="" // Tipo de Documento Devoluci�n de Venta

   PRIVATE cHora:=""

   dFecha :=CTOD("")

   IF ValType(oPos)="O"

      cTipDoc:=oPos:cTipDoc
      cTipDev:=oPos:cTipDev

      IF oPos:cCodCli<>REPLICATE("0",10) .AND. ISSQLFIND("DPCLIENTESCERO","CCG_RIF"+GetWhere("=",oPos:cCodCli))
        cRif   :=oPos:cCodCli // SPACE(12)
      ENDIF
//      cAsoTipDoc:=cTipDoc
   ENDIF

   IF cTipDoc="TIK" .AND. COUNT("DPDOCCLI","DOC_TIPDOC"+GetWhere("=",cTipDoc))=0
      cTipDoc:="FAV"
   ENDIF

   DEFINE FONT oFontB  NAME "Tahoma"   SIZE 0, -12 BOLD
   DEFINE FONT oFont   NAME "Tahoma"   SIZE 0, -12 BOLD

   DEFINE DIALOG oDlg TITLE " Devoluci�n de Venta desde ["+cTipDoc+"]" COLOR 0,oDp:nGris2 

   oDlg:lHelpIcon:=.F.

   @ 1.0,1 BMPGET oFecha VAR dFecha;
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oFecha,dFecha);
           SIZE 55,11 FONT oFontB 

   SAYTEXTO2("Fecha de la Venta",oFont,NIL,100,07)

   @ 2.9,1 GET oRif VAR cRif;
           VALID VALRIF(cRif);
           SIZE 55,11 FONT oFontB

   SAYTEXTO2("Rif o C�dula",oFont,NIL,100,07)

   @ 2.9,09 GET oNombre VAR cNombre;
            VALID VALNOMBRE(cNombre);
            SIZE 116,11 FONT oFontB;
            WHEN Empty(cRif) 

   SAYTEXTO2("Nombre del Cliente",oFont,NIL,100,07)

   @ 4.8,1 BMPGET oTicket VAR cTicket;
           VALID VALTICKET(cTicket);
           NAME "BITMAPS\FIND.BMP"; 
           ACTION FINDTICKET();
           SIZE 55+5,11 FONT oFontB 

   SAYTEXTO2("N�mero de Ticket",oFont,NIL,100,07)

   @ 5.5,1.3 SAY oMonto PROMPT TRAN(nMonto,"999,999,999,999,999.99");
             COLOR CLR_WHITE,CLR_HBLUE;
             RIGHT FONT oFontB;
             SIZE 55+30,10 

   SAYTEXTO2("Monto",oFont,NIL,100,07)

   @ 6,17 BUTTON oBtn;
          PROMPT " Aceptar ";
          SIZE 40,12 FONT oFontB;
          ACTION (lOk:=.T.,oDlg:End());
          WHEN lFound
  
   @ 6,24 BUTTON " Cerrar  ";
          SIZE 40,12 FONT oFontB;
          ACTION (lOk:=.F.,oDlg:End()) CANCEL

   ACTIVATE DIALOG oDlg;
            ON INIT (oDlg:SetSize(nWidth,nHeight,.T.),;
                     oTicket:SetFocus(),;
                     IF(!Empty(cRif),(VALRIF(cRif),FINDTICKET(),VALTICKET(cTicket)),NIL),;
                     ,.F.);
            CENTERED

   IF lOk .AND. lFound .AND. VALTICKET(cTicket)

      oPos:POSREINI(.T.)

      CursorWait()

      // 06-08-2008 Marlon Ramos (Traer los datos de numero y hora para evitar tickets kilom�tricos)
         /*aData:=ASQL(" SELECT INV_DESCRI,MOV_TOTAL*-1,MOV_CANTID*-1 AS MOV_CANTID,MOV_PRECIO,"+;
                     " MOV_UNDMED,MOV_CODIGO,MOV_IVA,MOV_TIPIVA,INV_DESCRI,MOV_UNDMED,MOV_CXUND,MOV_CODVEN,MOV_DESCUE "+;
                     " FROM DPMOVINV "+;
                     " INNER JOIN DPINV ON MOV_CODIGO=INV_CODIGO "+;
                     " WHERE "+;
                     " MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                     " MOV_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                     " MOV_DOCUME"+GetWhere("=",cTicket))
                     */

      aData:=ASQL(" SELECT INV_DESCRI,MOV_TOTAL*-1,MOV_CANTID*-1 AS MOV_CANTID,MOV_PRECIO,"+;
                  " MOV_UNDMED,MOV_CODIGO,MOV_IVA,MOV_TIPIVA,INV_DESCRI,MOV_UNDMED,MOV_CXUND,MOV_CODVEN,MOV_DESCUE "+;
                  " FROM DPMOVINV "+;
                  " INNER JOIN DPINV ON MOV_CODIGO=INV_CODIGO "+;
                  " WHERE "+;
                  " MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                  " MOV_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                  " MOV_DOCUME"+GetWhere("=",cTicket))

     IF Empty(aData)
        MsgMemo("Documento "+cTipDoc+"-"+cTicket)
        RETURN .F.
     ENDIF

// +" AND "+;
//                  " MOV_FECHA"+GetWhere("=",dFecha)+" AND "+;
//                  " MOV_HORA "+GetWhere("=",cHora ))
      // Fin 06-08-2008 Marlon Ramos 



      IF ValType(oPos)="O"

         // 17-06-2008 Marlon Ramos (Traer el descuento total si lo hay)
            /* 06-08-2008 Marlon Ramos (AGREGAR FECHA Y HORA)
               oPos:nDocDesc:=MYSQLGET("DPDOCCLI","DOC_DCTO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                             "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                             "DOC_NUMERO"+GetWhere("=",cTicket)+" AND "+;
                             "DOC_DOCORG='P' AND DOC_ACT =1 ")
                             */
               oPos:nDocDesc:=MYSQLGET("DPDOCCLI","DOC_DCTO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                             "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                             "DOC_NUMERO"+GetWhere("=",cTicket)+" AND "+;
                             "DOC_FECHA"+GetWhere("=",dFecha )+" AND "+;
                             "DOC_HORA "+GetWhere("=",cHora  )+" AND "+;
                             "DOC_DOCORG='P' AND DOC_ACT =1 ")

              // 11-08-2008 Marlon Ramos (Imprimir Fecha, hora y ticket Asociado a la Devoluci�n TICKETEPSON)
                 oPos:dFechAsoc:=dFecha
                 oPos:dHoraAsoc:=cHora 
                 oPos:cTickAsoc:=cTicket // 12-09-2008 Marlon Ramos
              // Fin 11-08-2008 Marlon Ramos 

            // Fin 06-08-2008 Marlon Ramos 
         // Fin 17-06-2008 Marlon Ramos 

         // 18-06-2008 Marlon Ramos (Traer los montos y formas de pago del ticket a devolver)
            lFound := CargaPagos(cCodSuc,cTipDoc,cTicket)
            IF !lFound
               RETURN .F.
            ENDIF
         // Fin 18-06-2008 Marlon Ramos 
   
         // 27-06-2008 Marlon Ramos (Traer los datos del cliente del ticket a devolver)
          CargaCliente(oPos,cCodSuc,cTipDoc,cTicket)
         // Fin 27-06-2008 Marlon Ramos 

        oPos:cTicketDev:=cTicket

        nEmpty:=ASCAN(oPos:oBrwItem:aArrayData,{|a,n|Empty(a[1]) })
    
        IF nEmpty>0
          AADD(aData,ACLONE(oPos:oBrwItem:aArrayData[nEmpty]))
          ARREDUCE(oPos:oBrwItem:aArrayData,nEmpty)
        ENDIF

        FOR I=1 TO LEN(aData)
           AADD(oPos:oBrwItem:aArrayData,aData[I])
        NEXT I

        oPos:oBrwItem:Refresh(.T.)
        oPos:oBrwItem:GoBottom(.T.)
        oPos:Calcular()

        DPFOCUS(oPos:oCodInv)

        oPos:oCodCli:VarPut(cRif   ,.T.)
        oPos:oNomCli:VarPut(cNombre,.T.)

      ENDIF

   ENDIF

RETURN .T.

/*
// Busca los Tickets por Fecha
*/
FUNCTION FINDTICKET(oControl)
   LOCAL cNumero,nPosic,cWhere:=""
   LOCAL cTitle:=ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)))+;
                 " "+DTOC(dFecha)

   DEFAULT oControl:=oTicket

   oDp:aPicture:={NIL,NIL,NIL,"999,999,999,999.99"}

   cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc      )+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D")+" AND "+;
           "DOC_ACT=1" 

   IF !Empty(cRif)

      cWhere:=cWhere+" AND (CLI_RIF"+GetWhere(" LIKE ","%"+ALLTRIM(cRif)+"%")+" OR "+;
                     "      CCG_RIF"+GetWhere(" LIKE ","%"+ALLTRIM(cRif)+"%")+")"

   ENDIF

   IF !Empty(cTicket)
     cWhere:=cWhere+" AND DOC_NUMERO"+GetWhere(" LIKE ","%"+ALLTRIM(cTicket)+"%")
   ENDIF

   IF !Empty(dFecha)
      cWhere:=cWhere+" AND DOC_FECHA"+GetWhere("=",dFecha)
   ENDIF

   IF !Empty(cNombre)

      cWhere:=cWhere+" AND (CLI_NOMBRE"+GetWhere(" LIKE ","%"+ALLTRIM(cNombre)+"%")+" OR "+;
                     "      CCG_NOMBRE"+GetWhere(" LIKE ","%"+ALLTRIM(cNombre)+"%")+")"

   ENDIF

   cNumero:=EJECUTAR("REPBDLIST","DPDOCCLI",{"DOC_NUMERO","IF(CCG_NOMBRE IS NULL,CLI_NOMBRE,CCG_NOMBRE) AS CLI_NOMBRE","DOC_HORA","DOC_NETO"},NIL,;
                     " LEFT JOIN DPCLIENTESCERO ON DOC_CODSUC=CCG_CODSUC AND DOC_TIPDOC=CCG_TIPDOC AND DOC_NUMERO=CCG_NUMDOC "+;
                     " LEFT JOIN DPCLIENTES     ON DOC_CODIGO=CLI_CODIGO "+;
                     " WHERE "+cWhere,;
                     cTitle,;
                     {"N�mero","Cliente","Hora","Neto"},NIL,NIL,NIL,NIL,oControl)

   IF !Empty(cNumero)
      lFound:=.T.
      oTicket:VarPut(cNumero,.T.)
      oTicket:KeyBoard(13)
   ELSE
      lFound:=.F.
   ENDIF

   oBtn:ForWhen(.T.)

RETURN cNumero

FUNCTION VALTICKET()
   LOCAL cDev,lFind,cWhere,cTitle:="Busca Factura",cNumero:=cTicket

   cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc      )+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
           "DOC_NUMERO"+GetWhere(" LIKE ","%"+ALLTRIM(cTicket)+"%")+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D")+" AND "+;
           "DOC_ACT=1" 

   IF COUNT("DPDOCCLI",cWhere)>1

       cNumero:=FINDTICKET()

       IF !Empty(cNumero)
         cTicket:=cNumero
       ENDIF
 
   ELSE

      cNumero:=SQLGET("DPDOCCLI","DOC_NUMERO",cWhere)

   ENDIF

   IF Empty(cNumero)

      cNumero:=FINDTICKET()

      IF Empty(cNumero)
         RETURN .F.
      ENDIF

      cTicket:=cNumero

   ENDIF

   cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc    )+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc    )+" AND "+;
           "DOC_NUMERO"+GetWhere("=",cTicket    )+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D"        )+" AND "+;
           "DOC_ACT=1" 

   // ? cWhere,COUNT("DPDOCCLI",cWhere)
   // JN 07/11/2022

   cWhere:=" LEFT JOIN DPCLIENTESCERO ON DOC_CODSUC=CCG_CODSUC AND DOC_TIPDOC=CCG_TIPDOC AND DOC_NUMERO=CCG_NUMDOC "+;
           " LEFT JOIN DPCLIENTES     ON DOC_CODIGO=CLI_CODIGO "+;
           " WHERE "+cWhere


   nMonto :=MYSQLGET("DPDOCCLI","DOC_NETO,IF(CCG_NOMBRE IS NULL,CLI_NOMBRE,CCG_NOMBRE) AS CLI_NOMBRE,IF(CCG_RIF IS NULL,CLI_RIF,CCG_RIF) AS CLI_RIF,DOC_FECHA",cWhere)

   cNombre:=DPSQLROW(2)
   cRif   :=DPSQLROW(3)
   dFecha :=DPSQLROW(4)

   oNombre:VarPut(cNombre,.T.)
   oNombre:Refresh(.T.)
   oRif:Refresh(.T.)
   oFecha:Refresh(.T.)

   // Fin 06-08-2008 Marlon Ramos 

   oMonto:Refresh(.T.)

   IF Empty(cTicket)
      RETURN .F.
   ENDIF

   // Verifica que la Factura no est� Devuelta
   cDev:=SQLGET("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                        "DOC_TIPDOC"+GetWhere("=",cTipDev)+" AND "+;
                                        "DOC_FACAFE"+GetWhere("=",cTicket))

   IF !Empty(cDev)
      MensajeErr("Ticket "+cTicket+", Est� Vinculado con Devoluci�n "+cTipDev+" "+;
                 cDev)
      RETURN .F.

   ENDIF

   IF !Empty(nMonto)
      lFound:=.T.
   ELSE
      lFound:=.F.
   ENDIF

   oBtn:ForWhen(.T.)

RETURN .T.

FUNCTION VALRIF(cRif)
   LOCAL cGet,cNumero

   IF Empty(cRif)
      RETURN .T.
   ENDIF

   cGet:=SQLGET("DPCLIENTESCERO","CCG_RIF,CCG_NOMBRE","CCG_RIF"+GetWhere("=",cRif))
    
   IF !Empty(cGet)
      oRif:VarPut(cRif,.T.)
      oNombre:VarPut(oDp:aRow[2],.T.)
   ELSE
      // oRif:MsgErr("Rif/CI: "+cRif+" no Existe")
      cNumero:=FINDTICKET(oRif)
      RETURN !Empty(cNumero)
   ENDIF

RETURN .T.

FUNCTION VALNOMBRE(cNombre)
   LOCAL cWhere,cNumero
   LOCAL cTitle:=ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)))+;
                 " "+DTOC(dFecha)

   IF Empty(cNombre)
      RETURN .T.
   ENDIF

   cNumero:=FINDTICKET(oNombre)

   IF Empty(cNumero)
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION CargaPagos(cCodSuc,cTipDoc,cTicket)
   LOCAL cWhere, oTable

   cWhere:="CAJ_CODSUC"+GetWhere("=",cCodSuc)+" AND CAJ_ORIGEN"+GetWhere("=",cTipDoc)+" AND "+;
           "CAJ_DOCASO"+GetWhere("=",cTicket)+" AND CAJ_CODCAJ"+GetWhere("=",oPos:cCodCaja)+" AND "+;
           "CAJ_ACT=1 AND CAJ_DEBCRE=1 "

   oTable:=OpenTable("SELECT * FROM DPCAJAMOV WHERE "+cWhere)
   //oTable:=OpenTable("SELECT * FROM DPCAJAMOV "+cWhere," WHERE "$cWhere)

   //? oTable:Recno(),cWhere
   //oTable:Browse()
   IF oTable:RecCount()=0
      MensajeErr("Documento "+cTipDoc+cTicket+", No se encontr� ninguna forma de pago.")
      // JN 18/11/2022, SI FUE A CREDITO?
      // RETURN .F.
      RETURN .T.
   ENDIF

  oPos:nIGTF:=0

   Do While !oTable:Eof()

      oPos:nIGTF :=oPos:nIGTF+oTable:CAJ_MTOITF

      // IF oTable:CAJ_TIPO = "DOL"
      //   oPos:nIGTF := oTable:CAJ_MTOITF
      // ENDIF

      IF oTable:CAJ_TIPO = "EFE"
         oPos:nEfectivo := oTable:CAJ_MONTO
      ENDIF

      // Cesta Ticket
      IF oTable:CAJ_TIPO = "CTK "
         oPos:nCesta := oTable:CAJ_MONTO
      ENDIF

      // Cheque
      IF oTable:CAJ_TIPO = "CHQ"
         oPos:nCheque :=oTable:CAJ_MONTO
         oPos:cCheque :=oTable:CAJ_NUMERO
         oPos:cBanco  :=oTable:CAJ_BCODIR
      ENDIF

      // Tarjeta de Cr�dito
      IF oTable:CAJ_TIPO = "TAR"
         oPos:nCredito :=oTable:CAJ_MONTO
         oPos:cCredito :=oTable:CAJ_NUMERO
         oPos:cBcoCre  :=oTable:CAJ_BCODIR
         oPos:cMarcaTC :=oTable:CAJ_MARCAF
         oPos:cPosTC   :=oTable:CAJ_POSBCO
      ENDIF

      // Tarjeta de D�bito
      IF oTable:CAJ_TIPO = "TDB"
         oPos:nDebito :=oTable:CAJ_MONTO
         oPos:cDebito :=oTable:CAJ_NUMERO
         oPos:cBanDeb :=oTable:CAJ_BCODIR
         oPos:cMarcaTD:=oTable:CAJ_MARCAF
         oPos:cPosTD  :=oTable:CAJ_POSBCO
      ENDIF

      // Tarjeta de CestaTicket
      IF oTable:CAJ_TIPO = "CTKE"
         oPos:nTarCT  := oTable:CAJ_MONTO
         oPos:cTarCT  :=oTable:CAJ_NUMERO
         oPos:cBcoTCT :=oTable:CAJ_BCODIR
         oPos:cMarcaCT:=oTable:CAJ_MARCAF
         oPos:cPosCT  :=oTable:CAJ_POSBCO
      ENDIF

      oTable:Dbskip(1)

   Enddo

   oTable:End()

   oPos:oIGTF:Refresh(.F.)

// ? oPos:nIGTF,"oPos:nIGTF"

RETURN .T.
//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

FUNCTION CargaCliente(oFrm,cCodSuc,cTipDoc,cTicket)
LOCAL cWhere, oTable
      cWhere:="CCG_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "CCG_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
              "CCG_NUMDOC"+GetWhere("=",cTicket)

   IF ValType(oFrm)="O"
      oTable  :=OpenTable("SELECT * FROM DPCLIENTESCERO WHERE "+cWhere,.T.)
      oFrm:CCG_RIF   :=oTable:CCG_RIF 
      oFrm:CCG_NIT   :=oTable:CCG_NIT 
      oFrm:CCG_NOMBRE:=oTable:CCG_NOMBRE
      oFrm:CCG_DIR1  :=oTable:CCG_DIR1  
      oFrm:CCG_DIR2  :=oTable:CCG_DIR2 
      oFrm:CCG_DIR3  :=oTable:CCG_DIR3
      oFrm:CCG_DIR4  :=oTable:CCG_DIR4
      oFrm:CCG_AREA  :=oTable:CCG_AREA
      oFrm:CCG_TEL1  :=oTable:CCG_TEL1 
      oFrm:CCG_TEL2  :=oTable:CCG_TEL2  
      oFrm:CCG_TEL3  :=oTable:CCG_TEL3  
      oFrm:CCG_CELUL1:=oTable:CCG_CELUL1
      oFrm:CCG_EMAIL :=oTable:CCG_EMAIL
      oTable:End()
   ENDIF

RETURN .T.
//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


// EOF

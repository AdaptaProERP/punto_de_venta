// Programa   : DPPOSPRINT
// Fecha/Hora : 20/09/2006 11:47:33
// Prop�sito  : Imprimir Ticket 
// Creado Por : Juan Navas
// Llamado por: DPPOS01
// Aplicaci�n : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lVenta)
   LOCAL cError:="",nRet,uBuf,cAlicuota:="",cTipCant,cCantid,cPrecio,cTipDesc,aData:={}
   LOCAL cCliente:="",nPrecio:=12345.25,nDesc:=5.55,cValDesc,nCant:=1.5,cTipAcre
   LOCAL cTotal:="",nTotal,cPago,cMsg,cRif:=""
   LOCAL lOpen:=.F.,nDif:=0,I
   LOCAL cDia,cMes,cAno,cHora,cMin,cSeg,cCupon,cSerie,cIva,cNombre:="",cRif:=""
   LOCAL cFecha:=oDp:dFecha
   LOCAL cHora :=TIME(),lOk,lOpen:=.F.

   DEFAULT lVenta:=.T.

   oPos:lImpErr:=.F.

   // JN 18/11/2022, imprimir� segun documento almacenados
   IF !Empty(oPos:aDocSave)

      AEVAL(oPos:aDocSave,{|a,n| lOk:=EJECUTAR("DPDOCCLI_PRINT",oDp:cSucursal,a[1],a[2])})

   ELSE

    IF oPos:nNeto>0
      lOk:=EJECUTAR("DPDOCCLI_PRINT",oDp:cSucursal,oPos:cTipDoc,oPos:DOC_NUMERO)
    ELSE
      lOk:=EJECUTAR("DPDOCCLI_PRINT",oDp:cSucursal,oPos:cTipDev,oPos:DOC_NUMERO)
    ENDIF

   ENDIF

   IF lOk
      RETURN .T.
   ENDIF

/*
   IF "EPSON"$UPPE(oDp:cImpFiscal) 
      EJECUTAR("DLL_EPSON",oPos:cTipDoc,oPos:DOC_NUMERO)
      RETURN 
   ENDIF
*/

//JHON ANULE ESTO PARA VER SI LOGRO IMPRIMIR POR BMC
/*
   IF oPos:lImpFis .AND. UPPE(oDp:cImpFiscal)="BMC"
      oPos:PRINTBMC()
      RETURN .F.
   ENDIF
*/
   IF !oPos:lImpFis .OR. !UPPE(oDp:cImpFiscal)="BEMATECH"
      RETURN .F.
   ENDIF

   cNombre:=MYSQLGET("DPCLIENTESCERO","CCG_NOMBRE,CCG_RIF","CCG_CODSUC"+GetWhere("=",oPos:cCodSuc)+" AND "+;
                                                           "CCG_TIPDOC"+GetWhere("=",oPos:cTipDoc)+" AND "+;
                                                           "CCG_NUMDOC"+GetWhere("=",oPos:DOC_NUMERO))
   IF !Empty(oDp:aRow)
      cRif:=oDp:aRow[2]
   ENDIF

   SysRefresh(.T.)

   CursorWait()

   oPos:SetMsgInv("Bematech Imprimiendo")
   oPos:SetMsgErr("Por Favor, Espere...")

   cTipCant:=IIF(nCant=INT(nCant),"I","F")  // Entero o "F" fracciondo

   cDia:=STRZERO(DAY(oDp:dFecha)  ,2)
   cMes:=STRZERO(MONTH(oDp:dFecha),2)
   cAno:=RIGHT(STRZERO(YEAR(oDp:dFecha) ,4),2)

   cHora:=_VECTOR(TIME(),":")

   cMin :=cHora[2]
   cSeg :=cHora[3]
   cHora:=cHora[1]

   IF cTipCant="F"
      cCantid :=STR(nCant,7,3)
   ELSE
      cCantid :=STR(nCant,4,0)
   ENDIF

   cCantid :=StrTran(cCantid,".","")
   cPrecio :=StrTran(Str(nPrecio,8,2),".","")
   cTipDesc:="%" // %=Relativo Y $=Absoluto

   IF cTipDesc="%"
      cValDesc:=STRZERO(nDesc*100,4) // STR(nDesc*100,4,0)
   ELSE
      cValDesc:=STRZERO(nDesc*100,8)
   ENDIF

   cValDesc:=StrTran(cValDesc , "." , ",") // Quitar Puntos

   IF EMPTY(HRBLOAD("BEMATECH"))
      oPos:SetMsgInv(cText)
      oPos:SetMsgErr(cError)
      RETURN .F.
   ENDIF
 
   cError:=BEMA_INI()

   IF !Empty(cError)
      oPos:SetMsgErr(cError)
      RETURN .F.
   ENDIF

   cFecha:=_VECTOR(DTOC(oDp:dFecha),"/")
   cFecha:=cFecha[1]+cFecha[2]+RIGHT(cFecha[3],2)
   cHora :=STRTRAN(TIME(),":","")

   // Verifica el Estatus de la Impresora
   uBuf  := 0
   nRet  := BmFlagFiscal(@uBuf) // Verifica si hay Cupones
   cError:= Bema_Error(nRet,.T.)

   // Asignar Moneda
   nRet:=BmSimboloMoneda("Bs")

   cError:= Bema_Error(nRet,.T.)
   oPos:BemaErr(cError)


   IF uBuf=0
     oPos:SetMsgInv("Bematech Imprimiendo, Estatus OK")
   ENDIF

   IF uBuf>0 .AND. (uBuf/1)%2=1

       MensajeInfo("Hay Cupon Abierto"+LSTR(uBuf)," Es necesario Cerrarlo")
       // puede ser cancelado

       lOpen:=.F.

       nRet:=BmCanCupom()

       IF Empty(cError)
          MensajeErr("Cupon Cancelado")
       ENDIF

       uBuf:=0

   ENDIF

   IF uBuf>0 .AND. (uBuf/2)%2=1

       MensajeInfo("Cupon sin Pago, Es Necesio Pagar o Cancelar <Anular>")
       // puede ser cancelado

       lOpen:=.F.

       nRet:=BmCanCupom()

       IF Empty(cError)
          MensajeErr("Cupon Cancelado")
       ENDIF

   ENDIF

   IF uBuf>0 .AND. (uBuf/4)%2=1

       MensajeInfo("Horario de Verano, Solo Brasil")

   ENDIF

   IF uBuf>0 .AND. (uBuf/8)%2=1

       MensajeInfo("Horario de Verano, Solo Brasil")

   ENDIF

   IF uBuf>0 .AND. (uBuf/16)%2=1

       MensajeInfo("Sin determinaci�n")

   ENDIF

   IF uBuf>0 .AND. (uBuf/32)%2=1

   //    MensajeInfo("Permite Cancelar <Anular> Cupon")
       nRet:=BmCanCupom()

       IF Empty(cError)
     //     MensajeErr("Cupon Cancelado")
       ENDIF

   ENDIF

  IF uBuf>0 .AND. (uBuf/128)%2=1

       MensajeInfo("No hay Espacio en Memoria Fiscal")
       MensajeErr("Cambie la Impresora por una Nueva")       

       RETURN .T.

   ENDIF

   IF !Empty(cError)
      RETURN .F.
   ENDIF

   cAlicuota:=SPACE(79)
   BemaLeerAlicuota(@cAlicuota)
// MensajeInfo(cAlicuota," Alicuotas Conocidas")

   cCliente:=PADR(cNombre,41)+PADR(cRif,18)

   IF lVenta .AND. !lOpen

     nRet    := BmAbreCup(cCliente)

   ENDIF

   IF !lVenta

     cSerie  :=STRZERO(1,13) // Numero de Serie de la Impresora
     cRif    :=PADR(1,15)
     cCliente:=PADR("Nombre",39)
     cCupon  :=STRZERO(1,6)
     cHora   :=_VECTOR(TIME(),":")

     cMin    :=cHora[2]
     cSeg    :=cHora[3]
     cHora   :=cHora[1]

     nRet:=BmAbreNotaDeCredito(cCliente,cSerie,cRif,cDia,cMes,cAno,cHora,cMin,cSeg,cCupon)

   ENDIF
/*
   cNombre:=MYSQLGET("DPCLIENTESCERO","CCG_NOMBRE,CCG_RIF","CCG_CODSUC"+GetWhere("=",oPos:cCodSuc)+" AND "+;
                                                           "CCG_TIPDOC"+GetWhere("=",oPos:cTipDoc)+" AND "+;
                                                           "CCG_NUMDOC"+GetWhere("=",oPos:DOC_NUMERO))

   IF !Empty(oDp:aRow)
     cRif:=oDp:aRow[2]
   ENDIF
*/
// cCliente:=PADR(ALLTRIM(cNombre)+" CI/RIF "+cRif,39)

   cError  := Bema_Error(nRet,.T.)
   oPos:BemaErr(cError)

   aData   := ACLONE(oPos:oBrwItem:aArrayData)

// ViewArray(aData) 

   FOR I=1 TO LEN(aData)

      IF !Empty(aData[I,6])

          nCant  :=aData[I,3]
          nPrecio:=IIF(aData[I,13]>0,aData[I,4],aData[I,2])
          nDesc  :=aData[I,13]
          cIva   :=STRZERO(aData[I,7]*100,4)
          cIva   :=LEFT(cIva,2)+","+RIGHT(cIva,2)
 ? cIva
// ? cValDesc
          IF cTipDesc="%"
            cValDesc:=STRZERO(nDesc*100,4) // STR(nDesc*100,4,0)
          ELSE
            cValDesc:=STRZERO(nDesc*100,8)
//           cValDesc:="9,99"
          ENDIF
// ? cValDesc
          cValDesc:=StrTran(cValDesc , "." , ",") // Quitar Puntos
// ? cValDesc
         IF cTipCant="F"
           cCantid :=STR(nCant,7,3)
         ELSE
            cCantid :=STR(nCant,4,0)
         ENDIF

         cCantid :=StrTran(cCantid,".","")
         cPrecio :=StrTran(Str(nPrecio/nCant,9,2),".","") // Antes era 8, Quitar Coma queda en 8

         nRet:=BmVendItem( PADR(aData[I,6]   ,13),;
                           PADR(aData[I,9]   ,29),;
                           PADR(cIva         ,05),;
                           cTipCant           ,;
                           cCantid            ,;
                           2                  ,;
                           cPrecio            ,;
                           cTipDesc           ,;
                           cValDesc           )

         cError  := Bema_Error(nRet,.T.)

         oPos:BemaErr(cError)


     ENDIF

    NEXT 

   // No permitido en Venezuela, Hacer -% General en el Encabezado

IF lVenta

   nRet:=BmIniFecCup("A","%","0000")

   cTotal:=SPACE(14)
   nRet:=BmSubTotal(@cTotal)

// ? TRAN(VAL(cTotal)/100,"999,999,999,999.99"),"TOTAL BemaTech",cTotal

   nTotal:=VAL(cTotal)/100
   cPago :=STRZERO((nTotal/1)*100,14) // Formas de Pago
//  nDif  :=nTotal

// ? cPago,oPos:nEfectivo

   IF oPos:nCheque>0
     nTotal:=(oPos:nCheque)
     cPago :=STRZERO((nTotal/1)*100,14) // Formas de Pago
     nRet:=BmFormasPag(PADR("Cheque" ,16),cPago)
     cError  := Bema_Error(nRet,.T.)
     oPos:BemaErr(cError)

   ENDIF

   IF oPos:nCesta>0
     nTotal:=(oPos:nCesta)
     cPago :=STRZERO((nTotal/1)*100,14) // Formas de Pago
     nRet:=BmFormasPag(PADR("Cesta Ticket" ,16),cPago)
     cError  := Bema_Error(nRet,.T.)
     oPos:BemaErr(cError)

   ENDIF

   IF oPos:nDebito>0
     nTotal:=(oPos:nDebito)
     cPago :=STRZERO((nTotal/1)*100,14) // Formas de Pago
     nRet:=BmFormasPag(PADR("Tarjeta D�bito" ,16),cPago)
     cError  := Bema_Error(nRet,.T.)
     oPos:BemaErr(cError)

   ENDIF

   IF oPos:nCredito>0
     nTotal:=(oPos:nCredito)
     cPago :=STRZERO((nTotal/1)*100,14) // Formas de Pago
     nRet:=BmFormasPag(PADR("Tarjeta Cr�dito" ,16),cPago)
     cError  := Bema_Error(nRet,.T.)
     oPos:BemaErr(cError)

   ENDIF

   IF oPos:nEfectivo>0

     nTotal:=(oPos:nEfectivo+oPos:nVuelto)
     cPago :=STRZERO((nTotal/1)*100,14) // Formas de Pago
     nRet:=BmFormasPag(PADR("Efectivo" ,16),cPago)
     cError  := Bema_Error(nRet,.T.)
     oPos:BemaErr(cError)
   ENDIF

ENDIF

/*
   nRet:=BmFormasPag(PADR("Cheque"   ,16),cPago)
   cError  := Bema_Error(nRet,.T.)

   nRet:=BmFormasPag(PADR("Debito"   ,16),cPago)
   cError  := Bema_Error(nRet,.T.)

   nRet:=BmFormasPag(PADR("T.Credito",16),cPago)
   cError  := Bema_Error(nRet,.T.)
*/

   cMsg:=PADR("Gracias por su Compra",48)+;
         PADR("Bematech",48)+;
         PADR("Datapro Punto de Venta",48)+;
         PADR("Aproveche el Mejor Precio",48)+;
         PADR("Calidad",48)+;
         PADR("Bajo Costo",48)+;
         PADR("No Aceptamos Devoluciones",48)+;
         PADR("No devolvemos Dinero",48)

   cMsg:=""

//   IF oPos:nVuelto>0
//     cMsg:=PADL("Vuelto "+TRAN(oPos:nVuelto,"99,999,999.99"),48)
//   ENDIF

   cMsg:=PADR("Ticket : "+oPos:DOC_NUMERO,48)+;
         PADR("Gracias por su Compra",48)+;
         PADR("No Aceptamos Devoluciones",48)+;
         PADR("No devolvemos Dinero",48)

   // Cuando la Impresora no est� fiscalizada esta funci�n Genera Error
   cCupon:=SPACE(06)
   nRet  :=BmNumCupom( @cCupon )
   oPos:cCupon:=cCupon

   cError:= Bema_Error(nRet,.T.)

   nRet:=BmTerFecCup( cMsg )
   cError  := Bema_Error(nRet,.T.)

   SysRefresh(.T.)

   IF !oPos:lImpErr

      oPos:SetMsgInv("Cupon Fiscal Impreso Exitosamente")

      SQLUPDATE("DPDOCCLI","DOC_IMPRES",1,"DOC_CODSUC"+GetWhere("=",oPos:cCodSuc)+" AND "+;
                                          "DOC_TIPDOC"+GetWhere("=",oPos:cTipDoc)+" AND "+;
                                          "DOC_NUMERO"+GetWhere("=",oPos:DOC_NUMERO))
    ELSE

       oPos:SetMsgInv("Cupon Fiscal Gener� Error")

    ENDIF

    oPos:SetMsgErr("")


RETURN .T.

//


// Programa   : DPPOSSAVE
// Fecha/Hora : 20/09/2006 11:53:04
// Propósito  : Salvar Ticket Punto de Venta
// Creado Por : Juan Navas
// Modificado : Marlon Ramos 09-06-2008 (Se agregan los campos DOC_BASNET y DOC_MTOIVA)
//                           08-07-2008 (Se arregla la devolución para la Bematech)
//                           31-07-2008 (Se agrega Fecha y hora de la transacción iguales para las tablas dpdoccli y dpmovinv,
//                                       garantizando que en los queries de impresion (programas BMC y BEMATECH) no traigan productos 
//                                       de otros tickets).
//                           04-08-2008 (Como se activó el vendedor en DPPOS01 se debe asegurar que todos los productos tengan el mismo vendedor)
//                           22-09-2008 (Se agrega la impresora Samsung)
//                           24-11-2009 (Se agrega la Star Mod. HSP-7000) Datapro
// Llamado por: DPPOS01
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lPrint,oPos)

  LOCAL oTable,cWhere,oMovi,I,aData,nItem:=0,nCosto:=0,nMtoDev:=0,cFmt,nAt,cWhere,nPagado:=0,cWhereD
  LOCAL DATO    :=0,Most:=""
  LOCAL AuxcRif :=oPos:CCG_RIF, AuxcNomb:=oPos:CCG_NOMBRE 
  LOCAL cNomCli :=EVAL(oPos:oNomCli:bSetGet)
  LOCAL nNetoOrg:=oPos:nNeto
 
  PRIVATE cHoraTrans:=TIME()      //Guardar la misma hora en dpdocli y dpmovinv (necesario para no imprimir tickets errados)
  PRIVATE dFechTrans:=oDp:dFecha  //Guardar la misma fecha en dpdocli y dpmovinv "es posible que se imprima a las 11:59:59 pm y quedarian en fechas diferentes" (necesario para no imprimir tickets errados)


  oPos:cDevolu:=""

  IF oPos:nNeto=0
     oPos:SetMsgErr("No hay Productos en el Documento")
     RETURN .F.
  ENDIF

  // 18-06-2008 Marlon Ramos 
  // 18-07-2022 JN oPos:lPagos 

//? oPos:lPagos,"oPos:lPagos"

  IF oPos:nNeto>0 .AND. oPos:lPagos .AND. oPos:nEfectivoUs+oPos:nEfectivo+oPos:nCesta+oPos:nCheque+oPos:nCredito+oPos:nDebito+oPos:nTarCT=0
     oPos:SetMsgErr("Seleccione una forma de Pago por Favor")
     RETURN .F.
  ENDIF
  // Fin 18-06-2008 Marlon Ramos 

  // 25-06-2008 Marlon Ramos (Evitar salvar el ticket sin cliente)

  // 28/07/2022, Pedidos con Clientes CERP

  cNomCli:=EVAL(oPos:oNomCli:bSetGet)

  IF !oPos:lLibVta .AND. Empty(oPos:CCG_RIF)
    oPos:CCG_RIF   :=oPos:cCodCli
    oPos:CCG_NOMBRE:=cNomCli 
    oPos:CCG_DIR1  :=""
    oPos:CCG_DIR2  :=""
    oPos:CCG_DIR3  :=""

   IF oPos:cCodCli=REPLI("0",10)
      oPos:SetMsgErr("Introduzca CI/RIF del Cliente")
      RETURN .F.
   ENDIF  

   IF Empty(oPos:CCG_NOMBRE) 
      oPos:SetMsgErr("Introduzca Nombre del Cliente")
      RETURN .F.
   ENDIF

  ENDIF

  IF oDp:lDpPosCli .AND. EMPTY(ALLTRIM(oPos:CCG_RIF + oPos:CCG_NOMBRE + oPos:CCG_DIR1))
      oPos:SetMsgErr("Seleccione un Cliente por favor.")
      oPos:PosCliente()
      RETURN .F.
   ENDIF
  // 25-06-2008 Fin Marlon Ramos 

  IF oDp:lDpPosCli .AND. !(SQLGET("DPCLIENTES","CLI_CODIGO","CLI_CODIGO"+GetWhere("=",oPos:cCodCli))==oPos:cCodCli)
     oPos:SetMsgErr("Cliente "+oPos:cCodCli+" no Existe")
     RETURN .F.
  ENDIF

//******************************* codigo vendedores ************************
/*
// JN 22/09/2023 Innecesario
    DATO:=LEN(ALLTRIM(oPos:cCodVen))
    most=ALLTRIM(oPos:cCodVen)
    dato:= 6- dato
    if dato=5
       oPos:cCodVen:="00000"+ALLTRIM(oPos:cCodVen)
    endif
    if dato=4
       oPos:cCodVen:="0000"+ALLTRIM(oPos:cCodVen)
    endif
    if dato=3
       oPos:cCodVen:="000"+ALLTRIM(oPos:cCodVen)
    endif
    if dato=2
       oPos:cCodVen:="00"+ALLTRIM(oPos:cCodVen)
    endif
    if dato=1
       oPos:cCodVen:="0"+ALLTRIM(oPos:cCodVen)
    endif

*/
  oPos:cCodVen:=REPLI("0",6-LEN(ALLTRIM(oPos:cCodVen)))+ALLTRIM(oPos:cCodVen) // JN 22/09/2023

  IF !ISSQLFIND("DPVENDEDOR","VEN_CODIGO"+GetWhere("=",oPos:cCodVen))
     oPos:SetMsgErr("Vendedor "+oPos:cCodVen+" no Existe")
     RETURN .F.
  ENDIF
//**********************************************************************************************

  oPos:SetMsgErr("")

  oPos:aDocSave:={} 

  DpSqlBegin(NIL,NIL,"DPDOCCLI")

  IF oPos:nBruto>0
    oPos:nMtoVta:=SAVEDOC(oPos:cTipDoc , .T. )  // Graba las Ventas
  ENDIF

// ? oPos:cTipDev,"para la devolucion en DPPOSSAVE"

  oPos:nMtoDev:=SAVEDOC(oPos:cTipDev , .F. )  // Graba las Devoluciones

  //? oPos:nMtoDev,"oPos:nMtoDev",oPos:nMtoVta,"<-oPos:nMtoVta"

  IF oPos:nMtoDev<>0 

     EJECUTAR("DPCAJAMOVREGDEV",oPos:cCodSuc,oPos:cTipDev,oPos:DOC_NUMERO,.F.) // no debe emitir mensaje

  ELSE

  //?  oPos:nNeto,"<-nNeto",oPos:nMtoDev,"oPos:nMtoDev"
  //IF oPos:nEfectivo>0
  //EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"EFE",oPos:cCodCaja,"",oPos:DOC_NUMERO,oDp:dFecha,oPos:nEfectivo-oPos:nVuelto,NIL,"")
  //ENDIF

  IF oPos:nEfectivo>0
     EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"EFE",oPos:cCodCaja,"",oPos:DOC_NUMERO,oDp:dFecha,oPos:nEfectivo,NIL,"")
  ENDIF

  IF oPos:nEfectivoUs>0
     EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"DOL",oPos:cCodCaja,"",oPos:DOC_NUMERO,oDp:dFecha,oPos:nEfectivoUs*oPos:nValCam,NIL,"","","",.T.,oPos:nEfectivoUs)
  ENDIF

  IF oPos:nZelle>0
     EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"DOL",oPos:cCodCaja,"",oPos:DOC_NUMERO,oDp:dFecha,oPos:nZelle*oPos:nValCam,NIL,"","","",.T.,oPos:nZelle)
  ENDIF


  IF oPos:nCesta>0
    EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"CTK",oPos:cCodCaja,"",oPos:DOC_NUMERO,oDp:dFecha,oPos:nCesta,NIL,"")
  ENDIF

  IF oPos:nPagoMovil>0
    EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"PAGM",oPos:cCodCaja,"",oPos:DOC_NUMERO,oDp:dFecha,oPos:nPagoMovil,NIL,"")
  ENDIF


  IF oPos:nCheque>0
    EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"CHQ",oPos:cCodCaja,oPos:cBanco,oPos:cCheque,oDp:dFecha,oPos:nCheque,NIL,"")
  ENDIF

  IF oPos:nCredito>0
      EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"TAR",oPos:cCodCaja,oPos:cBcoCre,oPos:cCredito,oDp:dFecha,oPos:nCredito,NIL,"",oPos:cMarcaTC,oPos:cPosTC)
  ENDIF

  IF oPos:nDebito>0
    EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"TDB",oPos:cCodCaja,oPos:cBcoDeb,oPos:cDebito,oDp:dFecha,oPos:nDebito,NIL,"" ,oPos:cMarcaTD,oPos:cPosTD)
  ENDIF

  IF oPos:nTarCT>0
    EJECUTAR("DPPOSCAJAMOV",oPos:DOC_NUMERO,"CTKE",oPos:cCodCaja,oPos:cBcoTCT,oPos:cTarCT,oDp:dFecha,oPos:nTarCT,NIL,"",oPos:cMarcaCT,oPos:cPosCT)
  ENDIF

  ENDIF

  DpSqlCommit()

  oPos:CCG_RIF:=SPACE(12)


  // 07-07-2008 Marlon Ramos IF lPrint .AND. oPos:lImpFis .AND. oPos:nMtoVta>0
  IF lPrint .AND. oPos:lImpFis .AND. oPos:nMtoVta>0 .AND. !(oPos:nMtoDev>0) .AND. (oPos:lLibVta .OR. oPos:DOC_TIPDOC="TIK")

    MsgRun("Emitiendo Ticket Fiscal "+oDp:cImpFiscal,"Por Favor Espere....",{||oPos:IMPRIMIR(.T.)})

  ENDIF

  // 26-08-2008 Marlon Ramos IF "LPT"$UPPE(oDp:cImpFiscal) .AND. oPos:nMtoVta>0
  IF "LPT"$UPPE(oDp:cImpFiscal) .AND. (oPos:nMtoVta>0 .OR. oPos:nMtoDev>0)
    oPos:cCupon:=""

     // 25-08-2008 Marlon Ramos 
        //MsgRun("Imprimiendo Ticket en "+oDp:cImpFiscal," Por favor Espere ",;
           //{||EJECUTAR("TICKETLPT",NIL,oDp:cImpFiscal,oPos:DOC_NUMERO)})
        MsgRun("Imprimiendo Ticket en "+oDp:cImpFiscal," Por favor Espere ",;
               {||EJECUTAR("TICKETLPT",NIL,oDp:cImpFiscal,oPos:DOC_NUMERO,IIF(oPos:nMtoDev>0, "DEV", oPos:cTipDoc),dFechTrans,cHoraTrans)})
        //MsgRun("Imprimiendo Ticket en "+oDp:cImpFiscal," Por favor Espere ",;
               //{||EJECUTAR("TICKETLPT",NIL,"XX.TXT",oPos:DOC_NUMERO,IIF(oPos:nMtoDev>0, "DEV", oPos:cTipDoc),dFechTrans,cHoraTrans)})
     // Fin 25-08-2008 Marlon Ramos 
  ENDIF

  IF "FMT:"$UPPE(oDp:cImpFiscal) .AND. oPos:nMtoVta>0

     nAt   :=AT(":",oDp:cImpFiscal)
     cFmt  :=SUBS(oDp:cImpFiscal,nAt+1,LEN(oDp:cImpFiscal))

     // 25-08-2008 Marlon Ramos 
        /* cWhere:=" WHERE MOV_CODSUC"+GetWhere("=",oPos:DOC_CODSUC)+;
                " AND MOV_TIPDOC"+GetWhere("=",oPos:DOC_TIPDOC)+;
                " AND MOV_DOCUME"+GetWhere("=",oPos:DOC_NUMERO)
        */

        cWhere:=" WHERE MOV_CODSUC"+GetWhere("=",oDp:cSucursal)+;
                "   AND MOV_TIPDOC"+GetWhere("=",IIF(oPos:nMtoDev>0, oPos:cTipDev, oPos:cTipDoc))+;
                "   AND MOV_DOCUME"+GetWhere("=",oPos:DOC_NUMERO)+;
                "   AND MOV_TIPO ='I' "+;
                "   AND MOV_FECHA"+GetWhere("=",dFechTrans)+;
                "   AND MOV_HORA"+GetWhere("=",cHoraTrans)
     // Fin 25-08-2008 Marlon Ramos 


     EJECUTAR("FMTRUN","TICKET",cFmt,"Ticket "+oPos:DOC_NUMERO,cWhere)
     oFmt:cWhere:=cWhere

  ENDIF


  DO CASE

       CASE oPos:nVuelto<>0

        nPagado:=oPos:nRecibe+oPos:nCesta

       CASE oPos:nResiduo<0

       nPagado:=oPos:nPagado

    OTHER

    nPagado:=0

  ENDCASE

// ? oPos:lLibVta,"oPos:lLibVta"

  IF !oPos:lLibVta

// ? oPos:nMtoDev,"oPos:nMtoDev",oPos:DOC_TIPDOC,"oPos:DOC_TIPDOC"

     SQLUPDATE("DPTIPDOCCLI","TDC_ACTIVO",.T.,"TDC_TIPO"+GetWhere("=",oPos:DOC_TIPDOC))

     cWhereD:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal  )+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",oPos:DOC_TIPDOC)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",oPos:DOC_NUMERO)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D")

     SQLUPDATE("DPDOCCLI","DOC_DOCORG","V",cWhereD)

     // PEDIDOS PARA CUENTA X COBRAR
     IF !oPos:lLibVta .AND. oPos:lCXC
        RETURN .T.
     ENDIF

     IF oPos:nMtoDev>0
       EJECUTAR("DPFACTURAV",oPos:cTipDev,oPos:DOC_NUMERO)
     ELSE
       EJECUTAR("DPFACTURAV",oPos:DOC_TIPDOC,oPos:DOC_NUMERO)
     ENDIF

     RETURN .T.

  ENDIF

  //NUEVO 29-06-2022 EPSON .DLL - USB
//  IF "EPSON"$UPPE(oDp:cImpFiscal) .AND. (oPos:nMtoVta>0 .OR. oPos:nMtoDev>0)
//     EJECUTAR("DLL_EPSON",oPos:DOC_NUMERO,oPos:DOC_TIPDOC,nPagado)
//  ENDIF

  //05-08-2008 Marlon Ramos IF "EPSON"$UPPE(oDp:cImpFiscal) .AND. oPos:nMtoVta>0
  IF "EPSON"$UPPE(oDp:cImpFiscal) .AND. (oPos:nMtoVta>0 .OR. oPos:nMtoDev>0)
   // ??   "ENTRA EN DPPOSSAVE a EPSON"
     //05-08-2008 Marlon Ramos EJECUTAR("EPSONTMU200",oPos:DOC_NUMERO,oPos:DOC_TIPDOC,nPagado)
     EJECUTAR("EPSONTMU200",oPos:DOC_NUMERO,oPos:DOC_TIPDOC,nPagado,dFechTrans,cHoraTrans)
  ENDIF

  IF "BMC"$UPPE(oDp:cImpFiscal) .AND. (oPos:nMtoVta>0 .OR. oPos:nMtoDev>0)
     // 15-07-2008 Marlon Ramos EJECUTAR("BMC",oPos:DOC_NUMERO,oPos:cTipDoc)
     // 15-10-2008 Marlon Ramos (Implementacion del DLL) EJECUTAR("BMC",oPos:DOC_NUMERO,IIF(oPos:nMtoDev>0, "DEV", oPos:cTipDoc),dFechTrans,cHoraTrans)
     MsgRun("Imprimiendo Ticket en "+oDp:cImpFiscal," Por favor Espere ",;
            {||EJECUTAR("BMC_DLL",oPos:DOC_NUMERO,IIF(oPos:nMtoDev>0, "DEV", oPos:cTipDoc),dFechTrans,cHoraTrans)})
  ENDIF

  // 22-09-2008 Marlon Ramos 
     // 29-01-2009 Marlon Ramos (Agregar la Aclas y Okidata)    IF "SAMSUNG"$UPPE(oDp:cImpFiscal) .AND. (oPos:nMtoVta>0 .OR. oPos:nMtoDev>0)
     IF ("SAMSUNG"$UPPE(oDp:cImpFiscal) .OR. "ACLAS"$UPPE(oDp:cImpFiscal) .OR. "OKIDATA"$UPPE(oDp:cImpFiscal) .OR. "STAR"$UPPE(oDp:cImpFiscal)) .AND. (oPos:nMtoVta>0 .OR. oPos:nMtoDev>0)
        MsgRun("Imprimiendo Ticket en "+oDp:cImpFiscal," Por favor Espere ",;
               {||EJECUTAR("DLL_SAMSUNG",oPos:DOC_NUMERO,IIF(oPos:nMtoDev>0, oPos:cTipDocDev, oPos:cTipDoc),dFechTrans,cHoraTrans)})
     ENDIF
  // Fin 22-09-2008 Marlon Ramos 

  // IMPRESION DE DEVOLUCIONES

  IF "FMT:"$UPPE(oDp:cImpFiscal) .AND.  oPos:nMtoDev>0

     nAt   :=AT(":",oDp:cImpFiscal)
     cFmt  :="TICKETDEV" // SUBS(oDp:cImpFiscal,nAt+1,LEN(oDp:cImpFiscal))

     // 25-08-2008 Marlon Ramos 
        /*cWhere:=" WHERE "+;
             "     MOV_CODSUC"+GetWhere("=",oPos:DOC_CODSUC)+;
             " AND MOV_TIPDOC"+GetWhere("=",oPos:cTipDev   )+;
             " AND MOV_DOCUME"+GetWhere("=",oPos:cDevolu   )

        */
        cWhere:=" WHERE MOV_CODSUC"+GetWhere("=",oDp:cSucursal)+;
                "   AND MOV_TIPDOC"+GetWhere("=",oPos:cTipDoc)+;
                "   AND MOV_DOCUME"+GetWhere("=",oPos:DOC_NUMERO)+;
                "   AND MOV_TIPO ='I' "+;
                "   AND MOV_FECHA"+GetWhere("=",dFechTrans)+;
                "   AND MOV_HORA"+GetWhere("=",cHoraTrans)
     // Fin 25-08-2008 Marlon Ramos 

     EJECUTAR("FMTRUN","TICKETDEV",cFmt,"Devolución "+oPos:cDevolu,cWhere)

     oFmt:cWhere:=cWhere

  ENDIF


  // 07-07-2008 Marlon Ramos IF lPrint .AND. oPos:lImpFis .AND. oPos:nMtoDev>0
  IF oPos:lImpFis .AND. oPos:nMtoDev>0
      oPos:CCG_RIF:= AuxcRif
      oPos:CCG_NOMBRE:= AuxcNomb

      MsgRun("Emitiendo Devolución Ticket Fiscal "+oDp:cImpFiscal,"Por Favor Espere....",{||oPos:IMPRIMIR(.F.)})
      //MsgRun("Emitiendo Devolución Ticket Fiscal "+oDp:cImpFiscal,"Por Favor Espere....",{||DPPOSIMPDEV(oPos)})
      oPos:CCG_RIF:= ""
      oPos:CCG_NOMBRE:= ""
  ENDIF

  // JN 04/08/2022
  // Caso de Contingencia, imprime en forma libre
  IF "NING"$UPPER(oDp:cImpFiscal)

    oDp:cWhere:="DOC_TIPDOC"+GetWhere("=",oPos:cTipDoc)
    oDp:cDocNumIni:=oPos:DOC_NUMERO
    oDp:cDocNumFin:=oPos:DOC_NUMERO

    IF oPos:nMtoDev>0

      REPORTE("DOCCLI"+oPos:cTipDev,oDp:cWhere)
      oDp:oGenRep:aCargo:=oPos:cTipDev

      oDp:cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal  )+" AND "+;
                  "DOC_TIPDOC"+GetWhere("=",oPos:cTipDev   )+" AND "+;
                  "DOC_NUMERO"+GetWhere("=",oPos:DOC_NUMERO)+" AND "+;
                  "DOC_TIPTRA"+GetWhere("=","D"            )

    ELSE

      REPORTE("DOCCLI"+oPos:cTipDoc,oDp:cWhere)
      oDp:oGenRep:aCargo:=oPos:cTipDoc

      oDp:cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal  )+" AND "+;
                  "DOC_TIPDOC"+GetWhere("=",oPos:cTipDoc   )+" AND "+;
                  "DOC_NUMERO"+GetWhere("=",oPos:DOC_NUMERO)+" AND "+;
                  "DOC_TIPTRA"+GetWhere("=","D"            )


    ENDIF

    oDp:oGenRep:aCargo:=oPos:cTipDoc

// ?  oPos:nMtoDev,"MTODEV",oPos:cTipDoc,"oPos:cTipDoc"


    oDp:cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal  )+" AND "+;
                "DOC_TIPDOC"+GetWhere("=",oPos:cTipDoc   )+" AND "+;
                "DOC_NUMERO"+GetWhere("=",oPos:DOC_NUMERO)+" AND "+;
                "DOC_TIPTRA"+GetWhere("=","D"            )

    bBlq:=[SQLUPDATE("DPDOCCLI","DOC_IMPRES",.T.,"]+oDp:cWhere+[")]

    oDp:oGenRep:bPostRun:=BLOQUECOD(bBlq) 


  ENDIF

  // Asigna el Cupon Fiscal
  IF !Empty(oPos:cCupon)
     SQLUPDATE("DPDOCCLI","DOC_NUMFIS",oPos:cCupon,   cWhere+" AND DOC_NUMERO"+GetWhere("=",oPos:DOC_NUMERO))
  ENDIF

  oPos:POSREINI(.T.)

  oPos:nNeto:=0
  oPos:nMtoVta:=0    // 06-08-2008 Marlon Ramos
  oPos:nMtoDev:=0    // 06-08-2008 Marlon Ramos
  oPos:nIGTF  :=0    // IGTF JN 04/08/2022
  // Reinicia codigo, JN 23/09/2023
  oPos:oCodCli:VarPut("0000000000",.T.)

  oPos:nIGTF:=0 
  oPos:CALCULAR()

// ? "SAVETICKET",oPos:cCodCli,oTable:DOC_NUMERO

RETURN .T.

/*
// Graba el Documento
*/
FUNCTION SAVEDOC(cTipDoc,lVenta)
//LOCAL oTable
  LOCAL cWhere,oMovi,I,nItem:=0,nCosto:=0,nInvAct:=IIF(lVenta,-1,1),nCant:=0,bCant
  LOCAL aData:={},aTallas:={}
  LOCAL cNumero:="",nLen,nDev:=0,U
  LOCAL cCodCli:=oPos:cCodCli

  //LOCAL cHoraTrans:=TIME()      //Guardar la misma hora en dpdocli y dpmovinv (necesario para no imprimir tickets errados)
  //LOCAL dFechTrans:=oDp:dFecha  //Guardar la misma fecha en dpdocli y dpmovinv "es posible que se imprima a las 11:59:59 pm y quedarian en fechas diferentes" (necesario para no imprimir tickets errados)
  
  IF lVenta

    AEVAL(oPos:oBrwItem:aArrayData,{|a,n| IIF(a[2]>0, AADD(aData,a) , NIL)  })
    nDev:=1
  ELSE

    AEVAL(oPos:oBrwItem:aArrayData,{|a,n| IIF(a[2]<0, AADD(aData,a) , NIL)  })
    AEVAL(aData,{|a,n| aData[n,2]:=ABS(a[2]) })
    nDev:=-1

  ENDIF
  // CRYSTIAN UVIEDO (ADAPTAPRO)   para que al libro de ventas lleve las devoluciones -.
  //SQLUPDATE("DPDOCCLI","DOC_CXC",1,"DOC_CXC=0 AND DOC_TIPDOC='TIK'")
  //SQLUPDATE("DPDOCCLI","DOC_CXC",-1,"DOC_CXC=0 AND DOC_TIPDOC='DEV'")
  // ViewArray(aData)

  oPos:CALCULAR(aData)

  // nNetoOrg

  IF oPos:nNeto=0
     RETURN 0
  ENDIF

  // JN 28/07/2022, Cliente con factura personalizada
  IF STRZERO(0,10)<>oPos:cCodCli .AND. !ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oPos:cCodCli))
     cCodCli:=STRZERO(0,10)
  ENDIF

  cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
          "DOC_TIPTRA='D'"

  IF !oPos:lLibVta .AND. oPos:lCXC

    cNumero:=SQLGETMAX("DPDOCCLI","DOC_NUMERO",cWhere)

  ELSE

    cNumero:=SQLGETMAX("DPDOCCLI","DOC_NUMERO",cWhere+" AND LEFT(DOC_NUMERO,1)"+GetWhere("=",oDp:cTkSerie))

  ENDIF

//? CLPCOPY(oDp:cSql),cWhere,cNumero,oDp:cTkSerie,"oDp:cTkSerie"

  IF Empty(cNumero)

    IF lVenta
      cNumero:=oDp:cTkNumero
    ELSE
      cNumero:=STRZERO(0,10)
    ENDIF

  ENDIF

  nLen   :=10-LEN(ALLTRIM(oDp:cTkSerie))

  cNumero:=RIGHT(cNumero,nLen)
  cNumero:=ALLTRIM(oDp:cTkSerie)+STRZERO(VAL(cNumero)+1,nLen)

// ? cNumero,"cNumero"

  oDp:cTkNumero:=cNumero
  oTable:=OpenTable("SELECT * FROM DPDOCCLI",.F.)
  oTable:SetForeignkeyOff()
  oTable:Replace("DOC_CODIGO",cCodCli       ) // 27/07/2022 oPos:cCodCli  )
  oTable:Replace("DOC_CODVEN",oPos:cCodVen  )
  oTable:Replace("DOC_CENCOS",oPos:cCenCos  )
  oTable:Replace("DOC_CODMON",oPos:cCodMon  )
  oTable:Replace("DOC_CODSUC",oDp:cSucursal )
  oTable:Replace("DOC_OTROS" ,oPos:nDocOtros)
  oTable:Replace("DOC_DCTO"  ,oPos:nDocDesc )
  oTable:Replace("DOC_TIPDOC",cTipDoc       )
  oTable:Replace("DOC_TIPTRA","D"           )
  oTable:Replace("DOC_ACT"   ,1             )
  oTable:Replace("DOC_ESTADO","AC"          )
  oTable:Replace("DOC_VALCAM",oPos:nValCam  )
  oTable:Replace("DOC_IMPRES",.F.           ) // FISCALMENTE NO IMPRESO
  oTable:Replace("DOC_MTODIV",ROUND(oPos:nNeto/oPos:nValCam,2))
 

  // 30-07-2008 Marlon Ramos Guardar la misma fecha y hora en dpdocli y dpmovinv (necesario para no imprimir tickets errados)
    //oTable:Replace("DOC_FECHA" ,oDp:dFecha    )
    //oTable:Replace("DOC_FCHVEN",oDp:dFecha    )
    //oTable:Replace("DOC_HORA"  ,TIME()        )
    oTable:Replace("DOC_FECHA" ,dFechTrans)
    oTable:Replace("DOC_FCHVEN",dFechTrans)
    oTable:Replace("DOC_HORA"  ,cHoraTrans)
  // Fin 30-07-2008 Marlon Ramos

  oTable:Replace("DOC_CXC",nDev             )
  oTable:Replace("DOC_DESTIN","N"           )
  //?"DOC_NETO"  ,oPos:nNeto
  oTable:Replace("DOC_NETO"  ,oPos:nNeto    )

  // 16-10-2008 Marlon Ramos (Guardar el serial de la impresora) oTable:Replace("DOC_CONDIC",NetName()     )
     oTable:Replace("DOC_CONDIC",oDp:cTkImpSer )
  // Fin 16-10-2008 

  oTable:Replace("DOC_USUARI",oDp:cUsuario    )
// oTable:Replace("DOC_MODFIS",oDp:cDenFiscal )
  oTable:Replace("DOC_DOCORG","P"             ) // Punto de Venta
  oTable:Replace("DOC_SERFIS",oDp:cTkSerie    )
  oTable:Replace("DOC_FACAFE" ,oPos:cTicketDev)

  IF !lVenta
     oTable:Replace("DOC_FACAFE" ,oPos:cTicketDev)
     oTable:Replace("DOC_TIPAFE" ,oPos:cTipDev   ) // tipo de devolución
     oPos:cDevolu:=cNumero
  ENDIF

  IF Empty(oDp:cDenFiscal)
     oTable:Replace("DOC_MODFIS",oDp:cImpFiscal)
  ENDIF

// oTable:Replace("DOC_MODFIS",oDp:cDenFiscal)
// oTable:Replace("DOC_NUMERO",SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO",cWhere))

  oTable:Replace("DOC_NUMERO",cNumero      )


  // 09-06-2008 Marlon Ramos (Evitar descuadres entre bruto, iva y neto)
   //?"Bruto",oPos:nBruto,"DOC_MTOIVA",oPos:nIvA
   oTable:Replace("DOC_BASNET",oPos:nBruto)
   oTable:Replace("DOC_MTOIVA",oPos:nIvA  )
  // Fin 09-06-2008 Marlon Ramos 

  oTable:Replace("DOC_NETO"  ,oPos:nIvA+oPos:nBruto )

// ? oPos:nIvA,"oPos:nIvA",oPos:nBruto,"oPos:nBruto"

  IF lVenta
    AEVAL(oTable:aFields , { | a,n | oPos:Set(a[1],oTable:FieldGet(n)) })
  ENDIF

  oTable:Commit()
  oTable:End()

  AADD(oPos:aDocSave,{cTipDoc,cNumero}) // 18/11/2022,utilizado en DPPOSPRINT para imprimir documentos

  oPos:DOC_CODSUC:=oDp:cSucursal
  oPos:DOC_TIPDOC:=cTipDoc
  oPos:DOC_NUMERO:=cNumero

  IF !Empty(oPos:CCG_RIF)
     EJECUTAR("DPCLICEROGRAB",oPos,.T.)
  ENDIF

  // Ahora grabamos el Cuerpo
  oMovi:=OpenTable("SELECT * FROM DPMOVINV",.F.)
  oMovi:SetForeignkeyOff()

  // aData:=ACLONE(oPos:oBrwItem:aArrayData)
  // Grabar el Cuerpo de la venta

//ViewArray(aData)

  FOR I=1 TO LEN(aData)

     nCant:=aData[I,3]

     IF !Empty(aData[I,6])



       nItem++
       nCosto:=EJECUTAR("INVCOSPRO" , aData[I,6] , aData[I,11] , oDp:cSucursal , oPos:dFecha,TIME())

       oMovi:Append()

       // JN 21/01/2011
       // Corrige Unidad de Medida, Errónea Importada desde Pedidos
       //

       aData[I,11]:=EJECUTAR("INVGETCXUND",aData[I,6],aData[I,10] )

       oMovi:Replace("MOV_CODIGO", aData[I,6]   )
       oMovi:Replace("MOV_TIPIVA", aData[I,8]   )
       oMovi:Replace("MOV_CODTRA", oPos:cCodTra )
       oMovi:Replace("MOV_CODALM", oPos:cCodAlm )
       oMovi:Replace("MOV_FISICO", nInvAct )
       oMovi:Replace("MOV_LOGICO", nInvAct )
       oMovi:Replace("MOV_CONTAB", nInvAct )
       oMovi:Replace("MOV_INVACT",  1 )
       oMovi:Replace("MOV_APLORG", "V")
       oMovi:Replace("MOV_CODCTA", oPos:cCodCli      )

       // 30-07-2008 Marlon Ramos Guardar la misma fecha y hora en dpdocli y dpmovinv (necesario para no imprimir tickets errados)
         //oMovi:Replace("MOV_FECHA" , oPos:dFecha       )
         //oMovi:Replace("MOV_HORA"  , TIME()            )
         oMovi:Replace("MOV_FECHA" ,dFechTrans)
         oMovi:Replace("MOV_HORA"  ,cHoraTrans)
       // Fin 30-07-2008 Marlon Ramos

       oMovi:Replace("MOV_DOCUME", oTable:DOC_NUMERO )
       oMovi:Replace("MOV_CODSUC", oTable:DOC_CODSUC )
       oMovi:Replace("MOV_TIPDOC", oTable:DOC_TIPDOC )
       oMovi:Replace("MOV_TIPO"  , "I"               ) // Individual
       oMovi:Replace("MOV_ITEM"  , STRZERO(nItem,LEN(oMovi:MOV_ITEM)))
       oMovi:Replace("MOV_LISTA" , oPos:cPrecio      )
       oMovi:Replace("MOV_IVA"   , aData[I,7]        )
       oMovi:Replace("MOV_TOTAL" , ABS(aData[I,2])   )
       oMovi:Replace("MOV_CANTID", ABS(aData[I,3])   )
       oMovi:Replace("MOV_PRECIO", aData[I,4]        )
       oMovi:Replace("MOV_UNDMED", aData[I,10]       )
       oMovi:Replace("MOV_CXUND" , aData[I,11]       )
       oMovi:Replace("MOV_COSTO" , nCosto            )
       oMovi:Replace("MOV_USUARI", oDp:cUsuario      )
       oMovi:Replace("MOV_CAPAP" , aData[I,14]       )
       oMovi:Replace("MOV_LOTE"  , aData[I,15]       )
       oMovi:Replace("MOV_PREDIV", ROUND(aData[I,4]/oPos:nValCam,2))

       // IVA En ZONA LIBRE
       IF oPos:cZonaNL="L"
          oMovi:Replace("MOV_IVA"   , 0    )
          oMovi:Replace("MOV_TIPIVA", "EX" )
       ENDIF

       // 04-08-2008 Marlon Ramos oMovi:Replace("MOV_CODVEN", aData[I,12]       )
       // Como se activó el vendedor en DPPOS01 se debe asegurar que todos los productos tengan el mismo vendedor
       // Fin 04-08-2008 Marlon Ramos 

       oMovi:Replace("MOV_CODVEN", oPos:cCodVen)  
       // 10-10-2008 Marlon Ramos (No grababa el descuento en Devoluciones) oMovi:Replace("MOV_DESCUE", VAL(SUBSTR(aData[I,5],1,2)))
       oMovi:Replace("MOV_DESCUE", aData[I,13])

       aTallas:=ACLONE(aData[I,16])

       FOR U=1 TO LEN(aTallas)
         oMovi:Replace("MOV_TALL"+STRZERO(U,2),aTallas[u])
       NEXT U

       oMovi:Commit()

// ? oDp:cSql

     ENDIF

  NEXT I

  oMovi:End()
  //JHON 17/07/2007 
  oPos:nDocDesc:=0
       //oMovi:Replace("MOV_DESCUE", aData[I,13]       )

  // Guardar Clientes CERO
  // ? cCodCli,oPos:cCodCli,"pago centralizado",oPos:CCG_RIF,"oPos:CCG_RIF"

  IF cCodCli<>oPos:cCodCli 
    oPos:CCG_NOMBRE:=cNomCli
    EJECUTAR("DPCLIENTESCEROCREA",oTable:DOC_CODSUC,oTable:DOC_TIPDOC,oTable:DOC_NUMERO,oPos:cCodCli,oPos:CCG_NOMBRE,oPos:CCG_DIR1,oPos:CCG_DIR2,oPos:CCG_DIR3) //,cMuni,cZona,cCodCla)
    SQLUPDATE("DPCLIENTESCERO","CCG_NOMBRE",cNomCli,"CCG_RIF"+GetWhere("=",oPos:cCodCli))
  ENDIF

RETURN oPos:nNeto
// EOF

// Programa   : DPPOSCAJAMOV
// Fecha/Hora : 24/02/2006 07:43:21
// Propósito  : Genera los Asientos de Caja
// Creado Por : Juan Navas
// Modificado : Marlon Ramos 03-06-2008 (Evitar descuadres entre bruto, iva y neto)
// Llamado por: DPPOS
// Aplicación : Ventas
// Tabla      : DPCAJAMOV

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cCodTick,cTipDoc,cCtaCaja,cBanco,cNumero,dFecha,nMonto,cWhere,cCuenta,cMarcaF,cPosBco,lDivisa,nMtoDiv)
   LOCAL aLine
   LOCAL oTable,cCodBco:="",oTableD
  
   DEFAULT cWhere:="",lDivisa:=.F.

// ? lDivisa,"lDivisa"
// ? cCodTick,cTipDoc,cCtaCaja,cBanco,cNumero,dFecha,nMonto,cWhere,cCuenta,cMarcaF,cPosBco,"AQUI ESTA JEJEJEJE"

   IF !Empty(cPosBco)
      cCodBco:=MYSQLGET("DPPOSBANCARIO","PVB_CODBCO","PVB_CODIGO"+GetWhere("=",cPosBco))
   ENDIF
  
   IF !Empty(cWhere)
      cWhere:=" WHERE "+cWhere
   ENDIF
 
   oTable:=OpenTable("SELECT * FROM DPCAJAMOV "+cWhere," WHERE "$cWhere)

//   ? oTable:Recno(),cWhere

   IF oTable:RecCount()=0
     oTable:Append()
     oTable:Replace("CAJ_NUMTRA",SQLINCREMENTAL("DPCAJAMOV","CAJ_NUMTRA","CAJ_CODCAJ"+GetWhere("=",cCtaCaja)))
   ENDIF

   // ? cCtaCaja," CUENTA CAJA",nMonto,"Monto"


//? cCodTick

   oTable:Replace("CAJ_DOCASO",cCodTick)
   oTable:Replace("CAJ_CODSUC",oDp:cSucursal     )
   oTable:Replace("CAJ_CODCAJ",cCtaCaja          )
   oTable:Replace("CAJ_ORIGEN",oPos:DOC_TIPDOC   ) 
   oTable:Replace("CAJ_FECHA" ,dFecha            ) // Fecha de la Transacción
   oTable:Replace("CAJ_FCHCON",oPos:DOC_FECHA )    // Fecha para Contabilizar
   oTable:Replace("CAJ_HORA"  ,IIF(oPos:DOC_TIPDOC="DEV",TIME(),oPos:DOC_HORA)  )
   oTable:Replace("CAJ_DESCRI","Ticket: "+cCodTick  )
   oTable:Replace("CAJ_CODMON",oPos:cMonedaPago)

   /* 03-06-2008 Marlon Ramos (Evitar descuadres entre bruto, iva y neto)
   oTable:Replace("CAJ_MONTO" ,ABS(nMonto))
   */
//   nMonto:=STR(nMonto,12,5)
//   nMonto:=VAL(LEFT( nMonto,IIF( AT(".",nMonto)>0,AT(".",nMonto)-1,LEN(nMonto) ) )+IIF( AT(".",nMonto)>0, SUBSTR( nMonto,AT(".",nMonto),3 ),"" ))

     oTable:Replace("CAJ_MONTO" ,nMonto)
   // Fin 03-06-2008 Marlon Ramos 

   /* 23-06-2008 Marlon Ramos (Realizar correctamente la devolución)
   oTable:Replace("CAJ_DEBCRE",IF(nMonto>0,1,-1) )            // Todo Ingresa
   */
   oTable:Replace("CAJ_DEBCRE",IF(oPos:DOC_TIPDOC="DEV",-1,1) ) 
   // Fin 23-06-2008 Marlon Ramos 

   oTable:Replace("CAJ_TIPO"  ,cTipDoc)
   oTable:Replace("CAJ_CODMAE",oPos:DOC_CODIGO)
   oTable:Replace("CAJ_NUMCAJ",oDp:cPcName    ) // oDp:cIpLocal   )
   oTable:Replace("CAJ_USUARI",oDp:cUsuario   )
   oTable:Replace("CAJ_NUMERO",cNumero        )
   oTable:Replace("CAJ_CHQCTA",cCuenta        )
   oTable:Replace("CAJ_CONTAB","N"            )
   oTable:Replace("CAJ_ACT"   ,1  ) 
   oTable:Replace("CAJ_CENCOS",oPos:DOC_CENCOS)

      // Requiere Directorio Bancario
   oTable:Replace("CAJ_BCODIR",cBanco)
   // Requiere Directorio Bancario
   oTable:Replace("CAJ_POSBCO" ,cPosBco)
   oTable:Replace("CAJ_MARCAF" ,cMarcaF)
   oTable:Replace("CAJ_CODBCO" ,cCodBco)

   IF oPos:cMonedaPago=oDp:cMonedaExt
     nMonto:=oPos:nEfectivo
     oTable:Replace("CAJ_MONTO" ,ABS(nMonto*oDp:nMonedaExt))
     oTable:Replace("CAJ_MTODIV",ABS(oPos:nRecibe))
     oTable:Replace("CAJ_VALCAM",oDp:nMonedaExt)
     
   ENDIF

   // JN 11/07/2022
   IF lDivisa

     // nMonto:=IF(nMonto=0,nMtoDiv*oPos:nValCam,nMonto)
     nMonto:=nMtoDiv*oPos:nValCam // 25/09/2023


     oTable:Replace("CAJ_MONTO" ,nMonto      )
     oTable:Replace("CAJ_MTODIV",nMtoDiv     )
     oTable:Replace("CAJ_VALCAM",oPos:nValCam)
     oTable:Replace("CAJ_MTOITF",oPos:nIGTF)

   ENDIF

// AEVAL(oTable:aFields,{|a,n| AADD(aLine,oTable:FieldGet(n))})
   aLine:=ACLONE(oTable:aBuffers)
// ViewArray(oTable:aBuffers)

   IF !oTable:Commit(cWhere)
      oTable:End()
      RETURN .F.
   ENDIF

//  ? oPos:nVueltoD,"oPos:nVueltoD"
  
   // Vuelto oPos:nVueltoD
   // 25/09/2023 no puede realizar salidas de caja por temas de vuelto.
   IF oPos:nVueltoD>0 .AND. .F.

     oTable:aBuffers:=ACLONE(aLine)
     oTableD:=OpenTable("SELECT * FROM DPCAJAMOV",.F.)
     oTableD:AppendBlank()
     AEVAL(oTable:aFields,{|a,n| oTableD:Replace(a[1],oTable:FieldGet(a[1]))})

     oTableD:Replace("CAJ_MONTO" ,oPos:nVueltoBs)
     oTableD:Replace("CAJ_MTODIV",oPos:nVueltoD)
     oTableD:Replace("CAJ_DEBCRE",.F. ) // !oTable:CAJ_DEBCRE)
     oTableD:Replace("CAJ_VALCAM",oDp:nMonedaExt)
     oTableD:Commit()
     oTableD:End()

   ENDIF

   oTable:End()

   // Reseta Variables para futuros Pagos
   oPos:cMonedaPago:=oDp:cMoneda
   oPos:nVueltoBs  :=0
   oPos:nVueltoD   :=0

RETURN .T.
// EOF

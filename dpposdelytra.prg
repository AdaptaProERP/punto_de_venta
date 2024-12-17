// Programa   : DPPOSDELYTRA
// Fecha/Hora : 19/10/2006 14:53:31
// Propósito  : Agregar Transporte en Delivery
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  LOCAL nAt:=0

  IF Empty(oDp:cCodTrans) .OR. Empty(oPOSCOMANDA:nTarifa)
     // No usa Transporte
     RETURN .T.
  ENDIF

  nAt:=ASCAN(oPOSCOMANDA:oBrw:aArrayData,{|a,n|a[1]=oDp:cCodTrans })

  IF nAt>0 // Transporte ya Existe
    RETURN .F.
  ENDIF

  IF !ISMYSQLGET("DPINV","INV_CODIGO",oDp:cCodTrans)
     MensajeErr("Código: "+ALLTRIM(oDp:cCodTrans)+" no Existe en la Tabla de Productos")
  ENDIF

  oPOSCOMANDA:oCOM_CODIGO:VarPut(oDp:cCodTrans,.T.)
  oPOSCOMANDA:COM_DESCRI :=MYSQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oDp:cCodTrans))
  oPOSCOMANDA:oCOM_CANTID:=1
  oPOSCOMANDA:COM_UNDMED :=oDp:cUndMedPos
  oPOSCOMANDA:COM_PRECIO :=oPOSCOMANDA:nTarifa
  oPOSCOMANDA:COM_LPT    :="Ning"

  oPOSCOMANDA:SAVE()

RETURN .T.
// EOF

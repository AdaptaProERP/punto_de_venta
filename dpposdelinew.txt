// Programa   : DPPOSDELINEW
// Fecha/Hora : 17/10/2006 19:30:55
// Propósito  : Generar Nuevo Pedido
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA/PRINTCMD
// Aplicación : Ventas
// Tabla      : DPPOSCOMANDA

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL aObj:={},aLine:={},aData:={}

   IF TYPE("oPOSCOMANDA")!="O"
      RETURN .F.
   ENDIF

   AADD(aObj , oPOSCOMANDA:oRif       )
   AADD(aObj , oPOSCOMANDA:oNombre    )
   AADD(aObj , oPOSCOMANDA:oDir1      )
   AADD(aObj , oPOSCOMANDA:oDir2      )
   AADD(aObj , oPOSCOMANDA:oDir3      )
   AADD(aObj , oPOSCOMANDA:oDirE1     )
   AADD(aObj , oPOSCOMANDA:oDirE2     )
   AADD(aObj , oPOSCOMANDA:oDirE3     )
   AADD(aObj , oPOSCOMANDA:oTel1      )
   AADD(aObj , oPOSCOMANDA:oTel2      )
   AADD(aObj , oPOSCOMANDA:oCOM_CODIGO)
   AADD(aObj , oPOSCOMANDA:oCOM_COMENT)

   AEVAL(aObj,{|o,n,uValue|uValue:=CTOEMPTY(EVAL(o:bSetGet)),o:VarPut(uValue,.T.)})

   oPOSCOMANDA:cPedido:=SQLINCREMENTAL("DPPOSCOMANDA","COM_PEDIDO","COM_LLEVAR=1")
   oPOSCOMANDA:oPedido:Refresh(.T.)

   oPOSCOMANDA:COM_PEDIDO:=""
   oPOSCOMANDA:cPedido   :=""

   AEVAL(oPOSCOMANDA:oBrw:aArrayData[1],{|uValue,n|AADD(aLine,CTOEMPTY(uValue)) })
   AADD(aData,aLine)

   oPOSCOMANDA:oBrw:aArrayData:=ACLONE(aData)
   oPOSCOMANDA:oBrw:nArrayAt:=1
   oPOSCOMANDA:oBrw:nRowSel :=1
   oPOSCOMANDA:oBrw:Refresh(.T.)
   oPOSCOMANDA:oBrw:Gotop(.T.)
   oPOSCOMANDA:nTarifa:=0

   oPOSCOMANDA:CALTOTAL()

   oPOSCOMANDA:oRif:VarPut(SPACE(10),.T.)
   oPOSCOMANDA:cOldcRif:=""

   DPFOCUS(oPOSCOMANDA:oRif)

RETURN .T.
// EOF

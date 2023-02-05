// Programa   : DPPOSPEDEDIT
// Fecha/Hora : 10/10/2006 15:47:00
// Propósito  : Leer Datos  del Delivery 
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPosComanda,cPedido)

  LOCAL cWhere,aData,cSql,cRif,oTable,cHora

  cWhere:=" COM_LLEVAR=1 AND COM_TIPO='P' "+;
          IIF(Empty(cPedido)," AND 1=0 ","")+;
          IIF(Empty(cPedido),""," AND COM_PEDIDO"+GetWhere("=",cPedido))

  aData:=ASQL(" SELECT COM_CODIGO,COM_DESCRI,COM_MESA,COM_MESERO,"+;
              " COM_PEDIDO,COM_CANTID, COM_ITEM,COM_UNDMED, COM_PRECIO, "+;
              " COM_RIF,COM_HORA FROM DPPOSCOMANDA "+;
              " WHERE "+cWhere )

  IF Empty(aData)
     MensajeErr("Noy hay Datos")
     RETURN .F.
  ENDIF

  cRif :=aData[1,10]
  cHora:=aData[1,11]

  oPOSCOMANDA:oBrw:aArrayData:=ACLONE( aData )

  oPOSCOMANDA:oBrw:Gotop(.T.)
  oPOSCOMANDA:oBrw:Refresh(.T.)

  oTable:=OpenTable("SELECT * FROM DPCLIENTESDELY WHERE CDL_RIF"+GetWhere("=",cRif),.T.)

  oPOSCOMANDA:oRif:VarPut(cRif,.T.)
  oPOSCOMANDA:oNombre:VarPut(oTable:CDL_NOMBRE,.T.)

  oPOSCOMANDA:oDir1:VarPut(oTable:CDL_DIR1,.T.)
  oPOSCOMANDA:oDir2:VarPut(oTable:CDL_DIR2,.T.)
  oPOSCOMANDA:oDir3:VarPut(oTable:CDL_DIR3,.T.)
 
  oPOSCOMANDA:oDirE1:VarPut(oTable:CDL_DIREN1,.T.)
  oPOSCOMANDA:oDirE2:VarPut(oTable:CDL_DIREN1,.T.)
  oPOSCOMANDA:oDirE3:VarPut(oTable:CDL_DIREN1,.T.)
  oPOSCOMANDA:oZona:VarPut(oTable:CDL_ZONA   ,.T.)

  ComboIni(oPOSCOMANDA:oZona)
  Eval(oPOSCOMANDA:oZona:bChange)

  oPOSCOMANDA:oTel1:VarPut(oTable:CDL_TEL1,.T.)
  oPOSCOMANDA:oTel2:VarPut(oTable:CDL_TEL2..T.)

  oPOSCOMANDA:cPedido   :=cPedido
  oPOSCOMANDA:cHora     :=cHora
  oPOSCOMANDA:COM_PEDIDO:=cPedido

  oPOSCOMANDA:oPedido:Refresh(.T.)

  oTable:End()

  oPOSCOMANDA:CALTOTAL()

  DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)

  // Ahora Buscamos los datos del Cliente

RETURN .T.
// EOF

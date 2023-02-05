// Programa   : DPPOSSAVECLI
// Fecha/Hora : 10/10/2006 10:58:52
// Propósito  : Grabar Cliente desde 
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : Punto de Venta (Delyveri)
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oForm)
  LOCAL oTable

  IF Empty(oPOSCOMANDA:cRif) // .AND. oPOSCOMANDA:lDely
    oPOSCOMANDA:cRif:="0"
  ENDIF

  IF MYSQLGET("DPCLIENTESDELY","CDL_PEDIDO","CDL_RIF"+GetWhere("=",oPOSCOMANDA:cRif))=oPOSCOMANDA:cRif

     IF !oPOSCOMANDA:lDely
       RETURN .T.
     ENDIF

  ENDIF

  oTable:=OpenTable("SELECT * FROM DPCLIENTESDELY WHERE CDL_RIF"+GetWhere("=",oPOSCOMANDA:cRif),.T.)
  
  IF oTable:RecCount()=0
     oTable:Append()
     oTable:cWhere:=NIL
  ENDIF

  oTable:Replace("CDL_RIF"   ,oPOSCOMANDA:cRif   )
  oTable:Replace("CDL_NOMBRE",oPOSCOMANDA:cNombre)
  oTable:Replace("CDL_PEDIDO",oPOSCOMANDA:cPedido)
  oTable:Replace("CDL_DIR1"  ,oPOSCOMANDA:cDir1  )
  oTable:Replace("CDL_DIR2"  ,oPOSCOMANDA:cDir2  )
  oTable:Replace("CDL_DIR3"  ,oPOSCOMANDA:cDir3  )
  oTable:Replace("CDL_DIREN1",oPOSCOMANDA:cDirE1 )
  oTable:Replace("CDL_DIREN2",oPOSCOMANDA:cDirE2 )
  oTable:Replace("CDL_DIREN3",oPOSCOMANDA:cDirE3 )
  oTable:Replace("CDL_TEL1"  ,oPOSCOMANDA:cTel1  )
  oTable:Replace("CDL_TEL2"  ,oPOSCOMANDA:cTel2  )
  oTable:Replace("CDL_ZONA"  ,oPOSCOMANDA:cZona  )
  oTable:Replace("CDL_ZONA2" ,oPOSCOMANDA:cMunici)

  oTable:Commit(oTable:cWhere)
  oTable:End()
 
RETURN .T.
// EOF

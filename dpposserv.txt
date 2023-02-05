// Programa   : DPPOSSERV
// Fecha/Hora : 03/07/2006 22:38:12
// Propósito  : Crear Item de Servicio en el Ticket
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : Ventas
// Tabla      : DPMOVINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTicket)
  LOCAL oTable,cGrupo

  IF Empty(oDp:nPorSerPos) .OR. ISMYSQLGET("DPINV","INV_CODIGO",oDp:cCodSer)
     RETURN .T.
  ENDIF

  cGrupo:=SQLGETMIN("DPGRU","GRU_CODIGO") // Busca el Primer Grupo

  IF Empty(cGrupo) 
     MensajeErr("Es necesario Crear Código ["+ALLTRIM(oDp:cCodSer)+"] para Servicios")
     RETURN .F.
  ENDIF

  oTable:=OpenTable("SELECT * FROM DPINV ",.F.)
  oTable:Append()
  oTable:Replace("INV_CODIGO",oDp:cCodSer)
  oTable:Replace("INV_DESCRI","Servicio" ) 
  oTable:Replace("INV_GRUPO" ,cGrupo     )
  oTable:Replace("INV_IVA"   ,"EX"       )
  oTable:Replace("INV_ESTADO","A"        )
  oTable:Replace("INV_UTILIZ","S"        )
  oTable:Replace("INV_METCOS","P"        )
  oTable:Replace("INV_PROCED","N"        )

  oTable:COMMIT()

RETURN .T.

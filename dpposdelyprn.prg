// Programa   : DPPOSDELYPRN
// Fecha/Hora : 26/08/2006 13:54:46
// Propósito  : Imprimir Comanda
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : Ventas
// Tabla      : DPPOSCOMANDA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cPedido,cUS)
   LOCAL aLpt:={},cWhere,I,oRun

   DEFAULT cPedido:=STRZERO(1,10),;
           cUs  :=oDp:cUsuario

   cWhere:=" COM_PEDIDO"+GetWhere("=",cPedido)+" AND COM_LLEVAR=1 AND COM_IMPRES=0 "+;
           " AND COM_LPT<>'NING' AND COM_LPT<>''"

   IF !Empty(cUs)
      cWhere:=cWhere +" AND COM_USUARI"+GetWhere("=",cUs)
   ENDIF

   aLpt  :=ASQL("SELECT COM_LPT FROM DPPOSCOMANDA WHERE "+cWhere+" GROUP BY COM_LPT")

   IF Empty(aLpt)
      MensajeErr("No hay Comandas para Imprimir")
      RETURN .F.
   ENDIF

   FOR I=1 TO LEN(aLpt)

     oRun:=EJECUTAR("FMTRUN","COMANDAS","COMANDASXPED","Comandas por Pedido "+cPedido+;
                   " Dispositivo "+aLpt[I,1],cWhere+" AND COM_LPT"+GetWhere("=",aLPT[I,1]),aLPT[I,1]+":")

     oRun:SETDEVICE(aLpt[I,1]+":")
//     oRun:lClose:=.T. // Cierra Automáticamente
//   oRun:FMTSTART()

   NEXT I

RETURN .T.

// EOF


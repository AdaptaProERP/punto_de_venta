// Programa   : DPPOSIMPDEV
// Fecha/Hora : 10/02/2007 12:26:42
// Propósito  : Imprimir Devolución Punto de Venta
// Creado Por : Juan Navas
// Llamado por: DPPOSGRABAR
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPos)

   LOCAL cTipDev:="DEV"
   LOCAL cNumDev:="A"+STRZERO(1,9)

   IF ValType(oPos)="O"
      cTipDev   :=oPos:cTipDev
      cNumDev   :=oPos:cDevolu
   ENDIF

   DO CASE

      CASE oDp:cImpFiscal="BMC"
         EJECUTAR("BMC",cNumDev,cTipDev)

      CASE UPPER(oDp:cImpFiscal)="BEMATECH"
        // 04-07-2008 Marlon Ramos (Imprimir Devolución de la Bematech)
           EJECUTAR("DPPOSPRINT",.F.)
        // Fin 04-07-2008 Marlon Ramos 

   ENDCASE

RETURN .T.
// EOF

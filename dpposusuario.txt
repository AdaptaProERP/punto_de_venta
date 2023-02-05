// Programa   : DPPOSUSUARIO
// Fecha/Hora : 20/09/2006 11:05:09
// Propósito  : Realizar Cambio de Usuario en Punto de Venta
// Creado Por : Juan Navas
// Llamado por: DPPOS01
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oForm)

  GetUsuario(.T.,"00M20",.F.)

  EJECUTAR("DPLOADCNF")  

  IF ValType(oForm)="O"

     EJECUTAR("DPPRIVVTALEE",oForm:cTipDoc,.F.) // Lee los Privilegios del Usuario
  
  ENDIF      

RETURN .T.
// EOF

// Programa   : DPPOSCALIGTF
// Fecha/Hora : 12/07/2022 01:41:37
// Propósito  : Calcular IGTF
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipo,nPor,nMonto)
  LOCAL nGTF:=0
  LOCAL lCal:=.T. 
  
// ICJ_PORITF
// ICJ_CALITF
  
  DEFAULT cTipo :="DOL",;
          nPor  :=SQLGET("DPCAJAINST","ICJ_PORITF","ICJ_CODIGO"+GetWhere("=",cTipo)+" AND ICJ_CALITF=1"),;
          nMonto:=oPos:nNeto

  // IGTF Solo Aplica en Ticket o Factura, los demás documentos podra utilizar pago en el formulario DIVISA
  IF oPos:cTipDoc="TIK" .OR. oPos:cTipDoc="FAV"
    oPos:nIGTF:=PORCEN(nMonto,nPor)
  ENDIF

  oPos:oIGTF:Refresh(.T.)
  oPos:oNeto:Refresh(.T.)
  oPos:oNetoUsd:Refresh(.T.)

RETURN oPos:nIGTF
// EOF	

// Programa   : DPPOSGUIACARPRN
// Fecha/Hora : 07/12/2006 11:11:28
// Prop�sito  : Reimprimir Guia de Carga
// Creado Por : Juan Navas
// Llamado por: 
// Aplicaci�n : Ventas
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

    LOCAL cNumGtr:=SPACE(10),cWhere:=""

    cWhere:=GetWhereAnd("GTR_FECHA",oDp:dFecha,oDp:dFecha)

    DPBRWPAG("DPGUIACARGA.BRW",NIL,@cNumGtr,"GTR_NUMERO",.T.,"GTR_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+cWhere)

    IF !Empty(cNumGtr)

      EJECUTAR("FMTRUN","RUTADESPACHO","RUTADESPACHO","Imprimir Gu�a de Despacho "+cNumGtr,;
                        "GTR_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                        "GTR_NUMERO"+GetWhere("=",cNumGtr))

    ENDIF

RETURN .T.

// Programa   : DPPOS_10IVA
// Fecha/Hora : 22/12/2016 02:18:31
// Propósito  : Punto de Venta, Facturación Condicionado
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oPos,lOn)
  LOCAL aInsCaj:={"TDB","CTKE"}
  LOCAL cTitle :="",nAt,cTitle

  AEVAL(aInsCaj,{|a,n| SQLUPDATE("DPCAJAINST",{"ICJ_PAGELE","ICJ_ACTIVO","ICJ_INGRES"},{.T.,.T.,.T.},"ICJ_CODIGO"+GetWhere("=",a)+" AND ICJ_PAGELE IS NULL ")})

  DEFAULT oPos:=EJECUTAR("DPPOSINI"),;
          lOn    :=.T.

  oPos:lLimite     :=lOn      // Documento con Limites
  oPos:lPagEle     :=lOn      // Pago en formas electrónica
  oPos:nLimite     :=200000   // Limite del Monto
  oPos:cTipPer     :="N"      // Personas Naturales
  oPos:nIvaGN      :=10       // Iva GN es 10%
  oPos:cTipIvaLim  :="PE"     // Tipo de IVA
  oPos:dDesdeLim   :=CTOD("24/12/2016")
  oPos:dHastaLim   :=CTOD("24/12/2016")+90
  oPos:cTitleCli   :="Clientes [Personas Naturales]"
  oPos:cWhereCli   :="(CLI_SITUAC='A' OR CLI_SITUAC='C') AND CLI_TIPPER"+GetWhere("=","N")

  cTitle:=oPos:oWnd:cTitle
  nAt   :=AT("Limitada",cTitle)

  IF nAt>0

     cTitle:=LEFT(cTitle,nAt-1)
     oPos:oWnd:SetText(cTitle)
     oPos:cTitle_:=cTitle

  ENDIF
 
  IF lOn

    oPos:oWnd:SetText(oPos:oWnd:cTitle+" Limitada ["+FDP(oPos:nLimite,"999,999")+" Persona Natural, Pago Electrónico]")
  ELSE

    oPos:cWhereCli   :="(CLI_SITUAC='A' OR CLI_SITUAC='C') "
    oPos:nLimite     :=0
//    oPos:lPar_AutoImp:=oPos:lParAutoImp // Restaura AutoImpresión
    oPos:dDesdeLim   :=CTOD("")
    oPos:dHastaLim   :=CTOD("")

  ENDIF

  oPos:cTitle_:=oPos:oWnd:cTitle

RETURN nil
// EOF


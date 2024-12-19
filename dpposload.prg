// Programa   : DPPOSLOAD
// Fecha/Hora : 25/10/2005 22:44:33
// Prop¢sito  : Carga los Valores del Display
// Creado Por : Juan Navas
// Llamado por: DPPOS
// Aplicaci¢n : Ventas
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cIp,lAuto)
  LOCAL oData
  LOCAL oDb:=OpenOdbc(oDp:cDsnData)

  DEFAULT cIp:=oDp:cIpLocal,;
          lAuto:=.F.

  oDp:cTkSerie :=""
  oDp:cTkNumero:=""
  oDp:cTkImpSer:=""   // 16-10-2008 Marlon Ramos 

  oData:=DATACONFIG("POS","PC",,,,,,cIp)

  oDp:cDisp_Com     :=oData:Get("cDisp_Com"     , "COM1"      )
  oDp:cDisp_nBaude  :=oData:Get("cDisp_nBaude"  , 9600        )
  oDp:cDisp_nBits   :=oData:Get("cDisp_nBits"   , 8           ) // oData:Get("
  oDp:cDisp_nparity :=oData:Get("cDisp_nparity" , 0           )
  oDp:cDisp_nstopbit:=oData:Get("cDisp_nstopbit", 1           )
  oDp:cDisp_lGaveta :=oData:Get("cDisp_lGaveta" , .F.         )
  oDp:cDisp_lDisplay:=oData:Get("cDisp_lDisplay", .F.         )
  oDp:cDenFiscal    :=oData:Get("cDenFiscal"    , ""          ) // Denominación Fiscal
  oDp:cImpFiscal    :=oData:Get("cImpFiscal"    , ""          )
  oDp:cFileBal      :=oData:Get("cFileBal"      , ""          )
  oDp:lTactil       :=oData:Get("lTactil"       , oDp:lTactil )
  oDp:lImpFis       :=(ALLTRIM(oDp:cImpFiscal)!="NINGUNA")
  oDp:cModeloPos    :=oData:Get("cModelo"       , "Clasico"   )
  oDp:cPrecioPos    :=oData:Get("cPrecio"       , "A"         )
  oDp:cUndMedPos    :=oData:Get("cUnidad"       , oDp:cUndMed )
  oDp:cCodMonPos    :=oData:Get("cCodMon"       , oDp:cMoneda )
  oDp:nPorSerPos    :=oData:Get("nPorSer"       , 0           ) // % por Servicio

  oDp:nPorReg       :=oData:Get("nPorReg"       , 0           )
  oDp:cImpCta       :=oData:Get("cImpCta"   , "Ninguna")
  oDp:cImpCmd       :=oData:Get("cImpCmd"   , "Ninguna")
  oDp:cCodSer       :=oData:Get("cCodSer"   , "SERVICIO"  ) // Código del Producto Servicio

// JN 01/04/2016
  oDp:cCodTrans     :=oData:Get("cCodTrans" , "FLETE"     ) // Código del Producto Transporte
  oDp:cCajaPos      :=oData:Get("cCajaPos"  , oDp:cCaja   ) // Caja para el Pos
  oDp:cCajaDeli     :=oData:Get("cCajaDeli" , oDp:cCaja   ) // Caja para Delivery
  oDp:lDelivery     :=oData:Get("lDelivery" , .F.         ) // Indica si Activa Delivery
  oDp:cCajaDeli     :=oData:Get("cCajaDeli" , oDp:cCaja   ) // Caja para Delivery
  oDp:lDpPosCli     :=oData:Get("lDpPosCli" , .F.         ) // Requiere Cliente Cero en Punto de Venta
  oDp:lDpPosPeso    :=oData:Get("lDpPosPeso", .F.         ) // Activa o Inactiva Columna Peso
  oDp:cTipDocVta    :=oData:Get("cTipDocVta", "TIK"       )
  oDp:cTipDocDev    :=oData:Get("cTipDocDev", "DEV"       )

  DEFAULT oDp:cCajaDeli:=oDp:cCaja

  oData:End(.F.)

  oDp:cCodMonPos:=LEFT(oDp:cCodMonPos,3)
  oDp:cMoneda   :=LEFT(oDp:cMoneda   ,3)

  EJECUTAR("DPIVATIP_CREA") // Crea Tipo de IVA Pago Electrónico

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"DPCAJAINST","ICJ_TRAMA",.T.) 
     EJECUTAR("ADDFIELDS_2208",.T.)
  ENDIF

  IF !lAuto
    EJECUTAR("DPSERIEFISCALLOAD") // 20/11/2022
  ENDIF

  EJECUTAR("DPCREATERCEROS")

RETURN .T.
// EOF
	

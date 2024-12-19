// Programa   : ADDFIELDS_2208
// Fecha/Hora : 18/01/2021 11:03:42
// Propósito  : Agregar Campos en Release 22_06
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lDown)
  LOCAL cId   :="ADDFIELD2208_45"
  LOCAL cWhere,cSql,I,cCodigo,cDescri,lRun
  LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
  LOCAL cWhere,oTable,oData
  LOCAL aFields:={}
  LOCAL cCodigo,cDescri,cSql,lRun
  LOCAL cFile  :="ADD\"+cId+"_"+oDp:cDsnData+".ADD"
  LOCAL aFields:={}

  DEFAULT lDown:=.F.

  // Si ya existe y no es descarga, devuelva

/*
  IF ISPCPRG() .AND. .F. 

     FERASE(cFile)

  ELSE
*/

IF !lDown

    IF FILE(cFile) .AND. !lDown
      RETURN .T.
    ENDIF

    oData:=DATASET(cId,"ALL")

    IF oData:Get(cId,"")<>cId 
      oData:End()
    ELSE
      oData:End()
      RETURN
    ENDIF

ENDIF

  MSGRUNVIEW("Actualizando Base de Datos R:22.08")

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

  cCodigo:="DPMOVINVCLIORGDES"
  cDescri:="Movimiento de Productos Clientes, Origen y Destino"

  cSql   :=[SELECT ]+CRLF+;
           [ MOV_CODSUC AS ORG_SUCDES, ]+CRLF+;
           [ MOV_TIPDOC AS ORG_TIPDES, ]+CRLF+;
           [ MOV_DOCUME AS ORG_DOCDES, ]+CRLF+;
           [ MOV_CODIGO AS ORG_CODIGO, ]+CRLF+;
           [ MOV_CODCTA AS ORG_CODCLI, ]+CRLF+;
           [ MOV_ITEM   AS ORG_ITMDES, ]+CRLF+;
           [ MOV_FECHA  AS ORG_FCHDES, ]+CRLF+;
           [ MOV_CANTID AS ORG_CANDES, ]+CRLF+;
           [ MOV_CXUND  AS ORG_CXUDES, ]+CRLF+;
           [ MOV_PESO   AS ORG_PESDES, ]+CRLF+;
           [ MOV_PRECIO AS ORG_PREDES, ]+CRLF+;
           [ MOV_COSTO  AS ORG_COSDES, ]+CRLF+;
           [ MOV_TOTAL  AS ORG_TOTDES, ]+CRLF+;
           [ MOV_MTODIV AS ORG_TOTDIV, ]+CRLF+;
           [ MOV_ASOTIP AS ORG_TIPORG, ]+CRLF+;
           [ MOV_ASODOC AS ORG_DOCORG, ]+CRLF+;
           [ MOV_ITEM_A AS ORG_ITMORG, ]+CRLF+;
           [ DOC_VALCAM AS ORG_VALCAM, ]+CRLF+;
           [ DOC_RECNUM AS ORG_RECNUM, ]+CRLF+;
           [ DOC_GIRNUM AS ORG_CODMOT  ]+CRLF+;
           [ FROM dpmovinv  ]+CRLF+;
           [ INNER JOIN dpdoccli ON MOV_CODSUC=DOC_CODSUC AND MOV_TIPDOC=DOC_TIPDOC AND MOV_DOCUME=DOC_NUMERO AND DOC_TIPTRA="D" AND DOC_ACT=1 ] +CRLF+;
           [ WHERE MOV_APLORG="V" AND MOV_ASOTIP<>"" AND MOV_ASODOC<>"" AND MOV_ITEM_A<>""  ]+CRLF+;
           [ ORDER BY MOV_CODSUC,MOV_TIPDOC,MOV_DOCUME  ]+CRLF+;
           []


  lRun    :=.T.

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)


  cSql:=[ SELECT  ]+;
        [ MDC_CODIGO AS MXD_CODIGO,]+CRLF+;
        [ MDC_TIPDOC AS MXD_TIPDOC,]+CRLF+;
        [ COUNT(*)   AS MXD_CANTID ]+CRLF+;
        [ FROM DPTIPDOCCLIMOT ]+CRLF+;
        [ INNER JOIN DPDOCCLI ON MDC_TIPDOC=DOC_TIPDOC AND MDC_CODIGO=DOC_GIRNUM AND DOC_TIPTRA="D" AND DOC_ACT=1 ]+CRLF+;
        [ GROUP BY MDC_CODIGO,MDC_TIPDOC ]

  lRun    :=.T.

  cCodigo:="DPDOCCLIXMOT"
  cDescri:="Resumen de Documento por Motivo"

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  SQLUPDATE("DPBOTBAR",[BOT_ACCION],[EJECUTAR("ADDON_EVE")],"BOT_CODIGO"+GetWhere("=","336"))

  SQLUPDATE("DPCAJAINST",[ICJ_CODMON],[BSD],"ICJ_CODMON"+GetWhere("=","Bs"))

  cSql:=[ SELECT   ]+CRLF+;                  
        [ DOC_CODSUC AS DOR_CODSUC,]+CRLF+;                    
        [ DOC_TIPDOC AS DOR_TIPORG,]+CRLF+;                    
        [ DOC_NUMERO AS DOR_DOCORG,]+CRLF+;                    
        [ DOC_TIPORG AS DOR_TIPDES,]+CRLF+;                  
        [ DOC_ASODOC AS DOR_DOCDES,]+CRLF+;            
        [ DOC_BASNET AS DOR_BASNET,]+CRLF+;            
        [ DOC_NETO   AS DOR_NETO  ,]+CRLF+;       
        [ DOC_ESTADO AS DOR_ESTADO,]+CRLF+;      
        [ DOC_VALCAM AS DOR_VALCAM,]+CRLF+;    
        [ DOC_FECHA  AS DOR_FECHA  ]+CRLF+;                 
        [ FROM DPDOCCLI ]+CRLF+;                    
        [ WHERE DOC_TIPTRA="D" ]+CRLF+;
        [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_TIPORG,DOC_ASODOC ]

  cCodigo:="DOCCLIDESORG"
  cDescri:="Documento de Clientes Destino Origen"

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  // Antes cSql:=[ SELECT TIP_CODIGO AS TCD_CODIGO,TIP_CTADEB AS TCD_CTADEB,CTA_DESCRI AS TCD_DESCRI FROM dpivatip LEFT JOIN dpcta ON TIP_CTADEB=CTA_CODIGO ORDER BY TIP_CTADEB ]
  SQLDELETE("DPVISTAS",GetWhereOr("VIS_VISTA",{"DPIVATIPCTADEB","DPIVATIPCTACRE"}))

  EJECUTAR("DPIVATIPCTACREA")

  cSql:=[ SELECT ]+;
        [ CIC_CODIGO AS TCD_CODIGO,]+CRLF+;
        [ CIC_CUENTA AS TCD_CTADEB,]+CRLF+;
        [ CTA_DESCRI AS TCD_DESCRI,]+CRLF+;
        [ CIC_CTAMOD AS TCD_CTAMOD ]+;
        [ FROM DPIVATIP_CTA ]+CRLF+;
        [ LEFT JOIN dpcta ON CIC_CTAMOD=CTA_CODMOD AND CIC_CUENTA=CTA_CODIGO ]+CRLF+;
        [ WHERE CIC_CODINT="CTAVTA" ]+CRLF+;
        [ GROUP BY CIC_CODIGO ]+CRLF+;
        [ ORDER BY CIC_CODIGO ]


  cCodigo:="DPIVATIPCTAVTA"
  cDescri:="Cuenta Contable en Columna Venta para Alícuotas de IVA"
  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  cSql:=[ SELECT ]+;
        [ CIC_CODIGO AS TCC_CODIGO,]+;
        [ CIC_CUENTA AS TCC_CTACRE,]+;
        [ CTA_DESCRI AS TCC_DESCRI,]+CRLF+;
        [ CIC_CTAMOD AS TCC_CTAMOD ]+;
        [ FROM DPIVATIP_CTA ]+CRLF+;
        [ LEFT JOIN dpcta ON CIC_CTAMOD=CTA_CODMOD AND CIC_CUENTA=CTA_CODIGO ]+CRLF+;
        [ WHERE CIC_CODINT="CTACOM" ]+CRLF+;
        [ GROUP BY CIC_CODIGO ]+CRLF+;
        [ ORDER BY CIC_CODIGO ]

  cCodigo:="DPIVATIPCTACOM"
  cDescri:="Cuenta Contable en Columna Compra para Alícuotas de IVA"
  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)


  EJECUTAR("DPCAMPOSADD","DPRECIBOSCLI","REC_LETRA" ,"C",2,0,"Letra Correlativo")
  EJECUTAR("DPCAMPOSADD","DPRECIBOSCLI","REC_FCHREG","D",8,0,"Fecha Registro")
  EJECUTAR("DPCAMPOSADD","DPRECIBOSCLI","REC_NUMORG","C",8,0,"Recibo Origen")

  EJECUTAR("DPCAMPOSADD","DPCBTEPAGO"  ,"PAG_LETRA","C",2,0,"Letra Correlativo")
  EJECUTAR("DPCAMPOSADD","DPCBTEPAGO"  ,"PAG_FCHREG","D",2,0,"Fecha Registro")
  EJECUTAR("DPCAMPOSADD","DPCBTEPAGO"  ,"PAG_NUMORG","C",8,0,"Recibo Origen")

  EJECUTAR("DPCAMPOSADD","DPDOCPRORTI" ,"RTI_DOCTIP","C",3,0,"Tipo de documento RTI")

  EJECUTAR("DPCAMPOSADD","DPCAJAINST" ,"ICJ_TRAMA","C",3,0,"Trama Impresora Fiscal THEFACTORY")

  SQLUPDATE("DPDOCCLI","DOC_ESTADO","CA","DOC_ESTADO"+GetWhere("=","PA"))

  EJECUTAR("SETFIELDLONG","DPDOCCLI","DOC_VALCAM" ,19,6) // debe ampliar el ancho a 6 decimales

  EJECUTAR("CXCDIVFIX2") // resuelve CxC en divisas

  EJECUTAR("ADDONADD","EDC","Envio de Datos para Contabilidad")
  EJECUTAR("ADDONADD","DDC","Descargar Datos para Contabilidad")

  EJECUTAR("DPCAJAMOVFIX")

  SQLUPDATE("DPMENU","MNU_TITULO","Calcular IGTF de Caja","MNU_CODIGO"+GetWhere("=","08P10"))
  SQLUPDATE("DPDOCCLI","DOC_DOCORG","R","DOC_TIPDOC"+GetWhere("=","ANT")+" AND DOC_TIPTRA"+GetWhere("=","D"))

  EJECUTAR("DPCAMPOSADD","dpdocmov"  ,"DOC_VALCAM","N",19,6,"Valor;Cambiario")

  EJECUTAR("DPCODINTEGRA_ADD","COMRMU","Retención Municipal Proveedores" )
  EJECUTAR("DPCODINTEGRA_ADD","VTARMU","Retención Municipal Clientes" )

  EJECUTAR("DPCODINTEGRA_ADD","COMANT","Anticipo Proveedores" )
  EJECUTAR("DPCODINTEGRA_ADD","VTAANT","Anticipo Clientes" )

  EJECUTAR("DPCODINTEGRA_ADD","CAJNAC","Caja Moneda Nacional" )
  EJECUTAR("DPCODINTEGRA_ADD","CAJEXT","Caja Moneda Extranjera" )

  EJECUTAR("DPCODINTEGRA_ADD","BCONAC","Banco Moneda Nacional" )
  EJECUTAR("DPCODINTEGRA_ADD","BCOEXT","Banco Moneda Extranjera" )

  SQLUPDATE("DPDOCMOV","DOC_VALCAM",1,"DOC_VALCAM IS NULL OR DOC_VALCAM=0")

  IF !ISFIELD("DPNUMCBTE","DNC_ACTIVO")
    EJECUTAR("DPNUMCBTECREA")
  ENDIF

  EJECUTAR("DPASIENTOSTIPCREA")
  EJECUTAR("DPASIENTOSORGCREA")

  EJECUTAR("DPPRECIOSFIX")

  oData:=DATASET(cId,"ALL")
  oData:Set(cId,cId)
  oData:Save()
  oData:End()

  DPWRITE(cFile,cFile)

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

RETURN .T.
// EOF









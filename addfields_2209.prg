// Programa   : ADDFIELDS_2209
// Fecha/Hora : 18/01/2021 11:03:42
// Propósito  : Agregar Campos en Release 22_06
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lDown,lDelete)
  LOCAL cId   :="ADDFIELD2209_10"
  LOCAL cWhere,cSql,I,cCodigo,cDescri,lRun
  LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
  LOCAL cWhere,oTable,oData
  LOCAL aFields:={}
  LOCAL cCodigo,cDescri,cSql,lRun
  LOCAL cFile  :="ADD\"+cId+"_"+oDp:cDsnData+".ADD"
  LOCAL aFields:={}

  DEFAULT lDown  :=.F.,;
          lDelete:=.F.

  // Si ya existe y no es descarga, devuelva

/*
  IF ISPCPRG() .OR. lDelete

     FERASE(cFile)

  ELSE
*/
    IF FILE(cFile) .AND. lDown
      RETURN .T.
    ENDIF

    oData:=DATASET(cId,"ALL")

    IF oData:Get(cId,"")<>cId 
      oData:End()
    ELSE
      oData:End()
      RETURN
    ENDIF

//  ENDIF

  MSGRUNVIEW("Actualizando Base de Datos R:22.09")

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

  EJECUTAR("DPTIPDOCPROCREA","PPF","Plantilla para Planificación Financiera","N")

  SQLUPDATE("DPTIPDOCPRO",{"TDC_LITEM","TDC_DOCEDI","TDC_LEN","TDC_ZERO","TDC_CONTAB"},{.T.,.T.,8,.T.,.F.},"TDC_TIPO"+GetWhere("=","PPF"))

  EJECUTAR("SETFIELDLONG","DPTIPDOCPRO" ,"TDC_DESCRI" ,40)
  EJECUTAR("SETFIELDLONG","DPPROVEEDORPROGCTA" ,"PPC_VALCAM",19,6)
  EJECUTAR("SETFIELDLONG","DPPROVEEDORPROG"    ,"PGC_VALCAM",19,6)

  EJECUTAR("DPCAMPOSADD","DPPROVEEDORPROG"  ,"PGC_TIPORG","C",03,0,"Tipo;Doc/Org")
  EJECUTAR("DPCAMPOSADD","DPPROVEEDORPROG"  ,"PGC_DOCORG","C",20,0,"Número;Doc/Org")
  EJECUTAR("DPCAMPOSADD","DPSERIEFISCAL"    ,"SFI_MODFIS","C",20,0,"Modelo;Impresora;Fiscal")
  EJECUTAR("DPCAMPOSADD","DPSERIEFISCAL"    ,"SFI_MODVAL","L",01,0,"Modelo;Validación")
  EJECUTAR("DPCAMPOSADD","DPSERIEFISCAL"    ,"SFI_REGAUD","L",01,0,"Registro de Auditoria")

  SQLUPDATE("DPTIPDOCPRO",{"TDC_LITEM","TDC_DOCEDI","TDC_LEN","TDC_ZERO","TDC_CONTAB"},{.T.,.T.,8,.T.,.F.},"TDC_TIPO"+GetWhere("=","PPF"))

  // libro de Compras (Contabilidad de Transcripción o Compras Ocasionales
  EJECUTAR("DPLIBCOMPRACREA")
 

  // Contrapartida=Cuentas x Pagar,Caja,Caja Divisa,Banco,Banco Divisa,Cuenta Contable
  // DOC_DESCCO

  EJECUTAR("DPCAMPOSADD","DPRIF","RIF_PORRTI","N",6,0,"%Ret;IVA")
  EJECUTAR("DPCAMPOSADD","DPDOCPROPROG","PLP_FCHDEC"  ,"D",008,0,"Fecha Declaración")

  EJECUTAR("ADDONADD","CDC","Contabilidad de Transcripción")

  EJECUTAR("DPLIBCOMSETFECHA")
  SQLUPDATE("DPCAJAINST","ICJ_TRAMA","","ICJ_TRAMAI IS NULL")

  // documentos que seran revalorizados
  SQLUPDATE("DPTIPDOCCLI","TDC_REVALO",.T.,GetWhereOr("TDC_TIPO",{"FAV","DEB","CRE","ANT","NEN"}))
  SQLUPDATE("DPMOVINV","MOV_LISTA",oDp:cPrecio,"MOV_APLORG"+GetWhere("=","V")+" AND MOV_LISTA"+GetWhere("=",""))

  EJECUTAR("DPIVATIPCTACREA")


   cSql:=[ SELECT ]+CRLF+;
         [ CIN_CODIGO, ]+CRLF+;
         [ CIC_CUENTA AS CIN_CODCTA,]+CRLF+;
         [ CIN_ABREVI, ]+CRLF+;
         [ CIN_ASIABR , ]+CRLF+;
         [ CIC_CTAMOD AS CIN_CTAMOD]+CRLF+;
         [ FROM dpcodintegra ]+CRLF+;
         [ LEFT JOIN DPCODINTEGRA_CTA         ON CIN_CODIGO=CIC_CODIGO ]+CRLF+;
         [ ORDER BY CIC_CODIGO,CIN_CTAMOD ]

  cCodigo:="DPCODINTEGRA"
  cDescri:="Código de Integración Contable"

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)
  

  cCodigo:="ASIENTOSXCODINT"
  cDescri:="Asientos por Código de Integración"
  cSql   :=[ SELECT AST_CODINT AS AIN_CODINT,]+CRLF+;
           [ COUNT(*)   AS AIN_CANTID,]+CRLF+;
           [ SUM(IF(MOC_CUENTA]+GetWhere("=",oDp:cCtaIndef)+[,1,0)) AS AIN_CANIND ]+;
           [ FROM DPASIENTOS ]+CRLF+;
           [ INNER JOIN DPASIENTOSTIP    ON MOC_ORIGEN=AST_APLORG AND MOC_TIPO=AST_TIPDOC AND MOC_TIPTRA=AST_TIPTRA AND MOC_TIPASI=AST_TIPO ]+CRLF+;
           [ GROUP BY AST_CODINT ]

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  EJECUTAR("DPCODINTEGRAFIX")

  oData:=DATASET(cId,"ALL")
  oData:Set(cId,cId)
  oData:Save()
  oData:End()

  DPWRITE(cFile,cFile)

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

RETURN .T.
// EOF










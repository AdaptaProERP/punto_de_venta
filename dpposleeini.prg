// Programa   : DPPOSLEEINI
// Fecha/Hora : 06/10/2005 05:48:54
// Prop�sito  : Lectura del Archivo INI
// Creado Por : Juan Navas
// Llamado por: DPPOS01
// Aplicaci�n : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cFileIni,nRows,nCols)
  LOCAL aLine:={},aBtn,cCod:="",I,X,U,oIni,nPage:=1,aGrupo:={},aPagina:={}
  LOCAL cText:="",cFile:="",cBmp01:="",cBmp02:="",cBmp03:="",cWhen:="",cAction:=""
  LOCAL oData,cError,nKey,cMsg

  DEFAULT nCols:=5,nRows:=4

// ? oDp:cIpLocal
//? cFileIni

  aBtn:=ARRAY(nCols)

  IF !File(cFileIni)
     MensajeErr(cFileIni+" no Existe")
     RETURN {}
  ENDIF

/*
  oData   :=DATASET("PRIV_VTIK","USER",,,oDp:cUsuario)

//cCodCaja:=oData:Get("TIKCODCAJA",oDp:cCodCaja)
//cCodCaja:=oData:Get("cCajaPos",oDp:cCodCaja)
*/


  oData:=DATACONFIG("POS","PC",,,,,,oDp:cPclocal) // IpLocal)
  cCodCaja:=oData:Get("cCajaPos",oDp:cCodCaja)

  oData:End(.F.)
  oData:=DATASET("FONDO","USER")

  nCajaFondo:=oData:Get("nCajaFondo"     ,0.00)     // Fondo de Caja
  lCierre   :=oData:Get("lCierre"        ,.F. )     // No ha Cerrado
  lAbierto  :=oData:Get("lAbierto"       ,.F. )     // Caja no Abierta
  lFecha    :=oData:Get("dFechaCierre"   ,CTOD("")) // Cirre de Caja
  cHoraIni  :=oData:Get("cHoraIni"       ,""      ) // Hora de Inicio

  oData:End(.F.)

  oIni:=Tini():New(cFileIni)

  nPage      := oIni:Get("MAIN","PAGE"      ,0," ")
  nPageIni   := oIni:Get("MAIN","PAGEINI"   ,0," ")     // Pagina Inicial

// JN 05/08/2022
//  cTipDoc    := oIni:Get("MAIN","TIPDOC"    ,"","TIK")  // Tipo de Documento
//  cTipDev    := oIni:Get("MAIN","TIPDEV"    ,"","DEV")  // Devoluci�n de Venta

  cTipDoc    := oDp:cTipDocVta // 05/08/2022
  cTipDev    := oDp:cTipDocDev // 05/08/2022

  lMesas     := oIni:Get("MAIN","MESAS"     ,.F.," ")   // Restaurant    
  lVendedor  := oIni:Get("MAIN","VENDEDOR"  ,.F.," ")   // Usa Vendedores

  cPrecio    := oIni:Get("MAIN","PRECIO"    ,"A","A")   // Precio de Venta
  cCodVen    := oIni:Get("MAIN","CODVEN"    ,"","")     // Vendedor       
  cCodCli    := oIni:Get("MAIN","CODCLI"    ,"","")     // Cliente        
  cCodMon    := oIni:Get("MAIN","CODMON"    ,"BsD",oDp:cMoneda) // Moneda         
  cCenCos    := oIni:Get("MAIN","CENCOS"    ,"","")     // Centro de Costos
  cCodTra    := oIni:Get("MAIN","CODTRA"    ,"","")     // Transacci�n    
  cCodAlm    := oIni:Get("MAIN","CODALM"    ,"","")     // Almacen

  FOR X:=1 TO nPage
 
    aGrupo:={}

    FOR I:=1 TO nRows

     aBtn:=ARRAY(nCols)

     FOR U:=1 TO nCols

       cBmp01:=""
       cBmp02:=""
       cBmp03:=""
       cWhen :=""

       cCod   := "BTN"+STR(X,1)+STR(I,1)+STR(U,1)

       cText  := oIni:get(cCod,"TEXT"   , "" , " ")
       cBmp01 := oIni:get(cCod,"BMP01"  , "" , " ")
       cBmp02 := oIni:get(cCod,"BMP02"  , "" , " ")
       cBmp03 := oIni:get(cCod,"BMP03"  , "" , " ")
       cWhen  := oIni:get(cCod,"WHEN"   , "" , " ")
       cAction:= oIni:get(cCod,"ACTION" , "" , " ")
       nKey   := oIni:Get(cCod,"KEY"    , 0  , 0  )
       cMsg   := oIni:Get(cCod,"MSG"    , "" , "" )
       nKey   :=CTOO(nKey,"N")

       cWhen  :=IIF( Empty(cWhen  ) , ".T." , cWhen  )
       cAction:=IIF( Empty(cAction) , ".T." , cAction)

       cWhen  :=BloqueCod(cWhen  )
       cAction:=BloqueCod(cAction)

       IF !EMPTY(cText) 

          cBmp02 :=IIF(Empty(cBmp02 ),cBmp01      ,cBmp02)
          cBmp03 :=IIF(Empty(cBmp03 ),"btnoff.bmp",cBmp03)

          aBtn[U]:={ cText , {cBmp01,cBmp02,cBmp03}  , cWhen , cAction,nKey,cMsg,cCod }

     //     ?  cCod,cText , cBmp01,cBmp02,cBmp03  , cWhen , cAction


       ELSE

          aBtn[U]:={ "Nada"          , {"XEDIT.BMP","XEDIT.BMP","btnoff.bmp"}  , cWhen , cAction ,nKey, cMsg,cCod }

       ENDIF

     NEXT U

     AADD(aGrupo,aBtn)

    NEXT

    AADD(aPagina,aGrupo)

  NEXT 

  IF !Empty(oDp:cImpFiscal)
    lImpFis:=.T.
  ENDIF

  IF UPPE(oDp:cImpFiscal)="BEMATECH"

     IF EMPTY(HRBLOAD("BEMATECH.HRB"))
       lImpFis:=.F.
    ENDIF

    cError:=BEMA_INI()

    IF !Empty(cError)
       MensajeErr(cError)
       lImpFis:=.F.
       RETURN {} //  JN 24/12/2016 (Deb devolver Arreglo} lImpFis               // 13-07-2010 Marlon Ramos
    ELSE
       lImpFis:=.T.
    ENDIF

 ENDIF

 // Par�metros del Documento
 EJECUTAR("DPPRIVVTALEE",cTipDoc,.F.) // Lee los Privilegios del Usuario

//if !MYSQLGET("DPCAJA","CAJ_CODIGO","CAJ_CODIGO"+GetWhere("=",cCodCaja))==cCodCaja 
 if !ISSQLFIND("DPCAJA","CAJ_CODIGO"+GetWhere("=",cCodCaja))

     MensajeErr("C�digo de Caja ["+cCodCaja+"] no Existe, Ser� Asumido el C�digo de Caja: "+oDp:cCaja+CRLF+;
                "Para definir caja del Usuario, Utilice la Opci�n: Privilegios del Usuario" )
     
     cCodCaja:=oDp:cCaja

 ENDIF

RETURN aPagina
// EOF

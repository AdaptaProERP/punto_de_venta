// Programa   : BRTICKETPOS
// Fecha/Hora : 08/07/2022 01:01:23
// Propósito  : "Detalles de Tickes del Punto de Venta"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,lZeta,cLetra)
   LOCAL aData,aFechas,cFileMem:="USER\BRTICKETPOS.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL oDb:=OpenOdbc(oDp:cDsnData)

   oDp:cRunServer:=NIL

   IF Type("oTICKETPOS")="O" .AND. oTICKETPOS:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oTICKETPOS,GetScript())
   ENDIF

   IF !EJECUTAR("ISFIELDMYSQL",oDb,"VIEW_DPCAJAMOVORG","CAJ_MTODIV")
      EJECUTAR("ADDFIELDS_2307",NIL,.T.)
   ENDIF


   IF oDp:lImpFisModVal=NIL
      EJECUTAR("DPSERIEFISCALLOAD",NIL,.F.)
   ENDIF

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   DEFAULT cTitle:="Detalles de Tickes y Transacciones del Punto de Venta" 


// +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD(""),;
           lZeta   :=.F.


   // Obtiene el Código del Parámetro

   // Resumen DIARIO de VENTA/DEVOLUCION  excluye

   
   DEFAULT cWhere:=""

   IF !Empty(cLetra)
      cWhere:=cWhere+IF(Empty(cWhere),""," AND")+" DOC_SERFIS"+GetWhere("=",cLetra)
   ENDIF

   cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+" NOT "+GetWhereOr("DOC_TIPDOC",{"RDV","RDD","ZFF","ZDF"})

   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oTICKETPOS

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL aDataSub:=ADEPURA(aData,{|a,n| [Sub]$a[1]})
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aDataSub)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oTICKETPOS","BRTICKETPOS.EDT")
// oTICKETPOS:CreateWindow(0,0,100,550)
   oTICKETPOS:Windows(0,0,aCoors[3]-160,MIN(526,aCoors[4]-10),.T.) // Maximizado

   oTICKETPOS:cCodSuc  :=cCodSuc
   oTICKETPOS:lMsgBar  :=.F.
   oTICKETPOS:cPeriodo :=aPeriodos[nPeriodo]
// oTICKETPOS:cCodSuc  :=cCodSuc
   oTICKETPOS:nPeriodo :=nPeriodo
   oTICKETPOS:cNombre  :=""
   oTICKETPOS:dDesde   :=dDesde
   oTICKETPOS:cServer  :=cServer
   oTICKETPOS:dHasta   :=dHasta
   oTICKETPOS:cWhere   :=cWhere
   oTICKETPOS:cWhere_  :=cWhere_
   oTICKETPOS:cWhereQry:=""
   oTICKETPOS:cSql     :=oDp:cSql
   oTICKETPOS:oWhere   :=TWHERE():New(oTICKETPOS)
   oTICKETPOS:cCodPar  :=cCodPar // Código del Parámetro
   oTICKETPOS:lWhen    :=.T.
   oTICKETPOS:cTextTit :="" // Texto del Titulo Heredado
   oTICKETPOS:oDb      :=oDp:oDb
   oTICKETPOS:cBrwCod  :="TICKETPOS"
   oTICKETPOS:lTmdi    :=.T.
   oTICKETPOS:aHead    :={}
   oTICKETPOS:lBarDef  :=.T. // Activar Modo Diseño.
   oTICKETPOS:lZeta    :=lZeta
   oTICKETPOS:cLetra   :=cLetra
   

   // Guarda los parámetros del Browse cuando cierra la ventana
   oTICKETPOS:bValid   :={|| EJECUTAR("BRWSAVEPAR",oTICKETPOS)}

   oTICKETPOS:lBtnRun     :=.F.
   oTICKETPOS:lBtnMenuBrw :=.F.
   oTICKETPOS:lBtnSave    :=.F.
   oTICKETPOS:lBtnCrystal :=.F.
   oTICKETPOS:lBtnRefresh :=.T.
   oTICKETPOS:lBtnHtml    :=.T.
   oTICKETPOS:lBtnExcel   :=.T.
   oTICKETPOS:lBtnPreview :=.T.
   oTICKETPOS:lBtnQuery   :=.F.
   oTICKETPOS:lBtnOptions :=.T.
   oTICKETPOS:lBtnPageDown:=.T.
   oTICKETPOS:lBtnPageUp  :=.T.
   oTICKETPOS:lBtnFilters :=.T.
   oTICKETPOS:lBtnFind    :=.T.

   oTICKETPOS:nClrPane1:=16775408
   oTICKETPOS:nClrPane2:=16771797

   oTICKETPOS:nClrText :=12870144
   oTICKETPOS:nClrText1:=255
   oTICKETPOS:nClrText2:=0
   oTICKETPOS:nClrText3:=0

   oTICKETPOS:oBrw:=TXBrowse():New( IF(oTICKETPOS:lTmdi,oTICKETPOS:oWnd,oTICKETPOS:oDlg ))
   oTICKETPOS:oBrw:SetArray( aData, .F. )
   oTICKETPOS:oBrw:SetFont(oFont)

   oTICKETPOS:oBrw:nColSubTotal:=1
   oTICKETPOS:oBrw:lFooter     := .T.
   oTICKETPOS:oBrw:lHScroll    := .T.
   oTICKETPOS:oBrw:nHeaderLines:= 2
   oTICKETPOS:oBrw:nDataLines  := 1
   oTICKETPOS:oBrw:nFooterLines:= 1

   oTICKETPOS:aData            :=ACLONE(aData)

   AEVAL(oTICKETPOS:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   
 // Campo: DOC_TIPDOC
  oCol:=oTICKETPOS:oBrw:aCols[1]
  oCol:cHeader      :='Tipo'+CRLF+"Doc."
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  // Campo: DOC_NUMERO
  oCol:=oTICKETPOS:oBrw:aCols[2]
  oCol:cHeader      :='Número'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: DOC_CODIGO
  oCol:=oTICKETPOS:oBrw:aCols[3]
  oCol:cHeader      :='RIF'+CRLF+"Código"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 90

  // Campo: CLI_NOMBRE
  oCol:=oTICKETPOS:oBrw:aCols[4]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 220

  // Campo: DOC_NETO
  oCol:=oTICKETPOS:oBrw:aCols[5]
  oCol:cHeader      :="Monto"+CRLF+'Neto '+oDp:cMoneda
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,5],;
                              oCol   := oTICKETPOS:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[5],oCol:cEditPicture)

  oCol:nEditType  :=1
  oCol:bOnPostEdit:={|oCol,uValue|oTICKETPOS:PUTMONTO(oCol,uValue,5)}


  // Campo: DOC_NETO
  oCol:=oTICKETPOS:oBrw:aCols[6]
  oCol:cHeader      :="Monto"+CRLF+'IVA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,6],;
                              oCol   := oTICKETPOS:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)


// Campo: DOC_MTODIV
  oCol:=oTICKETPOS:oBrw:aCols[7]
  oCol:cHeader      :="Neto"+CRLF+'Divisa '+oDp:cMonedaExt
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,7],;
                              oCol   := oTICKETPOS:oBrw:aCols[7],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)

 oCol:=oTICKETPOS:oBrw:aCols[8]
  oCol:cHeader      :="Monto"+CRLF+'Caja '+oDp:cMoneda
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,8],;
                              oCol   := oTICKETPOS:oBrw:aCols[8],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[8],oCol:cEditPicture)



  oCol:=oTICKETPOS:oBrw:aCols[9]
  oCol:cHeader      :="Divisa"+CRLF+'Caja '+oDp:cMonedaExt
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,9],;
                              oCol   := oTICKETPOS:oBrw:aCols[9],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[9],oCol:cEditPicture)

  oCol:=oTICKETPOS:oBrw:aCols[10]
  oCol:cHeader      :="Monto"+CRLF+'IGTF '+oDp:cMoneda
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,10],;
                              oCol   := oTICKETPOS:oBrw:aCols[10],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[10],oCol:cEditPicture)



  // Campo: DOC_FECHA
  oCol:=oTICKETPOS:oBrw:aCols[8+3]
  oCol:cHeader      :='Fecha'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: DOC_HORA
  oCol:=oTICKETPOS:oBrw:aCols[9+3]
  oCol:cHeader      :='Hora'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 64



  // Campo: DOC_IMPRES
  oCol:=oTICKETPOS:oBrw:aCols[10+3]
  oCol:cHeader      :='Impreso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 64
  // Campo: DOC_IMPRES
  oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
  oCol:bBmpData    := { |oBrw|oBrw:=oTICKETPOS:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,10+3],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
  oCol:bStrData    :={||""}

IF .T.
  // Campo: DOC_SERFIS
  oCol:=oTICKETPOS:oBrw:aCols[10+1+3]
  oCol:cHeader      :='Serie'+CRLF+"Fiscal"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 24


 // Campo: DOC_USUARI
  oCol:=oTICKETPOS:oBrw:aCols[11+1+3]
  oCol:cHeader      :='Usuario'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 24

 // Campo: DOC_USUARI
  oCol:=oTICKETPOS:oBrw:aCols[12+1+3]
  oCol:cHeader      :='Débito'+CRLF+"Crédito"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 30

 // Campo: DOC_NUMPER
  oCol:=oTICKETPOS:oBrw:aCols[13+1+3]
  oCol:cHeader      :='Activo/'+CRLF+"Anulado"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 64
  // Campo: DOC_IMPRES
  oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
  oCol:bBmpData    := { |oBrw|oBrw:=oTICKETPOS:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,13+1+3],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
  oCol:bStrData    :={||""}

  oCol:=oTICKETPOS:oBrw:aCols[14+1+3]
  oCol:cHeader      :='Estado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 30

  oCol:=oTICKETPOS:oBrw:aCols[15+1+3]
  oCol:cHeader      :='Reg'+CRLF+"Aud"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 30

  // Campo: DOC_NUMERO
  oCol:=oTICKETPOS:oBrw:aCols[16+1+3]
  oCol:cHeader      :='Documento'+CRLF+"Asociado"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oTICKETPOS:oBrw:aCols[18+3]
  oCol:cHeader      :="#"+CRLF+'Semana'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 60
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,18+3],;
                              oCol   := oTICKETPOS:oBrw:aCols[18+3],;
                              FDP(nMonto,oCol:cEditPicture)}

  // Campo: DOC_NUMERO
  oCol:=oTICKETPOS:oBrw:aCols[19+3]
  oCol:cHeader      :='Número'+CRLF+"Recibo"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: DOC_CODSUC
  oCol:=oTICKETPOS:oBrw:aCols[19+4]
  oCol:cHeader      :='Cód.'+CRLF+"Suc."
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

// Campo: DOC_CODSUC
  oCol:=oTICKETPOS:oBrw:aCols[19+5]
  oCol:cHeader      :='Zeta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 60

// Campo: DOC_CODSUC
  oCol:=oTICKETPOS:oBrw:aCols[19+6]
  oCol:cHeader      :='Desc.'+CRLF+"Absoluto"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 90

  oCol:=oTICKETPOS:oBrw:aCols[19+7]
  oCol:cHeader      :='Desc.'+"%"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oTICKETPOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 60
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,19+7],;
                              oCol   := oTICKETPOS:oBrw:aCols[19+7],;
                              FDP(nMonto,oCol:cEditPicture)}







//oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)


  oTICKETPOS:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

//  nClrText:=IF(aLine[12]<0,oTICKETPOS:nClrText1,nClrText),;


  oTICKETPOS:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oTICKETPOS:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                    nClrText:=oTICKETPOS:nClrText,;
                                                    nClrText:=IF(aLine[5]<0    ,oTICKETPOS:nClrText1,nClrText),;
                                                    nClrText:=IF("Sub"$aLine[1],oTICKETPOS:nClrText3,nClrText),;
                                                    {nClrText,iif( oBrw:nArrayAt%2=0, oTICKETPOS:nClrPane1, oTICKETPOS:nClrPane2 ) } }

ENDIF

   oTICKETPOS:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oTICKETPOS:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oTICKETPOS:oBrw:bLDblClick:={|oBrw|oTICKETPOS:RUNCLICK() }

   oTICKETPOS:oBrw:bChange:={||oTICKETPOS:BRWCHANGE()}
   oTICKETPOS:oBrw:CreateFromCode()

   AEVAL(oTICKETPOS:oBrw:aCols,{|oCol,n| oCol:nColArray:=n})

   oTICKETPOS:oWnd:oClient := oTICKETPOS:oBrw

   oTICKETPOS:Activate({||oTICKETPOS:ViewDatBar()})

   oTICKETPOS:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oTICKETPOS:lTmdi,oTICKETPOS:oWnd,oTICKETPOS:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oTICKETPOS:oBrw:nWidth()

   oTICKETPOS:oBrw:GoBottom(.T.)
   oTICKETPOS:oBrw:Refresh(.T.)

// IF !File("FORMS\BRTICKETPOS.EDT")
//     oTICKETPOS:oBrw:Move(44,0,526+50,460)
// ENDIF

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth+5,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -09 BOLD


 // Emanager no Incluye consulta de Vinculos


   IF oTICKETPOS:lZeta

   oTICKETPOS:oFontBtn   :=oFont    
   oTICKETPOS:nClrPaneBar:=oDp:nGris
   oTICKETPOS:oBrw:oLbx  :=oTICKETPOS

   DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\ZETA.BMP";
             TOP PROMPT "Zeta"; 
             ACTION  EJECUTAR("DLL_IMPFISCAL_CMD","","REPORTE X")

      oBtn:cToolTip:="Reporte Zeta "

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\AUDITORIA.BMP";
          TOP PROMPT "Auditoría"; 
          ACTION oTICKETPOS:VERAUDITA()

   oBtn:cToolTip:="Ver Traza de la Incidencia "


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.BMP";
          TOP PROMPT "Origen"; 
          ACTION  oTICKETPOS:VERDOCCLI()

   oBtn:cToolTip:="Formulario"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\devventa.BMP";
          TOP PROMPT "Dev/Vta"; 
          ACTION oTICKETPOS:DEVOLUCION()

   oBtn:cToolTip:="Devolución de Venta"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\MATH.BMP";
          TOP PROMPT "Sub-Total"; 
          ACTION EJECUTAR("BRSUBTOTAL",oTICKETPOS:oBrw)

   oBtn:cToolTip:="Incluir Sub-Total"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          TOP PROMPT "Consulta"; 
          ACTION  oTICKETPOS:MENUPOS(.F.)

   oBtn:cToolTip:="Opciones de Consulta"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\MENU.BMP";
          TOP PROMPT "Menú"; 
          ACTION oTICKETPOS:MENUPOS(.T.)

   oBtn:cToolTip:="Menú de Opciones "





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XDELETE.BMP";
          TOP PROMPT "Eliminar"; 
          ACTION  oTICKETPOS:DELTICKET(.T.)

   oBtn:cToolTip:="Anular Factura o Ticket "


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RECIBODIVISA.BMP";
          TOP PROMPT "Recibo"; 
          ACTION  oTICKETPOS:VERRECIBO()

   oBtn:cToolTip:="Ver Recibo de Ingreso"


/*
   IF Empty(oTICKETPOS:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","TICKETPOS")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","TICKETPOS"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
         TOP PROMPT "Detalles"; 
              ACTION  EJECUTAR("BRWRUNBRWLINK",oTICKETPOS:oBrw,"TICKETPOS",oTICKETPOS:cSql,oTICKETPOS:nPeriodo,oTICKETPOS:dDesde,oTICKETPOS:dHasta,oTICKETPOS)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oTICKETPOS:oBtnRun:=oBtn



       oTICKETPOS:oBrw:bLDblClick:={||EVAL(oTICKETPOS:oBtnRun:bAction) }


   ENDIF




IF oTICKETPOS:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oTICKETPOS");
            FILENAME "BITMAPS\RUN.BMP";
              TOP PROMPT "Ejecutar"; 
              ACTION  oTICKETPOS:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

/*
IF oTICKETPOS:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
               TOP PROMPT "Grabar"; 
              ACTION  EJECUTAR("DPBRWSAVE",oTICKETPOS:oBrw,oTICKETPOS:oFrm)
ENDIF
*/

IF oTICKETPOS:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
            TOP PROMPT "Menú"; 
              ACTION  (EJECUTAR("BRWBUILDHEAD",oTICKETPOS),;
                  EJECUTAR("DPBRWMENURUN",oTICKETPOS,oTICKETPOS:oBrw,oTICKETPOS:cBrwCod,oTICKETPOS:cTitle,oTICKETPOS:aHead));
          WHEN !Empty(oTICKETPOS:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oTICKETPOS:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
            TOP PROMPT "Buscar"; 
              ACTION  EJECUTAR("BRWSETFIND",oTICKETPOS:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oTICKETPOS:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oTICKETPOS:oBrw,oTICKETPOS);
            TOP PROMPT "Filtrar"; 
              ACTION  EJECUTAR("BRWSETFILTER",oTICKETPOS:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oTICKETPOS:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oTICKETPOS:oBrw);
          WHEN LEN(oTICKETPOS:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oTICKETPOS:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar"; 
          ACTION  oTICKETPOS:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oTICKETPOS:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal"; 
          ACTION  EJECUTAR("BRWTODBF",oTICKETPOS)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oTICKETPOS:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
            ACTION  (EJECUTAR("BRWTOEXCEL",oTICKETPOS:oBrw,oTICKETPOS:cTitle,oTICKETPOS:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oTICKETPOS:oBtnXls:=oBtn

ENDIF

IF oTICKETPOS:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html"; 
          ACTION  (oTICKETPOS:HTMLHEAD(),EJECUTAR("BRWTOHTML",oTICKETPOS:oBrw,NIL,oTICKETPOS:cTitle,oTICKETPOS:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oTICKETPOS:oBtnHtml:=oBtn

ENDIF


IF oTICKETPOS:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oTICKETPOS:oBrw))

   oBtn:cToolTip:="Previsualización"

   oTICKETPOS:oBtnPreview:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir"; 
              ACTION  oTICKETPOS:IMPRIMIR()

   oBtn:cToolTip:="Imprimir ticket no Impreso"
   oTICKETPOS:oBtnPrint:=oBtn


IF oTICKETPOS:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oTICKETPOS:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oTICKETPOS:oBrw:GoTop(),oTICKETPOS:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oTICKETPOS:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
            ACTION  (oTICKETPOS:oBrw:PageDown(),oTICKETPOS:oBrw:Setfocus())

  ENDIF

  IF  oTICKETPOS:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior"; 
           ACTION  (oTICKETPOS:oBrw:PageUp(),oTICKETPOS:oBrw:Setfocus())

  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oTICKETPOS:oBrw:GoBottom(),oTICKETPOS:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oTICKETPOS:Close()

  oTICKETPOS:oBrw:SetColor(0,oTICKETPOS:nClrPane1)

  oTICKETPOS:SETBTNBAR(40+10,40+10,oBar)

  EVAL(oTICKETPOS:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oTICKETPOS:oBar:=oBar

  oBar:SetSize(NIL,90,.T.)

  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  nCol:=32
  nLin:=45+15

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oTICKETPOS:oPeriodo  VAR oTICKETPOS:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oTICKETPOS:LEEFECHAS();
                WHEN oTICKETPOS:lWhen


  ComboIni(oTICKETPOS:oPeriodo )

  @ nLin, nCol+103 BUTTON oTICKETPOS:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oTICKETPOS:oPeriodo:nAt,oTICKETPOS:oDesde,oTICKETPOS:oHasta,-1),;
                         EVAL(oTICKETPOS:oBtn:bAction));
                WHEN oTICKETPOS:lWhen


  @ nLin, nCol+130 BUTTON oTICKETPOS:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oTICKETPOS:oPeriodo:nAt,oTICKETPOS:oDesde,oTICKETPOS:oHasta,+1),;
                         EVAL(oTICKETPOS:oBtn:bAction));
                WHEN oTICKETPOS:lWhen


  @ nLin, nCol+160 BMPGET oTICKETPOS:oDesde  VAR oTICKETPOS:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oTICKETPOS:oDesde ,oTICKETPOS:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oTICKETPOS:oPeriodo:nAt=LEN(oTICKETPOS:oPeriodo:aItems) .AND. oTICKETPOS:lWhen ;
                FONT oFont

   oTICKETPOS:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oTICKETPOS:oHasta  VAR oTICKETPOS:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oTICKETPOS:oHasta,oTICKETPOS:dHasta);
                SIZE 76-2,24;
                WHEN oTICKETPOS:oPeriodo:nAt=LEN(oTICKETPOS:oPeriodo:aItems) .AND. oTICKETPOS:lWhen ;
                OF oBar;
                FONT oFont

   oTICKETPOS:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oTICKETPOS:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oTICKETPOS:oPeriodo:nAt=LEN(oTICKETPOS:oPeriodo:aItems);
               ACTION oTICKETPOS:HACERWHERE(oTICKETPOS:dDesde,oTICKETPOS:dHasta,oTICKETPOS:cWhere,.T.);
               WHEN oTICKETPOS:lWhen

  BMPGETBTN(oBar,oFont,13)

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

  IF !Empty(oTICKETPOS:cLetra)

      DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

     @ nLin, nCol+392 SAY " Serie " OF oBar PIXEL SIZE 40,20 BORDER FONT oFont;
                                    COLOR oDp:nClrLabelText,oDp:nClrLabelPane RIGHT

     @ nLin, nCol+432 SAY " "+oTICKETPOS:cLetra+" "+SQLGET("DPSERIEFISCAL","SFI_MODELO","SFI_LETRA"+GetWhere("=",oTICKETPOS:cLetra));
                      OF oBar PIXEL SIZE 140,20 BORDER FONT oFont;
                      COLOR oDp:nClrYellowText,oDp:nClrYellow


  ENDIF


RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  LOCAL aLine:=oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt]
  LOCAL cTipDoc:=aLine[1]
  LOCAL cNumero:=aLine[2]
  LOCAL lImpres:=aLine[13],cWhere
  LOCAL cCodSuc:=aLine[19+4]

  IF oTICKETPOS:oBrw:SelectedCol():nColArray=13 .AND. ISTABMOD("DPDOCCLI")

     cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc  )+" AND "+;
             "DOC_TIPDOC"+GetWhere("=",aLine[1] )+" AND "+;
             "DOC_NUMERO"+GetWhere("=",aLine[2] )+" AND "+;
             "DOC_TIPTRA"+GetWhere("=","D"      )

     SQLUPDATE("DPDOCCLI","DOC_IMPRES",!lImpres,cWhere)

     oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,13]:=!lImpres
     oTICKETPOS:oBrw:DrawLine(.T.)

  ENDIF

RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
   LOCAL aLine:=oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt]
   LOCAL cCodSuc:=oTICKETPOS:cCodSuc,cTipDoc:=aLine[1],cNumero:=aLine[2],cSerFis:=aLine[10]

   IF Empty(cTipDoc)
      RETURN .F.
   ENDIF

   aLine[13]:=CTOO(aLine[13],"L")

   IF aLine[13] 

      IF !MsgNoYes("Documento "+cTipDoc+"-"+cNumero+CRLF+"Documento ya está Impreso","Desea Re-Imprimirlo")
         RETURN .F.
      ENDIF

   ELSE

     IF !MsgNoYes("Desea Imprimir Documento "+cTipDoc+" "+cNumero)
        RETURN .F.
     ENDIF

   ENDIF

// ? oDp:lImpFisModVal,"oDp:lImpFisModVal"

   CursorWait()

   EJECUTAR("DPDOCCLI_PRINT",cCodSuc,cTipDoc,cNumero,cSerFis)

   // MODO VALIDACION, DISPONIBLE PARA IMPRIMIR
   IF oDp:lImpFisModVal

     SQLUPDATE("DPDOCCLI","DOC_IMPRES",.F.,"DOC_CODSUC"+GetWhere("=",cCodSuc )+" AND "+;
                                           "DOC_TIPDOC"+GetWhere("=",cTipDoc )+" AND "+;
                                           "DOC_NUMERO"+GetWhere("=",cNumero )+" AND "+;
                                           "DOC_TIPTRA"+GetWhere("=","D"     ))
   ENDIF

   oTICKETPOS:BRWREFRESCAR()

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oTICKETPOS:oPeriodo:nAt,cWhere

  oTICKETPOS:nPeriodo:=nPeriodo


  IF oTICKETPOS:oPeriodo:nAt=LEN(oTICKETPOS:oPeriodo:aItems)

     oTICKETPOS:oDesde:ForWhen(.T.)
     oTICKETPOS:oHasta:ForWhen(.T.)
     oTICKETPOS:oBtn  :ForWhen(.T.)

     DPFOCUS(oTICKETPOS:oDesde)

  ELSE

     oTICKETPOS:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oTICKETPOS:oDesde:VarPut(oTICKETPOS:aFechas[1] , .T. )
     oTICKETPOS:oHasta:VarPut(oTICKETPOS:aFechas[2] , .T. )

     oTICKETPOS:dDesde:=oTICKETPOS:aFechas[1]
     oTICKETPOS:dHasta:=oTICKETPOS:aFechas[2]

     cWhere:=oTICKETPOS:HACERWHERE(oTICKETPOS:dDesde,oTICKETPOS:dHasta,oTICKETPOS:cWhere,.T.)

     oTICKETPOS:LEERDATA(cWhere,oTICKETPOS:oBrw,oTICKETPOS:cServer,oTICKETPOS)

  ENDIF

  oTICKETPOS:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPDOCCLI.DOC_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDOCCLI.DOC_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDOCCLI.DOC_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oTICKETPOS:cWhereQry)
       cWhere:=cWhere + oTICKETPOS:cWhereQry
     ENDIF

     oTICKETPOS:LEERDATA(cWhere,oTICKETPOS:oBrw,oTICKETPOS:cServer,oTICKETPOS)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL nAt,nRowSel

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT "+;
         " DOC_TIPDOC,"+;
         " DOC_NUMERO,"+;
         " IF(CCG_TIPDOC IS NULL,DOC_CODIGO,CCG_RIF   ) AS CLI_CODIGO,"+;
         " IF(CCG_TIPDOC IS NULL,CLI_NOMBRE,CCG_NOMBRE) AS CLI_NOMBRE,"+;
         [ DOC_NETO  *IF(DOC_TIPDOC="DEV" OR DOC_TIPDOC="CRE",-1,1),]+;
         [ DOC_MTOIVA*IF(DOC_TIPDOC="DEV" OR DOC_TIPDOC="CRE",-1,1),]+;
         [ DOC_MTODIV*IF(DOC_TIPDOC="DEV" OR DOC_TIPDOC="CRE",-1,1),]+;
         [ CAJ_MONTO ,]+;
         [ CAJ_MTODIV,]+;
         [ CAJ_MTOITF,]+;
         [ DOC_FECHA ,]+;
         [ DOC_HORA  ,]+;
         [ DOC_IMPRES,]+;
         [ DOC_SERFIS,]+;
         [ DOC_USUARI,]+;
         [ CASE  WHEN TDC_CXC="D"  THEN "Débito"  ]+;
         [       WHEN TDC_CXC="C"  THEN "Crédito" ]+;
         [       WHEN TDC_CXC="N"  THEN "Neutro"  ]+;
         [  ELSE SPACE(10)  ]+;
         [  END AS DOC_CXC,]+;
         [ DOC_ACT,]+;
         [ DOC_ESTADO,AUD_TIPO,DOC_FACAFE,DIA_SEMANA,DOC_RECNUM,DOC_CODSUC,DOC_GIRNUM,DOC_DESCCO,DOC_DCTO ]+;
         [ FROM DPDOCCLI ]+;
         [ LEFT JOIN DPTIPDOCCLI       ON DOC_TIPDOC=TDC_TIPO AND TDC_ESTVTA=1 ]+;
         [ LEFT JOIN DPSERIEFISCAL     ON DOC_SERFIS=SFI_LETRA  AND LEFT(SFI_IMPFIS,1)]+GetWhere("<>","N")+;
         [ LEFT JOIN DPCLIENTESCERO    ON CCG_CODSUC=DOC_CODSUC AND CCG_TIPDOC=DOC_TIPDOC AND CCG_NUMDOC=DOC_NUMERO ]+;
         [ LEFT JOIN DPCLIENTES        ON DOC_CODIGO=CLI_CODIGO ]+;
         [ LEFT JOIN dpauditor         ON CONCAT(DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO)=AUD_CLAVE ]+;
         [ LEFT JOIN DPDIARIO          ON DOC_FECHA=DIA_FECHA ]+;
         [ LEFT JOIN VIEW_DPCAJAMOVORG ON DOC_CODSUC=CAJ_CODSUC AND DOC_NUMERO=CAJ_DOCASO AND DOC_TIPDOC=CAJ_ORIGEN]+;                  
         [ WHERE DOC_TIPTRA]+GetWhere("=","D")+;
         [ GROUP BY DOC_TIPDOC,DOC_NUMERO ]+;
         [ ORDER BY CONCAT(DOC_FECHA,DOC_NUMERO) ]


//       " WHERE DOC_DOCORG"+GetWhere("=","P")+;


/*
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF
*/
   IF !Empty(cWhere)
     cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRTICKETPOS.SQL",cSql)

   aData:=ASQL(cSql,oDb)

//? CLPCOPY(oDp:cSql)

   oDp:cWhere:=cWhere

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'',0,CTOD(""),'',0,'',0,''})
   ENDIF

   AEVAL(aData,{|a,n| aData[n,13+1+3]:=(a[13+1+3]=1),;
                      aData[n,14+1+3] :=SAYOPTIONS("DPDOCCLI","DOC_ESTADO",a[14+1+3])})


   aData:=EJECUTAR("BRSUBTOTAL",aData,1)
   
   IF ValType(oBrw)="O"

      oTICKETPOS:cSql   :=cSql
      oTICKETPOS:cWhere_:=cWhere
      oBrw:nColSubTotal :=1

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)

      AEVAL(oTICKETPOS:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oTICKETPOS:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRTICKETPOS.MEM",V_nPeriodo:=oTICKETPOS:nPeriodo
  LOCAL V_dDesde:=oTICKETPOS:dDesde
  LOCAL V_dHasta:=oTICKETPOS:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oTICKETPOS)
RETURN .T.

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oTICKETPOS")="O" .AND. oTICKETPOS:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oTICKETPOS:cWhere_),oTICKETPOS:cWhere_,oTICKETPOS:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oTICKETPOS:LEERDATA(oTICKETPOS:cWhere_,oTICKETPOS:oBrw,oTICKETPOS:cServer)
      oTICKETPOS:oWnd:Show()
      oTICKETPOS:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oTICKETPOS:aHead:=EJECUTAR("HTMLHEAD",oTICKETPOS)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oTICKETPOS)
RETURN .T.

FUNCTION MENUPOS(lMenu)
  LOCAL aLine:=oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt]
  LOCAL cCodSuc:=oDp:cSucursal,cNumero:=aLine[2],cCodigo:=NIL,cNomDoc:=NIL,cTipDoc:=aLine[1],oForm:=NIL,cAction:=NIL

  cCodigo:=SQLGET("DPDOCCLI","DOC_CODIGO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                          "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                          "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                          "DOC_TIPTRA"+GetWhere("=","D"    ))
  IF lMenu
    EJECUTAR("DPDOCCLIMNU",cCodSuc,cNumero,cCodigo,cNomDoc,cTipDoc,oForm,cAction,"P")
  ELSE
    EJECUTAR("DPDOCCLIFAVCON",NIL,cCodSuc,cTipDoc,cNumero,cCodigo,NIL,"P")
  ENDIF

RETURN .T.

/*
// Anular Factura 
// Si está impresa, realizará la Anulación de la Factura
*/
FUNCTION DELTICKET()
   LOCAL aLine  :=oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt]
   LOCAL cCodSuc:=oTICKETPOS:cCodSuc,cTipDoc:=aLine[1],cNumero:=aLine[2],cSerFis:=aLine[10+1]
   LOCAL lResp  :=.T.
   LOCAL cWhere

   IF Empty(cTipDoc)
      RETURN .F.
   ENDIF

   IF !aLine[13+1]
      MsgMemo("Documento "+cTipDoc+"-"+cNumero,"Documento no Está Activo")
    //  RETURN .F.
   ENDIF

   IF aLine[9+1] .OR. .T.

      IF !MsgNoYes("Desea Anular Documento Impreso")
        RETURN .F.
      ENDIF

      MsgRun("Anulando Documento "+cTipDoc+"-"+cNumero)
      lResp:=EJECUTAR("DPDOCCLI_ANULAR",cCodSuc,cTipDoc,cNumero,cSerFis)

   ELSE

      IF !MsgNoYes("Desea Anular Documento no Impreso")
        RETURN .F.
      ENDIF

   ENDIF

   IF lResp

     cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
             "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
             "DOC_TIPTRA"+GetWhere("=","D"    )

     SQLUPDATE("DPDOCCLI",{"DOC_ACT","DOC_ESTADO"},{0,"NU"},cWhere)

   ENDIF

   oTICKETPOS:BRWREFRESCAR()

RETURN .T.

FUNCTION VERAUDITA()
  LOCAL aLine  :=oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt]
  LOCAL cCodSuc:=oTICKETPOS:cCodSuc,cTipDoc:=aLine[1],cNumero:=aLine[2],cSerFis:=aLine[10+1]
  LOCAL lResp  :=.T.
  LOCAL cWhere,cMemo
  LOCAL cFile:="TEMP\FILE"+cCodSuc+cTipDoc+cNumero+".TXT"
 
  cMemo:=SQLGET("DPAUDITOR","AUD_	MEMO","AUD_CLAVE"+GetWhere("=",cCodSuc+cTipDoc+cNumero))

  DPWRITE(cFile,cMemo)

  VIEWRTF(cFile,"Documento "+cTipDoc+cNumero)

RETURN .T.

FUNCTION VERDOCCLI()
  LOCAL aLine  :=oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt]
  LOCAL cTipDoc:=aLine[1],cCodigo:=aLine[3],cNumero:=aLine[2],cTipTra:="D"
  LOCAL cCodSuc:=aLine[19+4]


RETURN EJECUTAR("VERDOCCLI",cCodSuc,cTipDoc,cCodigo,cNumero,cTipTra)

/*
// Devolución de Venta
*/
FUNCTION DEVOLUCION()
  LOCAL aLine  :=oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt]
  LOCAL cTipDoc:=aLine[1],cCodigo:=aLine[3],cNumFav:=aLine[2],cTipTra:="D"
  LOCAL cTipDev:=""
  LOCAL cNumero,cDescri,cTitle:=NIL,cWhere:=NIL,aNumDoc
  LOCAL lReset:=NIL,dFecha:=oDp:dFecha,cCodSuc:=oTICKETPOS:cCodSuc,cNumExp

  IF cTipDoc="TIK" 
     cTipDev:="DEV"
  ENDIF

  IF cTipDoc="FAV" .OR. cTipDoc="FAM"
     cTipDev:="CRE"
  ENDIF

  IF cTipDoc="NEN"
     cTipDev:="DNE"
  ENDIF

  IF cTipDoc="CON"
     cTipDev:="DCO"
  ENDIF

  IF Empty(cTipDev)
     MsgMemo("Tipo de documento "+cTipDoc+" No Aplica Devolución")
     RETURN .F.
  ENDIF

  cNumExp:=SQLGET("DPMOVINV","MOV_DOCUME,MOV_TIPDOC,MOV_CODCTA","MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                                "MOV_ASOTIP"+GetWhere("=",cTipDoc)+" AND "+;
                                                                "MOV_ASODOC"+GetWhere("=",cNumFav))
  IF !Empty(cNumExp)
     MsgMemo("Documento "+cTipDoc+" "+cNumFav+" ya fué Exportada hacia "+CRLF+cTipDev+" "+cNumExp)
     EJECUTAR("VERDOCCLI",oTICKETPOS:cCodSuc,cTipDev,cCodigo,cNumExp,NIL)
     RETURN .T.
  ENDIF

  cDescri:=ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDev)))
  cNumero:=EJECUTAR("DPDOCCLIGETNUM",cTipDev)

  IF !MsgNoYes("Desea realizar "+cDescri+" "+cTipDev+"-"+cNumero+" Completa de la Factura")

     cWhere:="DOC_CODSUC"+GetWhere("=",oTICKETPOS:cCodSuc)+" AND "+;
             "DOC_TIPDOC"+GetWhere("=",cTipDoc           )+" AND "+;
             "DOC_NUMERO"+GetWhere("=",cNumFav           )

     EJECUTAR("BRFAVTOCREDET",cWhere,oTICKETPOS:cCodSuc,oTICKETPOS:nPeriodo,oTICKETPOS:dDesde,oTICKETPOS:dHasta,cTitle,cCodigo) // ,NILt,cTipDoc)

     RETURN .F.
  ENDIF

  aNumDoc:={cNumFav}

  cNumero:=EJECUTAR("DPDOCCLIGENDOC",oTICKETPOS:cCodSuc,cTipDoc,aNumDoc,cTipDev,lReset,dFecha,.F.,NIL,.T.)

  IF !Empty(cNumero)
     EJECUTAR("VERDOCCLI",oTICKETPOS:cCodSuc,cTipDev,cCodigo,cNumero,NIL)
  ENDIF

RETURN .T.

FUNCTION PUTMONTO(oCol,uValue,nCol)

  oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt,nCol]:=uValue

  EJECUTAR("CALSUBTOTAL",oTICKETPOS:oBrw,1)


RETURN .T.

/*
// Ver Recibo de Ingreso
*/
FUNCTION VERRECIBO()
 LOCAL aLine  :=oTICKETPOS:oBrw:aArrayData[oTICKETPOS:oBrw:nArrayAt]
 LOCAL cCodSuc:=aLine[21]
 LOCAL cRecibo:=aLine[22]
 LOCAL cTipDoc:=aLine[01]

 IF cTipDoc="TIK" .OR. cTipDoc="DEV"
    cRecibo:=aLine[02]
 ENDIF

RETURN EJECUTAR("VERRECIBOSCLI",cCodSuc,cRecibo,cTipDoc)
// EOF


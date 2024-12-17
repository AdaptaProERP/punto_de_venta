// Programa   : DPPOSBANCARIOCTA  
// Fecha/Hora : 09/09/2006 08:53:55
// Propósito  : Asociar Puntos de Venta con Cuentas Bancarias
// Creado Por : Juan Navas
// Llamado por: DPCTABANCO.LBX
// Aplicación : Tesorería
// Tabla      : DPPOSBANCARIOCTA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodBco,cCuenta)
   LOCAL cSql,aData:={},aPos:={}
   LOCAL I,nMonto:=0,cTitle:="",nAt
   LOCAL oTable,oFont,oFontB,oBrw,oCol

   DEFAULT cCodBco:=STRZERO(1,6),;
           cCuenta:="102030"

   cSql:=" SELECT PVB_CODIGO,PVB_DESCRI,PVB_SERIAL,0 AS OK "+;
         " FROM DPPOSBANCARIO "+;
         " ORDER BY PVB_CODIGO "

   aData:=ASQL(cSql)

   //clpcopy(oDp:cSql)

   IF Empty(aData)
     RETURN {}
   ENDIF

   aPos:=ASQL("SELECT PXC_CODPOS FROM DPPOSBANCARIOCTA "+;
              " WHERE PXC_CODBCO"+GetWhere("=",cCodBco)+;
              "   AND PXC_CUENTA"+GetWhere("=",cCuenta))

   aPos:=AEVAL(aPos,{|a,n|aPos[n]:=a[1]})

   Aeval(aData,{|a,n|aData[n,4]:=.F.})

   FOR I=1 TO LEN(aPos)

     nAt:=ASCAN( aData , {|a,n|aPos[I]=a[1] })

     IF nAt>0
        aData[nAt,4]:=.T.
     ENDIF

   NEXT I

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   cTitle:=ALLTRIM(GetFromVar("{oDp:DPPOSBANCARIOCTA}"))
//+" / "+cNombre

   oPvbxCta:=DPEDIT():New(cTitle,"DPPOSBANCARIOCTA.EDT","oPvbxCta",.T.)

   oPvbxCta:cNombre :=MYSQLGET("DPBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=", cCodBco))
  
   oPvbxCta:oBrw:=TXBrowse():New( oPvbxCta:oDlg )
   oPvbxCta:oBrw:SetArray( aData, .F. )
   oPvbxCta:oBrw:SetFont(oFont)
   oPvbxCta:oBrw:lFooter     := .T.
   oPvbxCta:oBrw:lHScroll    := .F.
   oPvbxCta:oBrw:nHeaderLines:= 1
   oPvbxCta:oBrw:lFooter     :=.F.
   oPvbxCta:oBrw:nFreeze     :=4

   oPvbxCta:cCodBco  :=cCodBco
   oPvbxCta:cCuenta  :=cCuenta
   
   oPvbxCta:aData    :=ACLONE(aData)

   AEVAL(oPvbxCta:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oPvbxCta:oBrw:aCols[1]   
   oCol:cHeader      :="Cód"
   oCol:nWidth       :=055

   oCol:=oPvbxCta:oBrw:aCols[2]
   oCol:cHeader      :=GetFromVar("Nombre")
   oCol:nWidth       :=210

   oCol:=oPvbxCta:oBrw:aCols[3]
   oCol:cHeader      :=GetFromVar("Serial")
   oCol:nWidth       :=210

   oCol:=oPvbxCta:oBrw:aCols[4]
   oCol:cHeader      := "Ok"
   oCol:nWidth       := 25
   oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
   oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
   oCol:bBmpData    := { ||oBrw:=oPvbxCta:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,4],1,2) }
   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
   oCol:bLDClickData:={||oPvbxCta:DocSelect(oPvbxCta)}

   oPvbxCta:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oPvbxCta:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16773862, 16771538 ) } }

   oPvbxCta:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oPvbxCta:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  
   FOR I=1 TO LEN(oPvbxCta:oBrw:aCols)
       oPvbxCta:oBrw:aCols[I]:bLClickFooter:=oCol:bLClickFooter
   NEXT I

   oPvbxCta:oBrw:CreateFromCode()

   oPvbxCta:Activate({||oPvbxCta:ViewDatBar(oPvbxCta)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oPvbxCta)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oPvbxCta:oDlg

   oPvbxCta:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oPvbxCta:oRep:=REPORTE("DPBCODIRCO"),;
                  oPvbxCta:oRep:SetCriterio(1,oPvbxCta:cNombre))

   oBtn:cToolTip:="Imprimir"
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oPvbxCta:oBrw,oPvbxCta:cTitle,oPvbxCta:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oPvbxCta:oBrw:GoTop(),oPvbxCta:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oPvbxCta:oBrw:PageDown(),oPvbxCta:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oPvbxCta:oBrw:PageUp(),oPvbxCta:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oPvbxCta:oBrw:GoBottom(),oPvbxCta:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oPvbxCta:Close()

  oPvbxCta:oBrw:SetColor(0,16773862)

  @ 0.1,40 SAY "Código: "+oPvbxCta:cCodBco+ " Cuenta:"+oPvbxCta:cCuenta OF oBar BORDER SIZE 345,18
  @ 1.4,40 SAY "Nombre: "+oPvbxCta:cNombre OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

FUNCTION SAVECOMISION(uValue,nCol)
/*
    LOCAL oTable,cSql,cWhere:=""

    oPvbxCta:oBrw:aArrayData[oPvbxCta:oBrw:nArrayAt,nCol]:=uValue

    cSql:=" SELECT * FROM DPBANCODIRPOR "+;
          " WHERE CXI_BANCO "+GetWhere("=",oPvbxCta:cNombre)+;
          "   AND CXI_CODINS"+GetWhere("=",oPvbxCta:oBrw:aArrayData[oPvbxCta:oBrw:nArrayAt,1])

    oTable:=OpenTable(cSql,.T.)

    IF oTable:RecNo()=0
      oTable:Append()
    ELSE
      cWhere:=oTable:cWhere
    ENDIF

    oTable:Replace("CXI_BANCO" ,oPvbxCta:cNombre)
    oTable:Replace("CXI_CODINS",oPvbxCta:oBrw:aArrayData[oPvbxCta:oBrw:nArrayAt,1])

    IF nCol=3
      oTable:Replace("CXI_PORIMP",oPvbxCta:oBrw:aArrayData[oPvbxCta:oBrw:nArrayAt,nCol])
    ELSE
      oTable:Replace("CXI_PORCOM",oPvbxCta:oBrw:aArrayData[oPvbxCta:oBrw:nArrayAt,nCol])
    ENDIF

    oTable:Commit(cWhere)
    oTable:End()
    
    IF nCol=3
       oPvbxCta:oBrw:GoRight()
    ELSE
       oPvbxCta:oBrw:KeyDown(VK_DOWN)
       oPvbxCta:oBrw:GoLeft()
    ENDIF
*/
RETURN .T.


/*
// Seleccionar POS
*/
FUNCTION DocSelect()
  LOCAL oTable,cWhere
  LOCAL oBrw:=oPvbxCta:oBrw
  LOCAL cPos:=oBrw:aArrayData[oBrw:nArrayAt,1]
  LOCAL nArrayAt,nRowSel,nAt:=0,nCuantos:=0
  LOCAL lSelect
  LOCAL nCol:=4
  LOCAL lSelect

  IF ValType(oBrw)!="O"
     RETURN .F.
  ENDIF

  nArrayAt:=oBrw:nArrayAt
  nRowSel :=oBrw:nRowSel
  lSelect :=oBrw:aArrayData[nArrayAt,nCol]

  oBrw:aArrayData[oBrw:nArrayAt,nCol]:=!lSelect
  oBrw:RefreshCurrent()

  IF lSelect

    SQLDELETE("DPPOSBANCARIOCTA ",;
              " WHERE PXC_CODBCO"+GetWhere("=",oPvbxCta:cCodBco)+;
              "   AND PXC_CUENTA"+GetWhere("=",oPvbxCta:cCuenta)+;
              "   AND PXC_CODPOS"+GetWhere("=",cPos))


     RETURN .T.
  ENDIF
  
  oTable:=OpenTable("SELECT * FROM DPPOSBANCARIOCTA "+;
                    " WHERE PXC_CODBCO"+GetWhere("=",oPvbxCta:cCodBco)+;
                    "   AND PXC_CUENTA"+GetWhere("=",oPvbxCta:cCuenta)+;
                    "   AND PXC_CODPOS"+GetWhere("=",cPos),.T.)


  cWhere:=oTable:cWhere

  IF oTable:RecCount()=0
     cWhere:=""
     oTable:AppendBlank()
  ENDIF

  oTable:Replace("PXC_CODBCO",oPvbxCta:cCodBco)
  oTable:Replace("PXC_CUENTA",oPvbxCta:cCuenta)
  oTable:Replace("PXC_CODPOS",cPos)
  oTable:Commit(cWhere)


  oTable:End()

RETURN .T.

// EOF

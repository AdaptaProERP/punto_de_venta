// Programa   : DPPOSBANCARIOCTA  
// Fecha/Hora : 09/09/2006 08:53:55
// Propósito  : Asociar Puntos de Venta con Cuentas Bancarias
// Creado Por : Juan Navas
// Llamado por: DPCTABANCO.LBX
// Aplicación : Tesorería
// Tabla      : DPPOSBANCARIOCTA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodBco,cCuenta)
   LOCAL cSql,aData:={},cNombre:="Nombre del Banco"
   LOCAL I,nMonto:=0,cTitle:=""
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

   Aeval(aData,{|a,n|aData[n,4]:=.F.})

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   cTitle:=ALLTRIM(GetFromVar("{oDp:DPPOSBANCARIOCTA}"))+" / "+cNombre

   oComBan:=DPEDIT():New(cTitle,"DPPOSBANCARIOCTA.EDT","oComBan",.T.)

   oComBan:cNombre :=cNombre

   oComBan:oBrw:=TXBrowse():New( oComBan:oDlg )
   oComBan:oBrw:SetArray( aData, .F. )
   oComBan:oBrw:SetFont(oFont)
   oComBan:oBrw:lFooter     := .T.
   oComBan:oBrw:lHScroll    := .F.
   oComBan:oBrw:nHeaderLines:= 1
   oComBan:oBrw:lFooter     :=.F.
   oComBan:oBrw:nFreeze     :=4

   oComBan:cCodCli  :=cCodCli
   oComBan:cNombre  :=cNombre
   oComBan:aData    :=ACLONE(aData)

   AEVAL(oComBan:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oComBan:oBrw:aCols[1]   
   oCol:cHeader      :="Cód"
   oCol:nWidth       :=055

   oCol:=oComBan:oBrw:aCols[2]
   oCol:cHeader      :=GetFromVar("{oDp:xDPCAJAINST}")
   oCol:nWidth       :=210


  oCol:=oBrw:aCols[4]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||oBrw:=oFrmCxC:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,4],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oFrmCxC:DocSelect(oFrmCxC)}
  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oFrmCxC:ChangeAllDoc(oFrmCxC,nRow,nCol,nKey,oCol,.T.)}



/*
   oCol:=oComBan:oBrw:aCols[3]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="% ISLR"
   oCol:nWidth       :=75
   oCol:bStrData     :={|nMonto|nMonto:=oComBan:oBrw:aArrayData[oComBan:oBrw:nArrayAt,3],;
                                TRAN(nMonto,"999.99")}
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue|oComBan:SAVECOMISION(uValue,3)}


   oCol:=oComBan:oBrw:aCols[4]   
   oCol:cHeader      :="% Comisión"
   oCol:nWidth       :=75
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oComBan:oBrw:aArrayData[oComBan:oBrw:nArrayAt,4],;
                                TRAN(nMonto,"999.99")}
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue|oComBan:SAVECOMISION(uValue,4)}

*/

   oComBan:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oComBan:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16773862, 16771538 ) } }

   oComBan:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oComBan:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  
   FOR I=1 TO LEN(oComBan:oBrw:aCols)
       oComBan:oBrw:aCols[I]:bLClickFooter:=oCol:bLClickFooter
   NEXT I

   oComBan:oBrw:CreateFromCode()

   oComBan:Activate({||oComBan:ViewDatBar(oComBan)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oComBan)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oComBan:oDlg

   oComBan:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oComBan:oRep:=REPORTE("DPBCODIRCO"),;
                  oComBan:oRep:SetCriterio(1,oComBan:cNombre))

   oBtn:cToolTip:="Imprimir"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oComBan:oBrw,oComBan:cTitle,oComBan:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oComBan:oBrw:GoTop(),oComBan:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oComBan:oBrw:PageDown(),oComBan:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oComBan:oBrw:PageUp(),oComBan:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oComBan:oBrw:GoBottom(),oComBan:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oComBan:Close()

  oComBan:oBrw:SetColor(0,16773862)

// @ 0.1,55 SAY "Código: "+oComBan:cCodCli OF oBar BORDER SIZE 345,18
// @ 1.4,55 SAY "Nombre: "+oComBan:cNombre OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

FUNCTION SAVECOMISION(uValue,nCol)
/*
    LOCAL oTable,cSql,cWhere:=""

    oComBan:oBrw:aArrayData[oComBan:oBrw:nArrayAt,nCol]:=uValue

    cSql:=" SELECT * FROM DPBANCODIRPOR "+;
          " WHERE CXI_BANCO "+GetWhere("=",oComBan:cNombre)+;
          "   AND CXI_CODINS"+GetWhere("=",oComBan:oBrw:aArrayData[oComBan:oBrw:nArrayAt,1])

    oTable:=OpenTable(cSql,.T.)

    IF oTable:RecNo()=0
      oTable:Append()
    ELSE
      cWhere:=oTable:cWhere
    ENDIF

    oTable:Replace("CXI_BANCO" ,oComBan:cNombre)
    oTable:Replace("CXI_CODINS",oComBan:oBrw:aArrayData[oComBan:oBrw:nArrayAt,1])

    IF nCol=3
      oTable:Replace("CXI_PORIMP",oComBan:oBrw:aArrayData[oComBan:oBrw:nArrayAt,nCol])
    ELSE
      oTable:Replace("CXI_PORCOM",oComBan:oBrw:aArrayData[oComBan:oBrw:nArrayAt,nCol])
    ENDIF

    oTable:Commit(cWhere)
    oTable:End()
    
    IF nCol=3
       oComBan:oBrw:GoRight()
    ELSE
       oComBan:oBrw:KeyDown(VK_DOWN)
       oComBan:oBrw:GoLeft()
    ENDIF
*/
RETURN .T.

// EOF
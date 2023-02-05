// Programa   : DPPOSCMDENVIA
// Fecha/Hora : 26/10/2006 15:49:58
// Propósito  : Enviar Pedidos para Transporte
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  LOCAL oDlgM, aPedidos:={},cSql,aDataM,aZonas:={},I,cZona:="",oZona,aTotal:={}
  LOCAL oBrwM,oFontBrw,oFontB,oDlg,oCol,oBtn,oVuelto,cVuelto:="Cambio"
  LOCAL nTop:=85,nLeft:=0,nWidth:=795,nHeight:=460,nZona:=6,nMuni:=10,nAT
  LOCAL nClrPane1:=14671839 , nClrPane2:=16777215
  LOCAL aCodTran:={},aTransp:={},cTransp,oTransp
  LOCAL aPlacas :={},aModelo:={},cPlaca ,oPlaca,aTotal:={},aMuni:={}
  LOCAL cConductor,aConductor,aCI:={},oConductor,nTotal:=0,nVuelto:=0
  LOCAL cNumGtr:="",cMuni:=""

  nClrPane1:=11595007
  nClrPane2:=14613246

  cSql:=" SELECT CDT_NOMBRE,CDT_CI_RIF FROM DPCONDUCTORES WHERE "+;
        " CDT_ACTIVO=1 AND  "+;
        " (CDT_V_LIC"+GetWhere(">=",oDp:dFecha)+" OR CDT_V_LIC"+GetWhere("=",CTOD(""))+")"+;
        " AND "+;
        " (CDT_V_MED"+GetWhere(">=",oDp:dFecha)+" OR CDT_V_MED"+GetWhere("=",CTOD(""))+")"

  aConductor:=ASQL( cSql , .T.)

  AEVAL(aConductor,{|a,n|aConductor[n]:=a[1],AADD(aCI,a[2])})

  IF Empty(aConductor) 

     MensajeErr("No hay "+ALLTRIM(GetFromVar("{oDp:DPCONDUCTORES}"))+" Registrados, Revise:"+CRLF+;
                "Las fecha de Vencimiento en los datos del "+ALLTRIM(GetFromVar("{oDp:xDPCONDUCTORES}"))+".")

     RETURN .F.

  ENDIF


  // Transporte
  cSql:=" SELECT TRA_CODIGO,TRA_DESCRI FROM DPTRANSP "+;
        " INNER JOIN DPVEHICULOS ON VEH_CODTRA=TRA_CODIGO "+;
        " WHERE TRA_ACTIVO=1 AND "+;
        " (VEH_V_SEG"+GetWhere(">=",oDp:dFecha)+" OR VEH_V_SEG"+GetWhere("=",CTOD(""))+")"+;
        " AND "+;
        " (VEH_V_PER"+GetWhere(">=",oDp:dFecha)+" OR VEH_V_PER"+GetWhere("=",CTOD(""))+")"+;
        " GROUP BY TRA_CODIGO,TRA_DESCRI "+;
        " ORDER BY TRA_CODIGO"

  aTransp:=ASQL(cSql)

  IF Empty(aTransp)

     MensajeErr("No hay "+ALLTRIM(GetFromVar("{oDp:DPTRANSP}"))+" Disponibles, Revise:"+CRLF+;
                "Fecha de "+ALLTRIM(GetFromVar("{oDp:DPVEHICULOS}"))+CRLF+;
                ALLTRIM(GetFromVar("{oDp:DPTRANSP}"))+" que estén Activos")

     RETURN .F.

  ENDIF

  AEVAL(aTransp,{|a,n|aTransp[n]:=a[2],AADD(aCodTran,a[1])})

  cTransp:=aTransp[1]

  cPlaca :=GETTRANSP(aCodTran[1])

  // Vehiculos

  cSql:=" SELECT DOC_FACAFE,DOC_NUMERO,CCG_NOMBRE,DOC_NETO,DOC_MTOCOM,CCG_DIR4,DOC_HORA,0 AS TIEMPO,0 AS L, CCG_DIR5 FROM DPDOCCLI "+;
        " INNER JOIN DPCLIENTESCERO ON DOC_CODSUC=CCG_CODSUC AND DOC_TIPDOC=CCG_TIPDOC AND DOC_NUMERO=CCG_NUMDOC "+;
        " WHERE DOC_TIPDOC='TIK' AND DOC_DOCORG='P' AND CCG_DIR4<>'Barra' AND DOC_NUMGTR='' AND DOC_FACAFE<>'' "


  cSql:=" SELECT DOC_FACAFE,DOC_NUMERO,CCG_NOMBRE,DOC_NETO,DOC_MTOCOM,CCG_DIR5,DOC_HORA,0 AS TIEMPO,0 AS L, CCG_DIR4 FROM DPDOCCLI "+;
        " INNER JOIN DPCLIENTESCERO ON DOC_CODSUC=CCG_CODSUC AND DOC_TIPDOC=CCG_TIPDOC AND DOC_NUMERO=CCG_NUMDOC "+;
        " WHERE DOC_TIPDOC='TIK' AND DOC_DOCORG='P' AND CCG_DIR4<>'Barra' AND DOC_NUMGTR='' AND DOC_FACAFE<>'' "


  aPedidos:=ASQL(cSql)

  IF Empty(aPedidos)
     MensajeErr("No hay Pedidos para el Despacho")
     RETURN .T.
  ENDIF

  AADD(aZonas,"-Todos") 
  AADD(aMuni ,"-Todos") 

  FOR I=1 TO LEN(aPedidos)

    IF ASCAN(aMuni,aPedidos[I,10])=0
       AADD(aMuni,aPedidos[I,10])
    ENDIF

  NEXT I

  cMuni :=aMuni[1]

  FOR I=1 TO LEN(aPedidos)

     aPedidos[I,8]:=ELAPTIME(aPedidos[I,7],TIME())
     aPedidos[I,9]:=.F.

     IF aPedidos[I,10]==cMuni .AND. ASCAN(aZonas,aPedidos[I,nZona])=0
        AADD(aZonas,aPedidos[I,nZona])
     ENDIF

  NEXT I

  WHILE nAt:=ASCAN(aConductor,{|a,n|Empty(a) }), nAt>0
     aConductor:=ARREDUCE(aConductor,nAt)
  ENDDO

 //aTotal:=ATOTALES(aPedidos)
  cZona :=aZonas[1]

  DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0, -14 BOLD
  DEFINE FONT oFontB   NAME "MS Sans Serif" SIZE 0, -10 BOLD

  aDataM:=GETXZONA(cMuni,cZona) // Obtiene por Zona

  aTotal:=ATOTALES(aDataM)

  DEFINE DIALOG oDlgM TITLE " Despacho de Pedidos ";
         COLOR NIL,oDp:nGris

  @ .5,.5 COMBOBOX cMuni ITEMS aMuni;
         ON CHANGE (BUILDPARRO(),;
            GETXZONA(cMuni,cZona,oBrwM));
         FONT oFontB;
         SIZE 110,NIL

  SAYTEXTO(oDp:xDPMUNICIPIOS,oFontB,oDlg)

  @ 1.8,.5 COMBOBOX oZona VAR cZona ITEMS aZonas;
         ON CHANGE GETXZONA(cMuni,cZona,oBrwM);
         FONT oFontB;
         SIZE 110,NIL

  SAYTEXTO(oDp:xDPPARROQUIAS,oFontB,oDlg)

  @ .8,15 COMBOBOX oTransp VAR cTransp ITEMS aTransp;
          ON CHANGE GETTRANSP( aCodTran[oTransp:nAt] , oPlaca );
          FONT oFontB;
          SIZE 100,NIL;
          WHEN LEN(aTransp)>1

  SAYTEXTO(GetFromVar("{oDp:xDPTRANSP}"),oFontB,oDlg)

  @ .8,28 COMBOBOX oPlaca VAR cPlaca ITEMS aPlacas;
          FONT oFontB;
          SIZE 40,NIL;
          WHEN LEN(aPlacas)>1

  SAYTEXTO(GetFromVar("{oDp:xDPVEHICULOS}"),oFontB,oDlg)

  @ .8,34 COMBOBOX oConductor VAR cConductor ITEMS aConductor;
          FONT oFontB;
          SIZE 80,NIL;
          WHEN LEN(aConductor)>1

  SAYTEXTO(GetFromVar("{oDp:xDPCONDUCTORES}"),oFontB,oDlg)

  @ 1.7,20 SAY oVuelto PROMPT cVuelto COLOR CLR_HBLUE,oDp:nGris;
           FONT oFontB SIZE 230,09


  SayAction(oVuelto,{||VIEWDESGLOSE()})

  oDlgM:lHelpIcon:=.F.

  oBrwM:=TXBrowse():New(oDlg )
  oBrwM:SetArray( aDataM ,.F.)
  oBrwM:lHScroll  := .F.
  oBrwM:lVScroll  := .T.
  oBrwM:nFreeze   := 1
  oBrwM:oFont     := oFontBrw
  oBrwM:nDataLines:= 1
  oBrwM:lFooter   := .T.
  oBrwM:lHeader   := .T.

  oCol:=oBrwM:aCols[1]
  oCol:cHeader       :="Ped."
  oCol:bStrData      :={||RIGHT(aDataM[oBrwM:nArrayAt,1],4)}
  oCol:nWidth        :=40
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrwM:aArrayData ) }

  oCol:=oBrwM:aCols[2]
  oCol:cHeader       :="Ticket"
  oCol:nWidth        :=070
  oCol:bStrData      :={||RIGHT(aDataM[oBrwM:nArrayAt,2],7)}
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrwM:aArrayData ) }

  oCol:=oBrwM:aCols[3]
  oCol:cHeader       :="Cliente"
  oCol:nWidth        :=220
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrwM:aArrayData ) }

  oCol:=oBrwM:aCols[4]
  oCol:cHeader       :="Monto"
  oCol:nWidth        :=100
  oCol:bStrData      :={||TRAN(aDataM[oBrwM:nArrayAt,4],"9,999,999.99")}
  oCol:nDataStrAlign := AL_RIGHT
  oCol:nHeadStrAlign := AL_RIGHT
  oCol:nFootStrAlign := AL_RIGHT
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrwM:aArrayData ) }
  oCol:cFooter       :=TRAN( aTotal[4] ,"9,999,999,999.99")

  oCol:=oBrwM:aCols[5]
  oCol:cHeader       :="Vuelto"
  oCol:nWidth        :=90
  oCol:bStrData      :={||TRAN(aDataM[oBrwM:nArrayAt,5],"99,999.99")}
  oCol:nDataStrAlign := AL_RIGHT
  oCol:nHeadStrAlign := AL_RIGHT
  oCol:nFootStrAlign := AL_RIGHT
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrwM:aArrayData ) }

  oCol:=oBrwM:aCols[6]
  oCol:cHeader       :="Zona"
  oCol:nWidth        :=105
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrwM:aArrayData ) }

  oCol:=oBrwM:aCols[7]
  oCol:cHeader       :="Hora"
  oCol:nWidth        :=42
  oCol:bStrData      :={||LEFT(aDataM[oBrwM:nArrayAt,7],5)}
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrwM:aArrayData ) }

  oCol:=oBrwM:aCols[8]
  oCol:cHeader       :="Tiempo"
  oCol:nWidth        :=42
  oCol:bStrData      :={||LEFT(aDataM[oBrwM:nArrayAt,8],5)}
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrwM:aArrayData ) }

  oCol:=oBrwM:aCols[9]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData     := { ||IIF(oBrwM:aArrayData[oBrwM:nArrayAt,9],1,2) }
  oCol:nDataStyle   := oCol:DefStyle( AL_LEFT, .F.)
// oCol:bLDClickData :={||DocSelect()}
  oBrwM:bLDblClick   := {||DocSelect()}

  oBrwM:bClrStd   := {|nAt|nAt:=oBrwM:nArrayAt, { iif( oBrwM:aArrayData[nAt,9], CLR_BLACK,  CLR_GRAY ),;
                                                  iif( oBrwM:nArrayAt%2=0, nClrPane2 ,  nClrPane1  ) } }

  oBrwM:bClrHeader:= {|| { CLR_BLACK, 8711165 } }

  oBrwM:DelCol(LEN(oBrwM:aCols))

  oBrwM:CreateFromCode()

  @.2, 80.5 SBUTTON oBtn ;
            SIZE 39, 14 FONT oFontB;
            FILE "BITMAPS\XSAVE.BMP","BITMAPS\XSAVE.BMP","BITMAPS\XSAVEG.BMP";
            NOBORDER;
            LEFT PROMPT "Grabar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            WHEN nTotal>0;
            ACTION CREAGUIACARGA() CANCEL


  @1.5, 80.5 SBUTTON oBtn ;
            SIZE 39, 14 FONT oFontB;
            FILE "BITMAPS\XCANCEL.BMP";
            NOBORDER;
            LEFT PROMPT "Cerrar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION CANCELACARGA()


  ACTIVATE DIALOG oDlgM ON INIT(oDlgM:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                oBrwM:SetColor(NIL,nClrPane2),;
                                oBrwM:Move(75,0,nWidth-05,nHeight-105,.T.),;
                                .F.)

  IF !Empty(cNumGtr)

      EJECUTAR("FMTRUN","RUTADESPACHO","RUTADESPACHO","Imprimir Guía de Despacho "+cNumGtr,;
                        "GTR_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                        "GTR_NUMERO"+GetWhere("=",cNumGtr))
  ENDIF

RETURN cNumGtr

FUNCTION GETXZONA(cMuni,cZona,oBrw)
   LOCAL aData:={},I,aTotal

   FOR I=1 TO LEN(aPedidos) 

       IF (cZona=aPedidos[I,nZona] .OR. "-Todos"$cZona) .AND.; 
          (cMuni=aPedidos[I,nMuni] .OR. "-Todos"$cMuni)

          AADD(aData,aPedidos[I])

       ENDIF

   NEXT I

   IF ValType(oBrw)="O"
      aTotal:=ATOTALES(aData)
      oBrw:aArrayData:=ACLONE(aData)
      oBrw:aCols[4]:cFooter:=TRAN( aTotal[4] ,"9,999,999,999.99")
      oBrw:Gotop()
      oBrw:Refresh(.T.)
   ENDIF

   aDataM:=ACLONE(aData)

RETURN aData

FUNCTION DocSelect(lSelect)
   LOCAL aLine:=oBrwM:aArrayData[oBrwM:nArrayAt],I
   LOCAL aData:={}

   LOCAL nAt:=ASCAN( aPedidos , {|a,n| a[1]=aLine[1] .AND. a[2]=aLine[2] } )

   oBrwM:aArrayData[oBrwM:nArrayAt,9]:=!oBrwM:aArrayData[oBrwM:nArrayAt,9]

   aPedidos[nAt,9]:=oBrwM:aArrayData[oBrwM:nArrayAt,9]

   oBrwM:DrawLine(.T.)

   aTotal :=ATOTALES(aPedidos , {|aLine| aLine[9] } )
   nTotal :=aTotal[4]
   nVuelto:=aTotal[5]

   oBrwM:aCols[4]:cFooter:=TRAN( nTotal   ,"9,999,999,999.99")
   oBrwM:aCols[5]:cFooter:=TRAN( aTotal[5],"9,999,999,999.99")
   oBrwM:Refresh(.F.)

   oBtn:ForWhen()
   oBtn:Refresh(.T.)

   FOR I=1 TO LEN(oBrwM:aArrayData)
     IF oBrwM:aArrayData[I,9] .AND. oBrwM:aArrayData[I,5]>0 
        AADD( aData, oBrwM:aArrayData[I,5] )
     ENDIF
   NEXT I

   oDp:cDesglose:="Vuelto"

   IF !Empty(aData)
     EJECUTAR("TDESGLOSE",aData)
   ENDIF

   cVuelto:=oDp:cDesglose
   oVuelto:Refresh(.T.)

RETURN .T.

/*
// Obtiene el Transporte
*/
FUNCTION GETTRANSP(cCodTra,oCombo)

  LOCAL cSql

  cSql   :=" SELECT VEH_PLACA ,VEH_TIPO FROM DPVEHICULOS WHERE VEH_CODTRA"+GetWhere("=",cCodTra)+;
           " AND VEH_ACTIVO=1 AND "+;
           " (VEH_V_SEG"+GetWhere(">=",oDp:dFecha)+" OR VEH_V_SEG"+GetWhere("=",CTOD(""))+")"+;
           " AND "+;
           " (VEH_V_PER"+GetWhere(">=",oDp:dFecha)+" OR VEH_V_PER"+GetWhere("=",CTOD(""))+")"

         
  aModelo:={}
  aPlacas :=ASQL(cSql)

  IF Empty(aPlacas)
     AADD(aPlacas,{"Ninguno","Ninguno"})
  ENDIF

  AEVAL(aPlacas,{|a,n| aPlacas[n]:=a[1] , AADD(aModelo,a[2]) })

  IF ValType(oCombo)="O"
     oCombo:SetItems(aPlacas)
     oCombo:Select(1)
  ENDIF


RETURN aPlacas[1]

FUNCTION DOCTODOS()

RETURN .T.

FUNCTION CREAGUIACARGA()
   LOCAL oTable,cWhere,aTickes:={},I,lResp

   FOR I=1 TO LEN(aPedidos)
     IF aPedidos[I,9]
       AADD(aTickes,aPedidos[I,2])
     ENDIF
   NEXT I

   cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND " +;
           "DOC_TIPDOC"+GetWhere("=","TIK")        +" AND ("+;
            GetWhereOr("DOC_NUMERO",aTickes)+")"

   DpSqlBegin()

   CursorWait()

   oTable:=OpenTable("SELECT * FROM DPGUIACARGA",.F.)
   oTable:Append()
   oTable:Replace("GTR_CODSUC",oDp:cSucursal)
   oTable:Replace("GTR_NUMERO",SQLINCREMENTAL("DPGUIACARGA","GTR_NUMERO","GTR_CODSUC"+GetWhere("=",oDp:cSucursal)))
   oTable:Replace("GTR_FECHA" , oDp:dFecha             )
   oTable:Replace("GTR_PLACA" , cPlaca                 )
   oTable:Replace("GTR_CI_RIF", aCI[oConductor:nAt]    )
   oTable:Replace("GTR_CODTRA", aCodTran[oTransp:nAt]  )
   oTable:Replace("GTR_MTOFON", nVuelto                )

   lResp:=oTable:Commit()
   oTable:End()

   SQLUPDATE("DPDOCCLI","DOC_NUMGTR",oTable:GTR_NUMERO,cWhere)

   IF !lResp

     DpSqlRollBack()

   ELSE

     cNumGtr:=oTable:GTR_NUMERO

     DpSqlCommit()

     oDlgM:End()

   ENDIF

RETURN .T.

FUNCTION BUILDPARRO()
  LOCAL I,aZonas:={}

  FOR I=1 TO LEN(aPedidos)

     IF aPedidos[I,10]==cMuni .AND. ASCAN(aZonas,aPedidos[I,nZona])=0
        AADD(aZonas,aPedidos[I,nZona])
     ENDIF

  NEXT I

  AADD(aZonas,"-Todos")
  
  oZona:SetItems(aZonas)
  oZona:VarPut(aZonas[1],.T.)
  COMBOINI(oZona)

RETURN .T.

FUNCTION CANCELACARGA()

   IF nTotal>0 .AND. !MsgNoYes("Desea Cerrar Guia de Carga")
      RETURN .T.
   ENDIF

   oDlgM:End()

RETURN .T.

FUNCTION VIEWDESGLOSE()

  LOCAL oBrwMp,oCol,oDlgP,I,aData:={},oFont4,cPicture:="9,999,999.99",nMonto:=0
  LOCAL nClrPane1 := 16770764
  LOCAL nClrPane2 := 16566954

  FOR I=1 TO LEN(oBrwM:aArrayData)
    IF oBrwM:aArrayData[I,9] .AND. oBrwM:aArrayData[I,5]>0 
       AADD( aData, oBrwM:aArrayData[I,5] )
       nMonto:=nMonto+oBrwM:aArrayData[I,5]
    ENDIF
  NEXT I

 
  aData:=EJECUTAR("TDESGLOSE",aData)

  DEFINE FONT oFont4   NAME "MS Sans Serif" SIZE 0, -10 BOLD

  DEFINE DIALOG oDlgP TITLE "Desglose, Total Cambio: "+TRAN(nMonto,cPicture)

  oDlgP:lHelpIcon:=.F.

  oBrwMp:=TXBrowse():New(oDlgP )
  oBrwMp:SetArray( aData ,.F.)
  oBrwMp:lHScroll       := .F.
  oBrwMp:lVScroll       := .F.
  oBrwMp:nFreeze        := 1
  oBrwMp:oFont          := oFont4
  oBrwMp:lFooter        := .F.
  oBrwMp:lRecordSelector:= .F.
  oBrwMp:lFooter        := .T.

  oCol:=oBrwMp:aCols[1]
  oCol:cHeader      := "Moneda"
  oCol:nWidth       := 080
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrwMp:aArrayData[oBrwMp:nArrayAt,1],cPicture)}
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrwMp:aCols[2]
  oCol:cHeader      := "X"
  oCol:nWidth       := 15
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrwMp:aCols[3]
  oCol:cHeader      := "Cant."
  oCol:nWidth       := 45
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrwMp:aCols[4]
  oCol:cHeader      := "="
  oCol:nWidth       := 15
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}

  oCol:=oBrwMp:aCols[5]
  oCol:cHeader      := "Total"
  oCol:nWidth       := 120+22
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:bStrData     := {||TRAN(oBrwMp:aArrayData[oBrwMp:nArrayAt,5],cPicture)}
  oCol:bClrHeader   := {||{CLR_WHITE,CLR_BLUE}}
  oCol:cFooter      := "0.00"   

  AEVAL(oBrwMp:aCols,{|oCol,n|oCol:oHeaderFont:=oFont4})

  oBrwMp:bClrStd   := {||{0, iif( oBrwMp:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }
  oBrwMp:bClrHeader:= {||{CLR_BLACK,14671839 }}

  oBrwMp:CreateFromCode()
  
  ACTIVATE DIALOG oDlgP CENTERED ON INIT (oDlgP:SetSize(322,400,.T.),;
                                          oBrwMp:Move(0,0,oDlgP:nWidth()-10,oDlgP:nHeight()-32,.T.),;
                                          oBrwMp:SetColor(nClrPane2,nClrPane1),,.F.)

RETURN .T.
// EOF


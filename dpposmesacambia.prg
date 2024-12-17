// Programa   : DPPOSMESACAMBIA
// Fecha/Hora : 07/01/2007 12:18:40
// Propósito  : Intercambio de Mesas
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : POS-RESTAURANT
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDesde)
  
   LOCAL oDlgIM,cHasta:=SPACE(3),nDesde,nHasta
   LOCAL oDesde,oHasta,oDesdeC,oHastaC,nWidth:=700,nHeight:=400
   LOCAL aDesde:={},aHasta:={}
   LOCAL oBrwD,oBrwH,oFont,oFontG,oBtnD,oBtnH,oBtnTD,oBtnTH

   DEFAULT cDesde:=SPACE(3)

   AADD(aDesde,{"",0})
   AADD(aHasta,{"",0})

   DEFINE FONT oFont  NAME "Courier New" SIZE 0,-12 
   DEFINE FONT oFontG NAME "Arial"   SIZE 0, -12 BOLD


   DEFINE DIALOG oDlgIM TITLE "Intercambio Entre Mesas";
          COLOR NIL,oDp:nGris

   oDlgIM:lHelpIcon:=.F.

   @ 0.7,1   SAY "Desde:";
             SIZE 21,8 FONT oFontG

   @ 1.7,1.0 GET oDesde VAR cDesde;
             SIZE 18,11;
             FONT oFontG;
             VALID CERO(cDesde) .AND. MESADESDE()

   @ 0.7,32  SAY "Hasta:";
             SIZE 20,8 FONT oFontG


   @ 1.7,24  GET oHasta VAR cHasta;
             SIZE 18,11;
             FONT oFontG;
             VALID CERO(cHasta) .AND. MESAHASTA()

   oBrwD:= TXBrowse():New( oDlgIM )
   oBrwD:SetFont(oFont)

   SetName(oBrwD,aDesde,.T.)
   oBrwD:aCols[2]:bStrData :={|nMonto|nMonto:=oBrwD:aArrayData[oBrwD:nArrayAt,2],;
                                      TRAN(nMonto,"999.9")}


   oBrwD:aCols[2]:bOnPostEdit  :={|oCol,uValue,nLastKey,nCol|PONDESDE(oCol,uValue,nLastKey)}


   oBrwH:= TXBrowse():New( oDlgIM )
   oBrwH:SetFont(oFont)
   SetName(oBrwH,aHasta,.T.)

   oBrwH:aCols[2]:bStrData :={|nMonto|nMonto:=oBrwH:aArrayData[oBrwH:nArrayAt,2],;
                                      TRAN(nMonto,"999.9")}

   oBrwH:aCols[2]:bOnPostEdit  :={|oCol,uValue,nLastKey,nCol|PONHASTA(oCol,uValue,nLastKey)}



   @ 2.5,25 BUTTON oBtnD PROMPT " > ";
            ACTION (SWAPBRW(oBrwD,oBrwH,cDesde,cHasta,aDesde),;
                    aDesde:=ACLONE(oBrwD:aArrayData),aHasta:=ACLONE(oBrwH:aArrayData)) ;
            FONT oFontG;
            SIZE 25,10;
            WHEN !Empty(oBrwD:aArrayData[1,1])

   @ 3.2,25 BUTTON oBtnTD PROMPT " >> ";
            ACTION TODOSDESDE() ;
            FONT oFontG;
            SIZE 25,10;
            WHEN !Empty(oBrwD:aArrayData[1,1])


   @ 4.5,25 BUTTON oBtnH PROMPT " < ";
            ACTION SWAPBRW(oBrwH,oBrwD,cHasta,cDesde,aHasta) ;
            FONT oFontG;
            SIZE 25,10;
            WHEN !Empty(oBrwH:aArrayData[1,1])

   @ 5.2,25 BUTTON oBtnTH PROMPT " << ";
            ACTION TODOSHASTA() ;
            FONT oFontG;
            SIZE 25,10;
            WHEN !Empty(oBrwH:aArrayData[1,1])


   @ 7.5,25 BUTTON oBtnTH PROMPT " Salir ";
            ACTION oDlgIM:End() ;
            FONT oFontG;
            SIZE 25,10 CANCEL
 
   ACTIVATE DIALOG oDlgIM CENTERED;
            ON INIT (oDlgIM:Move(10,10,nWidth,nHeight,.T.),;
                     oBrwD:Move(80,010,262,nHeight-115,.T.),;
                     oBrwH:Move(80,380,262,nHeight-115,.T.))

RETURN .T.

/*
// DESDE
*/
FUNCTION MESADESDE()

   aDesde:=ASQL(" SELECT INV_DESCRI,COM_CANTID,COM_ITEM FROM DPPOSCOMANDA "+;
                " INNER JOIN DPINV ON COM_CODIGO=INV_CODIGO"+;
                " WHERE COM_MESA"+GetWhere("=",cDesde)+" AND COM_TIPO='P' ORDER BY INV_DESCRI ")

   IF LEN(aDesde)=0
      MensajeErr("Mesa no Tienen Comanda")
      RETURN .F.
   ENDIF

   oBrwD:aCols[1]:cFooter:="Comandas "+LSTR(LEN(aDesde))
   oBrwD:aArrayData:=ACLONE(aDesde)
   oBrwD:Refresh(.T.)

  
RETURN .T.

FUNCTION MESAHASTA()

    IF cDesde=cHasta
       MensajeErr("Mesa debe ser Distinta :"+cDesde)
       RETURN .F. 
    ENDIF

    aHasta:=ASQL(" SELECT INV_DESCRI,COM_CANTID,COM_ITEM FROM DPPOSCOMANDA "+;
                 " INNER JOIN DPINV ON COM_CODIGO=INV_CODIGO"+;
                 " WHERE COM_MESA"+GetWhere("=",cHasta)+" AND COM_TIPO='P' ORDER BY INV_DESCRI ")

    oBrwH:aCols[1]:cFooter:="Comandas "+LSTR(LEN(aHasta))

    IF LEN(aHasta)=0
       AADD(aHasta,{"",0})
    ENDIF

    oBrwH:aArrayData:=ACLONE(aHasta)
    oBrwH:Refresh(.T.)

    oBrwD:nColSel:=2
    DpFocus(oBrwD)
 
RETURN .T.


FUNCTION SETNAME(oBrw,aData,lEdit)
   LOCAL nFor,oCol,aHead:={"Producto","Cant"}
   LOCAL aWidth:={200,35}

   IF EMPTY(aData)
      AADD(aData,{"",""})
   ENDIF

   oBrw:nFooterLines:=1
   oBrw:lFooter     :=.T.
   oBrw:SetArray(aData,!lEdit)

   For nFor:= 1 to len(oBrw:aCols)
      oCol:= oBrw:aCols[nFor]
      oCol:cHeader:=aHead[nFor]
      oCol:nWidth :=aWidth[nFor]
   Next
   
   oBrw:aCols[2]:nDataStrAlign:= AL_RIGHT
   oBrw:aCols[2]:nHeadStrAlign:= AL_RIGHT
   oBrw:aCols[1]:cFooter      :="Comandas: 0 "


   if lEdit
      oBrw:aCols[2]:nEditType:=1
   endif

   oBrw:nMarqueeStyle   := MARQSTYLE_HIGHLCELL
   oBrw:lHScroll        := .f.
   oBrw:bChange         := {||NIL}

   oBrw:nColDividerStyle    := LINESTYLE_BLACK
   oBrw:nRowDividerStyle    := LINESTYLE_BLACK
   oBrw:lColDividerComplete := .t.
   oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLROW
   oBrw:lRecordSelector     :=.f.  // if true a record selector column is displayed

   oBrw:CreateFromCode()

RETURN .T.

FUNCTION PONDESDE(oCol,uValue,nLastKey)

   IF uValue>oBrwD:aArrayData[oBrwD:nArrayAt,2]
     MensajeErr("Cantidad Inválida")
     RETURN .F.
   ENDIF

  IF uValue==oBrwD:aArrayData[oBrwD:nArrayAt,2]
    SWAPBRW(oBrwD,oBrwH,cDesde,cHasta,aDesde)
  ELSE

  ENDIF

  aDesde:=ACLONE(oBrwD:aArrayData)
  aHasta:=ACLONE(oBrwH:aArrayData)

RETURN .T.

FUNCTION PONHASTA(oCol,uValue,nLastKey)

   IF uValue>oBrwH:aArrayData[oBrwH:nArrayAt,2]
     MensajeErr("Cantidad Inválida")
     RETURN .F.
   ENDIF

  IF uValue==oBrwH:aArrayData[oBrwH:nArrayAt,2]
    SWAPBRW(oBrwH,oBrwD,cHasta,cDesde,aHasta)
  ELSE

  ENDIF

  aDesde:=ACLONE(oBrwD:aArrayData)
  aHasta:=ACLONE(oBrwH:aArrayData)

RETURN .T.

/*
// Intercambio de Campos entre Browse
*/
FUNCTION SWAPBRW(oBrw1,oBrw2,cDesde,cHasta,aData)
   // Quita del Brow1 y Coloca  en el Browse 2
   LOCAL nAt1:=oBrw1:nArrayAt,cWhere
   LOCAL nAt2:=oBrw2:nArrayAt
   LOCAL aSwap:=oBrw1:aArrayData[nAt1]

   IF LEN(oBrw1:aArrayData)=1.AND.EMPTY(oBrw1:aArrayData[1]) // ya esta Vacio
      RETURN NIL
   ENDIF

   cWhere:="COM_MESA"+GetWhere("=",cDesde)+" AND COM_ITEM"+GetWhere("=",aData[nAt1,3])

   SQLUPDATE("DPPOSCOMANDA","COM_MESA",cHasta,cWhere)


   IF LEN(oBrw1:aArrayData)=1 // Ultimo no Puede estar Vacio
     AEVAL(oBrw1:aArrayData[1],{|a,i|oBrw1:aArrayData[1,i]:=""})
   ELSE 
     ADEL(oBrw1:aArrayData,nAt1)
     ASIZE(oBrw1:aArrayData,LEN(oBrw1:aArrayData)-1)
   ENDIF

   oBrw1:Refresh()

   nAt2:=Min(nAt2+1,len(oBrw2:aArrayData))
   AADD(oBrw2:aArrayData,NIL)
   AINS(oBrw2:aArrayData,nAt2)
   oBrw2:aArrayData[nAt2]:=aSwap
   oBrw2:nArrayAt:=nAt2
   oBrw2:Refresh()

   nAt2:=ASCAN(oBrw2:aArrayData,{|a,i|Empty(a[1])})
   IF nAt2>0
      ADEL(oBrw2:aArrayData,nAt2)
      ASIZE(oBrw2:aArrayData,LEN(oBrw2:aArrayData)-1)
      oBrw2:Refresh()
   ENDIF

   IF oBrw1:bChange!=NIL
      EVAL(oBrw1:bChange)
   ENDIF

   IF oBrw2:bChange!=NIL
      EVAL(oBrw2:bChange)
   ENDIF

   oBtnD:ForWhen()
   oBtnH:ForWhen()


RETURN .T.

FUNCTION TODOSDESDE()

     LOCAL I,nLen:=LEN(oBrwD:aArrayData)

     CursorWait()

     FOR I=1 TO nLen
       oBrwD:Gotop(.T.)
       SWAPBRW(oBrwD,oBrwH,cDesde,cHasta,aDesde) 
       aDesde:=ACLONE(oBrwD:aArrayData)
       aHasta:=ACLONE(oBrwH:aArrayData)
     NEXT I

     CursorArrow()

RETURN .T.


FUNCTION TODOSHASTA()

     LOCAL I,nLen:=LEN(oBrwH:aArrayData)

     CursorWait()

     FOR I=1 TO nLen
       oBrwH:Gotop(.T.)
       oBrwH:nArrayAt:=1
       SWAPBRW(oBrwH,oBrwD,cHasta,cDesde,aHasta)
     NEXT I

     aDesde:=ACLONE(oBrwD:aArrayData)
     aHasta:=ACLONE(oBrwH:aArrayData)

     CursorArrow()

RETURN .T.


// EOF



// Programa   : DPPOSLEEBAL
// Fecha/Hora : 20/09/2006 12:09:40
// Propósito  : Lectura de Balanza bizerba
// Creado Por : Juan Navas
// Llamado por: DPPOS01
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  LOCAL cCodEqui,lFound:=.F.,aData:={},I,aLine:={}
  LOCAL oBrw :=oPos:oBrwItem,nAt
  LOCAL nAt  :=LEN(oBrw:aArrayData)
  LOCAL aLine:=oBrw:aArrayData[nAt]

  // JN 23/03/2017, este programa inncesario, genera incidencias en punto de venta cuando el codigo del producto no existe.
  // Podemos implementarlo cuando logramos implementar lectura de datos de balanzas digitales, en este caso fue la balanza bizerba

RETURN .F.


  aData:=EJECUTAR("TESTBAL",oPos:cCodInv)

  IF Empty(aData)
       RETURN .F. 
  ENDIF

  oPos:aDataBal:=aData

      FOR I=1 TO LEN(aData)
     
           nAt  :=LEN(oBrw:aArrayData)
           aLine:=ACLONE(oBrw:aArrayData[nAt])

           oPos:cCodInv :=aData[I,1]
           oPos:cCodVen :=aData[I,2]
           oPos:cCodVen :=STRZERO(VAL(oPos:cCodVen),6)
           oPos:nCantid :=aData[I,3]
           oPos:nPrecio :=aData[I,4]
//         oPos:cMsgInv :=SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oPos:cCodInv))
           oPos:cMsgInv :=SQLGET("DPINV","INV_DESCRI,INV_IVA","INV_CODIGO"+GetWhere("=",oPos:cCodInv))

           oPos:cIva    :=oDp:aRow[2]
           oPos:nIvaItem:=EJECUTAR("IVACAL",oPos:cIva,2,oPos:dFecha) // IVA (Nacional o Zona Libre
           aData[I,5]   :=oPos:PRECIOIVA(aData[I,5])

           oBrw:aArrayData[nAt,01]:=oPos:cCodInv+" "+ALLTRIM(STR(oPos:nCantid,10,3))+"X"+ALLTRIM(FDP(oPos:nPrecio,"999,999,999.99"))+CRLF+oPos:cMsgInv
           oBrw:aArrayData[nAt,02]:=aData[I,5]
           oBrw:aArrayData[nAt,03]:=oPos:nCantid 
           oBrw:aArrayData[nAt,04]:=oPos:nPrecio 
           oBrw:aArrayData[nAt,06]:=oPos:cCodInv
           oBrw:aArrayData[nAt,07]:=oPos:nIvaItem
           oBrw:aArrayData[nAt,08]:=oPos:cIva
           oBrw:aArrayData[nAt,09]:=oPos:cMsgInv
           oBrw:aArrayData[nAt,10]:=oPos:cUndMed
           oBrw:aArrayData[nAt,11]:=oPos:nCxUnd
           oBrw:aArrayData[nAt,12]:=oPos:cCodVen
           oPos:nNeto             :=aData[I,5]

           AEVAL(aLine,{|a,n|aLine[n]:=CTOEMPTY(a)})
           AADD(oBrw:aArrayData,aLine)

           oPos:DISPITEM()

       NEXT I


       oPos:cCodInv:=CTOEMPTY(oPos:cCodInv)
       oPos:oCodInv:VarPut(oPos:cCodInv,.T.)
      
       oBrw:GoBottom(.T.)
       oPos:Calcular()

       RETURN .F.

RETURN .T.
// EOF

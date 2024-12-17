// Programa   : DPPOSCOMMPRN
// Fecha/Hora : 26/08/2006 13:54:46
// Propósito  : Imprimir Comanda
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : Ventas
// Tabla      : DPPOSCOMANDA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cMesa,cUS)
   LOCAL aLpt:={},cWhere,I,oRun

   DEFAULT cMesa:=STRZERO(1,8),;
           cUs  :=oDp:cUsuario

   cWhere:=" COM_MESA"+GetWhere("=",cMesa)+" AND COM_LLEVAR=0 AND COM_IMPRES=0 "+;
           " AND COM_LPT<>'NING'"

   IF !Empty(cUs)
      cWhere:=cWhere +" AND COM_USUARI"+GetWhere("=",cUs)
   ENDIF

// ? cWhere,"DPPOSCOMMPRN"

   aLpt  :=ASQL("SELECT COM_LPT FROM DPPOSCOMANDA WHERE "+cWhere+" GROUP BY COM_LPT")

   IF Empty(aLpt)
      MensajeErr("No hay Comandas para Imprimir")
      RETURN .F.
   ENDIF

   FOR I=1 TO LEN(aLpt)

     oRun:=EJECUTAR("FMTRUN","COMANDAS","COMANDAXMESA","Comandas de la Mesa "+cMesa+;
                   " Dispositivo "+aLpt[I,1],cWhere+" AND "+;
                    "COM_LPT"+GetWhere("=",aLpt[I,1]),aLpt[I,1])

     oRun:SETDEVICE(aLpt[I,1]+":")
//     oRun:lClose:=.T. // Cierra Automáticamente
//     oRun:FMTSTART()

   NEXT I

RETURN .T.

PROCE OLD()
   LOCAL oTable,cLpt,cLine,cMemo:="",I,nLen:=39,aItem:={},cWhere,cTipo:=""
   LOCAL oCompo

   DEFAULT cMesa:=STRZERO(1,3)

   oTable:=OpenTable(" SELECT * FROM DPPOSCOMANDA WHERE COM_MESA"+GetWhere("=",cMesa)+" AND "+;
                     " COM_IMPRES=0 AND COM_LPT<>\\\'\\\' AND COM_TIPO=\\\'P\\\' "+;
                     " ORDER BY COM_LPT,COM_ITEM ",.T.)

//   ? CLPCOPY(oTable:cSql)

//   oTable:Browse()

   FERASE("TEST.TXT")

   WHILE !oTable:Eof()

      cLpt :=oTable:COM_LPT
      cMemo:=""

      Set(24,ALLTRIM(cLpt)+":",.T. )
      FERASE("TEST.TXT")
//      Set(24,"TEST.TXT",.T. )
      Set(23,"ON" )

      PRNLINE(REPLI("-",39))
      PRNLINE("Mesa:"   +oTable:COM_MESA  )
      PRNLINE("Mesero:" +ALLTRIM(oTable:COM_MESERO+" "+;
              MYSQLGET("DPVENDEDOR","VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",oTable:COM_MESERO))))

      PRNLINE(REPLI("-",39))

      WHILE !oTable:Eof() .AND. cLpt=oTable:COM_LPT

         AADD(aItem,oTable:COM_ITEM)

         cLine:=LEFT(oTable:COM_DESCRI,31)+ " " + ;
                TRAN(oTable:COM_CANTID,"9,999.99") 
         PRNLINE(cLine)

         IF !Empty(oTable:COM_COMENT)
            PRNLINE(" *"+oTable:COM_COMENT)
         ENDIF

         // Ahora los Componentes
         oCompo:=OpenTable("SELECT * FROM DPPOSCOMANDA WHERE COM_TIPO='C' AND COM_ITEM_A"+GetWhere("=",oTable:COM_ITEM),.T.)

         WHILE !oCompo:Eof()

 
            cLine:=LEFT(oCompo:COM_DESCRI,30)+ " " + ;
                   TRAN(oCompo:COM_CANTID,"9,999.99") 

            PRNLINE("#"+cLine)

            oCompo:DbSkip()

         ENDDO

         IF oCompo:RecCount()>0
           PRNLINE(REPLI(" ",39))
         ENDIF

         oCompo:End()
         oTable:DbSkip()

      ENDDO

      PRNLINE(REPLI("-",39))

      FOR I=1 TO 5
         PRNLINE("")
      NEXT I

      Set(23,"OFF" )

      SET PRINT TO
      SET PRINT OFF

   ENDDO

   oTable:End()

   cWhere:=GetWhereOr("COM_ITEM",aItem)

   IF FILE("TEST.TXT")
      ? MEMOREAD("TEST.TXT")
   ENDIF

   SQLUPDATE("DPPOSCOMANDA","COM_IMPRES",.T.,cWhere)

RETURN .T.


FUNCTION PRNLINE(cLine)
    cLine:=ANSITOOEM(cLine)
    cMemo:=cMemo+IIF( Empty(cMemo) , "" , CRLF )+;
           cLine
    QOut(PADR(cLine,nLen))
RETURN cLine

// EOF/ Programa   : DPPOSCOMMPRN
// Fecha/Hora : 26/08/2006 13:54:46
// Propósito  : Imprimir Comanda
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : Ventas
// Tabla      : DPPOSCOMANDA

#INCLUDE "DPXBASE.CH"

PROCE MAIN2(cMesa,cUS)
   LOCAL aLpt:={},cWhere,I,oRun

   DEFAULT cMesa:=STRZERO(1,8),;
           cUs  :=oDp:cUsuario

   cWhere:=" COM_MESA"+GetWhere("=",cMesa)+" AND COM_LLEVAR=0 AND COM_IMPRES=0 "+;
           " AND COM_LPT<>'NING'"

   IF !Empty(cUs)
      cWhere:=cWhere +" AND COM_USUARI"+GetWhere("=",cUs)
   ENDIF

   aLpt  :=ASQL("SELECT COM_LPT FROM DPPOSCOMANDA WHERE "+cWhere+" GROUP BY COM_LPT")

   IF Empty(aLpt)
      MensajeErr("No hay Comandas para Imprimir")
      RETURN .F.
   ENDIF

   FOR I=1 TO LEN(aLpt)

     oRun:=EJECUTAR("FMTRUN","COMANDAS","COMANDASXMESA","Comandas de la Mesa "+cMesa+;
                   " Dispositivo "+aLpt[I,1],cWhere+" AND "+;
                    "COM_LPT"+GetWhere("=",aLpt[I,1]))

     oRun:SETDEVICE(aLpt[I,1]+":")
     oRun:lClose:=.T. // Cierra Automáticamente
     oRun:FMTSTART()

   NEXT I

RETURN .T.

PROCE OLD()
   LOCAL oTable,cLpt,cLine,cMemo:="",I,nLen:=39,aItem:={},cWhere,cTipo:=""
   LOCAL oCompo

   DEFAULT cMesa:=STRZERO(1,3)

   oTable:=OpenTable(" SELECT * FROM DPPOSCOMANDA WHERE COM_MESA"+GetWhere("=",cMesa)+" AND "+;
                     " COM_IMPRES=0 AND COM_LPT<>'' AND COM_TIPO='P' "+;
                     " ORDER BY COM_LPT,COM_ITEM ",.T.)

// ? CLPCOPY(oTable:cSql)
// oTable:Browse()

   FERASE("TEST.TXT")

   WHILE !oTable:Eof()

      cLpt :=oTable:COM_LPT
      cMemo:=""

      Set(24,ALLTRIM(cLpt)+":",.T. )
      FERASE("TEST.TXT")
//      Set(24,"TEST.TXT",.T. )
      Set(23,"ON" )

      PRNLINE(REPLI("-",39))
      PRNLINE("Mesa:"   +oTable:COM_MESA  )
      PRNLINE("Mesero:" +ALLTRIM(oTable:COM_MESERO+" "+;
              MYSQLGET("DPVENDEDOR","VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",oTable:COM_MESERO))))

      PRNLINE(REPLI("-",39))

      WHILE !oTable:Eof() .AND. cLpt=oTable:COM_LPT

         AADD(aItem,oTable:COM_ITEM)

         cLine:=LEFT(oTable:COM_DESCRI,31)+ " " + ;
                TRAN(oTable:COM_CANTID,"9,999.99") 
         PRNLINE(cLine)

         IF !Empty(oTable:COM_COMENT)
            PRNLINE(" *"+oTable:COM_COMENT)
         ENDIF

         // Ahora los Componentes
         oCompo:=OpenTable("SELECT * FROM DPPOSCOMANDA WHERE COM_TIPO='C' AND COM_ITEM_A"+GetWhere("=",oTable:COM_ITEM),.T.)

         WHILE !oCompo:Eof()

 
            cLine:=LEFT(oCompo:COM_DESCRI,30)+ " " + ;
                   TRAN(oCompo:COM_CANTID,"9,999.99") 

            PRNLINE("#"+cLine)

            oCompo:DbSkip()

         ENDDO

         IF oCompo:RecCount()>0
           PRNLINE(REPLI(" ",39))
         ENDIF

         oCompo:End()
         oTable:DbSkip()

      ENDDO

      PRNLINE(REPLI("-",39))

      FOR I=1 TO 5
         PRNLINE("")
      NEXT I

      Set(23,"OFF" )

      SET PRINT TO
      SET PRINT OFF

   ENDDO

   oTable:End()

   cWhere:=GetWhereOr("COM_ITEM",aItem)

   IF FILE("TEST.TXT")
      ? MEMOREAD("TEST.TXT")
   ENDIF

   SQLUPDATE("DPPOSCOMANDA","COM_IMPRES",.T.,cWhere)

RETURN .T.


FUNCTION PRNLINE(cLine)
    cLine:=ANSITOOEM(cLine)
    cMemo:=cMemo+IIF( Empty(cMemo) , "" , CRLF )+;
           cLine
    QOut(PADR(cLine,nLen))
RETURN cLine

// EOF


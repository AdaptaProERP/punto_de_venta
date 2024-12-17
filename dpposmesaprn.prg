// Programa   : DPPOSMESAPRN
// Fecha/Hora : 25/05/2006 05:46:51
// Propósito  : Cuenta por Mesa
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cMesa,oComanda,lTotal,lPagEle)
  LOCAL oDlg,oFont,oBtn,oMemo,oFontB
  LOCAL nTop:=85,nLeft:=1,nWidth:=400,nHeight:=428+10,I,nPorIva:=0
  LOCAL nClrPane1:=16774636
  LOCAL lSelect:=.F.,cBanco:="",aData,nBtnAlto:=25
  LOCAL aTotal :={},cMemo:="",I,aTotal:={},nTotal:=0,nServicio:=0,nIva:=0

  DEFAULT cMesa  :=STRZERO(1,3),;
          lTotal :=.F.,;
          lPagEle:=.F.

  DEFAULT oDp:nPorSerPos:=0,;
          oDp:cImpCta:=""

  IF ALLDIGIT(cMesa)
    cMesa:=STRZERO(VAL(cMesa),LEN(cMesa))
  ENDIF

/*
  aData:=ASQL(" SELECT COM_CODIGO,COM_DESCRI,COM_CANTID,COM_PRECIO,COM_PRECIO*COM_CANTID,COM_IVA "+;
              " FROM DPPOSCOMANDA "+;
              " INNER JOIN DPINV ON COM_CODIGO=INV_CODIGO "+;
              " WHERE COM_MESA "+GetWhere("=",cMesa)+" AND COM_TIPO='P'"+;
              " ORDER BY COM_ITEM ")
*/


 aData:=ASQL(" SELECT COM_CODIGO,COM_DESCRI,COM_CANTID,COM_PRECIO,COM_PRECIO*COM_CANTID,INV_IVA "+;
              " FROM DPPOSCOMANDA "+;
              " INNER JOIN DPINV ON COM_CODIGO=INV_CODIGO "+;
              " WHERE COM_MESA "+GetWhere("=",cMesa)+" AND COM_TIPO='P'"+;
              " ORDER BY COM_ITEM ")


  FOR I=1 TO  LEN(aData)

     nPorIva:=EJECUTAR("IVACAL",aData[I,6],2,oDp:dFecha) // IVA (Nacional o Zona Libre

     // Pago Electrónico Reduce 2% del IVA 17/02/2017
     IF lPagEle
       nPorIva:=nPorIva-2
     ENDIF

     nIva   :=nIva + PORCEN(aData[I,5],nPorIva)

    //aData[I,5]:=nIva

   SQLUPDATE("DPPOSCOMANDA","COM_IVA",nPorIva,"COM_MESA "+GetWhere("=",cMesa)+;
                            " AND COM_TIPO='P' AND COM_CODIGO"+GetWhere("=",aData[I,1]))

 //? clpcopy(oDp:cSql)


  NEXT I


  aTotal:=ATOTALES(aData)

  nServicio:=PORCEN(aTotal[5],oDp:nPorSerPos)
  nTotal   :=aTotal[5]+nServicio+nIva
  nTotal   :=DIV(INT(nTotal*100),100)
  nTotal   :=DIV(INT(nTotal*100),100)

  // Total por Servicio
  oDp:nServicio:=nServicio

  IF lTotal
     RETURN nTotal
  ENDIF

  cMemo:=oDp:cEmpresa+" RIF:"+oDp:cRif+CRLF+;
         "Mesa:"+cMesa+" Fecha:"+DTOC(oDp:dFecha)+" Hora:"+TIME()+CRLF+;
         "Comprador: "+CRLF+;
         "Dirección: "+CRLF+;
         "Teléfono :                  RIF: "       +CRLF+;
         "-------------------- ------- ------------"+CRLF+;
         "Producto               Cant.        Monto"+CRLF+;
         "-------------------- ------- ------------ "
  
  FOR I=1 TO LEN(aData)

      cMemo:=cMemo+IIF(Empty(cMemo),"",CRLF)+;
             LEFT(aData[I,2],20)+" "+;
             PADL(LSTR(aData[I,3],07,2),07)+" "+;
             PADL(TRAN(aData[I,5],"9,999,999.99"),12)

  NEXT I

  cMemo:=cMemo+CRLF+;
         "-------------------- ------- ------------"+CRLF+;
         "                  SUB TOTAL:"+TRAN(aTotal[5],"99,999,999.99")+CRLF+;
         "                IVA %"+TRAN(nPorIva,"99.99")+" :"+TRAN(nIva     ,"99,999,999.99")+CRLF+;
         "           SERVICIO %"+STR(oDp:nPorSerPos,5,2)+" :"+TRAN(nServicio,"99,999,999.99")+CRLF+;
         "                     TOTAL :"+TRAN(nTotal   ,"99,999,999.99")

  DEFINE FONT oFont   NAME "Courier New" SIZE 0, -14 BOLD
  DEFINE FONT oFontB  NAME "Arial"       SIZE 0, -11 BOLD


  DEFINE DIALOG oDlg TITLE "Cuenta de Mesa "+cMesa;
         COLOR NIL,oDp:nGris

  @ 0,0 GET oMemo  VAR cMemo ;
             MEMO SIZE 80,80; 
             READONLY;
             FONT oFont

  IF !("NIN"$UPPE(oDp:cImpCta))

    @ 10.5,19 BUTTON " Imprimir "; 
              FONT oFontB;
              SIZE 40,12;
             ACTION (MsgRun("Imprimiendo","Por Favor Espere",{||PRINTCUENTA(cMemo,oDp:cImpCta)}),oDlg:End())

  ENDIF


  @ 10.5,26 BUTTON " Cerrar "; 
            FONT oFontB;
            SIZE 40,12;
            ACTION oDlg:End()

  ACTIVATE DIALOG oDlg ON INIT (oDlg:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                oMemo:SetSize(nWidth-5,nHeight-62,.T.))

                               
RETURN .T.

PROCE PRINTCUENTA(cMemo,cOut)
   LOCAL aLineas:={},cLine:=""

   DEFAULT cMemo  :=MEMOREAD("DP\DPPOS01.INI"),;
           cOut   :="LPT1:"

   cMemo  :=STRTRAN(cMemo,CHR(10),"")
   aLineas:=_VECTOR(cMemo,CHR(13))

   Set(24,cOut,.T. )
   Set(23,"ON" )

   FOR I=1 TO LEN(aLineas)
     cLine:=PADR(ANSITOOEM(aLineas[I]),39)
     QOut(cLine)
   NEXT I

   QOut("")
   QOut("")

   Set(23,"OFF" )
   SET PRINT OFF
   SET PRINT TO

RETURN .T.

// EOF


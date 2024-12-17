// Programa   : DPPOS03
// Fecha/Hora : importtik01/09/2005
// Propæsito  : Operaciones de Venta
// Creado Por : Juan Navas
// Modificado : Marlon Ramos 28-05-2008 (Cuando se pagaba con Tarj. Cred. Repet›a el pago en los siguientes tickets)
//                           02-06-2008 (Se redondea el iva para Evitar descuadres y se toma el descuento en el total)
//                           12-06-2008 (Reflejar el descuento total en pantalla)
//                           13-06-2008 (Evitar descuentos dobles)
//                           13-06-2008 (Evitar que coloquen % de descuentos de mas de tres d›gitos)
//                           26-06-2008 (No permitir cambiar el cliente de una devoluciæn)
//                           16-07-2008 (Cﬂlculo especial para BMC y Bematech, Ej: Al generar el sgte ticket: 
//                                       5 x Bs 10.50 % IVA 9 y 5 x Bs 50 % IVA 8 BMC genera el total del ticket por
//                                       Bs 327.25 y la impresora Bematech por Bs 327.23)
//                           21-07-2008 (Evitar generar tickets sin cliente)
//                           29-07-2008 (Correcciæn de funciæn de cambio de precio)
//                           04-08-2008 (Permitir seleccionar el vendedor)
//                           11-08-2008 (Creaciæn de Variables para ser utilizadas por DPPOSDEVOL y TICKETEPSON)
//                           25-08-2008 (Cuando tiene mﬂs de un precio permite seleccionar entre los Definidos para el producto)
//                           25-08-2008 (Mostrar Existencias en el grid de consulta de productos)
//                           18-09-2008 (Activaciæn de las teclas de Funciæn para los botones)
// 31-07-2009 : se habilito VALID CERO(cNumero) para que incluya los ceros al importar un pedido
// o devolucion
// Llamado por: DPMENU
// Aplicaciæn : Ventas y Cuentas por Pagar
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lConfig)
  LOCAL oBtn,oFontB,oTable,oBrw,oCol,oFontBrw,oFontB,aItems:={},aBtn:={}
  LOCAL nPorVar,I,nTotal:=0,oBrush,U,nLin,nCol,oBtn,oFontBtn
  LOCAL nBntAlto:=32,nBtnAncho:=32,aPagina:={},aGrupo:={},aLine:={},aBtnFile:={}
  LOCAL nPageIni:=1,cTipDoc:="TIK",lMesas:=.F.,cPrecio:="A",cCodCli:=STRZERO(0,10),cCodVen:=STRZERO(1,6)
  LOCAL oChk,oBrush,nCols:=5,nRows:=4,cCodMon:="Bs",cCenCos:=STRZERO(1,8)
  LOCAL nCajaFondo:=0.00,cTipPrecio:="A",cTipDev:="DEV"
  LOCAL lCierre   :=.F.,lAbierto:=.F.,lImpFis:=.F.,cCodTra:="S000",cCodAlm:="",cCodCaja:=oDp:cCaja
  LOCAL lVendedor :=.F.


  DEFAULT lConfig:=.F.

  MsgRun("Cargando Par·metros del POS ","Espere....",{||;
          EJECUTAR("DISPRUN","AdaptaPro","Punto de Venta"),;
          aPagina:=EJECUTAR("DPPOSLEEINI","DP\DPPOS01.INI",nRows,nCols)})

//  IF !lAbierto
//    ? "PUNTO DE VENTA NO ESTA ABIERTO"
//  ENDIF 



  IF EMPTY(aPagina)
    RETURN .T.
  ENDIF

//  IF !MYSQLGET("DPCAJA","CAJ_CODIGO","CAJ_CODIGO"+GetWhere("=",cCodCaja))==cCodCaja 
//      MensajeErr("Cædigo de Caja ["+cCodCaja+"] no Existe, Serﬂ Asumido el Cædigo de Caja: "+oDp:cCaja+CRLF+;
//                 "Para definir caja del Usuario, Utilice la Opciæn: Privilegios del Usuario" )
//     
//      cCodCaja:=oDp:cCaja
//  ENDIF
  
  // Descripciæn,Total,cantidad,precio,Unidad de Medida,codigo,IVA,cTipIva 
  // AADD(aItems,{SPACE(50),0,0,0,SPACE(6),SPACE(20),0,"",0})
  aItems:=POSREINI(.F.)

  DEFINE FONT oFontBrw NAME "Verdana" SIZE 0, -12 
  DEFINE FONT oFontB   NAME "Verdana" SIZE 0, -12 BOLD
  DEFINE FONT oFontBtn NAME "MS Sans Serif" SIZE 0, -06 ITALIC

  // 20-08-2008 Marlon Ramos (Se agrega el nombre de la impresora; ∑til cuando una marca tiene mﬂs de un mædelo Ej.: Epson 220AF, PF-200,etc)
   //DPEDIT():New("Punto de Venta","DPFRMPOS03.EDT","oPos",.F.)
  DPEDIT():New("Punto de Venta  .:"+ALLTRIM(oDp:cImpFiscal)+":.","DPFRMPOS01.EDT","oPos",.F.)

  oPos:cFileChm   :="CAPITULO3.CHM"
  oPos:lConfig    :=lConfig
  oPos:aPagina    :=ACLONE(aPagina)
  oPos:cTopic     :="00M10"
  oPos:aItems     :=ACLONE(aItems)
  oPos:cPicture   :="99,999,999,999.99"
  oPos:cPicItem   :="99,999,999.99"
  oPos:cCodInv    :=SPACE(20)
  oPos:nCantid    :=1.00
  oPos:nBruto     :=0.00
  oPos:nPrecio    :=0.00
  oPos:nIva       :=0.00
  oPos:nNeto      :=0.00
  oPos:cMsg1      :=SPACE(40)
  oPos:cMsg2      :=SPACE(40)
  oPos:aBtnBmp    :={}
  oPos:lCantid    :=.F.     // Requiere Cantidad
  oPos:lTikWait   :=.F.
  oPos:lMesas     :=lMesas  // Requiere Cantidad
  oPos:cTipDoc    :=cTipDoc 	
  oPos:cPrecio    :=cPrecio
  oPos:cTipDev    :=cTipDev
  oPos:cFileBmp   :="DPPOSDP.BMP"
  oPos:nMtoDev    :=0  // Devoluciæn
  oPos:cTicketDev :="" // Ticket Devoluciæn
  oPos:nMtoVta    :=0
  oPos:nMtoDev    :=0
  oPos:dFchVen    :=CTOD("")
  oPos:nCapa      :=0
  oPos:cLote      :=""
  oPos:cZonaNL    :=SQLGET("DPCLIENTES","CLI_ZONANL","CLI_CODIGO"+GetWhere("=",STRZERO(0,10)))
  oPos:cMsgCod    :=""
  oPos:lDpPosCli  :=.F.
  oPos:cColor     :=""
  oPos:oGrid      :=NIL
  oPos:aTallas    :={}
  oPos:lResItem    :=.T. // Resumen por Item JN 02/06/2013

 // oPos:cZonaNL :="L"
 // ? oPos:cZonaNL

  // 16-12-2008 Marlon Ramos (Ejecutar Programas para Impresoras Fiscales DpPos01)
     oDp:lDpPos02:=.F.  
  // Fin 16-12-2008 

  // 01-09-2008 Marlon Ramos
     IF Empty(oDp:cImpFiscal) .OR. "NINGUNA"$UPPE(oDp:cImpFiscal) 
        MensajeErr("No hay Impresora Configurada para el Punto de Venta"+CRLF+"Configure una desde Definiciones del Sistema.")
        Return .F.
     ENDIF
  // Fin 01-09-2008 Marlon Ramos

  IF "BEMA"$UPPE(oDp:cImpFiscal) 
    oPos:cFileBmp   :="DPPOSBEMA.BMP"
  ENDIF

  IF "BMC"$UPPE(oDp:cImpFiscal) 
    oPos:cFileBmp   :="DPPOSBMC.BMP"
  ENDIF

  IF "EPSON"$UPPE(oDp:cImpFiscal) 
    oPos:cFileBmp   :="DPPOSEPSON.BMP"
  ENDIF

  // 19-09-2008 Marlon Ramos (Inclusiæn de las Impresoras Samsung)
     IF "SAMSUNG"$UPPE(oDp:cImpFiscal) 
        oPos:cFileBmp   :="DPPOSSAMSUNG.BMP"
     ENDIF
  // Fin 19-09-2008 Marlon Ramos

  // 27-10-2009 Marlon Ramos (Inclusiæn de las Impresoras Aclas)
     IF "ACLAS"$UPPE(oDp:cImpFiscal) 
        oPos:cFileBmp   :="DPPOSACLAS.BMP"
     ENDIF
  // Fin 27-10-2009 Marlon Ramos

  // 29-10-2009 Marlon Ramos (Inclusiæn de las Impresoras Okidata)
     IF "OKIDATA"$UPPE(oDp:cImpFiscal) 
        oPos:cFileBmp   :="DPPOSOKIDATA.BMP"
     ENDIF
  // Fin 29-10-2009 Marlon Ramos

  // 24-11-2009 DataPro (Inclusion de las Impresoras STAR HSP-7000)
     IF "STAR"$UPPE(oDp:cImpFiscal) 
        oPos:cFileBmp   :="DPPOSSAMSUNG.BMP"
     ENDIF
  // Fin 24-11-2009 DataPro

  // 18-09-2008 Marlon Ramos
     //SET KEY VK_F3 TO oPos:FUNF3()
     SET KEY VK_F4 TO oPos:FUNF4()
     //SET KEY VK_F6 TO oPos:FUNF6()
  // Fin 18-09-2008 Marlon Ramos

  oPos:aDataWait  :={}
  oPos:cMsgInv    :="Introduzca el CÛdigo del Producto"
  oPos:cMsgErr    :=SPACE(40)
  oPos:cIva       :=""     // IVA del Producto
  oPos:nIva       :=0.00
  oPos:nDocOtros  :=0.00
  oPos:nDocDesc   :=0.00
  oPos:nBemaDesc  :=0.00
  oPos:nRows      :=nRows
  oPos:nCols      :=nCols
  oPos:nIvaItem   :=0.00 // Iva por Item
  oPos:dFecha     :=oDp:dFecha
  oPos:cCodSuc    :=oDp:cSucursal
  oPos:cCodCli    :=cCodCli
  oPos:cCodVen    :=cCodVen
  oPos:lCodVen    :=lVendedor
  oPos:cCodVenIni :=cCodVen
  oPos:cCodMon    :=cCodMon
  oPos:cCenCos    :=cCenCos
  oPos:cCodTra    :=cCodTra // CÛdigo de TransacciÛn
  oPos:lImpFis    :=lImpFis // Indica si Existe Impresora Fiscal
  oPos:cCodAlm    :=IIF(Empty(cCodAlm),oDp:cAlmacen,cCodAlm) // Almacen de Trabajo
  oPos:cUndMed    :=""     // Unidad de Medida en la Venta
  oPos:nCxUnd     :=0
  oPos:nEfectivo  :=0 
  oPos:nDebito    :=0  
  oPos:cBcoDeb    :="" 
  oPos:cMarcaTD   :=""
  oPos:cPosTC     :=""

  oPos:cBcoTCT    :=""
  oPos:cTarCT     :=""
  oPos:nTarCT     :=0
  oPos:cMarcaCT   :=""
  oPos:cPosCT     :=""

  oPos:nCredito   :=0  
  oPos:cCredito   :=""
  oPos:cBcoCre    :=""
  oPos:cMarcaTC   :=""
  oPos:cPosTC     :=""
    
  oPos:nRecibe    :=0      
  oPos:nResiduo   :=0
  oPos:nCesta     :=0 // Pago con Cesta
  oPos:nVuelto    :=0      
  oPos:nCanTot    :=0 // Cantidad Total de Productos
  oPos:aDataBal   :={} // Data de la Balanza
  oPos:cCodCaja   :=cCodCaja
  oPos:cTipPrecio :=cTipPrecio
  oPos:lPrecioIva :=SQLGET("DPPRECIOTIP","TPP_INCIVA","TPP_CODIGO"+GetWhere("=",cTipPrecio))  
  oPos:nPag       :=nPageIni
  oPos:nCheque    :=0
  oPos:nRecibe    :=0
  oPos:cBanco     :=""
  oPos:cCheque    :=""
  oPos:cCupon     :="" // Cupon de la Impresora Fiscal
  oPos:nDescxI    :=0  // Descuento por Item
  oPos:dFechAsoc  :={} // 11-08-2008 Marlon Ramos (Utilizada por DPPOSDEVOL / TICKETEPSON / DPPOSPRINT)
  oPos:dHoraAsoc  :="" // 11-08-2008 Marlon Ramos (Utilizada por DPPOSDEVOL / TICKETEPSON / DPPOSPRINT)
  oPos:cTickAsoc  :="" // 12-09-2008 Marlon Ramos (Utilizada por DPPOSDEVOL / DPPOSPRINT)

  oTable:=OpenTable("DPCLIENTESCERO",.F.)
  oPos:SetTable(oTable)
  oTable:End()

  oTable:=OpenTable("DPDOCCLI",.F.)
  AEVAL(oTable:aFields , { |a,n| __objAddData( oPos , a[1] ) })
  oTable:End()

  oPos:lMsgBar  :=.F.

  oPos:CreateWindow()

  SetWndDefault(oPos:oDlg)

//  WndSetDefault(oPos:oDlg)
//  oPos:oDlg:oFont:=oFontBtn
//  @ 2,1 GROUP oPos:oGrupo TO 4, 21.5 PROMPT "Datos del Producto"    

  oBrw:=TXBrowse():New(oPos:oDlg )
  oBrw:SetArray( oPos:aItems ,.F.)
  oBrw:lHScroll := .F.
  oBrw:lVScroll := .F.
  oBrw:nFreeze  := 1
  oBrw:oFont    :=oFontBrw
//  oBrw:nHeaderLines:= 2
  oBrw:nDataLines  := 2
  oBrw:lFooter     :=.F.
  oBrw:lHeader     :=.F.
//  oBrw:SETBRUSH(oBrush)

  oCol:=oBrw:aCols[1]
//  oCol:cHeader:="Descripciæn"
  oCol:nWidth :=250
  oCol:oHeaderFont:=oFontB

  oCol:=oBrw:aCols[2]
  oCol:nWidth       := 110+15
  oCol:oHeaderFont  := oFontB
  oCol:cEditPicture := oPos:cPicture
  oCol:bStrData     := {|oBrw|oBrw:=oPos:oBrwItem,FDP(oBrw:aArrayData[oBrw:nArrayAt,2],oPos:cPicItem)}
  oCol:bClrStd      := {|oBrw|oBrw:=oPos:oBrwItem,{IIF(oBrw:aArrayData[oBrw:nArrayAt,2]<0,CLR_HRED,CLR_HBLUE), iif( oBrw:nArrayAt%2=0,16770764,16774636 ) } }
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT

  oBrw:bClrStd      := {|oBrw|oBrw:=oPos:oBrwItem,{CLR_BLUE, iif( oBrw:nArrayAt%2=0,16770764,16774636 ) } }
  oBrw:bClrHeader   := {|oBrw|oBrw:=oPos:oBrwItem,{CLR_BLUE,12582911}}
  oBrw:bClrHeader   := {|| { CLR_WHITE,16744448}}

  oBrw:CreateFromCode()
  oPos:oBrwItem:=oBrw

  @ 1.0,29.0 BMPGET oPos:oCodInv  VAR oPos:cCodInv ;
             VALID oPos:ValCodigo();
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oDpLbx:=DpLbx("DPINVPOS") , oDpLbx:GetValue("INV_CODIGO",oPos:oCodInv)); 
             WHEN 1=1;
             SIZE 80,10

     oPos:oCodInv:bKeyDown:={|nKey|oPos:PosKeyDown(nKey)}

//  n{|nKey|IIF(!oPos:lCantid .AND. (nKey=13 .OR. nKey=9), oPos:SaveVenta(!oPos:lCodVen),NIL )}


  @ 10,38 GET oPos:oCantid VAR oPos:nCantid PICTURE oDp:cPictCanUnd RIGHT;
          VALID  oPos:ValCantid() .AND. oPos:SaveVenta(!oPos:lCodVen);
          WHEN oPos:lCantid

  @ 1.0,29.0 BMPGET oPos:oCodVen  VAR oPos:cCodVen ;
             VALID oPos:ValCodVen();
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oDpLbx:=DpLbx("DPVENDEDOR") , oDpLbx:GetValue("VEN_CODIGO",oPos:oCodVen)); 
             WHEN .T. ;
             SIZE 80,10

//             WHEN oPos:lCodVen 

  nBntAlto :=30
  nBtnAncho:=30
  aGrupo   :=aPagina[nPageIni]
  oFontBtn:=NIL

//VIEWARRAY(aGrupo)

  FOR I=1 TO oPos:nRows
    nLin :=20 + (nBntAlto*(I-1))
    aBtn :={}
    aLine:=aGrupo[i]

    FOR U=1 TO oPos:nCols
      nCol:=210+ (nBtnAncho*(U-1))
      aBtnFile:=aLine[U,2]

      @ nLin, nCol SBUTTON oBtn PIXEL;
                   SIZE nBntAlto-2,nBtnAncho-2 FONT oFontBtn;
                   FILE "BITMAPS\"+aBtnFile[1],"BITMAPS\"+aBtnFile[2],"BITMAPS\"+aBtnFile[3] BORDER;
                   TOP PROMPT aLine[U,1];
                   COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
                   ACTION 1=1

      oBtn:cToolTip:=aLine[U,6]
      oBtn:cMsg:=aLine[U,6]

      AADD(aBtn,oBtn)

      // 17-08-2008 Marlon Ramos (Mostrar tecla de funciæn asociada al botæn)
         //oBtn:SetText( aLine[U,1], 42, 2, nil, nil , nil )
         oBtn:SetText( IIF(LEFT(aLine[U,1],1)="F" .AND. VAL(SUBSTR(aLine[U,1],2,1))>0,LEFT(aLine[U,1],3),"")+CRLF+CRLF+CRLF+RIGHT(aLine[U,1],LEN(aLine[U,1])-IIF(LEFT(aLine[U,1],1)="F" .AND. VAL(SUBSTR(aLine[U,1],2,1))>0,3,0)), 5, 2, nil, nil , nil )
      // Fin 17-08-2008 Marlon Ramos 

  //    oBtn:SetFont(oFont)
  //    oBtn:SetText( aBtn[U,2], 40, 5, nil, nil,nil )

      oBtn:bWhen  :=aLine[U,3]
      IF oPos:lConfig
        oBtn:bAction:=BloqueCod([oPos:SETBONTON(]+["]+aLine[U,7]+[")])
      ELSE
        oBtn:bAction:=aLine[U,4]
      ENDIF
   
    NEXT U
   
    AADD(oPos:aBtnBmp,aBtn)
  NEXT I

  @ 3.0, 210 SBUTTON oBtn PIXEL;
             SIZE 30,18 FONT oFontB;
             FILE "BITMAPS\XTOP.BMP";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oPos:PAGSKIP(-1)

  @ 3.0, nCol SBUTTON oBtn PIXEL;
              SIZE 30,18 FONT oFontB;
              FILE "BITMAPS\xFIN.BMP";
              COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
              ACTION oPos:PAGSKIP(1)

  @ 3.0, 210 SBUTTON oPos:oBtnPagUp PIXEL;
             SIZE 20,28 FONT oFontB;
             FILE "BITMAPS\BOTONUP.BMP";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_GRAY, 1 };
             ACTION oPos:oBrwItem:GoUp()

  oPos:oBtnPagUp:cToolTip:="Pﬂgina Siguiente"

  @ 3.0, 210 SBUTTON oPos:oBtnPagDown PIXEL;
             SIZE 20,28 FONT oFontB;
             FILE "BITMAPS\BOTONDOWN.BMP";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_GRAY, 1 };
             ACTION oPos:oBrwItem:GoDown()

  oPos:oBtnPagDown:cToolTip:="Pﬂgina Anterior"

  oPos:Activate({||oPos:PAGBARRA()})
RETURN NIL


FUNCTION PrecioItem(nAt,nPrecio)
  LOCAL oBrw:=oPos:oBrwItem
 
  // 29-07-2008 Marlon Ramos oBrw:aArrayData[nAt,02]:=nPrecio
//  oBrw:aArrayData[nAt-IIF(EMPTY(oBrw:aArrayData[nAt,1]),1,0),02]:=nPrecio
  oBrw:aArrayData[nAt-IIF(EMPTY(oBrw:aArrayData[nAt,1]),1,0),04]:=nPrecio

//  IF "BMC"$UPPE(oDp:cImpFiscal) // Cﬂlculo especial para BMC
  //   //oBrw:aArrayData[nAt,02]:=ROUND(((oPos:nPrecio)-PORCEN(oPos:nPrecio,oPos:nDescxI))*(oPos:nIvaItem/100+1),2)*oPos:nCantid - ROUND((oPos:nPrecio-PORCEN(oPos:nPrecio,oPos:nDescxI))*oPos:nCantid/100*oPos:nIvaItem,2)
    // oBrw:aArrayData[nAt-IIF(EMPTY(oBrw:aArrayData[nAt,1]),1,0),02]:=ROUND(nPrecio*oBrw:aArrayData[nAt-IIF(EMPTY(oBrw:aArrayData[nAt,1]),1,0),03],2)
//  ELSE
  //   //oBrw:aArrayData[nAt,02]:=ROUND((oPos:nPrecio*oPos:nCantid)-PORCEN(oPos:nPrecio*oPos:nCantid,oPos:nDescxI),2)
     oBrw:aArrayData[nAt-IIF(EMPTY(oBrw:aArrayData[nAt,1]),1,0),02]:=ROUND(nPrecio*oBrw:aArrayData[nAt-IIF(EMPTY(oBrw:aArrayData[nAt,1]),1,0),03],2)
//  ENDIF


  oBrw:DrawLine(.T.)
  oPos:Calcular()

  oBrw:Refresh(.T.)
  oBrw:GoBottom(.T.)

  oDlg:End()
RETURN

FUNCTION ImportTik()
  LOCAL cNumero:=SPACE(10),oDlg,oRadio,nRadio,cTipDoc:=IIF(nRadio=1,"PED","TIK")
  LOCAL cMap:=MYSQLGET("DPUSUARIOS","OPE_MAPMNU","OPE_NUMERO"+GetWhere("=",oDp:cUsuario))

//  IF cMap="ADM"

    DEFINE DIALOG oDlg TITLE "Importar Documento" FROM 0,0 TO 8,33

    @ 0.5,1 SAY "Numero del Documento :" 
    @ 1.5,1 GET cNumero SIZE 50,10 VALID CERO(cNumero)

    @ 2.5,12 BUTTON "Aplicar" SIZE 22,12 ACTION oPos:IMPORTDOC(cNumero,nRadio)

    @ 2.5,17 BUTTON "Cerrar"  SIZE 22,12 ACTION oDlg:End()

    @ 0.5,10.5 RADIO oRadio VAR nRadio;
               ITEMS "Pedido","Devolucion";
               SIZE 60,12;
               COLOR NIL,oDp:nGris 

    ACTIVATE DIALOG oDlg CENTERED

//  EJECUTAR("DPPOSUSUARIO",oPos)
//  ELSE
//  MsgInfo("Acceso Restringido","Advertencia")
//  ENDIF

RETURN

FUNCTION IMPORTDOC(cNumero,nRadio)
  LOCAL cTipDoc:=IIF(nRadio=1,"PED","TIK")

  oPos:ImportTicket(cNumero,cTipDoc)
  oDlg:End()
RETURN 

FUNCTION CAMB_PRECIO(lPrec)
  LOCAL nMonto:=0.00,oDlg,oRadio,nRadio
  LOCAL cMap:=MYSQLGET("DPUSUARIOS","OPE_MAPMNU","OPE_NUMERO"+GetWhere("=",oDp:cUsuario))

  IF oPos:nNeto<0
    oPos:SetMsgErr("Debe Concluir la Devoluciæn")
    RETURN .F.
  ENDIF

  IF cMap="ADM"
    DEFINE DIALOG oDlg TITLE "Cambia Precio x Renglon" FROM 0,0 TO 8,33

    @ 0.5,1 SAY "Monto :" 
    @ 1.5,1 GET nMonto SIZE 50,10 RIGHT PICTURE "999,999,999.99"


    @ 2.5,12 BUTTON "Aplicar" SIZE 22,12 ACTION oPos:PrecioItem(oPos:oBrwItem:nArrayAt,nMonto)

    @ 2.5,17 BUTTON "Cerrar"  SIZE 22,12 ACTION oDlg:End()

    ACTIVATE DIALOG oDlg CENTERED

//    EJECUTAR("DPPOSUSUARIO",oPos)
  ELSE
    MsgInfo("Acceso Restringido","Advertencia")
  ENDIF
RETURN

FUNCTION DescItem(nAt,nDesc)
  LOCAL oBrw:=oPos:oBrwItem
  LOCAL aData:=oPos:oBrwItem:aArrayData

  nAt:=nAt-IIF(EMPTY(oBrw:aArrayData[nAt,1]),1,0)  // 21-07-2008 Marlon Ramos
  // 21-07-2008 oBrw:aArrayData[nAt,02]:=(oBrw:aArrayData[nAt,04]*oBrw:aArrayData[nAt,03])-PORCEN(oBrw:aArrayData[nAt,04]*oBrw:aArrayData[nAt,03],nDesc) 
  oBrw:aArrayData[nAt,02]:=(oBrw:aArrayData[nAt,04]*oBrw:aArrayData[nAt,03])-ROUND(PORCEN(oBrw:aArrayData[nAt,04]*oBrw:aArrayData[nAt,03],nDesc),2) 
  oBrw:aArrayData[nAt,05]:=IIF(nDesc<>0,ALLTRIM(FDP(nDesc,"99"))+" % Desc","0 %")
  oBrw:aArrayData[nAt,13]:=nDesc
  //viewarray(oPos:oBrwItem:aArrayData)
  oBrw:aArrayData:Refresh(.T.)
  CursorWait()

  oBrw:DrawLine(.T.)
  oPos:Calcular()

  oBrw:Refresh(.T.)
  oBrw:GoBottom(.T.)
RETURN

FUNCTION DESC_TOTAL(lDesc)
  LOCAL nMonto:=0,oDlg,oRadio,nRadio
  LOCAL cMap:=MYSQLGET("DPUSUARIOS","OPE_MAPMNU","OPE_NUMERO"+GetWhere("=",oDp:cUsuario))

  IF oPos:nNeto<0
    oPos:SetMsgErr("Debe Concluir la Devoluciæn")
    RETURN .F.
  ENDIF

  IF cMap="ADM"
    // 13-06-2008 Marlon Ramos (Evitar descuentos dobles)
       IF oPos:nDocDesc > 0
          MensajeErr("Ya hay un Descuento Activo de: "+TRANSFORM(oPos:nDocDesc,"999%"))
          Return
       ENDIF
    // Fin 13-06-2008 Marlon Ramos
 
    DEFINE DIALOG oDlg TITLE "Asignar Descuento a la Factura" FROM 0,0 TO 8,33

    @ 0.5,1 SAY "Descuento :" 


    /* 13-06-2008 Marlon Ramos (Evitar que coloquen descuentos de mas de tres d›gitos)
      @ 1.5,1 GET nMonto SIZE 30,10
      */
      @ 1.5,1 GET nMonto PICTURE "999" SIZE 20,10 
    // Fin 13-06-2008 Marlon Ramos


    @ 2.5,12 BUTTON "Aplicar" SIZE 22,12 ACTION APLI_DESC(nMonto,nRadio)
    @ 2.5,17 BUTTON "Cerrar"  SIZE 22,12 ACTION oDlg:End()
/* ORIGINAL
    @ 0.5,10.5 RADIO oRadio VAR nRadio;
               ITEMS "Absoluto (Monto)","Relativo (%)","X Item";
               SIZE 60,12;
               COLOR NIL,oDp:nGris 
*/
    @ 0.5,10.5 RADIO oRadio VAR nRadio;
               ITEMS "Del total (%)","De Item (%)";
               SIZE 60,12;
               COLOR NIL,oDp:nGris 
    ACTIVATE DIALOG oDlg CENTERED

//    EJECUTAR("DPPOSUSUARIO",oPos)
  ELSE
    MsgInfo("Acceso Restringido","Advertencia")
  ENDIF
RETURN

FUNCTION APLI_DESC(nMonto,nRadio)
 
  // 13-06-2008 Marlon Ramos (Evitar descuentos de mﬂs del 100%)
  IF nMonto > 100 .Or. nMonto < 1 
     MensajeErr("El Descuento debe estar en el rango de 1% a 100%")
     Return .F.
  ENDIF
  // Fin 13-06-2008 Marlon Ramos 
  
  IF nRadio=1
    oPos:nDocDesc:=nMonto
    oPos:nBemaDesc:=oPos:nDocDesc
  ENDIF

  IF nRadio=2
    oPos:DescItem(oPos:oBrwItem:nArrayAt,nMonto)
    oDlg:End()
  ENDIF

  //?"oPos:nDocDesc",oPos:nDocDesc,"oPos:nDocOtros",oPos:nDocOtros
  //?"oPos:nBruto:",oPos:nBruto
  //?"oPos:nIvA:", oPos:nIva
  IF oPos:nDocDesc<>0 .OR. oPos:nDocOtros<>0
    DO CASE
	 CASE nRadio=1
  	   oPos:nBruto:=oPos:nBruto-ROUND(PORCEN(oPos:nBruto,oPos:nDocDesc),2)
        //oPos:nBruto:=REDONDEA(oPos:nBruto-(oPos:nBruto/100*oPos:nDocDesc),2)

  	   oPos:nIvA  :=oPos:nIva-ROUND(PORCEN(oPos:nIva,oPos:nDocDesc),2)
        //oPos:nIvA  :=ROUND(oPos:nIva-(oPos:nIva/100*oPos:nDocDesc),2)
  	   //?"1",oPos:nIvA ,"oPos:nBruto:",oPos:nBruto
  	   //oPos:nIvA  :=oPos:nIva-REDONDEA(oPos:nIva/100*oPos:nDocDesc)
  	   //?"2",oPos:nIvA 
    ENDCASE

  /* 02-06-2008 Marlon Ramos (Se redondea para Evitar descuadres)
    oPos:nNeto    :=oPos:nBruto+oPos:nIva
  */
  oPos:nNeto :=STR(oPos:nBruto+ROUND(oPos:nIva,2),12,5)
  oPos:nNeto :=VAL(LEFT( oPos:nNeto,IIF( AT(".",oPos:nNeto)>0,AT(".",oPos:nNeto)-1,LEN(oPos:nNeto) ) )+IIF( AT(".",oPos:nNeto)>0, SUBSTR( oPos:nNeto,AT(".",oPos:nNeto),3 ),"" ))

  // FIN 02-06-2008 Marlon Ramos 

    oPos:oBruto:Refresh(.t.)
    oPos:oIva:Refresh(.t.)
    oPos:oNeto:Refresh(.t.)
    oPos:oDocDesc:Refresh(.t.)   //12-06-2008 Marlon Ramos (Reflejar el descuento en pantalla)
   //?"oPos:nBruto:",oPos:nBruto
   //?"oPos:nIvA:", oPos:nIva
   //?"oPos:nNeto:",oPos:nNeto
  ENDIF

  oDlg:End()
RETURN

FUNCTION PAGBARRA()
  // LOCAL oCursor,oBar,oBtn,oFont,oFontBrw,oFontT

  LOCAL nClrBlink := CLR_YELLOW   // blinking color
  LOCAL nInterval := 500-100      // blinking interval in milliseconds
  LOCAL nStop     := 0            // blinking limit to stop in milliseconds
  LOCAL oFontB,oFontT,oCol

  DEFINE FONT oFontB NAME "Times New Roman"   SIZE 0, -14 BOLD
  DEFINE FONT oFontT NAME "Times New Roman"   SIZE 0, -16 BOLD

  // Controles para Mensajes
  @26.8, 71 STSAY oPos:oMsgInv PROMPT oPos:cMsgInv;
            SIZE 300, 20  FONT oFontB;
            COLORS CLR_HRED

  @28.7,71 STSAY oPos:oMsgErr PROMPT oPos:cMsgErr OF oPos:oDlg;
            COLORS CLR_HRED SIZE 300, 19 FONT oFontB ;
            SHADED;
            BLINK nClrBlink, nInterval, nStop  

  @23.2, 70 STSAY oPos:oCodText PROMPT "CÛdigo  F6";
            SIZE 100, 20  FONT oFontB;
            COLORS CLR_BLUE

  @23.2,101 STSAY oPos:oCantText PROMPT "Cantidad";
            SIZE 100, 20  FONT oFontB;
            COLORS CLR_BLUE

  @23.2,115 STSAY oPos:oCantText PROMPT "Vendedor";
            SIZE 100, 20  FONT oFontB;
            COLORS CLR_BLUE

  /* 12-06-2008 Marlon Ramos (Reflejar el descuento en pantalla)
     @ 1.1, 38 SAY oPos:oBruto PROMPT FDP(oPos:nBruto,"999,999,999.99");
            RIGHT;
            SIZE 160, 20  FONT oFontT;
            COLOR CLR_HGREEN,CLR_BLACK
     */
     @ 1.1, 50 SAY oPos:oBruto PROMPT FDP(oPos:nBruto,"999,999,999.99");
            RIGHT;
            SIZE 88, 20  FONT oFontT;
            COLOR CLR_HGREEN,CLR_BLACK
  // Fin 12-06-2008 Marlon Ramos (Reflejar el descuento en pantalla)

  @ 2.3, 38 SAY oPos:oIva PROMPT FDP(oPos:nIva,"999,999,999.99");
            RIGHT;
            SIZE 160, 20  FONT oFontT;
            COLOR CLR_HGREEN,CLR_BLACK

  @ 3.6, 38 SAY oPos:oNeto PROMPT FDP(oPos:nNeto,"999,999,999.99");
            RIGHT;
            SIZE 160, 20  FONT oFontT;
            COLOR CLR_HGREEN,CLR_BLACK


  //12-06-2008 Marlon Ramos (Reflejar el descuento en pantalla)
    @ 1.1, 37 SAY "Dsct:" ;
            SIZE 34, 20  FONT oFontT;
            COLOR CLR_HGREEN,CLR_BLACK

    @ 1.1, 43 SAY oPos:oDocDesc PROMPT FDP(oPos:nDocDesc,"999");
            RIGHT;
            SIZE 25, 20  FONT oFontT;
            COLOR CLR_HGREEN,CLR_BLACK
    @ 1.1, 47 SAY "%" ;
            SIZE 20, 20  FONT oFontT;
            COLOR CLR_HGREEN,CLR_BLACK
  //Fin 12-06-2008 Marlon Ramos 

/*
  @ 7, 48 SCROLLBAR oPos:oScr SIZE 40,100

  oPos:oBrwItem:lVScroll:=.T.
  oPos:oBrwItem:oVScroll:=oPos:oScr
*/

//  oBrw:oVScroll:Move(0,0,200,200,.T.)
//  oPos:BtnRefresh(2)
RETURN .T.

// Seleccionar Forma de Pago
FUNCTION SELFORMAPAG()
  LOCAL oBrw:=oPos:oBrwItem
RETURN .T.

FUNCTION Recibido()
RETURN .T.

// Se encarga de Grabar la Venta
FUNCTION SAVEVENTA(lSave)
  LOCAL oBrw :=oPos:oBrwItem,lFound:=.F.
  LOCAL nAt  :=LEN(oBrw:aArrayData)
  LOCAL aLine:=oBrw:aArrayData[nAt]
  LOCAL cLine,cTotal,nLen,nPrecio:=0

  IF EMPTY(oPos:cCodInv) 
    RETURN .F.
  ENDIF

  // JN 02/06/2013
  IF oPos:lResItem .AND. ASCAN(oBrw:aArrayData,{|a,n| a[06]=oPos:cCodInv})>0

    nAt   :=ASCAN(oBrw:aArrayData,{|a,n| a[06]=oPos:cCodInv})
    IF nAt>0
      oPos:nCantid:=oBrw:aArrayData[nAt,03]+oPos:nCantid 
      lFound      :=.T.
      nPrecio:=oPos:GETPRECIOTAB()

      IF nPrecio>=0
        oPos:nPrecio:=nPrecio
      ENDIF
 
      ? nPrecio,"nPrecio"
    ELSE
      nAt:=1
    ENDIF

  ENDIF

  oPos:dFchVen:=CTOD("")
  oPos:cMsgCod:="  no Existe "

  IF !oPos:VALCODIGO(.T.)

    IF Empty(oPos:aDataBal)
      oPos:SetMsgErr("Producto ["+ALLTRIM(oPos:cCodInv)+"],"+oPos:cMsgCod)
      oPos:SetMsgInv("")
    ENDIF

    DpFocus(oPos:oCodInv)

    oPos:oCodInv:Refresh() 

    RETURN .F.

  ENDIF

  IF !Empty(oPos:dFchVen) .AND. oPos:dFchVen<=oDp:dFecha 

     oPos:SetMsgErr("Producto ["+ALLTRIM(oPos:cCodInv)+"], Vencido ["+DTOC(oPos:dFchVen)+"]")
     oPos:SetMsgInv("")
     DpFocus(oPos:oCodInv)
     oPos:oCodInv:Refresh() 

    RETURN .F.

  ENDIF

  oPos:SetMsgErr("") // Borra el Mensaje de Error

  IF !lSave
    RETURN .T.
  ENDIF

  AEVAL(aLine,{|a,n|aLine[n]:=CTOEMPTY(a)})
  oPos:nBruto:=0  // Monto Bruto

  //29-08-2008 Colocar unidad de Medida oBrw:aArrayData[nAt,01]:=oPos:cCodInv+" "+ALLTRIM(FDP(oPos:nCantid,"999,999,999.999",.F.))+" X "+;
                           ALLTRIM(FDP(oPos:nPrecio,"999,999,999.99"))+CRLF+oPos:cMsgInv
  oBrw:aArrayData[nAt,01]:=oPos:cCodInv+" "+ALLTRIM(FDP(oPos:nCantid,"999,999,999.999",.F.))+" "+ALLTRIM(oPos:cUndMed)+" X "+;
                           ALLTRIM(FDP(oPos:nPrecio,"999,999,999.99"))+CRLF+oPos:cMsgInv

  //12-06-2008 Marlon Ramos oBrw:aArrayData[nAt,02]:=(oPos:nPrecio*oPos:nCantid)-PORCEN(oPos:nPrecio*oPos:nCantid,oPos:nDescxI)
  //16-07-2008 Marlon Ramos oBrw:aArrayData[nAt,02]:=ROUND((oPos:nPrecio*oPos:nCantid)-PORCEN(oPos:nPrecio*oPos:nCantid,oPos:nDescxI),2)
  IF "BMC"$UPPE(oDp:cImpFiscal) // Cﬂlculo especial para BMC
     //oBrw:aArrayData[nAt,02]:=ROUND((oPos:nPrecio*oPos:nCantid)-PORCEN(oPos:nPrecio*oPos:nCantid,oPos:nDescxI),2)
     //?"Aqui",ROUND((oPos:nPrecio-PORCEN(oPos:nPrecio,oPos:nDescxI))*oPos:nCantid/100*oPos:nIvaItem,2)
     oBrw:aArrayData[nAt,02]:=ROUND(((oPos:nPrecio)-PORCEN(oPos:nPrecio,oPos:nDescxI))*(oPos:nIvaItem/100+1),2)*oPos:nCantid - ROUND((oPos:nPrecio-PORCEN(oPos:nPrecio,oPos:nDescxI))*oPos:nCantid/100*oPos:nIvaItem,2)
  ELSE
     oBrw:aArrayData[nAt,02]:=ROUND((oPos:nPrecio*oPos:nCantid)-PORCEN(oPos:nPrecio*oPos:nCantid,oPos:nDescxI),2)
  ENDIF


  // Clientes en Zona Libre no Pagan IVA
  // La tasa debe ser EXCENTA
  IF oPos:cZonaNL="L"
     oPos:nIvaItem:=0
     oPos:cIva    :="EX"
  ENDIF

  oBrw:aArrayData[nAt,03]:=oPos:nCantid 
  oBrw:aArrayData[nAt,04]:=oPos:nPrecio 
  oBrw:aArrayData[nAt,06]:=oPos:cCodInv
  oBrw:aArrayData[nAt,07]:=oPos:nIvaItem
  oBrw:aArrayData[nAt,08]:=oPos:cIva
  oBrw:aArrayData[nAt,09]:=oPos:cMsgInv
  oBrw:aArrayData[nAt,10]:=oPos:cUndMed
  oBrw:aArrayData[nAt,11]:=oPos:nCxUnd
  oBrw:aArrayData[nAt,12]:=oPos:cCodVen
  oBrw:aArrayData[nAt,13]:=oPos:nDescxI
  oBrw:aArrayData[nAt,14]:=oPos:nCapa
  oBrw:aArrayData[nAt,15]:=oPos:cLote
  oBrw:aArrayData[nAt,16]:=ACLONE(oPos:aTallas)


  //viewarray(oBrw:aArrayData)
  //?"oPos:cCodVen",oPos:cCodVen
//  AADD(aItems,{SPACE(50),0,0,0,SPACE(6),"6CODIGO",7,"8CIVA","9DESCRI","10UND","11cXUnd"})

  oBrw:DrawLine(.T.)
  oPos:Calcular()

  IF !lFound
    AADD(oBrw:aArrayData,aLine)
  ENDIF

  oBrw:Refresh(.T.)
  oBrw:GoBottom(.T.)

  oPos:DISPITEM()

/*
  cLine:=LSTR(oPos:nPrecio,10,IIF(oPos:nPrecio=INT(oPos:nPrecio),0,2))+"X"+;
         LSTR(oPos:nCantid,10,IIF(oPos:nCantid=INT(oPos:nCantid),0,2))

  cTotal:="="+ALLTRIM(FDP(oPos:nNeto,"999,999,999.99"))
  nLen  :=20-LEN(cLine)
  cLine :=cLine+PADL(cTotal,nLen)

  EJECUTAR("DISPRUN",oPos:cMsgInv,cLine)
*/
  oPos:oCodInv:VarPut(SPACE(20),.T.)
  oPos:oCantid:VarPut(1,.T.)

//  oPos:oBruto:Refresh(.t.)
//  oPos:oIva:Refresh(.t.)
//  oPos:oNeto:Refresh(.t.)
//  Pos:nPrecio)+"X"+LSTR(oPos:nCantid)+" ["+LSTR(oPos:nNeto)+"]")
//  oPos:Show()

  DpFocus(oPos:oCodInv)
RETURN .T.

FUNCTION VALCODIGO(lPidPrec)
  LOCAL cCodEqui,lFound:=.F.,aData:={},I,aLine:={},cCodBar:={}
  LOCAL oBrw :=oPos:oBrwItem,nAt,nPrecio:=0,dFecha:=CTOD(""),nCol
  LOCAL nAt  :=LEN(oBrw:aArrayData)
  LOCAL cCod :="",cBar:="" // Codigo para Validar
  LOCAL aLine:=oBrw:aArrayData[nAt]

  DEFAULT lPidPrec:=.F.

  oPos:cCodEqu :=""
  oPos:cDescri :=""
  oPos:nIvaItem:=0
  oPos:ncXUnd  :=0
  oPos:aDataBal:={}

  IF EMPTY(oPos:cCodInv)
    RETURN .F.
  ENDIF

  IF oPos:nNeto<0
    oPos:SetMsgErr("Debe Concluir la DevoluciÛn")
    RETURN .F.
  ENDIF

  IF oPos:lCodVen 

    SQLGET("DPVENDEDOR","VEN_CODIGO,VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",oPos:cCodVen))

    IF !Empty(oDp:aRow)
      oPos:SetMsgInv("Vendedor "+oDp:aRow[2])
    ENDIF

  ENDIF

  /*
  // Validar no Utilizar el codigo de Barra del Producto
  */

  cCod   :=SQLGET("DPEQUIV"         ,"EQUI_CODIG","EQUI_BARRA"+GetWhere("=",oPos:cCodInv))
  cBar   :=SQLGET("DPINVCAPAPRECIOS","CAP_CODBAR","CAP_CODIGO"+GetWhere("=",cCod))

  IF !Empty(cCod) .AND. !Empty(cBar)
    oPos:cMsgCod:="Utilice CÛdigo Barra Alterno ["+ALLTRIM(cCod)+"]"
//    oPos:SetMsgErr("Utilice CÛdigo Barra Alterno ["+ALLTRIM(cCod)+"]")
    RETURN .F.
  ENDIF

  /*
  // Validar no Utilizar el codigo del Producto en Productos con Codigo de Barra Alternativo
  */

  cCod   :=SQLGET("DPINV"           ,"INV_CODIGO","INV_CODIGO"+GetWhere("=",oPos:cCodInv))
  cBar   :=SQLGET("DPINVCAPAPRECIOS","CAP_CODBAR","CAP_CODIGO"+GetWhere("=",oPos:cCodInv))

  IF !Empty(cCod) .AND. !Empty(cBar)
    oPos:cMsgCod:="Utilice CÛdigo Barra Alterno ["+ALLTRIM(cCod)+"]"
//   oPos:SetMsgErr("Utilice CÛdigo Barra Alterno ["+ALLTRIM(cCod)+"]")
    RETURN .F.
  ENDIF



  // JN, Lectura de codigo de barra, farmacia
  nPrecio:=SQLGET("DPINVCAPAPRECIOS","CAP_PRECIO,CAP_FCHVEN,CAP_CODIGO,CAP_CAPA,CAP_LOTE","CAP_CODBAR"+GetWhere("=",oPos:cCodInv))

  oPos:dFchVen:=CTOD("")
  oPos:nCapa  :=0
  oPos:cLote  :=""

 
  IF !Empty(nPrecio)
    oPos:cCodEqu:=oPos:cCodInv
    oPos:cCodInv:=oDp:aRow[3]
    oPos:dFchVen:=oDp:aRow[2]
    oPos:nCapa  :=oDp:aRow[4]
    oPos:cLote  :=oDp:aRow[5]
  ENDIF

  IF SQLGET("DPINV","INV_CODIGO,INV_DESCRI,INV_IVA","INV_CODIGO"+GetWhere("=",oPos:cCodInv))!=oPos:cCodInv

    cCodEqui:=MYSQLGET("DPEQUIV","EQUI_CODIG","EQUI_BARRA"+GetWhere("=",oPos:cCodInv))


    IF Empty(cCodEqui) .AND. !Empty(oDp:cFileBal)
      EJECUTAR("DPPOSLEEBAL")  // Lectura de Balanza Bizerba
      RETURN .F.
    ENDIF

    oPos:cCodEqu:=cCodEqui
    oPos:cCodInv:=cCodEqui

    SQLGET("DPINV","INV_CODIGO,INV_DESCRI,INV_IVA","INV_CODIGO"+GetWhere("=",oPos:cCodInv))!=oPos:cCodInv

  ENDIF

  oPos:cMsgInv :=oDp:aRow[2]
  oPos:cIva    :=oDp:aRow[3]


  IF oPos:cZonaNL="N"
     nCol:=2
  ELSE 
     nCol:=IIF(!oPos:cZonaNL="N",5,2)
  ENDIF

  oPos:nIvaItem:=EJECUTAR("IVACAL",oPos:cIva,nCol,oPos:dFecha) // IVA (Nacional o Zona Libre
  oPos:SetMsgInv(oPos:cMsgInv)

// 25-08-2008 Marlon Ramos (Pedir Precios de Venta)
   oPos:aPrecios:=ASQL("SELECT PRE_PRECIO,PRE_UNDMED,UND_CANUND,PRE_DESCUE FROM DPPRECIOS "+;
                      " INNER JOIN DPUNDMED ON PRE_UNDMED=UND_CODIGO "+;
                      " WHERE "+;
                      " PRE_CODIGO"+GetWhere("=",oPos:cCodInv)+;
                      " ORDER BY PRE_PRECIO")
//                      " AND PRE_LISTA"+GetWhere("=",oPos:cPrecio)+" ORDER BY PRE_PRECIO")

   // Asume la Unidad de Medida
   IF LEN(oPos:aPrecios)=1

   ENDIF


   IF nPrecio=0 .AND. !oPos:PIDE_PRECIO(lPidPrec)
      oPos:cMsgCod:="No tiene Precio"
      RETURN .F.
   ENDIF

  // Buscamos el Precio
  // CÛdigo Restaurado por JN 13/01/2010

  IF LEN(oPos:aPrecios)>1
      // ViewArray(oPos:aPrecios)
      oPos:nPrecio:=oPos:aPrecios[1,1] // Toma el Precio m·s Bajo
      oPos:cUndMed:=oPos:aPrecios[1,2] // Unidad de Medida
      oPos:ncXUnd :=oPos:aPrecios[1,3] // Cantidad por Grupo
      oPos:nDescxI:=oPos:aPrecios[1,4] // Descuento por Item
   ENDIF

   IF LEN(oPos:aPrecios)=1
      oPos:nPrecio:=oPos:aPrecios[1,1]
      oPos:cUndMed:=oPos:aPrecios[1,2]
      oPos:ncXUnd :=oPos:aPrecios[1,3] // Cantidad por Grupo
   ENDIF
   // Fin de RestauraciÛn
  
   // Fin 25-08-2008 Marlon Ramos 

   // JN 8/6/2011 Farmacias
   IF nPrecio>0
      oPos:nPrecio:=nPrecio
   ENDIF

   IF !Empty(SQLGET("DPINV","INV_TALLAS","INV_CODIGO"+GetWhere("=",oPos:cCodInv)))

      EJECUTAR("OITEMTALLA",oPos:cCodInv,oPos:cColor,oPos:cTipDoc,oPos:oGrid,oPos)

   ELSE

      oPos:oGrid  :=NIL
      oPos:aTallas:={}

   ENDIF
  
   oPos:PRECIOIVA() // Genera Precios con IVA Incluido

  //  ? oPos:cUndMed,"undmed"
  // Debe ubicar la Unidad de Medida Excluivas del Producto

  IF nPrecio=0 .AND. Empty(oPos:aPrecios)
//  SetMsgErr("Producto no Tiene Precio")
    oPos:cMsgCod:="Producto no Tiene Precio"
    RETURN .F.
  ENDIF

//EJECUTAR("DISPRUN",oPos:cMsgInv,LSTR(oPos:nPrecio)+"X"+LSTR(oPos:nCantid))
//  oPos:nPrecio:=SQLGET("DPPRECIOS")
 
  IF EMPTY(oPos:cCodInv)
    RETURN .F.
  ENDIF
RETURN .T.

// Cambiar el BMP del Boton
FUNCTION POSSETBMP()
  LOCAL oBtn,aFile:=ARRAY(5),aRes:=ARRAY(5)

  oBtn:=oPos:aBtnBmp[1,1]

  aFile[1]:="bitmaps\xsalir.bmp"

  oBtn:LoadBitmaps( aRes, aFile )
RETURN .T.

FUNCTION BtnRefresh(nPag)
  LOCAL nLin:=0,aPage,aGrupo,U,I,aBtn,aSize
  LOCAL oBtn,aFile:=ARRAY(oPos:nCols),aRes:=ARRAY(oPos:nCols)

  oBtn :=oPos:aBtnBmp[1,1]
  aSize:={oBtn:nWidth,oBtn:nHeight}

  DEFAULT nPag:=1

  aGrupo:=oPos:aPagina[nPag]

  oPos:nPag:=nPag

  FOR I=1 TO LEN(aGrupo)
    FOR U=1 TO LEN(aGrupo[I])

      aBtn:=aGrupo[I,U]

      IF aBtn[1]!="Nada"
        oBtn:=oPos:aBtnBmp[I,U]

//        ? oBtn:aBitMaps[2],oBtn:aBitMaps[1],aBtn[2,1]

      // 17-08-2008 Marlon Ramos (Mostrar tecla de funciæn asociada al botæn)
         //oBtn:SetText( aBtn[1], 40, 5, nil, nil,nil )
         oBtn:SetText( IIF(LEFT(aBtn[1],1)="F" .AND. VAL(SUBSTR(aBtn[1],2,1))>0,LEFT(aBtn[1],3),"")+CRLF+CRLF+CRLF+RIGHT(aBtn[1],LEN(aBtn[1])-IIF(LEFT(aBtn[1],1)="F" .AND. VAL(SUBSTR(aBtn[1],2,1))>0,3,0)), 5, 2, nil, nil , nil )
      // Fin 17-08-2008 Marlon Ramos 


//        oBtn:oFont:=oPos:oDlg:oFont
        aFile[1]:="bitmaps\"+aBtn[2,1]
        aFile[2]:="bitmaps\"+aBtn[2,2]
        oBtn:LoadBitmaps( aRes, aFile )
        oBtn:SetSize(aSize[1],aSize[2])
//        oBtn:aBitMaps[1]:=aBtn[2,1]
        oBtn:bWhen  :=aBtn[3]
        oBtn:bAction:=aBtn[4]
      ENDIF
    NEXT U
  NEXT I
RETURN .T.

FUNCTION POSCERRAR()
  ? "AQUI CIERRA"
RETURN .T.

FUNCTION POSCLIENTE()
  // 26-06-2008 Marlon Ramos (No permitir cambiar el cliente de una devoluciæn)
  IF oPos:nNeto<0
    oPos:SetMsgErr("No puede Cambiar Cliente")
    RETURN .F.
  ENDIF
  // Fin 26-06-2008 Marlon Ramos 

  EJECUTAR('DPCLIENTESCERO',oPos,NIL)
RETURN .T.

// Indica el Mensaje de Error, Cuando el Producto No Existe
FUNCTION SetMsgErr(cText)
   IF !EMPTY(oPos:cMsgErr) .AND. Empty(cText) // Vacia el Mensaje
     oPos:cMsgErr:=SPACE(40)
     oPos:oMsgErr:Hide()
     oPos:oMsgErr:Show()
     RETURN .T.
   ENDIF

   IF Empty(cText) .OR. (oPos:cMsgErr=cText)
      RETURN .T.
   ENDIF

   SndPlaySound( "SOUNDS\_LASER.WAV", 1 )
   oPos:oMsgErr:Hide()
   oPos:cMsgErr:=cText
   oPos:oMsgErr:Show()
RETURN .T.

FUNCTION SetMsgInv(cText)
  IF cText=oPos:cMsgInv
//      RETURN .T.
  ENDIF

  oPos:cMsgInv:=cText
  oPos:oMsgInv:Hide()
  oPos:oMsgInv:Show()
RETURN .T.

FUNCTION Efectivo()

    IF oPos:nNeto<=0
      oPos:SetMsgErr("No hay Venta")
      RETURN .F.
    ENDIF

    oPos:DISPTOTAL()

    IF oPos:nNeto<0
      IF !oDp:TIKLDEVEFECT
        oPos:SetMsgErr("No Puede Devolver Dinero")
        RETURN .F.
      ENDIF

    RETURN MsgNoYes("Desea Realizar Devoluciæn en Efectivo","Devolver Dinero")
  ENDIF
RETURN EJECUTAR("DPPOSEFECTIVO",oPos)

FUNCTION EFECTIVOYCESTA()
  IF oPos:nNeto<=0
    oPos:SetMsgErr("No hay Venta")
    RETURN .F.
  ENDIF

  oPos:DISPTOTAL()
RETURN EJECUTAR("DPPOSEFEYCESTA",oPos)

FUNCTION TarjetaCre(cTipo)
  IF oPos:nNeto<=0
    oPos:SetMsgErr("No hay Venta")
    RETURN .F.
  ENDIF

  oPos:DISPTOTAL()        //28-05-2008 Marlon Ramos
  EJECUTAR("DPPOSTARJETACRE",oPos)
RETURN .T.

// Pago con Cheque
FUNCTION Cheque()
  IF oPos:nNeto<=0
    oPos:SetMsgErr("No hay Venta")
    RETURN .F.
  ENDIF

  oPos:DISPTOTAL()
RETURN  EJECUTAR("DPPOSCHEQUE",oPos)

// Pago con Cesta Ticket
FUNCTION CESTATICKET()
  IF oPos:nNeto<=0
    oPos:SetMsgErr("No hay Venta")
    RETURN .F.
  ENDIF

  oPos:DISPTOTAL()
RETURN EJECUTAR("DPPOSCESTA",oPos)

FUNCTION TARDEBITO()
  IF oPos:nNeto<=0
    oPos:SetMsgErr("No hay Venta")
    RETURN .F.
  ENDIF

  oPos:DISPTOTAL()
RETURN EJECUTAR("DPPOSDEBITO",oPos)

FUNCTION ImportTicket(cNumero,cTipDoc)
  LOCAL aData,oTable,cMsgInv:="",I:=0,aImport:={}
  LOCAL oBrw :=oPos:oBrwItem
  LOCAL nAt 

  aData:=ASQL("SELECT MOV_TOTAL,MOV_CANTID,MOV_PRECIO,MOV_CODIGO,MOV_IVA,MOV_TIPIVA,0 AS INV_DESCRI,"+;
              " MOV_UNDMED,MOV_CANTID,DOC_CODVEN,MOV_DESCUE "+;
              " FROM DPMOVINV INNER JOIN DPDOCCLI ON MOV_DOCUME=DOC_NUMERO "+;
              " WHERE DOC_NUMERO"+GetWhere("=",cNumero)+;
              "       AND DOC_TIPDOC"+GetWhere("=",cTipDoc)+;
              "       AND MOV_TIPDOC"+GetWhere("=",cTipDoc))
	
  nAt  :=LEN(aData)	

  FOR I=1 TO nAt

    cMsgInv:=MYSQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",aData[I,4]))

    AADD(aImport,{aData[I,4]+" "+ALLTRIM(FDP(aData[I,2],"999,999,999.999",.F.))+" X "+;
                                 ALLTRIM(FDP(aData[I,3],"999,999,999.99"))+CRLF+cMsgInv,aData[I,1],IF(cTipDoc="TIK",aData[I,2]*(-1),aData[I,2]),+;
    aData[I,3]," ",aData[I,4],aData[I,5],aData[I,6],aData[I,7],aData[I,8],aData[I,9],aData[I,10],aData[I,11]})

    cMsgInv:=""

  NEXT I

  oPos:aImport:=ACLONE(aImport)
  oPos:TicketRestore(.T.)

//  oTable:Browse()
//  ViewArray(aImport)
RETURN

FUNCTION TicketWait()
  LOCAL lNew:=.T.

  ADEL(oPos:aDataWait)
  AEVAL(oPos:oBrwItem:aArrayData,{|a,n| IIF(a[2]>0, AADD(oPos:aDataWait,a) , NIL)  })

  oPos:lTikWait:=!oPos:lTikWait
  oPos:POSREINI(lNew)
RETURN 

FUNCTION TicketRestore(lImport)
  LOCAL aData :=oPos:aDataWait 
  LOCAL oBrw  :=oPos:oBrwItem 
  LOCAL nAt   :=LEN(oPos:oBrwItem)
  LOCAL nAt1  :=LEN(aData),aItems:={}

  IF lImport
    ASIZE(oPos:oBrwItem:aArrayData,LEN(oPos:oBrwItem:aArrayData)-1)
    AEVAL(oPos:aImport,{|a,n| IIF(a[2]>0, AADD(oBrw:aArrayData,a) , NIL)  })
    AADD(oBrw:aArrayData,{SPACE(50),0,0,0,SPACE(6),"6CODIGO",7,"8CIVA","9DESCRI","10UND","11cXUnd","12CODVEN",0})

    oPos:POSREINI(.F.)
    oPos:oBrwItem:Refresh(.T.)
    oPos:Calcular()
    oPos:aImport:=ACLONE(aItems)
  ENDIF

  IF !oPos:lTikWait .AND. !lImport

    MensajeErr("No hay Ticket en Espera")

  ELSE

    ASIZE(oPos:oBrwItem:aArrayData,LEN(oPos:oBrwItem:aArrayData)-1)
    AEVAL(aData,{|a,n| IIF(a[2]>0, AADD(oBrw:aArrayData,a) , NIL)  })
    AADD(oBrw:aArrayData,{SPACE(50),0,0,0,SPACE(6),"6CODIGO",7,"8CIVA","9DESCRI","10UND","11cXUnd","12CODVEN",0})

    oPos:POSREINI(.F.)
    oPos:oBrwItem:Refresh(.T.)
    oPos:Calcular()
    oPos:aDataWait:=ACLONE(aItems)
    oPos:lTikWait:=!oPos:lTikWait
  ENDIF

RETURN 

FUNCTION ANULA()
  IF MsgYesNo("Esta seguro de borrar la transacciæn ?","Advertencia")	
    oPos:POSREINI(.T.)
  ENDIF
RETURN

FUNCTION SaveTicket(lPrint)
RETURN EJECUTAR("DPPOSSAVE",lPrint)

FUNCTION POSREINI(lNew)
  LOCAL aItems:={}

  // 12-06-2008 Marlon Ramos AADD(aItems,{SPACE(50),0,0,0,SPACE(6),"6CODIGO",7,"8CIVA","9DESCRI","10UND","11cXUnd","12CODVEN",0})
  AADD(aItems,{SPACE(50),0.00,0.00,0.00,SPACE(6),"6CODIGO",7,"8CIVA","9DESCRI","10UND","11cXUnd","12CODVEN",0,"14NCAPA","15nLOTE",{}})

  IF lNew
    oPos:DISPFINAL()

    oPos:oBrwItem:aArrayData:=ACLONE(aItems)
    oPos:oBrwItem:nArrayAt:=1
    oPos:oBrwItem:nRowSel :=1
    oPos:oBrwItem:Refresh(.T.)

    oPos:nNeto :=0
    oPos:nBruto:=0
    oPos:nIva  :=0
    oPos:nDocDesc:=0            // 12-06-2008 Marlon Ramos

    oPos:nEfectivo  :=0     
    oPos:nRecibe    :=0      
    oPos:nVuelto    :=0      
    oPos:nCheque    :=0
    oPos:nCesta     :=0 

    oPos:cCodVen    :=oPos:cCodVenIni
    oPos:SetMsgInv("Introduzca Cædigo del Producto")

    oPos:oBruto:Refresh(.t.)
    oPos:oIva:Refresh(.t.)
    oPos:oNeto:Refresh(.t.)
    oPos:oDocDesc:Refresh(.t.)   //12-06-2008 Marlon Ramos (Reflejar el descuento en pantalla)

    oPos:cTicketDev :="" // Ticket Devoluciæn

//  EJECUTAR("DISPRUN",oDp:cEmpresa,"Punto de Venta")
  ENDIF
RETURN aItems

// Usuario Cerrado
FUNCTION CierreUs()
  IF !Empty(oPos:nNeto)
    oPos:SetMsgErr("Debe Concluir la Venta")
    RETURN .F.
  ENDIF

  REPORTE("CIERREDIA")
RETURN .T.

// Impresion BemaTech
FUNCTION IMPRIMIR(lVenta)
  RETURN EJECUTAR("DPPOSPRINT",lVenta)
RETURN .T.

// Quita la Ultima Venta
FUNCTION DESHACER()
  LOCAL oBrw:=oPos:oBrwItem
  LOCAL nAt :=LEN(oPos:oBrwItem:aArrayData)-1

  IF Empty(nAt)
     RETURN .F.
  ENDIF

  IF !Empty(oPos:cCodInv)
    nAt:=ASCAN(oPos:oBrwItem:aArrayData,{|a,n|a[6]=oPos:cCodInv})
    IF nAt=0
      SetMsgInv("")
      SetMsgErr("Cædigo : "+ALLTRIM(oPos:cCodInv)+" no estﬂ en Ticket")
      RETURN .F.
    ENDIF
  ENDIF

  IF oPos:oBrwItem:aArrayData[oPos:oBrwItem:nArrayAt,04]=0
    ADEL(oPos:oBrwItem:aArrayData,nAt)
    ASIZE(oPos:oBrwItem:aArrayData,nAt)
    oPos:oBrwItem:Refresh(.F.)
    oPos:oBrwItem:GoBottom(.T.)
  ELSE
    ADEL(oPos:oBrwItem:aArrayData,oPos:oBrwItem:nArrayAt)
    ASIZE(oPos:oBrwItem:aArrayData,nAt)
    oPos:oBrwItem:Refresh(.F.)
    oPos:oBrwItem:GoBottom(.T.)
  ENDIF

  oPos:CALCULAR()

  DPFOCUS(oPos:oCodInv)
RETURN .T.

FUNCTION CALCULAR(aData)
  DEFAULT aData:=oPos:oBrwItem:aArrayData

  oPos:nIva   :=0
  oPos:nBruto :=0
  oPos:nCanTot:=0


  // JN 01/03/2011, Si el Cliente es Zona Libre el IVA sera Cero
  IF oPos:cZonaNL="L"
    AEVAL(aData,{|a,n| aData[n,7]:= 0 , aData[n,8]:="EX" })
  ENDIF

  
  /* 02-06-2008 Marlon Ramos (Se redondea el iva para Evitar descuadres y se toma el descuento)
   AEVAL(aData,{|a,n,nIva|oPos:nBruto :=oPos:nBruto +a[2],;
                         oPos:nCanTot:=oPos:nCanTot+a[3],;
                         nIva        :=PORCEN(a[2],a[7]),;
                         oPos:nIva   :=oPos:nIva+nIva})
   oPos:nNeto :=oPos:nBruto+oPos:nIva
  */

  //viewarray(aData)
/*  AEVAL(aData,{|a,n,nIva|oPos:nBruto :=oPos:nBruto +a[2],;
                         oPos:nCanTot:=oPos:nCanTot+a[3],;
                         nIva        :=oPos:REDONDEA(a[2]/100*a[7]),;
                         oPos:nIva   :=oPos:nIva+nIva})
*/
  // 16-07-2008 Marlon Ramos (Cﬂlculo especial para BMC)
  IF "BMC"$UPPE(oDp:cImpFiscal) 
	  AEVAL(aData,{|a,n,nIva,nBruto|nBruto:=ROUND(a[2]/100*a[7],2),;
                         oPos:nBruto :=oPos:nBruto +a[2],;
                         oPos:nCanTot:=oPos:nCanTot+a[3],;
                         nIva        :=ROUND(a[2]/100*a[7],2),;
                         oPos:nIva   :=oPos:nIva+nIva})
  ELSE
	  AEVAL(aData,{|a,n,nIva|oPos:nBruto :=oPos:nBruto +a[2],;
                         oPos:nCanTot:=oPos:nCanTot+a[3],;
                         nIva        :=a[2]/100*a[7],;
                         oPos:nIva   :=oPos:nIva+nIva})
  ENDIF

  // Fin 16-07-2008 Marlon Ramos nIva        :=ROUND(a[2]/100*a[7],2),;

  //?"oPos:nDocDesc!=0", oPos:nDocDesc != 0      
  IF oPos:nDocDesc != 0       //Si hay descuento total
  	//?"oPos:nBruto antes Calcular",oPos:nBruto
     //oPos:nBruto:=REDONDEA(oPos:nBruto-(oPos:nBruto/100*oPos:nDocDesc),2)
     oPos:nBruto:=oPos:nBruto-ROUND(oPos:nBruto/100*oPos:nDocDesc,2)
  	//?"oPos:nBruto desp Calcular",oPos:nBruto

     //oPos:nIvA  :=oPos:nIva-ROUND(PORCEN(oPos:nIva,oPos:nDocDesc),2)
     //?"oPos:nIvA  antes ",oPos:nIva
     //oPos:nIvA  :=ROUND(oPos:nIva-(oPos:nIva/100*oPos:nDocDesc),2)
     oPos:nIvA  :=oPos:nIva-ROUND(oPos:nIva/100*oPos:nDocDesc,2)
     //?"oPos:nIvA  desp ",oPos:nIva

  ENDIF
  oPos:nNeto :=STR(oPos:nBruto+ROUND(oPos:nIva,2),12,5)
  oPos:nNeto :=VAL(LEFT( oPos:nNeto,IIF( AT(".",oPos:nNeto)>0,AT(".",oPos:nNeto)-1,LEN(oPos:nNeto) ) )+IIF( AT(".",oPos:nNeto)>0, SUBSTR( oPos:nNeto,AT(".",oPos:nNeto),3 ),"" ))
  // FIN 02-06-2008 Marlon Ramos 

  //viewarray(aData)
  //?"Ojo (Calcular)",oPos:nNeto
  oPos:oBruto:Refresh(.t.)
  oPos:oIva:Refresh(.t.)
  oPos:oNeto:Refresh(.t.)
  oPos:oDocDesc:Refresh(.t.)   //12-06-2008 Marlon Ramos (Reflejar el descuento en pantalla)

RETURN .T.

/* Redondea a dos decimales (se reemplaza por la funciæn ROUND() porque en algunos casos 
 el redondeo no cuadra con el aplicado por la impresora fiscal en el ticket el cual siempre 
 toma en cuenta hasta el tercer decimal.
 Ej: 47.25/100*9 --> RESULTADO 4.2525  Aplicando ROUND()   --> Resultado 4.26
 Sin embargo el ticket se imprime por 4.25
 Ej: 47.25/100*9 --> RESULTADO 4.2525  Aplicando REDONDEA()--> Resultado 4.25
*/
FUNCTION REDONDEA(nTotal,nCantDecim)
  LOCAL nEntero:=0,nDecimal:=0, nContador, cNvoValor:=""
  LOCAL cEntero:="",cDecimal:="", lSw_Mayor:=.F.
  DEFAULT nTotal:=0, nCantDecim:=2

  nTotal  := STR(nTotal,16,5)
  cEntero :=LEFT ( nTotal, IIF( AT(".",nTotal)>0,AT(".",nTotal)-1,LEN(nTotal) ) )
  cDecimal:=RIGHT( nTotal, IIF( AT(".",nTotal)>0,LEN(nTotal)-AT(".",nTotal), 0 ) )
  ?"Entero",cEntero 
  ?"Decimal",cDecimal
  
  IF LEN(cDecimal)>0
     IF nCantDecim < LEN(cDecimal)
        nDecimal:=VAL(SUBSTR(cDecimal, nCantDecim+1,1))  //Buscar el d›gito siguiente al que se quiere redondear
        IF nDecimal >= 5
           lSw_Mayor:=.T.
           FOR nContador=nCantDecim TO 1 STEP -1
               nTotal:=VAL(SUBSTR(cDecimal, nContador,1))
               //?"nContador",nContador,"Val de nTotal",ntotal,"substr",SUBSTR(cDecimal, nContador,1)
               IF lSw_Mayor
                  nTotal:=nTotal+1
                  //?"nTotal+1",nTotal
               ENDIF
               //?"RIGHT totl",RIGHT(ALLTRIM(STR(nTotal)),1)
               cNvoValor:=RIGHT(ALLTRIM(STR(nTotal)),1)+cNvoValor
               //?"cNvoValor",cNvoValor
               lSw_Mayor:=nTotal>9
           NEXT
        ENDIF
     ELSE
        cNvoValor:=cDecimal
     ENDIF
  ENDIF
  IF lSw_Mayor
     cEntero := STR(VAL(cEntero)+1)
  ENDIF
  
cEntero:= cEntero + "." +cNvoValor
?cEntero,VAL(cEntero)
//?VAL(cEntero + "." +cNvoValor)
//RETURN VAL(cEntero + "." +cNvoValor)
RETURN VAL(cEntero)
//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*  

// Calcula el Precio Sin IVA
FUNCTION PRECIOIVA(nTotal)
  LOCAL nIva:=0,nPrecio:=0,nRata

  DEFAULT nTotal:=0

  IF !oPos:lPrecioIva
    RETURN nTotal
  ENDIF

  nRata       :=DIV(oPos:nIvaItem,100)+1
  oPos:nPrecio:=DIV(oPos:nPrecio,nRata)

RETURN DIV(nTotal,nRata)


FUNCTION DISPITEM()
  LOCAL cLine,nLen,cTotal

//LSTR(oPos:nPrecio,10,IIF(oPos:nPrecio=INT(oPos:nPrecio),0,2))+"X"+;
//         LSTR(oPos:nCantid,10,IIF(oPos:nCantid=INT(oPos:nCantid),0,2))

  cLine:=ALLTRIM(FDP(oPos:nPrecio,"9,999,999"+FDEC(oPos:nPrecio),.F.))+"X"+;
         ALLTRIM(FDP(oPos:nCantid,"9999999"  +FDEC(oPos:nCantid),.F.))

  cTotal:="="+ALLTRIM(FDP(oPos:nNeto,"999,999,999.99",.F.))

  IF LEN(cTotal+cLine)>20
    cLine:=ALLTRIM(FDP(oPos:nPrecio,"9999999"+FDEC(oPos:nPrecio),.F.))+"X"+;
           ALLTRIM(FDP(oPos:nCantid,"9999999"+FDEC(oPos:nCantid),.F.))
  ENDIF

  IF LEN(cTotal+cLine)>20
    cTotal:="="+ALLTRIM(FDP(oPos:nNeto,"999999999.99",.F.)+" ")
  ENDIF

  IF "LPT"$oDp:cDisp_Com
    nLen  :=19-LEN(cLine)
  ELSE
    nLen  :=20-LEN(cLine)
  ENDIF

  cLine :=ALLTRIM(cLine)+PADL(cTotal,nLen)

  EJECUTAR("DISPRUN",oPos:cMsgInv,cLine)
RETURN .T. 

FUNCTION DISPTOTAL()
  LOCAL cLine1,cLine2,nLen,cTotal

//cLine1:="TOTAL "+oDp:cMoneda+" "+FDP(nMonto,"999,999,999.99",NIL,.T.)

  cLine1:="TOTAL "+oDp:cMoneda
  cTotal:=FDP(oPos:nNeto,"999,999,999.99",NIL,.T.)
  nLen  :=20-LEN(cLine1)
  cLine1:=cLine1+PADL(cTotal,nLen)

  cLine2:="IVA"
  cTotal:=FDP(oPos:nIva,"999,999,999.99",NIL,.T.)

  IF "LPT"$oDp:cDisp_Com
    nLen  :=19-LEN(cLine2)
  ELSE
    nLen  :=20-LEN(cLine2)
  ENDIF

  cLine2:=cLine2+PADL(cTotal,nLen)

//cLine2:="IVA:"  +FDP(oPos:nIva   ,"999,999,999.99",NIL,.T.)

  EJECUTAR("DISPRUN",cLine1,cLine2)
RETURN .T.


FUNCTION DISPFINAL()
  LOCAL cLine1,cLine2,nLen,cTotal

  cLine1:="Muchas Gracias"

  IF !Empty(oPos:nVuelto)
    cLine1:="VUELTO" // +FDP(oPos:nVuelto,"999,999,999.99",NIL,.T.)
    cTotal:=FDP(oPos:nVuelto,"999,999,999.99",NIL,.T.)
    nLen  :=20-LEN(cLine1)
    cLine1:=cLine1+PADL(cTotal,nLen)
  ENDIF
    
  cLine2:="Cant. Productos:"+FDP(oPos:nCanTot,"999,999,999.999",.F.,.T.)

  IF LEN(cLine2)>20
    cLine2:="Productos:"+FDP(oPos:nCanTot,"999,999,999.999",.F.,.T.)
  ENDIF

  EJECUTAR("DISPRUN",cLine1,cLine2)
RETURN .T.

FUNCTION BRWGRUPOS()
  LOCAL cCodigo:=""
  cCodigo:=EJECUTAR("DPPOSSELGRU",oPos)
RETURN .T.

FUNCTION BRWMARCAS()
  LOCAL cCodigo:=""
  cCodigo:=EJECUTAR("DPPOSSELMARCAS",oPos)
RETURN .T.

// Avance de Pﬂginas
FUNCTION PAGSKIP(nSkip,nPage)
  LOCAL nOld:=oPos:nPag

  oPos:nPag:=oPos:nPag+nSkip
  IF nPage<>NIL
    oPos:nPag:=nPage
  ENDIF
  oPos:nPag:=MIN(oPos:nPag,LEN(oPos:aPagina))
  oPos:nPag:=MAX(oPos:nPag,1                )

  IF oPos:nPag<>nOld
    oPos:BtnRefresh(oPos:nPag)
  ENDIF
RETURN .T.

FUNCTION PUTTECLA(cKey,oGet)
  LOCAL cText

  DEFAULT oGet:=oPos:oCodInv

  cText:=EVAL(oGet:bSetGet)
  cText:=PADR(ALLTRIM(ctext)+cKey,LEN(cText))

  oGet:VarPut(cText,.T.)
  DpFocus(oGet)
  oGet:KeyBoard(35) // VK_END              35        //  0x23
 
RETURN .T.

FUNCTION SETCODIGO(cCodigo)
  IF !EMPTY(cCodigo)
    oPos:oCodInv:VarPut(cCodigo)
    oPos:oCodInv:KeyBoard(13)
  ENDIF
RETURN .T.

FUNCTION VALCODVEN()
  IF !SQLGET("DPVENDEDOR","VEN_CODIGO,VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",oPos:cCodVen))==oPos:cCodVen
    oPos:SetMsgErr("Vendedor "+oPos:cCodVen+" no Existe")
    RETURN .F.
  ENDIF

  SetMsgInv("Vendedor "+oDp:aRow[2])
 
  oPos:SaveVenta(.T.)
RETURN .T.

FUNCTION PosKeyDown(nKey)
  LOCAL aGrupo,I,U,aBtn

  // n{|nKey|IIF(!oPos:lCantid .AND. (nKey=13 .OR. nKey=9), oPos:SaveVenta(!oPos:lCodVen),NIL )}

  IF !oPos:lCantid .AND. (nKey=13 .OR. nKey=9 .OR. nKey=33 .OR. nKey=34)
    IF(nKey=33,oPos:oBrwItem:GoUp())
    IF(nKey=34,oPos:oBrwItem:GoDown())
    oPos:SaveVenta(!oPos:lCodVen)
  ENDIF

  aGrupo:=oPos:aPagina[oPos:nPag]

//  oDp:oFrameDp:SetText(LSTR(nKey))

  FOR I=1 TO LEN(aGrupo)
    FOR U=1 TO LEN(aGrupo[I])
      aBtn:=aGrupo[I,U]
      IF aBtn[5]=nKey
        //?aBtn[1]
        EVAL(aBtn[4])
      ENDIF
    NEXT U
  NEXT I
RETURN .T.

FUNCTION BemaErr(cError)
  IF !Empty(cError)
    oPos:lImpErr:=.T.

    SQLUPDATE("DPDOCCLI","DOC_IMPRES",0,"DOC_CODSUC"+GetWhere("=",oPos:cCodSuc)+" AND "+;
                                        "DOC_TIPDOC"+GetWhere("=",oPos:cTipDoc)+" AND "+;
                                        "DOC_NUMERO"+GetWhere("=",oPos:DOC_NUMERO))

    MensajeErr("Error en Impresiæn, Es necesario Reimprimir el Ticket",cError)
  ENDIF
RETURN .T.

FUNCTION VALCANTID()
  IF !oDp:TIKLDEVUELVE .AND. oPos:nCantid<0
    oPos:SetMsgErr("Devoluciæn no Autorizada")
    oPos:SetMsgInv("")
    RETURN .F.
  ENDIF 
RETURN .T.


////////////////////////////////////////////////////////////////////////////////////////////////////////
// 25-08-2008 Marlon Ramos (Permite seleccionar entre los precios de Venta Definidos para el producto)
////////////////////////////////////////////////////////////////////////////////////////////////////////
FUNCTION PIDE_PRECIO(lPrec)
  LOCAL cTipoPrec,cTipoUnid,lEsDev,nPosic,cAuxPrec,nPrecio:=0
  LOCAL cMap:=MYSQLGET("DPUSUARIOS","OPE_MAPMNU","OPE_NUMERO"+GetWhere("=",oDp:cUsuario))

  IF !lPrec
    RETURN .T.
  ENDIF
  IF oPos:nNeto<0
    oPos:SetMsgErr("No se Permite Cambiar precios a una Devoluciæn")
    RETURN .F.
  ENDIF 

  IF LEN(oPos:aPrecios)=0
     SetMsgErr("No se Encontræ ning∑n Precio para el  Producto: "+ALLTRIM(oPos:cCodInv))
     RETURN .F.
  ENDIF

  //IF cMap="ADM"
    /* EXISTENCIA oPos:aPrecios:=ASQL("SELECT MOV_CODIGO,SUM(IF(MOV_FECHA"+GetWhere("<=",oDp:dFecha)+" OR (MOV_FECHA"+GetWhere("=",oDp:dFecha)+" AND MOV_HORA"+GetWhere("<",TIME())+"),DPMOVINV.MOV_CANTID*MOV_FISICO*MOV_CXUND ,0)) AS MOV_CANTID ;
      FROM DPMOVINV WHERE MOV_CODIGO"+GetWhere("=",oPos:cCodInv)+" AND MOV_CODALM"+GetWhere("=",oDp:cAlmacen)+" AND MOV_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND MOV_INVACT=1 AND MOV_FISICO<>0  ;
      GROUP BY MOV_CODIGO") 
      ViewArray(oPos:aPrecios)
 */

     // JN 02/06/2013. (Precios por Tabulador)

     nPrecio:=0

     IF LEN(oPos:aPrecios)>1
        nPrecio:=oPos:GETPRECIOTAB() // Obtiene el Precio Tabulado
        IF nPrecio>0
           oPos:aPrecios[1,1]:=nPrecio   
        ENDIF 
     ENDIF

     IF LEN(oPos:aPrecios)>1 .AND. nPrecio=0



        cAuxPrec:=EJECUTAR("REPBDLIST","DPPRECIOS",{"PRE_LISTA","PRE_UNDMED","UND_CANUND","PRE_PRECIO","PRE_DESCUE","PRE_REQUIE"},NIL,;
                     " INNER JOIN DPUNDMED ON PRE_UNDMED=UND_CODIGO "+;
                     " WHERE "+;
                      " PRE_CODIGO"+GetWhere("=",oPos:cCodInv),;
                     "Seleccionar Precios de Venta",;
                     {"Tipo","Und Med","CanxUnd","Precio","Dscto"},NIL,NIL,.T.)

        IF Valtype(cAuxPrec)!="C" .AND. !Empty(cAuxPrec)
           cTipoPrec:=oPos:cPrecio
        ENDIF

        nPosic:=AT("|||",cAuxPrec)
        cTipoPrec:=LEFT(cAuxPrec,nPosic-1)
        cTipoUnid:=RIGHT(cAuxPrec,LEN(cAuxPrec)-nPosic-2)
        oPos:aPrecios:=ASQL("SELECT PRE_PRECIO,PRE_UNDMED,UND_CANUND,PRE_DESCUE FROM DPPRECIOS "+;
                      " INNER JOIN DPUNDMED ON PRE_UNDMED=UND_CODIGO "+;
                      " WHERE "+;
                      " PRE_CODIGO"+GetWhere("=",oPos:cCodInv)+;
                      " AND PRE_LISTA"+GetWhere("=",cTipoPrec)+" AND PRE_UNDMED"+GetWhere("=",cTipoUnid)+;
                      " ORDER BY PRE_PRECIO")

        IF Empty(oPos:aPrecios)
           SetMsgErr("Producto no Tiene Precio")
           RETURN .F.
        ENDIF
    ENDIF
    oPos:nPrecio:=oPos:aPrecios[1,1] // Precio Escogido
    oPos:cUndMed:=oPos:aPrecios[1,2] // Unidad de Medida
    oPos:ncXUnd :=oPos:aPrecios[1,3] // Cantidad por Grupo
  //ELSE
     //SetMsgErr("No estﬂ Autorizado...")
     //RETURN .F.
  //ENDIF
RETURN .T.

FUNCTION FUNF3()
   oPos:lCantid:=!oPos:lCantid
   oPos:oCantid:Refresh()
   DPFOCUS(oPos:oCantid)
   oPos:oCantid:Refresh()
RETURN .T.

FUNCTION FUNF4()
   IIF(oPos:EFECTIVOYCESTA(),oPos:SaveTicket(.t.),NIL)
RETURN .T.

FUNCTION FUNF6()
   IIF(oPos:Cheque(),oPos:SaveTicket(.t.),NIL)
RETURN .T.

FUNCTION GETPRECIOTAB()
   LOCAL nPrecio:=0

   nPrecio:=SQLGET("DPPRECIOS","PRE_PRECIO","PRE_CODIGO"+GetWhere("=", oPos:cCodInv)+" AND "+;
                                            "PRE_REQUIE"+GetWhere(">=",oPos:nCantid)+" AND "+;
                                            "PRE_REQUIE"+GetWhere(">",0)+;
                                            " ORDER BY PRE_REQUIE "+;
                                            " LIMIT 1 ")

   IF nPrecio=0

      nPrecio:=SQLGET("DPPRECIOS","PRE_PRECIO","PRE_CODIGO"+GetWhere("=", oPos:cCodInv)+" AND "+;
                                               "PRE_REQUIE"+GetWhere(">",0)+;
                                               " ORDER BY PRE_REQUIE DESC "+;
                                               " LIMIT 1 ")

   ENDIF

RETURN nPrecio

FUNCTION SETBONTON(cCual)
? cCual
RETURN NIL


// EOF

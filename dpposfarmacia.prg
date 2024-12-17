// Programa   : DPPOSFARMACIA
// Fecha/Hora : 01/09/2005
// Prop®sito  : Operaciones de Punto de Venta
// Creado Por : Juan Navas-CYBERIA SOLUTIONS COMPANY
// Llamado por: DPPOSINI
// Aplicaci®n : Ventas y Cuentas por Pagar
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oBtn,oFontB,oTable,oBrw,oCol,oFontBrw,oFontB,aItems:={},aBtn:={}
  LOCAL nPorVar,I,nTotal:=0,oBrush,U,nLin,nCol,oBtn,oFontBtn
  LOCAL nBntAlto:=32,nBtnAncho:=32,aPagina:={},aGrupo:={},aLine:={},aBtnFile:={}
  LOCAL nPageIni:=1,cTipDoc:="TIK",lMesas:=.F.,cPrecio:="A",cCodCli:=STRZERO(0,10),cCodVen:=STRZERO(1,6)
  LOCAL oChk,oBrush,nCols:=5,nRows:=4,cCodMon:="Bs",cCenCos:=STRZERO(1,8)
  LOCAL nCajaFondo:=0.00,cTipPrecio:="A",cTipDev:="DEV"
  LOCAL lCierre   :=.F.,lAbierto:=.F.,lImpFis:=.F.,cCodTra:="S000",cCodAlm:="",cCodCaja:=oDp:cCaja
  LOCAL lVendedor :=.F.

  MsgRun("Cargando Parámetros del POS ","Espere....",{||;
          EJECUTAR("DISPRUN","AdaptaPro","Punto de Venta"),;
          aPagina:=EJECUTAR("DPPOSLEEINI","DP\DPPOSFARM.INI",nRows,nCols);
          })

//  IF !lAbierto
  //   ? "PUNTO DE VENTA NO ESTA ABIERTO"
//  ENDIF 

  IF EMPTY(aPagina)
     RETURN .T.
  ENDIF

//  if !MYSQLGET("DPCAJA","CAJ_CODIGO","CAJ_CODIGO"+GetWhere("=",cCodCaja))==cCodCaja 
//
//     MensajeErr("Código de Caja ["+cCodCaja+"] no Existe, Será Asumido el Código de Caja: "+oDp:cCaja+CRLF+;
//                "Para definir caja del Usuario, Utilice la Opción: Privilegios del Usuario" )
//     
//     cCodCaja:=oDp:cCaja
//
//  ENDIF
  
  // Descripci¢n,Total,cantidad,precio,Unidad de Medida,codigo,IVA,cTipIva 
  // AADD(aItems,{SPACE(50),0,0,0,SPACE(6),SPACE(20),0,"",0})
  aItems:=POSREINI(.F.)

  DEFINE FONT oFontBrw NAME "Verdana" SIZE 0, -12 
  DEFINE FONT oFontB   NAME "Verdana" SIZE 0, -12 BOLD
  DEFINE FONT oFontBtn NAME "MS Sans Serif" SIZE 0, -06 ITALIC

  DPEDIT():New("Punto de Venta - Farmacias","DPPOSFARMACIA.EDT","oPos",.F.)

  oPos:cFileChm   :="CAPITULO3.CHM"
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
  oPos:aDataWait  :={}
  oPos:lCantid    :=.F.     // Requiere Cantidad
  oPos:lTikWait   :=.F.
  oPos:lMesas     :=lMesas  // Requiere Cantidad
  oPos:cTipDoc    :=cTipDoc 	
  oPos:cPrecio    :=cPrecio
  oPos:cTipDev    :=cTipDev
  oPos:cFileBmp   :="DPPOSFARMADP.BMP"
  oPos:nMtoDev    :=0 // Devolución

  IF "BEMA"$UPPE(oDp:cImpFiscal) 
     oPos:cFileBmp   :="DPPOSFARMABEMA.BMP"
  ENDIF

  IF "BMC"$UPPE(oDp:cImpFiscal) 
     oPos:cFileBmp   :="DPPOSFARMABMC.BMP"
  ENDIF

  IF "EPSON"$UPPE(oDp:cImpFiscal) 
     oPos:cFileBmp   :="DPPOSFARMAEPSON.BMP"
  ENDIF


  oPos:cMsgInv    :="Introduzca el Código del Producto"
  oPos:cMsgErr    :=SPACE(40)
  oPos:cIva       :=""     // IVA del Producto
  oPos:nIva       :=0
  oPos:nDocOtros  :=0
  oPos:nDocDesc   :=0
  oPos:nRows      :=nRows
  oPos:nCols      :=nCols
  oPos:nIvaItem   :=0 // Iva por Item
  oPos:dFecha     :=oDp:dFecha
  oPos:cCodSuc    :=oDp:cSucursal
  oPos:cCodCli    :=cCodCli
  oPos:cCodVen    :=cCodVen
  oPos:lCodVen    :=lVendedor
  oPos:cCodVenIni :=cCodVen
  oPos:cCodMon    :=cCodMon
  oPos:cCenCos    :=cCenCos
  oPos:cCodTra    :=cCodTra // C¢digo de Transacci¢n
  oPos:lImpFis    :=lImpFis // Indica si Existe Impresora Fiscal
  oPos:cCodAlm    :=IIF(Empty(cCodAlm),oDp:cAlmacen,cCodAlm) // Almacen de Trabajo
  oPos:cUndMed    :=""     // Unidad de Medida en la Venta
  oPos:nCxUnd     :=0
  oPos:nEfectivo  :=0 
  oPos:nDebito    :=0  
  oPos:cBcoDeb    :=""
  oPos:cMarcaTD   :=""
  oPos:cPosTC     :=""

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
//@ 2,1 GROUP oPos:oGrupo TO 4, 21.5 PROMPT "Datos del Producto"    

  oBrw:=TXBrowse():New(oPos:oDlg )
  oBrw:SetArray( oPos:aItems ,.F.)
  oBrw:lHScroll := .F.
  oBrw:lVScroll := .F.
  oBrw:nFreeze  := 1
  oBrw:oFont    :=oFontBrw
//oBrw:nHeaderLines:= 2
  oBrw:nDataLines  := 2
  oBrw:lFooter     :=.F.
  oBrw:lHeader     :=.F.
//oBrw:SETBRUSH(oBrush)

  oCol:=oBrw:aCols[1]
//  oCol:cHeader:="Descripción"
  oCol:nWidth :=250
  oCol:oHeaderFont:=oFontB

  oCol:=oBrw:aCols[2]
  oCol:nWidth :=70
  oCol:bStrData 	 := {|oBrw|oBrw:=oPos:oBrwItem,oBrw:aArrayData[oBrw:nArrayAt,5]}
  oCol:bClrStd      := {|oBrw|oBrw:=oPos:oBrwItem,{CLR_HBLUE, IIF( oBrw:nArrayAt%2=0,16770764,16774636 ) } }
  oCol:oHeaderFont:=oFontB


  oCol:=oBrw:aCols[3]
  oCol:nWidth       := 110+15
  oCol:oHeaderFont  := oFontB
  oCol:cEditPicture := oPos:cPicture
  oCol:bStrData     := {|oBrw|oBrw:=oPos:oBrwItem,FDP(oBrw:aArrayData[oBrw:nArrayAt,2],oPos:cPicItem)}
  oCol:bClrStd      := {|oBrw|oBrw:=oPos:oBrwItem,{CLR_HBLUE, iif( oBrw:nArrayAt%2=0,16770764,16774636 ) } }
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT

  oBrw:bClrStd      := {|oBrw|oBrw:=oPos:oBrwItem,{CLR_BLUE, iif( oBrw:nArrayAt%2=0,16770764,16774636 ) } }
  oBrw:bClrHeader   := {|oBrw|oBrw:=oPos:oBrwItem,{CLR_BLUE,12582911}}
  oBrw:bClrHeader   := {|| { CLR_WHITE,16744448}}
  oBrw:bLDblClick   := {||oPos:DescItem(oPos:oBrwItem:nArrayAt)}



  oBrw:CreateFromCode()
  oPos:oBrwItem:=oBrw

  @ 1.0,27   BMPGET oPos:oCodInv  VAR oPos:cCodInv ;
             VALID oPos:ValCodigo();
             NAME "BITMAPS\FIND.BMP"; 
                    WHEN 1=1;
                    SIZE 80,10;
             ACTION (EJECUTAR("GRIDBUSCAINVPOS")) 

  oPos:oCodInv:bKeyDown:={|nKey|oPos:PosKeyDown(nKey)}

 // n{|nKey|IIF(!oPos:lCantid .AND. (nKey=13 .OR. nKey=9), oPos:SaveVenta(!oPos:lCodVen),NIL )}


  @ 10,38 GET oPos:oCantid VAR oPos:nCantid PICTURE oDp:cPictCanUnd RIGHT;
              VALID  oPos:ValCantid() .AND. oPos:SaveVenta(!oPos:lCodVen);
              WHEN oPos:lCantid


  @ 1.0,29.0 BMPGET oPos:oCodVen  VAR oPos:cCodVen ;
             VALID oPos:ValCodVen();
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oDpLbx:=DpLbx("DPVENDEDOR") , oDpLbx:GetValue("VEN_CODIGO",oPos:oCodVen)); 
                    WHEN oPos:lCodVen;
                    SIZE 80,10

  nBntAlto :=30
  nBtnAncho:=30
  aGrupo   :=aPagina[nPageIni]
  oFontBtn:=NIL

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

      oBtn:SetText( aLine[U,1], 42, 2, nil, nil , nil )
//     oBtn:SetFont(oFont)
//    oBtn:SetText( aBtn[U,2], 40, 5, nil, nil,nil )

      oBtn:bWhen  :=aLine[U,3]
      oBtn:bAction:=aLine[U,4]

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

  oPos:oBtnPagUp:cToolTip:="Página Siguiente"

  @ 3.0, 210 SBUTTON oPos:oBtnPagDown PIXEL;
             SIZE 20,28 FONT oFontB;
             FILE "BITMAPS\BOTONDOWN.BMP";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_GRAY, 1 };
             ACTION oPos:oBrwItem:GoDown()

  oPos:oBtnPagDown:cToolTip:="Página Anterior"


  oPos:Activate({||oPos:PAGBARRA()})

Return nil

FUNCTION DescItem(nAt,nDesc)
LOCAL oBrw:=oPos:oBrwItem
LOCAL aData:=oPos:oBrwItem:aArrayData


  oBrw:aArrayData[nAt,02]:=(oBrw:aArrayData[nAt,04]*oBrw:aArrayData[nAt,03])-PORCEN(oBrw:aArrayData[nAt,04]*oBrw:aArrayData[nAt,03],nDesc) 
  oBrw:aArrayData[nAt,05]:=IIF(nDesc<>0,ALLTRIM(FDP(nDesc,"99"))+" % Desc","0 %")

  oBrw:DrawLine(.T.)
  oPos:Calcular()

  oBrw:Refresh(.T.)
  oBrw:GoBottom(.T.)

RETURN

FUNCTION PrecioItem(nAt,nPrecio)
LOCAL oBrw:=oPos:oBrwItem
 
  oBrw:aArrayData[nAt,02]:=nPrecio
  oBrw:DrawLine(.T.)
  oPos:Calcular()

  oBrw:Refresh(.T.)
  oBrw:GoBottom(.T.)

  oDlg:End()

RETURN

FUNCTION CAMB_PRECIO(lPrec)
  LOCAL nMonto:=0.00,oDlg,oRadio,nRadio
  LOCAL cMap:=MYSQLGET("DPUSUARIOS","OPE_MAPMNU","OPE_NUMERO"+GetWhere("=",oDp:cUsuario))

IF cMap="ADM"

   DEFINE DIALOG oDlg TITLE "Cambia Precio x Renglon" FROM 0,0 TO 8,33

   @ 0.5,1 SAY "Monto :" 
   @ 1.5,1 GET nMonto SIZE 50,10 RIGHT PICTURE "999,999,999.99"

   @ 2.5,12 BUTTON "Aplicar" SIZE 22,12 ACTION oPos:PrecioItem(oPos:oBrwItem:nArrayAt,nMonto)

   @ 2.5,17 BUTTON "Cerrar"  SIZE 22,12 ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED

   EJECUTAR("DPPOSUSUARIO",oPos)
ELSE

MsgInfo("Acceso Restringido","Advertencia")

ENDIF

RETURN

FUNCTION DESC_TOTAL(lDesc)
  LOCAL nMonto:=0,oDlg,oRadio,nRadio
  LOCAL cMap:=MYSQLGET("DPUSUARIOS","OPE_MAPMNU","OPE_NUMERO"+GetWhere("=",oDp:cUsuario))

IF cMap="ADM"

   DEFINE DIALOG oDlg TITLE "Asignar Descuento a la Factura" FROM 0,0 TO 8,33

   @ 0.5,1 SAY "Monto :" 
   @ 1.5,1 GET nMonto SIZE 30,10

   @ 2.5,12 BUTTON "Aplicar" SIZE 22,12 ACTION APLI_DESC(nMonto,nRadio)
   @ 2.5,17 BUTTON "Cerrar"  SIZE 22,12 ACTION oDlg:End()

   @ 0.5,10.5 RADIO oRadio VAR nRadio;
          ITEMS "Absoluto (Monto)","Relativo (%)","X Item";
          SIZE 60,12;
          COLOR NIL,oDp:nGris 

   ACTIVATE DIALOG oDlg CENTERED

   EJECUTAR("DPPOSUSUARIO",oPos)
ELSE

MsgInfo("Acceso Restringido","Advertencia")

ENDIF
RETURN

FUNCTION APLI_DESC(nMonto,nRadio)

IF nRadio=3
oPos:DescItem(oPos:oBrwItem:nArrayAt,nMonto)
oDlg:End()
ENDIF

IF nRadio=2
oPos:nDocDesc:=nMonto
ENDIF

IF nRadio=1
oPos:nDocOtros:=nMonto
ENDIF

IF oPos:nDocDesc<>0 .OR. oPos:nDocOtros<>0

DO CASE
	CASE nRadio=1
  	oPos:nBruto   :=oPos:nBruto-oPos:nDocOtros
	CASE nRadio=2
  	oPos:nBruto   :=oPos:nBruto-PORCEN(oPos:nBruto,oPos:nDocDesc)
ENDCASE

  oPos:nNeto    :=oPos:nBruto+oPos:nIva

  oPos:oBruto:Refresh(.t.)
  oPos:oIva:Refresh(.t.)
  oPos:oNeto:Refresh(.t.)

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
  @26.8,79  STSAY oPos:oMsgInv PROMPT oPos:cMsgInv;
            SIZE 300, 20  FONT oFontB;
            COLORS CLR_HRED

  @28.7,79 STSAY oPos:oMsgErr PROMPT oPos:cMsgErr OF oPos:oDlg;
            COLORS CLR_HRED SIZE 300, 19 FONT oFontB ;
            SHADED;
            BLINK nClrBlink, nInterval, nStop  

  @23.2,78  STSAY oPos:oCodText PROMPT "Código";
            SIZE 100, 20  FONT oFontB;
            COLORS CLR_BLUE

  @23.2,105 STSAY oPos:oCantText PROMPT "Cantidad";
            SIZE 100, 20  FONT oFontB;
            COLORS CLR_BLUE

  @ 1.1, 38 SAY oPos:oBruto PROMPT FDP(oPos:nBruto,"999,999,999.99");
            RIGHT;
            SIZE 160, 20  FONT oFontT;
            COLOR CLR_HGREEN,CLR_BLACK

  @ 2.3, 38 SAY oPos:oIva PROMPT FDP(oPos:nIva,"999,999,999.99");
            RIGHT;
            SIZE 160, 20  FONT oFontT;
            COLOR CLR_HGREEN,CLR_BLACK

  @ 3.6, 38 SAY oPos:oNeto PROMPT FDP(oPos:nNeto,"999,999,999.99");
            RIGHT;
            SIZE 160, 20  FONT oFontT;
            COLOR CLR_YELLOW,CLR_BLACK

/*
  @ 7, 48 SCROLLBAR oPos:oScr SIZE 40,100

  oPos:oBrwItem:lVScroll:=.T.
  oPos:oBrwItem:oVScroll:=oPos:oScr
*/

// oBrw:oVScroll:Move(0,0,200,200,.T.)
//  oPos:BtnRefresh(2)

RETURN .T.

/*
// Seleccionar Forma de Pago
*/
FUNCTION SELFORMAPAG()
   LOCAL oBrw:=oPos:oBrwItem
RETURN .T.

FUNCTION Recibido()
RETURN .T.

/*
// Se encarga de Grabar la Venta
*/
FUNCTION SAVEVENTA(lSave)
  LOCAL oBrw :=oPos:oBrwItem
  LOCAL nAt  :=LEN(oBrw:aArrayData)
  LOCAL aLine:=oBrw:aArrayData[nAt]
  LOCAL cLine,cTotal,nLen

  IF EMPTY(oPos:cCodInv) 
     RETURN .F.
  ENDIF

  IF !oPos:VALCODIGO()

     IF Empty(oPos:aDataBal)
       oPos:SetMsgErr("Producto ["+ALLTRIM(oPos:cCodInv)+"], no Existe")
       oPos:SetMsgInv("")
     ENDIF

     DpFocus(oPos:oCodInv)

     oPos:oCodInv:Refresh() 

     RETURN .F.

  ENDIF

  oPos:SetMsgErr("") // Borra el Mensaje de Error

  IF !lSave
     RETURN .T.
  ENDIF

//oPos:SetMsgInv(oPos:cMsgInv)
//oPos:cMsgInv:=oPos:cDescri
//SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oPos:cCodInv))
/*
  oPos:oMsgInv:Hide()
//  oPos:oMsgInv:Refresh(.T.)
  oPos:oMsgInv:Show()
*/

  AEVAL(aLine,{|a,n|aLine[n]:=CTOEMPTY(a)})
  oPos:nBruto:=0  // Monto Bruto

  oBrw:aArrayData[nAt,01]:=oPos:cCodInv+" "+ALLTRIM(FDP(oPos:nCantid,"999,999,999.999",.F.))+" X "+;
                           ALLTRIM(FDP(oPos:nPrecio,"999,999,999.99"))+CRLF+oPos:cMsgInv
  oBrw:aArrayData[nAt,02]:=(oPos:nPrecio*oPos:nCantid)-PORCEN(oPos:nPrecio*oPos:nCantid,oPos:nDescxI)
  oBrw:aArrayData[nAt,03]:=oPos:nCantid 
  oBrw:aArrayData[nAt,04]:=oPos:nPrecio 
  oBrw:aArrayData[nAt,05]:=IIF(oPos:nDescxI<>0,ALLTRIM(FDP(oPos:nDescxI,"99"))+" % Desc","0 %")
  oBrw:aArrayData[nAt,06]:=oPos:cCodInv
  oBrw:aArrayData[nAt,07]:=oPos:nIvaItem
  oBrw:aArrayData[nAt,08]:=oPos:cIva
  oBrw:aArrayData[nAt,09]:=oPos:cMsgInv
  oBrw:aArrayData[nAt,10]:=oPos:cUndMed
  oBrw:aArrayData[nAt,11]:=oPos:nCxUnd
  oBrw:aArrayData[nAt,12]:=oPos:cCodVen
  oBrw:aArrayData[nAt,13]:=oPos:nDescxI

//AADD(aItems,{SPACE(50),0,0,0,SPACE(6),"6CODIGO",7,"8CIVA","9DESCRI","10UND","11cXUnd"})

  oBrw:DrawLine(.T.)
  oPos:Calcular()

  AADD(oBrw:aArrayData,aLine)

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
// Pos:nPrecio)+"X"+LSTR(oPos:nCantid)+" ["+LSTR(oPos:nNeto)+"]")
//  oPos:Show()

  DpFocus(oPos:oCodInv)

RETURN .T.

FUNCTION VALCODIGO()
  LOCAL cCodEqui,lFound:=.F.,aData:={},I,aLine:={}
  LOCAL oBrw :=oPos:oBrwItem,nAt
  LOCAL nAt  :=LEN(oBrw:aArrayData)
  LOCAL aLine:=oBrw:aArrayData[nAt]

  oPos:cCodEqu :=""
  oPos:cDescri :=""
  oPos:nIvaItem:=0
  oPos:ncXUnd  :=0
  oPos:aDataBal:={}

  IF EMPTY(oPos:cCodInv)
     RETURN .F.
  ENDIF

  IF oPos:lCodVen 

   SQLGET("DPVENDEDOR","VEN_CODIGO,VEN_NOMBRE","VEN_CODIGO"+GetWhere("=",oPos:cCodVen))
   IF !Empty(oDp:aRow)
      oPos:SetMsgInv("Vendedor "+oDp:aRow[2])
   ENDIF

  ENDIF

  IF MYSQLGET("DPINV","INV_CODIGO,INV_DESCRI,INV_IVA","INV_CODIGO"+GetWhere("=",oPos:cCodInv))!=oPos:cCodInv

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

  oPos:nIvaItem:=EJECUTAR("IVACAL",oPos:cIva,2,oPos:dFecha) // IVA (Nacional o Zona Libre

 // ? oPos:cIva,"cIva",oPos:nIvaItem

  oPos:SetMsgInv(oPos:cMsgInv)

  // Buscamos el Precio
  oPos:aPrecios:=ASQL("SELECT PRE_PRECIO,PRE_UNDMED,UND_CANUND,PRE_DESCUE FROM DPPRECIOS "+;
                      " INNER JOIN DPUNDMED ON PRE_UNDMED=UND_CODIGO "+;
                      " WHERE "+;
                      " PRE_CODIGO"+GetWhere("=",oPos:cCodInv)+;
                      " AND PRE_LISTA"+GetWhere("=",oPos:cPrecio)+" ORDER BY PRE_PRECIO")

  IF LEN(oPos:aPrecios)>0
    // ViewArray(oPos:aPrecios)
    oPos:nPrecio:=oPos:aPrecios[1,1] // Toma el Precio m s Bajo
    oPos:cUndMed:=oPos:aPrecios[1,2] // Unidad de Medida
    oPos:ncXUnd :=oPos:aPrecios[1,3] // Cantidad por Grupo
    oPos:nDescxI:=oPos:aPrecios[1,4] // Descuento por Item

  ENDIF

  IF LEN(oPos:aPrecios)=1

    oPos:nPrecio:=oPos:aPrecios[1,1]
    oPos:cUndMed:=oPos:aPrecios[1,2]
    oPos:ncXUnd :=oPos:aPrecios[1,3] // Cantidad por Grupo

  ENDIF
  
  oPos:PRECIOIVA() // Genera Precios con IVA Incluido

  //  ? oPos:cUndMed,"undmed"
  // Debe ubicar la Unidad de Medida Excluivas del Producto

  IF Empty(oPos:aPrecios)
    SetMsgErr("Producto no Tiene Precio")
    RETURN .F.
  ENDIF

//EJECUTAR("DISPRUN",oPos:cMsgInv,LSTR(oPos:nPrecio)+"X"+LSTR(oPos:nCantid))
//  oPos:nPrecio:=SQLGET("DPPRECIOS")
 
  IF EMPTY(oPos:cCodInv)
     RETURN .F.
  ENDIF

RETURN .T.

/*
// Cambiar el BMP del Boton
*/
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

//       ? oBtn:aBitMaps[2],oBtn:aBitMaps[1],aBtn[2,1]

        oBtn:SetText( aBtn[1], 40, 5, nil, nil,nil )
//      oBtn:oFont:=oPos:oDlg:oFont
        aFile[1]:="bitmaps\"+aBtn[2,1]
        aFile[2]:="bitmaps\"+aBtn[2,2]
        oBtn:LoadBitmaps( aRes, aFile )
        oBtn:SetSize(aSize[1],aSize[2])
//      oBtn:aBitMaps[1]:=aBtn[2,1]
        oBtn:bWhen  :=aBtn[3]
        oBtn:bAction:=aBtn[4]

      ENDIF

     NEXT U

  NEXT I

RETURN .T.

FUNCTION POSCERRAR()
   MensajeErr("AQUI CIERRA")
RETURN .T.

FUNCTION POSCLIENTE()
  EJECUTAR('DPCLIENTESCERO',oPos,NIL)
RETURN .T.

/*
// Indica el Mensaje de Error, Cuando el Producto No Existe
*/
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

    IF oPos:nNeto=0

       oPos:SetMsgErr("No hay Venta")

       RETURN .F.

    ENDIF

    oPos:DISPTOTAL()

    IF oPos:nNeto<0

        IF !oDp:TIKLDEVEFECT
          oPos:SetMsgErr("No Puede Devolver Dinero")
          RETURN .F.
        ENDIF

        RETURN MsgNoYes("Desea Realizar Devolución en Efectivo","Devolver Dinero")

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

    EJECUTAR("DPPOSTARJETACRE",oPos)


RETURN .t.

/*
// Pago con Cheque
*/
FUNCTION Cheque()

    IF oPos:nNeto<=0

       oPos:SetMsgErr("No hay Venta")

       RETURN .F.

    ENDIF

    oPos:DISPTOTAL()

RETURN  EJECUTAR("DPPOSCHEQUE",oPos)

/*
// Pago con Cesta Ticket
*/
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

FUNCTION TicketWait()

//  ADEL(oPos:aDataWait)

  AEVAL(oPos:oBrwItem:aArrayData,{|a,n| IIF(a[2]>0, AADD(oPos:aDataWait,a) , NIL)  })

//ViewArray(oPos:aDataWait)

  oPos:lTikWait:=!oPos:lTikWait

oPos:POSREINI(.T.)


RETURN 

FUNCTION TicketRestore()
  LOCAL aData :=oPos:aDataWait 
  LOCAL oBrw  :=oPos:oBrwItem 
  LOCAL nAt   :=LEN(oPos:oBrwItem)
  LOCAL nAt1  :=LEN(aData),aItems:={}

IF !oPos:lTikWait
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

  	IF MsgYesNo("Esta seguro de borrar la transacción ?","Advertencia")	
  	oPos:POSREINI(.T.)
  	ENDIF

RETURN

FUNCTION SaveTicket(lPrint)
RETURN EJECUTAR("DPPOSSAVE",lPrint)

FUNCTION POSREINI(lNew)
  LOCAL aItems:={}

  AADD(aItems,{SPACE(50),0,0,0,SPACE(6),0,7,"8CIVA","VACIO","10UND","11cXUnd","12CODVEN",0})

  IF lNew

    oPos:DISPFINAL()

    oPos:oBrwItem:aArrayData:=ACLONE(aItems)
    oPos:oBrwItem:nArrayAt:=1
    oPos:oBrwItem:nRowSel :=1
    oPos:oBrwItem:Refresh(.T.)

    oPos:nNeto :=0
    oPos:nBruto:=0
    oPos:nIva  :=0

    oPos:nEfectivo  :=0     
    oPos:nRecibe    :=0      
    oPos:nVuelto    :=0      
    oPos:nCheque    :=0
    oPos:nCesta     :=0 
    oPos:cCodVen    :=oPos:cCodVenIni
    oPos:SetMsgInv("Introduzca Código del Producto")


    oPos:oBruto:Refresh(.t.)
    oPos:oIva:Refresh(.t.)
    oPos:oNeto:Refresh(.t.)

//  EJECUTAR("DISPRUN",oDp:cEmpresa,"Punto de Venta")
 
  ENDIF

RETURN aItems
/*
// Usuario Cerrado
*/
FUNCTION CierreUs()

  IF !Empty(oPos:nNeto)
    oPos:SetMsgErr("Debe Concluir la Venta")
    RETURN .F.
  ENDIF

  ? "Reliza Cierre del Usuario"

RETURN .T.

/*
// Impresion BemaTech
*/
FUNCTION IMPRIMIR(lVenta)

   RETURN EJECUTAR("DPPOSPRINT",lVenta)

RETURN .T.

/*
// Quita la Ultima Venta
*/
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
       SetMsgErr("C¢digo : "+ALLTRIM(oPos:cCodInv)+" no est  en Ticket")
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

  AEVAL(aData,{|a,n,nIva|oPos:nBruto :=oPos:nBruto +a[2],;
                         oPos:nCanTot:=oPos:nCanTot+a[3],;
                         nIva        :=PORCEN(a[2],a[7]),;
                         oPos:nIva   :=oPos:nIva+nIva})


  oPos:nNeto      :=oPos:nBruto+oPos:nIva

  oPos:oBruto:Refresh(.t.)
  oPos:oIva:Refresh(.t.)
  oPos:oNeto:Refresh(.t.)

RETURN .T.

/*
// Calcula el Precio Sin IVA
*/
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



/*
// Avance de Páginas
*/
FUNCTION PAGSKIP(nSkip)
   LOCAL nOld:=oPos:nPag

   oPos:nPag:=oPos:nPag+nSkip
   oPos:nPag:=MIN(oPos:nPag,LEN(oPos:aPagina))
   oPos:nPag:=MAX(oPos:nPag,1                )

   IF oPos:nPag<>nOld
     oPos:BtnRefresh(oPos:nPag)
   ENDIF

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
  IF !oPos:lCantid .AND. (nKey=13 .OR. nKey=9)
    oPos:SaveVenta(!oPos:lCodVen)
    RETURN .T.
  ENDIF

  aGrupo:=oPos:aPagina[oPos:nPag]

  // oDp:oFrameDp:SetText(LSTR(nKey))

  FOR I=1 TO LEN(aGrupo)

     FOR U=1 TO LEN(aGrupo[I])
      aBtn:=aGrupo[I,U]
      IF aBtn[5]=nKey
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

    MensajeErr("Error en Impresión, Es necesario Reimprimir el Ticket",cError)

  ENDIF

RETURN .T.

FUNCTION VALCANTID()

   IF !oDp:TIKLDEVUELVE .AND. oPos:nCantid<0
      oPos:SetMsgErr("Devolución no Autorizada")
      oPos:SetMsgInv("")
      RETURN .F.
   ENDIF 

RETURN .T.

// EOF

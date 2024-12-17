// Programa   : DPPOSSELBANCO	
// Fecha/Hora : 05/11/2005 09:12:14
// Propósito  : Seleccionar Bancos
// Creado Por : Juan Navas
// Llamado por: DPPOSCHEQUE
// Aplicación : Ventas
// Tabla      : DPBANCODIR

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oBrw,oDlg,aBancos:={},oFontBrw,oCol,oFontB,oBtn,oBrush
  LOCAL nTop:=160,nLeft:=20,nWidth:=615,nHeight:=310
  LOCAL nClrPane1:=16774636
  LOCAL lSelect:=.F.,cBanco:=""

  DEFAULT oDp:aBancos:=ASQL("SELECT BAN_NOMBRE,BAN_TELEF1 FROM DPBANCODIR ORDER BY BAN_NOMBRE")

  aBancos:=ACLONE(oDp:aBancos)

  IF EMPTY(aBancos)
     AADD(aBancos,{"Ninguno","Telefono"})
  ENDIF

//  IF oDp:lTactil
//    nWidth+=35
//  ENDIF

  DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0, -12 BOLD
  DEFINE FONT oFontB   NAME "MS Sans Serif" SIZE 0, -10 BOLD

//  DEFINE DIALOG oDlg TITLE "Directorio Bancario";
//         COLOR NIL,oDp:nGris

  DEFINE BRUSH oBrush;
               FILE "BITMAPS\dirbanco.BMP"

  DEFINE DIALOG oDlg TITLE "";
         STYLE nOr( WS_POPUP, WS_VISIBLE );
         BRUSH oBrush


  oDlg:lHelpIcon:=.F.

  oBrw:=TXBrowse():New(oDlg )
  oBrw:SetArray( aBancos ,.T.)
  oBrw:lHScroll  := .F.
  oBrw:lVScroll  := .T.
  oBrw:nFreeze   := 1
  oBrw:oFont     := oFontBrw
  oBrw:nDataLines:= 2
// IIF(oDp:lTactil,2,1)
  oBrw:lFooter   := .F.
  oBrw:lHeader   := .T.

  oCol:=oBrw:aCols[1]
  oCol:cHeader:="Banco"
  oCol:nWidth :=250

  oCol:=oBrw:aCols[2]
  oCol:cHeader:="Teléfono"
  oCol:nWidth :=310

  oBrw:bClrStd      := {||{CLR_BLUE, iif( oBrw:nArrayAt%2=0,16770764,16774636 ) } }
  oBrw:bClrHeader   := {||{CLR_YELLOW,16764315}}
  oBrw:bLDblClick   := {||lSelect:=.T.,oDlg:End()}
  oBrw:bKeyDown     := {|nKey| oBrw:nLastKey:=nKey,;
                               IIF( nKey=13,oDlg:End(),NIL) }

  oBrw:CreateFromCode()

  @ 4.0, 225 SBUTTON oBtn PIXEL;
             SIZE 25,25 FONT oFontB;
             NOBORDER;
             FILE "BITMAPS\BOTONUP.BMP";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oBrw:GoUp()

   oBtn:cToolTip:="Subir"


   @ 4.0, 251 SBUTTON oBtn PIXEL;
              SIZE 25,25 FONT oFontB;
              NOBORDER;
              FILE "BITMAPS\BOTONDOWN.BMP";
              COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
              ACTION oBrw:GoDown()

   oBtn:cToolTip:="Bajar"


   @ 4.0, 277 SBUTTON oBtn PIXEL;
              SIZE 25,25 FONT oFontB;
              NOBORDER;
              FILE "BITMAPS\XSALIR.BMP";
              COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
              ACTION oDlg:End()

   oBtn:cToolTip:="Cerrar"


   ACTIVATE DIALOG oDlg ON INIT (oDlg:Move(nTop,nLeft,nWidth,nHeight,.T.),;
                                 oBrw:Move(61,5,nWidth-10,nHeight-71,.T.),;
                                 oBrw:SetColor(NIL,nClrPane1))
 
   IF lSelect .OR. oBrw:nLastKey=13
     cBanco:=oBrw:aArrayData[oBrw:nArrayAt,1]
   ENDIF

RETURN cBanco
// EOF


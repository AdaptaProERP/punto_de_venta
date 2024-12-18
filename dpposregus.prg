// Programa   : DPPOSREGUS
// Fecha/Hora : 18/12/2006 15:09:56
// Prop�sito  : Registro Diario del Usuario
// Creado Por : Juan Navas
// Llamado por: DPPOSINI
// Aplicaci�n : Ventas
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oBtn,oFont

  DPEDIT():New("Registro de Inicio, Usuario "+oDp:cUsuario,"forms\DPPOSREGUS.EDT","oRegIUs",.T.)

  oRegIUs:lMsgBar  :=.F.
  oRegIUs:nMonto   :=SQLGET("DPPOSUSUARIO","RDP_MONTO,RDP_MTODIV","RDP_IP"+GetWhere("=",oDp:cIp)+" ORDER BY RDP_FECHA DESC LIMIT 1")
  oRegIUs:nMontoDiv:=DPSQLROW(2,0)

  @ 0,0 SAY "Usuario :" RIGHT
  @ 1,1 SAY "Fecha:"    RIGHT
  @ 2,1 SAY "Fondo de Caja en ("+oDp:cMoneda+"):"      RIGHT
 

  @ 0,10 SAY " "+oDp:cUsNombre
  @ 2,10 SAY " "+CSEMANA(oDp:dFecha)+" "+DTOC(oDp:dFecha)

  @ 4,1 SAY "Fondo de Caja en ("+oDp:cMonedaExt+"):"   RIGHT

  @ 3,0 GET oRegIUs:nMonto PICTURE "999,999,999.99";
            RIGHT;
            VALID oRegIUs:nMonto>=0

  @ 3,0 GET oRegIUs:oMontoDiv VAR oRegIUs:nMontoDiv;
            PICTURE "999,999,999.99";
            RIGHT;
            VALID oRegIUs:nMonto>=0

  oRegIUs:oMontoDiv:bKeyDown:={|nKey| IF(nKey=13,DPFOCUS(oRegIUs:oBtnSave),NIL)}
  oRegIUs:oMontoDiv:bLostfocus:={|| DPFOCUS(oRegIUs:oBtnSave)}

  oRegIUs:Activate({||oRegIUs:INICIO()})

RETURN .T.

FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oRegIUs:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
          ACTION (oRegIUs:RegistroUs())

   oBtn:cToolTip:="Guardar"

   oRegIUs:oBtnSave:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XCANCEL.BMP";
          ACTION (oRegIUs:Cancel()) CANCEL

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })
 
RETURN .T.



FUNCTION RegistroUs()

   LOCAL cNumero:=SQLINCREMENTAL("DPPOSUSUARIO","RDP_NUMERO")
   LOCAL oTable

   oTable:=OpenTable("SELECT * FROM DPPOSUSUARIO",.F.)
   oTable:Append()
   oTable:Replace("RDP_US"    ,oDp:cUsuario     )
   oTable:Replace("RDP_FECHA" ,oDp:dFecha       )
   oTable:Replace("RDP_MONTO" ,oRegIUs:nMonto   )
   oTable:Replace("RDP_HORA"  ,TIME()           )
   oTable:Replace("RDP_TIPTRA","I"              )
   oTable:Replace("RDP_IP"    ,oDp:cIp          )
   oTable:Replace("RDP_NUMERO",cNumero          )
   oTable:Replace("RDP_MTODIV",oRegIUs:nMontoDiv)
   oTable:Commit()
   oTable:End()

   oRegIUs:Close()

   EJECUTAR("DPPOSINI")

RETURN .T.


// RETURN .T.


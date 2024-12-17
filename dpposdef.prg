// Programa   : DPPOSDEF
// Fecha/Hora : 02/11/2005 18:59:18
// Propósito  : Definir Impresora Fiscal
// Creado Por : Juan Navas
// Modificado : Marlon Ramos 
// Llamado por: DPMENU
// Aplicación : DEFINICION
// Tabla      : 

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cIp,cPostRun)
  LOCAL oBtn,oFont,oGrp,aFmt
  LOCAL x:=EJECUTAR("DPUNDMEDCREA")
  // 18-08-2008 Marlon Ramos (Agregar PF-220,PF-300) LOCAL aDefImp:={"Ninguna","Bematech","BMC","Epson TMU200","Epson TMU220AF","LPT1:","LPT2:"},aComs:={"COM1","COM2","COM3","COM4","LPT1","LPT2"}
  // 19-09-2008 Marlon Ramos (Agregar impresoras SAMSUNG) LOCAL aDefImp:={"Ninguna","Bematech","BMC","Epson TMU200","Epson TMU220AF","Epson PF-220","Epson PF-300","LPT1:","LPT2:"},aComs:={"COM1","COM2","COM3","COM4","LPT1","LPT2"}
  // 26-01-2009 Marlon Ramos (Agregar ACLAS PP1F3)   LOCAL aDefImp:={"Ninguna","Bematech","BMC","Epson TMU200","Epson TMU220AF","Epson PF-220","Epson PF-300","SAMSUNG","LPT1:","LPT2:"},aComs:={"COM1","COM2","COM3","COM4","LPT1","LPT2"}
  LOCAL aDefImp   :={"Ninguna","Aclas PP1F3","Bematech","BMC","Epson PF-220","Epson PF-300","Epson TMU200","Epson TMU220AF","Okidata ML1120","Samsung","Star","LPT1:","LPT2:"},aComs:={"COM1","COM2","COM3","COM4","LPT1","LPT2"}
  LOCAL aModelo   :={"Clásico","Restaurant","Farmacia"}
  LOCAL aPrecio   :=ASQL("SELECT TPP_DESCRI,TPP_CODIGO FROM DPPRECIOTIP WHERE TPP_ACTIVO=1")
  LOCAL aTipPre   :={}
  LOCAL aUndMed   :=ASQL("SELECT UND_DESCRI,UND_CODIGO FROM DPUNDMED WHERE UND_ACTIVO=1")
  LOCAL aTipUnd   :={}
  LOCAL aImpCta   :={"LPT1:","LPT2:","LPT3:","Ninguna"}
  LOCAL aImpCmd   :={"LPT1:","LPT2:","LPT3:","Ninguna"}
  LOCAL cPcName   :=""
  LOCAL aSerFis   :=ATABLE("SELECT SFI_MODELO FROM DPSERIEFISCAL WHERE SFI_ACTIVO=1")
  LOCAL cSerFiscal:=""

  EJECUTAR("DPPOSLOAD")

  IF Empty(aPrecio)
     EJECUTAR("DPDATACREA")
     aPrecio   :=ASQL("SELECT TPP_DESCRI,TPP_CODIGO FROM DPPRECIOTIP WHERE TPP_ACTIVO=1")
  ENDIF

  DEFAULT cIp          :=oDp:cIpLocal,;
          oDp:cCajaDeli:=oDp:cCaja,;
          oDp:cCajaPos :=oDp:cCaja

  cPcName:=SQLGET("DPPCLOG","PC_NOMBRE","PC_IP"+GetWhere("=",cIp))

  IF Empty(aSerFis)
     MsgMemo("No hay Series Fiscales Activa")
     DPLBX("DPSERIEFISCAL.LBX")
     RETURN .T.
  ENDIF

  IF cIp!=oDp:cIpLocal
     EJECUTAR("DPPOSLOAD",cIp)
  ENDIF

  cSerFiscal:=SQLGET("DPSERIEFISCAL","SFI_MODELO","SFI_PCNAME"+GetWhere("=",cPcName))

//? cSerFiscal,"cSerFiscal"
//  ViewArray(aSerFis)

  IF Empty(aPrecio)
     MensajeErr("Requiere Registros del Catálogo de Precios")
     DPLBX("DPPRECIOTIP.LBX")
     RETURN .T.
  ENDIF

  aFmt:=ASQL("SELECT FOR_CODIGO FROM DPFORMATOSPRN WHERE FOR_GRUPO='TICKET'")

  AEVAL(aFmt,{|a,n|AADD(aDefImp,"Fmt:"+a[1]) })

  AEVAL(aUndMed,{|a,n|aUndMed[n]:=a[1],AADD(aTipUnd,a[2])})  
  AEVAL(aPrecio,{|a,n|aPrecio[n]:=a[1],AADD(aTipPre,a[2])})

  DEFAULT oDp:cFileBal:="BALANZA\T0000001.BAL"

  DPEDIT():New("Configurar Punto de Venta PC:"+cIp+"/"+cPcName,"forms\DEFIMPFISCAL.EDT","oDefFis",.F.)

  oDefFis:cIp           :=cIp
  oDefFis:cImpFiscal    :=oDp:cImpFiscal
  oDefFis:cImpCta       :=oDp:cImpCta    // Cuenta
  oDefFis:cImpCmd       :=oDp:cImpCmd    // Comada
  oDefFis:cDenFiscal    :=PADR(oDp:cDenFiscal,15)
  oDefFis:cDisp_Com     :=oDp:cDisp_Com
  oDefFis:cDisp_nBaude  :=CTOO(oDp:cDisp_nBaude ,"N")
  oDefFis:cDisp_nBits   :=CTOO(oDp:cDisp_nBits  ,"N")
  oDefFis:cDisp_nparity :=CTOO(oDp:cDisp_nparity,"N")
  oDefFis:cDisp_nstopbit:=oDp:cDisp_nstopbit
  oDefFis:cDisp_lDisplay:=oDp:cDisp_lDisplay
  oDefFis:cDisp_lGaveta :=oDp:cDisp_lGaveta   // Impresora Incluye Gaveta
  oDefFis:cDisp_nLen    :=20  // Caracteres 
  oDefFis:cFileBal      :=PADR(oDp:cFileBal,60)
  oDefFis:lTactil       :=oDp:lTactil
  oDefFis:lDelivery     :=oDp:lDelivery
  oDefFis:lMsgBar       :=.F.
  oDefFis:cModelo       :=oDp:cModeloPos
  oDefFis:cUndMed       :=oDp:cUndMedPos
  oDefFis:aTipPre       :=aTipPre  
  oDefFis:aTipUnd       :=aTipUnd
  oDefFis:aUndMed       :=aUndMed
  oDefFis:cPrecio       :=aPrecio[MAX(ASCAN(aTipPre,oDp:cPrecioPos),1)]
  oDefFis:cUndMed       :=aUndMed[MAX(ASCAN(aTipUnd,oDp:cUndMedPos),1)]
  oDefFis:nPorSer       :=CTOO(oDp:nPorSerPos,"N")
  oDefFis:nPorReg       :=oDp:nPorReg
  oDefFis:cCodSer       :=PADR(oDp:cCodSer  ,20)  // Codigo del Producto Servicios
  oDefFis:cCodTrans     :=PADR(oDp:cCodTrans,20)  // Codigo del Transporte 
  oDefFis:cCajaDeli     :=oDp:cCajaDeli           // Caja Delivery
  oDefFis:cCajaPos      :=oDp:cCajaPos            // Caja Punto de Venta
  oDefFis:lDpPosCli     :=oDp:lDpPosCli           // Requiere Cliente en Punto de Venta
  oDefFis:lDpPosPeso    :=oDp:lDpPosPeso          // Columna Peso
  oDefFis:cPostRun      :=cPostRun
  oDefFis:cSerFiscal    :=cSerFiscal
  oDefFis:cPcName       :=cPcName
  oDefFis:cTipDocVta    :=oDp:cTipDocVta
  oDefFis:cTipDocDev    :=oDp:cTipDocDev 

  oDefFis:cFileBal      :=STRTRAN(oDefFis:cFileBal,"\"+"\","\")

  oDefFis:SetScroll(0,10,0,0)
  oDefFis:CreateWindow()       // Presenta la Comprana

  @ .1,.5 GROUP oGrp TO 10,10 PROMPT "Serie Fiscal"

  @ 2,.5 GROUP oGrp TO 10,10 PROMPT "Configuración Display "

  @ 5,.5 GROUP oGrp TO 10,10 PROMPT "Datos de Balanza Bizerva "

//  @ 5,.5 GROUP oGrp TO 10,10 PROMPT " Monitor Punto de Venta "

  @ 12,.5 GROUP oGrp TO 13,50 PROMPT " Parámetros "

  @ 12,.5 GROUP oGrp TO 13,50 PROMPT " Caja Delivery "
  @ 12,.5 GROUP oGrp TO 13,50 PROMPT " Caja Venta "
  @ 14,.5 GROUP oGrp TO 16,50 PROMPT " Tipo de Documento "

  @ 12,.5 GROUP oGrp TO 13,50 PROMPT " Restaurante "



  // @ 1.6, 06.0 COMBOBOX oDefFis:oImpFiscal VAR oDefFis:cImpFiscal ITEMS aDefImp
  // ComboIni(oDefFis:oImpFiscal)

  @ 1.6, 06.0 COMBOBOX oDefFis:oSerFiscal VAR oDefFis:cSerFiscal ITEMS aSerFis;
              WHEN LEN(oDefFis:oSerFiscal:aItems)>1
 
  ComboIni(oDefFis:oSerFiscal)

  @ 0,0 CHECKBOX oDefFis:cDisp_lGaveta  PROMPT "Incluye Gaveta";
                 WHEN ALLTRIM(UPPE(oDefFis:cImpFiscal))<>"NINGUNA"

  @ 0,0 CHECKBOX oDefFis:cDisp_lDisplay PROMPT "Usar Display"

  @ 0,0 CHECKBOX oDefFis:lTactil PROMPT ANSITOOEM("Táctil")

  @12,0 CHECKBOX oDefFis:lDelivery PROMPT ANSITOOEM("Delivery")

  @ 4,1 SAY "Puerto:" RIGHT

  @ 4.6, 06.0 COMBOBOX oDefFis:oDisp_Com VAR oDefFis:cDisp_Com ITEMS aComs;
              WHEN oDefFis:cDisp_lDisplay
 
  ComboIni(oDefFis:oDisp_Com)

  @ 5,1 SAY "Baudios:" RIGHT
  @ 5.6, 06.0 GET oDefFis:cDisp_nBaude PICTURE "99999" RIGHT ;
              WHEN oDefFis:cDisp_lDisplay


  @ 6,1 SAY "Bits:" RIGHT
  @ 6.6, 06.0 GET oDefFis:cDisp_nBits PICTURE "9" RIGHT ;
              WHEN oDefFis:cDisp_lDisplay


  @ 8,1 SAY "Parity:" RIGHT
  @ 8.6, 06.0 GET oDefFis:cDisp_nparity PICTURE "9" RIGHT;
              WHEN oDefFis:cDisp_lDisplay
 

  @ 7,1 SAY "Stop:" RIGHT
  @ 7.6, 06.0 GET oDefFis:cDisp_nparity PICTURE "9" RIGHT;
              WHEN oDefFis:cDisp_lDisplay
 
  @ 8,1 SAY "Longitud :" RIGHT
  @ 8.6, 06.0 GET oDefFis:cDisp_nLen  PICTURE "99" RIGHT;
              WHEN oDefFis:cDisp_lDisplay


  // Uso   : Archivo de la BaLanza
  //
  @ 6.4, 1.0 BMPGET oDefFis:oDefFis_FILBAL  VAR oDefFis:cFileBal ;
                    NAME "BITMAPS\FIND.BMP"; 
                    ACTION (cFile:=cGetFile32("Bmp File (*.BAL) |*.BAL|Archivos de la Balanza (*.BAL) |*.BAL",;
                    "Seleccionar Archivo Balanza (BAL)",1,cFilePath(oDefFis:cFileBal),.f.,.t.),;
                    cFile:=STRTRAN(cFile,"\","/"),;
                    oDefFis:cFileBal:=IIF(!EMPTY(cFile),cFile,oDefFis:cFileBal),;
                    oDefFis:oDefFis_FILBAL:Refresh());
                    WHEN .T.


  // Uso   : Caja para Delivery
  //

  @ .1,06 BMPGET oDefFis:oCajaDeli VAR oDefFis:cCajaDeli;
                 VALID oDefFis:VALCAJDELI();
                 NAME  "BITMAPS\CLIENTE2.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPCAJA",NIL,"1=1"),;
                         oDpLbx:GetValue("CAJ_CODIGO",oDefFis:oCajaDeli)); 
                 SIZE 48,10


  @ .1,06 BMPGET oDefFis:oCajaPos VAR oDefFis:cCajaPos;
                 VALID oDefFis:VALCAJPOS();
                 NAME  "BITMAPS\CLIENTE2.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPCAJA",NIL,"1=1"),;
                         oDpLbx:GetValue("CAJ_CODIGO",oDefFis:oCajaPos)); 
                 SIZE 48,10


// 05/08/2022
/*
  @ 10.6, 06.0 GET oDefFis:cDenFiscal; 
               VALID oDefFis:ValDenFiscal();
               WHEN UPPE(ALLTRIM(oDefFis:cImpFiscal))!="NINGUNA"
*/

  @ 1,30 SAY "Modelo"
  @ 1.6, 06.0 COMBOBOX oDefFis:oModelo VAR oDefFis:cModelo ITEMS aModelo
 
  ComboIni(oDefFis:oModelo)

  @ 2,30 SAY "Precio de Venta"

  @ 2.6, 06.0 COMBOBOX oDefFis:oPrecio VAR oDefFis:cPrecio ITEMS aPrecio

  ComboIni(oDefFis:oPrecio)

  @ 3,30 SAY "Unidad de Medida"

  @ 3.6, 06.0 COMBOBOX oDefFis:oUndMed VAR oDefFis:cUndMed ITEMS aUndMed;
              WHEN LEN(oDefFis:oUndMed:aItems)>1

  ComboIni(oDefFis:oUndMed)

  @ 8,30 SAY "Impresora Comanda"

  @ 9.6, 16.0 COMBOBOX oDefFis:oImpCmd VAR oDefFis:cImpCmd ITEMS aImpCmd

  ComboIni(oDefFis:oImpCmd)


  @ 8,30 SAY "Impresora Cuenta"

  @ 9.6, 16.0 COMBOBOX oDefFis:oImpCta VAR oDefFis:cImpCta ITEMS aImpCta

  ComboIni(oDefFis:oImpCta)


  @ 3,30 SAY "% por Servicio"

  @ 10.6, 10 GET oDefFis:nPorSer; 
             PICTURE "99.99";
             RIGHT;
             VALID oDefFis:nPorSer>=0;
             WHEN "RESTAURANT"=UPPE(oDefFis:cModelo)



  @ 3,30 SAY "Servicio de Mesa "

/*
  @ 10.6, 10 GET oDefFis:nPorReg; 
             PICTURE "99.99";
             RIGHT;
             VALID oDefFis:nPorReg>=0;
             WHEN "FARMACIA"=UPPE(oDefFis:cModelo)
*/

  // Uso   : Código del Producto Servicio 10%
  //

  @ 1, 1.0 BMPGET oDefFis:oCodSer  VAR oDefFis:cCodSer ;
                  NAME "BITMAPS\MESAS2.BMP"; 
                  ACTION (oDpLbx:=DpLbx("DPINV_SERVICIOS.LBX","Servicios de Mesa",NIL,NIL,NIL,NIL,NIL,NIL,NIL,oDefFis:oCodSer),;
                          oDpLbx:GetValue("INV_CODIGO",oDefFis:oCodSer)); 
                  VALID oDefFis:VALCODSER();
                  WHEN "RESTAURANT"=UPPE(oDefFis:cModelo)


  // Uso   : Código del Transporte
  //
  @ 3,30 SAY "Servicio de Flete"

  @ 1, 1.0 BMPGET oDefFis:oCodTrans  VAR oDefFis:cCodTrans ;
                  NAME "BITMAPS\DELIVERY2.BMP"; 
                  ACTION (oDpLbx:=DpLbx("DPINV_SERVICIOS.LBX","Servicio de Flete",nil,nil,nil,nil,nil,nil,nil,oDefFis:oCodTrans),;
                          oDpLbx:GetValue("INV_CODIGO",oDefFis:oCodTrans)); 
                  VALID oDefFis:VALCodTrans();
                  WHEN .T.

//"RESTAURANT"=UPPE(oDefFis:cModelo)

  @ 12, 1.0 SAY oDefFis:oSayCajaDeli PROMPT MYSQLGET("DPCAJA","CAJ_NOMBRE","CAJ_CODIGO"+GetWhere("=",oDefFis:cCajaDeli))
  @ 12, 1.0 SAY oDefFis:oSayCajaPos  PROMPT MYSQLGET("DPCAJA","CAJ_NOMBRE","CAJ_CODIGO"+GetWhere("=",oDefFis:cCajaPos ))

  @ 12,2 CHECKBOX oDefFis:lDpPosCli  PROMPT "Cliente (Obligatorio)"
  @ 12,2 CHECKBOX oDefFis:lDpPosPeso PROMPT "Columna Peso"


  // 	
  // Uso   : Tipo de Documento para  Venta
  //

  @ 17,01 SAY "Facturación"

  @ 18,01 BMPGET oDefFis:oTipDocVta VAR oDefFis:cTipDocVta;
                 VALID oDefFis:VALTIPDOCVTA();
                 NAME  "BITMAPS\find22.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPTIPDOCCLI.LBX",NIL,"TDC_PRODUC=1 AND TDC_ACTIVO=1 AND TDC_CXC"+GetWhere("<>","C"),NIL,NIL,NIL,NIL,NIL,NIL,oDefFis:oTipDocVta),;
                         oDpLbx:GetValue("TDC_TIPO",oDefFis:oTipDocVta)); 
                 SIZE 48,10

  @ 18, 50 SAY oDefFis:oSayTipDocVta PROMPT SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oDefFis:cTipDocVta))

  @ 19,01 SAY "Devolución"

  @ 20,01 BMPGET oDefFis:oTipDocDev VAR oDefFis:cTipDocDev;
                 VALID oDefFis:VALTIPDOCDEV();
                 NAME  "BITMAPS\find22.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPTIPDOCCLI.LBX",NIL,"TDC_PRODUC=1 AND TDC_ACTIVO=1 AND TDC_CXC"+GetWhere("=","C"),NIL,NIL,NIL,NIL,NIL,NIL,oDefFis:oTipDocDev),;
                         oDpLbx:GetValue("TDC_TIPO",oDefFis:oTipDocDev)); 
                 SIZE 48,10

  @ 20, 50 SAY oDefFis:oSayTipDocDev PROMPT SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oDefFis:cTipDocDev))


  @ 12, 10 SAY oDefFis:oSayCodServicio PROMPT MYSQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oDefFis:cCodSer  ))
  @ 13, 10 SAY oDefFis:oSayCodTrans    PROMPT MYSQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oDefFis:cCodTrans))

  oDefFis:Activate({||oDefFis:INICIO()})

RETURN .t.


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oDefFis:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD


   IF oDefFis:nOption!=2

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
            ACTION (oDefFis:SetFiscal())

     oBtn:cToolTip:="Guardar"

     oDefFis:oBtnSave:=oBtn

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\impresoratxt.BMP";
            ACTION DPLBX("DPEQUIPOSPOS.LBX")

     oBtn:cToolTip:="Impresoras Fiscales, para cada PC"

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\facturavta.BMP";
            ACTION DPLBX("DPSERIEFISCAL.LBX")

     oBtn:cToolTip:="Series Fiscales"



     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XCANCEL.BMP";
            ACTION (oDefFis:Cancel()) CANCEL


   
   ELSE


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            ACTION (oDefFis:Cancel()) CANCEL

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })


 
RETURN .T.



FUNCTION SetFiscal()

  LOCAL oData

  //IF ALLTRIM(UPPE(oDefFis:cImpFiscal))="NINGUNA"
  //  oDefFis:cDisp_lGaveta:=.F.
  //ENDIF

  oData:=DATACONFIG("POS","PC",,,,,,oDp:cPcName) // 28/11/2023 evitamos el cambio de IP oDefFis:cIp)

  // 05/08/2022, Seleccionar Serie fiscal sera desactivado todas las formas fiscale para este PC
  SQLUPDATE("DPSERIEFISCAL","SFI_PCNAME",""             ,"SFI_PCNAME"+GetWhere("=",oDefFis:cPcName  ))
//,"SFI_MODELO"+GetWhere("=",oDefFis:cSerFiscal))
  SQLUPDATE("DPSERIEFISCAL",{"SFI_PCNAME","SFI_ACTIVO"},{oDefFis:cPcName,.T.},"SFI_MODELO"+GetWhere("=",oDefFis:cSerFiscal))

// "SFI_PCNAME"+GetWhere("=",cPcName))
// ? oDefFis:cSerFiscal,"oDefFis:cSerFiscal"

  oData:Set("cImpFiscal"    ,oDefFis:cImpFiscal    )
  oData:Set("cSerFiscal",   ,oDefFis:cSerFiscal    )
  oData:Set("cDisp_Com"     ,oDefFis:cDisp_Com     )
  oData:Set("cDisp_nBaude"  ,oDefFis:cDisp_nBaude  ) 
  oData:Set("cDisp_lDisplay",oDefFis:cDisp_lDisplay)
  oData:Set("cDisp_nBits"   ,oDefFis:cDisp_nBits   )
  oData:Set("cDisp_nstopbit",oDefFis:cDisp_nstopbit)
  oData:Set("cDisp_lGaveta" ,oDefFis:cDisp_lGaveta )
  oData:Set("cDisp_nLen"    ,oDefFis:cDisp_nLen    )
  oData:Set("cFileBal"      ,oDefFis:cFileBal      )
  oData:Set("lTactil"       ,oDefFis:lTactil       )
  oData:Set("cDenFiscal"    ,oDefFis:cDenFiscal    )
  oData:Set("cModelo"       ,oDefFis:cModelo       )
  oData:Set("cPrecio"       ,oDefFis:aTipPre[oDefFis:oPrecio:nAt])
  oData:Set("cUndMed"       ,oDefFis:aUndMed[oDefFis:oUndMed:nAt])
  oData:Set("nPorSer"       ,oDefFis:nPorSer       ) // % por Servicio

  oData:Set("nPorReg"       ,oDefFis:nPorReg	   ) //Producto Regulado
  oData:Set("cImpCta"       ,oDefFis:cImpCta       )
  oData:Set("cImpCmd"       ,oDefFis:cImpCmd       ) // Comada
  oData:Set("cCodSer"       ,oDefFis:cCodSer       ) // Código Servicio
  oData:Set("cCodTrans"     ,oDefFis:cCodTrans     ) // Transporte
  oData:Set("lDelivery"     ,oDefFis:lDelivery     ) // Delivery
  oData:Set("cCajaDeli"     ,oDefFis:cCajaDeli     ) // Caja Delivery
  oData:Set("cCajaPos"      ,oDefFis:cCajaPos      ) // Caja POS
  oData:Set("lDpPosCli"     ,oDefFis:lDpPosCli     ) // Requiere Cliente en Punto de Venta
  oData:Set("lDpPosPeso"    ,oDefFis:lDpPosPeso    ) // Requiere Cliente en Punto de Venta

  oData:Set("cTipDocVta",oDefFis:cTipDocVta) // Facturación
  oData:Set("cTipDocDev",oDefFis:cTipDocDev) // Devoluciones

  oData:Save()
  oData:End(.F.)
  

  IF oDefFis:cIp=oDp:cIpLocal
     EJECUTAR("DPPOSLOAD",oDefFis:cIp)
  ELSE
     EJECUTAR("DPPOSLOAD")
  ENDIF

  oDefFis:Close()

  EJECUTAR("DISPRUN")

  IF !Empty(oDefFis:cPostRun)
     EJECUTAR(oDefFis:cPostRun)
  ENDIF

RETURN .T.

FUNCTION VALCODSER()

  IF !ISMYSQLGET("DPINV","INV_CODIGO",oDefFis:cCodSer)
     oDefFis:oCodSer:KeyBoard(VK_F6)
     RETURN .T.
  ENDIF

RETURN .T.

FUNCTION VALCODTRANS()

  IF !ISMYSQLGET("DPINV","INV_CODIGO",oDefFis:cCodTrans)
     oDefFis:oCodTrans:KeyBoard(VK_F6)
     RETURN .T.
  ENDIF

RETURN .T.



FUNCTION ValDenFiscal()

   IF Empty(oDefFis:cDenFiscal)

      MensajeErr("Es necesario Denominar a la Impresora Fiscal"+CRLF+;
                 "para lograr emitir libro de Venta por Impresora","Impresora Fiscal Requiere Denominación")

     oDefFis:cDenFiscal:=PADR("UNICA",15)

   ENDIF

RETURN .T.

FUNCTION VALCAJDELI()

   IF !ISSQLGET("DPCAJA","CAJ_CODIGO",oDefFis:cCajaDeli)
      oDefFis:oCajaDeli:KeyBoard(VK_F6)
      RETURN .T.
   ENDIF

   oDefFis:oSayCajaDeli:Refresh(.T.)

RETURN .T.


FUNCTION VALCAJPOS()

   IF !ISSQLGET("DPCAJA","CAJ_CODIGO",oDefFis:cCajaPos)
      oDefFis:oCajaPos:KeyBoard(VK_F6)
      RETURN .T.
   ENDIF

   oDefFis:oSayCajaPos:Refresh(.T.)

RETURN .T.

FUNCTION VALTIPDOCVTA()
   LOCAL cWhere:="TDC_TIPO"+GetWhere("=",oDefFis:cTipDocVta)+" AND TDC_PRODUC=1 AND TDC_ACTIVO=1 AND TDC_CXC"+GetWhere("=","D")

   oDefFis:oSayTipDocVta:Refresh(.T.)

   IF !ISSQLFIND("DPTIPDOCCLI",cWhere)
     oDefFis:oTipDocVta:KeyBoard(VK_F6)
     RETURN .T.
   ENDIF

   oDefFis:oSayTipDocVta:Refresh(.T.)

RETURN .T.

FUNCTION VALTIPDOCDEV()
   LOCAL cWhere:="TDC_TIPO"+GetWhere("=",oDefFis:cTipDocDEV)+" AND TDC_PRODUC=1 AND TDC_ACTIVO=1 AND TDC_CXC"+GetWhere("=","C")

   oDefFis:oSayTipDocDEV:Refresh(.T.)

   IF !ISSQLFIND("DPTIPDOCCLI",cWhere)
     oDefFis:oTipDocDEV:KeyBoard(VK_F6)
     RETURN .T.
   ENDIF

   oDefFis:oSayTipDocDEV:Refresh(.T.)

RETURN .T.

// EOF

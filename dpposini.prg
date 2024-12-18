// Programa   : DPPOSINI
// Fecha/Hora : 25/05/2006 00:56:53
// Prop�sito  : Iniciaci�n del Punto de Venta
// Creado Por : Juan Navas
// Llamado por: MENU 
// Aplicaci�n :
// Tabla      :
// 31-07-2009  Se inabilito las lineas para que el usuario pueda entrar nuevamente al punto de venta
// luego de ejecutado el reporte Z.


#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL dFecha,i,,ancho:=IIF(AT(" ",oDp:cImpFiscal)>0,AT(" ",oDp:cImpFiscal)-1,LEN(oDp:cImpFiscal))

   LOCAL lOk

   DEFAULT oDp:dFechaChk:=CTOD("")

   EJECUTAR("DPPOSLOAD"      ) // Valores del Display Serial Debe ser Ejecutado desde el Punto de Venta

   // Aqui Validamos el PC
   // 16-10-2008 Marlon Ramos (Traer el serial de la impresora) IF !(MYSQLGET("DPEQUIPOSPOS","EPV_IP,EPV_SERIEF,EPV_NUMERO","EPV_IP"+GetWhere("=",oDp:cPcName))=oDp:cPcName)

/*
// 17/11/2023 No necesita validar la impresora fiscal

   IF !(UPPER(SQLGET("DPEQUIPOSPOS","EPV_IP,EPV_SERIEF,EPV_NUMERO,EPV_IMPFIS","EPV_IP"+GetWhere("=",oDp:cPcName)))=UPPER(oDp:cPcName))
      MensajeErr("PC, Indentificado con Nombre :["+oDp:cPcName+"] no est� Autorizado para Generar Ventas"+CRLF+;
                 "Debe Asignarlo en ["+oDp:DPEQUIPOSPOS+"]")
      RETURN .F.
   ENDIF

   oDp:cTkSerie :=oDp:aRow[2]
   oDp:cTkNumero:=oDp:aRow[3]
   oDp:cTkImpSer:=oDp:aRow[4]   // 16-10-2008 Marlon Ramos (Hacer accesible el serial de la impresora.)


   IF SQLGET("DPTABXUSU","TXU_CODUSU","TXU_CODUSU"+GetWhere("=",oDp:cUsuario)+" AND "+;
                                      "TXU_CODIGO"+GetWhere("=",oDp:cTkSerie)+" AND "+;
                                      "TXU_TABLA='DPEQUIPOSPOS' AND TXU_PERMIS=0")=oDp:cUsuario


     MensajeErr("Usuario "+oDp:cUsuario+" no est� Autorizado para el PC "+oDp:cIpLocal+CRLF+;
                "Es necesario otorgar Permisos en ["+oDp:DPEQUIPOSPOS+"]")

     RETURN .T.

   ENDIF
*/

   // Buscamos el Ultimo dia Trabajado, para verificar si realiz� reporte Zeta.
   dFecha:=MYSQLGET("DPPOSUSUARIO","MAX(RDP_FECHA)","RDP_US"+GetWhere("=",oDp:cUsuario)+" AND RDP_FECHA"+GetWhere("<",oDp:dFecha))

   // Ultimo dia de Trabajo
   // 15-10-2008 Marlon Ramos (Bematech hace cierres automaticos - Se agrega Samsung) IF (!Empty(dFecha) .AND. (oDp:cImpFiscal$"Bematech,BMC,Epson")) 
  // 27-01-2009 Marlon Ramos (Se agrega ACLAS)   IF (!Empty(dFecha) .AND. (UPPER(oDp:cImpFiscal)$"SAMSUNG,BMC,EPSON")) 
   IF (!Empty(dFecha) .AND. (UPPER(LEFT(oDp:cImpFiscal,ancho))$"ACLAS,SAMSUNG,BMC,EPSON,OKIDATA,STAR"))
   //IF (!Empty(dFecha) .AND. (UPPER(oDp:cImpFiscal)$"SAMSUNG,BMC,EPSON")) 

       oDp:dFechaChk:=oDp:dFecha

       //?"AUD_CLAVE"  ,oDp:cImpFiscal,"AUD_TIPO","PROC","AUD_FECHAS",dFecha,"AUD_ESTACI",LEFT(oDp:cPcName,10),oDp:cImpFiscal

       IF MYSQLGET("DPAUDITOR","AUD_CLAVE","AUD_CLAVE"  +GetWhere("=",oDp:cImpFiscal  )+" AND "+;
                                           "AUD_TIPO"   +GetWhere("=","PROC"              )+" AND "+;
                                           "AUD_FECHAS" +GetWhere("=",dFecha              )+" AND "+;
                                           "AUD_ESTACI" +GetWhere("=",LEFT(oDp:cPcName,10))) != oDp:cImpFiscal

          MensajeErr("No ha sido Realizado el Reporte Zeta para la Impresora "+oDp:cImpFiscal+;
                     CRLF+"Cambie la fecha del Sistema con el dia "+DTOC(dFecha))

          oDp:dFecha:=dFecha
          EJECUTAR("DPFECHA",BLOQUECOD("EJECUTAR('BEMAMENU')"))

          RETURN .F.

        ENDIF

   ENDIF

/* Inabilitadas
   // 15-10-2008 Marlon Ramos (Se agrega Samsung) IF (oDp:cImpFiscal$"Bematech,BMC,Epson") 
   // 27-01-2009 Marlon Ramos (Se agrega ACLAS)   IF UPPER(oDp:cImpFiscal)$"BEMATECH,BMC,EPSON,SAMSUNG"
   IF UPPER(LEFT(oDp:cImpFiscal,ancho))$"ACLAS,BEMATECH,BMC,EPSON,SAMSUNG,OKIDATA"

       IF MYSQLGET("DPAUDITOR","AUD_CLAVE","AUD_CLAVE"  +GetWhere("=",oDp:cImpFiscal  )+" AND "+;
                                           "AUD_TIPO"   +GetWhere("=","PROC"          )+" AND "+;
                                           "AUD_FECHAS" +GetWhere("=",oDp:dFecha      )+" AND "+;
                                           "AUD_ESTACI" +GetWhere("=",LEFT(oDp:cPcName,10)))= oDp:cImpFiscal

          MensajeErr("Este PC "+oDp:cPcName+" ya Ejecut� el Reporte Zeta para la Impresora "+oDp:cImpFiscal+;
                     CRLF+"con la fecha actual "+DTOC(oDp:dFecha))

          IF !Empty(oDp:dFechaChk)
             oDp:dFecha:=oDp:dFechaChk
             EJECUTAR("DPFECHA",{||EJECUTAR("DPPOSINI")})
          ENDIF

          RETURN .F.

        ENDIF

   ENDIF
*/

   // Aqui Validamos que el Usuario ya se Inicio
   IF SQLGET("DPPOSUSUARIO","RDP_US","RDP_US"+GetWhere("=",oDp:cUsuario)+" AND RDP_FECHA"+GetWhere("=",oDp:dFecha))!=oDp:cUsuario
      EJECUTAR("DPPOSREGUS")
      RETURN .F.  
   ENDIF

   // 15-10-2008 Marlon Ramos (Se agrega Samsung) IF (oDp:cImpFiscal$"Bematech,BMC,Epson,Epson") 
   // 27-01-2009 Marlon Ramos (Se agrega ACLAS)      IF UPPER(oDp:cImpFiscal)$"BEMATECH,BMC,EPSON,SAMSUNG"
   IF UPPER(LEFT(oDp:cImpFiscal,ancho))$"ACLAS,BEMATECH,BMC,EPSON,SAMSUNG,OKIDATA,STAR"
      DPSETTIMER({||EJECUTAR('PRCRUN','CIERREIMPFISCAL')},"CIERREFISCAL",5)
   ENDIF

   IF oDp:cModeloPos="Restaurant"
      RETURN EJECUTAR("DPPOSCOMANDA",.F.)
   ENDIF

   IF oDp:cModeloPos="Farmacia"
      RETURN EJECUTAR("DPPOSFARMACIA",.F.)
   ENDIF

   EJECUTAR("DPPOS01")     

RETURN .T.
// EOF

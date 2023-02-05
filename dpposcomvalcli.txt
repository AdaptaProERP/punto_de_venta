// Programa   : DPPOSCOMVALCLI
// Fecha/Hora : 26/10/2006 15:04:13
// Propósito  : Validar Codigo RIF del Cliente
// Creado Por : Juan Navas
// Llamado por: DPPOSCOMANDA
// Aplicación : Ventas
// Tabla      : DPCLIENTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

   LOCAL oTable,lFound:=.F.

   IF Empty(oPOSCOMANDA:cRif)
      RETURN .T.
   ENDIF

   oTable:=OpenTable("SELECT CLI_CODIGO,CLI_NOMBRE,CLI_DIR1,CLI_DIR2,CLI_DIR3,CLI_PARROQ,CLI_MUNICI,CLI_TEL1,CLI_TEL2 FROM DPCLIENTES "+;
           " WHERE CLI_RIF"+GetWhere("=",oPOSCOMANDA:cRif))

   IF oTable:RecCount()>0

      lFound:=.T.

      oPOSCOMANDA:oNombre:VarPut(oTable:CLI_NOMBRE,.T.)
      oPOSCOMANDA:oDir1:VarPut(oTable:CLI_DIR1,.T.)
      oPOSCOMANDA:oDir2:VarPut(oTable:CLI_DIR2,.T.)
      oPOSCOMANDA:oDir3:VarPut(oTable:CLI_DIR3,.T.)

      oPOSCOMANDA:oTel1:VarPut(oTable:CLI_TEL1,.T.)
      oPOSCOMANDA:oTel2:VarPut(oTable:CLI_TEL2,.T.)

      oPOSCOMANDA:cZona  :=oTable:CLI_PARROQ
      oPOSCOMANDA:cMunici:=oTable:CLI_MUNICI

      ComboIni(oPOSCOMANDA:oMuni)
      ComboIni(oPOSCOMANDA:oZona)

      Eval(oPOSCOMANDA:oZona:bChange)

      DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)

   ENDIF

   oTable:End()

   IF !lFound

      oTable:=OpenTable("SELECT CCG_NOMBRE,CCG_DIR1,CCG_DIR2,CCG_DIR3,CCG_DIR4 AS ZONA,CCG_TEL1,CCG_TEL2 FROM DPCLIENTESCERO "+;
                        " WHERE CCG_RIF"+GetWhere("=",oPOSCOMANDA:cRif)+" ORDER BY CCG_NUMDOC DESC LIMIT 1",.T.)

      IF oTable:RecCount()>0

        oPOSCOMANDA:oNombre:VarPut(oTable:CCG_NOMBRE,.T.)
        oPOSCOMANDA:oDir1:VarPut(oTable:CCG_DIR1,.T.)
        oPOSCOMANDA:oDir2:VarPut(oTable:CCG_DIR2,.T.)
        oPOSCOMANDA:oDir3:VarPut(oTable:CCG_DIR3,.T.)

        oPOSCOMANDA:oTel1:VarPut(oTable:CCG_TEL1,.T.)
        oPOSCOMANDA:oTel2:VarPut(oTable:CCG_TEL2,.T.)

//        oPOSCOMANDA:cZona:=oTable:ZONA
//        ComboIni(oPOSCOMANDA:oZona)
//        Eval(oPOSCOMANDA:oZona:bChange)
        DPFOCUS(oPOSCOMANDA:oCOM_CODIGO)

        lFound:=.T.

      ENDIF

   ENDIF
 
   oPOSCOMANDA:aDirE:=ASQL("SELECT DIR_DIR1,DIR_DIR2,DIR_DIR3,DIR_COMEN1,DIR_COMEN2,DIR_TELEFO FROM DPDOCCLIDIR WHERE DIR_DIRIGI"+;
                           GetWhere("=",oPOSCOMANDA:cRif)+;
                           " GROUP BY DIR_DIR1,DIR_DIR2,DIR_DIR3,DIR_COMEN1,DIR_COMEN2,DIR_TELEFO ")

  
   IF LEN(oPOSCOMANDA:aDirE)>0

      oPOSCOMANDA:nDir:=1
      oPOSCOMANDA:NEXTDIR(0)

   ELSE

     // No tiene Direccion de Entrega

     oPOSCOMANDA:oDirE1:VarPut(CTOEMPTY(oPOSCOMANDA:cDirE1),.T.)
     oPOSCOMANDA:oDirE2:VarPut(CTOEMPTY(oPOSCOMANDA:cDirE1),.T.)
     oPOSCOMANDA:oDirE3:VarPut(CTOEMPTY(oPOSCOMANDA:cDirE1),.T.)

   ENDIF

   oPOSCOMANDA:CALTARIFA()

RETURN .T.
// EOF


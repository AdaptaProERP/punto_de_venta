// Programa   : DPSERIEFISCALLOAD
// Fecha/Hora : 27/07/2022 23:59:34
// Propósito  : Cargar variables de la Impresora Fiscal
// Creado Por : Juan Navas, 
// Llamado por: DPPOS04, DPFACTURAV
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,lSay)
   LOCAL oSerFis,lResp:=.T.

   oDp:nImpFisEntPre:=0
   oDp:nImpFisEntCan:=0

   DEFAULT cWhere:="SFI_PCNAME"+GetWhere("=",oDp:cPcName),;
           lSay  :=.T.


   oSerFis     :=OpenTable("SELECT * FROM DPSERIEFISCAL WHERE "+cWhere,.T.) // SFI_PCNAME"+GetWhere("=",oDp:cPcName))

   IF oSerFis:RecCount()=0 .AND. lSay
      lResp:=.F.
//? CLPCOPY(oDp:cSql)
      MsgMemo("Este PC "+oDp:cPcName+" no tiene Serie Fiscal Asignada")
      DPLBX("DPSERIEFISCAL.LBX")
     // ? oDp:cSql,"SERIE FISCAL NO ENCONTRADO"
     // oSerFis:Browse()
   ENDIF
  
   
   // 07/07/2022
   oDp:cImpFiscal   :=oSerFis:SFI_IMPFIS
   oDp:cImpLetra    :=oSerFis:SFI_LETRA

   oDp:cImpFisCom   :=ALLTRIM(oSerFis:SFI_PUERTO)
   oDp:nImpFisLen   :=oSerFis:SFI_ANCHO

   oDp:nImpFisEntPre:=oSerFis:SFI_PREENT
   oDp:nImpFisDecPre:=oSerFis:SFI_PREDEC

   oDp:nImpFisEntCan:=oSerFis:SFI_CANENT
   oDp:nImpFisDecCan:=oSerFis:SFI_CANDEC
   oDp:cTkSerie     :=oSerFis:SFI_LETRA
   oDp:cImpFisSer   :=oSerFis:SFI_SERIMP // Serial Impresora
   oDp:lImpFisModVal:=oSerFis:SFI_MODVAL // Impresora Fiscal en Modelo Evaluación
   oDp:lImpFisRegAud:=oSerFis:SFI_REGAUD // Registro de Auditoría

   oDp:nImpFisEntPre:=IF(oDp:nImpFisEntPre=0,14,oDp:nImpFisEntPre)
   oDp:nImpFisDecPre:=IF(oDp:nImpFisDecPre=0,02,oDp:nImpFisDecPre)

   oDp:nImpFisEntCan:=IF(oDp:nImpFisEntCan=0,14,oDp:nImpFisEntCan)
   oDp:nImpFisDecCan:=IF(oDp:nImpFisDecCan=0,02,oDp:nImpFisDecCan)

   IF "Ningu"$oDp:cImpFiscal

      oDp:cImpPuerto:=""
      oDp:cImpFisCom:=""
      oDp:cImpLetra :=""

      oDp:nImpFisEntPre:=0
      oDp:nImpFisDecPre:=0

      oDp:nImpFisEntCan:=0
      oDp:nImpFisDecCan:=0
   ENDIF

   oSerFis:End(.T.) 

// ? oDp:cImpFiscal

RETURN lResp
// EOF

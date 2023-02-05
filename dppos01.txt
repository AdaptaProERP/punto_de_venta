// Programa   : DPPOS01
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

   DEFAULT lConfig:=.F.

RETURN EJECUTAR("DPPOS04",lConfig)
// EOF

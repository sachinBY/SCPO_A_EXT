%dw 2.0
var fcst = vars.outboundUDCs.fcst[0].dfutoskufcst[0]
var funCaller = readUrl("classpath://dwl/date-util.dwl")
var DEFAULT_VALUE='DEFAULT'
fun typeDecider(data)= if(data == '1') 'BASE' else if(data == '2') 'AGG_MKT_ACT' else if(data == '3') 'ST_FCST_LCK_ADJ' else if(data=='4') 'RECONCILE' else if(data == '5') 'PROMOTIONAL' else if(data == '6') 'OVERRIDE' else if(data=='7') 'MKT_ACT' else if(data=='8') 'DT_DRV_EVNT' else if(data=='9') 'TRG_IMP' else if(data=='99') 'MIG_EVNT' else DEFAULT_VALUE
output application/java
---
(payload groupBy ((item, index) -> item.ITEM ++ "-" ++ item.SKULOC ++ "-" ++ item.DMDGROUP ++ "-" ++ item.TYPE ++ "-" ++ item.STARTDATE ++ "-" ++ item.DUR) mapObject ((value, key, index) -> values:{
    ITEM: value.ITEM[0],
 	SKULOC: value.SKULOC[0],
 	DMDGROUP: value.DMDGROUP[0],
 	TYPE: typeDecider(value.TYPE[0] as String),
 	STARTDATE: value.STARTDATE[0] >> "UTC",
 	DUR: value.DUR[0],
 	TOTFCST: sum(value.TOTFCST)
}
)).*values
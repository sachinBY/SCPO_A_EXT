%dw 2.0
output application/csv
var DEFAULT_VALUE='DEFAULT'
fun typeDecider(data)= if(data == '1') 'BASE' else if(data == '2') 'AGG_MKT_ACT' else if(data == '3') 'ST_FCST_LCK_ADJ' else if(data=='4') 'RECONCILE' else if(data == '5') 'PROMOTIONAL' else if(data == '6') 'OVERRIDE' else if(data=='7') 'MKT_ACT' else if(data=='8') 'DT_DRV_EVNT' else if(data=='9') 'TRG_IMP' else if(data=='99') 'MIG_EVNT' else DEFAULT_VALUE
---
payload map ((item, index) ->{
"forecast2.itemId": item.DMDUNIT,	
"forecast2.locationId":item.LOC,	
"forecast2.demandChannel":item.DMDGROUP,
"forecast2.forecastId":item.FCSTID,	
"forecast2.forecastTypeCode":typeDecider(item.TYPE as String),
"forecast2.modelId":item.MODEL,	
"forecast2.measure.forecastStartDate":item.STARTDATE,	
"forecast2.measure.durationInMinutes": item.DUR,
"forecast2.measure.quantity.value":item.QTY
}
 )
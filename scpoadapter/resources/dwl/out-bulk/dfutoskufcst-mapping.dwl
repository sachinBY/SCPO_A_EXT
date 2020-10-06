%dw 2.0
output application/csv
---
payload map ((item, index) ->{
"itemId": item.ITEM,	
"locationId":item.SKULOC,	
 "demandChannel":item.DMDGROUP,	
"forecastTypeCode":item.TYPE,	
"measure.forecastStartDate":item.STARTDATE,	
"measure.durationInMinutes": item.DUR,	
"measure.quantity.value":item.TOTFCST
}
)
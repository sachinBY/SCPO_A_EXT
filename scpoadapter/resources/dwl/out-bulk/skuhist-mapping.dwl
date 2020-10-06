%dw 2.0
output application/csv 
---
payload map (value, index) -> {

"demandHistory.itemId" : value.ITEM,
"demandHistory.locationId" : value.LOC,
"demandHistory.durationInMinutes" : value.DUR,
"demandHistory.demandQuantity.value" : value.QTY,
"demandHistory.startDateTime" : value.STARTDATE,
"demandHistory.isNetTotalHistory" : value.TYPE

}
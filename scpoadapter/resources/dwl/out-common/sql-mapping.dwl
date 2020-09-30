%dw 2.0
output application/json
---
using (
    sql = "SELECT * FROM " ++ vars.tableName
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition
  else 
  	sql
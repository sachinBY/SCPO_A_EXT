%dw 2.0
output application/xml encoding="UTF-8"
ns forecast urn:jda:ecom:forecast:xsd:3
ns sh http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader
var funCaller = readUrl("classpath://dwl/date-util.dwl")
var udcs = vars.outboundUDCs.fcst[0].dfutoskufcst[0]
fun getConfiguredUDCs(dbOutput) = (((udcs.scpoColumnName) map (obj , index) -> {"value": dbOutput[obj]}).value joinBy ",")
fun concatenate(data) = data.ITEM ++ "," ++ data.SKULOC ++ "," ++ data.DMDGROUP ++ "," ++ data.TYPE ++ "," ++ data.STARTDATE ++ "," ++ data.DUR ++ "," ++ data.TOTFCST
---
{
	forecast#forecastMessage @(
  	({"xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance"}), 
  	({"xmlns:sh": "http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader"}),
  	({"xsi:schemaLocation": "urn:jda:ecom:forecast:xsd:3 ../Schemas/jda/ecom/Forecast.xsd"})
  	): {
		sh#StandardBusinessDocumentHeader: {
			sh#HeaderVersion: p("gs1.sbdh.headerversion"),
			sh#Sender: {
				sh#Identifier @(Authority: "ENTERPRISE"): p("gs1.sbdh.sender")
			},
			(splitBy(p("gs1.sbdh.receiver") , ",") map {
				(sh#Receiver: {
				sh#Identifier @(Authority: "ENTERPRISE"): $
			}) if ($ != null and $ != '')
			}),
			(splitBy(trim(p("gs1.sbdh.dfutoskufcst.receiver")) , ",") map {
				(sh#Receiver: {
				sh#Identifier @(Authority: "ENTERPRISE"): $
				}) if ($ != null and $ != '')
			}),
			sh#DocumentIdentification: {
				sh#Standard: "GS1",
				sh#TypeVersion: p("gs1.sbdh.typeversion") as Number,
				sh#InstanceIdentifier: (vars.uuid),
				sh#Type: "forecast",
				sh#CreationDateAndTime: now()
			},
			sh#BusinessScope: {
				sh#Scope: {
					sh#Type: "SCHEMA_GUID

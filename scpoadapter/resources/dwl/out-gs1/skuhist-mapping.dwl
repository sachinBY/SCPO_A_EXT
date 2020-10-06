%dw 2.0
output application/xml encoding="UTF-8"
ns demand_history urn:jda:ecom:demand_history:xsd:3
ns sh http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader
var funCaller = readUrl("classpath://dwl/date-util.dwl")
var demandHistory = vars.outboundUDCs.skuhist[0].skuhist[0]
---
{
	demand_history#demandHistoryMessage @(({
		"xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance"
	}), 
  	({
		"xmlns:sh": "http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader"
	}), 
  	({
		"xsi:schemaLocation": "urn:jda:ecom:demand_history:xsd:3 ../Schemas/jda/ecom/DemandHistory.xsd"
	})): {
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
			(splitBy(trim(p("gs1.sbdh.skuhist.receiver")) , ",") map {
				(sh#Receiver: {
				sh#Identifier @(Authority: "ENTERPRISE"): $
				}) if ($ != null and $ != '')
			}),
			sh#DocumentIdentification: {
				sh#Standard: "GS1",
				sh#TypeVersion: p("gs1.sbdh.typeversion") as Number,
				sh#InstanceIdentifier: (vars.uuid),
				sh#Type: "demandHistory",
				sh#CreationDateAndTime: now()
			},
			sh#BusinessScope: {
				sh#Scope: {
					sh#Type: "SCHEMA_GUIDE",
					sh#InstanceIdentifier: p("gs1.sbdh.scope.skuhistidentifier")
				}
			}
		},
		(payload map {
			demandHistory: {
				creationDateTime: now(),
				documentStatusCode: "ORIGINAL",
				documentActionCode: "ADD",
				(avpList: {
					(demandHistory map (udc , value) -> {
						(eComStringAttributeValuePairList @(attributeName: udc.hostColumnName): $[upper(udc.scpoColumnName)]) if ($[upper(udc.scpoColumnName)] != null and $[upper(udc.scpoColumnName)] != "")
					})
				}) if (demandHistory != null and sizeOf (demandHistory) > 0),
				itemIdentifier: $.ITEM,
				locationIdentifier: $.LOC,
				durationInMinutes: $.DUR,
				demandQuantity: {
					value: $.QTY
				},
				startDateTime: $.STARTDATE,
				isNetTotalHistory: $.TYPE
			}
		})
	}
}

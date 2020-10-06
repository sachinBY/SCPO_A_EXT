%dw 2.0
import * from dw::core::Strings
output application/xml encoding="UTF-8"
ns forecast2 urn:jda:ecom:forecast2:xsd:3
ns sh http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader
var funCaller = readUrl("classpath://dwl/date-util.dwl")
var udcs = vars.outboundUDCs.fcst[0].fcst[0]
var DEFAULT_VALUE='DEFAULT'
fun typeDecider(data)= if(data == '1') 'BASE' else if(data == '2') 'AGG_MKT_ACT' else if(data == '3') 'ST_FCST_LCK_ADJ' else if(data=='4') 'RECONCILE' else if(data == '5') 'PROMOTIONAL' else if(data == '6') 'OVERRIDE' else if(data=='7') 'MKT_ACT' else if(data=='8') 'DT_DRV_EVNT' else if(data=='9') 'TRG_IMP' else if(data=='99') 'MIG_EVNT' else DEFAULT_VALUE
---
{
  forecast2#forecast2Message @(({"xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance"}), 
  	({"xmlns:sh": "http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader"}), 
  	({"xsi:schemaLocation": "urn:jda:ecom:planned_supply:xsd:3 ../Schemas/jda/ecom/Forecast2.xsd"})): {
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
			(splitBy(trim(p("gs1.sbdh.fcst.receiver")) , ",") map {
				(sh#Receiver: {
				sh#Identifier @(Authority: "ENTERPRISE"): $
				}) if ($ != null and $ != '')
			}),
	      sh#DocumentIdentification: {
	        sh#Standard: upper(p("gs1.fcst.out.message") as String default ""),
	        sh#TypeVersion: p("gs1.sbdh.typeversion") as Number,
	        sh#InstanceIdentifier: (vars.uuid),
	        sh#Type: p("gs1.fcst.messageType") as String default "",
	        sh#CreationDateAndTime: now()
	      },
	      sh#BusinessScope: {
	        sh#Scope: {
	          sh#Type: "SCHEMA_GUIDE",
	          sh#InstanceIdentifier: p("gs1.sbdh.scope.identifier")
	        }
	      }
    }, 
    (payload map {
    	forecast2:{
    		itemId: $.DMDUNIT,
    		locationId: $.LOC,
    		demandChannel: $.DMDGROUP,
    		forecastId: $.FCSTID,
    		forecastTypeCode: typeDecider($.TYPE as String),
    		modelId:$.MODEL,
    		measure:{
    			forecastStartDate: substringBefore($.STARTDATE,"T"),
    			durationInMinutes: $.DUR,
    			quantity:{
    				value: $.QTY,
    			}
    		},
    		(avpList: {
    			(udcs map (udc , value) -> {
	        		(eComStringAttributeValuePairList @(attributeName: udc.hostColumnName): $[upper(udc.scpoColumnName)]) if ($[upper(udc.scpoColumnName)] != null and $[upper(udc.scpoColumnName)] != "")
	        	})
    		}) if(udcs != null and udcs != "")
    	}
    		
    })
  }
 }
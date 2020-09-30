%dw 2.0
output application/xml  
ns planned_supply urn:jda:ecom:planned_supply:xsd:3
ns sh http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader
var funCaller = readUrl("classpath://dwl/date-util.dwl")
var recship = vars.outboundUDCs.recship[0].recship[0]
---
{
  planned_supply#plannedSupplyMessage @(({"xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance"}), 
  	({"xmlns:sh": "http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader"}), 
  	({"xsi:schemaLocation": "urn:jda:ecom:planned_supply:xsd:3 ../Schemas/jda/ecom/PlannedSupply.xsd"})): {
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
			(splitBy(trim(p("gs1.sbdh.recship.receiver")) , ",") map {
				(sh#Receiver: {
				sh#Identifier @(Authority: "ENTERPRISE"): $
				}) if ($ != null and $ != '')
			}),
	      sh#DocumentIdentification: {
	        sh#Standard: "GS1",
	        sh#TypeVersion: p("gs1.sbdh.typeversion") as Number,
	        sh#InstanceIdentifier: (vars.uuid),
	        sh#Type: "plannedSupply",
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
    	plannedSupply: {
	        creationDateTime: now(),
	        documentStatusCode: "ORIGINAL",
	        documentActionCode: "ADD",
	        (avpList: {
	        	(recship map (udc , value) -> {
	        		(eComStringAttributeValuePairList @(attributeName: udc.hostColumnName): $[upper(udc.scpoColumnName)]) if ($[upper(udc.scpoColumnName)] != null and $[upper(udc.scpoColumnName)] != "")
	        	})
	        }) if (recship != null and sizeOf (recship) > 0),
	        plannedSupplyIdentification: ({
				item: {
					gtin: "00000000000000", 
					additionalTradeItemIdentification @(additionalTradeItemIdentificationTypeCode:"BUYER_ASSIGNED"): $.item
				},
				shipTo: {
					gln: "0000000000000", 
					additionalPartyIdentification @(additionalPartyIdentificationTypeCode:"UNKNOWN"): $.dest
				},
				shipFrom: {
					gln: "0000000000000", 
					additionalPartyIdentification: $.source
				}
				
        }),
        "type": "REC_SHIP",
         plannedSupplyDetail: {
        	scheduledOnHandDate: funCaller.formatSCPOToGS1($.schedarrivdate),
        	requestedDeliveryDate: funCaller.formatSCPOToGS1($.needarrivdate),
        	requestedShipDate: funCaller.formatSCPOToGS1($.needshipdate),
			availableForSaleDate: funCaller.formatSCPOToGS1($.earliestselldate),
			supplyExpirationDate: funCaller.formatSCPOToGS1($.expdate),
			requestedQuantity: $.qty,
			movementInformation:{
				sourcingMethod: $.sourcing,
				transportEquipment:{
					transportEquipmentTypeCode: $.transmode
				},
				availableForShipDate: funCaller.formatSCPOToGS1($.availtoshipdate),
				scheduledShipDate: funCaller.formatSCPOToGS1($.schedshipdate),
				despatchDate: funCaller.formatSCPOToGS1($.departuredate),
				reviewDespatchDate: funCaller.formatSCPOToGS1($.orderplacedate),
				deliveryDate: funCaller.formatSCPOToGS1($.deliverydate),
				promotionalOrderAllocationQuantity: $.supporderqty
			}
		}
      }
    })
  }
  }
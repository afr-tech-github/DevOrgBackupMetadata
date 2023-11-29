public with sharing class TriggerHandlerFactory {
    public static Map<String, Amount_Wording_Setting__mdt> wordingFieldMap = new Map<String, Amount_Wording_Setting__mdt>();
    
    public static void createHandler(Schema.sObjectType soType) {
        MetadataWordingSetting wordingSeting = MetadataWordingSetting.getInstance();
        if( wordingSeting.wordingFieldMapbyObject.containsKey(soType.getDescribe().getName())){
            wordingFieldMap = wordingSeting.wordingFieldMapbyObject.get(soType.getDescribe().getName());
        }else{
           wordingFieldMap = new Map<String, Amount_Wording_Setting__mdt>(); 
        }
       
        ITrigger handler = getHandler(soType);

        /*if (handler == null) {
            throw new TriggerException('No Trigger Handler registered for Object Type: ' + soType);
        }*/

        execute(handler);
    }

    private static void execute(ITrigger handler) { 
        
		if(handler == null) {
            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate )){
                for (SObject so : Trigger.new) {
                    Util.wordingFields(so, wordingFieldMap);
                }
            }
            if(Trigger.isBefore && Trigger.isDelete){
                for (SObject so : Trigger.old) {
                    Util.wordingFields(so, wordingFieldMap);
                }
            }
			return;
		}
//        String handlerName = handler.getHandlerName();
//        if (!Test.isRunningTest()) {
//            if (TriggerExecutionHelper.isRunning(handlerName) || TriggerExecutionHelper.isForcedOff(handlerName)) {
//                return;
//            }
//        }

        if (Trigger.isBefore) {
            handler.bulkBefore();
           
            if (Trigger.isDelete) {
				handler.bulkBeforeDelete();
                for (SObject so : Trigger.old) {
                    if(handler != null){
                        handler.beforeDelete(so);
                    }
                }
            }  
			else if (Trigger.isInsert) {
				handler.bulkBeforeInsert();
                for (SObject so : Trigger.new) {
                    if(handler != null){
                        handler.beforeInsert(so);
                    }
                    Util.wordingFields(so, wordingFieldMap);
                }
            } 
			else if (Trigger.isUpdate) {
				handler.bulkBeforeUpdate();
                for (SObject so : Trigger.old) {
                    if(handler != null){
                        handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                    }
                    Util.wordingFields(Trigger.newMap.get(so.Id), wordingFieldMap);
                }
            }
        } 
		else {
            TriggerExecutionHelper.register(handler.getHandlerName());
            handler.bulkAfter();

            if (Trigger.isDelete) {
				handler.bulkAfterDelete();
                for (SObject so : Trigger.old) {
                    handler.afterDelete(so);
                }
            } 
			else if (Trigger.isInsert) {
				handler.bulkAfterInsert();
                for (SObject so : Trigger.new) {
                    handler.afterInsert(so);
                }
            } 
			else if (Trigger.isUpdate) {
				handler.bulkAfterUpdate();
                for (SObject so : Trigger.old) {
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        handler.andFinally();
    }

    private static ITrigger getHandler(Schema.sObjectType soType) {
		
        if (soType == Account.sObjectType) {
            return new AccountTriggerHandler();
        } else if (soType == CustomObject1__c.sObjectType) {
            return new HBLShipmentsTriggerHandler();
        } else if (soType == AnkenMeisai__c.sObjectType) {
            return new HBLSellingBuyingTriggerHandler();
        } else if (soType == MasterAnkenMeisai__c.sObjectType) {
            return new MBLBuyingTriggerHandler();
        } /*else if (soType == MgmtMaster__c.sObjectType) {
            return new ExchangeRateTriggerHandler();
        } */else if (soType == Container_Info__c.sObjectType) {
            return new ContainerInfoTriggerHandler();
        } else if (soType == Contact.sObjectType) {
            return new ContactTriggerHandler();
        } else if (soType == Tax_Ratio__c.sObjectType) {
            return new TaxRatioTriggerHandler();
        } else if (soType == Cargo_Delivery__c.sObjectType) {
            return new CargoDeliveryTriggerHandler();
        } else if (soType == Carrier_Code__c.sObjectType) {
            return new CarrierCodeTriggerHandler();
        } else if (soType == Custom_Clearance__c.sObjectType) {
            return new CustomClearanceTriggerHandler();
        } else if (soType == HS_Code__c.sObjectType) {
            return new HSCodeTriggerHandler();
        } else if (soType == VAT_INVOICE__c.sObjectType) {
            return new VATInvoiceTriggerHandler();
        } else if (soType == INVOICING_VAT__c.sObjectType) {
            return new InvoicingVATTriggerHandler();
        } else if (soType == LoadingLocation__c.sObjectType) {
            return new LoadingLocationTriggerHandler();
        } else if (soType == PurchasingOrder__c.sObjectType) {
            return new PurchasingOrderTriggerHandler();
        } 
        //else if (soType == ConnectPurchasingInvoiceCash__c.sObjectType) {
        //    return new POCashTriggerHandler();
        //} 
        //else if (soType == ConnectInvoicingAndCash__c.sObjectType) {
        //    return new InvoicingCashTriggerHandler();
        //} 
        else if (soType == PurchasingInvoice__c.sObjectType) {
            return new PurchasingInvoiceTriggerHandler();
        } else if (soType == TimeEntry__c.sObjectType) {
            return new TimeEntryTriggerHandler();
        } else if (soType == Transit__c.sObjectType) {
            return new TransitTriggerHandler();
        } else if (soType == Kickback__c.sObjectType) {
            return new KickbackTriggerHandler();
        } 
        //else if (soType == ConnectKickabckCash__c.sObjectType) {
        //    return new KickbackCashTriggerHandler();
        //}
         else if (soType == CASH_BOOK__c.sObjectType) {
            return new CashBookTriggerHandler();
        }
        else if (soType == WorkOrder__c.sObjectType) {
            return new WorkOrderTriggerHandler();
        }
        else if (soType == OtherRevenueCost__c.sObjectType){
            return new OtherRevenueCostTriggerHelper();
        }
        else if (soType == clofor_com_cfs__ContainerGoodSO__c.sObjectType){
            return new ContainerGoodSOTriggerHandler();
        }
        else if (soType == clofor_com_cfs__SALES_ORDER__c.sObjectType){
            return new SalesOrderTriggerHelper();
        }

        return null;
    }

    public static void isBeforeDelContainerNumber(List<clofor_com_cfs__Container_Info__c> lstOld){
        String shipId = '';
        String ConId = '';
        for(clofor_com_cfs__Container_Info__c info : lstOld){
            shipId = info.clofor_com_cfs__HBL_SHIPMENT__c;
            ConId = info.Id;
        }
        system.debug('lstOld :' + lstOld);
        clofor_com_cfs__CustomObject1__c ship = [Select 
        Id,
        clofor_com_cfs__Container__c,clofor_com_cfs__ContainerNumber__c,
        clofor_com_cfs__Container2__c,clofor_com_cfs__ContainerNumber2__c,
        clofor_com_cfs__Container3__c,clofor_com_cfs__ContainerNumber3__c,
        clofor_com_cfs__Container4__c,clofor_com_cfs__ContainerNumber4__c,
        clofor_com_cfs__Container5__c,clofor_com_cfs__ContainerNumber5__c,
        clofor_com_cfs__Container6__c,clofor_com_cfs__ContainerNumber6__c,
        clofor_com_cfs__Container7__c,clofor_com_cfs__ContainerNumber7__c
        
        From clofor_com_cfs__CustomObject1__c 
        Where Id =: shipId];
        system.debug('ship1 :' +ship);
        List<clofor_com_cfs__Container_Info__c> lstinfo = [Select 
        Id,
        clofor_com_cfs__Container__c 
        From clofor_com_cfs__Container_Info__c 
        Where clofor_com_cfs__HBL_SHIPMENT__c =: shipId AND Id !=: ConId];
        system.debug('lstinfo :'+lstinfo);
        Integer count = 0;
        Integer count2 = 0;
        Integer count3 = 0;
        Integer count4 = 0;
        Integer count5 = 0;
        Integer count6 = 0;
        Integer count7 = 0;
        for(clofor_com_cfs__Container_Info__c inf : lstinfo){
            
            if(ship.clofor_com_cfs__Container__c == inf.clofor_com_cfs__Container__c){
                count ++;
            }else if(ship.clofor_com_cfs__Container2__c == inf.clofor_com_cfs__Container__c){
                count2 ++;
            }
            else if(ship.clofor_com_cfs__Container3__c == inf.clofor_com_cfs__Container__c){
                count3 ++;
            }
            else if(ship.clofor_com_cfs__Container4__c == inf.clofor_com_cfs__Container__c){
                count4 ++;
            }
            else if(ship.clofor_com_cfs__Container5__c == inf.clofor_com_cfs__Container__c){
                count5 ++;
            }
            else if(ship.clofor_com_cfs__Container6__c == inf.clofor_com_cfs__Container__c){
                count6 ++;
            }
            else if(ship.clofor_com_cfs__Container7__c == inf.clofor_com_cfs__Container__c){
                count7 ++;
            }
        }
        system.debug('count :' +count +count2 +count3 +count4 +count5 +count6 +count7);
        if(count != 0){
            ship.clofor_com_cfs__ContainerNumber__c = count;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber__c = null;
            ship.clofor_com_cfs__Container__c = null;
        }
        if(count2 != 0){
            ship.clofor_com_cfs__ContainerNumber2__c = count2;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber2__c = null;
            ship.clofor_com_cfs__Container2__c = null;
        }
        if(count3 != 0){
            ship.clofor_com_cfs__ContainerNumber3__c = count3;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber3__c = null;
            ship.clofor_com_cfs__Container3__c = null;
        }
        if(count4 != 0){
            ship.clofor_com_cfs__ContainerNumber4__c = count4;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber4__c = null;
            ship.clofor_com_cfs__Container4__c = null;
        }
        if(count5 != 0){
            ship.clofor_com_cfs__ContainerNumber5__c = count5;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber5__c = null;
            ship.clofor_com_cfs__Container5__c = null;
        }
        if(count6 != 0){
            ship.clofor_com_cfs__ContainerNumber6__c = count6;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber6__c = null;
            ship.clofor_com_cfs__Container6__c = null;
        }
        if(count7 != 0){
            ship.clofor_com_cfs__ContainerNumber7__c = count7;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber7__c = null;
            ship.clofor_com_cfs__Container7__c = null;
        }
        system.debug('ship :'+ship);
        try {
            update ship;
        } catch (DmlException e){
            System.debug('ship mes: '+e.getMessage());
        }


    }

}
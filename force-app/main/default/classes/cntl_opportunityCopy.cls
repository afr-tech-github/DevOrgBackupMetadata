global with sharing class cntl_opportunityCopy {
    // 2021/09/19 Chien Truong Minh Add Start
    private static final List<String> SHIPMENT_FILEDS_COPY = new List<String> {
        'clofor_com_cfs__CarrierType__c'
        ,'clofor_com_cfs__TranporationType__c'
        ,'clofor_com_cfs__Field1__c'
        ,'clofor_com_cfs__shipper__c'
        ,'clofor_com_cfs__Cnee__c'
        ,'clofor_com_cfs__Notifyparty__c'
        ,'clofor_com_cfs__DeliveryAgent__c'
        ,'clofor_com_cfs__CARGO_TYPE__c'
        ,'clofor_com_cfs__Item__c'
        ,'clofor_com_cfs__POL__c'
        ,'clofor_com_cfs__POD__c'
        ,'clofor_com_cfs__PortOfLoadingDetail__c'
        ,'clofor_com_cfs__PortOfDischargeDetail__c'
        ,'clofor_com_cfs__PlaceOfHouseBLIssued__c'
        ,'clofor_com_cfs__Partner__c'
        ,'clofor_com_cfs__ADDRESS_ON_B_L__c'
        ,'clofor_com_cfs__CNEE_ADDRESS_ON_B_L__c'
        ,'clofor_com_cfs__NOTIFY_ADDRESS_ON_B_L__c'
        ,'clofor_com_cfs__QuotationPaymentCondition__c'
        ,'clofor_com_cfs__SUB_RECORD_TYPE__c'
        ,'clofor_com_cfs__GoodsDescriptiononAN__c'
        ,'clofor_com_cfs__GOODS_ATTACHMENT__c'
        ,'clofor_com_cfs__PlaceofDeliveryshowonPOD__c'
        // 2021/09/19 Chien Truong Minh Add End      
        // 2022/05/05 Quan Do Add Start
        ,'clofor_com_cfs__Vessle__c'
        ,'clofor_com_cfs__Voy_No__c'
        ,'clofor_com_cfs__CONTAINERSEALNO__c'
        // ,'clofor_com_cfs__HBL__c'
        ,'clofor_com_cfs__Master_B_L__c'
        ,'clofor_com_cfs__Freight_Collect_Prepaid__c'
        ,'clofor_com_cfs__Prepaid_at__c'
        ,'clofor_com_cfs__Payable_at__c'
        ,'clofor_com_cfs__D_O_type__c'  
        ,'clofor_com_cfs__BLtype__c'
        ,'clofor_com_cfs__No_of_Original_BL__c'
        ,'clofor_com_cfs__SecondNotifyParty__c'
        // ,'clofor_com_cfs__PlaceOfHouseBLIssued__c'
        ,'clofor_com_cfs__DATE_OF_HOUSE_BL_ISSUED__c'
        ,'clofor_com_cfs__Marks_and_Numbers__c'
        ,'clofor_com_cfs__Freight_and_charges__c'
        ,'clofor_com_cfs__carton__c'
        ,'clofor_com_cfs__Place_Of_Receipt__c'
        ,'clofor_com_cfs__UnitType__c'
        ,'clofor_com_cfs__GrossWeight__c'
        ,'clofor_com_cfs__weight__c'
        ,'clofor_com_cfs__Place_Of_Delivery__c'
        ,'clofor_com_cfs__CBM__c'
        ,'clofor_com_cfs__FinalDestination__c'
        ,'clofor_com_cfs__DOCUMENT_CLOSING_TIME__c'
        ,'clofor_com_cfs__NumberOfContainers__c'
        ,'clofor_com_cfs__CARGO_CLOSING_TIME__c'
        ,'clofor_com_cfs__Remarks__c'
        ,'clofor_com_cfs__ETD__c'
        ,'clofor_com_cfs__ETA__c'
        ,'clofor_com_cfs__BookingStatus__c'
        ,'clofor_com_cfs__BookingDate__c'
        ,'clofor_com_cfs__HouseBookingNo__c'
        ,'clofor_com_cfs__MASTER_BOOKINGNO__c'
        ,'clofor_com_cfs__No_Of_LoadingConfirmation__c'
        ,'clofor_com_cfs__BookingNv__c'
        ,'clofor_com_cfs__MSurrender__c'
        ,'clofor_com_cfs__LoadLocation__c'
        ,'clofor_com_cfs__FormattedETA__c'
        ,'clofor_com_cfs__MAWB__c'
        ,'CreatedDate'
        // 2022/05/05 Quan Do Add End
    };
      

    webService static String cloneFullShipment(String sourceShipmentId) {
        Savepoint sp;
        try {
            String clonedShipmentId = '';
            CustomObject1__c sourceShipment;

            sourceShipment = get_OppoData(sourceShipmentId);
            sp = Database.setSavepoint();

            if (sourceShipment != null) {
                List<AnkenMeisai__c> MeiList = get_MeisaiData(sourceShipmentId);
                if (MeiList != null) {
                    CustomObject1__c clonedShipment = ins_OppoData(sourceShipment, false);

                    if (clonedShipment != null) {
                        if (PermissionValidationUtil.isCreatableHBLBuying()) {
                            ins_MeiData(clonedShipment, MeiList, false);
                            clonedShipment.AccountingClosingStatus__c = null;
                            if (PermissionValidationUtil.isEditableHBL()) {
                                clonedShipment = [SELECT FlgCopy__c FROM CustomObject1__C WHERE Id = :clonedShipment.Id];
                                clonedShipment.FlgCopy__c = null;
                               
                                FlsService.doUpdate(clonedShipment);

                                clonedShipmentId = clonedShipment.id;
                            }
                        }
                    }
                }
            }

            return clonedShipmentId;
        } catch (Exception ex) {
            if (sp != null) {
                Database.rollback(sp);
            }
            throw ex;
        }
    }

    @AuraEnabled
    public static string getUserLanguage(){
        return UserInfo.getLanguage();
    }

    @AuraEnabled
    public static String cloneFullShipment_lightning(String sourceShipmentId) {
        Savepoint sp;
        try {
            String clonedShipmentId = '';
            CustomObject1__c sourceShipment;            
            sourceShipment = get_OppoData(sourceShipmentId);
            sp = Database.setSavepoint();

            // CopyFullDataResponse res = new CopyFullDataResponse();

            if (sourceShipment != null) {
                List<AnkenMeisai__c> MeiList = get_MeisaiData(sourceShipmentId);
                if (MeiList != null) {
                    CustomObject1__c clonedShipment = ins_OppoData(sourceShipment, false);
                    if (clonedShipment != null) {
                        if (PermissionValidationUtil.isCreatableHBLBuying()) {                        
                            ins_MeiData(clonedShipment, MeiList, false);
                            //res.MeiList = insertMeiDataForFullCopy(clonedShipment, MeiList, false);
                            clonedShipment.AccountingClosingStatus__c = null;
                            if (PermissionValidationUtil.isEditableHBL()) {
                                clonedShipment = [SELECT FlgCopy__c FROM CustomObject1__C WHERE Id = :clonedShipment.Id];
                                clonedShipment.FlgCopy__c = null;

                                FlsService.doUpdate(clonedShipment);

                                clonedShipmentId = clonedShipment.id;
                            }
                        }
                    }
                }
            }
            // res.clonedShipmentId = clonedShipmentId;
            return clonedShipmentId;
            // return JSON.serialize(res);
        } catch (Exception ex) {
            if (sp != null) {
                Database.rollback(sp);
            }
            throw ex;
        }
    }

    class CopyFullDataResponse{
        public id clonedShipmentId {get; set;}
        public List<AnkenMeisai__c> MeiList {get; set;}
    }

    @AuraEnabled
    public static String init_lingtning(Id oppoid) {
        Savepoint sp;
        try {
            String clonedShipmentId = '';
            CustomObject1__c sourceShipment;
            sourceShipment = get_OppoData(oppoid);
            sp = Database.setSavepoint();

            if (sourceShipment != null) {
                List<AnkenMeisai__c> MeiList = get_MeisaiData(oppoid);
                if (MeiList != null) {
                    CustomObject1__c clonedShipment = ins_OppoData(sourceShipment, true);

                    if (clonedShipment != null) {
                        if (PermissionValidationUtil.isCreatableHBLBuying()) {
                            ins_MeiData(clonedShipment, MeiList, true);
                            clonedShipment.AccountingClosingStatus__c = null;
                            if (PermissionValidationUtil.isEditableHBL()) {
                                clonedShipment = [SELECT FlgCopy__c FROM CustomObject1__C WHERE Id = :clonedShipment.Id];
                                clonedShipment.FlgCopy__c = null;

                                sp = Database.setSavepoint();
                                FlsService.doUpdate(clonedShipment);

                                clonedShipmentId = clonedShipment.id;
                            }
                        }
                    }
                }
            }

            return clonedShipmentId;
        } catch (Exception ex) {
            if (sp != null) {
                Database.rollback(sp);
            }
            throw ex;
        }
    }

    webService static String init(Id oppoid) {
        Savepoint sp;
        try {
            String clonedShipmentId = '';
            CustomObject1__c sourceShipment;
            sourceShipment = get_OppoData(oppoid);
            sp = Database.setSavepoint();

            if (sourceShipment != null) {
                List<AnkenMeisai__c> MeiList = get_MeisaiData(oppoid);
                if (MeiList != null) {
                    CustomObject1__c clonedShipment = ins_OppoData(sourceShipment, true);

                    if (clonedShipment != null) {
                        if (PermissionValidationUtil.isCreatableHBLBuying()) {
                            ins_MeiData(clonedShipment, MeiList, true);
                            clonedShipment.AccountingClosingStatus__c = null;
                            if (PermissionValidationUtil.isEditableHBL()) {
                                clonedShipment = [SELECT FlgCopy__c FROM CustomObject1__C WHERE Id = :clonedShipment.Id];
                                clonedShipment.FlgCopy__c = null;

                                FlsService.doUpdate(clonedShipment);

                                clonedShipmentId = clonedShipment.id;
                            }
                        }
                    }
                }
            }

            return clonedShipmentId;
        } catch (Exception ex) {
            if (sp != null) {
                Database.rollback(sp);
            }
            throw ex;
        }
    }

    webService static String cloneShallowCopy(ID inOppoId) {
        Savepoint sp;
        try {
            inOppoId = StringUtils.escapeSingleQuotes(inOppoId);
            String soql = getCreatableFieldsSOQL('CustomObject1__c', 'Id = \'' + inOppoId + '\'');
            CustomObject1__c shipment = (CustomObject1__c) Database.query(soql);
            CustomObject1__c clonedShipment = shipment.clone(false, true);
            clonedShipment.Original_WKID__c = shipment.Name;
            clonedShipment.Field1__c = shipment.Field1__c;
            clonedShipment.HBL__c = '';
            clonedShipment.Master_B_L__c = '';
            // clonedShipment.DeliveryDate__c = null;
            // clonedShipment.DateOfSending__c = null;
            clonedShipment.ETD__c = null;
            clonedShipment.ETA__c = null;
            // clonedShipment.CustomsReleaseDay__c = null;
            // clonedShipment.DateOfSending__c = null;
            // clonedShipment.DeadlineForPaymentOfInvoices__c = null;
            clonedShipment.FlgCopy__c = null;
            clonedShipment.QuotationVer__c = 1;
            clonedShipment.ContainerSeal_No__c = null;
            clonedShipment.ContainerSealNo__c = null;
            // clonedShipment.Container_Measurement_Details__c = null;
            // clonedShipment.Container_Details_SL__c = null;
            clonedShipment.CARGO_CLOSING_TIME__c = null;
            clonedShipment.DOCUMENT_CLOSING_TIME__c = null;
            // clonedShipment.DebitNote_duedate__c = null;
            // clonedShipment.DeadlineForPaymentOfExpense__c = null;
            clonedShipment.DevanningDate__c = null;
            clonedShipment.GOODS_ATTACHMENT__c = null ;
            // clonedShipment.MARKS_NUMBERS_ATTACHMENT__c = null;
            clonedShipment.Marks_and_Numbers__c = null;
            clonedShipment.MASTER_BOOKINGNO__c = null;
            // clonedShipment.SOIDCopy__c = null;
            clonedShipment.ApprovalStatus__c = null;
            clonedShipment.SalesAccountedDate__c = null;
            // clonedShipment.ParentFTMSSO__c = null;          

            resetFieldDataByRecordType(clonedShipment);

            if (PermissionValidationUtil.isCreatableHBL()) {
                sp = Database.setSavepoint();
                FlsService.doInsert(clonedShipment);
                return clonedShipment.Id;
            }
            return '';
        } catch (Exception ex) {
            if (sp != null) {
                Database.rollback(sp);
            }
            throw ex;
        }
    }

    webService static String copyFieldsFromMasterAnken(String customOjbId, String masterAnkenID) {
        customOjbId = StringUtils.escapeSingleQuotes(customOjbId);
        masterAnkenID = StringUtils.escapeSingleQuotes(masterAnkenID);

        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isEditableHBL()
                && PermissionValidationUtil.isAccessibleMBL()) {
            String soql = getCreatableFieldsSOQL('CustomObject1__c', 'Id=\'' + StringUtils.escapeSingleQuotes(customOjbId) + '\'');
            CustomObject1__c shipment = (CustomObject1__c) Database.query(soql);
            String masterAnkenSOQL = getCreatableFieldsSOQL('MasterAnken__c', 'Id=\'' + StringUtils.escapeSingleQuotes(masterAnkenID) + '\'');
            MasterAnken__c myMasterAK = (MasterAnken__c) Database.query(masterAnkenSOQL);

            if (myMasterAK != null) {
                shipment.POL__c = myMasterAk.MPOL__c;
                shipment.POD__c = myMasterAK.MPOD__c;
                shipment.Place_Of_Delivery__c = myMasterAK.MPlace_Of_Delivery__c;
                shipment.Place_Of_Receipt__c = myMasterAK.MPlace_Of_Receipt__c;
                shipment.ETD__c = myMasterAK.METD__c;
                shipment.ETA__c = myMasterAK.META__c;
                shipment.Vessle__c = myMasterAK.MVessel__c;
                shipment.Voy_No__c = myMasterAK.MVoy_No__c;
                shipment.Devan__c = myMasterAK.MDevan__c;
                shipment.DevanningDate__c = myMasterAK.MDevanningDate__c;
                shipment.TransitV__c = myMasterAK.MTRANSIT_VESSEL__c;
                shipment.TS__c = myMasterAK.MTRANSIT_PORT__c;
                shipment.T_ETD__c = myMasterAK.MTRANSIT_T_ETD__c;
                shipment.Master_B_L__c = myMasterAK.MMaster_B_L_No__c;

                if (myMasterAK.bondedtimetoCFS__c != null) {
                    shipment.LoadingTime__c = Date.newInstance(myMasterAK.bondedtimetoCFS__c.year(), myMasterAK.bondedtimetoCFS__c.month(), myMasterAK.bondedtimetoCFS__c.day()) ;
                }

                if (PicklistReference.CONSOLIDATION_TYPE_CONSOLIDATION.equals(shipment.ConsolidationType__c)) {
                    shipment.ContainerSeal_No__c = ContainerInfoService.extractContainerNo(myMasterAK.MContainer_No__c);
                } else if (PicklistReference.CONSOLIDATION_TYPE_MULTIPLE_BL.equals(shipment.ConsolidationType__c)) {
                    shipment.ContainerSeal_No__c = myMasterAK.MContainer_No__c;
                }

                try {
                    FlsService.doUpdate(shipment);
                } catch (Exception e) {
                }
            }
        }

        return customOjbId;
    }

    webService static String copyFieldsFromMaasterAnken(ID inOppoId) {
        inOppoId = StringUtils.escapeSingleQuotes(inOppoId);

        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isEditableHBL()
                && PermissionValidationUtil.isAccessibleMBL()) {
            String soql = getCreatableFieldsSOQL('CustomObject1__c', 'Id=\'' + StringUtils.escapeSingleQuotes(inOppoId) + '\'');
            CustomObject1__c shipment = (CustomObject1__c) Database.query(soql);

            if (shipment.MasterAnkenName__c != null) {
                String masterAnkenSOQL = getCreatableFieldsSOQL('MasterAnken__c', 'Id=\'' + shipment.MasterAnkenName__c + '\'');
                MasterAnken__c myMasterAK = (MasterAnken__c) Database.query(masterAnkenSOQL);
                if (myMasterAK != null) {
                    shipment.POL__c = myMasterAk.MPOL__c;
                    shipment.POD__c = myMasterAK.MPOD__c;
                    shipment.Place_Of_Delivery__c = myMasterAK.MPlace_Of_Delivery__c;
                    shipment.Place_Of_Receipt__c = myMasterAK.MPlace_Of_Receipt__c;

                    if (myMasterAK.METD__c != null) {
                        shipment.ETD__c = myMasterAK.METD__c;
                    }
                    if (myMasterAK.META__c != null) {
                        shipment.ETA__c = myMasterAK.META__c;
                    }
                    if (myMasterAK.MVessel__c != null) {
                        shipment.Vessle__c = myMasterAK.MVessel__c;
                    }
                    if (myMasterAK.MVoy_No__c != null) {
                        shipment.Voy_No__c = myMasterAK.MVoy_No__c;
                    }
                    if (myMasterAK.MDevan__c != null) {
                        shipment.Devan__c = myMasterAK.MDevan__c;
                    }
                    //if (myMasterAK.MDevanRep__c != null) {
                    //    shipment.DevanRep__c = myMasterAK.MDevanRep__c;
                    //}

                    if (myMasterAK.MDevanningDate__c != null) {
                        shipment.DevanningDate__c = myMasterAK.MDevanningDate__c;
                    }
                    if (myMasterAK.MTRANSIT_VESSEL__c != null) {
                        shipment.TransitV__c = myMasterAK.MTRANSIT_VESSEL__c;
                    }
                    if (myMasterAK.MTRANSIT_PORT__c != null) {
                        shipment.TS__c = myMasterAK.MTRANSIT_PORT__c;
                    }
                    if (myMasterAK.MTRANSIT_T_ETD__c != null) {
                        shipment.T_ETD__c = myMasterAK.MTRANSIT_T_ETD__c;
                    }
                    if (myMasterAK.MDevanWarehouse__c != null) {
                        shipment.LoadLocation__c = myMasterAK.MDevanWarehouse__c;
                    }
                    if (myMasterAK.bondedtimetoCFS__c != null) {
                        shipment.LoadingTime__c = Date.newInstance(myMasterAK.bondedtimetoCFS__c.year(), myMasterAK.bondedtimetoCFS__c.month(), myMasterAK.bondedtimetoCFS__c.day()) ;
                    }
                    if (PicklistReference.CONSOLIDATION_TYPE_CONSOLIDATION.equals(shipment.ConsolidationType__c)) {
                        shipment.ContainerSeal_No__c = ContainerInfoService.extractContainerNo(myMasterAK.MContainer_No__c);
                    } else if (PicklistReference.CONSOLIDATION_TYPE_MULTIPLE_BL.equals(shipment.ConsolidationType__c)) {
                        shipment.ContainerSeal_No__c = myMasterAK.MContainer_No__c;
                    }

                    FlsService.doUpdate(shipment);
                }
            }
        }

        return inOppoId;
    }

    webservice static String copyMBLWithBuyingDetails(String mblId) {
        String clonedMBLId = cloneMBL(mblId);
        if (!StringUtils.isEmpty(clonedMBLId)) {
            cloneMBLBuyingDetails(mblId, clonedMBLId);
            return clonedMBLId;
        }
        return null;
    }

    webservice static String cloneMBL(String mblId) {
        if (PermissionValidationUtil.isCreatableMBL() && PermissionValidationUtil.isAccessibleMBL()) {
            String soqlMBLQuery = getCreatableFieldsSOQL('MasterAnken__c', 'Id = \'' + StringUtils.escapeSingleQuotes(mblId) + '\'');
            MasterAnken__c mblRecord = (MasterAnken__c) Database.query(soqlMBLQuery);
            List<MasterAnken__c> mblRecords = new List<MasterAnken__c>();
            mblRecords.add(mblRecord);

            List<MasterAnken__c> clonedMBLRecords = mblRecords.deepClone();
            MasterAnken__c clonedMBLRecord = clonedMBLRecords.get(0);

            clonedMBLRecord.Internal_Memo__c = 'Cloned from ' + mblId;
            clonedMBLRecord.MContainer_No__c = null;
            clonedMBLRecord.MMaster_B_L_No__c = null;
            clonedMBLRecord.MVessel__c = null;
            clonedMBLRecord.MVoy_No__c = null;
            clonedMBLRecord.Mcarton_c__c = null;
            clonedMBLRecord.Gross_Weight__c = null;
            clonedMBLRecord.MCBM__c = null;
            clonedMBLRecord.METD__c = null;
            clonedMBLRecord.META__c = null;
            clonedMBLRecord.NO_HOUSE_B_L__c = null;
            clonedMBLRecord.MContainer_No__c = null;
            clonedMBLRecord.MDevanningDate__c = null;
            clonedMBLRecord.CYBONDEDTIME__c = null;
            clonedMBLRecord.bondedtimetoCFS__c = null;
            clonedMBLRecord.MTRANSIT_T_ETD__c = null;
            clonedMBLRecord.SECONDSWITCH_BL__c = null;
            clonedMBLRecord.MTRANSIT_VESSEL__c = null;
            clonedMBLRecord.MContainerNumber__c = null;
            clonedMBLRecord.MContainerNumber2__c = null;
            clonedMBLRecord.MContainer__c = null;
            clonedMBLRecord.MContainer2__c = null;

            FlsService.doInsert(clonedMBLRecord);

            return clonedMBLRecord.Id;
        }

        return null;      
    }

    private static CustomObject1__c ins_OppoData(CustomObject1__c Oppo, Boolean resetFields) {
        if (PermissionValidationUtil.isCreatableHBL()) {
            List<CustomObject1__c> OppoList = new List<CustomObject1__c>();
            List<CustomObject1__c> clnOppoList = new List<CustomObject1__c>();
            Map<String, Id> mapRecordTypes = retrieveRecordTypeIdsByNames();

            OppoList.add(Oppo);

            clnOppoList = OppoList.deepClone();

            clnOppoList[0].Field1__c = Oppo.Field1__c;
            clnOppoList[0].Original_WKID__c = Oppo.Name;
            clnOppoList[0].AccountingClosingStatus__c = null;
            clnOppoList[0].EBooking__c = null;
            //2022/05/19 QuanDo add
            // if (Oppo.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_EXPORT_RT) || Oppo.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_EXPORT_LOCK_RT) || Oppo.RecordTypeId == mapRecordTypes.get(Constants.AIR_EXPORT_RT) || Oppo.RecordTypeId == mapRecordTypes.get(Constants.AIR_EXPORT_LOCK_RT)){
                // clnOppoList[0].SalesAccountedDate__c = Oppo.ETD__c;
            // } else if (Oppo.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_IMPORT_RT) || Oppo.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_IMPORT_LOCK_RT) || Oppo.RecordTypeId == mapRecordTypes.get(Constants.AIR_IMPORT_RT) || Oppo.RecordTypeId == mapRecordTypes.get(Constants.AIR_IMPORT_LOCK_RT)){
                // clnOppoList[0].   = Oppo.ETA__c;
            // } else {
                // clnOppoList[0].SalesAccountedDate__c = Date.newInstance(Oppo.CreatedDate.year(), Oppo.CreatedDate.month(), Oppo.CreatedDate.day());
            // }


            if (resetFields) {
                resetFieldDataByRecordType(clnOppoList[0]);
            } else {
                // Reset unique fields
                clnOppoList[0].HBL__c = '';
                clnOppoList[0].HAWB__c = null;
                clnOppoList[0].REFNO__c = null;

                //exclude fields from Full Copy (commented by Thong 20190715)
                clnOppoList[0].Container__c = null;
                clnOppoList[0].Container2__c = null;
                clnOppoList[0].Container3__c = null;
                clnOppoList[0].Container4__c = null;
                clnOppoList[0].Container5__c = null;
                clnOppoList[0].Container6__c = null;
                clnOppoList[0].Container7__c = null;               
                clnOppoList[0].ContainerNumber__c = null;
                clnOppoList[0].ContainerNumber2__c = null;
                clnOppoList[0].ContainerNumber3__c = null;
                clnOppoList[0].ContainerNumber4__c = null;
                clnOppoList[0].ContainerNumber5__c = null;    
                clnOppoList[0].ContainerNumber6__c = null;  
                clnOppoList[0].ContainerNumber7__c = null;            
                clnOppoList[0].status__c = null;
                clnOppoList[0].DeliveryService_required__c = '0';
                // clnOppoList[0].Container_Measurement_Details__c = null;
                // clnOppoList[0].Container_Details_SL__c = null;
                clnOppoList[0].CONTAINERSEALNO__c = null;
                // clnOppoList[0].Container_Measurement_Details__c = null;
                // clnOppoList[0].Container_Details_SL__c = null;
                // clnOppoList[0].SOIDCopy__c = null;
                clnOppoList[0].ApprovalStatus__c = null;
                clnOppoList[0].SalesAccountedDate__c = null;
                clnOppoList[0].JobRequestID__c = null;
                clnOppoList[0].CustomizedShipOrderID__c = null;
                clnOppoList[0].CustomizedShipmentOrderID2__c = null;
                clnOppoList[0].ContainerDetailBLType2__c = null;
                clnOppoList[0].ContainerDetailSIType2__c = null;
                // clnOppoList[0].ParentFTMSSO__c = null;
      //exclude fields from full Copy (commented by Kwon 20200301)                   
                // clnOppoList[0].ETD__c = null;
                // clnOppoList[0].ETA__c = null;
                clnOppoList[0].MonthlyFMSSOID__c = null;
                clnOppoList[0].MonthlyHBLID__c = null;
                clnOppoList[0].YearlyFMSSOID__c = null;  
                clnOppoList[0].DATE_OF_HOUSE_BL_ISSUED__c = null;  
                clnOppoList[0].DATE_OF_MASTER_BL_ISSUED__c = null;  
                // clnOppoList[0].DeliveryDate__c = null;  
                clnOppoList[0].DOCUMENT_CLOSING_TIME__c = null;  
                clnOppoList[0].CARGO_CLOSING_TIME__c = null;                 
                clnOppoList[0].BookingDate__c = null;  
                clnOppoList[0].MASTER_BOOKINGNO__c = null;      
                // clnOppoList[0].Master_B_L__c = null;  
                clnOppoList[0].SalesAccountedDate__c = null;  
                clnOppoList[0].CarrierCodeMBLNo__c = null;
                clnOppoList[0].NvoccCodeHBLNo__c = null;      
                clnOppoList[0].Filing_Time__c = null;    
                      
                resetRecordType(clnOppoList[0]);
            }
			
            FlsService.doInsert(clnOppoList[0]);
            return clnOppoList[0];
        } else {
            return null;
        }
    }

    private static void resetFieldDataByRecordType(CustomObject1__c shipment) {
        Map<String, Id> mapRecordTypes = retrieveRecordTypeIdsByNames();

        if (shipment.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_EXPORT_RT)) {
            shipment.Vessle__c = null;
            shipment.Number_of_Containers__c = null;
            shipment.CutDay__c = null;
            shipment.BookingNo__c = null;
        } else if (shipment.RecordTypeId == mapRecordTypes.get(Constants.AIR_IMPORT_RT)) {
            shipment.FlightNo__c = null;
        } else if (shipment.RecordTypeId == mapRecordTypes.get(Constants.AIR_EXPORT_RT)) {
            shipment.Number_of_Containers__c = null;
            shipment.CutDay__c = null;
            shipment.BookingNo__c = null;
            shipment.FlightNo__c = null;
        } /*else if (shipment.RecordTypeId == mapRecordTypes.get(Constants.AIR_EXPORT_LOCK_RT)) {
            shipment.RecordTypeId = mapRecordTypes.get(Constants.AIR_EXPORT_RT);
        } else if (shipment.RecordTypeId == mapRecordTypes.get(Constants.AIR_IMPORT_LOCK_RT)) {
            shipment.RecordTypeId = mapRecordTypes.get(Constants.AIR_IMPORT_RT);
        } else if (shipment.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_EXPORT_LOCK_RT)) {
            shipment.RecordTypeId = mapRecordTypes.get(Constants.OCEAN_EXPORT_RT);
        } else if (shipment.RecordTypeId == mapRecordTypes.get(Constants.OCEAN_IMPORT_LOCK_RT)) {
            shipment.RecordTypeId = mapRecordTypes.get(Constants.OCEAN_IMPORT_RT);
        }*/

        // Reset unique fields
        shipment.HBL__c = '';
        shipment.HAWB__c = null;
        shipment.REFNO__c = null;

        //exclude fields from Partial Copy (commented by Thong 20190715)
        // shipment.Master_B_L__c = '';
        // shipment.DeliveryDate__c = null;
        // shipment.DateOfSending__c = null;
        // shipment.ETD__c = null;
        // shipment.ETA__c = null;
        // shipment.CustomsReleaseDay__c = null;
        // shipment.DateOfSending__c = null;
        // shipment.DeadlineForPaymentOfInvoices__c = null;
        shipment.FlgCopy__c = 'true';
        shipment.QuotationVer__c = 1;
        shipment.ContainerSeal_No__c = null;
        shipment.ContainerSealNo__c = null;
        // shipment.Container_Measurement_Details__c = null;
        // shipment.Container_Details_SL__c = null;
        shipment.CARGO_CLOSING_TIME__c = null;
        shipment.DOCUMENT_CLOSING_TIME__c = null;
        // shipment.DebitNote_duedate__c = null;
        // shipment.DeadlineForPaymentOfExpense__c = null;
        shipment.DevanningDate__c = null;
        shipment.GOODS_ATTACHMENT__c = null ;
        // shipment.MARKS_NUMBERS_ATTACHMENT__c = null;
        shipment.Marks_and_Numbers__c = null;
        shipment.MASTER_BOOKINGNO__c = null;

        // shipment.MAWB__c = null;
        shipment.ExchangeRate__c = null;
        shipment.BUYING__c = null;
        // shipment.CustomsReleaseDay__c = null;
        // shipment.InvoiceIssueStatus__c = null;
        // shipment.DebitIssueStatus__c = null;
        // shipment.Submit_to_Account__c = null;
        // shipment.HistoryOfUnpaid__c = null;
        // shipment.Remark__c = null;
        shipment.Memo__c = null;
        // shipment.DeadlineForPaymentOfInvoices__c = null;
        // shipment.DeadlineForPaymentOfExpense__c = null;
        // shipment.DebitNote_duedate__c = null;
        // shipment.DateOfSending__c = null;
        // shipment.SeikyusyoRemark__c = null;
        // shipment.ParMailAutoSent__c = false;
        // shipment.CusMailAutoSent__c = false;
        shipment.weight__c = null;
        // shipment.chargable_weight__c = null;
        // shipment.NET_NET_Weight__c = null;
        shipment.MasterAnkenName__c = null;
        // shipment.Voy_No__c = null;
        shipment.FlightNo__c = null;
        shipment.carton__c = null;
        shipment.CBM__c = null;
        // shipment.BL_withdraw__c = null;
        shipment.ContainerSeal_No__c = null;
        shipment.T_ETD__c = null;
        // shipment.Vessle__c = null;
        shipment.status__c = null;
        // shipment.A_N_Password__c = null;
        // shipment.BREAL_BULK_INVOICE_PASSWORD__c = null;
        // shipment.B_L_PASSWORD__c = null;
        // shipment.D_O_PASSWORD__c = null;
        // shipment.CHECK_B_L_PASSWORD__c = null;
        // shipment.DEBIT_CREDIT_PASSWORD__c = null;
        // shipment.FREIGHT_MEMO_PASSWORD__c = null;
        // shipment.S_I_PASSWORD__c = null;
        // shipment.QUOTATION_PASSWORD__c = null;
        // shipment.CC_PASSWORD__c = null;
        // shipment.A_N_LINK__c = null;
        // shipment.B_L_LINK__c = null;
        // shipment.D_O_LINK__c = null;
        // shipment.BREAK_BULK_INVOICE_LINK__c = null;
        // shipment.CHECK_B_L_LINK__c = null;
        // shipment.DEBIT_CREDIT_LINK__c = null;
        // shipment.FREIGHT_MEMO_LINK__c = null;
        // shipment.S_I_LINK__c = null;
        // shipment.QUOTATION_LINK__c = null;
        // shipment.CC_LINK__c = null;
        // shipment.Document_Receipt_Time__c = null;
        // shipment.First_Approval_Time__c = null;
        // shipment.FreeDemurrage__c = null;
        // shipment.FreeDemurrageTime__c = null;
        // shipment.FreeDetentionTime__c = null;
        // shipment.PrinteDate_ED__c = null;
        shipment.Filing_Time__c = null;
        // shipment.Style_Number__c = null;
        // shipment.DO_NO__c = null;
        // shipment.FUMIGATION_STATUS__c = null;
        shipment.Remarks__c = null;
        // shipment.Damage_Remarks__c = null;
        shipment.DevanningDate__c = null;
        shipment.No_Of_LoadingConfirmation__c = null;
        shipment.LoadingTime__c = null;
        // shipment.SwitchB_L__c = null;
        shipment.TransitV__c = null;
        // shipment.QuotationNO__c = null;
        // shipment.QuotationPrintDate__c = null;
        // shipment.Frequency__c = null;
        // shipment.SubmisionDueDate__c = null;
        // shipment.TargetRate__c = null;
        // shipment.QuoationDescription__c = null;
        // shipment.ExpiryDate__c = null;
        // shipment.ExpanseCondition__c = null;
        // shipment.ReimbursementCondition__c = null;
        shipment.QuotationPaymentCondition__c = null;
        // shipment.TT__c = null;
        // shipment.FirstReceptionDate__c = null;
        // shipment.OrderCompletedDate__c = null;
        // shipment.AcquiringDate__c = null;
        shipment.Container__c = null;
        shipment.Container2__c = null;
        shipment.Container3__c = null;
        shipment.Container4__c = null;
        shipment.Container5__c = null;
        shipment.Container6__c = null;
        shipment.Container7__c = null;
        shipment.ContainerNumber__c = null;
        shipment.ContainerNumber2__c = null;
        shipment.ContainerNumber3__c = null;
        shipment.ContainerNumber4__c = null;
        shipment.ContainerNumber5__c = null;        
        shipment.ContainerNumber6__c = null;        
        shipment.ContainerNumber7__c = null;        
        // shipment.SOIDCopy__c = null;
        shipment.ApprovalStatus__c = null;
        shipment.SalesAccountedDate__c = null;      
        shipment.JobRequestID__c = null;
        shipment.CustomizedShipOrderID__c = null;
        shipment.CustomizedShipmentOrderID2__c = null;
        shipment.ContainerDetailBLType2__c = null;
        shipment.ContainerDetailSIType2__c = null;
        // shipment.ParentFTMSSO__c = null;  
        
    //exclude fields from partial Copy (commented by Kwon 20200301)           
        shipment.MonthlyFMSSOID__c = null;
        shipment.MonthlyHBLID__c = null;
        shipment.YearlyFMSSOID__c = null;  
        shipment.DATE_OF_HOUSE_BL_ISSUED__c = null;  
        shipment.DATE_OF_MASTER_BL_ISSUED__c = null;              
        shipment.BookingDate__c = null;  
        shipment.CarrierCodeMBLNo__c = null;
        shipment.NvoccCodeHBLNo__c = null;      
        shipment.Filing_Time__c = null;  
    //exclude fields from partial Copy (commented by QuanDO 20220905)    
        shipment.CONTAINERSEALNO__c = '';
        resetRecordType(shipment);
    }

    private static Map<String, Id> retrieveRecordTypeIdsByNames() {
        String objectName = Constants.NAMESPACE + 'CustomObject1__c';
        Map<String, Id> mapRecordTypes = new Map<String, Id>();

        List<RecordType> recordTypes = [
                SELECT DeveloperName, Id
                FROM RecordType
                WHERE SObjectType = :objectName AND IsActive = True
        ];

        for (RecordType rt : recordTypes) {
            mapRecordTypes.put(rt.DeveloperName, rt.Id);
        }

        return mapRecordTypes;
    }

    private static void ins_MeiData(CustomObject1__c Oppo, List<AnkenMeisai__c> MeiList, Boolean resetBuyingUnitPrice) {
        if (PermissionValidationUtil.isCreatableHBLBuying()) {
            List<AnkenMeisai__c> clnMeiList = new List<AnkenMeisai__c>();
            clnMeiList = MeiList.deepclone();

            for (AnkenMeisai__c temp : clnMeiList) {
                temp.Anken__c = Oppo.id;
                temp.NyukinKakuninzumi__c = false;
                temp.Nyukingaku__c = 0;
                temp.ReceivingBank__c = null;
                temp.ReceiptanceDate_del__c = null;
                temp.SellDetail__c = null;
                temp.SiharaiKakuninzumi__c = false;
                temp.Siharaigaku__c = 0;
                temp.PaymentDate__c = null;
                temp.Shiharaikouza__c = null;
                temp.BuyDetail__c = null;
                temp.Cost_Allocation_Margin_USD__c = null;
                temp.Cost_Allocation_Margin__c = null;

                if (resetBuyingUnitPrice) {
                    temp.BuyTankaJPY__c = temp.Tariff__r.BuyKingaku__c;
                    temp.BuyTankaUSD__c = temp.Tariff__r.BuyAmountUSD__c;
                    temp.SellTankaJPY__c = temp.Tariff__r.SellKingakuJPY__c;
                    temp.SellTankaUSD__c = temp.Tariff__r.SellAmountUSD__c;    
                }

                //temp.CurrencyConversionSelling__c = null;
                //temp.CurrencyConversionBuying__c = null;
                //temp.ExchangeRateSellingUpdate__c = null;
                //temp.ExchangeRateBuyingUpdate__c = null;
                //temp.ExchangeRequiredForBuying__c = null;
                temp.AccountingClosingStatus__c = null;

                temp.AMOUNT_PAID_SELLING_USD__c = null;
                temp.AMOUNT_PAID_BUYING_USD__c = null;
                temp.VAT_INVOICE_ISSUE_STATUS__c = false;
                temp.TAX_ADJUSTMENTSELL__c = null;
                temp.TAX_ADJUSTMENT__c = null;
                temp.payment_category__c = null;
                temp.BANKTRANSITTYPE__c = null;
                temp.ReceivingBank__c = null;
                temp.PayingBank__c = null;
                temp.Payer__c = null;
                temp.actual_payer__c = null;
                //Nov 12 2018 added for bad-debt
                temp.BadDebtCheckBox__c =  false;
                temp.CollectionDueDate__c = null;
                temp.PaymentDueDate__c = null;          
                temp.ApprovalStatus__c = null;    
                temp.BankAccountForPayment__c = null;         
                temp.InboundVATInvNo__c = null;  
                temp.OutboundVATInvNo__c = null;    
                temp.SalesAccountedDateInvoicing__c = null;   
                //Nov 5 2019 added for Text S/O ID
                temp.TextFTMSSOID__c = null;
                 //Jan 22 2020 added for Bad Debt and Bad Debtor Type
                temp.BadDebt__c = null;
                temp.BadDebtorType__c = null;
                
            }

            FlsService.doInsert(clnMeiList);
        }
    }

    private static List<AnkenMeisai__c> insertMeiDataForFullCopy(CustomObject1__c Oppo, List<AnkenMeisai__c> MeiList, Boolean resetBuyingUnitPrice) {
        if (PermissionValidationUtil.isCreatableHBLBuying()) {
            List<AnkenMeisai__c> clnMeiList = new List<AnkenMeisai__c>();
            clnMeiList = MeiList.deepclone();

            for (AnkenMeisai__c temp : clnMeiList) {
                temp.Anken__c = Oppo.id;
                temp.NyukinKakuninzumi__c = false;
                temp.Nyukingaku__c = 0;
                temp.ReceivingBank__c = null;
                temp.ReceiptanceDate_del__c = null;
                temp.SellDetail__c = null;
                temp.SiharaiKakuninzumi__c = false;
                temp.Siharaigaku__c = 0;
                temp.PaymentDate__c = null;
                temp.Shiharaikouza__c = null;
                temp.BuyDetail__c = null;
                temp.Cost_Allocation_Margin_USD__c = null;
                temp.Cost_Allocation_Margin__c = null;

                if (resetBuyingUnitPrice) {
                    temp.BuyTankaJPY__c = temp.Tariff__r.BuyKingaku__c;
                    temp.BuyTankaUSD__c = temp.Tariff__r.BuyAmountUSD__c;
                    temp.SellTankaJPY__c = temp.Tariff__r.SellKingakuJPY__c;
                    temp.SellTankaUSD__c = temp.Tariff__r.SellAmountUSD__c;    
                }

                //temp.CurrencyConversionSelling__c = null;
                //temp.CurrencyConversionBuying__c = null;
                //temp.ExchangeRateSellingUpdate__c = null;
                //temp.ExchangeRateBuyingUpdate__c = null;
                //temp.ExchangeRequiredForBuying__c = null;
                temp.AccountingClosingStatus__c = null;

                temp.AMOUNT_PAID_SELLING_USD__c = null;
                temp.AMOUNT_PAID_BUYING_USD__c = null;
                temp.VAT_INVOICE_ISSUE_STATUS__c = false;
                temp.TAX_ADJUSTMENTSELL__c = null;
                temp.TAX_ADJUSTMENT__c = null;
                temp.payment_category__c = null;
                temp.BANKTRANSITTYPE__c = null;
                temp.ReceivingBank__c = null;
                temp.PayingBank__c = null;
                temp.Payer__c = null;
                temp.actual_payer__c = null;
                //Nov 12 2018 added for bad-debt
                temp.BadDebtCheckBox__c =  false;
                temp.CollectionDueDate__c = null;
                temp.PaymentDueDate__c = null;          
                temp.ApprovalStatus__c = null;    
                temp.BankAccountForPayment__c = null;         
                temp.InboundVATInvNo__c = null;  
                temp.OutboundVATInvNo__c = null;    
                temp.SalesAccountedDateInvoicing__c = null;   
                //Nov 5 2019 added for Text S/O ID
                temp.TextFTMSSOID__c = null;
                 //Jan 22 2020 added for Bad Debt and Bad Debtor Type
                temp.BadDebt__c = null;
                temp.BadDebtorType__c = null;
            }
            return clnMeiList;
            // FlsService.doInsert(clnMeiList);
        }
        return null;
    }

    @AuraEnabled
    public static void insert1MeiData(String meiDataJson){
        System.debug('meiDataJson: ' + meiDataJson);
        AnkenMeisai__c meiData = (AnkenMeisai__c) JSON.deserialize(meiDataJson, AnkenMeisai__c.class);
        System.debug('insert1MeiData: ' + meiData);
        FlsService.doInsert(meiData);
    }

    private static CustomObject1__c get_OppoData(id OppoId) {
        if (PermissionValidationUtil.isAccessibleHBL()) {
            Schema.SObjectType sobj = CustomObject1__c.Schema.SObjectType;
            // 2021/09/19 Chien Truong Minh Modify Start
            // String wfnms = 'Id, Name, RecordTypeId,' + getCustomFieldsNames(sobj);
            String wfnms = 'Id, Name, RecordTypeId,' + String.join(SHIPMENT_FILEDS_COPY, ',');
            // 2021/09/19 Chien Truong Minh Modify End            
            CustomObject1__c[] objectList = Database.query('SELECT ' + wfnms + ' FROM ' + sobj +
                    ' WHERE Id = \'' + OppoId + '\' LIMIT 1');

            return objectList[0] ;
        }

        return null;
    }

    private static List<AnkenMeisai__c> get_MeisaiData(Id OppoId) {
        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying()) {
            List<AnkenMeisai__c> objectList = new List<AnkenMeisai__c>();
            Schema.SObjectType sobj = AnkenMeisai__c.Schema.SObjectType;
            string parentField = 'Anken__r.Id';
            String wfnms = 'Id, Name, RecordTypeId, Tariff__r.BuyKingaku__c, Tariff__r.BuyAmountUSD__c, Tariff__r.SellKingakuJPY__c, Tariff__r.SellAmountUSD__c,' + getCustomFieldsNames(sobj);
            objectList = Database.query('select ' + wfnms + ' from ' + sobj + ' where ' + parentField + ' =\'' + OppoId + '\'');
            return ObjectList ;
        }

        return null;
    }

    private static String getCustomFieldsNames(Schema.SObjecttype tp) {
        String res = '';
        Map<String, Schema.sObjectField> fmap = tp.getDescribe().fields.getMap();
        for (String fn:fmap.keySet()) {
            if (fn.endswith('__c')) {
                res = res + fn + ',';
            }
        }
        return res.substring(0, res.length() - 1);
    }

    private static string getCreatableFieldsSOQL(String objectName, String whereClause) {
        String selects = 'Name, ';

        if (objectName.contains('MasterAnken__c')) {
            selects = '';
        }

        objectName = Constants.NAMESPACE + objectName;

        if (whereClause == null || whereClause == '') {
            return null;
        }

        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();

        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()) { // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()) { // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }

        if (!selectFields.isEmpty()) {
            for (string s:selectFields) {
                selects += s + ',';
            }
            if (selects.endsWith(',')) {
                selects = selects.substring(0, selects.lastIndexOf(','));
            }

        }

        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;

    }

    private static void cloneMBLBuyingDetails(String originalMBLId, String clonedMBLId) {
        if (PermissionValidationUtil.isCreatableMBLBuying() && PermissionValidationUtil.isAccessibleMBLBuying()) {
            String soqlMBLBuyingQuery = getCreatableFieldsSOQL('MasterAnkenMeisai__c', 'MasterAnken__c = \'' + StringUtils.escapeSingleQuotes(originalMBLId) + '\'');
            List<MasterAnkenMeisai__c> mblBuyingRecords = (List<MasterAnkenMeisai__c>) Database.query(soqlMBLBuyingQuery);

            if (mblBuyingRecords != null && mblBuyingRecords.size() > 0) {
                List<MasterAnkenMeisai__c> clonedmblBuyingRecords = mblBuyingRecords.deepClone();
                List<MasterAnkenMeisai__c> toBeUpdated = new List<MasterAnkenMeisai__c>();

                for (MasterAnkenMeisai__c mam : clonedmblBuyingRecords) {
                    mam.MasterAnken__c = clonedMBLId;
                    mam.BuyTankaUSD__c = null;
                    mam.BuyTankaJPY__c = null;
                    mam.Suryo__c = null;
                    toBeUpdated.add(mam);
                }

                FlsService.doInsert(toBeUpdated);
            }
        }
    }

    private static void resetRecordType(CustomObject1__c shipment) {
        String recordTypeName = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);
        String nonLockedRecordTypeId = null;

        if (String.isNotBlank(recordTypeName)) {
            if (Constants.OCEAN_IMPORT_LOCK_RT.equalsIgnoreCase(recordTypeName)) {
                nonLockedRecordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.OCEAN_IMPORT_RT);
            } else if (Constants.OCEAN_EXPORT_LOCK_RT.equalsIgnoreCase(recordTypeName)) {
                nonLockedRecordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.OCEAN_EXPORT_RT);
            } else if (Constants.AIR_EXPORT_LOCK_RT.equalsIgnoreCase(recordTypeName)) {
                nonLockedRecordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.AIR_EXPORT_RT);
            } else if (Constants.AIR_IMPORT_LOCK_RT.equalsIgnoreCase(recordTypeName)) {
                nonLockedRecordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.AIR_IMPORT_RT);
            } else if (Constants.DOMESTIC_TRANSPORTATION_LOCK_RT.equalsIgnoreCase(recordTypeName)) {
                nonLockedRecordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.DOMESTIC_TRANSPORTATION_RT);
            } else if (Constants.CROSS_BOARDER_LOCK_RT.equalsIgnoreCase(recordTypeName)) {
                nonLockedRecordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.CROSS_BOARDER_RT);
            } else if (Constants.LOGISTICS_SERVICE_LOCK.equalsIgnoreCase(recordTypeName)) {
                nonLockedRecordTypeId = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.LOGISTICS_SERVICE);
            }

            if (String.isNotBlank(nonLockedRecordTypeId)) {
                shipment.RecordTypeId = nonLockedRecordTypeId;
            }
        }
    }
}
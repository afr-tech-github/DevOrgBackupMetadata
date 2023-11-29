import {LightningElement, api, track} from 'lwc';
import getAnkenData from "@salesforce/apex/FMS_SortByCurrentSOController.getListAnkenMeisaiByShipment";
import saveListAnken from "@salesforce/apex/FMS_SortByCurrentSOController.saveListAnken";
import deleteAnkenMeisai from "@salesforce/apex/FMS_SortByCurrentSOController.deleteAnkenMeisai";
import { loadStyle } from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/CustomDataTable';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class LwcSortBySo extends NavigationMixin(LightningElement) {
    @api recordId;
    @api lstAnken;
    @api lstAnkenColumns;
    @api lstAnkenSellingColumns;
    @api picklistChargeUnit;
    @api draftValues = [];
    @api isLoaded = false;

    lastSavedData = [];

    selectedRows = [];

    async connectedCallback(){
        await this.getDataInit(this.recordId);
        const actions = [{ label: "Edit", name: "action_edit" }, { label: "Delete", name: "action_delete" }];

        this.lstAnkenColumns = [
            {
                type: "action", fixedWidth: 60,
                typeAttributes: { rowActions: actions, menuAlignment: "left" }
            },
            {label: "F/TMS SO", fieldName: "AnkenName", type: "text", initialWidth: 120 }, // master-detail
            {label: "F/TMS Bill ID", fieldName: "AnkenUrl", type: "url", initialWidth: 150,
                typeAttributes: {
                    target: '_blank',
                    label: { fieldName: "Name" }
                }
            }, // name
            {label: "Invoice S/B Display No", fieldName: "clofor_com_cfs__SeikyuBangou__c", type: "number", editable: true, initialWidth: 250}, // number
            {label: "Service Name", fieldName: "clofor_com_cfs__Tariff__c", type: "lookup", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: 'Select Service Name',
                    uniqueId: { fieldName: 'Id' }, //pass Id of current record to lookup for context
                    object: "clofor_com_cfs__TariffMaster__c",
                    icon: "clofor_com_cfs__TariffMaster__c",
                    label: "Service Name",
                    displayFields: "Name",
                    displayFormat: "Name",
                    filters: "",
                    fieldApiName: "clofor_com_cfs__Tariff__c",
                    isDisplay: { fieldName: 'CheckedRow' },
                    valueId: { fieldName: 'clofor_com_cfs__Tariff__c' }
                }
            }, // lookup
            {label: "Bill Name at Print(Local)", fieldName: "clofor_com_cfs__InsatuyouSyohin__c", type: "text", editable: true, initialWidth: 250}, // text
            {label: "Payment to-Buying", fieldName: "clofor_com_cfs__PaymentTo__c", type: "lookup", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: 'Select Payment to-Buying',
                    uniqueId: { fieldName: 'Id' }, //pass Id of current record to lookup for context
                    object: "Account",
                    icon: "",
                    label: "Payment to-Buying",
                    displayFields: "Name",
                    displayFormat: "Name",
                    filters: "",
                    fieldApiName: "clofor_com_cfs__PaymentTo__c",
                    valueId: { fieldName: 'clofor_com_cfs__PaymentTo__c' }
                }
            }, // lookup
            {label: "Charge Quantity", fieldName: "clofor_com_cfs__Suryo__c", type: "number", editable: true, initialWidth: 120}, // number
            {label: "Currency-Buying", fieldName: "clofor_com_cfs__CurrencyBuying__c", type: "picklist", editable: true, fixedWidth: 200,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__CurrencyBuying__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__CurrencyBuying__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }, // picklist
            {label: "Unit Price of Buying(Local)", fieldName: "clofor_com_cfs__BuyTankaJPY__c", type: "currency", editable: true}, // currency
            {label: "Unit Price of Buying(FCY)", fieldName: "clofor_com_cfs__BuyTankaUSD__c", type: "number", editable: true},  // number
            {label: "Tax Rate-Buying(%)", fieldName: "clofor_com_cfs__BuyTaxInitial__c", type: "percent", editable: true},  // percent
            {label: "Exchange Rate-Buying(Credit)", fieldName: "clofor_com_cfs__KawaseBay__c", type: "number", editable: true}, // number
            {label: "Print", fieldName: "clofor_com_cfs__PrintFlag__c", type: "boolean", editable: true, initialWidth: 60},   // checkbox
            {label: "Amount Buying Incl Tax(Local)", fieldName: "clofor_com_cfs__BuyInTaxAmountJPY__c", type: "currency", editable: true}, // currency
            {label: "Currency Conversion for Buying", fieldName: "clofor_com_cfs__CurrencyConversionBuying__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__CurrencyConversionBuying__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__CurrencyConversionBuying__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            } // picklist
            /*{label: "Invoice to", fieldName: "clofor_com_cfs__Seikyusaki__c", type: "lookup", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: 'Select Invoice to',
                    uniqueId: { fieldName: 'Id' }, //pass Id of current record to lookup for context
                    object: "Account",
                    icon: "Accounts",
                    label: "Invoice to",
                    displayFields: "Name",
                    displayFormat: "Name",
                    filters: "",
                    fieldApiName: "clofor_com_cfs__Seikyusaki__c",
                    valueId: { fieldName: 'clofor_com_cfs__Seikyusaki__c' }
                }
            }, // lookup
            {label: "Charge Unit(Override)", fieldName: "clofor_com_cfs__ChargeUnit__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__ChargeUnit__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__ChargeUnit__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }, // picklist
            {label: "Container Size(Override)", fieldName: "clofor_com_cfs__ContainerSize__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__ContainerSize__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__ContainerSize__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }, // picklist
            {label: "Currency-Selling", fieldName: "clofor_com_cfs__curr__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__curr__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__curr__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }, // picklist
            {label: "Unit Price of Selling(Local)", fieldName: "clofor_com_cfs__SellTankaJPY__c", type: "currency", editable: true, initialWidth: 250}, // currency
            {label: "Unit Price of Selling(FCY)", fieldName: "clofor_com_cfs__SellTankaUSD__c", type: "number", editable: true, initialWidth: 250}, // number
            {label: "Tax Rate-Selling(%)", fieldName: "clofor_com_cfs__TaxInitial__c", type: "percent", editable: true, initialWidth: 250}, // percent
            {label: "Exchange Rate-Selling(Debit)", fieldName: "clofor_com_cfs__KawaseSel__c", type: "number", editable: true, initialWidth: 250}, // number
            {label: "Amount Selling Incl Tax(FCY)", fieldName: "clofor_com_cfs__SellInTaxAmount_USD__c", type: "number", editable: true, initialWidth: 250}, // number
            {label: "Currency Conversion for Selling", fieldName: "clofor_com_cfs__CurrencyConversionSelling__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__CurrencyConversionSelling__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__CurrencyConversionSelling__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }, // picklist*/
        ];

        this.lstAnkenSellingColumns = [
            {
                type: "action", fixedWidth: 60,
                typeAttributes: { rowActions: actions, menuAlignment: "left" }
            },
            {label: "F/TMS SO", fieldName: "AnkenName", type: "text", initialWidth: 120 }, // master-detail
            {label: "F/TMS Bill ID", fieldName: "AnkenUrl", type: "url", initialWidth: 150,
                typeAttributes: {
                    target: '_blank',
                    label: { fieldName: "Name" }
                }
            }, // name
            {label: "Service Name", fieldName: "clofor_com_cfs__Tariff__c", type: "lookup", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: 'Select Service Name',
                    uniqueId: { fieldName: 'Id' }, //pass Id of current record to lookup for context
                    object: "clofor_com_cfs__TariffMaster__c",
                    icon: "clofor_com_cfs__TariffMaster__c",
                    label: "Service Name",
                    displayFields: "Name",
                    displayFormat: "Name",
                    filters: "",
                    fieldApiName: "clofor_com_cfs__Tariff__c",
                    valueId: { fieldName: 'clofor_com_cfs__Tariff__c' }
                }
            }, // lookup
            {label: "Bill Name at Print(Local)", fieldName: "clofor_com_cfs__InsatuyouSyohin__c", type: "text", editable: true, initialWidth: 250}, // text
            {label: "Invoice to", fieldName: "clofor_com_cfs__Seikyusaki__c", type: "lookup", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: 'Select Invoice to',
                    uniqueId: { fieldName: 'Id' }, //pass Id of current record to lookup for context
                    object: "Account",
                    icon: "Accounts",
                    label: "Invoice to",
                    displayFields: "Name",
                    displayFormat: "Name",
                    filters: "",
                    fieldApiName: "clofor_com_cfs__Seikyusaki__c",
                    valueId: { fieldName: 'clofor_com_cfs__Seikyusaki__c' }
                }
            }, // lookup
            {label: "Charge Quantity", fieldName: "clofor_com_cfs__Suryo__c", type: "number", editable: true, initialWidth: 120}, // number
            {label: "Charge Unit(Override)", fieldName: "clofor_com_cfs__ChargeUnit__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__ChargeUnit__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__ChargeUnit__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }, // picklist
            {label: "Container Size(Override)", fieldName: "clofor_com_cfs__ContainerSize__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__ContainerSize__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__ContainerSize__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }, // picklist
            {label: "Currency-Selling", fieldName: "clofor_com_cfs__curr__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__curr__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__curr__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }, // picklist
            {label: "Unit Price of Selling(Local)", fieldName: "clofor_com_cfs__SellTankaJPY__c", type: "currency", editable: true, initialWidth: 250}, // currency
            {label: "Unit Price of Selling(FCY)", fieldName: "clofor_com_cfs__SellTankaUSD__c", type: "number", editable: true, initialWidth: 250}, // number
            {label: "Tax Rate-Selling(%)", fieldName: "clofor_com_cfs__TaxInitial__c", type: "percent", editable: true, initialWidth: 250}, // percent
            {label: "Exchange Rate-Selling(Debit)", fieldName: "clofor_com_cfs__KawaseSel__c", type: "number", editable: true, initialWidth: 250}, // number
            {label: "Amount Selling Incl Tax(FCY)", fieldName: "clofor_com_cfs__SellInTaxAmount_USD__c", type: "number", editable: true, initialWidth: 250}, // number
            {label: "Currency Conversion for Selling", fieldName: "clofor_com_cfs__CurrencyConversionSelling__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__CurrencyConversionSelling__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__CurrencyConversionSelling__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }/*, // picklist
            {label: "Invoice S/B Display No", fieldName: "clofor_com_cfs__SeikyuBangou__c", type: "number", editable: true, initialWidth: 250}, // number
            {label: "Payment to-Buying", fieldName: "clofor_com_cfs__PaymentTo__c", type: "lookup", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: 'Select Payment to-Buying',
                    uniqueId: { fieldName: 'Id' }, //pass Id of current record to lookup for context
                    object: "Account",
                    icon: "",
                    label: "Payment to-Buying",
                    displayFields: "Name",
                    displayFormat: "Name",
                    filters: "",
                    fieldApiName: "clofor_com_cfs__PaymentTo__c",
                    valueId: { fieldName: 'clofor_com_cfs__PaymentTo__c' }
                }
            }, // lookup
            {label: "Currency-Buying", fieldName: "clofor_com_cfs__CurrencyBuying__c", type: "picklist", editable: true, fixedWidth: 200,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__CurrencyBuying__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__CurrencyBuying__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            }, // picklist
            {label: "Unit Price of Buying(Local)", fieldName: "clofor_com_cfs__BuyTankaJPY__c", type: "currency", editable: true}, // currency
            {label: "Unit Price of Buying(FCY)", fieldName: "clofor_com_cfs__BuyTankaUSD__c", type: "number", editable: true},  // number
            {label: "Tax Rate-Buying(%)", fieldName: "clofor_com_cfs__BuyTaxInitial__c", type: "percent", editable: true},  // percent
            {label: "Exchange Rate-Buying(Credit)", fieldName: "clofor_com_cfs__KawaseBay__c", type: "number", editable: true}, // number
            {label: "Print", fieldName: "clofor_com_cfs__PrintFlag__c", type: "boolean", editable: true, initialWidth: 60},   // checkbox
            {label: "Amount Buying Incl Tax(Local)", fieldName: "clofor_com_cfs__BuyInTaxAmountJPY__c", type: "currency", editable: true}, // currency
            {label: "Currency Conversion for Buying", fieldName: "clofor_com_cfs__CurrencyConversionBuying__c", type: "picklist", editable: true, fixedWidth: 250,
                typeAttributes: {
                    placeholder: '--None--'
                    , objectName: 'clofor_com_cfs__AnkenMeisai__c'
                    , fieldApiName: 'clofor_com_cfs__CurrencyConversionBuying__c'
                    , recordtypeId: { fieldName: 'RecordTypeId' }
                    , value: { fieldName: 'clofor_com_cfs__CurrencyConversionBuying__c' } // default value for picklist
                    , context: { fieldName: 'Id' }
                }
            } // picklist*/
        ];

        this.isLoaded = true;

        console.log('Connected');
    }

    getDataInit(shipmentId){
        getAnkenData({
            shipmentID: shipmentId
        })
            .then((result) => {
                if (result) {
                    var rows = result;
                    for(let i = 0; i < rows.length; i++){
                        let row = rows[i];
                        row.AnkenName = row.clofor_com_cfs__Anken__r.Name;
                        row.AnkenUrl = '/' + row.Id;
                        row.CheckedRow = true;
                    }
                    this.lstAnken = rows;
                    this.lastSavedData = JSON.parse(JSON.stringify(this.lstAnken));
                    //console.log('result : ' + this.lstAnken);
                    //console.log('result lastSavedData: ' + JSON.stringify(this.lastSavedData));
                }
            })
            .catch((error) => {
                console.error(error);
            });
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        console.log('row : ' + JSON.stringify(row));

        if (action.name == "action_edit") {
            this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: row.Id,
                            objectApiName: 'clofor_com_cfs__AnkenMeisai__c', // objectApiName is optional
                            actionName: 'edit'
                        }
                    });
        }
        else if (action.name == "action_delete") {
            this.isLoaded = false;
            deleteAnkenMeisai({
                anken: row
            })
            .then((result) => {
                this.getDataInit(this.recordId);
                const event = new ShowToastEvent({
                                      title: "Success!",
                                      message: "Record deleted!",
                                      variant: 'success'
                                  });
                this.dispatchEvent(event);
                this.isLoaded = true;
            })
            .catch((error) => {
                 console.error(error);
                 console.log('error ' + JSON.stringify(error))
                 const event = new ShowToastEvent({
                                       title: "Error!",
                                       message: error,
                                       variant: 'error'
                                   });
                 this.dispatchEvent(event);
                 this.isLoaded = true;
            });
        }
    }

    updateDataValues(updateItem) {
        console.log('updateDataValues ' + JSON.stringify(updateItem));
        let copyData = [... this.lstAnken];
        let index = 0;
        copyData.forEach(item => {
            let key = 'row-';
            key = key + index.toString();
            index = index + 1;

            if(updateItem.id == key){
                for (let field in updateItem) {
                    if(field != 'id'){
                        item[field] = updateItem[field];
                    }
                }
            }

            if (item.Id == updateItem.Id ) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.lstAnken = [...copyData];
    }

    updateDraftValues(updateItem) {
        console.log('updateItem ' + JSON.stringify(updateItem));
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
                if(item.Id === updateItem.id){
                     for (let field in updateItem) {
                         item[field] = updateItem[field];
                     }
                     draftValueChanged = true;
                }
                else{
                    for(let i = 0; i < this.lstAnken.length; i++){
                        let key = '';
                        key = 'row-' + i.toString();
                        if(updateItem.id == key){
                            for (let field in updateItem) {
                                if(field != 'id'){
                                    item[field] = updateItem[field];
                                }
                            }
                            //draftValueChanged = true;
                        }
                    }
                }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
        console.log('updateDraftValues ' + JSON.stringify(this.draftValues));
    }

    handleSelection(event) {
        console.log('handleSelection XXXXX ' + JSON.stringify(event.detail.data));
        event.stopPropagation();
        let dataRecieved = event.detail.data;

        //console.log('handleSelection 1 ' + JSON.stringify(event));
        console.log('handleSelection 1 ' + JSON.stringify(dataRecieved));
        console.log('handleSelection 2 ' + JSON.stringify(this.draftValues));
        let updatedItem;
        if(dataRecieved.fieldApiName == 'clofor_com_cfs__Tariff__c'){
            updatedItem = { Id: dataRecieved.key, clofor_com_cfs__Tariff__c: dataRecieved.selectedId, CheckedRow: dataRecieved.isDisplay };
        }
        else if(dataRecieved.fieldApiName == 'clofor_com_cfs__Seikyusaki__c'){
            updatedItem = { Id: dataRecieved.key, clofor_com_cfs__Seikyusaki__c: dataRecieved.selectedId };
        }
        else if(dataRecieved.fieldApiName == 'clofor_com_cfs__PaymentTo__c'){
            updatedItem = { Id: dataRecieved.key, clofor_com_cfs__PaymentTo__c: dataRecieved.selectedId };
        }
        this.updateDraftValues(updatedItem);
        //this.updateDataValues(updatedItem);
    }

    getSelectedName(event){
        this.selectedRows = event.detail.selectedRows;
        let copyData = [... this.lstAnken];

        copyData.forEach(item => {
            this.selectedRows.forEach(rowSelected => {
                   if(rowSelected.Id == item.Id){
                        item.CheckedRow = true;
                   }
            });
        });
        //console.log('getSelectedName : ' + JSON.stringify(event.detail.selectedRows));
    }

    handleCustomApply(event){
        console.log('handleCustomApply ' + JSON.stringify(event.detail.data));
        //console.log('this.selectedRows ' + JSON.stringify(this.selectedRows));
        let applySelectedRow = [];
        applySelectedRow = this.selectedRows;
        let isApply = event.detail.data;
        //console.log('isApply.isChecked && applySelectedRow.length ' + isApply.isChecked + applySelectedRow.length);
        if(isApply.isChecked && applySelectedRow.length > 0){
            applySelectedRow.forEach(item => {
                console.log('this.selectedRows ' + JSON.stringify(item.Id));
                let updatedItem;
                isApply.key = item.Id;
                if(isApply.fieldApiName == 'clofor_com_cfs__Tariff__c'){
                    updatedItem = { Id: isApply.key, clofor_com_cfs__Tariff__c: isApply.selectedId, CheckedRow: true };
                }
                else if(isApply.fieldApiName == 'clofor_com_cfs__Seikyusaki__c'){
                    updatedItem = { Id: isApply.key, clofor_com_cfs__Seikyusaki__c: isApply.selectedId, CheckedRow: true };
                }
                else if(isApply.fieldApiName == 'clofor_com_cfs__PaymentTo__c'){
                    updatedItem = { Id: isApply.key, clofor_com_cfs__PaymentTo__c: isApply.selectedId, CheckedRow: true  };
                }
                console.log('handleCustomApply updatedItem ' + JSON.stringify(updatedItem));
                console.log('=========================================');
                this.updateDraftValues(updatedItem);
                this.updateDataValues(updatedItem);
            });
        }
    }

    handleChangeApply(event){
        console.log('handleChangeApply checkbox ' + JSON.stringify(event.detail.data));
        //let copyDraftValues = [...this.draftValues];
    }

    handleCustomApplyPicklist(event){
        console.log('====================start=====================');
        console.log('handleCustomApplyPicklist ' + JSON.stringify(event.detail.data));
        let applySelectedRow = [];
        applySelectedRow = this.selectedRows;
        let isApply = event.detail.data;
        if(isApply.isChecked && applySelectedRow.length > 0){
            applySelectedRow.forEach(item => {
                console.log('this.selectedRows ' + JSON.stringify(item.Id));
                let updatedItem;
                isApply.context = item.Id;
                if(isApply.fieldApiName == 'clofor_com_cfs__ChargeUnit__c'){
                    updatedItem = { Id: isApply.context, clofor_com_cfs__ChargeUnit__c: isApply.value };
                }
                else if(isApply.fieldApiName == 'clofor_com_cfs__ContainerSize__c'){
                    updatedItem = { Id: isApply.context, clofor_com_cfs__ContainerSize__c: isApply.value };
                }
                else if(isApply.fieldApiName == 'clofor_com_cfs__curr__c'){
                    updatedItem = { Id: isApply.context, clofor_com_cfs__curr__c: isApply.value };
                }
                else if(isApply.fieldApiName == 'clofor_com_cfs__CurrencyConversionSelling__c'){
                    updatedItem = { Id: isApply.context, clofor_com_cfs__CurrencyConversionSelling__c: isApply.value };
                }
                else if(isApply.fieldApiName == 'clofor_com_cfs__CurrencyBuying__c'){
                    updatedItem = { Id: isApply.context, clofor_com_cfs__CurrencyBuying__c: isApply.value };
                }
                else if(isApply.fieldApiName == 'clofor_com_cfs__CurrencyConversionBuying__c'){
                    updatedItem = { Id: isApply.context, clofor_com_cfs__CurrencyConversionBuying__c: isApply.value };
                }
                console.log('handleCustomApply updatedItem ' + JSON.stringify(updatedItem));
                console.log('=========================================');
                this.updateDraftValues(updatedItem);
                this.updateDataValues(updatedItem);
            });
        }
        console.log('===================end======================');
    }

    picklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log('picklistChanged ' + JSON.stringify(dataRecieved));
        let updatedItem;
        if(dataRecieved.fieldApiName == 'clofor_com_cfs__ChargeUnit__c'){
            updatedItem = { Id: dataRecieved.context, clofor_com_cfs__ChargeUnit__c: dataRecieved.value };
        }
        else if(dataRecieved.fieldApiName == 'clofor_com_cfs__ContainerSize__c'){
            updatedItem = { Id: dataRecieved.context, clofor_com_cfs__ContainerSize__c: dataRecieved.value };
        }
        else if(dataRecieved.fieldApiName == 'clofor_com_cfs__curr__c'){
            updatedItem = { Id: dataRecieved.context, clofor_com_cfs__curr__c: dataRecieved.value };
        }
        else if(dataRecieved.fieldApiName == 'clofor_com_cfs__CurrencyConversionSelling__c'){
            updatedItem = { Id: dataRecieved.context, clofor_com_cfs__CurrencyConversionSelling__c: dataRecieved.value };
        }
        else if(dataRecieved.fieldApiName == 'clofor_com_cfs__CurrencyBuying__c'){
            updatedItem = { Id: dataRecieved.context, clofor_com_cfs__CurrencyBuying__c: dataRecieved.value };
        }
        else if(dataRecieved.fieldApiName == 'clofor_com_cfs__CurrencyConversionBuying__c'){
            updatedItem = { Id: dataRecieved.context, clofor_com_cfs__CurrencyConversionBuying__c: dataRecieved.value };
        }
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    handleCellChange(event) {
        let updateItem = [];
        updateItem = event.detail.draftValues;
        console.log('handleCellChange ' + JSON.stringify(event));
        updateItem.forEach(item => {
            this.updateDraftValues(item);
            this.updateDataValues(item);
        });
    }

    handleSave(event) {
        this.isLoaded = false;
        saveListAnken({
            ankens: this.lstAnken
        })
        .then((result) => {
            console.log('saved data ');
            this.draftValues = [];
            const event = new ShowToastEvent({
                                  title: "Success!",
                                  message: "Record updated!",
                                  variant: 'success'
                              });
            this.dispatchEvent(event);
            this.isLoaded = true;
        })
        .catch((error) => {
            console.error(error);
            console.log('error ' + JSON.stringify(error))
            const event = new ShowToastEvent({
                                  title: "Error!",
                                  message: error.body.pageErrors[0].message,
                                  variant: 'error'
                              });
            this.dispatchEvent(event);
            this.isLoaded = true;
        });
    }

    handleCancel(event) {
        //remove draftValues & revert data changes
        this.lstAnken = JSON.parse(JSON.stringify(this.lastSavedData));
        //console.log('cancel : ' + JSON.stringify(this.lstAnken));
        this.draftValues = [];
        this.selectedRows = [];
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, CustomDataTableResource)
        ]).then((

        ) => { })
    }


}
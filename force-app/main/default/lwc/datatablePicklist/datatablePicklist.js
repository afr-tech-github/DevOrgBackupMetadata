import {LightningElement, api, wire,track} from 'lwc';
import getPicklistValue from "@salesforce/apex/FMS_SortByCurrentSOController.getPicklistValueFromObjectField";
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import ANKEN_MEISAI_OBJECT from '@salesforce/schema/AnkenMeisai__c';

export default class DatatablePicklist extends LightningElement {
    @api label;
    @api value;
    @api options = [];
    @api placeholder;
    @api context;
    @api objectName;
    @api fieldApiName;
    @api recordtypeId;
    @api isChecked = false;

    @track obj;

    connectedCallback(){
        //console.log('options' + JSON.stringify(this.options));
        //console.log('label' + JSON.stringify(this.fieldApiName));
        console.log('recordtypeId' + JSON.stringify(this.recordtypeId));
       this.obj = { fieldApiName: this.fieldApiName, objectApiName: this.objectName};
        console.log('connectedCallback');
        //this.getDataPicklist();
    }
    @wire(getPicklistValuesByRecordType, {recordTypeId: '$recordtypeId', objectApiName: ANKEN_MEISAI_OBJECT})
    loadPicklistValuesByRecordType(result) {
        if(result){
            /*console.log('wire' + this.recordtypeId);
            console.log('++++++++++++++++');
            console.log('recordtypeId : ' + JSON.stringify(this.recordtypeId))
            console.log('obj : ' + JSON.stringify(this.obj))
            console.log(JSON.stringify(result));
            console.log(JSON.stringify(result.data));
            console.log('++++++++++++++++');*/
            let jsonData = result.data;
            if(jsonData != null){
                if(this.fieldApiName == 'clofor_com_cfs__ChargeUnit__c'){
                    this.options = jsonData.picklistFieldValues.clofor_com_cfs__ChargeUnit__c.values;
                }
                else if(this.fieldApiName == 'clofor_com_cfs__ContainerSize__c'){
                    this.options = jsonData.picklistFieldValues.clofor_com_cfs__ContainerSize__c.values;
                }
                else if(this.fieldApiName == 'clofor_com_cfs__curr__c'){
                    this.options = jsonData.picklistFieldValues.clofor_com_cfs__curr__c.values;
                }
                else if(this.fieldApiName == 'clofor_com_cfs__CurrencyConversionSelling__c'){
                    this.options = jsonData.picklistFieldValues.clofor_com_cfs__CurrencyConversionSelling__c.values;
                }
                else if(this.fieldApiName == 'clofor_com_cfs__CurrencyBuying__c'){
                    this.options = jsonData.picklistFieldValues.clofor_com_cfs__CurrencyBuying__c.values;
                }
                else if(this.fieldApiName == 'clofor_com_cfs__CurrencyConversionBuying__c'){
                    this.options = jsonData.picklistFieldValues.clofor_com_cfs__CurrencyConversionBuying__c.values;
                }
            }
            console.log('options' + JSON.stringify(this.options));
        }else{
            console.log('===Error====')
        }
    }

    handleChange(event){
        this.value = event.detail.value;
        //console.log('handleChange ' + JSON.stringify(this.value));
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context,
                        value: this.value,
                        objectName: this.objectName,
                        fieldApiName: this.fieldApiName}
            }
        }));
    }

    changeApply(event){
        if(!this.isChecked){
            this.isChecked = true;
        }
        else this.isChecked = false;

        let isChecked = this.isChecked;
        const evt = new CustomEvent('changeapplypicklist', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail:{
                data: {isChecked}
            }
        });
        this.dispatchEvent(evt);
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        console.log('changeApplyPicklist ' + isChecked);
    }

    apply(event){
        //console.log('apply picklist isChecked ' + this.isChecked);

        const evt = new CustomEvent('customapplypicklist', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context,
                        value: this.value,
                        objectName: this.objectName,
                        fieldApiName: this.fieldApiName,
                        isChecked: this.isChecked
                }
            }
        });
        this.dispatchEvent(evt);

        console.log('finish apply picklist ' + JSON.stringify(evt.detail.data));

        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
    }

    cancel(event){

    }
}
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import OBJECT_CARGO from '@salesforce/schema/Cargo__c';
import OBJECT_WOSLINE from '@salesforce/schema/WOSLineItem__c';

import getCargoDetails from '@salesforce/apex/WMS_QrService.getCargoDetails';
import { validationUtils } from 'c/utilities';

export default class QrLandingV2_CargoFields extends LightningElement {
    @api workerId;
    @api locatorId;
    @api wosId;
    @api cargoId;
    @api get cargo() { return {...this._cargo}; }
    @api get wosLine() { return {...this._wosLine}; }
    @api reportValidity() { return validationUtils.validateFields(this) }

    @wire(getPicklistValuesByRecordType, { objectApiName: OBJECT_CARGO, recordTypeId: '012000000000000AAA' })
    picklistValues_Cargo;
    
    @wire(getPicklistValuesByRecordType, { objectApiName: OBJECT_WOSLINE, recordTypeId: '012000000000000AAA' })
    picklistValues_WosLine;

    @wire(getObjectInfo, { objectApiName: OBJECT_CARGO })
    objInfo_Cargo;

    @wire(getObjectInfo, { objectApiName: OBJECT_WOSLINE })
    objInfo_WosLine;

    @track _cargo = {};
    @track _wosLine = {};

    get _isReady() { return this.picklistValues_Cargo.data && this.picklistValues_WosLine.data && this.objInfo_Cargo.data && this.objInfo_WosLine.data }
    get _isWeight() { return this._cargo && this._cargo.clofor_com_cfs__Product__r && this._cargo.clofor_com_cfs__Product__r.clofor_com_cfs__BillingType__c === 'Weight' }
    get _isUnit() { return this._cargo && this._cargo.clofor_com_cfs__Product__r && this._cargo.clofor_com_cfs__Product__r.clofor_com_cfs__BillingType__c === 'Unit' }
    get _showNote() { return this._wosLine.clofor_com_cfs__CargoStatus__c !== 'Completed' }
    get _lblWeight() { return `${this.objInfo_Cargo.data.fields.clofor_com_cfs__Weight__c.label} (${this._cargo.clofor_com_cfs__Product__r.clofor_com_cfs__WeightUnit__c})` }
    get _optionsCargoStatus() {
        return (
            this.picklistValues_WosLine.data 
            && this.picklistValues_WosLine.data.picklistFieldValues 
            && this.picklistValues_WosLine.data.picklistFieldValues.clofor_com_cfs__CargoStatus__c 
        ) ? this.picklistValues_WosLine.data.picklistFieldValues.clofor_com_cfs__CargoStatus__c.values : [] 
    }


    connectedCallback() {
        this._cargo = {};
        this._wosLine = { 
            clofor_com_cfs__WorkOrderService__c: this.wosId, 
            clofor_com_cfs__Cargo__c: this.cargoId, 
            clofor_com_cfs__Worker__c: this.workerId, 
            clofor_com_cfs__Locator__c: this.locatorId, 
            clofor_com_cfs__CargoStatus__c: 'Completed' 
        };

        getCargoDetails({ wosId: this.wosId, cargoId: this.cargoId })
            .then(data => { this._cargo = {...data} })
            .catch(ex => this.dispatchEvent(new ShowToastEvent({ message: ex.body.message, variant: 'error' })));
    }

    handleInputChange(e) {
        const [obj, field] = e.target.name.split('.');
        let val = e.detail.value;

        if (e.detail.value == null && e.target.dataset.type !== 'Boolean') {
            val = null;
        } else if (e.target.dataset.type === 'Boolean') {
            val = e.target.checked;
        } else if (e.target.dataset.type === 'Integer') {
            val = e.detail.value === '' ? 0 : parseInt(e.detail.value, 10);
        } else if (e.target.dataset.type === 'Decimal') {
            val = e.detail.value === '' ? 0 : parseFloat(e.detail.value);
        }
        this[obj][field] = val;
    }
}
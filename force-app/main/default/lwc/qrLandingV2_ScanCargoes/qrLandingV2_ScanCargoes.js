/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWoCargoesByWosId from '@salesforce/apex/WMS_QrService.getWoCargoesByWosId';
import createCargo from '@salesforce/apex/WMS_QrService.createCargo';

export default class QrLandingV2_ScanCargoes extends LightningElement {
    @api workerId;
    @api locatorId;
    @api wosId;
    @api productId;
    @api focus() { setTimeout(() => { this.template.querySelector('c-cmp_autocomplete').focus() }, 0) }

    @track _isLoading = true;
    @track _cargoId;
    @track _listRecords = [];

    get _options() {
        return (this.productId == null ? this._listRecords : this._listRecords.filter(x => x.clofor_com_cfs__Cargo__r.clofor_com_cfs__Product__c === this.productId))
            .map(x => ({
                customLabel: `
                    <b>${x.clofor_com_cfs__Cargo__r.Name}</b><br/>
                    ${x.clofor_com_cfs__Cargo__r.clofor_com_cfs__Summary__c}
                    ${x.clofor_com_cfs__Cargo__r.clofor_com_cfs__LotQuantity__c > 0 ? ('<br/>Quantity: ' + x.clofor_com_cfs__Cargo__r.clofor_com_cfs__LotQuantity__c) : ''}
                    ${x.clofor_com_cfs__Cargo__r.clofor_com_cfs__Weight__c > 0 ? ('<br/>Weight: ' + x.clofor_com_cfs__Cargo__r.clofor_com_cfs__Weight__c + x.clofor_com_cfs__Cargo__r.clofor_com_cfs__Product__r.clofor_com_cfs__WeightUnit__c) : ''}
                `,
                label: x.clofor_com_cfs__Cargo__r.Name,
                value: x.clofor_com_cfs__Cargo__c
            }))
    }

    /**
     * @param {string} val
     */
    set cargoId(val) {
        this._cargoId = val;
        this.dispatchEvent(new CustomEvent('change', { detail: { 
            value: this._cargoId,
            productId: !val ? null : this._listRecords.find(x => x.clofor_com_cfs__Cargo__c === val).clofor_com_cfs__Cargo__r.clofor_com_cfs__Product__c
        }}));
    }

    @api
    connectedCallback() {
        getWoCargoesByWosId({ wosId: this.wosId })
            .then(data => { this._isLoading = false; this._listRecords = data; })
            .catch(ex => this.dispatchEvent(new ShowToastEvent({ message: ex.body.message, variant: 'error' })));
    }

    handleChange(e) {
        this.cargoId = e.detail.value;
    }

    handleAddNewWoCargo() {
        this._isLoading = true;
        createCargo({ wosId: this.wosId, productId: this.productId })
            .then(data => { 
                this._isLoading = false;
                this._listRecords.push(data);
                this.cargoId = data.clofor_com_cfs__Cargo__c; 
            })
            .catch(ex => {
                this._isLoading = false;
                this.dispatchEvent(new ShowToastEvent({ message: ex.body.message, variant: 'error' }))
            });
    }
}
/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWoProductsByWosId from '@salesforce/apex/WMS_QrService.getWoProductsByWosId';
import createWoProduct from '@salesforce/apex/WMS_QrService.createWoProduct';

export default class QrLandingV2_ScanProducts extends LightningElement {
    @api workerId;
    @api locatorId;
    @api wosId;
    @api 
    get productId() { return this.productId }
    set productId(val) { this._productId = val }

    @track _isLoading = 'fun';
    @track _productId;
    @track _productLookupId; //used for creating WO+Product
    @track _productLookupSearchTerm;
    @track _listRecords = [];

    get _options() {
        return this._listRecords.map(x => ({
            customLabel: `
                <b>${x.clofor_com_cfs__ProductID__r.Name}</b><br/>
                ${x.clofor_com_cfs__ProductID__r.clofor_com_cfs__Summary__c}
            `,
            label: x.clofor_com_cfs__ProductID__r.Name,
            value: x.clofor_com_cfs__ProductID__c
        }));
    }

    connectedCallback() {
        getWoProductsByWosId({ wosId: this.wosId })
            .then(data => { this._isLoading = false; this._listRecords = data; })
            .catch(ex => this.dispatchEvent(new ShowToastEvent({ message: ex.body.message, variant: 'error' })));
    }

    handleInputChange(e) {
        this[e.target.dataset.name] = e.detail.value;
    }

    handleChange(e) {
        this._productId = e.detail.value;
        this.dispatchEvent(new CustomEvent('change', { detail: { value: e.detail.value }}));
    }

    handleAddNewWoProduct(e) {
        this._productLookupSearchTerm = e.detail.value;
        this.template.querySelector('c-cmp_modal').showConfirm({
            title: 'Add WO+Product',
            closeOnConfirm: false,
            onConfirm: () => this.handleCreateWoProduct()
        });
    }

    handleCreateWoProduct() {
        this._isLoading = true;
        createWoProduct({ wosId: this.wosId, productId: this._productLookupId})
            .then(data => { 
                this._isLoading = false;
                this._listRecords.push(data);
                this._productId = this._productLookupId; 
                this._productLookupId = null;
                this.template.querySelector('c-cmp_modal').hide();
                this.dispatchEvent(new CustomEvent('change', { detail: { value: this._productId }}));
            })
            .catch(ex => {
                this._isLoading = false;
                this.dispatchEvent(new ShowToastEvent({ message: ex.body.message, variant: 'error' }))
            });
    }
}